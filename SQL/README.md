# Case_SQL
Тут собраны решения тестовых задач по SQL от компании `Case Plase`.

# 👨‍💻 Решения

Пройдем по решению каждой задачи. Все задачи и описание таблицы можно посмотреть в файле [Тестовое задание.pdf](https://github.com/roge111/Case_SQL/blob/main/SQL/Тестовое%20задание%20SQL.pdf).
### Задание 1
---

```
select pd.name_store, od.nomenclature, od.date, od.price * od.quantity_product as revenue 
from 
    orders_directory as od 
    join 
        product_directory as pd 
    on 
        pd.nomenclature = od.nomenclature
    where
        pd.name_store = 'Магазин 1'
order by od.date DESC;
```

Тут мы возвращаем в качестве результата то, что от нас требуется: `Название магазина`, `Номенклатура`, `Дата` и `выручка`. 

`od.price * od.quantity_product as revenue` — это и есть выручка, которая в результирующей таблице будет названа как `revenue`.

С помощью `join ... on` мы соединяем две таблицы и сравниваем строчки по общему ключу — `nomenclature`. То есть мы будем проверять данные по одной и той же строке.

`where pd.name_store = 'Магазин 1'` — это мы фильтруем магазины по названию `Магазин 1`.

`order by od.date DESC` — мы сортируем результат от новых к старым.
### Задание 2
---

```
select * from print_directory 
where print not in (
    select print from product_directory where print is not null
);

```

Тут всё просто. Мы сначала получаем, по сути, список всех `print` из таблицы `product_directory`, где `print` не пустой: 
```
select print from product_directory where print is not null
```

Дальше с помощью `where` мы фильтруем результат и оставляем тот, где `print` из `print_directory` есть в списке `print` операции выше:

```
where print not in (
    select print from product_directory where print is not null
);

```

Ну а дальше выводим результат. Мы выводим всю информацию, используя `*`.

### Задание 3
---

```
select prod_dir.nomenclature, pd.print, pd.name_print_1, pd.name_print_2 
from
    print_directory as pd 
join 
    product_directory as prod_dir 
on 
    pd.print = prod_dir.print 
where 
    pd.name_print_1 is not null and pd.name_print_2 is not null;
```

Тут я просто опишу алгоритм. Мы берем две таблицы `print_directory` и `product_directory` и проверяем, что `print` у них одинаковые. И результат фильтруем. Отбираем то, где `name_print_1` и `name_print_2` не пустые, то есть `is not null`.

### Задание 4
---
```
select pd.name_store, pd.nomenclature, sd.warehouse as name_house, sd.value_stocks 
from
    product_directory as pd 

join
    stocks_directory as sd
on
    sd.nomenclature = pd.nomenclature
where
    value_stocks > 0 and value_stocks is not null and sd.date = '2024-10-18' and sd.warehouse = 'Склад 1';
```
Тут мы соединяем через `join ... on` таблицы `stocks_directory` и `product_directory`. Однако, если посмотреть на датологическую диаграмму, то мы увидим, что напрямую эти две таблицы связи не имеют, но имеют через один и тот же параметр связь через третью таблицу. И нет смысла связывать одну таблицу с другой, а потом вторую с третьей. Это всё равно, что проверить, что a = c так: `a = b and b = c`, когда можно сделать так: `a = c`.

А в фильтре мы проверяем, что у нас дата равна заданной `2024-10-18` и что склад называется `Склад 1`.

### Задание 5
---
```
select pd.barcode, od.date, count(*) as order_count, sum(quantity_product * price) as revenue, sum(quantity_product * price) * 0.95 as revenue_nalog
from
    orders_directory as od
join
    product_directory as pd
on
    od.nomenclature = pd.nomenclature
where
    pd.barcode = 'Code 1'
group by
    pd.barcode,
    od.date
having 
    count(*) > 0
order by
    od.date
```


`count(*) as order_count` — количество строк в результате, что и является количеством заказов.
`sum(quantity_product * price) as revenue` — считает общую выручку для каждой даты.
`sum(quantity_product * price) * 0.95 as revenue_nalog` — это выручка тоже, но с учетом налога 5%.

Ту добавляется новый элемент 
```
group by
    pd.barcode,
    od.date
```

Тут мы группируем таблицу по штрихкоду и дате, так мы можем найти сумму и количество на каждую дату и штрихкод.
### Задание 6
---

```
WITH print_sales AS (
    SELECT 
        pd.print AS print_article,
        p.name_print_1,
        SUM(od.quantity_product) AS total_sales
    FROM 
        orders_directory od
    JOIN 
        product_directory pd ON od.nomenclature = pd.nomenclature
    JOIN 
        print_directory p ON pd.print = p.print
    GROUP BY 
        pd.print, p.name_print_1
)
SELECT 
    print_article,
    name_print_1,
    total_sales
FROM 
    print_sales
ORDER BY 
    total_sales DESC
LIMIT 1;
```
Тут мы можем разделить задачу на две. Мы создаем временную таблицу с именем `print_sales`, в которой мы соединяем таблицы заказов. Также мы группируем таблицу по артикулу и названию принта 1 и считаем количество продаж. Количество продаж записано как `totals_sales`.

Дальше, уже в основной таблице, мы выводим артикулы, имя принта 1 и максимальное значение продаж. А вот максимальное число продаж у нас вычисляется так: `ORDER BY total_sales DESC LIMIT 1`. 

Тут я в командах использую заглавные буквы, так как кода много, и чтоб он выдилялся среди названий, то я так и сделал)


