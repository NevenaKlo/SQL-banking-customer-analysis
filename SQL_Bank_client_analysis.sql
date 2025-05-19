-- INDICATORI DI BASE
-- calcolo eta cliente: creo tabella temporanea popolata con colonne di banca.cliente + eta calcolata con case when per ottenere eta precisa

select * from banca.cliente; 

create temporary table cliente_tmp as
select id_cliente, nome, cognome, data_nascita, 
CASE
        WHEN MONTH(current_date()) >= MONTH(data_nascita) AND DAY(current_date()) >= DAY(data_nascita)
        THEN (YEAR(current_date()) - YEAR(data_nascita))
        ELSE (YEAR(current_date()) - YEAR(data_nascita) - 1)
    END AS eta
FROM
    banca.cliente;
   
  -- sanity check: vediamo la tabella temporanea
select * from cliente_tmp;

    
-- INDICATORI SULLE TRANSAZIONI
-- calcolo numero di tranzazioni in uscita e in entrate per ciascun conto
-- calcolo l'importo totale in entrata e uscita per ciascun conto

select * from banca.transazioni;
select * from banca.tipo_transazione;

create temporary table info_transazioni as
select t.id_conto,
sum(case when tt.segno = "+" then 1 else 0 end) as trans_entrata,
sum(case when tt.segno = "-" then 1 else 0 end) as trans_uscita,
sum(case when tt.segno = "+" then t.importo else 0 end) as importo_entrata,
sum(case when tt.segno = "-" then t.importo else 0 end) as importo_uscita
from banca.transazioni as t
join banca.tipo_transazione as tt
on t.id_tipo_trans = tt.id_tipo_transazione
group by 1;

select * from info_transazioni;

-- INDICATORI SUI CONTI
-- Calcolo numero totale di conti posseduti e conti posseduti per tipologia

select * from banca.conto;
select * from banca.tipo_conto;

create temporary table conti_tmp as
select c.id_cliente,
count(c.id_conto) as totale_conti,
sum(case when tc.desc_tipo_conto = 'Conto Base' then 1 else 0 end) as conto_base,
sum(case when tc.desc_tipo_conto = 'Conto Business' then 1 else 0 end) as conto_business,
sum(case when tc.desc_tipo_conto = 'Conto Privati' then 1 else 0 end) as conto_privati,
sum(case when tc.desc_tipo_conto = 'Conto Famiglie' then 1 else 0 end) as conto_famiglie
from banca.conto as c
join banca.tipo_conto as tc 
on c.id_tipo_conto = tc.id_tipo_conto
group by 1;

select * from conti_tmp;

-- INDICATORI SULLE TRANSAZIONI PER TIPOLOGIA DI CONTO

-- unisco la tabella temporanea info_transazioni con banca.conti per avere sia id_conto che id_cliente
create temporary table info_trans_conti as
select 
 it.id_conto,
    it.trans_entrata,
    it.trans_uscita,
    it.importo_entrata,
    it.importo_uscita,
    c.id_cliente,
    c.id_tipo_conto
from info_transazioni as it
inner join banca.conto as c
on it.id_conto = c.id_conto;

select * from info_trans_conti;

-- calcolo numero di transazioni in uscita ed entrata per tipologia di conto
-- calcolo importo transato in uscita ed entrata per tipologia di conto

create temporary table trans_tipologia as
select i.id_cliente,
sum(case when i.id_tipo_conto = 0 then i.trans_uscita else 0 end) as transout_base,
sum(case when i.id_tipo_conto = 1 then i.trans_uscita else 0 end) as transout_business,
sum(case when i.id_tipo_conto = 2 then i.trans_uscita else 0 end) as transout_privati,
sum(case when i.id_tipo_conto = 3 then i.trans_uscita else 0 end) as transout_famiglie,
sum(case when i.id_tipo_conto = 0 then i.trans_entrata else 0 end) as transin_base,
sum(case when i.id_tipo_conto = 1 then i.trans_entrata else 0 end) as transin_business,
sum(case when i.id_tipo_conto = 2 then i.trans_entrata else 0 end) as transin_privati,
sum(case when i.id_tipo_conto = 3 then i.trans_entrata else 0 end) as transin_famiglie,
sum(case when i.id_tipo_conto = 0 then i.importo_entrata else 0 end) as importoin_base,
sum(case when i.id_tipo_conto = 1 then i.importo_entrata else 0 end) as importoin_business,
sum(case when i.id_tipo_conto = 2 then i.importo_entrata else 0 end) as importoin_privati,
sum(case when i.id_tipo_conto = 3 then i.importo_entrata else 0 end) as importoin_famiglie,
sum(case when i.id_tipo_conto = 0 then i.importo_uscita else 0 end) as importoout_base,
sum(case when i.id_tipo_conto = 1 then i.importo_uscita else 0 end) as importoout_business,
sum(case when i.id_tipo_conto = 2 then i.importo_uscita else 0 end) as  importoout_privati,
sum(case when i.id_tipo_conto = 3 then i.importo_uscita else 0 end) as importoout_famiglie
from info_trans_conti as i
group by 1;

select * from trans_tipologia;

-- FINAL TABLE
-- left join on "id_cliente" tra le tabelle temporanee create
-- uso coalesce() per inserire 0 al posto di NULL nelle righe dei clienti senza conti

create table banca_mml as
select
    cl.id_cliente,
    cl.nome,
    cl.cognome,
    cl.data_nascita,
    cl.eta,
    coalesce(ct.totale_conti, 0) as totale_conti,
    coalesce(ct.conto_base, 0) as conto_base,
    coalesce(ct.conto_business, 0) as conto_business,
    coalesce(ct.conto_privati, 0) as conto_privati,
    coalesce(ct.conto_famiglie, 0) as conto_famiglie,
    coalesce(tt.transout_base, 0) as transout_base,
    coalesce(tt.transout_business, 0) as transout_business,
    coalesce(tt.transout_privati, 0) as transout_privati,
    coalesce(tt.transout_famiglie, 0) as transout_famiglie,
    coalesce(tt.transin_base, 0) as transin_base,
    coalesce(tt.transin_business, 0) as transin_business,
    coalesce(tt.transin_privati, 0) as transin_privati,
    coalesce(tt.transin_famiglie, 0) as transin_famiglie,
    coalesce(tt.importoin_base, 0) as importoin_base,
    coalesce(tt.importoin_business, 0) as importoin_business,
    coalesce(tt.importoin_privati, 0) as importoin_privati,
    coalesce(tt.importoin_famiglie, 0) as importoin_famiglie,
    coalesce(tt.importoout_base, 0) as importoout_base,
    coalesce(tt.importoout_business, 0) as importoout_business,
    coalesce(tt.importoout_privati, 0) as importoout_privati,
    coalesce(tt.importoout_famiglie, 0) as importoout_famiglie
from cliente_tmp as cl
left join conti_tmp as ct 
    on cl.id_cliente = ct.id_cliente
left join trans_tipologia as tt 
    on cl.id_cliente = tt.id_cliente;

-- tabella finale 
select * from banca_mml;