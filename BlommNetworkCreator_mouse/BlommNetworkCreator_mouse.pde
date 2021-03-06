/** //<>//
 *
 * Network Chain Example using PixelFlow Librarie Thomas Diewald
 * Carles Gutierrez
 * http://carlesgutierrez.github.io
 */

EditablePixFlowNetwork myPixFlowNet;
DwPixelFlow context;

///////
//SemiTransParent Background Contend
Boolean bBackgroundAlpha = true;
//int alphaBk = 250;

///////
int viewport_w = 1280;//2560;//
int viewport_h = 720;//1440;//
int viewport_x = 230;
int viewport_y = 0;
Boolean bRecordScreen = false;

///////
color defaultColorNode = color(255, 255, 153);
color defaultColorLines = defaultColorNode;
float minNodeSize = 5;
float maxNodeSize = 10;
int minResetInitNodes = 10;
int maxResetInitNodes = 15;
Boolean bdrawForcesColor = false;

//////
//Gui
import controlP5.*;
ControlP5 cp5;
int slider_resetInitNodes = 20;
float slider_BloomMult = 0;
float slider_BloomRadius = 0;
int slider_LuminanceExponent = 10;
float slider_LuminanceThreshold = 0.3f;
int slider_AlphaBackground = 250;
Boolean bGuiHide = false;

///////
//-------------------------------------------
public void settings() {
  size(viewport_w, viewport_h, P2D); 
  smooth(8);
}

//-------------------------------------------
public void setup() {

  // main library context
  context = new DwPixelFlow(this);
  context.print();
  context.printGL();

  myPixFlowNet = new EditablePixFlowNetwork(this, width, height);
  myPixFlowNet.setup();

  //Gui
  setupGui();

  frameRate(60);
}


//-------------------------------------------
public void draw() {

  // draw particlesystem
  myPixFlowNet.draw();

  //Draw Fx
  drawFXeffects_pg_render();

  //Draw compositions 
  image(myPixFlowNet.pg_render, 0, 0);

  //Draw Interactions Outside FX effects
  myPixFlowNet.drawMouseInteraction();

  if (bRecordScreen) {
    //TODO add a timer to avoid to save all frames
    recordFrame();
  }
}

//-----------------------------------------------------------
public void drawFXeffects_pg_render() {
  DwFilter filter = DwFilter.get(context);

  filter.luminance_threshold.param.threshold = slider_LuminanceThreshold; //0.3f;
  filter.luminance_threshold.param.exponent = slider_LuminanceExponent; //10;
  filter.luminance_threshold.apply(myPixFlowNet.pg_render, myPixFlowNet.pg_luminance);

  filter.bloom.param.mult   = slider_BloomMult;//map(mouseX, 0, width, 0, 2);
  filter.bloom.param.radius = slider_BloomRadius;//map(mouseY, 0, height, 0, 1);

  filter.bloom.apply(myPixFlowNet.pg_luminance, myPixFlowNet.pg_bloom, myPixFlowNet.pg_render);
  blendMode(REPLACE);
  background(0);
}

//-------------------------------------------
public void recordFrame() {
  saveFrame("/data/savedFrames/Animation-######.png");
}

//--------------------------------------------
public void keyPressed() {
  if (key == 's') {
    bRecordScreen = true;
  }
}
//--------------------------------------------
public void keyReleased() {
  if (key == 's') {
    bRecordScreen = false;
  }
  if (key == 'h') {
    bGuiHide = ! bGuiHide;
    if (bGuiHide)cp5.hide();
    else cp5.show();
  }

  myPixFlowNet.keyReleased();
}

public void mousePressed() {
  if (cp5.isMouseOver() == false) {
    myPixFlowNet.mousePressed();
  }
}

public void mouseReleased() {
  if (cp5.isMouseOver() == false) {
    myPixFlowNet.mouseReleased();
  }
}

//----------------------------------------
void setupGui() {
  ////////////////////////////////
  //GUi
  cp5 = new ControlP5(this);
  int initPosX = 10;
  int initPosY = 10;
  int gapY = 20; 
  int gapYColorPicker = 100;
  int numItemGui = 0;

  cp5.addColorWheel("defaultColorLines", width-gapYColorPicker, initPosY + gapYColorPicker*0, gapYColorPicker).setRGB(color(128, 0, 255));
  cp5.addColorWheel("defaultColorNode", width-gapYColorPicker, initPosY + gapYColorPicker*1, gapYColorPicker).setRGB(color(128, 0, 255));

  // add a horizontal sliders, the value of this slider will be linked
  // to variable 'sliderValue' 
  cp5.addSlider("slider_resetInitNodes")
    .setPosition(initPosX, initPosY + gapY*numItemGui)
    .setRange(0, 200)
    ;
  numItemGui++;

  cp5.addSlider("slider_BloomMult")
    .setPosition(initPosX, initPosY + gapY*numItemGui)
    .setRange(0, 2)
    ;

  numItemGui++;

  cp5.addSlider("slider_BloomRadius")
    .setPosition(initPosX, initPosY + gapY*numItemGui)
    .setRange(0, 1)
    ;
  numItemGui++;

  cp5.addSlider("slider_AlphaBackground")
    .setPosition(initPosX, initPosY + gapY*numItemGui)
    .setRange(0, 255)
    ;
  numItemGui++;

  cp5.addSlider("slider_LuminanceThreshold")
    .setPosition(initPosX, initPosY + gapY*numItemGui)
    .setRange(0, 1)
    ;
  numItemGui++;

  cp5.addSlider("slider_LuminanceExponent")
    .setPosition(initPosX, initPosY + gapY*numItemGui)
    .setRange(0, 30)
    ;
  numItemGui++;
}