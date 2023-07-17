use apple_store_data;

create table app_store(
id bigint,
track_name varchar(400),
size_bytes bigint,
currency varchar(10),
price float,
rating_count_tot int,
rating_count_ver int,
user_rating float,
user_rating_ver float,
ver varchar(20),
cont_rating varchar(5),
prime_genre varchar(20),
sup_devices_num int,
ipadSc_urls_num int,
lang_num int,
vpp_lic int
);


load data infile "C:\\ProgramData\\MySQL\\MySQL Server 8.03\\Uploads\\AppleStore.csv"
into table app_store
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

select * from app_store;

drop table if exists appleStore_description;
create table appleStore_description (
id bigint,
track_name varchar(500),
size_bytes bigint,
app_desc text(20000));

load data infile "C:\\ProgramData\\MySQL\\MySQL Server 8.03\\Uploads\\appleStore_description.csv"
into table applestore_description
fields terminated by ','
enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows;

select * from applestore_description;

-- count values in both files
select count(*) from applestore_description;
select count(*) from app_store;

-- checking null values
select count(*) as missing_nulls from app_store where track_name|user_rating|prime_genre is null;
select count(*) as missing_nulls from applestore_description where app_desc is null;

-- count of genres
select prime_genre, count(*) as genre_count from app_store group by prime_genre order by genre_count desc;

-- ratings overview
select prime_genre, avg(user_rating) as avg_ratings, sum(rating_count_tot) from app_store group by prime_genre order by avg_ratings desc;

select prime_genre, min(user_rating),avg(user_rating),max(user_rating) from app_store group by prime_genre order by avg(user_rating) desc;

-- price

select case
when price>0 then 'paid'
else 'free'
end as app_type, 
avg(user_rating) as avg_ratings from app_store group by app_type;

select case
when price>0 then 'paid'
else 'free'
end as app_type,
sum(rating_count_tot) as total_ratings from app_store group by app_type;


select round(avg(lang_num),0) as no_of_languages,
prime_genre from app_store group by prime_genre order by no_of_languages;

select avg(user_rating) as avg_ratings, 
case
when (lang_num)>30 then 'more than 30 languages'
when lang_num between 10 and 30 then 'less than 30 languages'
when (lang_num)<10 then 'less than 10 languages' 
end as num_language from app_store group by num_language order by avg_ratings desc;


-- correlation between desc_length and user rating
select case
when length(b.app_desc)>1000 then "too long"
when length(b.app_desc) between 500 and 1000 then "long"
when length(b.app_desc) between 200 and 500 then "medium"
else  "short length" end as len from applestore_description b;


select avg(a.user_rating), 
case
when length(b.app_desc) <100 then "short"
when length(b.app_desc) between 100 and 1000 then "medium"
else  "long length" end as len
from app_store as a inner join applestore_description as b on a.id=b.id
group by len order by avg(a.user_rating) desc;

-- top rated app in each genre
select track_name, prime_genre
from(select track_name, prime_genre, user_rating, 
rank() over(partition by prime_genre order by user_rating desc, rating_count_tot desc) as genre_rank from app_store) a where a.genre_rank=1;
