import geomerative.*;
import processing.pdf.*;

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

void setup() {

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
    lshape.children[int(lshape.countChildren() - 1)].transform(mat);
  }
  lpoints = lshape.getPointsInPaths();

  for(int i = 0; i < svglist.length; i++) {
    ImaginaryTools[i] = loadShape(svglist[i]);
    //ImaginaryTools[i].disableStyle();
  }
  shapeMode(CENTER);

  scalefactor = width/(lshape.getWidth() * 1.2);

  for(int i = 0; i < alreadytaken.length; i++) {
      alreadytaken[i] = 0;
  }
}

void draw() {

  //background(255);
  beginRecord(PDF, "lgm.pdf"); 

  pushMatrix();

  translate(15,height/4.8);
  scale(scalefactor);
  rotate(radians(-15));

  fill(255,0,0);
  stroke(0);

  for (int i = 0; i < lpoints.length; i++) {
    
    RPoint[] llpoints = lpoints[i];
 
    indent = int(random(10,llpoints.length/15));
    for (int j = 0; j <= llpoints.length-indent; j++) {
      
      xprev = x;
      yprev = y; 
      x = int(llpoints[j].x);
      y = int(llpoints[j].y);

      randy = random(y-1400,
                     height / (scalefactor*1.9));

      if ( randy > y ) { a = 0; }
      else { a = radians(180); }
 
      if ( ( j == 0 ) ) {
        if ( random(0,10) > 3 ) {
          
        v = int(random(sn,svglist.length));
        imagineInput(x,randy,a,v);
        beginShape();          
        vertex(x,randy);
        vertex(x,y);
        } else { 
        v = int(random(0,sn-1));
        a = radians(90 * int(random(1,5)));
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
        v = int(random(sn,svglist.length));
        imagineInput(xprev,randy,a,v);
        } else { 
        vertex(xprev,yprev);
        endShape();
        v = int(random(0,sn-1));
        a = radians(90 * int(random(1,5)));
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


void imagineInput (float x, float y, float rotation, int vector) {
  
 //  http://forum.processing.org/topic/find-element-in-array
     if(alreadytaken[vector] > 0) {
       vector = int(random(0,sn-1));
       rotation = radians(90 * int(random(1,5)));
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

