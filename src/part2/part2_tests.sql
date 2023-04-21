CALL p2p_check('blackwoo', 'grandpat', 'CPP2_s21_containers', 'Start', '10:00:00');
CALL p2p_check('fritzkil', 'myrebean', 'CPP3_SmartCalc_v2.0', 'Start', '13:00:00');

CALL p2p_check('blackwoo', 'grandpat', 'CPP2_s21_containers', 'Start', '10:00:00');
CALL p2p_check('fritzkil', 'myrebean', 'CPP3_SmartCalc_v2.0', 'Start', '13:00:00');

CALL verter_check('blackwoo', 'CPP2_s21_containers', 'Start', '11:00:00');
CALL verter_check('fritzkil', 'CPP3_SmartCalc_v2.0', 'Success', '14:00:00');

INSERT INTO p2p("check", checking_peer, state, time)
VALUES (3, 'myrebean', 'Start', '16:00:00');

INSERT INTO xp("check", xp_amount)
VALUES (3, 123123123);

INSERT INTO xp("check", xp_amount)
VALUES (3, 100);