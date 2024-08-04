alter database set time_zone = '-02:00';
alter session set time_zone = 'Europe/Berlin';

create table system.test_table (
    id        int primary key,
    today     date,
    right_now timestamp
);


insert into system.test_table (
    id,
    today,
    right_now
) values ( 1,
           current_date,
           current_timestamp );

insert into system.test_table (
    id,
    today,
    right_now
) values ( 2,
           current_date,
           current_timestamp );

insert into system.test_table (
    id,
    today,
    right_now
) values ( 3,
           current_date,
           current_timestamp );

commit;