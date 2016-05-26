// M_2_5_02_TOOL.pde
// GUI.pde
// 
// Generative Gestaltung, ISBN: 978-3-87439-759-9
// First Edition, Hermann Schmidt, Mainz, 2009
// Hartmut Bohnacker, Benedikt Gross, Julia Laub, Claudius Lazzeroni
// Copyright 2009 Hartmut Bohnacker, Benedikt Gross, Julia Laub, Claudius Lazzeroni
//
// http://www.generative-gestaltung.de
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/**
 * explore different parameters of drawing lissajous figures 
 *
 * KEYS
 * m                   : menu open/close
 * s                   : save png
 * p                   : save pdf
 */

//////////////////////////////////////////////////////////////////////////////////////////////////////////
// M_2_5_02_TOOL.pde
// Drawing Lissajous figures
//
// Extremely attractive forms are created when the points on the Lissajous curve are not connected in the
// usual manner (i.e. one point only to the next point) but rather when each point is connected with all
// others. To avoid black clumpâ€“after all, many lines have to be drawnâ€“it is necessary to ensure that the 
// farter apart the points are, the more transparent the lines become, as Keith Peters demonstrates in 
// â€˜Random Lissajous Websâ€™ on his website.

// â€˜The Lissajous Toolâ€™ All the possible ways of working with two-dimensional Lissajous figures can be 
// combined in one program, which also contains additional parameters used to modify the figures. The 
// value randomOffset offsets the x- and y-coordinates of all points by a random value between 
// -randomOffset and +randomOffset. The parameters modFreq2X, modFreq2Y, and modFreq2Strength are a bit 
// more difficult to understand. These parameters modulate the freqyencies of the harmonic oscillations. 
// This means the frequencies freqX and freqY are no longer constant, but sometimes higher or lower.â€¨

//////////////////////////////////////////////////////////////////////////////////////////////////////////
// Generative Design Variation
//
// M_2_5_02_GDV_10
//
// Change as much as possible of the program but keep the essential things.
//
// February 25, 2015
// Â© 2015 Loftmatic, Henk Lamers.

// ------ Imports ------
import processing.pdf.*;
import java.util.Calendar;


// ------ Initial parameters and declarations ------
int PointCount = 1500;
PVector[] LissajousPoints = new PVector[0];

int Frequency_X = 1;
int Frequency_Y = 1;
float PhaseShift = 0;

int ModulationFrequency_X = 0;
int ModulationFrequency_Y = 0;

int ModulationFrequency_X2 = 0;
int ModulationFrequency_Y2 = 0;
float ModulationFrequency_2Strength = 0.0;

float RandomOffset = 0;

boolean InvertBackground = true;
float LineWeight = 0.6;
float LineAlpha = 100;

boolean ConnectAllPoints = true;
float ConnectionRadius = 125;
int StartingPoints = 0;
float MinimumHueValue = 100;
float MaximumHueValue = 200;
float SaturationValue = 100;
float BrightnessValue = 100;
boolean InvertHue = true;


// ------ ControlP5 ------

import controlP5.*;
ControlP5 controlP5;
boolean GUI = false;
boolean guiEvent = false;
Slider[] sliders;
Range[] ranges;
Toggle[] toggles;
Bang[] bangs;


// ------ image output ------

boolean SaveOneFrame = false;
boolean SavePDF = false;


void setup () {
  size (800, 800);
  smooth(8);
  background (255);

  setupGUI ();
  calculateLissajousPoints ();
}


