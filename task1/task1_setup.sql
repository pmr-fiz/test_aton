-- task1_setup.sql — DDL + детерминированные сид-данные для тестового задания (DS intern, SQL).
-- Идемпотентно: пересоздаёт схему и данные при каждом запуске.
-- Запуск: psql "$DATABASE_URL" -f task1_setup.sql

BEGIN;

DROP TABLE IF EXISTS account_deposits CASCADE;
DROP TABLE IF EXISTS trades           CASCADE;
DROP TABLE IF EXISTS accounts         CASCADE;
DROP TABLE IF EXISTS instruments      CASCADE;
DROP TABLE IF EXISTS clients          CASCADE;

CREATE TABLE clients (
    client_id         INTEGER     PRIMARY KEY,
    full_name         TEXT        NOT NULL,
    phone             TEXT        NOT NULL,
    registration_date DATE        NOT NULL
);

CREATE TABLE accounts (
    account_id    INTEGER PRIMARY KEY,
    client_id     INTEGER NOT NULL REFERENCES clients(client_id),
    account_type  TEXT    NOT NULL,           -- IIS / BROKER
    base_currency TEXT    NOT NULL,
    opened_at     DATE    NOT NULL
);

CREATE TABLE instruments (
    instrument_id INTEGER PRIMARY KEY,
    ticker        TEXT    NOT NULL,
    asset_class   TEXT    NOT NULL,           -- equity / bond / currency / etf
    currency      TEXT    NOT NULL
);

CREATE TABLE trades (
    trade_id       BIGSERIAL   PRIMARY KEY,
    account_id     INTEGER     NOT NULL REFERENCES accounts(account_id),
    instrument_id  INTEGER     NOT NULL REFERENCES instruments(instrument_id),
    side           TEXT        NOT NULL,      -- BUY / SELL
    quantity       NUMERIC     NOT NULL,
    price          NUMERIC     NOT NULL,
    commission_rub NUMERIC     NOT NULL,      -- комиссия уже в рублях
    executed_at    TIMESTAMP   NOT NULL
);

CREATE TABLE account_deposits (
    deposit_id   BIGSERIAL  PRIMARY KEY,
    account_id   INTEGER    NOT NULL REFERENCES accounts(account_id),
    amount_rub   NUMERIC    NOT NULL,
    deposited_at TIMESTAMP  NOT NULL
);

CREATE INDEX idx_accounts_client      ON accounts(client_id);
CREATE INDEX idx_trades_account       ON trades(account_id);
CREATE INDEX idx_trades_instrument    ON trades(instrument_id);
CREATE INDEX idx_deposits_account     ON account_deposits(account_id);

-- ============================ СИД-ДАННЫЕ ============================
-- Сгенерированы детерминированно.

INSERT INTO clients (client_id, full_name, phone, registration_date) VALUES
  (1, 'Иванов Иван Иванович', '+7 (905) 123-45-67', DATE '2019-03-12'),
  (2, 'Петрова Мария Сергеевна', '+7 (916) 222-33-44', DATE '2020-07-01'),
  (3, 'Сидоров Алексей Петрович', '8 (903) 555-10-20', DATE '2018-11-05'),
  (4, 'Кузнецова Ольга Игоревна', '+7 (921) 700-80-90', DATE '2021-02-18'),
  (5, 'Морозов Дмитрий Олегович', '+7 (495) 111-22-33', DATE '2022-05-30'),
  (6, 'Волкова Анна Викторовна', '+7 (812) 444-55-66', DATE '2020-09-09'),
  (7, 'Иванов И. И.', '8 905 123 45 67', DATE '2021-06-14'),
  (8, 'Зайцев Павел Андреевич', '+7 (926) 888-77-66', DATE '2023-01-20'),
  (9, 'Соколова Елена Дмитриевна', '+7 (909) 333-22-11', DATE '2022-08-08'),
  (10, 'А. П. Сидоров', '79035551020', DATE '2023-04-02'),
  (11, 'Иван Иванов', '79051234567', DATE '2022-12-01'),
  (12, 'Беляев Роман Сергеевич', '+7 (901) 246-80-13', DATE '2021-10-10');

