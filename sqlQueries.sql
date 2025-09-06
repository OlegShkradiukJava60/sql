/* 1) Top 5 longest tracks
      a) Track ID
      b) Track name
      c) Album title
      d) Time: minutes / seconds / milliseconds */
WITH tracks AS (
  SELECT
    t.TrackId      AS TrackId,
    t.Name         AS TrackName,
    al.Title       AS AlbumTitle,
    t.Milliseconds AS Ms
  FROM Track AS t
  JOIN Album AS al ON al.AlbumId = t.AlbumId
),
rank_like AS (
  SELECT
    a.TrackId,
    a.TrackName,
    a.AlbumTitle,
    a.Ms,
    (SELECT COUNT(DISTINCT b.Ms) FROM tracks AS b WHERE b.Ms > a.Ms) AS GreaterCnt
  FROM tracks AS a
),
top5 AS (
  SELECT TrackId, TrackName, AlbumTitle, Ms
  FROM rank_like
  WHERE GreaterCnt < 5
)
SELECT
  TrackId,
  TrackName,
  AlbumTitle,
  Ms/60000     AS Minutes,
  (Ms/1000)%60 AS Seconds,
  Ms%1000      AS Milliseconds
FROM top5;


/* 2) Genres with revenue in top-3 values */
WITH genre_rev AS (
  SELECT
    g.GenreId,
    g.Name AS GenreName,
    SUM(il.UnitPrice * il.Quantity) AS Revenue
  FROM Genre AS g
  JOIN Track AS t ON t.GenreId = g.GenreId
  JOIN InvoiceLine AS il ON il.TrackId = t.TrackId
  GROUP BY g.GenreId, g.Name
),
rank_like AS (
  SELECT
    a.GenreName,
    a.Revenue,
    (SELECT COUNT(DISTINCT b.Revenue) FROM genre_rev AS b WHERE b.Revenue > a.Revenue) AS RankMinus1
  FROM genre_rev AS a
),
top3 AS (
  SELECT GenreName, Revenue, RankMinus1 + 1 AS Rank
  FROM rank_like
  WHERE RankMinus1 < 3
)
SELECT GenreName, Revenue, Rank
FROM top3;


/* 3) Customers with revenue in top-3 positions */
WITH cust_rev AS (
  SELECT
    c.CustomerId,
    c.FirstName || ' ' || c.LastName AS FullName,
    SUM(i.Total) AS Revenue
  FROM Customer AS c
  JOIN Invoice AS i ON i.CustomerId = c.CustomerId
  GROUP BY c.CustomerId, c.FirstName, c.LastName
),
rank_like AS (
  SELECT
    a.CustomerId,
    a.FullName,
    a.Revenue,
    (SELECT COUNT(DISTINCT b.Revenue) FROM cust_rev AS b WHERE b.Revenue > a.Revenue) AS RankMinus1
  FROM cust_rev AS a
),
top3 AS (
  SELECT CustomerId, FullName, Revenue
  FROM rank_like
  WHERE RankMinus1 < 3
)
SELECT CustomerId, FullName, Revenue
FROM top3;


/* 4) Billing countries with maximal number of invoices */
WITH by_country AS (
  SELECT
    i.BillingCountry AS Country,
    COUNT(*) AS Cnt
  FROM Invoice AS i
  GROUP BY i.BillingCountry
),
max_cnt AS (
  SELECT MAX(Cnt) AS MaxCnt FROM by_country
)
SELECT
  bc.Country,
  bc.Cnt AS NumberOfInvoices
FROM by_country AS bc
CROSS JOIN max_cnt AS m
WHERE bc.Cnt = m.MaxCnt;


/* 5) Employees whose supported customers provide 80% total revenue (Pareto) */
WITH emp_rev AS (
  SELECT
    e.EmployeeId,
    e.FirstName || ' ' || e.LastName AS EmpName,
    COALESCE(SUM(i.Total), 0) AS Revenue
  FROM Employee AS e
  LEFT JOIN Customer AS c ON c.SupportRepId = e.EmployeeId
  LEFT JOIN Invoice AS i ON i.CustomerId = c.CustomerId
  GROUP BY e.EmployeeId, e.FirstName, e.LastName
),
total_rev AS (
  SELECT SUM(Revenue) AS AllRev FROM emp_rev
),
thr AS (
  SELECT 0.8 * AllRev AS Thr FROM total_rev
),
cutoff_rev AS (
  SELECT MIN(er2.Revenue) AS Cutoff
  FROM emp_rev AS er2
  CROSS JOIN thr
  WHERE (
    SELECT SUM(er3.Revenue) FROM emp_rev AS er3
    WHERE er3.Revenue >= er2.Revenue
  ) >= thr.Thr
),
selected AS (
  SELECT er.EmpName, er.Revenue
  FROM emp_rev AS er
  CROSS JOIN cutoff_rev AS c
  WHERE er.Revenue >= c.Cutoff
)
SELECT EmpName AS EmployeeFullName, Revenue AS RevenueFromSupportedCustomers
FROM selected;
