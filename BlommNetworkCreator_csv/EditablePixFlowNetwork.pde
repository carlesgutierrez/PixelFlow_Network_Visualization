//<>// //<>// //<>// //<>//
/**
 * 
 * PixelFlow | Copyright (C) 2016 Thomas Diewald - http://thomasdiewald.com
 * 
 * A Processing/Java library for high performance GPU-Computing (GLSL).
 * MIT License: https://opensource.org/licenses/MIT
 * 
 */

import java.util.ArrayList;
import processing.core.PApplet;

import com.thomasdiewald.pixelflow.java.DwPixelFlow;//Pixel Flow required
import com.thomasdiewald.pixelflow.java.imageprocessing.filter.DwFilter;//Bloom required
import com.thomasdiewald.pixelflow.java.softbodydynamics.DwPhysics;//General Physics required
import com.thomasdiewald.pixelflow.java.softbodydynamics.constraint.DwSpringConstraint;//Chain Physics required
import com.thomasdiewald.pixelflow.java.softbodydynamics.constraint.DwSpringConstraint2D;//Chain Physics required
import com.thomasdiewald.pixelflow.java.softbodydynamics.particle.DwParticle2D;//Physics required to get and modify exiting nodes
//import com.thomasdiewald.pixelflow.java.softbodydynamics.particle.DwParticle;
import processing.core.*;

//
// Getting started with verlet particles/softbody simulation.
// 
// + Collision Detection
// + Network Chain Generation
// + Bloom FX effect

//Nodes ( particles ) as an Array of the NodeVA class
ArrayList<NodeVA> particles = new ArrayList<NodeVA>();
Boolean bMoreStaticPhysics = false;
float dampBounds;
float dampCollision;
float dampVelocity;

class EditablePixFlowNetwork {

  //Mouse interaction status
  Boolean bPressedFirstTime = false;
  float millisAtPressed = 0;
  float millisInteraction = 0;
  float radius_ball = 0;

  public PApplet papplet;
  public int size_x;
  public int size_y;

  // physics parameters
  DwPhysics.Param param_physics = new DwPhysics.Param();

  // physics simulation
  DwPhysics<DwParticle2D> physics;

  //Param_particle Used to set particular properties to each particle
  DwParticle2D.Param param_particle;

  //Interger Used to assign next Node to add a Particle in the Network
  vaID findId_particleMouse_pressed = new vaID(0);
  vaID findId_particleMouse_released = new vaID(0);
  //vaID modifyId_particleMouse = new vaID(0);
  String numParticlesText = " ";
  DwSpringConstraint.Param param_spring = new DwSpringConstraint.Param();
  Boolean bMoveMouseParticle = false; 
  color moveNodeColor = color(0, 0, 255);
  Boolean bAddNewNodeChain = false;
  color addNodeColor = color(255, 0, 0);
  //remove connexions
  boolean DELETE_SPRINGS = false;
  float   DELETE_RADIUS  = 20;

  ///////////////////////////////////
  //FX Effects and render variables
  PGraphics2D pg_render;
  PGraphics2D pg_luminance;
  PGraphics2D pg_bloom;
  DwFilter filter;

  ////////////////////////////////////////////////////

  //-------------------------------------------
  //Constructor
  public EditablePixFlowNetwork(PApplet papplet, int size_x, int size_y) {
    this.papplet = papplet;

    this.size_x = size_x;
    this.size_y = size_y;
  }

  //-------------------------------------------
  public void setup() {

    println(numParticlesText);

    //set this windows somewhere in your screen
    //surface.setLocation(viewport_x, viewport_y);

    setupPhysics();

    setupFXeffects();
  }

