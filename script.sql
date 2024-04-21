-- Задание 1

SELECT SUM(DATA_LENGTH), SUM(INDEX_LENGTH), SUM(INDEX_LENGTH) / SUM(DATA_LENGTH) * 100 as procent_index
FROM INFORMATION_SCHEMA.TABLES 

-- Задание 2

-- в ходе анализа выявлены не используемые таблицы, зависимости от которых существенно тормозили процесс - удалены.

EXPLAIN	ANALYZE
select distinct concat(c.last_name, ' ', c.first_name), sum(p.amount) over (partition by c.customer_id)
from payment p, rental r, customer c
where date(p.payment_date) = '2005-07-30' and p.payment_date = r.rental_date and r.customer_id = c.customer_id



-> Table scan on <temporary>  (cost=2.5..2.5 rows=0) (actual time=4929..4929 rows=391 loops=1) -- результат изначального запроса (оставил только 1е строки)
                        
-> Table scan on <temporary>  (cost=2.5..2.5 rows=0) (actual time=7.34..7.38 rows=391 loops=1) -- результат после оптимизации (более чем в 600 раз быстрее)

-> Table scan on <temporary>  (cost=2.5..2.5 rows=0) (actual time=7.26..7.3 rows=391 loops=1) -- после добавления индексов


CREATE INDEX payment_index ON payment(payment_date);

CREATE INDEX rental_date_ind ON rental(rental_date);


SELECT table_name, data_length, index_length
FROM INFORMATION_SCHEMA.TABLES
WHERE table_name = "customer";