/** //<>//
 *
 * Network Chain Example using PixelFlow Librarie Thomas Diewald
 * Carles Gutierrez
 * http://carlesgutierrez.github.io
 */

EditablePixFlowNetwork myPixFlowNet;

DwPixelFlow context;

///////
Boolean bBackgroundAlpha = true;
int alphaBk = 250;

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

  //set this windows somewhere in your screen
  //surface.setLocation(viewport_x, viewport_y);

  myPixFlowNet = new EditablePixFlowNetwork(this, width, height);
  myPixFlowNet.setup();

  frameRate(60);
}


//-------------------------------------------
public void draw() {

  //background(8);
    //if (bBackgroundAlpha) {
    //  fill(0, 0, 0, alphaBk);
    //  rectMode(CORNER);
    //  rect(0, 0, width, height);
    //} else background(0, 0, 0);

  // draw particlesystem
  myPixFlowNet.draw();

  //Draw Fx
  drawFXeffects_pg_render();

  //Draw compositions 
  image(myPixFlowNet.pg_render, 0, 0);
  
  //Draw Interactions Outside FX effects
  myPixFlowNet.drawMouseInteraction();

  if (bRecordScreen) {
    //thread("recordFrame");
    recordFrame();
  }
}

//-----------------------------------------------------------
public void drawFXeffects_pg_render() {
  DwFilter filter = DwFilter.get(context);
  //filter.bloom.param.mult   = 1.0f;
  //filter.bloom.param.radius = 1;
  filter.bloom.param.mult   = map(mouseX, 0, width, 0, 2);
  filter.bloom.param.radius = map(mouseY, 0, height, 0, 1);

  filter.luminance_threshold.param.threshold = 0.3f;
  filter.luminance_threshold.param.exponent = 10;
  //filter.luminance_threshold.apply(pg_src_A, pg_src_B);
  filter.bloom.apply(myPixFlowNet.pg_render, myPixFlowNet.pg_bloom, myPixFlowNet.pg_render);
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

  if (keyCode == LEFT)alphaBk += 10; 
  if (alphaBk>255) alphaBk = 255;
  if (keyCode == RIGHT)alphaBk -= 10; 
  if (alphaBk<1) alphaBk = 1;
}
//--------------------------------------------
public void keyReleased() {
  if (key == 's') {
    bRecordScreen = false;
  }

  myPixFlowNet.keyReleased();
}

public void mousePressed() {
  myPixFlowNet.mousePressed();
}

public void mouseReleased() {
  myPixFlowNet.mouseReleased();
}