CREATE TABLE goods (
  id       INTEGER PRIMARY KEY AUTOINCREMENT ,
  name     TEXT    NOT NULL,
  price    INTEGER NOT NULL CHECK (price > 0),
  quantity INTEGER NOT NULL
    CHECK (quantity >= 0)
    DEFAULT 0
);

CREATE TABLE managers (
  id INTEGER PRIMARY KEY AUTOINCREMENT ,
  name TEXT NOT NULL,
  plan INTEGER NOT NULL CHECK (plan > 0),
  boss_id INTEGER REFERENCES managers
);

CREATE TABLE sales (
  id INTEGER PRIMARY KEY AUTOINCREMENT ,
  manager_id INTEGER NOT NULL REFERENCES managers,
  good_id INTEGER NOT NULL REFERENCES goods,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  price INTEGER NOT NULL CHECK (price > 0)
);

INSERT INTO managers VALUES
  (1, 'Vasya', 10000, NULL),
  (2, 'Petya', 20000, 1),
  (3, 'Masha', 30000, 1),
  (4, 'Dasha', 30000, 3)
;

INSERT INTO goods VALUES
  (1, 'BigMac', 120, 10),
  (2, 'Burger', 60, 10),
  (3, 'Cola', 40, 10);

INSERT INTO sales (
  manager_id,
  good_id,
  quantity,
  price)
VALUES
  (1, 1, 5, 200), -- Vasya, BigMac - 200rub
  (1, 1, 5, 120), -- Vasya, BigMac - 120rub
  (2, 2, 1, 60),
  (2, 2, 1, 50),
  (3, 3, 10, 50), -- Masha, Cola - 50
  (3, 2, 10, 80); -- Masha, Burger - 80