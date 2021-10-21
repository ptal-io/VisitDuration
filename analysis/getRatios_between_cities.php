<?php

	$cats = array();
	getRelations("ttest_newyork_precovid-newyork_postcovid.csv");
	getRelations("ttest_losangeles_precovid-losangeles_postcovid.csv");
	getRelations("ttest_chicago_precovid-chicago_postcovid.csv");
	getRelations("ttest_houston_precovid-houston_postcovid.csv");

	$file = fopen("../data/ratios.csv","w");
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
		$name = $f[1] . "-" . $f[3];

		$handle = fopen("../data/".$file, "r");
		$out = array();
		if ($handle) {
		    while (($line = fgets($handle)) !== false) {
		        $e = explode(",",$line);
		        $cat = str_replace('"','',$e[0]);
		        $pre = floatval(str_replace('"','',$e[8]));
		        $post = floatval(str_replace('"','',$e[9]));
		        //$sig = floatval(str_replace('"','',$e[2]));
		        //$diff = floatval(str_replace('"','',$e[5]));
		        //if ($sig >= 0.05) {
	        	if (!isset($cats[$cat]))
	        		$cats[$cat] = array();
	        	$cats[$cat][$name] = round(($pre-$post)/$pre * 1000)/10*-1;
		        //}
		    }

		    fclose($handle);
		} else {
		    // error opening the file.
		} 
	}


?>