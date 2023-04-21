DROP PROCEDURE IF EXISTS export() CASCADE;

CREATE OR REPLACE PROCEDURE export(IN tablename varchar, IN path text, IN separator char) AS $$
    BEGIN
        EXECUTE format('COPY %s TO ''%s'' DELIMITER ''%s'' CSV HEADER;',
            tablename, path, separator);
    END;
$$ LANGUAGE plpgsql;

CALL export('peers', '/Users/myrebean/goinfre/peers.csv', ',');
CALL export('tasks', '/Users/myrebean/goinfre/tasks.csv', ',');
CALL export('checks', '/Users/myrebean/goinfre/checks.csv', ',');
CALL export('p2p', '/Users/myrebean/goinfre/p2p.csv', ',');
CALL export('verter', '/Users/myrebean/goinfre/verter.csv', ',');
CALL export('transfered_points', '/Users/myrebean/goinfre/transferred_points.csv', ',');
CALL export('friends', '/Users/myrebean/goinfre/friends.csv', ',');
CALL export('recommendations', '/Users/myrebean/goinfre/recommendations.csv', ',');
CALL export('xp', '/Users/myrebean/goinfre/xp.csv', ',');
CALL export('time_tracking', '/Users/myrebean/goinfre/time_tracking.csv', ',');

TRUNCATE TABLE peers CASCADE;
TRUNCATE TABLE tasks CASCADE;
TRUNCATE TABLE checks CASCADE;
TRUNCATE TABLE p2p CASCADE;
TRUNCATE TABLE verter CASCADE;
TRUNCATE TABLE transferred_points CASCADE;
TRUNCATE TABLE friends CASCADE;
TRUNCATE TABLE recommendations CASCADE;
TRUNCATE TABLE xp CASCADE;
TRUNCATE TABLE time_tracking CASCADE;
