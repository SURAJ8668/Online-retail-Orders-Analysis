-- 1. Write a query to Display the product details (product_class_code, product_id, product_desc, product_price,) as per the following criteria and sort them in descending order of category: 


--   a. If the category is 2050, increase the price by 2000 
--   b. If the category is 2051, increase the price by 500 
--   c. If the category is 2052, increase the price by 600. 
--   Hint: Use case statement. no permanent change in table required. (60 ROWS) [NOTE: PRODUCT TABLE]

SELECT PRODUCT_CLASS_CODE AS 'Product Catagory',
PRODUCT_ID AS 'Product ID',
PRODUCT_DESC AS 'Product Description',
PRODUCT_PRICE AS 'Actual Price', 
CASE PRODUCT_CLASS_CODE
WHEN 2050 THEN PRODUCT_PRICE+2000 
WHEN 2051 THEN PRODUCT_PRICE+500 
WHEN 2052 THEN PRODUCT_PRICE+600 
ELSE PRODUCT_PRICE 
END AS 'Calculated Price'
FROM PRODUCT 
ORDER BY PRODUCT_CLASS_CODE DESC;


-- 2. Write a query to display (product_class_desc, product_id, product_desc, product_quantity_avail ) and Show inventory status of products as below as per their available quantity: 
--   a. For Electronics and Computer categories, if available quantity is &lt;= 10, show 'Low stock', 11 &lt;= qty &lt;= 30, show 'In stock', &gt;= 31, show 'Enough stock' 
--   b. For Stationery and Clothes categories, if qty &lt;= 20, show 'Low stock', 21 &lt;= qty &lt;= 80, show 'In stock', &gt;= 81, show 'Enough stock' 
--   c. Rest of the categories, if qty &lt;= 15 – 'Low Stock', 16 &lt;= qty &lt;= 50 – 'In Stock', &gt;= 51 – 'Enough stock' For all categories, if available quantity is 0, show 'Out of stock'. 
--   Hint: Use case statement. (60 ROWS) [NOTE: TABLES TO BE USED – product, product_class]


SELECT PC.PRODUCT_CLASS_DESC AS 'Product Category',
P.PRODUCT_ID AS 'Product ID',
P.PRODUCT_DESC AS 'Product Description',
P.PRODUCT_QUANTITY_AVAIL AS 'Product Availability',
CASE 
WHEN PC.PRODUCT_CLASS_CODE IN (2050,2053) THEN
CASE
WHEN P.PRODUCT_QUANTITY_AVAIL =0 THEN 'Out of stock' 
WHEN P.PRODUCT_QUANTITY_AVAIL &lt;=10 THEN 'Low stock'
WHEN (P.PRODUCT_QUANTITY_AVAIL &gt;=11 AND P.PRODUCT_QUANTITY_AVAIL &lt;=30) THEN 'In stock'
WHEN (PRODUCT_QUANTITY_AVAIL &gt;=31) THEN 'Enough stock'
END
WHEN PC.PRODUCT_CLASS_CODE IN (2052,2056) THEN
CASE
WHEN P.PRODUCT_QUANTITY_AVAIL =0 THEN 'Out of stock' 
WHEN P.PRODUCT_QUANTITY_AVAIL &lt;=20 THEN 'Low stock'
WHEN (P.PRODUCT_QUANTITY_AVAIL &gt;=21 AND P.PRODUCT_QUANTITY_AVAIL &lt;=80) THEN 'In stock'
WHEN (PRODUCT_QUANTITY_AVAIL &gt;=81) THEN 'Enough stock'
END
ELSE
CASE
WHEN P.PRODUCT_QUANTITY_AVAIL =0 THEN 'Out of stock' 
WHEN P.PRODUCT_QUANTITY_AVAIL &lt;=15 THEN 'Low stock'
WHEN (P.PRODUCT_QUANTITY_AVAIL &gt;=16 AND P.PRODUCT_QUANTITY_AVAIL &lt;=50) THEN 'In stock'
WHEN (PRODUCT_QUANTITY_AVAIL &gt;=51) THEN 'Enough stock'
END
END AS 'Inventory Status'
FROM PRODUCT P
INNER JOIN PRODUCT_CLASS PC ON P.PRODUCT_CLASS_CODE = PC.PRODUCT_CLASS_CODE
ORDER BY P.PRODUCT_CLASS_CODE,P.PRODUCT_QUANTITY_AVAIL DESC;




-- 3. Write a query to show the number of cities in all countries other than USA &amp; MALAYSIA, with more than 1 city, in the descending order of CITIES. (2 rows) [NOTE: ADDRESS TABLE]

SELECT COUNT(CITY) AS Count_of_Cites,
COUNTRY AS Country
 FROM ADDRESS
 GROUP BY COUNTRY
 HAVING COUNTRY NOT IN ('USA','Malaysia') AND COUNT(CITY) &gt; 1
