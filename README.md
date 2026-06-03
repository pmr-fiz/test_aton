# Тестовое задание - Андрей Стадник

## Task 1 - SQL

Запрос к брокерской БД на PostgreSQL.

**Что делает:** для каждого клиента считает суммарную комиссию по сделкам с акциями и суммарные пополнения счетов за 2024 год, присваивает ранг по комиссии и считает долю в общей сумме.

**Решение:** `task1/task1_solution.sql`

Запуск:
```bash
psql "$DATABASE_URL" -f task1/task1_setup.sql
psql "$DATABASE_URL" -f task1/task1_solution.sql
```

---

## Task 2 - ML

Предсказание выживших на Титанике, `RandomForestClassifier`.

**Accuracy on test: 0.7863**

**Решение:** `task2/task2_solution.py`  
**Ход решения с EDA:** `task2/solution.ipynb`

Запуск:
```bash
pip install -r requirements.txt
python task2/task2_solution.py
```

**Ключевые решения:**
- Извлечение титула из имени - кодирует пол, возраст и статус одновременно
- Импутация возраста по медиане внутри группы титула
- Дроп `boat` и `body` - утечка данных
- Импутация и OHE строго после train/test сплита
- Подбор гиперпараметров через GridSearchCV с cv=5
