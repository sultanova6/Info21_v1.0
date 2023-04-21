-- 3.1
create or replace function transferred_points_human_readable()
returns table (peer1 varchar, peer2 varchar, poinstamount bigint)
as $$
    begin
        return query (select t1.checking_peer, t1.checked_peer, (t1.points_amount -
                                                               t2.points_amount) as poinstamount
                      from transferred_points as t1
                      join transferred_points as t2 on t1.checking_peer = t2.checked_peer and
                                                      t1.checked_peer = t2.checking_peer and t1.id < t2.id);
    end;
$$ language plpgsql;



-- 3.2
create or replace function peer_task_xp()
returns table(peer varchar, task varchar, xp bigint)
as $$
    select p.checking_peer as peer,
           c.task as task,
           xp.xp_amount as xp
    from p2p p
    join checks c on p.checking_peer = c.peer
    join xp on c.id = xp.check
    where p.state = 'Success'
    order by 1, 2, 3;
$$ language sql;



-- 3.3
create or replace function peer_in_campus(date_to_check date)
returns table(peer varchar)
as $$
select distinct peer
from time_tracking
where date = date_to_check and state = 1
group by 1
having count(state) < 3
order by 1 asc
$$ language sql;



-- 3.4
create or replace function procents_success_fail()
returns table(successfulchecks integer, unsuccessfulchecks integer)
as $$
    select
    trunc(100 * count(*) filter(where state = 'Success')/count(*) filter(where state <> 'Start'), 2) as successfulchecks,
    trunc(100 * count(*) filter(where state = 'Failure')/count(*) filter(where state <> 'Start'), 2) as unsuccessfulchecks
    from verter where state <> 'Start';
$$ language sql;



-- 3.5
create or replace function shanges_prp()
returns table (peer text, points_change integer)
as $$
begin
    return query
        select distinct on (peer)
               peer,
               cast(sum(points_amount) over (partition by peer order by peer, points_amount desc) as integer) as points_change
        from transferred_points
        order by peer, points_amount desc;
end;
$$ language plpgsql;



-- 3.6
create or replace procedure pointschange(in ref refcursor)
as $$
    begin
        open ref for
            with p1 as (select peer1 as peer, sum(poinstamount) as pointschange
            from transferred_points_human_readable()
            group by peer1),
                 p2 as (select peer2 as peer, sum(poinstamount) as pointschange
            from transferred_points_human_readable()
            group by peer2)
        select coalesce(p1.peer, p2.peer) as peer, (coalesce(p1.pointschange, 0) - coalesce(p2.pointschange, 0)) as pointschange
        from p1
        full join p2 on p1.peer = p2.peer
        order by pointschange desc;
    end;
$$ language plpgsql;



-- 3.7
create or replace procedure popular_task(in ref refcursor)
as $$
    begin
        open ref for
            with t1 as (select task, date, count(*) as counts
                        from checks
                        group by task, date),
                 t2 as (select t1.task, t1.date, rank() over (partition by t1.date order by t1.counts) as rank
                        from t1)
            select t2.date, t2.task
            from t2
            where rank = 1;
    end;
$$ language plpgsql;



-- 3.8
create or replace function time_last_checks()
returns time
as $$
declare
    duration time;
begin
    with all_p2p_time as
        (select p."check", (max(p.time) - min(p.time)) as duration
        from p2p p
        group by "check", "check"
        having "check" = max("check") and count(*) = 2)
    select all_p2p_time.duration into duration
    from all_p2p_time
    order by "check" desc
    limit 1;
    return duration;
end;
$$ language plpgsql;



-- 3.9
create or replace procedure speedrunners(ref refcursor, b_name varchar)
as $$
begin
    open ref for
        select c.peer, to_char(max(c.date), 'DD.MM.YYYY') as day from checks c
        join p2p on c.id = p2p.check and p2p.state = 'Success'
                                        and c.task IN (select title from tasks
                                                        where title similar to format('%s[0-9]+_%%', b_name))
        left join verter v on c.id = v.check
        where v.state = 'Success' or v.state is null
        group by c.peer
        having count(distinct c.task) =
               (select count(*) from tasks
                where title similar to format('%s[0-9]+_%%', b_name));
end;
$$ language plpgsql;



-- 3.10
create or replace procedure popular_peer(in ref refcursor)
as $$
    begin
        open ref for
            with ffriends as (select nickname,
                                 (case when nickname = friends.peer_1 then peer_2 else peer_1 end) as frineds
                                  from peers
                                  join friends on peers.nickname = friends.peer_1 or peers.nickname = friends.peer_2),
                 find_recc as (select nickname, count(recommended_peer) as count_rec, recommended_peer
                                     from ffriends
                                     join recommendations on ffriends.frineds = recommendations.peer_nickname
                                     where ffriends.nickname != recommendations.recommended_peer
                                     group by nickname, recommended_peer),
                 find_max as (select nickname, max(count_rec) as max_count
                              from find_recc
                              group by nickname)
            select find_recc.nickname as peer, recommended_peer
            from find_recc
            join find_max on find_recc.nickname = find_max.nickname and
                             find_recc.count_rec = find_max.max_count;
    end;
