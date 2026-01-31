-- Create Table
drop table ife
create table retail_sales
(
	transactions_id	INT PRIMARY KEY,
	sale_date	DATE,
	sale_time	TIME,
	customer_id	 INT,
	gender	VARCHAR(15),
	age	INT,
	category	VARCHAR(15),
	quantiy	INT,
	price_per_unit	FLOAT,
	cogs	FLOAT,
	total_sale FLOAT

);

-- To check the number of data
select count(*) from retail_sales;

-- To check for null values
select * from retail_sales
where transactions_id is null
or
sale_date is null
or
sale_time is null
or
customer_id is null
or 
gender is null
or 
age is null
or
category is null
or
quantiy is null
or
price_per_unit is null
or
cogs is null
or 
total_sale is null

-- Delete empty data table
delete from retail_sales
where transactions_id is null
or
sale_date is null
or
sale_time is null
or
customer_id is null
or 
gender is null
or 
age is null
or
category is null
or
quantiy is null
or
price_per_unit is null
or
cogs is null
or 
total_sale is null


-- Data Exploration

-- How many sales we have?
select count(*) as total_sales from retail_sales

-- How many customers we have
select count(distinct customer_id) as total_customer
from retail_sales

-- How many category
select distinct category
from retail_sales

-- Data Analysis 

-- Write a SQL query to retrieve all columns for sales made on '2022-11-05'
select * from retail_sales where sale_date = '2022-11-05'

-- Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022.
select * from retail_sales 
where  category = 'Clothing' 
and quantiy >= 4 
and TO_CHAR(sale_date,'YYYY-MM') = '2022-11';

-- Write a SQL query to calculate the total sales (total_sale) for each category
select distinct category,
sum(total_sale)
from retail_sales
group by category

-- Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
select round(avg(age),2) as average_age from retail_sales
where category = 'Beauty'

-- Write a SQL query to find all transactions where the total_sale is greater than 1000.
select * from retail_sales
where total_sale > 1000

-- Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
select category,gender,count(transactions_id) as total_trans
from retail_sales
group by category,gender

-- Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
select * from retail_sales

select year,month,avg_sale from(
	select extract(year from sale_date) as  year,extract(month from sale_date) as month,avg(total_sale) as avg_sale,
	rank() over(Partition by extract(year from sale_date) order by avg(total_sale) desc ) as rank
	from retail_sales
	group by year,month
) as t1
where rank = 1


-- Write a SQL query to find the top 5 customers based on the highest total sales
select distinct customer_id,sum(total_sale) as sales
from retail_sales
group by customer_id
order by sales desc
limit 5

-- Write a SQL query to find the number of unique customers who purchased items from each category.
select category,count(distinct customer_id)
from retail_sales
group by category

-- Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)
With hourly_sale as (
	select *,
	  case
	    when extract(hour from sale_time) < 12 then 'Morning'
		when extract(hour from sale_time)  between 12 and 17  then 'Afternoon'
		else 'Evening'
	  end as shift
	 from retail_sales
)
select shift,count(shift) as total_orders
from hourly_sale
group by shift

-- END --







