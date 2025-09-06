-- 1. Tracks never sold ordered by artist’s name and track’s name
select	tr.track_id "Track ID",
		tr.name "Track name",
		g.name "Genre name",
		art.name "Artist name"
from track tr
left join album al on tr.album_id = al.album_id
left join artist art on art.artist_id = al.artist_id
left join genre g on tr.genre_id = g.genre_id
where not exists (select 1 from invoice_line il where il.track_id = tr.track_id)
order by art.name, tr.name;

-- 2. Top 10 tracks by revenue ordered by revenue in descending order and by artist name and by track name
select 	tr.track_id "Track ID",
		tr.name "Track name",
		art.name "Artist"
from track tr
join invoice_line il on tr.track_id = il.track_id
left join album al on tr.album_id = al.album_id
left join artist art on art.artist_id = al.artist_id
group by tr.track_id, tr.name, art.name
order by sum(il.quantity * il.unit_price) desc, art.name, tr.name
limit 10;

-- 3. Top 5 genres by revenue ordered by revenue in descending order and by genre name
select	g.genre_id as "Genre ID",
		g.name as "Genre name",
		sum(il.quantity * il.unit_price) as "Revenue"
from track tr
join genre g on tr.genre_id = g.genre_id
join invoice_line il on tr.track_id = il.track_id
group by g.genre_id, g.name
order by sum(il.quantity * il.unit_price) desc, g.name
limit 5;

-- 4. Invoices having attribute “total” different from the total value computed from the appropriate invoice lines
select i.invoice_id
from invoice i
where i.total != (
	select sum(il.quantity * il.unit_price)
	from invoice_line il
	where il.invoice_id = i.invoice_id
);

-- 5. Albums having tracks with different values of the unit price
 select al.album_id as "Album id", al.title as "Album name"
 from album al
 join track tr on tr.album_id = al.album_id
 group by al.album_id, al.title
 having count(distinct tr.unit_price) > 1;