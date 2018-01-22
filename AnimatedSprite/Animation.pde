// Class for animating a sequence of GIFs //<>// //<>//

import java.io.FilenameFilter;

static final FilenameFilter FILTER = new FilenameFilter() {
  static final String NAME = "Animation", EXT = ".png";

  @ Override boolean accept(File path, String name) {
    return name.startsWith(NAME) && name.endsWith(EXT);
  }
};

class Animation {
  PImage[] images;
  int imageCount;
  int frame;

  Animation() {

    File f = dataFile("C:/Users/carles/Documents/develop/processing/VA/AnimatedSprite/data");
    String[] names = f.list(FILTER);
    printArray(names);
    imageCount = names.length;
    images = new PImage[imageCount];

    for (int i = 0; i < imageCount; i++) {
      images[i] = loadImage(names[i]);
    }
 
  }

  void display(float xpos, float ypos) {
    if (imageCount > 0) {
      frame = (frame+1) % imageCount;
      image(images[frame], xpos, ypos);
    }

  }

  int getWidth() {
    int auxWidth = 0;
    if (imageCount > 0) {
      auxWidth = images[0].width;
    }
    return auxWidth;
  }
}