### Задание 7
---

Триггер — это специальная процедура в базе данных, которая автоматически выполняется при наступлении определенного события.

 ```
CREATE OR REPLACE FUNCTION log_ddl_actions()

RETURNS event_trigger

LANGUAGE plpgsql AS $$

BEGIN

    INSERT INTO ddl_log (event_type, object_type, object_name, user_name, ddl_time)

    VALUES (
        tg_event,
        tg_tag,
        (SELECT object_identity FROM pg_event_trigger_ddl_commands() LIMIT 1),
        current_user,
        current_timestamp

    );

END;

CREATE TABLE IF NOT EXISTS ddl_log (

    id SERIAL PRIMARY KEY,
    event_type TEXT,
    object_type TEXT,
    object_name TEXT,
    user_name TEXT,
    ddl_time TIMESTAMP

);

CREATE EVENT TRIGGER log_ddl_trigger
ON ddl_command_end
EXECUTE FUNCTION log_ddl_actions();
```

Сначала мы создадим таблицу для логов.

`Логи` — это записи о событиях в системе.

```

CREATE TABLE IF NOT EXISTS ddl_log (

    id SERIAL PRIMARY KEY,
    event_type TEXT,
    object_type TEXT,
    object_name TEXT,
    user_name TEXT,
    ddl_time TIMESTAMP

);

```

Где:
- `id` — уникальный идентификатор записи
- `event_type` — какое действие выполнено
- `object_type` — тип объекта
- `object_name` — имя изменяемого объекта
- `user_name` — пользователь, выполнивший действие
- `ddl_time` — время события

Далее создадим функцию, которая будет обрабатывать.

```
CREATE OR REPLACE FUNCTION log_ddl_actions()
RETURNS event_trigger
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO ddl_log (event_type, object_type, object_name, user_name, ddl_time)
    VALUES (
        tg_event,
        tg_tag,
        (SELECT object_identity FROM pg_event_trigger_ddl_commands() LIMIT 1),
        current_user,
        current_timestamp
    );
END;
```

Где:
- `tg_event` — тип события, встроенная переменная.
- `tg_tag` — тег команды, например: CREATE TABLE.
- `pg_event_trigger_ddl_command()` — функция, которая возвращает информацию о DDL команде. Эта функция встроена в PostgreSQL, которую я использую.
- `object_identity` — полное имя объекта.

Затем мы создаем триггеры:
```

CREATE EVENT TRIGGERS log_ddl
ON ddl_comand_end
EXECUTE log_ddl actions();
```

### Задание 8
---
```
CREATE TABLE product_directory_audit IF NOT EXISTS (
    id SERIAL PRIMARY KEY,
    operation CHAR(1),
    user_name TEXT,
    change_time TIMESTAMP,
    old_data JSONB,
    new_data JSONB
);

CREATE OR REPLACE FUNCTION log_product_changes()

RETURNS TRIGGER
LANGUAGE plpgsql AS $$

BEGIN
    IF TG_OP = 'UPDATE' THEN

    INSERT INTO product_directory_audi  (
        operation,
        user_name,
        change_time,
        old_data,
        new_data
    )

    VALUES (
        'U',
        current_user,
        current_timestamp,
        to_jsonb(OLD),
        to_jsonb(NEW)
    );
    END IF;
    RETURN NEW;

END;

CREATE TRIGGER product_directory_audit_trigger
AFTER UPDATE ON product_directory
FOR EACH ROW EXECUTE FUNCTION log_product_changes();
```

Тут я не буду комментировать

### Задание 9
----

```
CREATE DATABASE company_db;
\c company_db

CREATE SCHEMA business;

CREATE USER admin_user PASSWORD 'admin_password';
GRANT ALL ON SCHEMA business TO admin_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA business TO admin_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA business TO admin_user;

CREATE USER read_user WITH PASSWORD 'read_password';
GRANT USAGE ON SCHEMA business to read_user;
GRANT SELECT ON ALL TABLES IN SCHEMA business TO read_user;

SET ROLE admin_user;
CREATE TABLE business. test_table (id SERIAL);
DROP TABLE business. test_table;
RESET ROLE;

SET ROLE read_user;
SELECT * FROM business.any_table;
RESET ROLE;
```

Создаем базу данных и подключаемся к ней:

