create or replace function p2p_trigger()
returns trigger as $tab$
    begin
        if (new.state = 'Start') then
            with peer as (select distinct new.checking_peer, checks.peer as checked_peer
                          from p2p
                          join checks on checks.id = new.check
                          group by 1,2)
            update transferred_points
            set points_amount = points_amount + 1
            from peer
            where transferred_points.checking_peer = peer.checking_peer and transferred_points.checked_peer = checked_peer;
            return new;
        end if;
            return null;
    end;
$tab$ language plpgsql;

create trigger check_p2p_table
    after insert on p2p
    execute procedure p2p_trigger();


create or replace function xp_validate_trigger()
returns trigger as $tab$
    declare
        s21_max_xp int := 0;
    begin
        select max_xp into s21_max_xp
        from xp
            join checks on xp.check = checks.id
            join tasks on checks.task = tasks.title
            join p2p on checks.id = p2p.check
            join verter on checks.id = verter."check"
        where p2p.state = 'Success' and verter.state = 'Success' and new.check = checks.id limit 1;
--         проверки вертером может и не быть

        if (new.xp_amount > s21_max_xp) then
            RAISE NOTICE 'xp_amount: %', new.xp_amount;
            RAISE NOTICE 'max_xp: %', s21_max_xp;
        elsif (s21_max_xp = 0) then
            RAISE NOTICE 'xp_amount: %', new.xp_amount;
            RAISE NOTICE 'max_xp: %', s21_max_xp;
        else
            RAISE NOTICE 'xp_amount: %', new.xp_amount;
            RAISE NOTICE 'max_xp: %', s21_max_xp;
            return new;
        end if;
    end;
$tab$ language plpgsql;

create trigger validate_xp_insert
    before insert on xp
    execute procedure xp_validate_trigger();

