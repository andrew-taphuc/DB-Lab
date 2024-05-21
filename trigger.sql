CREATE OR REPLACE FUNCTION check_copies_count()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.current_number_of_copies > NEW.total_number_of_copies THEN
        RAISE EXCEPTION 'Current number of copies cannot exceed total number of copies';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ensure_copies_count
BEFORE INSERT OR UPDATE ON library.Book
FOR EACH ROW EXECUTE FUNCTION check_copies_count();

CREATE OR REPLACE FUNCTION set_initial_copies()
RETURNS TRIGGER AS $$
BEGIN
    NEW.current_number_of_copies := NEW.total_number_of_copies;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_initial_book_copies
BEFORE INSERT ON library.Book
FOR EACH ROW EXECUTE FUNCTION set_initial_copies();


CREATE OR REPLACE FUNCTION prevent_borrowed_book_deletion()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM BorrowCardItem WHERE book_id = OLD.book_id) THEN
        RAISE EXCEPTION 'Cannot delete book that is currently borrowed';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER no_delete_borrowed_book
BEFORE DELETE ON library.Book
FOR EACH ROW EXECUTE FUNCTION prevent_borrowed_book_deletion();


CREATE OR REPLACE FUNCTION update_copies_on_borrow()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE library.Book
    SET current_number_of_copies = current_number_of_copies - 1
    WHERE book_id = NEW.book_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER decrease_copies_on_borrow
AFTER INSERT ON BorrowCardItem
FOR EACH ROW EXECUTE FUNCTION update_copies_on_borrow();


CREATE OR REPLACE FUNCTION update_copies_on_return()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE library.Book
    SET current_number_of_copies = current_number_of_copies + 1
    WHERE book_id = OLD.book_id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER increase_copies_on_return
AFTER DELETE ON BorrowCardItem
FOR EACH ROW EXECUTE FUNCTION update_copies_on_return();


