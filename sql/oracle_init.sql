alter database set time_zone = '+02:00';
alter session set time_zone = 'Europe/Berlin';


drop table system.test_table;

create table system.test_table (
	id        number
		generated always as identity ( start with 1 increment by 1 ),
	today     date,
	right_now timestamp
);


insert into system.test_table (
	today,
	right_now
) values ( current_date,
           current_timestamp );

insert into system.test_table (
	today,
	right_now
) values ( current_date,
           current_timestamp );

insert into system.test_table (
	today,
	right_now
) values ( current_date,
           current_timestamp );

commit;