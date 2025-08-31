-- 1) Tracks with album and artist
select t."Name", al."Title", ar."Name"
from "Track" t
join "Album"  al on t."AlbumId" = al."AlbumId"
join "Artist" ar on al."ArtistId" = ar."ArtistId"
order by t."Name";

-- 2) Invoice lines with track, invoice date, and customer
select il."InvoiceLineId", i."InvoiceDate", t."Name", il."UnitPrice", il."Quantity", c."FirstName", c."LastName"
from "InvoiceLine" il
join "Invoice"  i on il."InvoiceId" = i."InvoiceId"
join "Track"    t on il."TrackId"   = t."TrackId"
join "Customer" c on i."CustomerId" = c."CustomerId"
order by il."InvoiceLineId";

-- 3) Customers with their support representative
select c."CustomerId", c."FirstName", c."LastName", e."FirstName", e."LastName"
from "Customer" c
left join "Employee" e on c."SupportRepId" = e."EmployeeId"
order by e."FirstName", e."LastName", c."FirstName", c."LastName";

-- 4) Playlist contents: playlist name with each track
select p."Name", t."Name"
from "Playlist" p
join "PlaylistTrack" pt on p."PlaylistId" = pt."PlaylistId"
join "Track"         t  on pt."TrackId"   = t."TrackId"
order by p."Name", t."Name";

-- 5) Invoices with billing city
select i."InvoiceId", i."InvoiceDate", i."BillingCity", i."Total", c."FirstName", c."LastName"
from "Invoice" i
join "Customer" c on i."CustomerId" = c."CustomerId"
order by i."InvoiceDate" desc, i."InvoiceId" asc;

-- 6) Employees with no manager
select e."FirstName", e."LastName", e."Title", e."BirthDate", e."HireDate"
from "Employee" e
where e."ReportsTo" is null
order by e."FirstName", e."LastName";
