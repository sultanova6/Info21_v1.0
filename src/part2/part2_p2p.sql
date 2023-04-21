create or replace procedure p2p_check(person_being_checked varchar,
checkers_nickname varchar, task_name varchar, p2p_check_status state,
"time" time) as $$
    declare
        check_id integer := 0;
    begin
        if (p2p_check_status = 'Start') then
            insert into checks(peer, task, date) values (person_being_checked, task_name, now());
            check_id = (select last_value from checks_id_seq);
        else
            check_id = (select checks.id from p2p
                        join checks on p2p.check = checks.id
                        where p2p.checking_peer = checkers_nickname
                        and checks.peer = person_being_checked
                        and checks.task = task_name
                        order by 1 limit 1);
        end if;
        insert into p2p("check", checking_peer, state, time) values (check_id, checkers_nickname, p2p_check_status, "time");
    end;
$$ language plpgsql;
