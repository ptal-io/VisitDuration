<?php

	$cats = array();
	getRelations("losangeles_timespent_postcovid.csv");
	getRelations("newyork_timespent_postcovid.csv");
	getRelations("houston_timespent_postcovid.csv");
	getRelations("chicago_timespent_postcovid.csv");

	$file = fopen("../data/forjsd_post.csv","w");
	$cnt = 0;
	foreach($cats as $k=>$v) {
		if (count($v) == 4) {
			if ($cnt == 0)
				fwrite($file, $k . "," . implode(",", array_keys($v)) . "\n");
			fwrite($file, $k . "," . implode(",", $v) . "\n");
			$cnt++;
		}
	}
	fclose($file);

	function getRelations($file) {
		global $cats;
		$f = explode("_",str_replace("-","_",$file));
		$name = $f[0];

		$handle = fopen("../data/".$file, "r");
		$out = array();
		if ($handle) {
		    while (($line = fgets($handle)) !== false) {
		        $e = explode(",",$line);
		        $cat = str_replace('"','',$e[0]);
		        $count = intval(str_replace('"','',$e[1]));
		        $mean = floatval(str_replace('"','',$e[4]));
		        
		        if (!isset($cats[$cat]))
		        	$cats[$cat] = array();

		        if ($count >= 20)
		        	$cats[$cat][$name] = $mean;
		        
		    }

		    fclose($handle);
		} else {
		    // error opening the file.
		} 
	}


?>