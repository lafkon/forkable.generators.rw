#!/bin/bash

# MADE WITH:
# GNU coreutils 8.5
# Inkscape 0.47 r22583
# GNU sed version 4.2.1
#
#
#.-------------------------------------------------------------------------.#
#. generate_inputs.sh                                                       #
#.                                                                          #
#. Copyright (C) 2012 LAFKON/Christoph Haag                                 #
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

 TMPDIR=.
 SVGDIR=.
 PDFDIR=$TMPDIR

 ENDDIR=.

 ILLUDIR=../../../../o/free/pdf/people


 for SVG in `ls $SVGDIR/*.svg`
  do

   TMPSVG=$TMPDIR/tmp.svg

   NAME=`basename $SVG | cut -d "." -f 1`
   TYPE=`echo $SVG | cut -d "_" -f 2 | cut -d "-" -f 1`

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

     TMPPDF=$TMPDIR/tmp_${LINENUMBER}-${ELEMENT}.pdf

     inkscape -z --export-pdf=$TMPPDF \
              --export-id=$ELEMENT \
              --export-id-only \
              --export-area-page \
              $TMPSVG
 done

 # --------------------------------------------------- #
 # THIS IS BRUTEFORCE (WO ROHE KRÄFTE SINNLOS WALTEN)
 # --------------------------------------------------- #

 COUNT=1

 while [ $COUNT -le 200 ]
  do

 for ELEMENTTYPE in `ls $TMPDIR/tmp_*.pdf | \
                     cut -d "-" -f 3 | \
                     sort -u`
  do
      LAYERID=`ls $TMPDIR/tmp_*.pdf | \
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

       EXPORTFILENAME=${LAYERID}

  if [ `ls $PDFDIR | grep $EXPORTFILENAME | wc -l` -lt 1 ]
   then

      cp $TMPDIR/`cat $COMBINATION | head -1` \
         $TMPDIR/background.pdf

      cp $TMPDIR/`cat $COMBINATION | head -1` \
         $TMPDIR/background_2.pdf


     for LAYER in `sed -n '2,$p' $COMBINATION`
      do
         pdftk $TMPDIR/$LAYER \
               background $TMPDIR/background.pdf  \
               output $TMPDIR/out.pdf
         mv $TMPDIR/out.pdf $TMPDIR/background.pdf
     
      # MAKE PDF WITHOUT CONNECTOR #

       if [ `echo $LAYER | grep z0- | wc -l ` -lt 1 ];
        then
         pdftk $TMPDIR/$LAYER \
               background $TMPDIR/background_2.pdf  \
               output $TMPDIR/out_2.pdf
         mv $TMPDIR/out_2.pdf $TMPDIR/background_2.pdf
       fi

    done

       LAYERID=`echo $LAYERID | sed 's/-//g'`
       SHORTNAME=`echo ${NAME} | cut -d "_" -f 2`
       SHORTLAID=`echo $LAYERID | sed 's/z0..//g'`
       EXPORTFILENAME=$SHORTNAME-${SHORTLAID}_${TYPE}.png
 
       pdfcrop --margins '10 10 10 20' $TMPDIR/background_2.pdf \
                                       ${EXPORTFILENAME%%.*}.pdf

       mv ${EXPORTFILENAME%%.*}.pdf $ILLUDIR

       EXPORTFILENAME=$SHORTNAME-${LAYERID}_${TYPE}.png

       pdf2svg $TMPDIR/background.pdf $TMPDIR/tmp.svg
       sed -i 's/stroke-width:0[^;]*;/stroke-width:1\.3;/' $TMPDIR/tmp.svg
       inkscape --export-png=${EXPORTFILENAME%%.*}_tmp.png \
                --export-height=2000 \
                $TMPDIR/tmp.svg
       convert -resize x300 ${EXPORTFILENAME%%.*}_tmp.png $EXPORTFILENAME
       rm $TMPDIR/background*.pdf ${EXPORTFILENAME%%.*}_tmp.png

  else
       echo $EXPORTFILENAME exists
  fi

  done

  rm *.list tmp_*.* tmp.svg

done


exit 0;