INSERT INTO accounts (account_id, client_id, account_type, base_currency, opened_at) VALUES
  (101, 1, 'IIS', 'RUB', DATE '2019-04-01'),
  (102, 1, 'BROKER', 'RUB', DATE '2020-01-15'),
  (201, 2, 'BROKER', 'RUB', DATE '2020-07-10'),
  (202, 2, 'IIS', 'RUB', DATE '2021-03-01'),
  (301, 3, 'BROKER', 'RUB', DATE '2018-12-01'),
  (302, 3, 'IIS', 'RUB', DATE '2019-05-20'),
  (401, 4, 'BROKER', 'RUB', DATE '2021-03-01'),
  (402, 4, 'IIS', 'RUB', DATE '2022-01-11'),
  (501, 5, 'BROKER', 'RUB', DATE '2022-06-01'),
  (601, 6, 'BROKER', 'RUB', DATE '2020-10-01'),
  (701, 7, 'IIS', 'RUB', DATE '2021-07-01'),
  (702, 7, 'BROKER', 'RUB', DATE '2022-02-02'),
  (801, 8, 'BROKER', 'RUB', DATE '2023-02-01'),
  (901, 9, 'IIS', 'RUB', DATE '2022-09-01'),
  (1001, 10, 'BROKER', 'RUB', DATE '2023-04-15'),
  (1101, 11, 'BROKER', 'RUB', DATE '2023-01-05'),
  (1201, 12, 'IIS', 'RUB', DATE '2021-11-01');

INSERT INTO instruments (instrument_id, ticker, asset_class, currency) VALUES
  (1, 'SBER', 'equity', 'RUB'),
  (2, 'GAZP', 'equity', 'RUB'),
  (3, 'LKOH', 'equity', 'RUB'),
  (4, 'YNDX', 'equity', 'RUB'),
  (5, 'AAPL', 'equity', 'USD'),
  (6, 'OFZ26230', 'bond', 'RUB'),
  (7, 'USDRUB', 'currency', 'RUB'),
  (8, 'GOLD', 'etf', 'RUB');

