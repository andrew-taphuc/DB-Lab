create table library.Book
(book_id char(10) PRIMARY KEY, 
title char(50) NOT NULL,
publisher char(20) NOT NULL,
published_year INT CHECK( published_year > 1900),
total_number_of_copies INT check (total_number_of_copies >= 0),
current_number_of_copies INT check (current_number_of_copies >= 0)
);

ALTER TABLE library.Book ADD CONSTRAINT copies_number CHECK (total_number_of_copies >= current_number_of_copies);

CREATE TABLE library.Borrower(
    borrower_id VARCHAR(255) PRIMARY KEY,
    name char(10) NOT NULL,
    address text,
    telephone_number CHAR(12)
    );
alter table borrower alter column name type varchar(255);

CREATE TABLE BorrowCard (
    card_id INT PRIMARY KEY,
    borrower_id CHAR(10),
    borrow_date DATE NOT NULL,
    expected_return_date DATE NOT NULL,
    actual_return_date DATE,
    FOREIGN KEY (borrower_id) REFERENCES Borrower(borrower_id)
);

CREATE TABLE BorrowCardItem (
    card_id INT,
    book_id CHAR(10),
    number_of_copies INT,
    PRIMARY KEY (card_id, book_id),
    FOREIGN KEY (card_id) REFERENCES BorrowCard(card_id),
    FOREIGN KEY (book_id) REFERENCES Book(book_id)
);
Alter table borrowcarditem Drop column number_of_copies;


\COPY borrower (borrower_id,name, address, telephone_number) FROM /Users/andrew_ta/Andrew-Code/CSDL-LAB/borrower.csv delimiter ',' null as 'null';

\COPY borrowcard (card_id, borrower_id, borrow_date, expected_return_date, actual_return_date) FROM /Users/andrew_ta/Andrew-Code/CSDL-LAB/borrowcard.csv delimiter ',' null as 'null';

\COPY borrowcarditem (card_id, book_id) FROM /Users/andrew_ta/Andrew-Code/CSDL-LAB/borrowcarditem.csv delimiter ',' null as 'null';


//Cau 2
SELECT * FROM library.book where publisher like 'Wiley%' and published_year = 2012;

//Cau 3
select publisher, count(publisher) as total from Book group by publisher;

SELECT publisher, count () FROM library. book group by publisher;

//Cau 4

with t as (
select Book book_id as book_id, Book title as title, count (Book book id) as amount from BorrowCardItem
join Book on Book.book_id = BorrowCardItem.book_id
group by Book.book.id, Book title
);
select top 5 t.id, t.title from t order by t.amount desc;


select distinct Borrower.* from Borrower
join BorrowCard on BorrowCard.borrower_id = Borrower.borrower_id
and actual_return_date>expected_return_date
order by Borrower.name;

delete Book b from Book where b.book_id NOT IN ( select book.id
from BorrowCardItem);



UPDATE Book
SET current_number_of_copies = current_number_of_copies + 10
WHERE book_id IN (
   SELECT t.book_id
   FROM (
       SELECT Book.book_id, COUNT(BorrowCardItem.book_id) AS amount
       FROM BorrowCardItem
       JOIN Book ON Book.book_id = BorrowCardItem.book_id
       WHERE Book.publisher = 'Wiley'
       GROUP BY Book.book_id
       ORDER BY COUNT(BorrowCardItem.book_id) DESC
       LIMIT 3
   ) AS t
);