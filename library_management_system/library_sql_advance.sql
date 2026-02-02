select * from return_status
-- Advance SQl Query
-- Task 13: Identify Members with Overdue Books Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.
select ist.issued_member_id,m.member_name,bk.book_title,current_date - ist.issued_date as over_dues_date from issued_status as ist
join 
members as m
on m.member_id = ist.issued_member_id
join books as bk
on bk.isbn = ist.issued_book_isbn
left join
return_status as rs
on rs.issued_id = ist.issued_id
where
rs.return_date is null
and
(current_date - ist.issued_date) > 30
order by 1

-- Task 14:Update Book Status on Return Update Book Status on Return
-- Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
-- SQL stored procedures
CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10), p_issued_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
    v_isbn VARCHAR(50);
    v_book_name VARCHAR(80);
    
BEGIN
    -- all your logic and code
    -- inserting into returns based on users input
    INSERT INTO return_status(return_id, issued_id, return_date)
    VALUES
    (p_return_id, p_issued_id, CURRENT_DATE);

    SELECT 
        issued_book_isbn,
        issued_book_name
        INTO
        v_isbn,
        v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    RAISE NOTICE 'Thank you for returning the book: %', v_book_name;
    
END;
$$


-- Testing FUNCTION add_return_records

issued_id = IS135
ISBN = WHERE isbn = '978-0-307-58837-1'

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

-- calling function 
CALL add_return_records('RS158', 'IS135');

-- calling function 
CALL add_return_records('RS148', 'IS140');

UPDATE books
SET status = 'no'
select * from books
where isbn = '978-0-307-58837-1'

-- Task 15: Branch Performance Report
-- Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
select * from branch

select * from issued_status

select * from employees

select * from books

select * from return_status

create table branch_reports
as
select b.branch_id,b.manager_id,count(ist.issued_id) as number_book_issued,count(rs.return_id) as number_of_book_return,sum(bk.rental_price) as total_revenue from issued_status as ist
join
employees as  e
on e.emp_id = ist.issued_emp_id
join
branch as b
on e.branch_id = b.branch_id
left join
return_status as rs
on rs.issued_id = ist.issued_id
join
books as bk
on ist.issued_book_isbn = bk.isbn
group by 1,2

select * from branch_reports

-- Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months

CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN (SELECT 
                        DISTINCT issued_member_id   
                    FROM issued_status
                    WHERE 
                        issued_date >= CURRENT_DATE - INTERVAL '2 month'
                    )
;

SELECT * FROM active_members;

-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch
create TABLE employee_issue_count as
SELECT e.emp_name, b.*, count(ist.issued_id) as no_books_issued from issued_status as ist
JOIN
employees as e
on e.emp_id = ist.issued_emp_id
join 
branch as b
on b.branch_id = e.branch_id
group by 1,2
order by no_books_issued desc

select * from employee_issue_count

-- Task 19: Stored Procedure 
/*
Create a stored procedure to manage the status of books in a library system. 
Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
The procedure should function as follows: The stored procedure should take the book_id as an input parameter. The procedure should first check if the book is available (status = 'yes'). 
If the book is available, it should be issued, and the status in the books table should be updated to 'no'. If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
*/

select * from books
where status = 'no';

select * from issued_status;

CREATE OR REPLACE PROCEDURE issue_book(p_issued_id VARCHAR(10), p_issued_member_id VARCHAR(30), p_issued_book_isbn VARCHAR(30), p_issued_emp_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
-- all the variabable
    v_status VARCHAR(10);

BEGIN
-- all the code
    -- checking if book is available 'yes'
    SELECT 
        status 
        INTO
        v_status
    FROM books
    WHERE isbn = p_issued_book_isbn;

    IF v_status = 'yes' THEN

        INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES
        (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

        UPDATE books
            SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

        RAISE NOTICE 'Book records added successfully for book isbn : %', p_issued_book_isbn;


    ELSE
        RAISE NOTICE 'Sorry to inform you the book you have requested is unavailable book_isbn: %', p_issued_book_isbn;
    END IF;
END;
$$

CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');






