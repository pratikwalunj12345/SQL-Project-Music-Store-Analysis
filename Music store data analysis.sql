select * from album;
select * from artist;
select * from customer;
select * from employee;
select * from genre;
select * from invoice;
select * from invoice_line;
select * from media_type;
select * from playlist;
select * from playlist_track;
select * from track;

-- 1. Who is the senior most employee based on job title?

select * from employee
order by levels desc
limit 1;
-- Mohan Madan

-- 2. Which countries have the most invoices?

select count(*) as no_of_invoices , billing_country as country
from invoice
group by country
order by no_of_invoices desc
limit 5;

-- 3. What are top 3 values of Total invoice ? 

select total
from invoice
order by total desc
limit 3;

-- 4. Which city has best customers ? We would like to throw a Promotional festival in city
-- we made the most money. Write query that returns one city that has highest sum
-- of invoice totals . Return both city names & sum of all invoice totals.

select billing_city as city , sum(total) as total_sum
from invoice
group by city 
order by total_sum desc
limit 1;

-- Prague  273.240

-- 5. Who is the best customer ? Write query who spent more money

select concat(c.first_name,c.last_name) as name , sum(i.total) as total_amount
from customer c inner join invoice i 
on c.customer_id = i.customer_id
group by name
order by total_amount desc
limit 1;

-- R Madhav

-- 6. Write query to return email, first_name, last_name & genre of all rock music listeners. Return your list ordered
-- alphabetically by email starting with A.

select distinct email , first_name, last_name
from customer c inner join invoice i 
on c.customer_id = i.customer_id
inner join invoice_line il
on i.invoice_id = il.invoice_id
where track_id in(
	select track_id from track t
	inner join genre g on t.genre_id = g.genre_id
	where g.name like 'Rock'
)
order by email asc;

-- 7. Find the artists name & total track count of top 10 rock bands 

select a.name as band_name , count(a.artist_id) as no_of_songs
from artist a inner join album al on a.artist_id = al.artist_id
inner join track t on t.album_id = al.album_id
inner join genre g on g.genre_id = t.genre_id
where g.name like 'Rock'
group by band_name 
order by no_of_songs desc
limit 10;

-- 8. Return all track names that have song length longer than the avg song length. Return name & miliseconds 
-- for each track. Order by song length with longest song listed first.

select name , milliseconds
from track 
where milliseconds >
( select avg(milliseconds)
   from track)
order by milliseconds desc
limit 1;

-- 9. Find out how much ampunt spent by each customer on artists? Write a query to return customer name, artist name
-- & total spent.

with best_artist as (
select a.artist_id as artist_ID ,a.name, sum(il.unit_price * il.quantity) as total_amount
from artist a inner join album al on a.artist_id = al.artist_id
inner join track tr on al.album_id = tr.album_id
inner join invoice_line il on tr.track_id = il.track_id
group by a.name , a.artist_id
order by total_amount desc
)
select concat(c.first_name,' ',c.last_name) as customer_name, ba.name as artist_name,
       sum(il.unit_price * il.quantity) as total_amount
from customer c inner join invoice i on c.customer_id = i.customer_id
inner join invoice_line il on il.invoice_id = i.invoice_id
inner join track tr on tr.track_id = il.track_id
inner join album al on al.album_id = tr.album_id
inner join best_artist ba on ba.artist_id = al.artist_id
group by customer_name , artist_name
order by total_amount desc;

-- 10. We want to find out the most popular music genre for each country . We determine most popular genre as 
-- genre with highest amount of purchases . Write query that returns each country along with top genre . For 
-- countries where max purchases is shared return all genres.

with popular_genre as 
(
select count(il.quantity) as total_purchases, c.country as customer_country , g.name as genre_name,
	row_number() over( partition by c.country order by count(il.quantity) desc) as row_rank
from genre g inner join track tr on g.genre_id = tr.genre_id
inner join invoice_line il on il.track_id = tr.track_id
inner join invoice i on i.invoice_id = il.invoice_id
inner join customer c on c.customer_id = i.customer_id
group by customer_country , genre_name
order by row_rank asc , total_purchases desc
	)
select * from popular_genre where row_rank <=1;

-- 11. Write query that determines customer that has spent the most on music for each country. Write query that
-- returns country along with top customer & how much they spent. For countries where the top amount spent is shared 
-- provide all customers who spend this amount.

with top_customers as
	(
select concat(c.first_name,' ',c.last_name) as customer_name , billing_country, sum(i.total) as amount_spent,
row_number() over( partition by billing_country order by sum(i.total) desc) as customer_rank
from customer c inner join invoice i on c.customer_id = i.invoice_id
inner join invoice_line il on i.invoice_id = il.invoice_id
group by billing_country, customer_name
order by  billing_country asc, customer_rank asc
)
select * from top_customers where customer_rank <=1;
