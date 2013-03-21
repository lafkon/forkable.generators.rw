#!/bin/bash

#.-------------------------------------------------------------------------.#
#. do.sh (is not make)                                                      #
#.                                                                          #
#. Copyright (C) 2013 LAFKON/Christoph Haag                                 #
#.                                                                          #
#. This file is part of the r+w id for the Libre Graphics Meeting 2013      #
#.                                                                          #
#. do.sh is free software: you can redistribute it and/or modify            #
#. it under the terms of the GNU General Public License as published by     #
#. the Free Software Foundation, either version 3 of the License, or        #
#. (at your option) any later version.                                      #
#.                                                                          #
#. do.sh is distributed in the hope that it will be useful,                 #
#. but WITHOUT ANY WARRANTY; without even the implied warranty of           #
#. MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     #
#. See the GNU General Public License for more details.                     #
#.                                                                          #
#.-------------------------------------------------------------------------.#

 TMPDIR=tmp ; rm $TMPDIR/*.*
 OUTPUTDIR=o/__

 SVGDIR=i/free/svg/made/
 SVGLIST=i/free/svg/load.list
 VOICES=i/free/voice

 URL="http://www.forkable.eu/"

# -------------------------------------------------------------------------- #
# PREPARE INPUT FOR PROCESSING --------------------------------------------- #
# -------------------------------------------------------------------------- #

# SELECT VOICE FROM THE PUBLIC
# -------------------------------------------------------------------------- #

  if [ -z $1 ] 
   then
        VOICE=`ls $VOICES/*.txt | shuf -n 1` 
  else
        VOICE=$1
  fi

  # THE MORE ANSWERS THE MORE HIGHER IS THE PROBABILITY
  VOICE=`ls $VOICES/*.txt | \
         grep ${VOICE%%_*} | \
         grep Q.txt | shuf -n 1`

  cat $VOICE | recode HTML..utf-8 | \
  fold -s -15 > $TMPDIR/voice.txt

  if [ `cat $VOICE | fold -s -20 | wc -l` -gt 6 ]; then
        cat $VOICE | sed ':a;N;$!ba;s/\n/ /g' | \
        sed -e "s/ \+ / /g" | fold -s -20 | \
        head -12 > $TMPDIR/voice.txt
  fi

  cat $TMPDIR/voice.txt > $VOICES/voice.txt
  cat $VOICES/voice.txt; echo;echo;

# FIND ANSWERS (and render scalable vector graphics)                         #
# -------------------------------------------------------------------------- #
  if [ -f $SVGLIST.tmp ]; then rm $SVGLIST.tmp ; fi

  MD5IDQUESTION=${VOICE%%_Q.txt}
  #####################################
  # EXCLUDE EMPTY AND DUPLICATE FILES #
  #####################################
  find $VOICES -type f -size -2c         >  $TMPDIR/exclude_this_voices.list
  fdupes $VOICES | grep $MD5IDQUESTION |\
  tail -n +3 | shuf                      >> $TMPDIR/exclude_this_voices.list
  echo XXXX                              >> $TMPDIR/exclude_this_voices.list
  XGREP=`cat $TMPDIR/exclude_this_voices.list | sed ':a;N;$!ba;s/\n/|/g'`
  echo $XGREP


  for ANSWER in `ls ${VOICE%%_Q.txt}_A-*.txt | egrep -v "$XGREP"`
   do
      SPEAKSRC=`ls i/free/svg/src/speak-*.svg | shuf -n 1`
      SPEAKMADE=$TMPDIR/speak-$RANDOM.svg

   ANSWERRECODE=$TMPDIR/answer.recoded
   cat $ANSWER | recode HTML..utf-8 | \
   sed "s/\&/\&amp;/g" | \
   sed "s/\&sect;/§/g" | \
   sed "s/\"/\&quot;/g"                            > $ANSWERRECODE

   # REPLACE PATTERN WITH PATTTERN + NEWLINE
   cat $SPEAKSRC | sed "s/QWERTZY/\nQWERTZY \n/"   > ${SPEAKMADE}.tmp

   tac ${SPEAKMADE}.tmp | \
   sed -n '/QWERTZY/,$p' | grep -v QWERTZY | tac   >  $SPEAKMADE
   cat $ANSWERRECODE                               >> $SPEAKMADE
   cat ${SPEAKMADE}.tmp | sed -n '/QWERTZY/,$p' | \
   grep -v QWERTZY                                 >> $SPEAKMADE
   sed -i ':a;N;$!ba;s/\n//g' $SPEAKMADE 

   NUMCHAR=`cat $ANSWER | recode HTML..utf-8 | wc -c`    
   FONTSIZE=`expr 450 / $NUMCHAR + 8`

   if [ $FONTSIZE -gt 28 ]; then FONTSIZE=14 ; fi

   sed -i "s/font-size:8px;/font-size:${FONTSIZE}px;/g" \
          $SPEAKMADE

# -------------------------------------------------------------------------- #
    cat $ANSWER | recode HTML..utf-8
    echo "numchar: "$NUMCHAR" - fontsize: "$FONTSIZE
# -------------------------------------------------------------------------- #

   inkscape --export-area-page \
            --export-text-to-path  \
            --export-pdf=${SPEAKMADE%%.*}.pdf \
            $SPEAKMADE

   SPEAKMADE4P5=${SPEAKMADE%%.*}4p5.svg
   pdf2svg ${SPEAKMADE%%.*}.pdf $SPEAKMADE4P5

   sed -i "s/rgb(100%,100%,100%);/#0000ff;/g" $SPEAKMADE4P5
   sed -i "s/rgb(0%,0%,0%);/#00ff00;/g"       $SPEAKMADE4P5
   sed -i 's/: /:/g'                          $SPEAKMADE4P5
   sed -i 's/; /;/g'                          $SPEAKMADE4P5

   ls $TMPDIR/*.svg | grep $SPEAKMADE4P5  >> $SVGLIST.tmp
  done
# -------------------------------------------------------------------------- #

# MAKE LISTS WITH SVG FILES
# -------------------------------------------------------------------------- #
  LETTERNUM=`echo $VOICE | wc -c`
  SIMPLENUM=`ls $TMPDIR/speak-*.svg | wc -l`
   VOICENUM=`cat $SVGLIST.tmp | wc -l`
  ls $SVGDIR/*.svg | \
  grep -v simple | \
  shuf -n `expr $LETTERNUM \/ 2 - $VOICENUM`  >> $SVGLIST.tmp
  ls $SVGDIR/*.svg | grep simple | shuf -n 20 >> $SVGLIST.tmp

  tac $SVGLIST.tmp > $SVGLIST

# -------------------------------------------------------------------------- #
# RUN PROCESSING SKETCH ---------------------------------------------------- #
# -------------------------------------------------------------------------- #

  # START VIRTUAL XSERVER FOR PROCESSING HEADLESS ######################
  # Xvfb :1 -screen 0 1152x900x8 -fbdir /tmp &

  # EXPORT DISPLAY FOR PROCESSING HEADLESS ##############################
  export DISPLAY=localhost:1.0 ##########################################

  SKETCHNAME=fontplate_1_00

  APPDIR=$(dirname "$0")
  LIBDIR=$APPDIR/src/$SKETCHNAME/application.linux/lib
  SKETCH=$LIBDIR/$SKETCHNAME.jar

  CORE=$LIBDIR/core.jar
  PDF=$LIBDIR/pdf.jar
  GMRTV=$LIBDIR/geomerative.jar
  BTK=$LIBDIR/batikfont.jar
  TXT=$LIBDIR/itext.jar

  LIBS=$SKETCH:$CORE:$PDF:$GMRTV:$BTK:$TXT

  java  -Djava.library.path="$APPDIR" \
        -cp "$LIBS" \
        $SKETCHNAME 

# -------------------------------------------------------------------------- #
  rm $VOICES/voice.txt $TMPDIR/speak-*.* $SVGLIST 


# -------------------------------------------------------------------------- #
# MODIFY PDF WRITTEN BY PROCESSING ----------------------------------------- #
# -------------------------------------------------------------------------- #
  PDF=lgm.pdf ; pdf2svg $PDF ${PDF%%.*}_tmp.svg

# SELECT AND WRITE SVG HEADER ---------------------------------------------- #
# -------------------------------------------------------------------------- #
  cat ${PDF%%.*}_tmp.svg | \
  sed '/path style/,$d'                           >  ${PDF%%.*}_l_tmp.svg

# PATHS WITH RED FILL (WRITTEN BY PROCESSING)  ----------------------------- #
# -------------------------------------------------------------------------- #
  for LINE in `cat ${PDF%%.*}_tmp.svg | grep "path style" | \
               grep "fill: *rgb(100%,0%,0%)" | sed 's/ /XXYYZZ/g' | shuf`
   do
     if [ $((RANDOM%10)) -ge 4 ]; then
          STORE=${PDF%%.*}_l_tmp.svg
     else
          STORE=$TMPDIR/text.lines
     fi
        FILL=`echo "rgb(0%,0%,0%)-rgb(100%,100%,100%)" | \
              sed 's/-/\\n/g' | shuf -n 1`

      echo $LINE | sed 's/XXYYZZ/ /g' | \
      sed "s/fill:[^;]*;/fill:$FILL;/"            >> $STORE
  done

# PATHS WITHOUT RED FILL AND BLUE/GREEN COLOR ------------------------------ #
# -------------------------------------------------------------------------- #
  cat ${PDF%%.*}_tmp.svg | grep "path style" | \
  grep -v "fill: *rgb(100%,0%,0%)" | \
  grep -v "rgb(0%,0%,100%)" | \
  grep -v "rgb(0%,100%,0%)" >> ${PDF%%.*}_l_tmp.svg

# PATHS WITH RED FILL (THE REST) ------------------------------------------- #
# -------------------------------------------------------------------------- #
  cat $TMPDIR/text.lines | \
  sed 's/fill:rgb(0%,0%,0%)/fill:rgb(100%,100%,100%)/g' \
                                                  >> ${PDF%%.*}_l_tmp.svg
# PATHS WITH BLUE COLOR ---------------------------------------------------- #
# -------------------------------------------------------------------------- #
  cat ${PDF%%.*}_tmp.svg | grep "path style" | \
  grep "rgb(0%,0%,100%)" | \
  sed 's/rgb(0%,0%,100%)/rgb(100%,100%,100%)/g'   >> ${PDF%%.*}_l_tmp.svg

# PATHS WITH GREEN COLOR --------------------------------------------------- #
# -------------------------------------------------------------------------- #
  cat ${PDF%%.*}_tmp.svg | grep "path style" | \
  grep "rgb(0%,100%,0%)" | \
  sed 's/rgb(0%,100%,0%)/rgb(0%,0%,0%)/g'         >> ${PDF%%.*}_l_tmp.svg

# SVG CLOSE  --------------------------------------------------------------- #
# -------------------------------------------------------------------------- #
  tac ${PDF%%.*}_tmp.svg | head -200  | \
  sed '/path style/,$d' | tac                     >> ${PDF%%.*}_l_tmp.svg
# -------------------------------------------------------------------------- #
  sed -i 's/stroke-width:[^;]*;/stroke-width:0\.3;/' ${PDF%%.*}_l_tmp.svg
  sed -i 's/rgb(0%,0%,100%)/rgb(100%,100%,100%)/g'   ${PDF%%.*}_l_tmp.svg
  # cp ${PDF%%.*}_l_tmp.svg $TMPDIR/simple_`date +%s`.svg
  inkscape --export-pdf=lgm_unified+layered.pdf      ${PDF%%.*}_l_tmp.svg
# -------------------------------------------------------------------------- #
  rm *_tmp.svg $PDF
# -------------------------------------------------------------------------- #


# -------------------------------------------------------------------------- #
# FINALIZING --------------------------------------------------------------- #
# -------------------------------------------------------------------------- #
  PDF=lgm_unified+layered.pdf
  VOICEID=`basename $VOICE | cut -d "_" -f 1 | cut -c 1-8`
  PDFNAME=LGM-2013_${VOICEID}_`date +%s`.pdf
# INFOSVG=i/free/svg/130219_SUBLINE-11.svg
  INFOPDF=i/free/svg/130319_SUBLINE-12_Print4Madrid.pdf
# -------------------------------------------------------------------------- #
# DATETIME=`date +%d.%m.%Y\ %H:%M`
# INFOBLOCK=`date +%s%N`

# cat $INFOSVG > $TMPDIR/$INFOBLOCK.svg
# sed 's/display:none/display:inline/g' $TMPDIR/$INFOBLOCK.svg \
#                                     > $TMPDIR/${INFOBLOCK}+OFFSET.svg
#
# inkscape --export-pdf=$TMPDIR/$INFOBLOCK.pdf \
#          --export-text-to-path \
#          $TMPDIR/$INFOBLOCK.svg
#
# inkscape --export-pdf=$TMPDIR/${INFOBLOCK}+OFFSET.pdf \
#          --export-text-to-path \
#          $TMPDIR/${INFOBLOCK}+OFFSET.svg

# -------------------------------------------------------------------------- #

  PDFMETA=$TMPDIR/pdfmeta.txt ; I=$TMPDIR/info.txt            
  SUBJECT=`echo $VOICE | sed ':a;N;$!ba;s/\n/ /g'`
  ##########################################################################.

  echo "The GNU/Linux commandline is a playground of ideas! "        >  $I
  echo "For further information visit "                              >> $I #.          
  echo "http://www.forkable.eu "      			             >> $I #.                                          
  echo "Possible Keywords: generative, design, linux"                >> $I #.

  ##########################################################################.
  echo "InfoKey: Title"                                        >  $PDFMETA #.
  echo "InfoValue: $SUBJECT"                                   >> $PDFMETA #.
  echo "InfoKey: Subject"                                      >> $PDFMETA #.
  echo "InfoValue: $SUBJECT"                                   >> $PDFMETA #.
  echo "InfoKey: Keywords"                                     >> $PDFMETA #.
  echo "InfoValue: "`cat $I`                                   >> $PDFMETA #.
  echo "InfoKey: Author"                                       >> $PDFMETA #.
  echo "InfoValue: LAFKON Publishing"                          >> $PDFMETA #.
  echo "InfoKey: Producer"                                     >> $PDFMETA #.
  echo "InfoValue: $URL/generators/r+w/do.sh"                  >> $PDFMETA #.
  ##########################################################################.

  #pdftk $TMPDIR/$INFOBLOCK.pdf  \
  #      background $PDF \
  #      output $TMPDIR/$PDFNAME

  #pdftk $TMPDIR/${INFOBLOCK}+OFFSET.pdf  \
  #      background $PDF \
  #      output $TMPDIR/${PDFNAME%%.*}+OFFSET.pdf

  #for KOMBI in $PDFNAME ${PDFNAME%%.*}+OFFSET.pdf
  # do
  #     pdftk $TMPDIR/$KOMBI update_info $PDFMETA \
  #           output $OUTPUTDIR/$KOMBI
  #     KOMBI=$OUTPUTDIR/$KOMBI
  #     gs -o ${KOMBI%%.*}.jpg -sDEVICE=jpeg -r144 ${KOMBI}
  #     convert -resize x498 \
  #             -border 1x1 \
  #             -bordercolor black \
  #             ${KOMBI%%.*}.jpg ${KOMBI%%.*}.gif
  #     rm ${KOMBI%%.*}.jpg
  #done


  pdftk $INFOPDF  \
        background $PDF \
        output $TMPDIR/${PDFNAME}

  KOMBI=$PDFNAME
  
  pdftk $TMPDIR/$KOMBI update_info $PDFMETA \
        output $OUTPUTDIR/$KOMBI
  KOMBI=$OUTPUTDIR/$KOMBI
  gs -o ${KOMBI%%.*}.jpg -sDEVICE=jpeg -r144 -dUseCIEColor ${KOMBI}
  convert -resize x498 \
          -border 1x1 \
          -bordercolor black \
          ${KOMBI%%.*}.jpg ${KOMBI%%.*}.gif
  rm ${KOMBI%%.*}.jpg




  rm $PDF $TMPDIR/$INFOBLOCK* $SVGLIST.tmp

# -------------------------------------------------------------------------- #

  echo "Wozu das alles?" > /dev/null ; 
  exit 0;

