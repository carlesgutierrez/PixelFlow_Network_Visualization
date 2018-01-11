/** //<>//
 * 
 * PixelFlow | Copyright (C) 2016 Thomas Diewald - http://thomasdiewald.com
 * 
 * A Processing/Java library for high performance GPU-Computing (GLSL).
 * MIT License: https://opensource.org/licenses/MIT
 * 
 */

import java.util.ArrayList;

import com.thomasdiewald.pixelflow.java.DwPixelFlow;

import com.thomasdiewald.pixelflow.java.imageprocessing.filter.DwFilter;//Bloom required

import com.thomasdiewald.pixelflow.java.softbodydynamics.DwPhysics;
import com.thomasdiewald.pixelflow.java.softbodydynamics.constraint.DwSpringConstraint;
import com.thomasdiewald.pixelflow.java.softbodydynamics.constraint.DwSpringConstraint2D;
import com.thomasdiewald.pixelflow.java.softbodydynamics.particle.DwParticle2D;

import processing.core.*;

//
// Getting started with verlet particles/softbody simulation.
// 
// + Collision Detection
//

int viewport_w = 1280;
int viewport_h = 720;
int viewport_x = 230;
int viewport_y = 0;

// physics parameters
DwPhysics.Param param_physics = new DwPhysics.Param();

// physics simulation
DwPhysics<DwParticle2D> physics;

//DwParticle2D[] particles = new DwParticle2D[int(random(3, 10))];

//Modified values
ArrayList<NodeVA> particles = new ArrayList<NodeVA>();
DwParticle2D.Param param_particle;
//NodeVA[] particles = new NodeVA[int(random(3, 10))];

vaID findId_particleMouse = new vaID(0);
String numParticlesText;
DwSpringConstraint.Param param_spring = new DwSpringConstraint.Param();
Boolean bMoveMouseParticle = false;

///////////////////////////////////
//FX Effects
// render targets
PGraphics2D pg_render;
PGraphics2D pg_bloom;
// pixelflow context
DwPixelFlow context;
DwFilter filter;

public void settings() {
  size(viewport_w, viewport_h, P2D); 
  smooth(8);
}

public void setup() {

  println(numParticlesText);

  //set this windows somewhere in your screen
  //surface.setLocation(viewport_x, viewport_y);

  setupPhysics();

  setupFXeffects();

  frameRate(60);
}

//-------------------------------------------
public void setupPhysics() {

  // physics object
  physics = new DwPhysics<DwParticle2D>(param_physics);

  // global physics parameters
  param_physics.GRAVITY = new float[]{ 0, 0};//0.5f };
  param_physics.bounds  = new float[]{ 0, 0, width, height };
  param_physics.iterations_collisions = 4;
  param_physics.iterations_springs    = 4;

  // particle parameters
  DwParticle2D.Param param_particle = new DwParticle2D.Param();
  param_particle.DAMP_BOUNDS          = 0.50f;
  param_particle.DAMP_COLLISION       = 0.9990f;
  param_particle.DAMP_VELOCITY        = 0.9999991f; 

  // spring parameters
  //DwSpringConstraint.Param param_spring = new DwSpringConstraint.Param();
  param_spring.damp_dec = 0.899999f;
  param_spring.damp_inc = 0.000099999f;

  reset();
}

//-------------------------------------------
public void setupFXeffects() {


  // main library context
  context = new DwPixelFlow(this);
  context.print();
  context.printGL();

  filter = new DwFilter(context);

  // render targets
  pg_bloom = (PGraphics2D) createGraphics(width, height, P2D);
  pg_bloom.smooth(8);

  pg_render = (PGraphics2D) createGraphics(width, height, P2D);
  pg_render.smooth(8);

  pg_render.beginDraw();
  pg_render.background(0); //8);
  pg_render.endDraw();
}

public void draw() {

  updateMouseInteractions();    

  // update physics simulation
  physics.update(1);

  // render
  //background(255);

  pg_render.beginDraw();
  pg_render.noStroke();
  //pg_render.fill(255, 96); // no idea what do this if afeter background is 0
  //pg_render.rect(0, 0, width, height);

  pg_render.background(0);
  drawNetwork();
  pg_render.endDraw();

  drawFXeffects_pg_render();

  // stats, to the title window
  String txt_fps = String.format(getClass().getName()+ "   [particles %d]   [frame %d]   [fps %6.2f]", particles.size(), frameCount, frameRate);
  surface.setTitle(txt_fps);
}

//-----------------------------------------------------------
void drawFXeffects_pg_render() {
  DwFilter filter = DwFilter.get(context);
  //filter.bloom.param.mult   = 1.0f;
  //filter.bloom.param.radius = 1;
  filter.bloom.param.mult   = map(mouseX, 0, width, 0, 2);
  filter.bloom.param.radius = map(mouseY, 0, height, 0, 1);

  filter.luminance_threshold.param.threshold = 0.3f;
  filter.luminance_threshold.param.exponent = 10;
  //filter.luminance_threshold.apply(pg_src_A, pg_src_B);
  filter.bloom.apply(pg_render, pg_bloom, pg_render);
  blendMode(REPLACE);
  background(0);
  image(pg_render, 0, 0);
}
///////
//Draw NetWork
void drawNetwork() {

  //pushStyle();
  // render springs: access the springs and use the current force for the line-color
  pg_render.noFill();
  pg_render.strokeWeight(1);
  pg_render.beginShape(LINES);
  ArrayList<DwSpringConstraint> springs = physics.getSprings();
  for (DwSpringConstraint spring : springs) {
    if (spring.enabled) {
      DwParticle2D pa = particles.get(spring.idxPa());
      DwParticle2D pb = particles.get(spring.idxPb());
      float force = Math.abs(spring.force);
      float r = force*5000f;
      float g = r/10;
      float b = 0;
      pg_render.stroke(200-r, 200-g, 200-b);
      pg_render.vertex(pa.cx, pa.cy);
      pg_render.vertex(pb.cx, pb.cy);
    }
  }
  pg_render.endShape();


  // render particles
  pg_render.noStroke();
  pg_render.fill(255, 255, 255);
  for (int i = 0; i < particles.size(); i++) {
    DwParticle2D particle = particles.get(i);
    pg_render.ellipse(particle.cx, particle.cy, particle.rad*2, particle.rad*2);
  }

  //popStyle();
}


