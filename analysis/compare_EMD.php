<?php

	$cats = array();
	getRelations("emd_losangeles_precovid-newyork_precovid.csv");
	getRelations("emd_losangeles_precovid-houston_precovid.csv");
	getRelations("emd_losangeles_precovid-chicago_precovid.csv");
	getRelations("emd_newyork_precovid-houston_precovid.csv");
	getRelations("emd_newyork_precovid-chicago_precovid.csv");
	getRelations("emd_houston_precovid-chicago_precovid.csv");

	$file = fopen("../data/mostemd.csv","w");
	$cnt = 0;
	foreach($cats as $k=>$v) {
		if (count($v) == 6) {
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
		        //$sig = floatval(str_replace('"','',$e[2]));
		        $emd = floatval(str_replace('"','',$e[1]));
		        
		        //if ($sig >= 0.05) {
		        	if (!isset($cats[$cat]))
		        		$cats[$cat] = array();
		        	$cats[$cat][$name] = $emd;
		        //}
		    }

		    fclose($handle);
		} else {
		    // error opening the file.
		} 
	}


?>