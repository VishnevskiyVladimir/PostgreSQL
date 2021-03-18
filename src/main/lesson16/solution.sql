-- Second part of code works in console after choosing schema

CREATE DATABASE book_db;
-- Then we change console settings of IDEA database client to book_db
CREATE SCHEMA book_sch;
-- Then we change console settings of IDEA database client to book_db.book_sch
CREATE TABLE author
(
    id         SERIAL PRIMARY KEY,
    first_name VARCHAR(128) NOT NULL,
    last_name  VARCHAR(128) NOT NULL,
    UNIQUE (last_name, first_name)
);
CREATE TABLE book_db.book_sch.book
(
    id                 SERIAL PRIMARY KEY,
    name               VARCHAR(256) NOT NULL,
    year_of_publishing SMALLINT     NOT NULL CHECK (year_of_publishing < 2022),
    pages              SMALLINT     NOT NULL CHECK (pages >= 0),
    author_id          INTEGER REFERENCES author (id) ON DELETE SET NULL
);

DROP TABLE book;
DROP TABLE author;

INSERT INTO author(last_name, first_name)
VALUES ('Dokins', 'Richard'),
       ('Kurpatov', 'Andrej'),
       ('King', 'Stephen'),
       ('Kaneman', 'Daniel'),
       ('Kiyosaki', 'Robert'),
       ('Uhtomskiy', 'Alexej');
--
-- DELETE FROM author
-- RETURNING *;

INSERT INTO book(name, year_of_publishing, pages, author_id)
VALUES ('egoistic gen', 1980, 3500, (SELECT id FROM author WHERE last_name = 'Dokins')),
       ('his other book', 1995, 1500, (SELECT id FROM author WHERE last_name = 'Dokins')),
       ('red tablet', 2010, 6500, (SELECT id FROM author WHERE last_name = 'Kurpatov')),
       ('another book', 2020, 500, (SELECT id FROM author WHERE last_name = 'Kurpatov')),
       ('Dark tower', 2012, 1, (SELECT id FROM author WHERE last_name = 'King')),
       ('Dark tower 2', 1960, 9999, (SELECT id FROM author WHERE last_name = 'King')),
       ('Think slowly', 2019, 4500, (SELECT id FROM author WHERE last_name = 'Kaneman')),
       ('Decide fast', 1985, 2500, (SELECT id FROM author WHERE last_name = 'Kaneman')),
       ('Poor father', 2000, 30, (SELECT id FROM author WHERE last_name = 'Kiyosaki')),
       ('Rich father', 1987, 30, (SELECT id FROM author WHERE last_name = 'Kiyosaki')),
       ('Dominanta', 1983, 30, (SELECT id FROM author WHERE last_name = 'Uhtomskiy')),
       ('unknown', 1990, 3500, (SELECT id FROM author WHERE last_name = 'Uhtomskiy'));

-- DELETE FROM book
-- RETURNING *;

-- 4.	Написать запрос, выбирающий: название книги, год и имя автора,
-- отсортированные по году издания книги в возрастающем порядке.
-- Написать тот же запрос, но для убывающего порядка.

-- way 1
SELECT b.name, b.year_of_publishing, a.last_name || ' ' || a.first_name author
FROM book b
         LEFT JOIN author a on b.author_id = a.id
ORDER BY b.year_of_publishing DESC;
-- way 2
SELECT b.name,
       b.year_of_publishing,
       (SELECT last_name || ' ' || first_name
        FROM author
        WHERE id = b.author_id)
FROM book b
ORDER BY b.year_of_publishing DESC;

-- 5.	Написать запрос, выбирающий количество книг у заданного автора.

SELECT count(b.*)
FROM book b
WHERE b.author_id = (SELECT a.id
                     FROM author a
                     WHERE a.last_name = 'Dokins');

-- 6.	Написать запрос, выбирающий книги, у которых количество страниц
-- больше среднего количества страниц по всем книгам

SELECT *
FROM book
WHERE pages > (SELECT avg(pages)
               FROM book);

-- 	7.	Написать запрос, выбирающий 5 самых старых книг
-- Дополнить запрос и посчитать суммарное количество страниц среди этих книг

SELECT *,
       (SELECT sum(pages)
        FROM (SELECT *
              FROM book
              ORDER BY year_of_publishing
                  LIMIT 5) q2) sum_pages
FROM (SELECT *
      FROM book
      ORDER BY year_of_publishing
          LIMIT 5) q1;

-- 8.	Написать запрос, изменяющий количество страниц у одной из книг

UPDATE book
SET pages = pages * 2
WHERE id = (SELECT min(id)
            FROM book);

-- 9.	Написать запрос, удаляющий автора, который написал самую большую книгу

DELETE FROM author
WHERE id = (SELECT author_id
            FROM book
            where pages = (SELECT max(pages)
                           FROM book))
    RETURNING *;


