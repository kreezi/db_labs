CREATE TABLE IF NOT EXISTS public.Salepeople (
    snum SERIAL NOT NULL PRIMARY KEY,
    sname TEXT NOT NULL,
    city TEXT NOT NULL,
    comm FLOAT NOT NULL
);

CREATE TABLE public.Customers(
    cnum SERIAL NOT NULL PRIMARY KEY,
    cname TEXT NOT NULL,
    city TEXT NOT NULL,
    rating INTEGER,
    snum INTEGER REFERENCES public.Salepeople(snum)
);

CREATE TABLE public.Order(
    onum SERIAL PRIMARY KEY NOT NULL,
    amt FLOAT NOT NULL,
    odate DATE DEFAULT ('24/11/2003'),
    cnum INTEGER REFERENCES public.Customers(cnum),
    snum INTEGER REFERENCES public.Salepeople(snum)
);

--ПРОДАВЦЫ
INSERT INTO Salepeople (snum, sname, city, comm)
VALUES ('1001', 'Peel', 'London', '0.12'),
       ('1002', 'Serres', 'San Jose', '0.13'),
       ('1004', 'Motika', 'London', '0.11'),
       ('1007', 'Rifkin', 'Barcelona', '0.15'),
       ('1003', 'Axelrod', 'New York', '0.10');

--ЗАКАЗЧИКИ
INSERT INTO Customers (cnum, cname, city, rating, snum)
VALUES ('2001', 'Hoffman', 'London', '100', '1001'),
       ('2002', 'Giovanni', 'Rome', '200', '1003'),
       ('2003', 'Liu', 'SanJose', '200', '1002'),
       ('2004', 'Grass', 'Berlin', '300', '1002'),
       ('2006', 'Clemens', 'London', '100', '1001'),
       ('2008', 'Cisneros', 'SanJose', '300', '1007'),
       ('2007', 'Pereira', 'Rome', '100', '1004');

--ЗАКАЗЫ
INSERT INTO "order" (onum, amt, odate, cnum, snum)
VALUES ('3001', '18.69', '10/03/1990', '2008', '1007'),
       ('3003', '767.19', '10/03/1990', '2001', '1001'),
       ('3002', '1900.10', '10/03/1990', '2007', '1004'),
       ('3005', '5160.45', '10/03/1990', '2003', '1002'),
       ('3006', '1098.16', '10/03/1990', '2008', '1007'),
       ('3009', '1713.23', '10/04/1990', '2002', '1003'),
       ('3007', '75.75', '10/04/1990', '2004', '1002'),
       ('3008', '4723', '10/05/1990', '2006', '1001'),
       ('3010', '1309.95', '10/06/1990', '2004', '1002'),
       ('3011', '9891.88', '10/06/1990', '2006', '1001');

--LAB 6
--№1
SELECT s.snum, s.sname
FROM Salepeople s
WHERE EXISTS (
    SELECT 1
    FROM Customers c
    WHERE c.snum = s.snum AND c.rating = 300
);
--№2
SELECT DISTINCT s.snum, s.sname
FROM Salepeople s
JOIN Customers c ON s.snum = c.snum
WHERE c.rating = 300;

--№3
SELECT DISTINCT s.snum, s.sname
FROM Salepeople s
WHERE EXISTS (
    SELECT 1
    FROM Customers c
    WHERE c.city = s.city AND c.snum != s.snum
);

--№4
SELECT c.*
FROM Customers c
WHERE c.snum IN (
    SELECT snum
    FROM Customers
    WHERE snum IS NOT NULL
    GROUP BY snum
    HAVING COUNT(DISTINCT cnum) > 1
);

--№5
SELECT *
FROM Customers
WHERE rating >= ANY (
    SELECT rating
    FROM Customers
    WHERE cname = 'Serres'
);

--№6
--7
SELECT snum, sname
FROM Salepeople s
WHERE NOT EXISTS (
    SELECT 1
    FROM Customers c
    WHERE c.snum = s.snum
    AND c.city = s.city
);

--8
SELECT *
FROM "order"
WHERE amt > ANY (
    SELECT amt
    FROM "order" o
    JOIN Customers c ON o.cnum = c.cnum
    WHERE c.city = 'London'
);

--9
SELECT *
FROM "order"
WHERE amt < (
    SELECT MAX(o.amt)
    FROM "order" o
    JOIN Customers c ON o.cnum = c.cnum
    WHERE c.city = 'London'
);


--lab 7
--1
SELECT cname, city, rating,
       CASE
           WHEN rating >= 200 THEN 'Высокий Рейтинг'
           ELSE 'Низкий Рейтинг'
       END AS rating_category
FROM Customers;

--2
SELECT s.snum AS seller_num, s.sname AS seller_name, c.cnum AS customer_num, c.cname AS customer_name
FROM Salepeople s
JOIN Customers c ON s.snum = c.snum
JOIN "order" o ON c.cnum = o.cnum
GROUP BY s.snum, s.sname, c.cnum, c.cname
HAVING COUNT(o.onum) > 1
ORDER BY s.sname, c.cname;

--3
-- Выбрать snum всех продавцов в San Jose
SELECT snum
FROM Salepeople
WHERE city = 'San Jose'

UNION

-- Выбрать cnum всех заказчиков в San Jose
SELECT cnum
FROM Customers
WHERE city = 'San Jose'

