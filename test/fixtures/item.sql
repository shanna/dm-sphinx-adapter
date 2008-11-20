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
  ('foo', 'I really like foo!', now()),
  ('bar', 'I really like bar!', now()),
  ('baz', 'I really like baz!', now());
