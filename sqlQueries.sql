-- album and artist 
select a.name "artist name", a.title "album title", t.name "track name"
from track t
join adlbum a on t.albumid = a.albumid
join artist ar on a.artistid = ar.artistid
where ar.name = 'Queen';

-- customer and support rep
select to_char(cust.customer_id, '9999999999') "Customer ID"
		 ,concat(cust.first_name, ' ', cust.last_name) "Customer's name"
		 ,concat(e.first_name, ' ', e.last_name) "Represantative"
from customer cust
join employee e on (cust.support_rep_id = e.employee_id)
order by 3, 2;

-- invoices
select to_char(line.invoice_line_id, '9999999999') "Line ID",
		to_char(i.invoice_date, 'dd.mm.yyyy') "Invoice date",
		tr.name "Track name",
		line.unit_price "Price per unit",
		line.quantity "Quantity",
		concat(cust.first_name, ' ', cust.last_name) "Customer"
from invoice i
join customer cust on i.customer_id = cust.customer_id
join invoice_line line on i.invoice_id = line.invoice_id
join track tr on line.track_id = tr.track_id
order by i.invoice_date desc, i.total desc;

-- Invoices with billing cities
select i.invoice_id "ID"
		,to_char(i.invoice_date, 'yyyy-mm-dd') "Invoice date"
		,i.billing_city "City"
		,i.total "Total"
		,concat(cust.first_name, ' ', cust.last_name) "Customer's name"
from invoice i
join customer cust on i.customer_id = cust.customer_id
order by 2 desc, 1;


-- top 5 most expensive tracks
select city, income
from (
	select	i.billing_city city,
			sum(i.total) income,
			rank() over (order by sum(i.total) desc) rnk
	from invoice i
	group by i.billing_city
) agg
where rnk <= 5
order by income desc;

-- Employees with no manager
select	concat(e.first_name, ' ', e.last_name) "Employee",
		e.title "Title",
		to_char(e.birth_date, 'yyyy-mm-dd') "Birthdate",
		to_char(e.hire_date, 'yyyy-mm-dd') "Hire date"
from employee e
where e.reports_to is null;

