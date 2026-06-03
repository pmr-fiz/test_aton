-- task1_solution.sql

WITH equity_commissions AS (
    --суммарная комиссия по акциям за 2024 год на клиента.
    SELECT
        c.client_id,
        SUM(t.commission_rub) AS total_commission_rub
    FROM clients c
    JOIN accounts a ON a.client_id = c.client_id
    JOIN trades t ON t.account_id = a.account_id
    JOIN instruments i ON i.instrument_id = t.instrument_id
    --период фильтрую диапазоном через executed_at, не через EXTRACT, т.к. это быстрее и более читаемо.
    WHERE i.asset_class = 'equity'
      AND t.executed_at >= '2024-01-01'
      AND t.executed_at < '2025-01-01'
    GROUP BY c.client_id
),

deposits_2024 AS (
    --суммарные пополнения счетов за 2024 год на клиента.
    SELECT
        c.client_id,
        SUM(d.amount_rub) AS total_deposits_rub
    FROM clients c
    JOIN accounts a ON a.client_id = c.client_id
    JOIN account_deposits d ON d.account_id = a.account_id
    WHERE d.deposited_at >= '2024-01-01'
      AND d.deposited_at < '2025-01-01'
    GROUP BY c.client_id
),

combined AS (
    --объединяю комиссии и пополнения через LEFT JOIN,
    --это гарантирует вывод всех клиентов, даже без активности в 2024 году.
    SELECT
        c.client_id,
        c.full_name,
        c.phone,
        COALESCE(e.total_commission_rub, 0) AS total_commission_rub,
        COALESCE(d.total_deposits_rub, 0) AS total_deposits_rub
    FROM clients c
    LEFT JOIN equity_commissions e ON e.client_id = c.client_id
    LEFT JOIN deposits_2024 d ON d.client_id = c.client_id
)

SELECT
    --убираю все символы в номере телефона, кроме цифр, беру последние 10 символов.
    RIGHT(REGEXP_REPLACE(phone, '[^0-9]', '', 'g'), 10) AS person_phone,
    full_name,
    ROUND(total_commission_rub::NUMERIC, 2) AS total_commission_rub,
    ROUND(total_deposits_rub::NUMERIC, 2) AS total_deposits_rub,
    --оконная функция 1: ранг по убыванию комиссии
    RANK() OVER (ORDER BY total_commission_rub DESC) AS commission_rank,
    --оконная функция 2: доля комиссии клиента в общей сумме
    --использую NULLIF, чтобы предотвратить ошибку деления на ноль, если вдруг комиссия у всех клиентов будет равна нулю
    ROUND(total_commission_rub * 100.0 / NULLIF(SUM(total_commission_rub) OVER (), 0), 2) AS commission_share_pct
FROM combined
ORDER BY commission_rank, person_phone;