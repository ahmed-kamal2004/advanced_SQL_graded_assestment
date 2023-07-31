USE Lucky_Shrub;
SELECT *
FROM notifications;
SELECT *
FROM activity;
SELECT *
FROM Employees;
SELECT *
FROM addresses;
SELECT *
FROM products;
SELECT *
FROM clients;
SELECT *
FROM Audit;
SHOW Columns
FROM Orders;
--task 1
CREATE FUNCTION FindAverageCost(needed_year INT) RETURNS DECIMAL(10, 2) DETERMINISTIC RETURN (
    SELECT AVG(Cost)
    FROM Orders
    WHERE YEAR(Date) = needed_year
);
SELECT FindAverageCost(2022);
--task 2
CREATE PROCEDURE EvaluateProduct(
    IN id VARCHAR(10),
    OUT Data_2020 INT,
    OUT Data_2021 INT,
    OUT Data_2022 INT
) Begin
SET Data_2020 = (
        SELECT SUM(Quantity)
        FROM Orders
        WHERE Year(Date) = 2020
            AND ProductID = id
    );
SET Data_2021 = (
        SELECT SUM(Quantity)
        FROM Orders
        WHERE Year(Date) = 2021
            AND ProductID = id
    );
SET Data_2022 = (
        SELECT SUM(Quantity)
        FROM Orders
        WHERE Year(Date) = 2022
            AND ProductID = id
    );
end;
SET @data2020 = 0;
SET @data2021 = 0;
SET @data2022 = 0;
CALL EvaluateProduct('P1', @data2020, @data2021, @data2022);
SELECT @data2020,
    @data2021,
    @data2022;
--task 3
CREATE TRIGGER UpdateAudit BEFORE
INSERT ON Orders FOR EACH ROW Begin
INSERT INTO Audit(OrderDateTime)
VAlues (CURRENT_TIMESTAMP());
end;
START TRANSACTION
INSERT INTO Orders(
        OrderID,
        ClientID,
        ProductID,
        Quantity,
        Cost,
        Date
    )
VALUES ('31', 'Cl2', 'P2', 1, 100.00, '2022-07-02');
ROLLBACK;
--task 4
SELECT Clients.FullName,
    addresses.Street,
    addresses.County
FROM clients
    LEFT JOIN addresses ON clients.AddressID = addresses.AddressID
UNION
SELECT Employees.FullName,
    addresses.Street,
    addresses.County
FROM Employees
    LEFT JOIN addresses ON Employees.AddressID = addresses.AddressID
ORDER BY Street;
--task 5
WITH cte1 AS (
    SELECT CONCAT (SUM(Cost), " (2020)") AS "Total sum of P2 Product"
    FROM Orders
    WHERE YEAR (Date) = 2020
        AND ProductID = "P2"
),
cte2 AS (
    SELECT CONCAT (SUM(Cost), "(2021)")
    FROM Orders
    WHERE YEAR (Date) = 2021
        AND ProductID = "P2"
),
cte3 AS (
    SELECT CONCAT (SUM (Cost), "(2022)")
    FROM Orders
    WHERE YEAR (Date) = 2022
        AND ProductID = "P2"
)
SELECT *
from cte1
UNION
SELECT *
from cte2
UNION
SELECT *
from cte3;
--task 6
SELECT clients.ClientID,
    activity.Properties->>'$.ProductID',
    clients.FullName,
    clients.ContactNumber
FROM clients
    RIGHT JOIN activity ON clients.ClientID = activity.Properties->>'$.ClientID';
--task 7
CREATE PROCEDURE GetProfit(GivenID VARCHAR(10), GivenYear INT) Begin
SELECT SUM(
        orders.Quantity * (products.SellPrice - products.BuyPrice)
    )
FROM orders
    LEFT JOIN products ON products.ProductID = orders.ProductID
WHERE orders.ProductID = GivenID
    AND YEAR(Date) = GivenYear;
end;
CALL GetProfit("P1", 2020);
--task 8
CREATE VIEW DataSummary AS
SELECT clients.FullName,
    clients.ContactNumber,
    addresses.County,
    products.ProductName,
    products.ProductID,
    orders.Cost,
    orders.Date
FROM clients
    INNER JOIN addresses
    INNER JOIN products
    INNER JOIN orders ON clients.ClientID = orders.ClientID
    AND clients.AddressID = addresses.AddressID
    AND orders.ProductID = products.ProductID
WHERE YEAR(orders.Date) = 2022
ORDER BY orders.Cost;
SELECT *
FROM datasummary;