drop table if exists delta;
create table delta (
  name varchar(50) not null,
  updated_on datetime,
  primary key (name)
) engine=innodb default charset=utf8;

insert into delta (name, updated_on) values
  ('items', now());

drop table if exists items;
create table items (
  id int(11) not null auto_increment,
  t_string   varchar(50),
  t_text     text,
  t_decimal  decimal(30,10),
  t_float    float,
  t_integer  int,
  t_datetime datetime,
  primary key (id)
) engine=innodb default charset=utf8;

insert into items (t_string, t_text, t_decimal, t_float, t_integer, t_datetime) values
  ('one',   'text one!',   '10.50', '100.50', '1000', now()),
  ('two',   'text two!',   '20.50', '200.50', '2000', now()),
  ('three', 'text three!', '30.50', '300.50', '3000', now());
