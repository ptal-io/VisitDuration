create table chi2021 as select safegraph_place_id, location_name, street_address, median(median_dwell), avg(median_dwell) as mean, stddev(median_dwell) from weekly where city ilike 'Chicago%' group by safegraph_place_id, location_name, street_address;

create table chi2020 as select safegraph_place_id, location_name, street_address, median(median_dwell), avg(median_dwell) as mean, stddev(median_dwell) from weekly2020 where city ilike 'Chicago%' group by safegraph_place_id, location_name, street_address;

create table chi_google_places as select a.name, a.lat, a.lng, array_avg(a.time_spent) as ts2020, array_avg(b.time_spent) as ts2021 from chicago_precovid a, chicago_postcovid b where a.name = b.name and a.lat = b.lat and a.lng = b.lng and a.time_spent[1] is not null and b.time_spent[1] is not null;

create table chi_safegraph_places as select a.safegraph_place_id, a.location_name, a.median as med2020, a.mean as mean2020, b.median as med2021, b.mean as mean2021 from chi2020 a, chi2021 b where a.safegraph_place_id = b.safegraph_place_id;

alter table chi_safegraph_places add column lat float8, add column lng float8;

update chi_safegraph_places set lat = a.latitude, lng = a.longitude from places a where a.safegraph_place_id = chi_safegraph_places.safegraph_place_id;

# create table chi_gs as select a.safegraph_place_id as sid, b.id as gid, a.location_name, b.name, levenshtein(lower(a.location_name), lower(b.name)), st_distancesphere(st_makepoint(a.longitude, a.latitude), st_makepoint(b.lng, b.lat)), b.cats, a.med2020, a.med2021, a.mean2020, a.mean2021, a.sd2020, a.sd2021, array_avg(b.ts2020) as g2020, array_avg(b.ts2021) as g2021 from chi_safegraph_places a, chi_google_places b where st_distancesphere(st_makepoint(a.longitude, a.latitude), st_makepoint(b.lng, b.lat)) < 100 and levenshtein(lower(a.location_name), lower(b.name)) < 3;


alter table chi_google_places add column id serial;
alter table chi_google_places add column cats varchar[];
update chi_google_places b set cats = a.cats from chicago_precovid a where a.name = b.name and a.lat = b.lat and a.lng = b.lng;

create table chi_gs as select a.safegraph_place_id as sid, b.id as gid, a.location_name, b.name, levenshtein(lower(a.location_name), lower(b.name)), st_distancesphere(st_makepoint(a.lng, a.lat), st_makepoint(b.lng, b.lat)), b.cats, a.med2020, a.med2021, a.mean2020, a.mean2021, b.ts2020 as g2020, b.ts2021 as g2021 from chi_safegraph_places a, chi_google_places b where st_distancesphere(st_makepoint(a.lng, a.lat), st_makepoint(b.lng, b.lat)) < 200 and levenshtein(lower(a.location_name), lower(b.name)) < 1;

#\copy (select unnest(cats) as cat, count(*) as cnt, median(med2021)-median(med2020) as med, avg(mean2021)-avg(mean2020) as mean, avg(g2021) - avg(g2020) as goog from chi_gs group by cat order by cnt desc) to '/home/athena/safegraph/chi.csv' with csv;

\copy (select med2021-med2020 as med, mean2021-mean2020 as mean, g2021-g2020 as goog from chi_gs) to '/home/athena/safegraph/chi_all.csv' with csv header;

data <- read.csv('chi_all.csv', header=T)



create view vw_ny as select * from (select cats, count(*) as cnt from (select unnest(cats) as cats from newyork_precovid) a group by cats) b where cnt > 10 order by cats;

create view vw_la as select * from (select cats, count(*) as cnt from (select unnest(cats) as cats from losangeles_precovid) a group by cats) b where cnt > 10 order by cats;

create view vw_ch as select * from (select cats, count(*) as cnt from (select unnest(cats) as cats from chicago_precovid) a group by cats) b where cnt > 10 order by cats;

create view vw_ho as select * from (select cats, count(*) as cnt from (select unnest(cats) as cats from houston_precovid) a group by cats) b where cnt > 10 order by cats;

select a.cats, a.cnt, b.cnt, c.cnt, d.cnt from vw_ny a, vw_la b, vw_ch c, vw_ho d where a.cats = b.cats and a.cats = c.cats and a.cats = d.cats;