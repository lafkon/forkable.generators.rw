<?php

 $voicedirectory  = "o/free/voice";
 $posterdirectory = "o/__";
 $peopledirectory = "i/free/png/people"; 
 $pdfppldirectory = "o/free/pdf/people"; 

 if(isset($_GET["md5"])) {

 	$txt = (htmlspecialchars($_GET["md5"]) .'_Q.txt');

 	if(!file_exists($voicedirectory .'/' .$txt )) {
		$host  = $_SERVER['HTTP_HOST'];
		$uri  = rtrim(dirname($_SERVER['PHP_SELF']), '/\\');
		$extra = 'Q&A';
		header("Location: http://$host$uri/$extra");
		exit;
 	} 
 } else {
	$txt = glob($voicedirectory."/*_Q.txt");
	$txt = $txt[rand(0, count($txt)-1)];
 }

?>


<html>
<head>
<title>Libre Graphics Questions & Answers</title>
<script language="javascript">

var initialQtxt;
var qgreen, agreen = false;

function rawurlencode(str) {
  return encodeURIComponent(str).replace(/!/g, '%21').replace(/'/g, '%27').replace(/\(/g, '%28').
  replace(/\)/g, '%29').replace(/\*/g, '%2A').replace(/~/g, '%7E');
}

window.onresize = function(event) {
  document.getElementById('answer').style.paddingTop =   (58+((document.getElementById('controls').offsetTop) + 50) - (document.getElementById('answer').offsetTop))  +'px';
}

function textAreaChanged(elem) {

	if(elem.name == 'question') {
		if(rawurlencode(elem.value) == initialQtxt) {
			document.getElementById('questionbg').style.backgroundColor = 'transparent';
			document.getElementById('allanswers').style.display = 'block';
			qgreen = false;
		} else {
			document.getElementById('questionbg').style.backgroundColor = '#00a651';
			document.getElementById('write').src = 'i/free/png/interface/write_over.png';
			document.getElementById('read').style.backgroundImage = 'url(i/free/png/interface/read.png)';
			document.getElementById('allanswers').style.display = 'none';
			qgreen = true;
		}
	}
	else if(elem.name == 'answer') {
		if(elem.value == "") {
			document.getElementById('answerbg').style.backgroundColor = 'transparent';
			agreen = false;
		} else {
			document.getElementById('answerbg').style.backgroundColor = '#00a651';
			document.getElementById('write').src = 'i/free/png/interface/write_over.png';
			document.getElementById('read').style.backgroundImage = 'url(i/free/png/interface/read.png)';
			agreen = true;
		}
	}
	
	if(!qgreen && !agreen) {
		document.getElementById('write').src = 'i/free/png/interface/write.png';
		document.getElementById('read').style.backgroundImage = 'url(i/free/png/interface/read_over.png)';
	}
}

</script>

<link rel="stylesheet" href="q+a.css" type="text/css" />
</head>
<body onLoad='onresize();'>


<?php

$name = basename($txt, ".txt");
$info = explode("_", $name);

echo "<div class='komplett'>";
echo "<form action='post.php' name='voicesfromthepublic' method='post' accept-charset='utf-8'>";

// -------------------------------------------- // QUESTION

$question = $voicedirectory."/".$info[0]."_Q.txt";
if(is_readable($question)) {
	$f = fopen($question, "r");
	while(! feof($f)){
		$qtxt .=  html_entity_decode(fgets($f));
	}
	fclose($f);
} else {
	$qtxt = 'oops...error.';
}

echo "<div id='questionbg' class='questionbg'>";
echo "</div>";

echo "<textarea name='question' onkeyup='textAreaChanged(question)' spellcheck='false' autocomplete='off' class='question'>";
	echo $qtxt;
echo "</textarea>";

echo "<script>initialQtxt = '" .rawurlencode($qtxt) ."'; </script>";

// -------------------------------------------- // EMPTYANSWER


echo "<div id='answerbg' class='answerbg'>";
echo "</div>";

echo "<textarea name='answer' id='answer' onkeyup='textAreaChanged(answer)' spellcheck='false' autocomplete='off' class='answer'>";
echo "</textarea>";

// -------------------------------------------- // PEOPLE

$ppl_l = glob($peopledirectory."/*_L.png");
$ppl_r = glob($peopledirectory."/*_R.png");
$sel_l = array_rand($ppl_l);
$sel_r = array_rand($ppl_r);

echo "<div class='people'>";
echo "<img src='" .$ppl_l[$sel_l] ."' class='talkL' />";
echo "<img src='" .$ppl_r[$sel_r] ."' class='talkR'  />";
echo "</div>";

// -------------------------------------------- // ALLANSWERS


echo "<div id='allanswers' class='allanswers'>";

$allanswers = array_reverse(glob($voicedirectory.'/'.$info[0].'_A-*.*'));
foreach($allanswers as $answerx) {

	$lines = file_get_contents($answerx);
	if(strlen($lines)==1 || strlen($lines)==0) { continue; }
	
	echo "<div id='answerx' class='answer_" .(rand(0,3)) ."'>";
	//echo "<textarea name='answerx' autocomplete='off' class='answerx'>";
	echo html_entity_decode($lines);
	//echo "</textarea>";
	echo "</div>";
}

$md5 = substr($info[0],0,32);
$posterlink = glob($posterdirectory."/".$md5."*.html");

$pattern="/(z0)([0-9]{2})/";

$pdfppl_l = preg_replace($pattern,'',basename($ppl_l[$sel_l],".png"));
$pdfppl_r = preg_replace($pattern,'',basename($ppl_r[$sel_r],".png"));

 echo "<div class='pluslinks'>";
if(!empty($posterlink)) {
 echo "<a href='".$posterlink[0]."' />";
 echo "see posters for this conversation";
 echo "</a><br/>";
}

 echo "<a href='".$posterdirectory."/SEEME' />";
 echo "see all posters";
 echo "</a><br/>";

 echo "<a href='".$voicedirectory."/ALL' />";
 echo "see all conversations";
 echo "</a><br/>";

 echo "(<a href='".$pdfppldirectory."/".$pdfppl_l.".pdf"."' />";
 echo "*";
 echo "</a>|";
 echo "<a href='".$pdfppldirectory."/".$pdfppl_r.".pdf"."' />";
 echo "*";
 echo "</a>)";
 
echo "</div>";
echo "</div>";

// -------------------------------------------- //

?>

<div class='controls' id='controls'>
	<a href='Q&A' class='read' id='read'></a>
	<input type='image' id='write' name='submit to the pool' src='i/free/png/interface/write.png' class='write'/>
</div>
</form>
</div>


<div class='bottom'>
	<div class='logo'>
		<a href='http://libregraphicsmeeting.org/2013/'><img src='o/press/rgb/LGM-Logo+15_Solo_120px.png' class='logo'/></a>
	</div>
</div>


</body>
</html>
