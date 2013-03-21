<?php header("Location: Q&A"); ?>
<html><head><title>WRITE!</title></head>
<body>
<?php

$md5id = md5($_POST["question"]);
$q = "o/free/voice/".$md5id."_Q.txt";
$a = "o/free/voice/".$md5id."_A-".time().rand(100,999).".txt";

if(strlen(str_replace(' ', '',$_POST["question"])) > 2) {

 // Open the text file
 $f = fopen($q, "w");
 // Write text
 fwrite($f, htmlentities(preg_replace('/(\r\n|\r|\n)/s',"\n",stripslashes($_POST["question"])),ENT_COMPAT,"UTF-8")); 
 // Close the text file
 fclose($f);


 if(strlen(str_replace(' ', '',$_POST["answer"])) > 2) {

  // Open the text file
  $f = fopen($a, "a");
  // Append text
  fwrite($f, htmlentities(preg_replace('/\s\s+/', ' ',stripslashes($_POST["answer"])),ENT_COMPAT,"UTF-8")); 
  fwrite($f, "\n");
  // Close the text file
  fclose($f);
 }
}
?>
	
</body>
</html>
