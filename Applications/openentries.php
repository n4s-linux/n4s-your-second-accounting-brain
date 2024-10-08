<?php
require_once("/svn/svnroot/Applications/gettags.php");
function findsimilar($trans,$transactions) {
	$forslag=array();
	$total = 0;
	$trans["tekst"] = trim($trans["tekst"]);
	foreach ($transactions as $curtrans) {
		if (isset($curtrans["Description"])) $curtrans["Description"] = trim($curtrans["Description"]);
  		if (stristr(json_encode($curtrans['Transactions']),"Fejl")) continue; // tager ej fejlkonto med i betragtning
		$id = gettag($trans,"TransID");
		error_reporting(0);
		if(! ( ($trans['Amount'] > 0 && $curtrans["Transactions"][$id]['Amount'] > 0) || ($trans['Amount'] < 0 && $curtrans["Transactions"][$id]['Amount'] < 0) )) continue; // udgifter matches med ugfiter, indtægter matches med indtægter
		error_reporting(E_ALL);
		$similarity = similar_text($curtrans['Description'],$trans['tekst'],$percent);
		if ($percent > 90) {
			error_reporting(0);
			$konto = $curtrans["Transactions"][$id]['Account'];
			$moms = $curtrans["Transactions"][$id]['Func'];
			error_reporting(E_ALL);
			if ($konto == "") continue;
			if (!isset($forslag[$konto . "|||" . $moms] )) { 
				$forslag[$konto . "|||" . $moms] = 1;$total++;
			}
			else { 
				$total++; $forslag[$konto . "|||" . $moms]++;
			}
		}	
	}
	foreach ($forslag as $kontoforslag => $antal) {
		if ($antal / $total * 100 >= 80) {
			$x = explode("|||",$kontoforslag);
			fwrite(STDERR,"Forslag [ $x[0]$moms] på ". $antal / $total *100 . "% accepteres for $trans[tekst]\n");
			return array("Kontoforslag"=>$x[0],"Momsforslag"=>$x[1],"Sandsynlighed"=>$antal/$total*100 . "%");
		}
		else if ($antal / $total * 100 >= 50) {
			$x = explode("|||",$kontoforslag);
			if ($x[1] != "") $moms = " ($x[1])"; else $moms = "";
			fwrite(STDERR,"Forslag [ $x[0]$moms] på ". $antal / $total *100 . "% ignoreres for $trans[tekst] da konteringen ikke er sikker nok\n");
		}
	}
	return false;
}
function cirka ($transa,$transb,$afvigelse = 5) {
	$deviation = abs(1- ($transa['Amount'] / $transb['Amount']));
	if ($deviation < $afvigelse) return true; else return false;
}
function findmatch($open,$fejl,$maxtimediff = 5) {
	global $tpath;
	foreach ($open as $key => $val) {
		foreach ($val['Transactions'] as $curopentrans) {
			foreach ($fejl as $curfejl) {
				if (isset($curopentrans['Description']) && stristr($curopentrans['Description'],"#cirka") && cirka($curopen,$curfejl)) {
					die("yescirka\n");	
				}
				if ($curopentrans['Amount'] == -$curfejl['Amount']) {
					$diff = abs(strtotime($curopentrans['Date']) - strtotime($curfejl['Date'])) / 86400;
					if ($diff > $maxtimediff) continue;
					$curfejl['Filename'] = gettag($curfejl,"Filename");
					$md = md5(json_encode($curopentrans['Filename']) . json_encode($curfejl['Filename']));
					if (file_exists("$tpath/.openentries/$md")) continue;
					return array('Open'=>$curopentrans,'Fejl'=>$curfejl,'Ignorefile'=>"$tpath/.openentries/$md");
				}
			}
		}
	}
	return false;
}
function getopen($dk) {
	$grouped = groupbyacc($dk);
	if (empty($grouped)) die("empty group\n");
	$grouped_sorted = sortbydate($grouped);
	$removezeroes = removezero($grouped_sorted);
	return $removezeroes;
}
function removezero($d) {
	foreach ($d as $key => &$val) {
		$transactions = array();
		$sum = 0;
		foreach ($val['Transactions'] as &$curtrans) {
			$sum += $curtrans['Amount'];
			array_push($transactions,$curtrans);
			if (intval($sum) == 0) {
				$transactions = array();
			}
		}
		$retval[$key]['Transactions'] = $transactions;
		$retval[$key]['Sum'] = $sum;
	}
	return $d;
}
function transbydate($a,$b) {
	return strtotime($a['Date']) > strtotime($b['Date']);
}
function sortbydate($data) {
	foreach ($data as &$curdata) {
		usort($curdata['Transactions'],"transbydate");
	}
	return $data;
}
function groupbyacc($dk) {
	$r = array();
	foreach ($dk as $c) {
		$r[$c['Account']]['Transactions'][] = $c;
		if (isset($c['Account']['Sum']))
			$r[$c['Account']]['Sum'] += $c['Amount'];
		else
			$r[$c['Account']]['Sum'] = $c['Amount'];
	}
	// remove empty
	$retval = array();
	foreach ($r as $key=>$curr) {
		if (!intval($curr['Sum']) == 0)
			$retval[$key] = $curr;
	}
	return ($retval);
}
function getfejl($x,$onlyfejl = false) { //onlyfejl will only return fejlkonto postings, but sometimes we want to consider postings with no bilag as well
	$fejl = array();
	foreach ($x as $curtrans) {
		if (!$onlyfejl && stristr($curtrans['bilag'],"CSV-") && (substr($curtrans['Account'],0,strlen("Indtægter:")) == "Indtægter:" || substr($curtrans['Account'],0,strlen("Udgifter:")) == "Udgifter:")) {
			array_push($fejl,$curtrans);
		}
		else if (stristr($curtrans['Account'],'Fejlkonto')) {
			array_push($fejl,$curtrans);
		}
	}
	return $fejl;
}
function getdebcred($x) {
		$open = array();
		$i = 0;
		foreach ($x as $curtrans) {
				if (stristr($curtrans['Account'],'Debitorer') || stristr($curtrans['Account'],'Kreditorer')) {
					$curtrans['Filename'] = gettag($curtrans,"Filename");
					array_push($open,$curtrans);
				}
				$i++;
		}
		return $open;
}
?>
