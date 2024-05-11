def add_new_book(book_id, title, publisher, published_year, total_copies):
    current_copies = total_copies
    if published_year <= 1900 or total_copies < 0:
        return "Invalid input: Year must be after 1900 and copies must be non-negative"
    
    # SQL to insert new book
    sql = """
    INSERT INTO library.Book (book_id, title, publisher, published_year, total_number_of_copies, current_number_of_copies)
    VALUES (%s, %s, %s, %s, %s, %s)
    """
    # Execute SQL (implementation depends on your database connection method)
    # execute_sql(sql, (book_id, title, publisher, published_year, total_copies, current_copies))
    
    return "Book added successfully"