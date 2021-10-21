<?php

	$city = $argv[1];

	// ssh athena@athena-platial.geog.mcgill.ca -L 5555:localhost:5432
	$dbconn = pg_connect("host=localhost port=5555 dbname=timespent user=poi password=poi");
	$query = "select unnest(cats) as cat, array_to_string(time_spent,',') as ts from ".$city." where array_length(time_spent,1) > 0 and match = 1";
	$res = pg_query($query) or die(pg_last_error());

	$cats = array();
	while($row = pg_fetch_object($res)) {
		if (strlen($row->cat) > 1) {
			if (!isset($cats[$row->cat])) 
				$cats[$row->cat] = array();
			
			$g = explode(",",$row->ts);
			$cats[$row->cat][] = array_sum($g) / count($g);
		}
	}
	$max = 0;
	foreach($cats as $k=>$v) {
		if (count($v) > $max)
			$max = count($v);
	}

	$file = fopen("../data/".$city."_timespent_full.csv","w");
	//fwrite($file, "Category\n");
	$names = "";
	foreach($cats as $k=>$v) {
		if (count($v) > 19) {
			$names .= strtolower($k) . ",";
		}
	}
	fwrite($file,rtrim($names, ","));
	fwrite($file, "\n");

	
	for($i=0;$i<$max;$i++) {
		$names = "";
		foreach($cats as $k=>$v) {
			if (count($v) > 19) {
				if (isset($v[$i]))
					$names .= $v[$i] . ",";
				else
					$names .= ",";
			}
			
		}
		fwrite($file,rtrim($names, ","));
		fwrite($file, "\n");
	}
	fclose($file);

/*
alter table houson_precovid add column match smallint default 0;
alter table houson_postcovid add column match smallint default 0;
update houson_precovid set match = 1 where concat(name,lat,lng) in (select concat(name,lat,lng) from houson_postcovid);
update houston_postcovid set match = 1 where concat(name,lat,lng) in (select concat(name,lat,lng) from houston_precovid);
*/
?>