/**
 * Animated Sprite (Shifty + Teddy)
 * by James Paterson. 
 * 
 * Press the mouse button to change animations.
 * Demonstrates loading, displaying, and animating GIF images.
 * It would be easy to write a program to display 
 * animated GIFs, but would not allow as much control over 
 * the display sequence and rate of display. 
 */

Animation animation1;
PFont f;

void setup() {
  size(1280, 720);
  background(255, 204, 0);
  frameRate(30);

  animation1 = new Animation();

  //Display Text
  f = createFont("Arial", 16, true); // Arial, 16 point, anti-aliasing on
}

void draw() { 

  background(255, 204, 0);
  
  textFont(f, 16);    // Specify font to be used
  fill(0);            // Specify font color 
  textAlign(CENTER);  // Specify aligment
  text("Add png images at data folder --> Animation-#####.png", width/2, height/2);   //Display Text
  
  animation1.display(0, 0);


}