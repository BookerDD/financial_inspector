CREATE TABLE IF NOT EXISTS service.load_history (
    load_id serial PRIMARY KEY,
    source_file text NOT NULL,
    bank text NOT NULL CHECK (bank IN ('tbank', 'alfa', 'sber')),
    rows_parsed int,
    rows_rejected int,
    rows_loaded int,
    period_from date,
    period_to date,
    amount_total_parsed numeric(18, 2),
    amount_total_statement numeric(18, 2),
    checksum_ok boolean,
    status text NOT NULL CHECK (status IN ('ok', 'partial', 'failed')),
    error text,
    loaded_at date NOT NULL DEFAULT current_date
);
CREATE INDEX IF NOT EXISTS load_history_source_file_idx ON service.load_history (source_file);


CREATE TABLE IF NOT EXISTS service.parse_rejects (
    reject_id serial PRIMARY KEY,
    load_id int NOT NULL REFERENCES service.load_history(load_id),
    row_no int,
    raw_line text NOT NULL,
    reason text NOT NULL,
    rejected_at date NOT NULL DEFAULT current_date
);
CREATE INDEX IF NOT EXISTS parse_rejects_load_id_idx ON service.parse_rejects (load_id);
