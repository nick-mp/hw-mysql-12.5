-- Задание 1

SELECT SUM(DATA_LENGTH), SUM(INDEX_LENGTH), SUM(INDEX_LENGTH) / SUM(DATA_LENGTH) * 100 as procent_index
FROM INFORMATION_SCHEMA.TABLES 

-- Задание 2

-- в ходе анализа выявлены не используемые таблицы, зависимости от которых существенно тормозили процесс - удалены.

EXPLAIN	ANALYZE
select distinct concat(c.last_name, ' ', c.first_name), sum(p.amount) over (partition by c.customer_id)
from rental r
join payment p on p.payment_date = r.rental_date
join customer c on r.customer_id = c.customer_id
where p.payment_date >= '2005-07-30' and p.payment_date < DATE_ADD('2005-07-30', INTERVAL 1 DAY);


-> Table scan on <temporary>  (cost=2.5..2.5 rows=0) (actual time=4929..4929 rows=391 loops=1) -- результат изначального запроса (оставил только 1е строки)
                        
-> Table scan on <temporary>  (cost=2.5..2.5 rows=0) (actual time=7.34..7.38 rows=391 loops=1) -- результат после оптимизации (более чем в 600 раз быстрее)

-> Table scan on <temporary>  (cost=2.5..2.5 rows=0) (actual time=7.26..7.3 rows=391 loops=1) -- после добавления индексов

-> Table scan on <temporary>  (cost=2.5..2.5 rows=0) (actual time=7.19..7.23 rows=391 loops=1) -- после изменения на join таблиц payment, customer

-> Table scan on <temporary>  (cost=2.5..2.5 rows=0) (actual time=4.1..4.14 rows=391 loops=1) -- после изменения условия where (убрано DATE) 

-> Table scan on <temporary>  (cost=2.5..2.5 rows=0) (actual time=3.67..3.71 rows=391 loops=1)
    -> Temporary table with deduplication  (cost=0..0 rows=0) (actual time=3.67..3.67 rows=391 loops=1)
        -> Window aggregate with buffering: sum(payment.amount) OVER (PARTITION BY c.customer_id )   (actual time=2.72..3.51 rows=642 loops=1)
            -> Sort: c.customer_id  (actual time=2.7..2.74 rows=642 loops=1)
                -> Stream results  (cost=730 rows=635) (actual time=0.0361..2.56 rows=642 loops=1)
                    -> Nested loop inner join  (cost=730 rows=635) (actual time=0.0331..2.38 rows=642 loops=1)
                        -> Nested loop inner join  (cost=508 rows=635) (actual time=0.0286..1.75 rows=642 loops=1)
                            -> Index range scan on p using payment_ind over ('2005-07-30 00:00:00' <= payment_date < '2005-07-31 00:00:00'), with index condition: ((p.payment_date >= TIMESTAMP'2005-07-30 00:00:00') and (p.payment_date < <cache>(('2005-07-30' + interval 1 day))))  (cost=286 rows=634) (actual time=0.022..0.718 rows=634 loops=1)
                            -> Covering index lookup on r using rental_date (rental_date=p.payment_date)  (cost=0.25 rows=1) (actual time=0.0011..0.0015 rows=1.01 loops=634)
                        -> Single-row index lookup on c using PRIMARY (customer_id=r.customer_id)  (cost=0.25 rows=1) (actual time=838e-6..860e-6 rows=1 loops=642)


CREATE INDEX payment_index ON payment(payment_date);

CREATE INDEX rental_date ON rental(rental_date);


SELECT table_name, data_length, index_length
FROM INFORMATION_SCHEMA.TABLES
WHERE table_name = "customer";