$$ language plpgsql;



-- 3.11
create function procents(block1 varchar, block2 varchar)
returns table (start1 bigint, start2 bigint, startboth bigint, didntstartany bigint)
as $$
declare
    count_peers int := (select count(peers.nickname)
                        from peers);
begin
    return query
        with start1 as (select distinct peer
                               from checks
                               where checks.task similar to concat(block1, '[0-9]_%')),
             start2 as (select distinct peer
                               from checks
                               where checks.task similar to concat(block2, '[0-9]_%')),
             startboth as (select distinct start1.peer
                             from start1
                                      join start2 on start1.peer = start2.peer),
             startoneof as (select distinct peer
                              from ((select * from start1) union (select * from start2)) as foo),

             count_start1 as (select count(*) as count_start1
                                     from start1),
             count_start2 as (select count(*) as count_start2
                                     from start2),
             count_startboth as (select count(*) as count_startboth
                                   from startboth),
             count_startoneof as (select count(*) as count_startoneof
                                    from startoneof)
        select ((select count_start1::bigint from count_start1) * 100 / count_peers)             as start1,
               ((select count_start2::bigint from count_start2) * 100 /
                count_peers)                                                                                   as start2,
               ((select count_startboth::bigint from count_startboth) * 100 /
                count_peers)                                                                                   as startboth,
               ((select count_peers - count_startoneof::bigint from count_startoneof) * 100 /
                count_peers)                                                                                   as didntstartany;
end
$$ language plpgsql;



-- 3.12
create or replace procedure max_friends(in ref refcursor, in max int)
as $$
begin
    open ref for
        select peer_1        as peer,
               count(peer_2) as "count"
        from friends
        group by peer
        order by "count" desc
        limit max;
end;
$$ language plpgsql;



-- 3.13
create function success_birthday()
returns table (successchecks bigint, failchecks bigint)
as $$
declare
    checks_count integer := (select max(id)
                             from checks);
    checks  bigint  := (select count(*)
                             from peers
                                     join checks on peers.birthday = checks."date"
                             where peers.nickname = checks.peer);
begin
    return query
        select (select checks / checks_count * 100)                  as successchecks,
               (select (checks_count - checks) / checks_count * 100) as failchecks;
end
$$ language plpgsql;



-- 3.14
create or replace procedure xp_sum(in ref refcursor)
as $$
    begin
        open ref for
            with max_xp as (select checks.peer, max(table_xp.xp_amount) as max_xp
                            from checks
                            join xp as table_xp on checks.id = table_xp."check"
                            group by checks.peer, task)
            select max_xp.peer as peer, sum(max_xp) as xp
            from max_xp
            group by max_xp.peer
            order by xp;
    end;
$$ language plpgsql;



-- 3.15
create or replace procedure tasks_1_2_without_3(task1 varchar, task2 varchar,
                            task3 varchar, ref refcursor)
as $$
    begin
       open ref for
            with success_task1 as (select peer from peer_task_xp() as t
                                   where task1 in (select task from peer_task_xp())),
                 success_task2 as (select peer from peer_task_xp() as t
                                   where task2 in (select task from peer_task_xp())),
                 failure_task3 as (select peer from peer_task_xp() as t
                                   where task3 not in (select task from peer_task_xp()))
            select *
            from ((select * from success_task1)
                   intersect
                  (select * from success_task2)
                   intersect
                  (select * from failure_task3)) as new_table;

    end;
$$ language plpgsql;



-- 3.16
create or replace function with_recursive()
returns table (task varchar, prev integer)
as $$
with recursive recurs as (select case
                                when (tasks.parent_task is null) then 0
                            else 1 end as counter,
                            tasks.title, tasks.parent_task as current_tasks, tasks.parent_task
                     from tasks
                     union all
                     select (case
                                 when child.parent_task is not null then counter + 1
                                 else counter end) as counter,child.title as title, child.parent_task as current_tasks, parrent.title as parrent_task
                     from tasks as child
                              cross join recurs as parrent where parrent.title like child.parent_task)
select title        as task,
       max(counter) as prev
from recurs
group by title
order by 1;
$$ language sql;



-- 3.17
create or replace procedure lucky_day(in n int, in ref refcursor)
as $$
    begin
        open ref for
            with t as (select *
                       from checks
                       join p2p on checks.id = p2p."check"
                       left join verter on checks.id = verter."check"
                       join tasks on checks.task = tasks.title
                       join xp on checks.id = xp."check"
                       where p2p.state = 'Success' and (verter.state = 'Success' or verter.state is null))
        select date
        from t
        where t.xp_amount >= t.max_xp * 0.8
        group by date
        having count(date) >= n;
    end;
