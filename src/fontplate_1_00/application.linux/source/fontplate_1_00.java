import processing.core.*; 
import processing.xml.*; 

import geomerative.*; 
import processing.pdf.*; 

import java.applet.*; 
import java.awt.*; 
import java.awt.image.*; 
import java.awt.event.*; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class fontplate_1_00 extends PApplet {




 RFont lfont;
RShape lshape;
RGroup lgroup;
RPoint[][] lpoints;
RMatrix mat;

PShape[] ImaginaryTools;

String ltext[] = loadStrings("i/free/voice/voice.txt");
String svglist[] = loadStrings("i/free/svg/load.list");

float x,y,xprev,yprev,randy,a;
float scalefactor,lineheight;
int indent;
int textHeight = 800;
int v;

int[] alreadytaken = new int[svglist.length];
// NUMBER OF SIMPLE SVGS
int sn = 20;

public void setup() {

  size(420,594,P3D);
  background(255);
  frameRate(1);
  //smooth();
  noLoop();

  RG.init(this);
  lfont = new RFont("i/free/fonts/SerreriaSobria.ttf", 500, LEFT);
  mat = new RMatrix();

  ImaginaryTools = new PShape[svglist.length];

  lshape = lfont.toShape(ltext[0]);

  // MULTILINE HACK FOR TEXT & GEOMERATIVE //
  for(int i = 1; i < ltext.length; i++) {
    lshape.addChild(lfont.toShape(ltext[i]));
    mat.translate(0,textHeight);
    lshape.children[PApplet.parseInt(lshape.countChildren() - 1)].transform(mat);
  }
  lpoints = lshape.getPointsInPaths();

  for(int i = 0; i < svglist.length; i++) {
    ImaginaryTools[i] = loadShape(svglist[i]);
    //ImaginaryTools[i].disableStyle();
  }
  shapeMode(CENTER);

  scalefactor = width/(lshape.getWidth() * 1.2f);

  for(int i = 0; i < alreadytaken.length; i++) {
      alreadytaken[i] = 0;
  }
}

public void draw() {

  //background(255);
  beginRecord(PDF, "lgm.pdf"); 

  pushMatrix();

  translate(15,height/4.8f);
  scale(scalefactor);
  rotate(radians(-15));

  fill(255,0,0);
  stroke(0);

  for (int i = 0; i < lpoints.length; i++) {
    
    RPoint[] llpoints = lpoints[i];
 
    indent = PApplet.parseInt(random(10,llpoints.length/15));
    for (int j = 0; j <= llpoints.length-indent; j++) {
      
      xprev = x;
      yprev = y; 
      x = PApplet.parseInt(llpoints[j].x);
      y = PApplet.parseInt(llpoints[j].y);

      randy = random(y-1400,
                     height / (scalefactor*1.9f));

      if ( randy > y ) { a = 0; }
      else { a = radians(180); }
 
      if ( ( j == 0 ) ) {
        if ( random(0,10) > 3 ) {
          
        v = PApplet.parseInt(random(sn,svglist.length));
        imagineInput(x,randy,a,v);
        beginShape();          
        vertex(x,randy);
        vertex(x,y);
        } else { 
        v = PApplet.parseInt(random(0,sn-1));
        a = radians(90 * PApplet.parseInt(random(1,5)));
        imagineInput(x,y,a,v); 
        beginShape();
        vertex(x,y);
        }
      }
      else if ( ( j == llpoints.length-indent ) ) {
        if ( random(0,10) > 9 ) {
        vertex(xprev,yprev);
        vertex(xprev,randy);
        endShape();
        v = PApplet.parseInt(random(sn,svglist.length));
        imagineInput(xprev,randy,a,v);
        } else { 
        vertex(xprev,yprev);
        endShape();
        v = PApplet.parseInt(random(0,sn-1));
        a = radians(90 * PApplet.parseInt(random(1,5)));
        imagineInput(xprev,yprev,a,v); 
        }
      }
      else {
        vertex(xprev,yprev);
        vertex(x,y);
      }       
    }
  }
  popMatrix();
  endRecord();
  exit();
}


public void imagineInput (float x, float y, float rotation, int vector) {
  
 //  http://forum.processing.org/topic/find-element-in-array
     if(alreadytaken[vector] > 0) {
       vector = PApplet.parseInt(random(0,sn-1));
       rotation = radians(90 * PApplet.parseInt(random(1,5)));
     }
     alreadytaken[vector]++;
  
     pushMatrix();
      translate(x,y);
      rotate(rotation);
      
      float groesse = random(5,7);
      scale(groesse);
        pushMatrix();
        translate(-160,-160);
        shape(ImaginaryTools[vector],0,0,400,400);
        popMatrix();
     popMatrix();

}


  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#DFDFDF", "fontplate_1_00" });
  }
}
