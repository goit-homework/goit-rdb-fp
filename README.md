# goit-rdb-fp: фінальний проєкт, схема `pandemic`

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/goit-homework/goit-rdb-fp/blob/main/fp_pandemic.ipynb)

Фінальний проєкт курсу «Реляційні бази даних для Data Science» (GoIT Neoversity) на датасеті `infectious_cases.csv`.

## Що зроблено

1. Схема `pandemic` стала схемою за замовчуванням, CSV імпортовано через `COPY` у таблицю `infectious_cases`.
2. Таблицю нормалізовано до 3НФ: довідник `entities` з парами `Entity`-`Code` і таблиця показників `infectious_cases_normalized`, яка посилається на нього через `entity_id`.
3. Для `Number_rabies` пораховано середнє, мінімум, максимум і суму по кожній сутності, топ-10 за середнім.
4. Різницю в роках між 1 січня року й поточною датою побудовано через `make_date`, `CURRENT_DATE` і `age()`.
5. Створено функції `years_since` і `avg_cases_per_period` і використано їх у запитах, другу з дільниками 12, 4 і 2.

## Файли

- `fp_pandemic.ipynb`: усі запити з результатами.
- `sql/`: ті самі запити скриптами для `psql`, по одному на завдання.
- `screenshots/`: таблиці, запити й результати кожного завдання.
- `data/infectious_cases.csv`: датасет з курсу.

## Запуск

Ноутбук відкривається кнопкою Colab, далі Runtime > Run all. Скрипти запускаються з кореня репозиторію на будь-якій базі PostgreSQL 16:

```bash
for f in sql/0*.sql; do psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f "$f"; done
```