$$ language plpgsql;



-- 3.18
create or replace procedure peer_max_task_complete(in ref refcursor)
as $$
begin
    open ref for
        select peer, count(xp_amount) xp
        from xp
                 join checks c on c.id = xp."check"
        group by peer
        order by xp desc
        limit 1;
end;
$$ language plpgsql;



-- 3.19
create or replace procedure peer_maxxp(ref refcursor)
as $$
begin
    open ref for
        select checks.peer as peer, sum(xp.xp_amount) as xp from xp
                    join checks on (xp.check = checks.id)
        group by checks.peer
        order by 2 desc
        limit 1;
end;
$$ language plpgsql;



-- 3.20
create or replace procedure all_day_in_campus(out nick varchar)
as $$
    begin
        with time_in as (select peer, sum(time) as time_in_campus
                         from time_tracking
                         where date = current_date and state = 1
                         group by peer),
             time_out as (select peer, sum(time) as time_out_campus
                         from time_tracking
                         where date = current_date and state = 2
                         group by peer),
             diff_time as (select time_in.peer, (time_out_campus - time_in_campus) as full_time
                           from time_in
                           join time_out on time_in.peer = time_out.peer)
        select peer into nick
        from diff_time
        order by full_time desc
        limit 1;
    end;
$$ language plpgsql;



-- 3.21
create or replace procedure peer_came_early(in time_check date, in N integer, in ref refcursor)
as $$
    begin
        open ref for
            select peer
            from (select peer, MIN(time) as min_time, date
                  from time_tracking
                  where state = 1
                  group by date, peer) as t1
            where min_time < time_check
            group by peer
            having COUNT(peer) >= N;
    end;
$$ language plpgsql;



-- 3.22
create or replace procedure peer_over_out(in N int, in M int, in ref refcursor)
as $$
    begin
        open ref for
            select peer
            from (select peer, date, (COUNT(*) - 1) as counts
                  from time_tracking
                  where state = 2 and date > (current_date - N)
                  group by peer, date) as t1
            group by peer
            having SUM(counts) > M;
    end;
$$ language plpgsql;



-- 3.23
create or replace procedure peer_came_last_today(out nick varchar)
as $$
    begin
        with t1 as (select peer, MIN(time) as first_coming
                   from time_tracking
                   where state = 1 and date = current_date
                   group by peer)
        select peer into nick
        from t1
        order by first_coming desc
        limit 1;
    end;
$$ language plpgsql;



-- 3.24
create or replace procedure get_peers_that_left_yesterday(ref refcursor, N interval minute)
language plpgsql
as $$ begin
    open ref for
        select * from fnc_get_peers_that_left_yesterday(N);
end; $$;


create or replace function fnc_get_peers_that_left_yesterday(N interval minute)
returns setof varchar
as $$
declare
    peer_name varchar;
    row record;
    time_out time;
    is_first_step bool := true;
begin
    for peer_name in
        select peer from time_tracking
        where date = now()::date - 1
        group by peer
        having count(*) >= 4
    loop
        for row in
            select * from time_tracking
            where date = now()::date - 1 and peer = peer_name
        loop
            if row.state = 2 then
                time_out := row.time;
            else
                if is_first_step = false then
                    if row.time - time_out > N then
                        return next peer_name;
                        exit;
                    end if;
                end if;
            end if;
            is_first_step := false;

        end loop;

        is_first_step := true;
    end loop;
    return;
end;
$$ language plpgsql;



-- 3.25
create or replace procedure get_percent_early_entries_for_each_months(ref refcursor)
as $$
begin
    open ref for
        select * from fnc_get_percent_early_entries_for_each_months();
end;
$$ language plpgsql;


create or replace function fnc_get_percent_early_entries_for_each_months()
returns table(month varchar, early_entries numeric)
as $$
begin
    for curr_month in 1..12 loop
        return query
        with agg as (select peer, date, min(time) as time_min, case when min(time) < '12:00' then 1 else 0 end as early
                     from time_tracking
                      where peer in (select nickname from peers where date_part('month', birthday) = curr_month)
                        and state = 1
                      group by peer, date)
        select get_month_varchar(curr_month) as month,
                (select coalesce(round((case when sum(early) = 0 then 1 else sum(early) end)::numeric /
                              (case when count(*) = 0 then 1 else count(*) end) * 100), 0)
                from agg) as early_entries;

        curr_month := curr_month + 1;
    end loop;
end;
$$ language plpgsql;


create or replace function get_month_varchar(n int)
returns varchar
as $$
declare
    month varchar[] := '{"January", "February", "March", "April", "May",' ||
                    '"June", "July", "August", "September", "October", "November", "December"}';
begin
    return month[n];
end;
$$ language plpgsql;