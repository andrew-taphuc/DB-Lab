CREATE OR REPLACE FUNCTION add_new_book(
    p_book_id CHAR(10),
    p_title CHAR(50),
    p_publisher CHAR(20),
    p_published_year INT,
    p_total_copies INT
) RETURNS TEXT AS $$
BEGIN
    IF p_published_year <= 1900 OR p_total_copies < 0 THEN
        RETURN 'Invalid input: Year must be after 1900 and copies must be non-negative';
    END IF;

    INSERT INTO library.Book (book_id, title, publisher, published_year, total_number_of_copies, current_number_of_copies)
    VALUES (p_book_id, p_title, p_publisher, p_published_year, p_total_copies, p_total_copies);

    RETURN 'Book added successfully';
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'Error: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION register_borrower(
    p_borrower_id VARCHAR(255),
    p_name VARCHAR(255),
    p_address TEXT,
    p_telephone_number CHAR(12)
) RETURNS TEXT AS $$
BEGIN
    INSERT INTO library.Borrower (borrower_id, name, address, telephone_number)
    VALUES (p_borrower_id, p_name, p_address, p_telephone_number);

    RETURN 'Borrower registered successfully';
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'Error: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION create_borrow_card(
    p_card_id INT,
    p_borrower_id CHAR(10),
    p_borrow_date DATE,
    p_expected_return_date DATE
) RETURNS TEXT AS $$
BEGIN
    INSERT INTO BorrowCard (card_id, borrower_id, borrow_date, expected_return_date)
    VALUES (p_card_id, p_borrower_id, p_borrow_date, p_expected_return_date);

    RETURN 'Borrow card created successfully';
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'Error: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_book_to_borrow_card(
    p_card_id INT,
    p_book_id CHAR(10)
) RETURNS TEXT AS $$
DECLARE
    v_current_copies INT;
BEGIN
    SELECT current_number_of_copies INTO v_current_copies
    FROM library.Book
    WHERE book_id = p_book_id;

    IF v_current_copies > 0 THEN
        INSERT INTO BorrowCardItem (card_id, book_id)
        VALUES (p_card_id, p_book_id);

        UPDATE library.Book
        SET current_number_of_copies = current_number_of_copies - 1
        WHERE book_id = p_book_id;

        RETURN 'Book added to borrow card successfully';
    ELSE
        RETURN 'Book not available';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'Error: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;