void draw () {
  if (SavePDF) beginRecord (PDF, timestamp () + ".pdf");

  colorMode (RGB, 255, 255, 255, 100);
  strokeWeight (LineWeight);
  stroke (0, LineAlpha);
  strokeCap (ROUND);
  noFill ();

  color bgColor = color (255);
  if (InvertBackground) {
    bgColor = color (0);
  } 

  // Calculate points whenever something has changed via the gui and start drawing again.
  if (guiEvent || SaveOneFrame || SavePDF || StartingPoints == 0) {
    calculateLissajousPoints ();
    background (bgColor);
    StartingPoints = 0; 
    guiEvent = false;
  }


  if (!ConnectAllPoints) {
    background (bgColor);

    // Simple drawing method
    colorMode (HSB, 360, 100, 100, 100);

    for (int i = 0; i <= PointCount - 1; i++) {
      drawLine (LissajousPoints[i], LissajousPoints[i+1]);
      StartingPoints++;
    }
  } 
  else {
    // Drawing method where all points are connected with each other.
    // Alpha depends on distance of the points.  
    // Draw lines not all at once, just the next 100 milliseconds to keep performance.
    int drawEndTime = millis () + 100;
    if (SaveOneFrame || SavePDF) {
      drawEndTime = Integer.MAX_VALUE;
    }

    colorMode (HSB, 360, 100, 100, 100);
    while (StartingPoints < PointCount && millis () < drawEndTime) {
      for (int totalPoints = 0; totalPoints < StartingPoints; totalPoints++) {
        drawLine (LissajousPoints[StartingPoints], LissajousPoints[totalPoints]);
      }
      StartingPoints++;

      if (SavePDF) {
        println ("Saving to pdf â€“ step " + StartingPoints + "/" + PointCount);
      }
    }
  }

  // Image output.
  if (SavePDF) {
    SavePDF = false;
    println ("Saving to pdf â€“ finishing");
    endRecord ();
    println ("Saving to pdf â€“ done");
  }

  if (SaveOneFrame) {
    saveFrame (timestamp () + ".png");
  }

  // Draw gui.
  drawGUI ();

  // Image output
  if (SaveOneFrame) {
    if (controlP5.group ("menu").isOpen ()) {
      saveFrame (timestamp () + "_menu.png");
    }
    SaveOneFrame = false;
  }
}


void calculateLissajousPoints () {
  if (PointCount != LissajousPoints.length - 1) {
    LissajousPoints = new PVector[PointCount + 1];
  }

  randomSeed (0);
  //float t;
  float x;
  float y;
  float random_X;
  float random_Y;

  for (int i = 0; i <= PointCount; i++) {
    float angle = map (i, 0, PointCount, 0, TWO_PI);

    // An additional modulation of the oscillations. The oscillation values fmx and
    // fmy are calculated from the parameters msFreq2X, modFreq2Y and modFreq2Strenght.
    float oscillationValue_X = sin (angle * ModulationFrequency_X2) * ModulationFrequency_2Strength + 1;
    float oscillationValue_Y = sin (angle * ModulationFrequency_Y2) * ModulationFrequency_2Strength + 1;
    
    // These values are used to modulate the main frequencies freqX and freqY.
    x = sin (angle * Frequency_X * oscillationValue_X + radians (PhaseShift)) * cos (angle * ModulationFrequency_X);
    y = sin (angle * Frequency_Y * oscillationValue_Y) * cos (angle * ModulationFrequency_Y);

    random_X = random (-RandomOffset, RandomOffset);
    random_Y = random (-RandomOffset, RandomOffset);

    x = (x * (width / 2 - 30 - RandomOffset) + width / 2) + random_X;
    y = (y * (height / 2 - 30 - RandomOffset) + height / 2) + random_Y;

    LissajousPoints[i] = new PVector (x, y);
  }
}


void drawLine (PVector point_1, PVector point_2) {
  float distanceBetweenPoints;
  float transparencyValue;
  float hueValue;

  distanceBetweenPoints = PVector.dist (point_1, point_2);
  transparencyValue = pow (1 / (distanceBetweenPoints / ConnectionRadius + 1), 6);

  if (distanceBetweenPoints <= ConnectionRadius) {
    if (!InvertHue) {
      hueValue = map (transparencyValue, 0, 1, MinimumHueValue, MaximumHueValue) % 360;
    } 
    else {
      hueValue = map(1 - transparencyValue, 0, 1, MinimumHueValue, MaximumHueValue) % 360;
    }
    stroke (hueValue, SaturationValue, BrightnessValue, transparencyValue * LineAlpha + (StartingPoints %2 * 2));
    line (point_1.x, point_1.y, point_2.x, point_2.y);
  }
}


void keyPressed () {

  if (key == 'm' || key == 'M') {
    GUI = controlP5.group ("menu").isOpen ();
    GUI = !GUI;
    guiEvent = true;
  }
  if (GUI) controlP5.group ("menu").open ();
  else controlP5.group ("menu").close ();

  if (key == 's' || key == 'S') {
    SaveOneFrame = true;
  }
  if (key == 'p' || key == 'P') {
    SavePDF = true; 
    SaveOneFrame = true; 
    println ("Saving to pdf - starting");
  }
}

