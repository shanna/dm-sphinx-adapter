drop table if exists delta;
create table delta (
  name varchar(50) not null,
  updated_on datetime,
  primary key (name)
) engine=innodb default charset=utf8;

drop table if exists items;
create table items (
  id int(11) not null auto_increment,
  name varchar(50) not null,
  likes text not null,
  updated_on datetime,
  primary key (id),
  index (updated_on)
) engine=innodb default charset=utf8;

insert into items (name, likes, updated_on) values
  ('one', 'I really like one!', now()),
  ('two', 'I really like two!', now()),
  ('three', 'I really like three!', now());