ORDER BY Count_of_Cites DESC;


-- 4. Write a query to display the customer_id,customer full name ,city,pincode,and order details (order id, product class desc, product desc, subtotal(product_quantity * product_price)) for orders shipped to cities whose pin codes do not have any 0s in them. Sort the output on customer name and subtotal. (52 ROWS) [NOTE: TABLE TO BE USED - online_customer, address, order_header, order_items, product, product_class]


SELECT OC.CUSTOMER_ID,
OC.CUSTOMER_FNAME || ' ' || OC.CUSTOMER_LNAME AS 'Customer Full Name' ,
A.CITY,
A.PINCODE,
OH.ORDER_ID,
PC.PRODUCT_CLASS_DESC,
P.PRODUCT_DESC,
P.PRODUCT_PRICE,
OI.PRODUCT_QUANTITY,
(P.PRODUCT_PRICE * OI.PRODUCT_QUANTITY) AS Sub_Total 
FROM 
ONLINE_CUSTOMER OC
INNER JOIN ADDRESS A ON OC.ADDRESS_ID = A.ADDRESS_ID 
INNER JOIN ORDER_HEADER OH ON OH.CUSTOMER_ID = OC.CUSTOMER_ID 
INNER JOIN ORDER_ITEMS OI ON OI.ORDER_ID = OH.ORDER_ID 
INNER JOIN PRODUCT P ON P.PRODUCT_ID = OI.PRODUCT_ID 
INNER JOIN PRODUCT_CLASS PC ON PC.PRODUCT_CLASS_CODE = P.PRODUCT_CLASS_CODE
WHERE OH.ORDER_STATUS='Shipped' AND A.PINCODE NOT LIKE '%0%'
ORDER BY OC.CUSTOMER_FNAME, Sub_Total;


