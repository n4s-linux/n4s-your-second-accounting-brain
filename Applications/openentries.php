<?php
function findmatch($open,$fejl,$maxtimediff = 30) {
	global $tpath;
	foreach ($open as $key => $val) {
		foreach ($val['Transactions'] as $curopentrans) {
			foreach ($fejl as $curfejl) {
				if ($curopentrans['Amount'] == -$curfejl['Amount']) {
					$md = md5(json_encode($curopentrans) . json_encode($curfejl));
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
	foreach ($r as $key=>$curr) {
		if (!intval($curr['Sum']) == 0)
			$retval[$key] = $curr;
	}
	return ($retval);
}
function getfejl($x) {
	$fejl = array();
	foreach ($x as $curtrans) {
		if (stristr($curtrans['Account'],'Fejlkonto')) {
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
function gettag($trans,$tag) {
	if (!isset($trans['tags'])) return -1;
	$x = explode("$tag:",$trans['tags']);
	if (!isset($x[1])) {
		 return -2;
	}
	return trim(explode("||||",$x[1])[0]);
}
?>