void mouseReleased () {
  guiEvent = false;
}

String timestamp () {
  return String.format ("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", Calendar.getInstance ());
}



// M_2_5_02_TOOL.pde
// GUI.pde
// 
// Generative Gestaltung, ISBN: 978-3-87439-759-9
// First Edition, Hermann Schmidt, Mainz, 2009
// Hartmut Bohnacker, Benedikt Gross, Julia Laub, Claudius Lazzeroni
// Copyright 2009 Hartmut Bohnacker, Benedikt Gross, Julia Laub, Claudius Lazzeroni
//
// http://www.generative-gestaltung.de
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

void setupGUI() {
  color activeColor = color(0, 130, 164);
  controlP5 = new ControlP5(this);
  //controlP5.setAutoDraw(false);
  controlP5.setColorActive(activeColor);
  controlP5.setColorBackground(color(170));
  controlP5.setColorForeground(color(50));
  controlP5.setColorLabel(color(50));
  controlP5.setColorValue(color(255));

  ControlGroup ctrl = controlP5.addGroup("menu", 15, 25, 35);
  ctrl.activateEvent(true);
  ctrl.setColorLabel(color(255));
  ctrl.close();


  sliders = new Slider[30];
  ranges = new Range[30];
  toggles = new Toggle[30];
  bangs = new Bang[30];

  int left = 0;
  int top = 5;
  int len = 100;

  int si = 0;
  int ri = 0;
  int ti = 0;
  int bi = 0;
  int posY = 0;

  sliders[si++] = controlP5.addSlider("PointCount", 1, 1500, left, top+posY, len, 15);
  posY += 30;

  sliders[si++] = controlP5.addSlider("Frequency_X", 1, 10, left, top+posY, len, 15);
  sliders[si++] = controlP5.addSlider("Frequency_Y", 1, 10, left, top+posY+20, len, 15);
  sliders[si++] = controlP5.addSlider("PhaseShift", 0, 360, left, top+posY+40, len, 15);
  posY += 70;

  sliders[si++] = controlP5.addSlider("ModulationFrequency_X", 1, 5, left, top+posY, len, 15);
  sliders[si++] = controlP5.addSlider("ModulationFrequency_Y", 1, 5, left, top+posY+20, len, 15);
  posY += 50;

  sliders[si++] = controlP5.addSlider("ModulationFrequency_X2", 0, 1, left, top+posY, len, 15);
  sliders[si++] = controlP5.addSlider("ModulationFrequency_Y2", 0, 1, left, top+posY+20, len, 15);
  sliders[si++] = controlP5.addSlider("ModulationFrequency_2Strength", 0, 1, left, top+posY+40, len, 15);
  posY += 70;

  sliders[si++] = controlP5.addSlider("RandomOffset", 0, 50, left, top+posY, len, 15);
  posY += 30;

  toggles[ti] = controlP5.addToggle("InvertBackground", InvertBackground, left+0, top+posY, 15, 15);
  toggles[ti++].setLabel("Invert Background");
  sliders[si++] = controlP5.addSlider("LineWeight", 1, 50, left, top+posY+20, len, 15);
  sliders[si++] = controlP5.addSlider("LineAlpha", 0, 100, left, top+posY+40, len, 15);
  posY += 70;

  ranges[ri++] = controlP5.addRange("hueRange", 0, 720, MinimumHueValue, MaximumHueValue, left, top+posY+0, len, 15);
  sliders[si++] = controlP5.addSlider("SaturationValue", 0, 100, left, top+posY+20, len, 15);
  sliders[si++] = controlP5.addSlider("BrightnessValue", 0, 100, left, top+posY+40, len, 15);
  toggles[ti] = controlP5.addToggle("InvertHue", InvertHue, left+0, top+posY+60, 15, 15);
  toggles[ti++].setLabel("Invert Hue Range");
  posY += 90;

  sliders[si++] = controlP5.addSlider("ConnectionRadius", 1, 500, left, top+posY+0, len, 15);
  //sliders[si++] = controlP5.addSlider("connectionRamp",1,20,left,top+posY+20,len,15);
  posY += 20;

  toggles[ti] = controlP5.addToggle("ConnectAllPoints", ConnectAllPoints, left+0, top+posY, 15, 15);
  toggles[ti++].setLabel("Connect All Points");


  for (int i = 0; i < si; i++) {
    sliders[i].setGroup(ctrl);
    sliders[i].captionLabel().toUpperCase(true);
    sliders[i].captionLabel().style().padding(4,3,3,3);
    sliders[i].captionLabel().style().marginTop = -4;
    sliders[i].captionLabel().style().marginLeft = 0;
    sliders[i].captionLabel().style().marginRight = -14;
    sliders[i].captionLabel().setColorBackground(0x99ffffff);
  }
  for (int i = 0; i < ri; i++) {
    ranges[i].setGroup(ctrl);
    ranges[i].captionLabel().toUpperCase(true);
    ranges[i].captionLabel().style().padding(4,3,3,3);
    ranges[i].captionLabel().style().marginTop = -4;
    ranges[i].captionLabel().setColorBackground(0x99ffffff);
  }
  for (int i = 0; i < ti; i++) {
    toggles[i].setGroup(ctrl);
    toggles[i].setColorLabel(color(50));
    toggles[i].captionLabel().style().padding(4, 3, 1, 3);
    toggles[i].captionLabel().style().marginTop = -19;
    toggles[i].captionLabel().style().marginLeft = 18;
    toggles[i].captionLabel().style().marginRight = 5;
    toggles[i].captionLabel().setColorBackground(0x99ffffff);
  }
  for (int i = 0; i < bi; i++) {
    bangs[i].setGroup(ctrl);
    bangs[i].setColorLabel(color(50));
    bangs[i].captionLabel().style().padding(4, 3, 1, 3);
    bangs[i].captionLabel().style().marginTop = -19;
    bangs[i].captionLabel().style().marginLeft = 48;
    bangs[i].captionLabel().style().marginRight = 5;
    bangs[i].captionLabel().setColorBackground(0x99ffffff);
  }
}



