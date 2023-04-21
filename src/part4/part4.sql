create or replace procedure drop_table(t_name varchar default 'tablename') as $$
declare
    drop_name text;
begin
    for drop_name in
        (select table_name
        from information_schema.tables
        where table_schema = current_schema() and table_name like t_name)
    loop
        execute 'drop table if exists ' || drop_name || ' cascade';
    end loop;
end;
$$ language plpgsql;


create or replace procedure get_scalar_functions(out function_count integer) as $$
declare
    function_name text;
    param_list text;
begin
    select count(*)
    into function_count
    from pg_proc
    where proname not like 'pg_%' and proname not like 'sql_%' and pronargs > 0;

    for function_name, param_list in
        (select p.proname,
               pg_catalog.pg_get_function_arguments(p.oid) as params
        from pg_catalog.pg_proc p
        where p.proname not like 'pg_%' and p.proname not like 'sql_%' and p.pronargs > 0
        order by 1)
    loop
        raise notice 'function: %, params: %', function_name, param_list;
    end loop;
end;
$$ language plpgsql;


create or replace procedure delete_triggers(out deleted_count integer) as $$
declare
    trig_name text;
begin
    deleted_count := 0;
    for trig_name in
        (select trigger_name
        from information_schema.triggers
        where trigger_schema = current_schema())
    loop
        execute 'drop trigger if exists ' || trig_name || ' on ' || quote_ident(trig_name) || ' cascade';
        deleted_count = deleted_count + 1;
    end loop;
end;
$$ language plpgsql;


create or replace procedure find_objects_by_sql(ref refcursor, str text)
as $$
begin
    open ref for
        (select routine_name, routine_type
        from information_schema.routines as r
        where r.specific_schema not in ('information_schema', 'pg_catalog')
        and r.routine_definition ilike '%' || str ||'%');

end;
$$ language plpgsql;
