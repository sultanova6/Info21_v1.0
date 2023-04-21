create type state as enum ('Start', 'Success', 'Failure');

create table if not exists peers
(nickname varchar primary key,
birthday date not null);

create table if not exists tasks
(title varchar primary key,
parent_task varchar references tasks(title),
max_xp int not null);

create table if not exists checks
(id serial primary key,
peer varchar not null references peers(nickname),
task varchar not null references tasks(title),
date date not null);

create table if not exists p2p
(id serial primary key,
"check" bigint not null references checks(id),
checking_peer varchar not null references peers(nickname),
state state not null,
time time without time zone not null,
unique ("check", checking_peer, state));

create table if not exists verter
(id serial primary key,
"check" bigint not null references checks(id),
state state not null,
time time without time zone not null,
unique ("check", state, time));

create table if not exists transferred_points
(id serial primary key,
checking_peer varchar not null references peers(nickname),
checked_peer varchar not null references peers(nickname) check (checking_peer <> checked_peer),
points_amount bigint not null);

create table if not exists friends
(id serial primary key,
peer_1 varchar not null references peers(nickname),
peer_2 varchar not null references peers(nickname) check (peer_1 <> peer_2));

create table if not exists recommendations
(id serial primary key,
peer_nickname varchar not null references peers(nickname),
recommended_peer varchar not null references peers(nickname) check (recommended_peer <> peer_nickname));

create table if not exists xp
(id serial primary key,
"check" bigint not null references checks(id),
xp_amount bigint not null check (xp_amount > 0));

create table if not exists time_tracking
(id serial primary key,
peer varchar not null references peers(nickname),
date date not null,
time time without time zone not null,
state bigint not null check (state in (1, 2)),
unique (peer, date, time));
