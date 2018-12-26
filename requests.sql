CREATE TABLE goods
(
  id       INTEGER PRIMARY KEY AUTOINCREMENT,
  name     TEXT    NOT NULL,
  price    INTEGER NOT NULL CHECK (price > 0),
  quantity INTEGER NOT NULL
    CHECK (quantity >= 0)
    DEFAULT 0
);

CREATE TABLE managers
(
  id      INTEGER PRIMARY KEY AUTOINCREMENT,
  name    TEXT    NOT NULL,
  plan    INTEGER NOT NULL CHECK (plan > 0),
  boss_id INTEGER REFERENCES managers
);

CREATE TABLE sales
(
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  manager_id INTEGER NOT NULL REFERENCES managers,
  good_id    INTEGER NOT NULL REFERENCES goods,
  quantity   INTEGER NOT NULL CHECK (quantity > 0),
  price      INTEGER NOT NULL CHECK (price > 0)
);

INSERT INTO managers
VALUES (1, 'Vasya', 10000, NULL),
       (2, 'Petya', 20000, 1),
       (3, 'Masha', 30000, 1),
       (4, 'Dasha', 30000, 3);

INSERT INTO goods
VALUES (1, 'BigMac', 120, 10),
       (2, 'Burger', 60, 10),
       (3, 'Cola', 40, 10);

INSERT INTO sales (manager_id, good_id, quantity, price)
VALUES (1, 1, 5, 200), -- Vasya, BigMac - 200rub
       (1, 1, 5, 120), -- Vasya, BigMac - 120rub
       (2, 2, 1, 60),
       (2, 2, 1, 50),
       (3, 3, 10, 50), -- Masha, Cola - 50
       (3, 2, 10, 80); -- Masha, Burger - 80


SELECT id, name, plan
FROM managers
LIMIT 3; -- оставляем всего 3

SELECT id, name, plan
FROM managers
LIMIT 3 OFFSET 3; -- начиная с 3, оставь 3

SELECT id, name, plan
FROM managers
ORDER BY name; -- ASC
SELECT id, name, plan
FROM managers
ORDER BY name ASC; -- ASC
SELECT id, name, plan
FROM managers
ORDER BY name DESC;

-- TOP-3 продукта по цене (самых дорогих)

SELECT id, name, price
FROM goods
ORDER BY price DESC
LIMIT 3;

-- Definition
ALTER TABLE managers
  ADD salary INTEGER NOT NULL DEFAULT 0;

UPDATE managers
SET salary = 40; -- WHERE лучше писать, т.к. иначе обновятся все

SELECT *
FROM managers;

UPDATE managers
SET salary = 100000 - plan; -- можно ссылаться на поля обновляемых строк

SELECT *
FROM managers;

SELECT 1 + 1; -- вычисляемые поля

-- на руки
SELECT id, name, salary * 0.87 clear
FROM managers;

SELECT id, name, salary * 0.87 AS total
FROM managers; -- AS total - псевдоним
SELECT id, name, salary * 0.87 total
FROM managers; -- AS можно не писать

SELECT id, name
FROM managers
WHERE salary > 70000;

SELECT id, name
FROM managers
WHERE name = 'Petya';

SELECT id, name
FROM managers
WHERE salary > 60000
  AND salary < 90000; -- OR/AND/NOT

SELECT id, name, salary
FROM managers
WHERE salary BETWEEN 80000 AND 90000; -- BETWEEN - границы включены

SELECT id, name
FROM managers
WHERE salary NOT BETWEEN 80000 AND 90000;

SELECT id, name
FROM managers
WHERE name IN ('Petya', 'Dasha');

SELECT id, name
FROM managers
WHERE name NOT IN ('Petya', 'Dasha');

-- % - несколько символов, _ - ровно один
SELECT id, name
FROM managers
WHERE name LIKE '%ya';
SELECT id, name
FROM managers
WHERE name NOT LIKE '%ya';
SELECT id, name
FROM managers
WHERE name LIKE '_asha';

-- SELECT id, name FROM managers WHERE name ILIKE 'petya';
-- добавить ещё один столбец, где имя в верхнем/нижнем регистре

