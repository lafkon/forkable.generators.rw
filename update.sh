#!/bin/bash

  TMPDIR=tmp
  PDFDIR=o/__
  VOICEDIR=o/free/voice

  REMOTELIST=http://libregraphicsmeeting.org/2013/r+w/list.php


if [ `ps aux | grep Xvfb | grep -v grep | wc -l` -ge 1 ]; then

# ------------------------------------------------------------------------------------------ #

  VNUMLOCALE=`ls $VOICEDIR/*.txt | wc -l`

  ls -t $VOICEDIR/*.txt | \
  rev | cut -d "/" -f 1 | rev | \
  shuf -n 40                                         >  q+a.list

  XGREP=`ls $VOICEDIR/*.txt | \
         rev | cut -d "/" -f 1 | rev | \
         sed ':a;N;$!ba;s/\n/|/g'`

# ------------------------------------------------------------------------------------------ #
# UPDATE QUESTIONS & ANSWERS
# ------------------------------------------------------------------------------------------ #

  REMOTEDIR=http://www.forkable.eu/generators/r+w/i/free/voice/
  LOCALEDIR=$VOICEDIR

  cd $LOCALEDIR
  #wget -r -np -nH --no-directories -N -S -R index.html -A .txt $REMOTEDIR

  LIST=voices.list
  wget -O $LIST  $REMOTELIST

  wget -r -np -nH --no-directories -N -S -i $LIST
  #rm robots.txt
  #rm $LIST
  
  cd -

  for FILE in `ls $LOCALEDIR/*.txt`
   do
      if [ `grep \`basename $FILE\` $LOCALEDIR/$LIST | wc -l` -ge 1 ]
      then
            sleep 0
      else
            cat $FILE
            rm  $FILE
      fi
  done

  rm $LOCALEDIR/$LIST

# ------------------------------------------------------------------------------------------ #

  VNUMREMOTE=`ls $VOICEDIR/*.txt | wc -l`

  ls -t o/free/voice/*.txt |
  rev | cut -d "/" -f 1 | rev | \
  egrep -v "$XGREP"                                 >> q+a.list

# ------------------------------------------------------------------------------------------ #

 NUM2GENERATE=`expr $VNUMREMOTE - $VNUMLOCALE + 1`

 if [ $VNUMREMOTE -gt $VNUMLOCALE ]
  then
# ------------------------------------------------------------------------------------------ #

# ------------------------------------------------------------------------------------------ #
# CREATE NEW POSTERS                                                                         # 
# ------------------------------------------------------------------------------------------ #

  CNT=1 ; while [ $CNT -le $NUM2GENERATE ]; do

       SELECTID=`tac q+a.list | \
                 rev | cut -d "_" -f 2 | cut -d "/" -f 1 | rev | \
                 awk ' !x[$0]++' | head -n $CNT | tail -1`
        SELECTQ=`ls -t i/free/voice/*_Q.txt | grep $SELECTID | head -n 1`

       ./do.sh $SELECTQ
       CNT=`expr $CNT + 1`

    done

# ------------------------------------------------------------------------------------------ #
# MAKE HTML FILES 
# ------------------------------------------------------------------------------------------ #

  TIMEREFERENCE=older.tmp
  touch -t 201303190000 $TIMEREFERENCE

  ALLHTML=$PDFDIR/HYPERSEEME.htm

  echo "<html>"                                                         >  $ALLHTML
  echo "<head>"                                                         >> $ALLHTML
  echo "<link rel=\"stylesheet\""                                       >> $ALLHTML
  echo "href=\"show.css\" type=\"text/css\" />"                         >> $ALLHTML
  echo "<title>generative poster lor LGM 2013</title>"                  >> $ALLHTML
  echo "</head>"                                                        >> $ALLHTML
  echo "<body>"                                                         >> $ALLHTML


 for QTYPE in `find $PDFDIR -newer $TIMEREFERENCE -name "*.pdf" \
               -exec ls -tr {} + | tac | \
               cut -d "_" -f 4 | \
               uniq`
  do
      HTMLNAME=`ls -t $VOICEDIR | \
                grep $QTYPE | \
                cut -d "_" -f 1 | \
                sort -u`

      if [ -z $HTMLNAME ]; then

        sleep 0.1

      else

        HTMLFILE=${PDFDIR}/${HTMLNAME}.html
        #echo ; echo $HTMLFILE 
        
        QFILE=`ls $VOICEDIR/*Q.txt | grep $QTYPE `

        if [ `echo $QFILE | wc -c` -gt 2 ];then
        TITLE=`cat $QFILE`
        #echo $TITLE
        else
        TITLE=0  
        fi

        echo "<html>"                                                    >  $HTMLFILE
        echo "<head>"                                                    >> $HTMLFILE
        echo "<link rel=\"stylesheet\""                                  >> $HTMLFILE
        echo "href=\"show.css\" type=\"text/css\" />"                    >> $HTMLFILE
        echo "<title>"$TITLE"</title>"                                   >> $HTMLFILE
        echo "</head>"                                                   >> $HTMLFILE
        echo "<body>"                                                    >> $HTMLFILE

        for GIF in `find $PDFDIR -newer $TIMEREFERENCE -name "*.gif" \
                    -exec ls -tr {} + | tac | \
                    grep $QTYPE | grep -v 300px`
         do
            if [ -f ${GIF%%.*}+OFFSET.gif ]; 
            then GIF=${GIF%%.*}+OFFSET.gif ; fi

            GIF=`basename $GIF`
       
            echo "<a href=\""${GIF%%.*}.pdf"\">"                         >> $HTMLFILE
            echo "<img src=\""$GIF"\" />"                                >> $HTMLFILE
            echo "</a>"                                                  >> $HTMLFILE
       

            #AOPEN="<a href=\""${GIF%%.*}.pdf"\">"
            AOPEN="<a href=\""${HTMLNAME}.html"\">"
            ACLOSE="</a>"
            echo "$AOPEN<img src=\""$GIF"\" />$ACLOSE"                   >> $ALLHTML.tmp

        done

        echo "</body>"                                                   >> $HTMLFILE
        echo "</html>"                                                   >> $HTMLFILE
      fi
 done
        #cat $ALLHTML.tmp | \
        #uniq --skip-chars=18 --check-chars=7 | head -n 50               >> $ALLHTML
        #cat $ALLHTML.tmp | shuf -n 100                                   >> $ALLHTML

        cat $ALLHTML.tmp | \
        uniq --skip-chars=9 --check-chars=30                             >> $ALLHTML
        echo "</body>"                                                   >> $ALLHTML
        echo "</html>"                                                   >> $ALLHTML

        rm $ALLHTML.tmp

# ------------------------------------------------------------------------------------------ #

# ------------------------------------------------------------------------------------------ #
# UPLOAD NEW FILES
# ------------------------------------------------------------------------------------------ #

# GENERATE FTP COMMANDS -------------------------------------------------------------------- #

  ACCESS=`cat ~/.forkable/ftp.input`

  echo $ACCESS                                                >  ftp.tmp
  for HTML in `ls ${PDFDIR}/*.html`
   do
      echo "put $HTML "`basename $HTML`                       >> ftp.tmp
  done

  NUM2UPLOAD=`expr $NUM2GENERATE \* 2`

  for PDF in `ls -t ${PDFDIR}/*.pdf | head -n $NUM2UPLOAD`
   do
      echo "put $PDF "`basename $PDF`                         >> ftp.tmp
  done

  for GIF in `ls -t ${PDFDIR}/*.gif | head -n $NUM2UPLOAD`
   do
      echo "put $GIF "`basename $GIF`                         >> ftp.tmp
  done

  echo "put $ALLHTML "`basename $ALLHTML`                     >> ftp.tmp
  echo "bye"                                                  >> ftp.tmp

  mv ftp.tmp ftp.input

# UPLOAD VIA FTP --------------------------------------------------------------------------- #

  ftp -n forkable.eu < ftp.input
  rm ftp.input


# UPLOAD VIA FTP --------------------------------------------------------------------------- #

#  ACCESS=`cat ~/.forkable/wput.input` 
#  wput --timestamping --basename=$PDFDIR/ $PDFDIR/*.* ftp://$ACCESS@forkable.eu
#  rm q+a.list

# ------------------------------------------------------------------------------------------ #

  echo 
  echo "VOICES ONLINE = "$VNUMREMOTE
  echo "VOICES LOKAL  = "$VNUMLOCALE
  echo "NUM2GENERATE  = "$NUM2GENERATE

  rm $TIMEREFERENCE

 else

  echo
  echo "VOICES ONLINE = "$VNUMREMOTE
  echo "VOICES LOKAL  = "$VNUMLOCALE
  echo "-> NOTHING NEW"

 fi

  rm q+a.list

fi


exit 0;