void drawGUI() {
  controlP5.show();
  controlP5.draw();
}



void controlEvent(ControlEvent theControlEvent) {
  guiEvent = true;

  GUI = controlP5.group("menu").isOpen();

  if (theControlEvent.isController()) {
    if (theControlEvent.controller().name().equals("hueRange")) {
      float[] f = theControlEvent.controller().arrayValue();
      MinimumHueValue = f[0];
      MaximumHueValue = f[1];
    }
  }
}

void invertBackground() {
  guiEvent = true;
  InvertBackground = !InvertBackground;
  updateColors(InvertBackground);
}



void updateColors(boolean stat) {
  ControllerGroup ctrl = controlP5.getGroup("menu");

  for (int i = 0; i < sliders.length; i++) {
    if (sliders[i] == null) break;
    if (stat == false) {
      sliders[i].setColorLabel(color(50));
      sliders[i].captionLabel().setColorBackground(0x99ffffff);
    } 
    else {
      sliders[i].setColorLabel(color(200));
      sliders[i].captionLabel().setColorBackground(0x99000000);
    }
  }
  for (int i = 0; i < ranges.length; i++) {
    if (ranges[i] == null) break;
    if (stat == false) {
      ranges[i].setColorLabel(color(50));
      ranges[i].captionLabel().setColorBackground(0x99ffffff);
    } 
    else {
      ranges[i].setColorLabel(color(200));
      ranges[i].captionLabel().setColorBackground(0x99000000);
    }
  }
  for (int i = 0; i < toggles.length; i++) {
    if (toggles[i] == null) break;
    if (stat == false) {
      toggles[i].setColorLabel(color(50));
      toggles[i].captionLabel().setColorBackground(0x99ffffff);
    } 
    else {
      toggles[i].setColorLabel(color(200));
      toggles[i].captionLabel().setColorBackground(0x99000000);
    }
  }
  for (int i = 0; i < bangs.length; i++) {
    if (bangs[i] == null) break;
    if (stat == false) {
      bangs[i].setColorLabel(color(50));
      bangs[i].captionLabel().setColorBackground(0x99ffffff);
    } 
    else {
      bangs[i].setColorLabel(color(200));
      bangs[i].captionLabel().setColorBackground(0x99000000);
    }
  }
}

