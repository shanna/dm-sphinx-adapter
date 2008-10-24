drop table if exists items;

create table items (
  id int(11) not null,
  name varchar(50) not null,
  likes text not null,
  updated_on datetime,
  primary key (id)
) engine=innodb default charset=utf8;

insert into items (id, name, likes, updated_on) values
  (CRC32('foo'), 'foo', 'I really like foo!', now()),
  (CRC32('bar'), 'bar', 'I really like bar!', now()),
  (CRC32('baz'), 'baz', 'I really like baz!', now());