SELECT id, name
FROM managers
WHERE LOWER(name) = LOWER('PETYA'); -- SQL поддерживает функции (перечень функций зависит от СУБД)
SELECT LOWER('Петя'); -- но не всё поддерживается (кириллица не lowercas'иться)

-- агрегирующие запросы
-- сколько всего менеджеров
SELECT COUNT(*) total
FROM managers; -- COUNT - агрегирующая функция

SELECT COUNT(*) total
FROM managers
WHERE name LIKE '%ya';

SELECT SUM(salary)
FROM managers;

-- Сосчитать стоимость всех товаров в магазине
SELECT SUM(price * quantity)
FROM goods;

SELECT SUM(price * quantity)
FROM goods
WHERE price > 50;

-- Сосчитать выручку
SELECT SUM(price * quantity)
FROM sales;

SELECT AVG(salary)
FROM managers;

-- Сосчитать зп без босса
SELECT AVG(salary)
FROM managers
WHERE boss_id IS NOT NULL;

-- в агрегирующих запросах нельзя просто так использовать поля!
-- можно только агрегирующие функции, либо столбцы по которым идёт группировка
-- но в SQLite можно
SELECT id, name, MAX(salary)
FROM managers;
SELECT id, name, MIN(salary)
FROM managers;
SELECT id, name, AVG(salary)
FROM managers;

SELECT COUNT(*)
FROM sales; -- 1 строку
-- в SELECT можно использовать только агрегирующие функции либо те столбцы, по которым идёт группировка
SELECT manager_id, COUNT(*)
FROM sales
GROUP BY manager_id; -- 1 строку

-- На сколько каждый менеджер продал?
SELECT manager_id, SUM(quantity * price)
FROM sales
GROUP BY manager_id;

-- TODO: на сколько каждого товара продано
SELECT good_id, SUM(quantity * price)
FROM sales
GROUP BY good_id;

-- TODO: id товара, которого было продано больше всего (количество)
SELECT good_id, SUM(quantity) total
FROM sales
GROUP BY good_id
ORDER BY total DESC
LIMIT 1
;

-- manager_id, good_id, на такую-то сумму

SELECT manager_id, good_id, SUM(quantity) total
FROM sales
GROUP BY manager_id, good_id;

SELECT manager_id, good_id, SUM(quantity) total
FROM sales
GROUP BY manager_id, good_id
HAVING total > 5; -- Having работает после группировки

-- запросы, затрагивающие несколько таблиц

-- подзапросы
SELECT s.manager_id,
       SUM(s.quantity * s.price)                                 total,
       (SELECT m.name FROM managers m WHERE s.manager_id = m.id) manager_name -- должен возвращать только 1 строку и 1 столбец
FROM sales s -- sales AS s (везде sales - будет s)
GROUP BY s.manager_id;

-- TODO: по всем продажам:
-- Имя менеджера и название товара

SELECT s.id,
       s.price,
       s.quantity,
       (
         SELECT m.name
         FROM managers m
         WHERE s.manager_id = m.id
       ) manager_name,
       (
         SELECT g.name
         FROM goods g
         WHERE s.good_id = g.id
       ) good_name
FROM sales s;

-- TODO: на сколько продал каждый менеджер (сумма)
-- имя менеджера, сумма продаж
-- должно быть 4 строки в ответе

-- неправильно, Даша спряталась :-)
SELECT s.manager_id,
       SUM(s.quantity * s.price)                                 total,
       (SELECT m.name FROM managers m WHERE s.manager_id = m.id) manager_name -- должен возвращать только 1 строку и 1 столбец
FROM sales s -- sales AS s (везде sales - будет s)
GROUP BY s.manager_id;

-- "правильный"
SELECT m.id,
       m.name,
       m.salary,
       m.plan,
       ifnull((
                SELECT SUM(s.quantity * s.price)
                FROM sales s
                WHERE s.manager_id = m.id
              ), 0) total
       -- вот это работать не будет m.plan - total
FROM managers m;

-- VIEW
CREATE VIEW manager_stats AS
SELECT m.id,
       m.name,
       m.salary,
       m.plan,
       ifnull((
                SELECT SUM(s.quantity * s.price)
                FROM sales s
                WHERE s.manager_id = m.id
              ), 0) total
