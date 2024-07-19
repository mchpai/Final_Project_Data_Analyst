-- Selama transaksi yang terjadi selama 2021, pada bulan apa total nilai transaksi
--(after_discount) paling besar? Gunakan is_valid = 1 untuk memfilter data transaksi.
-- Source table: order_detail

select
    to_char(order_date, 'Month') month_2021,
    round(sum(after_discount)) total_sales
 from order_detail 
where
    is_valid = 1
    and to_char(order_date,'yyyy-mm-dd') between '2021-01-01' and '2021-12-31'
 group by 1
 order by 2 desc

-- Selama transaksi pada tahun 2022, kategori apa yang menghasilkan nilai transaksi paling
-- besar? Gunakan is_valid = 1 untuk memfilter data transaksi
-- Source table: order_detail, sku_detai

select
    sd.category,
    sum(od.after_discount) total_sales
 from order_detail od
 left join sku_detail sd on sd.id = od.sku_id
 where
    is_valid = 1
    and to_char(order_date,'yyyy-mm-dd') between '2022-01-01' and '2022-12-31'
 group by 1
 order by 2 desc

-- Bandingkan nilai transaksi dari masing-masing kategori pada tahun 2021 dengan 2022.
-- Sebutkan kategori apa saja yang mengalami peningkatan dan kategori apa yang mengalami
-- penurunan nilai transaksi dari tahun 2021 ke 2022. Gunakan is_valid = 1 untuk memfilter data transaksi.
-- Source table: order_detail, sku_detail
	
with total_perbandingan as (
 select
    sd.category,
    sum(case when to_char(order_date,'yyyy-mm-dd') 
		between '2021-01-01' and '2021-12-31' then od.after_discount end) total_sales_2021,
    sum(case when to_char(order_date,'yyyy-mm-dd') 
		between '2022-01-01' and '2022-12-31' then od.after_discount end) total_sales_2022
 from order_detail od
    left join sku_detail sd 
    on sd.id = od.sku_id
 where
    is_valid = 1
    group by 1
 order by 2 desc
 )
 select
    total_perbandingan.*,
    total_sales_2022 - total_sales_2021 growth_value,
    CASE
        WHEN total_sales_2022 > total_sales_2021 THEN 'Increase'
        WHEN total_sales_2022 < total_sales_2021 THEN 'Decrease'
        ELSE 'No Change'
    END AS growth_status
 from total_perbandingan
 order by 4 desc

-- Tampilkan top 5 metode pembayaran yang paling populer digunakan selama 2022
-- (berdasarkan total unique order). Gunakan is_valid = 1 untuk memfilter data transaksi.
-- Source table: order_detail, payment_method

select
 pd.payment_method,
 count (distinct od.id) total_pembayaran
from 
 order_detail od
 left join payment_detail pd on pd.id = od.payment_id
where
 to_char (order_date, 'yyyy-mm-dd') between '2022-01-01' and '2022-12-31'
 and is_valid = 1 
  group by 1
  order by 2 desc

-- Urutkan dari ke-5 produk ini berdasarkan nilai transaksinya.
-- 1. Samsung
-- 2. Apple
-- 3. Sony
-- 4. Huawei
-- 5. Lenovo
-- Gunakan is_valid = 1 untuk memfilter data transaksi.
-- Source table: order_detail, sku_detail
	
	with Brand as
	(
	select
	 case
	  When lower(sd.sku_name) like '%samsung%' then 'samsung'
	  when lower(sd.sku_name) like '%apple%' or
		   lower(sd.sku_name) like '%iphone%' or
		   lower(sd.sku_name) like '%macbook%' then 'apple'
	  when lower(sd.sku_name) like '%sony%' then 'sony'
	  when lower(sd.sku_name) like '%huawei%' then 'huawei'
	  when lower(sd.sku_name) like '%lenovo%' then 'lenovo'
	  end nama_brand,
	sum (od.after_discount) Total_Penjualan
	from order_detail od
	left join sku_detail sd on sd.id = od.sku_id 
	where
    to_char(order_date,'yyyy-mm-dd') between '2022-01-01' and '2022-12-31'
	and is_valid = 1
	group by 1 
	)
	select
	Brand.*
	 from brand
	where 
	 nama_brand notnull
	 order by 2 desc
