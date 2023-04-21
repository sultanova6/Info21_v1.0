create or replace procedure verter_check(checkers_nickname varchar, task_name varchar, verter_check_status state, "time" time) as $$
    begin
        insert into verter("check", state, time) values ((select checks.id from checks
                                                         join p2p on checks.id = p2p."check"
                                                         where checks.task = task_name and p2p.checking_peer = checkers_nickname
                                                         order by p2p.time desc limit 1),
                                                         verter_check_status, "time");
    end;
$$ language plpgsql;