UNION ALL

-- Выбрать onum всех заказов на 3 октября
SELECT onum
FROM "order"
WHERE odate = '2003-10-03';

--lab 8
--1
INSERT INTO Salepeople (city, sname, comm, snum)
VALUES ('San Jose', 'Bianco', NULL, 1100);

--2
DELETE FROM "Order"
WHERE cnum IN (
    SELECT cnum
    FROM Customers
    WHERE cname = 'Clemens'
);

--3
UPDATE Customers
SET rating = rating + 100
WHERE city = 'Rome';

--4
UPDATE Customers
SET snum = (
    SELECT snum
    FROM Salepeople
    WHERE sname = 'Motika'
)
WHERE snum = (
    SELECT snum
    FROM Salepeople
    WHERE sname = 'Serres'
);

DELETE FROM Salepeople
WHERE sname = 'Serres';

--lab 9
--1
INSERT INTO Multicust (snum, sname, city, comm)
SELECT snum, sname, city, comm
FROM Salepeople
WHERE snum IN (
    SELECT snum
    FROM Customers
    GROUP BY snum
    HAVING COUNT(cnum) > 1
);

--2
DELETE FROM Customers
WHERE cnum NOT IN (
    SELECT cnum
    FROM "order"
);

--3
UPDATE Salepeople
SET comm = comm * 1.2
WHERE snum IN (
    SELECT s.snum
    FROM Salepeople s
    JOIN "order" o ON s.snum = o.snum
    GROUP BY s.snum
    HAVING SUM(o.amt) > 3000
);


--lab 10
--1
CREATE TABLE Customers (
    cnum SERIAL NOT NULL PRIMARY KEY,
    cname TEXT NOT NULL,
    city TEXT NOT NULL,
    rating INTEGER,
    snum INTEGER REFERENCES Salepeople(snum)
);

--2
SELECT odate, COUNT(*) as order_count, SUM(amt) as total_amount
FROM "order"
GROUP BY odate
ORDER BY odate;

--3
ALTER TABLE "order"
ADD CONSTRAINT unique_onum UNIQUE (onum);

--4
CREATE INDEX idx_seller_orders ON "order" (snum, odate);

--5
SELECT s.snum AS seller_num, s.sname AS seller_name, c.cnum AS customer_num, c.cname AS customer_name, c.rating
FROM Salepeople s
JOIN Customers c ON s.snum = c.snum;

--Laba 11 #1:
CREATE TABLE Orders (
    onum INTEGER PRIMARY KEY,
    amt MONEY,
    data DATE NOT NULL DEFAULT('11/24/2003'),
    cnum INTEGER REFERENCES public.customers(cnum),
    snum INTEGER REFERENCES public.salepeople(snum),
    UNIQUE (cnum, snum)
);

--#2:
CREATE TABLE Sale_people(
    snum INTEGER PRIMARY KEY,
    name TEXT CHECK (
        name BETWEEN 'A' AND 'M'
        ),
    comm FLOAT NOT NULL DEFAULT (0.10)
);

--#3:
CREATE TABLE Order_s (
    onum INTEGER PRIMARY KEY NOT NULL CHECK ( onum > cnum ),
    cnum INTEGER NOT NULL CHECK ( cnum > snum ),
    snum INTEGER NOT NULL
);

--#4:
CREATE TABLE Cityorders (
    onum INTEGER PRIMARY KEY,
    amt MONEY NOT NULL DEFAULT (0),
    snum INTEGER REFERENCES public.salepeople(snum),
    cnum INTEGER REFERENCES public.customers(cnum),
    city TEXT
);

--#5:
ALTER TABLE public.order
ADD COLUMN prev INTEGER;

--Lab 12
--#1:
CREATE OR REPLACE VIEW ViewCustomers AS
    SELECT * FROM public.customers
    WHERE rating =(SELECT max(rating) FROM public.customers);

--#2:
CREATE OR REPLACE VIEW NumberSalepeople AS
    SELECT snum, city FROM public.salepeople
    GROUP BY city, snum;

--#3:
CREATE OR REPLACE VIEW AverageAndTotalOrder AS
    SELECT s.sname, AVG(amt) AS avg_amt, SUM(amt) AS max_amt FROM public.salepeople s
    JOIN public.order o on s.snum = o.snum
    GROUP BY s.sname;

--#4:
CREATE OR REPLACE VIEW SC AS
    SELECT * FROM public.salepeople s
    WHERE 1 != (
        SELECT COUNT(DISTINCT cnum) FROM public.customers
        GROUP BY s.snum
        );

--#5:Второе представление немодифицируемое, содержит вывод из двух таблиц и плюсом агрегатная функция Первое не подходит из-за distinct

--#6:
CREATE OR REPLACE VIEW Commissions AS
    SELECT snum, comm FROM public.salepeople
    WHERE comm BETWEEN 0.10 AND 0.20;

--#7:
CREATE TABLE Orders_2(
    onum INTEGER PRIMARY KEY,
    amt MONEY,
    odate DATE NOT NULL DEFAULT (current_date),
    cnum INTEGER REFERENCES public.customers(cnum),
    snum INTEGER REFERENCES public.salepeople(snum)
);


SELECT * FROM salepeople;
SELECT * FROM Customers;
SELECT * FROM "order";

























































































































































































































































































































































































































































