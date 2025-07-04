			--set 1--
--Q1: who is the senior most employee based on job title?==

select top 1 * from emp
order by levels desc


--Q2:which country have more invoices--

select * from invoice

select count(*) as coun,billing_country
from invoice
group by billing_country
order by coun desc


-- Q3: what are the top 3 values of total invoice--

select top 3 * from invoice
order by total desc

/*Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city
we made the most money. Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals*/ 
select sum(total) as invoice_total,billing_city
from invoice
group by billing_city
order by invoice_total desc

/*Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/


-- here we join two tables(customer table and Invoice table) to obtain the result
--

select customer.customer_id,customer.first_name,customer.last_name,SUM( invoice.total) as tot
from customer
join invoice on customer.customer_id=invoice.customer_id
group by customer.customer_id,customer.first_name,customer.last_name
order by tot


/*
Question Set 2 

Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners.
Return your list ordered alphabetically by email starting with A */


select distinct email,first_name,last_name
from customer
join invoice on invoice.customer_id=customer.customer_id
join invoice_line on invoice_line.invoice_id=invoice.invoice_id
join track on track.track_id=invoice_line.track_id
join genre on genre.genre_id=track.track_id
where genre.name like 'rock'	
order by email


/*Q2:  Let's invite the artists who have written the most rock music in our dataset. Write a 
query that returns the Artist name and total track count of the top 10 rock bands */


select artist.artist_id,artist.name,count(artist.artist_id) as number_of_songs
from track
join album on album.album_id=track.album_id
join artist on artist.artist_id=album.artist_id
join genre on genre.genre_id=track.genre_id
where genre.name like'rock'
group by artist.artist_id,artist.name
order by number_of_songs desc



/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the 
longest songs listed first*/


select name,milliseconds  
from track
where milliseconds >(select avg(milliseconds) as avg_track_length from track)
order by milliseconds desc







								--Question Set 3 --
/*Q2: We want to find out the most popular music Genre for each country. 
We determine the most popular genre as the genre with the highest amount of purchases.
Write a query that returns each country along with the top Genre. 
For countries where the maximum number of purchases is shared return all Genres.
Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level.*/


   SELECT 
        COUNT(invoice_line.quantity) AS purchases,
        customer.country,
        genre.name,
        genre.genre_id,
        ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS rowno
    FROM 
        invoice_line 
    JOIN 
        invoice ON invoice.invoice_id = invoice_line.invoice_id
    JOIN 
        customer ON customer.customer_id = invoice.customer_id
    JOIN 
        track ON track.track_id = invoice_line.track_id
    JOIN 
        genre ON genre.genre_id = track.genre_id
    GROUP BY 
        customer.country, genre.name, genre.genre_id
    ORDER BY 
        customer.country ASC, purchases DESC
)


/* Q2. Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent*/

with best_selling_artist as (
select artist.artist_id as artist_id, artist.name as artist_name,
sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
from invoice_line
join track on track.track_id=invoice_line.track_id
join album on album.album_id= track.album_id
join artist on artist.artist_id= album.artist_id
group by artist.artist_id,artist.name
order by total_sales desc
)
select c.customer_id,c.first_name,c.last_name,bsa.artist_name ,
sum(il.unit_price*il.quantity) as amount_spent
from invoice i
join customer c on c.customer_id=i.customer_id
join invoice_line il on il.invoice_id=i.invoice_id
join track t on t.track_id=il.track_id
join album alb on alb.album_id=t.album_id
join best_selling_artist bsa on bsa.artist_id=alb.artist_id
group by c.customer_id,c.first_name,c.last_name,bsa.artist_name
order by amount_spent ;

