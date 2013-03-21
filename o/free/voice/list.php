<?php
 $url = "http://www.forkable.eu/generators/r+w/o/free/voice";
 $voicedirectory  = ".";
 $txt = array_reverse(glob($voicedirectory."/*.txt"));

 foreach($txt as $entry) {

 echo $url."/".basename($entry)."\n";

 }

?>