//////////////////////////////////////////////////////////////////////////////
// User Interaction
//////////////////////////////////////////////////////////////////////////////

DwParticle2D particle_mouse = null;

public DwParticle2D findNearestParticle(float mx, float my, float search_radius, vaID indexParticle) {
  float dd_min_sq = search_radius * search_radius;
  DwParticle2D particle = null;
  for (int i = 0; i < particles.size(); i++) {
    float dx = mx - particles.get(i).cx;
    float dy = my - particles.get(i).cy;
    float dd_sq =  dx*dx + dy*dy;
    if ( dd_sq < dd_min_sq) {
      dd_min_sq = dd_sq;
      particle = particles.get(i);
      //Memo index particle inside particles
      indexParticle.id = i;
    }
  }
  return particle;
}

//--------------------------------------------
public void updateMouseInteractions() {
  if (bMoveMouseParticle) {
    if (particle_mouse != null) {
      float[] mouse = {mouseX, mouseY};
      particle_mouse.moveTo(mouse, 0.2f);
    }
  }
}

//----------------------------------------------
public void reset() {
  particles.clear();
  physics.reset(); //Reset ALL. Better use setParticles with a new size?
  newRandomChainItems();
}
//--------------------------------------------
public void keyReleased() {
  if (key == 'r') reset();
  //if (key == 'p') DISPLAY_PARTICLES = !DISPLAY_PARTICLES;
}

public void mousePressed() {

  particle_mouse = findNearestParticle(mouseX, mouseY, 100, findId_particleMouse);
  if (particle_mouse != null) {
    particle_mouse.enable(false, false, false);
    
    if (mouseButton == LEFT  ) {

      bMoveMouseParticle = true;
    }
  }
}

public void mouseReleased() {
  if (particle_mouse != null) {
    particle_mouse.enable(true, true, true);
    
    if (mouseButton == LEFT  ) {
      bMoveMouseParticle = false;
    }
    //if(mouseButton == CENTER) particle_mouse.enable(true, false, false);
    if (mouseButton == RIGHT) {
      addNewItemChain(particle_mouse, mouseX, mouseY, findId_particleMouse);
    }


    particle_mouse = null;
  }
}

//------------------------------------------------
public void newRandomChainItems() {
  int numRandomParticles = int(random(2, 10));
  // create particles + chain them together
  for (int i = 0; i < numRandomParticles; i++) {
    float radius = random(10, 45);
    float px = width/2;
    float py = 100 + i * radius * 3;
    //particles[i] = new DwParticle2D(i, px, py, radius, param_particle);
    NodeVA auxNodeVA = new NodeVA(i, px, py, radius, param_particle, 0, 1);
    particles.add(auxNodeVA);

    if (i > 0) DwSpringConstraint2D.addSpring(physics, particles.get(i-1), particles.get(i), param_spring);
  }

  DwParticle2D[] particles_Array = particles.toArray(new DwParticle2D[particles.size()]);
  physics.setParticles(particles_Array, particles.size());
}

//----------------------------------------------
public void addNewItemChain(DwParticle2D _prevItem, int _px, int _py, vaID _findId) {
  // particle parameters
  param_particle = new DwParticle2D.Param();
  param_particle.DAMP_BOUNDS          = random(0.80f, 0.9999991f);
  param_particle.DAMP_COLLISION       = random(0.99f, 0.9999991f);
  param_particle.DAMP_VELOCITY        = random(0.51f, 0.9999991f); 
  println(param_particle.DAMP_BOUNDS, param_particle.DAMP_COLLISION, param_particle.DAMP_VELOCITY);

  if (particle_mouse != null) {
    //Add one circle to this particle
    int id_LastNodeToAdd = _findId.id;//particles.size()-1;
    float radius = random(30, 40);
    float px = _px+random(-10, 10);
    float py = _py+random(-10, 10);//100 + int(particles[0].getShape().getVertexY(0));
    NodeVA auxParticle = new NodeVA(particles.size(), px, py, radius, param_particle, 0, 0); //TODO modify 0,0 to real values... 
    particles.add(auxParticle);

    //Check Location Clicked
    //_prevItem.get

    //Add to World
    DwSpringConstraint2D.addSpring(physics, particles.get(id_LastNodeToAdd), particles.get(particles.size()-1), param_spring);
  }

  DwParticle2D[] particles_Array = particles.toArray(new DwParticle2D[particles.size()]);
  physics.setParticles(particles_Array, particles.size());
}

class NodeVA extends DwParticle2D {
  int id0, id1;

  NodeVA(int _id, float _px, float _py, float _radius, DwParticle2D.Param _param_particle, int _id0, int _id1) {

    super(_id);
    setPosition(_px, _py);
    setRadius(_radius);
    setParamByRef(_param_particle);

    id0 = _id0;
    id1 = _id1;
  }

  /*
  NodeVA (int _id0, int _id1) {  
   id0 = _id0; 
   id1 = _id1;
   
   //how to add DwParticle2D params... 
   }*/

  void update() {
  }

  void display() {
  }
}

class vaID {
  int id = -1;

  vaID(int _id) {
    id = _id;
  }
}