```
CREATE DATABASE company_db;
\c company_db

```
Создаем `admin_user` с полными правами, как того и требует задача:

```
CREATE USER admin_user PASSWORD 'admin_password';
GRANT ALL ON SCHEMA business TO admin_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA business TO admin_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA business TO admin_user;
```

Конечно, потом для большей безопасности пароль `admin_password` мы заменим на более надежный.

Далее создадим `read_user` с правами только на чтение:
```
CREATE USER read_user WITH PASSWORD 'read_password';
GRANT USAGE ON SCHEMA business to read_user;
GRANT SELECT ON ALL TABLES IN SCHEMA business TO read_user;
```

Тут с паролем то же самое. И, кстати, без разницы, в каком порядке создавать.

Дальше протестируем:

```
SET ROLE admin_user;
CREATE TABLE business.test_table (id SERIAL);
DROP TABLE business.test_table;
RESET ROLE;
```
Должно выйти, так как это для `admin_user`.

И протестируем `read_user`:

```
SET ROLE read_user;
SELECT * FROM business.any_table;
RESET ROLE;
```

Тоже должно подойти.

### Задание 10
---

Оптимизация запроса для таблицы orders с 10 млн записей

---

1. Какие индексы могут улучшить выполнение запроса?

Для запроса:

```SELECT * FROM orders WHERE order_date >= CURRENT_DATE - INTERVAL '1 month';```

Рекомендуемый индекс:

```CREATE INDEX idx_orders_order_date ON orders(order_date);```

Давай разберу, почему так:
- Индекс по полю order_date ускорит фильтрацию по диапазону дат.
- Для временных меток (TIMESTAMP) B-дерево работает эффективно.

---

2. Как проверить, что индекс улучшил производительность?

Снача замерим время выполнения до создания индекса:

```
EXPLAIN ANALYZE 
SELECT * FROM orders WHERE order_date >= CURRENT_DATE - INTERVAL '1 month';
```

Потом создадим индекс и повторим замер:
```
CREATE INDEX idx_orders_order_date ON orders(order_date);
EXPLAIN ANALYZE 
SELECT * FROM orders WHERE order_date >= CURRENT_DATE - INTERVAL '1 month';
```

В итоге мы получим что-то вроде таблицы `EXPLAIN ANALYZE`. На что смотреть в выводе `EXPLAIN ANALYZE`:

-До индекса: Seq Scan (полное сканирование таблицы).
- После индекса: Index Scan или Bitmap Index Scan (использование индекса).
- Уменьшение времени выполнения (например, с 2000 мс до 50 мс).

---

3. Влияние VACUUM ANALYZE на производительность

Зачем нужно:

- VACUUM освобождает место, помеченное для удаления (например, после DELETE).
- ANALYZE обновляет статистику по таблице для оптимизатора запросов.

Выполняется следующим образом:
```
VACUUM ANALYZE orders;
```

Что это нам даст:

- Оптимизатор сможет точнее выбирать план выполнения (например, использовать индекс).
- Особенно важно, если данные в таблице часто изменяются.

---

4. Другие способы оптимизации

a. Партиционирование таблицы

Разделим таблицу по месяцам/годам:
```
CREATE TABLE orders (
    order_id SERIAL,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (order_id, order_date)
) PARTITION BY RANGE (order_date);


-- Создаем партиции
CREATE TABLE orders_2024_01 PARTITION OF orders
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
```

Преимущества:

- Запрос будет сканировать только актуальную партицию (например, за последний месяц).

---

b. Оптимизация размера таблицы

- Удалим неиспользуемые данные:
```
DELETE FROM orders WHERE order_date < '2020-01-01';
```

- Используем pg_repack для устранения фрагментации без блокировки.

---

c. Настройка PostgreSQL

В postgresql.conf:
```
work_mem = 64MB              # Увеличить для сложных сортировок
maintenance_work_mem = 1GB   # Для ускорения создания индексов
effective_cache_size = 4GB   # Помогает оптимизатору
random_page_cost = 1.1       # Для SSD-дисков
```

---

d. Использование материализованных представлений

Если данные редко меняются:
```
CREATE MATERIALIZED VIEW orders_last_month AS
SELECT * FROM orders 
WHERE order_date >= CURRENT_DATE - INTERVAL '1 month';

-- Обновлять по расписанию
REFRESH MATERIALIZED VIEW orders_last_month;
```

---

Подвидем итоги

1. Создадим индекс `CREATE INDEX idx_orders_order_date ON orders(order_date)`.
2. Проверим план выполнения с `EXPLAIN ANALYZE`.
3. Выполните `VACUUM ANALYZE orders` для актуализации статистики.
4. Для долгосрочного решения рассмотрите партиционирование.

Таким образом можно оптимизировать обработку такой большой таблицы


#  Прощание 👋

Спасибо за внимание! Если понравилось и хочешь узнать про SQL, аналитику или разработку на Python больше, то подписывайся на мой GitHub.