INSERT INTO trades (account_id, instrument_id, side, quantity, price, commission_rub, executed_at) VALUES
  (101, 1, 'BUY', 100, 270.00, 1500.00, TIMESTAMP '2024-02-05 10:00:00'),
  (101, 2, 'SELL', 50, 160.00, 1000.00, TIMESTAMP '2024-06-11 10:00:00'),
  (102, 3, 'BUY', 10, 6500.00, 600.00, TIMESTAMP '2024-03-20 10:00:00'),
  (102, 4, 'BUY', 20, 2500.00, 500.00, TIMESTAMP '2024-08-14 10:00:00'),
  (102, 1, 'SELL', 30, 280.00, 400.00, TIMESTAMP '2024-11-02 10:00:00'),
  (201, 1, 'BUY', 500, 265.00, 3000.00, TIMESTAMP '2024-01-15 10:00:00'),
  (201, 5, 'BUY', 40, 190.00, 2000.00, TIMESTAMP '2024-05-22 10:00:00'),
  (201, 2, 'SELL', 200, 165.00, 1000.00, TIMESTAMP '2024-09-30 10:00:00'),
  (202, 3, 'BUY', 25, 6600.00, 1800.00, TIMESTAMP '2024-04-04 10:00:00'),
  (202, 4, 'SELL', 60, 2450.00, 1200.00, TIMESTAMP '2024-10-19 10:00:00'),
  (301, 1, 'BUY', 300, 268.00, 2500.00, TIMESTAMP '2024-02-28 10:00:00'),
  (301, 5, 'SELL', 30, 195.00, 1500.00, TIMESTAMP '2024-07-07 10:00:00'),
  (302, 2, 'BUY', 100, 158.00, 900.00, TIMESTAMP '2024-03-03 10:00:00'),
  (302, 3, 'BUY', 8, 6450.00, 800.00, TIMESTAMP '2024-05-16 10:00:00'),
  (302, 4, 'SELL', 15, 2480.00, 700.00, TIMESTAMP '2024-08-25 10:00:00'),
  (302, 1, 'BUY', 40, 272.00, 600.00, TIMESTAMP '2024-12-09 10:00:00'),
  (401, 1, 'BUY', 200, 269.00, 1800.00, TIMESTAMP '2024-01-22 10:00:00'),
  (401, 4, 'SELL', 50, 2500.00, 1200.00, TIMESTAMP '2024-06-30 10:00:00'),
  (402, 5, 'BUY', 60, 188.00, 2000.00, TIMESTAMP '2024-09-12 10:00:00'),
  (501, 2, 'BUY', 80, 159.00, 800.00, TIMESTAMP '2024-02-14 10:00:00'),
  (501, 3, 'BUY', 5, 6500.00, 700.00, TIMESTAMP '2024-07-21 10:00:00'),
  (501, 1, 'SELL', 20, 275.00, 500.00, TIMESTAMP '2024-11-29 10:00:00'),
  (601, 6, 'BUY', 10, 1000.00, 1234.00, TIMESTAMP '2024-04-01 10:00:00'),
  (601, 7, 'BUY', 100, 92.00, 777.00, TIMESTAMP '2024-08-08 10:00:00'),
  (701, 1, 'BUY', 150, 266.00, 1200.00, TIMESTAMP '2024-03-15 10:00:00'),
  (701, 4, 'SELL', 30, 2470.00, 800.00, TIMESTAMP '2024-10-01 10:00:00'),
  (702, 5, 'BUY', 25, 192.00, 900.00, TIMESTAMP '2024-05-05 10:00:00'),
  (702, 2, 'SELL', 100, 162.00, 600.00, TIMESTAMP '2024-09-18 10:00:00'),
  (801, 3, 'BUY', 6, 6480.00, 700.00, TIMESTAMP '2024-02-09 10:00:00'),
  (801, 1, 'BUY', 30, 271.00, 500.00, TIMESTAMP '2024-06-25 10:00:00'),
  (801, 4, 'SELL', 10, 2490.00, 300.00, TIMESTAMP '2024-11-11 10:00:00'),
  (901, 2, 'BUY', 60, 157.00, 600.00, TIMESTAMP '2024-03-30 10:00:00'),
  (901, 5, 'SELL', 10, 196.00, 400.00, TIMESTAMP '2024-08-19 10:00:00'),
  (1001, 1, 'BUY', 40, 270.00, 600.00, TIMESTAMP '2024-04-12 10:00:00'),
  (1001, 3, 'SELL', 3, 6520.00, 400.00, TIMESTAMP '2024-10-22 10:00:00'),
  (1101, 5, 'BUY', 50, 191.00, 1500.00, TIMESTAMP '2024-02-20 10:00:00'),
  (1101, 1, 'BUY', 80, 273.00, 900.00, TIMESTAMP '2024-07-14 10:00:00'),
  (1101, 2, 'SELL', 120, 164.00, 600.00, TIMESTAMP '2024-12-01 10:00:00'),
  (1201, 4, 'BUY', 10, 2510.00, 500.00, TIMESTAMP '2024-05-27 10:00:00'),
  (201, 6, 'BUY', 50, 1000.00, 2222.00, TIMESTAMP '2024-02-11 10:00:00'),
  (301, 7, 'BUY', 200, 91.50, 1111.00, TIMESTAMP '2024-03-17 10:00:00'),
  (302, 8, 'BUY', 10, 18000.00, 950.00, TIMESTAMP '2024-06-22 10:00:00'),
  (401, 6, 'SELL', 20, 1010.00, 1300.00, TIMESTAMP '2024-07-30 10:00:00'),
  (501, 8, 'BUY', 5, 17500.00, 640.00, TIMESTAMP '2024-08-03 10:00:00'),
  (102, 7, 'BUY', 300, 90.00, 480.00, TIMESTAMP '2024-10-10 10:00:00'),
  (701, 8, 'SELL', 12, 17800.00, 720.00, TIMESTAMP '2024-11-20 10:00:00'),
  (901, 6, 'BUY', 15, 1005.00, 360.00, TIMESTAMP '2024-12-15 10:00:00'),
  (201, 1, 'BUY', 100, 240.00, 9999.00, TIMESTAMP '2023-12-31 10:00:00'),
  (101, 2, 'BUY', 10, 150.00, 7777.00, TIMESTAMP '2023-06-15 10:00:00'),
  (501, 1, 'BUY', 300, 270.00, 9000.00, TIMESTAMP '2025-02-10 10:00:00'),
  (901, 3, 'BUY', 20, 6500.00, 4000.00, TIMESTAMP '2025-03-05 10:00:00'),
  (1201, 2, 'BUY', 500, 160.00, 2500.00, TIMESTAMP '2025-01-20 10:00:00'),
  (301, 5, 'SELL', 50, 180.00, 8888.00, TIMESTAMP '2025-01-02 10:00:00');