  //-------------------------------------------
  public void setupPhysics() {

    // physics object
    physics = new DwPhysics<DwParticle2D>(param_physics);

    // global physics parameters
    param_physics.GRAVITY = new float[]{ 0, 0};//0.5f };
    param_physics.bounds  = new float[]{ 0, 0, size_x, size_y };
    param_physics.iterations_collisions = 4;
    param_physics.iterations_springs    = 4;

    // particle parameters
    DwParticle2D.Param param_particle = new DwParticle2D.Param();
    param_particle.DAMP_BOUNDS = dampBounds       = 0.50f;
    param_particle.DAMP_COLLISION = dampCollision = 0.9990f;
    param_particle.DAMP_VELOCITY = dampVelocity   = 0.9999991f; 
    println(param_particle.DAMP_BOUNDS, param_particle.DAMP_COLLISION, param_particle.DAMP_VELOCITY);

    // spring parameters
    //DwSpringConstraint.Param param_spring = new DwSpringConstraint.Param();
    param_spring.damp_dec = 0.899999f;
    param_spring.damp_inc = 0.000099999f;

    reset();
  }

  //-------------------------------------------
  public void setupFXeffects() {

    filter = new DwFilter(context);

    // render targets
    pg_bloom = (PGraphics2D) createGraphics(size_x, size_y, P2D);
    pg_bloom.smooth(8);

    pg_render = (PGraphics2D) createGraphics(size_x, size_y, P2D);
    pg_render.smooth(8);

    pg_luminance = (PGraphics2D) createGraphics(size_x, size_y, P2D);
    pg_luminance.smooth(8);

    pg_render.beginDraw();
    pg_render.background(0); //just once
    pg_render.endDraw();
  }

  //---------------------------
  public void drawMouseInteraction() {
    if (bAddNewNodeChain) {
      if (particle_mouse_pressed != null) {
        //pg_render.
        stroke(200, 200, 200);
        //pg_render.
        line(particles.get(findId_particleMouse_pressed.id).cx, particles.get(findId_particleMouse_pressed.id).cy, mouseX, mouseY);
        //pg_render.
        fill(200, 200, 200);
        //pg_render.
        ellipse(mouseX, mouseY, 10, 10);
      }
    }

    // interaction stuff
    if (DELETE_SPRINGS) {
      noFill();
      stroke(200);
      strokeWeight(1);
      ellipse(mouseX, mouseY, DELETE_RADIUS, DELETE_RADIUS);
    }

    //Mouse Add Item interaction
    if (bPressedFirstTime) {
      noFill();
      stroke(addNodeColor);
      strokeWeight(1);
      ellipse(mouseX, mouseY, radius_ball, radius_ball);
    }
  }

  //--------------------------------
  public void update() {

    // update physics simulation
    physics.update(1);

    //update mouse interactions while pressed
    if (bPressedFirstTime) {
      millisInteraction = millis()*0.001 - millisAtPressed;
      //println("millisInteraction ="+str(millisInteraction));
      //recalc node size
      radius_ball = map(millisInteraction, 0, 3, 4, 100);
    }
  }

