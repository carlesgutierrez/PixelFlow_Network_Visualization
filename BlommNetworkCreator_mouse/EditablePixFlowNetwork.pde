//<>// //<>//
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

import processing.core.*;

//
// Getting started with verlet particles/softbody simulation.
// 
// + Collision Detection
// + Network Chain Generation
// + Bloom FX effect

//Nodes ( particles ) as an Array of the NodeVA class
ArrayList<NodeVA> particles = new ArrayList<NodeVA>();

class EditablePixFlowNetwork {

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
  vaID findId_particleMouse = new vaID(0);
  //vaID modifyId_particleMouse = new vaID(0);
  String numParticlesText = " ";
  DwSpringConstraint.Param param_spring = new DwSpringConstraint.Param();
  Boolean bMoveMouseParticle = false; 
  color moveNodeColor = color(0, 0, 255);
  Boolean bAddNewNodeChain = false;
  color addNodeColor = color(255, 0, 0);

  ///////////////////////////////////
  //FX Effects and render variables
  PGraphics2D pg_render;
  PGraphics2D pg_bloom;

  DwFilter filter;



  ////////////////////////////////////////////////////
  //Code

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


    filter = new DwFilter(context);

    // render targets
    pg_bloom = (PGraphics2D) createGraphics(size_x, size_y, P2D);
    pg_bloom.smooth(8);

    pg_render = (PGraphics2D) createGraphics(size_x, size_y, P2D);
    pg_render.smooth(8);

    pg_render.beginDraw();
    pg_render.background(0); //8);
    pg_render.endDraw();
  }

//---------------------------
  public void drawMouseInteraction() {
    if (bAddNewNodeChain) {
      if (particle_mouse != null) {
        pg_render.stroke(200, 200, 200);
        pg_render.line(particles.get(findId_particleMouse.id).cx, particles.get(findId_particleMouse.id).cy, mouseX, mouseY);
        pg_render.fill(200, 200, 200);
        pg_render.ellipse(mouseX, mouseY, 10, 10);
      }
    }
  }

//---------------------------
  public void draw() {

    // update physics simulation
    physics.update(1);

    pg_render.beginDraw();
    pg_render.noStroke();
    //pg_render.fill(255, 96); //seems to be not necesary
    //pg_render.rect(0, 0, width, height);

    pg_render.background(0);
    drawNetwork();

    drawMouseInteraction();


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
      if (bMoveMouseParticle && findId_particleMouse.id == i) {
        pg_render.fill(moveNodeColor);
      } else if (bAddNewNodeChain && findId_particleMouse.id == i) {
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
      } else if (mouseButton == RIGHT) {
        bAddNewNodeChain = true;
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
        bAddNewNodeChain = false;
      }

      particle_mouse = null;
    }
  }

  //------------------------------------------------
  public void newRandomChainItems() {
    int numRandomParticles = int(random(minResetInitNodes, maxResetInitNodes));
    // create particles + chain them together
    for (int i = 0; i < numRandomParticles; i++) {
      float radius = random(minNodeSize, maxNodeSize);
      float px = size_x/2;
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
      float radius = random(minNodeSize, maxNodeSize);
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
}