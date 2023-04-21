insert into peers values ('myrebean', '2000-10-06');
insert into peers values ('blackwoo', '2000-03-23');
insert into peers values ('gatorrya', '2002-12-02');
insert into peers values ('fritzkil', '2001-12-20');
insert into peers values ('grandpat', '1999-04-15');

insert into tasks values ('CPP1_s21_matrixplus', null, 300);
insert into tasks values ('CPP2_s21_containers', 'CPP1_s21_matrixplus', 501);
insert into tasks values ('CPP3_SmartCalc_v2.0', 'CPP2_s21_containers', 708);
insert into tasks values ('CPP4_3DViewer_v2.0', 'CPP3_SmartCalc_v2.0', 1050);
insert into tasks values ('CPP5_MLP', 'CPP4_3DViewer_v2.0', 700);

insert into checks(peer, task, date) values ('myrebean', 'CPP1_s21_matrixplus', '2020-10-10');
insert into checks(peer, task, date) values ('myrebean', 'CPP2_s21_containers', '2020-10-11');
insert into checks(peer, task, date) values ('myrebean', 'CPP3_SmartCalc_v2.0', '2020-10-12');
insert into checks(peer, task, date) values ('myrebean', 'CPP4_3DViewer_v2.0', '2020-10-13');
insert into checks(peer, task, date) values ('myrebean', 'CPP5_MLP', '2020-10-14');

insert into p2p("check", checking_peer, state, time) values (1, 'myrebean', 'Start', '09:00:00');
insert into p2p("check", checking_peer, state, time) values (1, 'myrebean', 'Success', '10:00:00');
insert into p2p("check", checking_peer, state, time) values (2, 'blackwoo', 'Start', '13:00:00');
insert into p2p("check", checking_peer, state, time) values (2, 'blackwoo', 'Success', '14:00:00');
insert into p2p("check", checking_peer, state, time) values (3, 'gatorrya', 'Start', '22:00:00');
insert into p2p("check", checking_peer, state, time) values (3, 'gatorrya', 'Success', '23:00:00');
insert into p2p("check", checking_peer, state, time) values (4, 'fritzkil', 'Start', '15:00:00');
insert into p2p("check", checking_peer, state, time) values (4, 'fritzkil', 'Success', '16:00:00');
insert into p2p("check", checking_peer, state, time) values (5, 'grandpat', 'Start', '14:00:00');
insert into p2p("check", checking_peer, state, time) values (5, 'grandpat', 'Failure', '15:00:00');

insert into verter("check", state, time) values (2, 'Start', '09:00:00');
insert into verter("check", state, time) values (2, 'Success', '10:00:00');
insert into verter("check", state, time) values (3, 'Start', '13:00:00');
insert into verter("check", state, time) values (3, 'Success', '14:00:00');
insert into verter("check", state, time) values (4, 'Start', '22:00:00');
insert into verter("check", state, time) values (4, 'Failure', '23:00:00');
insert into verter("check", state, time) values (5, 'Start', '15:00:00');
insert into verter("check", state, time) values (5, 'Success', '16:00:00');

insert into transferred_points(checking_peer, checked_peer, points_amount) values ('blackwoo', 'grandpat', 1);
insert into transferred_points(checking_peer, checked_peer, points_amount) values ('fritzkil', 'myrebean', 1);
insert into transferred_points(checking_peer, checked_peer, points_amount) values ('myrebean', 'fritzkil', 1);
insert into transferred_points(checking_peer, checked_peer, points_amount) values ('gatorrya', 'blackwoo', 1);
insert into transferred_points(checking_peer, checked_peer, points_amount) values ('grandpat', 'gatorrya', 1);

insert into friends(peer_1, peer_2) values ('blackwoo', 'grandpat');
insert into friends(peer_1, peer_2) values ('fritzkil', 'myrebean');
insert into friends(peer_1, peer_2) values ('myrebean', 'fritzkil');
insert into friends(peer_1, peer_2) values ('gatorrya', 'blackwoo');
insert into friends(peer_1, peer_2) values ('grandpat', 'gatorrya');

insert into recommendations(peer_nickname, recommended_peer) values ('blackwoo', 'grandpat');
insert into recommendations(peer_nickname, recommended_peer) values ('fritzkil', 'myrebean');
insert into recommendations(peer_nickname, recommended_peer) values ('myrebean', 'fritzkil');
insert into recommendations(peer_nickname, recommended_peer) values ('gatorrya', 'blackwoo');
insert into recommendations(peer_nickname, recommended_peer) values ('grandpat', 'gatorrya');

insert into xp("check", xp_amount) values (1, 501);
insert into xp("check", xp_amount) values (2, 300);
insert into xp("check", xp_amount) values (3, 1050);
insert into xp("check", xp_amount) values (4, 300);
insert into xp("check", xp_amount) values (5, 700);

insert into time_tracking(peer, date, time, state) values ('blackwoo', '2022-01-01', '10:00:00', 1);
insert into time_tracking(peer, date, time, state) values ('blackwoo', '2022-01-01', '23:00:00', 2);
insert into time_tracking(peer, date, time, state) values ('fritzkil', '2022-02-01', '13:00:00', 1);
insert into time_tracking(peer, date, time, state) values ('fritzkil', '2022-02-01', '22:00:00', 2);
insert into time_tracking(peer, date, time, state) values ('myrebean', '2022-01-02', '11:00:00', 1);
insert into time_tracking(peer, date, time, state) values ('myrebean', '2022-01-02', '23:00:00', 2);