INSERT INTO account_deposits (account_id, amount_rub, deposited_at) VALUES
  (101, 50000.00, TIMESTAMP '2024-01-10 12:00:00'),
  (101, 30000.00, TIMESTAMP '2024-05-10 12:00:00'),
  (102, 20000.00, TIMESTAMP '2024-03-01 12:00:00'),
  (201, 100000.00, TIMESTAMP '2024-01-05 12:00:00'),
  (201, 80000.00, TIMESTAMP '2024-04-05 12:00:00'),
  (201, 60000.00, TIMESTAMP '2024-07-05 12:00:00'),
  (201, 40000.00, TIMESTAMP '2024-10-05 12:00:00'),
  (202, 70000.00, TIMESTAMP '2024-02-01 12:00:00'),
  (202, 30000.00, TIMESTAMP '2024-08-01 12:00:00'),
  (301, 90000.00, TIMESTAMP '2024-01-20 12:00:00'),
  (301, 50000.00, TIMESTAMP '2024-05-20 12:00:00'),
  (301, 25000.00, TIMESTAMP '2024-09-20 12:00:00'),
  (302, 40000.00, TIMESTAMP '2024-06-06 12:00:00'),
  (401, 55000.00, TIMESTAMP '2024-02-15 12:00:00'),
  (401, 45000.00, TIMESTAMP '2024-09-15 12:00:00'),
  (402, 35000.00, TIMESTAMP '2024-03-10 12:00:00'),
  (402, 25000.00, TIMESTAMP '2024-07-10 12:00:00'),
  (402, 15000.00, TIMESTAMP '2024-11-10 12:00:00'),
  (501, 30000.00, TIMESTAMP '2024-04-01 12:00:00'),
  (501, 20000.00, TIMESTAMP '2024-10-01 12:00:00'),
  (601, 60000.00, TIMESTAMP '2024-02-02 12:00:00'),
  (601, 40000.00, TIMESTAMP '2024-06-02 12:00:00'),
  (601, 20000.00, TIMESTAMP '2024-11-02 12:00:00'),
  (701, 25000.00, TIMESTAMP '2024-05-15 12:00:00'),
  (702, 30000.00, TIMESTAMP '2024-03-25 12:00:00'),
  (702, 10000.00, TIMESTAMP '2024-09-25 12:00:00'),
  (801, 18000.00, TIMESTAMP '2024-04-18 12:00:00'),
  (901, 22000.00, TIMESTAMP '2024-06-09 12:00:00'),
  (901, 12000.00, TIMESTAMP '2024-10-09 12:00:00'),
  (1001, 15000.00, TIMESTAMP '2024-05-12 12:00:00'),
  (1101, 28000.00, TIMESTAMP '2024-03-08 12:00:00'),
  (102, 99999.00, TIMESTAMP '2023-11-11 12:00:00'),
  (601, 500000.00, TIMESTAMP '2025-01-15 12:00:00'),
  (401, 150000.00, TIMESTAMP '2025-02-20 12:00:00');

COMMIT;
