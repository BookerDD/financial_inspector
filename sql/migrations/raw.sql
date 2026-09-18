CREATE TABLE IF NOT EXISTS raw.tbank_transactions (
    id serial PRIMARY KEY,
    source_file text NOT NULL,
    row_no int NOT NULL,
    operation_datetime text,
    processing_date text,
    description text,
    amount_operation text,
    amount_account_currency text,
    loaded_at date NOT NULL DEFAULT current_date,
    UNIQUE (source_file, row_no)
);
