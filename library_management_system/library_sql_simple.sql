select * from books
select * from branch
select * from employees
select * from issued_status
select * from members
select * from return_status

-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
insert into books(isbn,book_title,category,rental_price,status,author,publisher)
values('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')

-- Task 2: Update an Existing Member's Address
update members
set member_name = 'John Doe'
where member_id = 'C102'

-- Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
delete from issued_status
where issued_id = 'IS121'

-- Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
select * from issued_status
where issued_emp_id = 'E101'

-- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.
select issued_emp_id,count(*)
from issued_status
group  by issued_emp_id
having count(*) > 1

--  CTAS (Create Table As Select)
-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

create table book_cnts
as
select b.isbn,b.book_title,count(issued_id) as no_issued from books as b
join
issued_status as ist
on ist.issued_book_isbn = b.isbn
group by b.isbn

select * from book_cnts

-- 4. Data Analysis & Findings
-- Task 7. Retrieve All Books in a Specific Category
select * from books
where category = 'Classic'

-- Task 8: Find Total Rental Income by Category
select category,sum(rental_price)
from books
group by category

select b.category,sum(b.rental_price),count(*)
from issued_status as ist
join
books as b
on b.isbn = ist.issued_book_isbn
group by 1

-- Task 9 List Members Who Registered in the Last 180 Days
insert into members(member_id,member_name,member_address,reg_date)
values ('C120','Sam','145 Main St','2026-01-22'),
('C121','John','145 Main St','2026-01-23')

select * from members
where reg_date >= current_date - interval '180 days'

-- Task 10: List Employees with Their Branch Manager's Name and their branch details
select e1.*,e2.emp_name as manager,b.manager_id from employees as e1
join
branch as b
on b.branch_id = e1.branch_id
join employees as e2
on b.manager_id = e2.emp_id

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold
drop table if exists expensive_books 
create table expensive_books as
select * from books
where rental_price > 7.00 
order by rental_price desc;

-- Task 12: Retrieve the List of Books Not Yet Returned
select distinct ist.issued_book_name from issued_status as ist
left join
return_status as rs
on ist.issued_id = rs.issued_id
where rs.return_id is null



