def create_borrow_card(card_id, borrower_id, borrow_date, expected_return_date):
    # SQL to insert new borrow card
    sql = """
    INSERT INTO BorrowCard (card_id, borrower_id, borrow_date, expected_return_date)
    VALUES (%s, %s, %s, %s)
    """
    # Execute SQL
    # execute_sql(sql, (card_id, borrower_id, borrow_date, expected_return_date))
    
    return "Borrow card created successfully"

