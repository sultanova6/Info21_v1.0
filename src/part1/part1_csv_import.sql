DROP PROCEDURE IF EXISTS import() CASCADE;

CREATE OR REPLACE PROCEDURE import(IN tablename varchar, IN path text, IN separator char) AS $$
    BEGIN
        EXECUTE format('COPY %s FROM ''%s'' DELIMITER ''%s'' CSV HEADER;',
            tablename, path, separator);
    END;
$$ LANGUAGE plpgsql;

CALL import('peers', '/Users/myrebean/goinfre/peers.csv', ',');
CALL import('tasks', '/Users/myrebean/goinfre/tasks.csv', ',');
CALL import('checks', '/Users/myrebean/goinfre/checks.csv', ',');
CALL import('p2p', '/Users/myrebean/goinfre/p2p.csv', ',');
CALL import('verter', '/Users/myrebean/goinfre/verter.csv', ',');
CALL import('transfered_points', '/Users/myrebean/goinfre/transferred_points.csv', ',');
CALL import('friends', '/Users/myrebean/goinfre/friends.csv', ',');
CALL import('recommendations', '/Users/myrebean/goinfre/recommendations.csv', ',');
CALL import('xp', '/Users/myrebean/goinfre/xp.csv', ',');
CALL import('time_tracking', '/Users/myrebean/goinfre/time_tracking.csv', ',');

-- DROP TABLE if exists checks CASCADE ;
-- DROP TABLE if exists friends CASCADE ;
-- DROP TABLE if exists p2p CASCADE ;
-- DROP TABLE if exists peers CASCADE ;
-- DROP TABLE if exists recommendations CASCADE ;
-- DROP TABLE if exists tasks CASCADE ;
-- DROP TABLE if exists time_tracking CASCADE ;
-- DROP TABLE if exists transferred_points CASCADE ;
-- DROP TABLE if exists verter CASCADE ;
-- DROP TABLE if exists xp CASCADE ;
-- DROP TYPE if exists state;
-- DROP sequence if exists checks_id_seq;
-- DROP sequence if exists friends_id_seq;
-- DROP sequence if exists p2p_id_seq;
-- DROP sequence if exists recommendations_id_seq;
-- DROP sequence if exists time_tracking_id_seq;
-- DROP sequence if exists transfered_points_id_seq;
-- DROP sequence if exists verter_id_seq;
-- DROP sequence if exists xp_id_seq;
--
-- DROP PROCEDURE if exists export CASCADE ;
-- DROP PROCEDURE if exists import CASCADE ;