-- 5. Write a Query to display product id,product description,totalquantity(sum(product quantity) for a given item whose product id is 201 and which item has been bought along with it maximum no. of times. Display only one record which has the maximum value for total quantity in this scenario. (USE SUB-QUERY)(1 ROW)[NOTE : ORDER_ITEMS TABLE,PRODUCT TABLE]


SELECT OI.PRODUCT_ID AS Product_ID, 
P.PRODUCT_DESC AS Product_Description, 
SUM(OI.PRODUCT_QUANTITY) AS Total_Quantity
FROM ORDER_ITEMS OI
INNER JOIN PRODUCT P ON P.PRODUCT_ID = OI.PRODUCT_ID 
WHERE OI.ORDER_ID IN 
( 
SELECT DISTINCT
ORDER_ID
FROM
ORDER_ITEMS A
WHERE
PRODUCT_ID = 201
)
AND OI.PRODUCT_ID &lt;&gt; 201 
GROUP BY OI.PRODUCT_ID
ORDER BY Total_Quantity DESC 
LIMIT 1; 


-- 6. Write a query to display the customer_id,customer name, email and order details (order id, product desc,product qty, subtotal(product_quantity * product_price)) for all customers even if they have not ordered any item.(225 ROWS) [NOTE: TABLE TO BE USED - online_customer, order_header, order_items, product]


SELECT 
OC.CUSTOMER_ID AS Customer_ID, 
(OC.CUSTOMER_FNAME ||' '|| OC.CUSTOMER_LNAME) AS Customer_Full_Name, 
OC.CUSTOMER_EMAIL AS Customer_Email, 
O.ORDER_ID AS Order_ID,
P.PRODUCT_DESC AS Product_Description, 
 OI.PRODUCT_QUANTITY AS Purchase_Quantity,
P.PRODUCT_PRICE AS Product_Price,
(OI.PRODUCT_QUANTITY*P.PRODUCT_PRICE) AS Subtotal
FROM 
ONLINE_CUSTOMER OC
LEFT JOIN ORDER_HEADER O ON OC.CUSTOMER_ID = O.CUSTOMER_ID 
LEFT JOIN ORDER_ITEMS OI ON O.ORDER_ID = OI.ORDER_ID 
LEFT JOIN PRODUCT P ON OI.PRODUCT_ID = P.PRODUCT_ID 
ORDER BY Customer_ID,Purchase_Quantity DESC;


-- 7. Write a query to display carton id, (len*width*height) as carton_vol and identify the optimum carton (carton with the least volume whose volume is greater than the total volume of all items (len * width * height * product_quantity)) for a given order whose order id is 10006, Assume all items of an order are packed into one single carton (box). (1 ROW) [NOTE: CARTON TABLE]

-- Solution :

SELECT C.CARTON_ID , 
 (C.LEN*C.WIDTH*C.HEIGHT)AS Carton_Volume 
FROM ORDERS.CARTON C 
WHERE (C.LEN*C.WIDTH*C.HEIGHT) >= (
SELECT SUM(P.LEN*P.WIDTH*P.HEIGHT*OI.PRODUCT_QUANTITY) AS VOL 
 FROM 
ORDERS.ORDER_ITEMS OI 
INNER JOIN ORDERS.PRODUCT P ON OI.PRODUCT_ID = P.PRODUCT_ID  
WHERE OI.ORDER_ID =10006 )
ORDER BY (C.LEN*C.WIDTH*C.HEIGHT) ASC
LIMIT 1; 


-- 8. Write a query to display details (customer id,customer fullname,order id,product quantity) of customers who bought more than ten (i.e. total order qty) products per shipped order. (11 ROWS) [NOTE: TABLES TO BE USED - online_customer, order_header, order_items,]


-- Solution:

SELECT OC.CUSTOMER_ID AS Customer_ID, 
CONCAT(CUSTOMER_FNAME,' ',CUSTOMER_LNAME) AS Customer_FullName,
OH.ORDER_ID AS Order_ID,
 SUM(OI.PRODUCT_QUANTITY) AS Total_Order_Quantity
FROM ONLINE_CUSTOMER OC
INNER JOIN ORDER_HEADER OH ON OH.CUSTOMER_ID = OC.CUSTOMER_ID 
INNER JOIN ORDER_ITEMS OI ON OI.ORDER_ID = OH.ORDER_ID 
WHERE OH.ORDER_STATUS = 'Shipped' 
GROUP BY OH.ORDER_ID 
HAVING Total_Order_Quantity > 10
ORDER BY CUSTOMER_ID;


-- 9. Write a query to display the order_id, customer id and cutomer full name of customers along with (product_quantity) as total quantity of products shipped for order ids > 10060. (6 ROWS) [NOTE: TABLES TO BE USED - online_customer, order_header, order_items]


-- Solution:

SELECT 
OC.CUSTOMER_ID AS Customer_ID, 
CONCAT(CUSTOMER_FNAME,' ',CUSTOMER_LNAME) AS Customer_FullName,
 OH.ORDER_ID AS Order_ID,
SUM(OI.PRODUCT_QUANTITY) AS Total_Order_Quantity
FROM ONLINE_CUSTOMER OC
INNER JOIN ORDER_HEADER OH ON OH.CUSTOMER_ID = OC.CUSTOMER_ID -- To connect the Order and Customer details.
INNER JOIN ORDER_ITEMS OI ON OI.ORDER_ID = OH.ORDER_ID -- To fetch the Product Quantity.
WHERE OH.ORDER_STATUS = 'Shipped' AND OH.ORDER_ID > 10060 -- To check for order_status whether it is shipped.
GROUP BY OH.ORDER_ID 
ORDER BY Customer_FullName;


-- 10. Write a query to display product class description ,total quantity (sum(product_quantity),Total value (product_quantity * product price) and show which class of products have been shipped highest(Quantity) to countries outside India other than USA? Also show the total value of those items. (1 ROWS)[NOTE:PRODUCT TABLE,ADDRESS TABLE,ONLINE_CUSTOMER TABLE,ORDER_HEADER TABLE,ORDER_ITEMS TABLE,PRODUCT_CLASS TABLE]


-- Solution:


SELECT PC.PRODUCT_CLASS_CODE AS Product_Class_Code,
PC.PRODUCT_CLASS_DESC AS Product_Class_Description,
SUM(OI.PRODUCT_QUANTITY) AS Total_Quantity,
SUM(OI.PRODUCT_QUANTITY*P.PRODUCT_PRICE) AS Total_Value
FROM ORDER_ITEMS OI
INNER JOIN ORDER_HEADER OH ON OH.ORDER_ID = OI.ORDER_ID -- Join to connect Online Customer
INNER JOIN ONLINE_CUSTOMER OC ON OC.CUSTOMER_ID = OH.CUSTOMER_ID 
INNER JOIN PRODUCT P ON P.PRODUCT_ID = OI.PRODUCT_ID 
INNER JOIN PRODUCT_CLASS PC ON PC.PRODUCT_CLASS_CODE = P.PRODUCT_CLASS_CODE
INNER JOIN ADDRESS A ON A.ADDRESS_ID = OC.ADDRESS_ID -- To retrive the country details.
WHERE OH.ORDER_STATUS ='Shipped' AND A.COUNTRY NOT IN('India','USA') # Order status as Shipped & country without India and USA.
GROUP BY PC.PRODUCT_CLASS_CODE,PC.PRODUCT_CLASS_DESC 
ORDER BY Total_Quantity DESC -- Order by Total_Quality
LIMIT 1;