FROM managers m;

SELECT m.name, m.plan - m.total todo
FROM manager_stats m;

-- TODO: для каждого вывести имя босса
-- имя менеджера, имя босса

SELECT m.name,
       (
         SELECT b.name
         FROM managers b
         WHERE b.id = m.boss_id
       ) boss_name
FROM managers m;

-- INNER JOIN

SELECT s.id, s.price, s.quantity, g.name good_name
FROM sales s
       JOIN goods g
            ON s.good_id = g.id;

SELECT s.id,
       s.price,
       s.quantity,
       g.name good_name,
       m.name manager_name
FROM sales s
       JOIN goods g
            ON s.good_id = g.id
       JOIN managers m
            ON s.manager_id = m.id;

-- LEFT JOIN

SELECT m.name, b.name boss_name
FROM managers m
       LEFT JOIN managers b on m.boss_id = b.id;

-- CTE (Common Table Expressions)

WITH managers_cte AS (
  SELECT m.id,
         m.name,
         m.salary,
         m.plan,
         ifnull((
                  SELECT SUM(s.quantity * s.price)
                  FROM sales s
                  WHERE s.manager_id = m.id
                ), 0) total
  FROM managers m
)
SELECT name, plan - total todo
FROM managers_cte;

SELECT m.name
FROM managers m
UNION
SELECT g.name
FROM goods g;

-- Толстой, Пушкин
-- Козьма Прутков

-- иерархия
-- for:
-- 1:
-- SELECT ... boss_id = 1 : Step 2
-- SELECT ... boss_id IN (step 2) : Step 3
-- SELECT ... boss_id IN (step 3) : ...

-- SELECT ... boss_id IN (step 100) -> 0 строк

-- Рекурсивные запросы
-- функция вызывает саму себя

WITH RECURSIVE
     manager_hierarchy(id, name, boss, level) AS (
       -- выбираем того, с кого начинаем
       SELECT m.id, m.name, 'I''m a Boss', 1
       FROM managers m
       WHERE m.boss_id IS NULL
       UNION ALL
       SELECT m.id, m.name, mh.name, mh.level + 1
       FROM managers m
              JOIN manager_hierarchy mh
                   ON m.boss_id = mh.id
     )
SELECT *
FROM manager_hierarchy;

-- Vasya [+]
-- Petya [-]
-- Masha [+]
-- Dasha [-]

-- Транзакции
UPDATE managers
SET salary = salary * 1.1;
SELECT *
FROM managers;
UPDATE goods
SET price = price * 1.1;
SELECT *
FROM goods;

-- HomeWork
SELECT COUNT(*) total_sales
FROM sales;

SELECT SUM(quantity * price) total_sum
FROM sales;

SELECT SUM(quantity) AS total_sales_quantity
FROM sales;

SELECT good_id,Sum(quantity)
FROM sales
GROUP BY good_id;

SELECT manager_id,SUM(quantity * price)
FROM sales
GROUP BY manager_id;

-- стоимость самой дорогой продажи
SELECT id, (quantity * price)
FROM sales
ORDER BY (quantity * price) DESC
LIMIT 1;

-- стоимость самой дешёвой продажи
SELECT id, (quantity * price)
FROM sales
ORDER BY (quantity * price) ASC
LIMIT 1;

-- средняя стоимость одной продажи
SELECT AVG(price*quantity) average
FROM sales;

-- средняя стоимость продажи по каждому менеджеру (должно быть 4 строки)
SELECT m.id,
       m.name,
       ifnull((SELECT AVG(s.quantity * s.price)
               FROM sales s
               WHERE s.manager_id = m.id), 0) total
FROM managers m;

-- среднее количество продаж по каждому менеджеру (должно быть 4 строки)
SELECT m.name,
       ifnull((SELECT AVG(s.quantity)
               FROM sales s
               WHERE s.manager_id = m.id), 0) total
FROM managers m;

-- максимальная стоимость продажи по каждому менеджеру (должно быть 4 строки)
SELECT m.name,
       ifnull((SELECT MAX(s.quantity*s.price)
               FROM sales s
               WHERE s.manager_id = m.id), 0) total
FROM managers m;

