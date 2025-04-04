/* Which countries have the most invoices? */
SELECT i.billing_country as 'Billing Country', COUNT(i.invoice_id) as Invoices
FROM invoice i
GROUP BY i.billing_country
ORDER BY Invoices DESC;

/* Which cities have the best customers? */
SELECT i.billing_city as 'Billing City', SUM(i.total) as 'Invoice Totals (USD)'
FROM invoice i
GROUP BY i.billing_city
ORDER BY SUM(i.total) DESC
LIMIT 10;

/* Who is the best customer? */
SELECT c.customer_id as 'Customer ID', SUM(i.total) as 'Invoice Totals (USD)'
FROM customer c
JOIN invoice i
ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY SUM(i.total) DESC
LIMIT 1;

/* Who writes the most rock music? */
SELECT a.artist_id as 'Artist ID', a.name as 'Artist Name', COUNT(t.track_id) as Songs
FROM artist a
JOIN album b
ON a.artist_id = b.artist_id
JOIN track t
ON b.album_id = t.album_id
JOIN genre g
ON t.genre_id = g.genre_id
WHERE g.name='Rock'
GROUP BY a.artist_id, a.name
ORDER BY Songs DESC
LIMIT 20;

/* Which artist earned the most? */
SELECT a.name as 'Artist Name', SUM(l.unit_price * l.quantity) as 'Amount Spent (USD)'
FROM artist a
JOIN album b
ON a.artist_id = b.artist_id
JOIN track t
ON b.album_id = t.album_id
JOIN invoice_line l
ON t.track_id = l.track_id
JOIN invoice i
ON l.invoice_id = i.invoice_id
JOIN customer c
ON i.customer_id = c.customer_id
GROUP BY a.name
ORDER BY SUM(l.unit_price * l.quantity) DESC
LIMIT 10;

/* Which customer spent the most on a single purchase? */
SELECT a.name as 'Artist Name', SUM(l.unit_price * l.quantity) as 'Amount Spent (USD)', c.first_name as 'Customer Name', c.last_name as 'Customer Surname', c.customer_id as 'Customer ID'
FROM artist a
JOIN album b
ON a.artist_id = b.artist_id
JOIN track t
ON b.album_id = t.album_id
JOIN invoice_line l
ON t.track_id = l.track_id
JOIN invoice i
ON l.invoice_id = i.invoice_id
JOIN customer c
ON i.customer_id = c.customer_id
GROUP BY a.name, c.customer_id, c.first_name, c.last_name
ORDER BY SUM(l.unit_price * l.quantity) DESC
LIMIT 10;

/* Which customers listen to rock music? */
SELECT c.email as 'Customer Email', c.first_name as 'Customer Name', c.last_name as 'Customer Surname', g.name as Genre
FROM customer c
JOIN invoice i
ON c.customer_id = i.customer_id
JOIN invoice_line l
ON i.invoice_id = l.invoice_id
JOIN track t
ON l.track_id = t.track_id
JOIN genre g
ON t.genre_id = g.genre_id
WHERE g.name='Rock'
GROUP BY c.email, c.first_name, c.last_name, g.name
ORDER BY c.email



/* What is the most popular genre for each country? */
WITH GenrePerCountry AS
    (SELECT SUM(l.quantity) as Purchases, c.country, g.name, g.genre_id
    FROM customer c
    JOIN invoice i
    ON c.customer_id = i.customer_id
    JOIN invoice_line l
    ON i.invoice_id = l.invoice_id
    JOIN track t
    ON l.track_id = t.track_id
    JOIN genre g
    ON t.genre_id = g.genre_id
    GROUP BY l.quantity, c.country, g.name, g.genre_id
    ORDER BY c.country)

SELECT a.country as Country, a.name as Genre, a.genre_id as 'Genre ID', a.Purchases
FROM GenrePerCountry a
WHERE a.Purchases = (SELECT MAX(Purchases)
                    FROM GenrePerCountry
                    WHERE a.country = Country
                    GROUP BY Country)
ORDER BY Country;

/* How many songs are longer than the average song length? */
SELECT a.name as 'Artist Name', t.name as 'Track Name', (t.milliseconds / 1000.0) as Seconds
FROM track t
JOIN album b
ON t.album_id = b.album_id
JOIN artist a
ON b.artist_id = a.artist_id
GROUP BY t.name, Seconds
HAVING milliseconds > (SELECT AVG(milliseconds)
                    FROM track)
ORDER BY Seconds DESC;

/* Which customer has spent the most for each country? */
WITH CustomerPerCountry AS
    (SELECT c.country, SUM(i.total) as TotalSpent, c.first_name, c.last_name, c.customer_id
    FROM customer c
    JOIN invoice i
    ON c.customer_id = i.customer_id
    GROUP BY c.country, c.first_name, c.last_name, c.customer_id
    ORDER BY TotalSpent DESC)

SELECT a.country as Country, a.TotalSpent as 'Total Spent (USD)', a.first_name as 'Customer Name', a.last_name as 'Customer Surname', a.customer_id as 'Customer ID'
FROM CustomerPerCountry a
WHERE a.TotalSpent = (SELECT MAX(TotalSpent)
                    FROM CustomerPerCountry
                    WHERE a.country = Country
                    GROUP BY Country)
ORDER BY Country;

/* What genre has the longest song on average? */
SELECT g.name AS "Genre", ROUND(AVG(t.milliseconds)/1000, 2) AS "Average Length of Songs (sec)"
FROM track t
JOIN genre g
ON t.genre_id = g.genre_id
GROUP BY 1
ORDER BY 2 DESC;

/* What is the most popular genre for each city? */
WITH GenrePerCity AS
    (SELECT SUM(l.quantity) AS Purchases, c.city, c.country, g.name
    FROM customer c
    JOIN invoice i
    ON c.customer_id = i.customer_id
    JOIN invoice_line l
    ON i.invoice_id = l.invoice_id
    JOIN track t
    ON l.track_id = t.track_id
    JOIN genre g
    ON t.genre_id = g.genre_id
    GROUP BY 2, 3, 4
    ORDER BY 2)

SELECT a.city AS "City", a.country AS "Country", a.name AS "Genre", a.Purchases AS "Total Purchases"
FROM GenrePerCity a
WHERE a.Purchases = (SELECT MAX(Purchases)
                    FROM GenrePerCity
                    WHERE a.city = City
                    GROUP BY City)
ORDER BY Purchases DESC;

/* What month had the highest sales in the USA? */
SELECT DATE(i.invoice_date, 'start of month') AS "Month", SUM(i.total) AS "Total Purchases (USD)"
FROM invoice i
JOIN customer c
ON i.customer_id = c.customer_id
WHERE c.country = 'USA'
GROUP BY 1
ORDER BY 2 DESC;

/* What media type had the most sales? */
SELECT m.name AS "Media Type", SUM(l.unit_price*l.quantity) AS "Total Purchases (USD)" 
FROM media_type m
JOIN track t
ON m.media_type_id = t.media_type_id
JOIN invoice_line l
ON t.track_id = l.track_id
JOIN invoice i
ON l.invoice_id = i.invoice_id
GROUP BY 1
ORDER BY 2 DESC;

