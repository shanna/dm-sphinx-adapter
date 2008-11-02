drop table if exists delta;

create table delta (
  name varchar(50) not null,
  updated_on datetime,
  primary key (name)
) engine=innodb default charset=utf8;

drop table if exists items;

create table items (
  id int(11) not null,
  name varchar(50) not null,
  likes text not null,
  updated_on datetime,
  primary key (id),
  index (updated_on)
) engine=innodb default charset=utf8;

insert into items (id, name, likes, updated_on) values
  (CRC32('foo'), 'foo', 'I really like foo!', now()),
  (CRC32('bar'), 'bar', 'I really like bar!', now()),
  (CRC32('baz'), 'baz', 'I really like baz!', now());
