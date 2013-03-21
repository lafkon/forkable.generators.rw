#!/bin/bash

#.-------------------------------------------------------------------------.#
#. generate_inputs.sh                                                       #
#.                                                                          #
#. Copyright (C) 2013 LAFKON/Christoph Haag                                 #
#.                                                                          #
#. This file is part of the r+w id for the Libre Graphics Meeting 2013      #
#.                                                                          #
#. this is free software: you can redistribute it and/or modify             #
#. it under the terms of the GNU General Public License as published by     #
#. the Free Software Foundation, either version 3 of the License, or        #
#. (at your option) any later version.                                      #
#.                                                                          #
#. this script is distributed in the hope that it will be useful,           #
#. but WITHOUT ANY WARRANTY; without even the implied warranty of           #
#. MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     #
#. See the GNU General Public License for more details.                     #
#.                                                                          #
#.-------------------------------------------------------------------------.#

 TMPDIR=tmp
 SVGDIR=i/free/svg/src
 PDFDIR=$TMPDIR

 ENDDIR=i/free/svg/made

 for SVG in `ls $SVGDIR/*.svg | grep -v speak`
  do

   rm $TMPDIR/*.*
   TMPSVG=$TMPDIR/`basename $SVG`

 # --------------------------------------------------- #
 # COPY SVG TO TMP FILE,                               #
 # MAKE ALL LAYERS VISIBLE,                            #
 # CONVERT EVERY space TO NEWLINE (-> EASIFY GREP)     #
 # --------------------------------------------------- #

   cat $SVG | \
   sed 's/display:none/display:inline/g' | \
   sed 's/ /\n/g' > $TMPSVG

 # --------------------------------------------------- #
 # EXPORT ALL ELEMENTS WHICH MATCH THE                 #
 # ID PATTERN (id="ELEMENT-)                           #
 # --------------------------------------------------- #

 for ELEMENT in `grep "id=\"ELEMENT-" $TMPSVG | \
                     cut -d "\"" -f 2`
  do
     LINENUMBER=`grep -n $ELEMENT $TMPSVG | \
                 cut -d ":" -f 1 | tail -1`

     TMPPDF=$TMPDIR/${LINENUMBER}-${ELEMENT}.pdf

     inkscape -z --export-pdf=$TMPPDF \
              --export-area-page \
              --export-id=$ELEMENT \
              --export-area-page \
              $TMPSVG
 done

 # --------------------------------------------------- #
 # THIS IS BRUTEFORCE (WO ROHE KRÄFTE SINNLOS WALTEN)
 # --------------------------------------------------- #

COUNT=1
while [ $COUNT -le 250 ]
 do

 for ELEMENTTYPE in `ls $TMPDIR/*.pdf | \
                     cut -d "-" -f 3 | \
                     sort -u`
  do
      LAYERID=`ls $TMPDIR/*.pdf | \
               grep $ELEMENTTYPE | \
               shuf -n 1 | \
               cut -d "-" -f 3,4 | cut -d "." -f 1`

      ls $TMPDIR | grep $LAYERID >> $TMPDIR/$COUNT.list

 done
      cat $TMPDIR/$COUNT.list | sort > $TMPDIR/$COUNT.list.tmp
      mv $TMPDIR/$COUNT.list.tmp $TMPDIR/$COUNT.list

      if [ `fdupes $TMPDIR | wc -l` -gt 1 ]
       then
            echo $COUNT.list " = COMBINATIONS EXISTS"
            rm $TMPDIR/$COUNT.list
      fi
      COUNT=`expr $COUNT + 1`
done


 # --------------------------------------------------- #
 #
 # --------------------------------------------------- #

  INPUTDIMENSIONS=`basename $SVG | cut -d "." -f 1`

  for COMBINATION in `ls $TMPDIR/*.list`
   do
       LAYERID=`head -1 $COMBINATION | \
                cut -d "." -f 1 | \
                cut -d "-" -f 3,4`

     for LAYER in `sed -n '2,$p' $COMBINATION`
      do
         LAYERID=$LAYERID-`echo $LAYER | \
                 cut -d "." -f 1 | cut -d "-" -f 3,4`
    done
       EXPORTFILENAME=${LAYERID}_${INPUTDIMENSIONS}

  if [ `ls $PDFDIR | grep $EXPORTFILENAME | wc -l` -lt 1 ]
   then

      cp $TMPDIR/`cat $COMBINATION | head -1` \
         $TMPDIR/background.pdf

     for LAYER in `sed -n '2,$p' $COMBINATION`
      do
         pdftk $TMPDIR/$LAYER \
               background $TMPDIR/background.pdf  \
               output $TMPDIR/out.pdf
         mv $TMPDIR/out.pdf $TMPDIR/background.pdf
    done

       LAYERID=`echo $LAYERID | sed 's/-//g'`
       EXPORTFILENAME=${INPUTDIMENSIONS}_${LAYERID}
       mv $TMPDIR/background.pdf $PDFDIR/$EXPORTFILENAME.pdf
       pdf2svg $PDFDIR/$EXPORTFILENAME.pdf \ 
               $ENDDIR/$EXPORTFILENAME.svg

       sed -i "s/rgb(100%,100%,100%);/#ffffff;/" \
           $ENDDIR/$EXPORTFILENAME.svg
       sed -i "s/rgb(0%,0%,0%);/#000000;/" \
           $ENDDIR/$EXPORTFILENAME.svg

  else
       echo $EXPORTFILENAME exists
  fi

  done

done


exit 0;