  //---------------------------
  public void draw() {

    update();

    pg_render.beginDraw();
    pg_render.noStroke();

    //Alpha Smoothing Drawings
    pg_render.fill(0, 0, 0, slider_AlphaBackground);
    pg_render.rectMode(CORNER);
    pg_render.rect(0, 0, width, height);

    drawNetwork();
    
    pg_render.endDraw();

    updateMouseInteractions();    

    // stats, to the title window
    String txt_fps = String.format(getClass().getName()+ "   [particles %d]   [frame %d]   [fps %6.2f]", particles.size(), frameCount, frameRate);
    surface.setTitle(txt_fps);
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
        color lineColor;
        if (bdrawForcesColor)lineColor = color(200-r, 200-g, 200-b); //small color modif to show chaing color in a black background
        else lineColor = defaultColorLines;

        pg_render.stroke(lineColor); 
        pg_render.vertex(pa.cx, pa.cy);
        pg_render.vertex(pb.cx, pb.cy);
      }
    }
    pg_render.endShape();


    // render particles
    pg_render.noStroke();

    for (int i = 0; i < particles.size(); i++) {
      if (bMoveMouseParticle && findId_particleMouse_pressed.id == i) {
        pg_render.fill(moveNodeColor);
      } else if (bAddNewNodeChain && findId_particleMouse_pressed.id == i) {
        pg_render.fill(addNodeColor);
      } else pg_render.fill(defaultColorNode);
      DwParticle2D particle = particles.get(i);
      pg_render.ellipse(particle.cx, particle.cy, particle.rad*2, particle.rad*2);
    }

    //popStyle();
  }


  //////////////////////////////////////////////////////////////////////////////
  // User Interaction
  //////////////////////////////////////////////////////////////////////////////

  DwParticle2D particle_mouse_pressed = null;
  DwParticle2D particle_mouse_released = null;

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

  //-----------------------------------------------
  public ArrayList<DwParticle2D> findParticlesWithinRadius(float mx, float my, float search_radius) {
    float dd_min_sq = search_radius * search_radius;
    DwParticle2D[] particles = physics.getParticles();
    ArrayList<DwParticle2D> list = new ArrayList<DwParticle2D>();
    for (int i = 0; i < particles.length; i++) {
      float dx = mx - particles[i].cx;
      float dy = my - particles[i].cy;
      float dd_sq =  dx*dx + dy*dy;
      if (dd_sq < dd_min_sq) {
        list.add(particles[i]);
      }
    }
    return list;
  }

  //--------------------------------------------
  public void updateMouseInteractions() {
    if (DELETE_SPRINGS) {
      ArrayList<DwParticle2D> list = findParticlesWithinRadius(mouseX, mouseY, DELETE_RADIUS);
      for (DwParticle2D tmp : list) {
        tmp.enableAllSprings(false);
        tmp.collision_group = physics.getNewCollisionGroupId();
        tmp.rad_collision = tmp.rad;
      }
    } else if (bMoveMouseParticle) {
      if (particle_mouse_pressed != null) {
        float[] mouse = {mouseX, mouseY};
        particle_mouse_pressed.moveTo(mouse, 0.2f);
      }
    }
  }

  //----------------------------------------------
  public void reset() {
    particles.clear();
    physics.reset(); //Reset ALL. Better use setParticles with a new size?
    newRandomChainItems();
  }

  //--------------------------------------
  public void addSpringBetweenParticles(vaID _id0, vaID _id1) {

    if (particles.size() > _id1.id && particles.size() > _id0.id) { //saved acces to arrayList
      DwSpringConstraint2D.addSpring(physics, particles.get(_id0.id), particles.get(_id1.id), param_spring);
    }
  }

  //--------------------------------------
  public void setupNextParamParticles(float _dampBounds, float _dampCollision, float _dampVelocity) {

    param_particle = new DwParticle2D.Param();
    param_particle.DAMP_BOUNDS          = _dampBounds;
    param_particle.DAMP_COLLISION       = _dampCollision;
    param_particle.DAMP_VELOCITY        = _dampVelocity; 
    println(param_particle.DAMP_BOUNDS, param_particle.DAMP_COLLISION, param_particle.DAMP_VELOCITY);

    // Reset All Them?
    for (int i = 0; i < particles.size(); i++) { // This work if they are the only ones. Not others like softbodies

      particles.get(i).updateParamByRef(param_particle);
      //if (i > 0) DwSpringConstraint2D.addSpring(physics, particles.get(i-1), particles.get(i), param_spring);
    }
  }
  //--------------------------------------------
  public void keyReleased() {
    if (key == 'r') reset();
    else if (key == 'p') {
      bMoreStaticPhysics = !bMoreStaticPhysics;
      if (bMoreStaticPhysics) {
        //More Statics values particle parameters
        dampBounds = 0.80f;
        dampCollision = 0.99f;
        dampVelocity = 0.51f;
      } else {

        dampBounds = 0.50f;
        dampCollision = 0.9990f;
        dampVelocity = 0.9999991f;
      }

      setupNextParamParticles(dampBounds, dampCollision, dampVelocity);
    }
    //if (key == 'p') DISPLAY_PARTICLES = !DISPLAY_PARTICLES;
  }
  //--------------------------------------------
  public void mousePressed() {

    particle_mouse_released = null;//reset
    particle_mouse_pressed = findNearestParticle(mouseX, mouseY, 100, findId_particleMouse_pressed);
    if (particle_mouse_pressed != null) {
      particle_mouse_pressed.enable(false, false, false);

      if (mouseButton == LEFT  ) {
        bMoveMouseParticle = true;
      } else if (mouseButton == RIGHT) {
        bAddNewNodeChain = true;
        //particle_mouse_pressed.enableSprings(true);//do not work as I thought
      }
    } else {
      //Nobody pressed
      if (mouseButton == RIGHT) { 
        DELETE_SPRINGS = true;
      } else if (mouseButton == LEFT) {
        bPressedFirstTime = true;
        millisAtPressed = millis()*0.001;
      }
    }
  }
  //--------------------------------------------
  public void mouseReleased() {

    bPressedFirstTime = false;

    particle_mouse_released = findNearestParticle(mouseX, mouseY, 25, findId_particleMouse_released);

    if (particle_mouse_pressed != null) {
      particle_mouse_pressed.enable(true, true, true); //Reset full status physics
      if (mouseButton == LEFT  ) {
        bMoveMouseParticle = false;
      }

      if (particle_mouse_released == null) { // There were NOT another node
        if (mouseButton == RIGHT) { // and Right Mouse Interaction
          addNewItemChain(particle_mouse_pressed, mouseX, mouseY, findId_particleMouse_pressed);
        }
      } else { // if item released
        //Add new spring between pressed and released
        //particle_mouse_released.enableSprings(true);//do not work as I thought
        addSpringBetweenParticles(findId_particleMouse_pressed, findId_particleMouse_released);
      }
    } else {
      //nobody pressed
      if (DELETE_SPRINGS) {
        //remove selected node spring from everyone. //TODO look how to remove just to springs with the right ids
        //if (particle_mouse_released != null)particle_mouse_released.enableAllSprings(false); //enableSprings(false);
      } else {
        //nobody released and no Deletion status, allow to add new item
        if (particle_mouse_released == null) {
          //Free to add a new it
          addNewItemCollision(mouseX, mouseY);
        }
      }
    }

    if (mouseButton == RIGHT ) DELETE_SPRINGS = false;
    bAddNewNodeChain = false;

    //reset 
    particle_mouse_released = null;
    particle_mouse_pressed = null;
  }


  //------------------------------------------------
  public void newRandomChainItems() {
    int numRandomParticles = int(slider_resetInitNodes);
    // create particles + chain them together
    for (int i = 0; i < numRandomParticles; i++) {
      float radius = random(minNodeSize, maxNodeSize);
      float px = size_x/2;
      float py = (100 + i * radius * 3)%height;
      float delta_px = px+random(-100, 100);
      float delta_py = py+random(-100, 100);

      //particles[i] = new DwParticle2D(i, px, py, radius, param_particle);
      NodeVA auxNodeVA = new NodeVA(i, delta_px, delta_py, radius, param_particle);
      particles.add(auxNodeVA);

      if (i > 0) DwSpringConstraint2D.addSpring(physics, particles.get(i-1), particles.get(i), param_spring);
    }

    DwParticle2D[] particles_Array = particles.toArray(new DwParticle2D[particles.size()]);
    physics.setParticles(particles_Array, particles.size());
  }

  //----------------------------------------------
  public void addNewItemCollision(float _px, float _py) {

    NodeVA auxParticle = new NodeVA(particles.size(), _px, _py, radius_ball, param_particle);
    particles.add(auxParticle);

    DwParticle2D[] particles_Array = particles.toArray(new DwParticle2D[particles.size()]);
    physics.setParticles(particles_Array, particles.size());
  }
  //----------------------------------------------
  public void addNewItemChain(DwParticle2D _prevItem, int _px, int _py, vaID _findId) {


    if (particle_mouse_pressed != null) {
      //Add one circle to this particle
      int id_LastNodeToAdd = _findId.id;//particles.size()-1;
      float radius = random(minNodeSize, maxNodeSize);
      float px = _px+random(-10, 10);
      float py = _py+random(-10, 10);
      NodeVA auxParticle = new NodeVA(particles.size(), px, py, radius, param_particle);
      particles.add(auxParticle);

      //Check Location Clicked
      //_prevItem.get

      //Add to World
      DwSpringConstraint2D.addSpring(physics, particles.get(id_LastNodeToAdd), particles.get(particles.size()-1), param_spring);
    }

    DwParticle2D[] particles_Array = particles.toArray(new DwParticle2D[particles.size()]);
    physics.setParticles(particles_Array, particles.size());
  }
}