
int slider_minNodeSize = 5;
int slider_maxNodeSize = 20;
Boolean bLoadedData = false;

void setup() {
  size(1280, 720);
  smooth(8);
  background(20);
}

//----------------------
void drawNetwork(String _nodeNameParameter, int _nodeSizeParameterMin, int _nodeSizeParameterMax) {

    if (hm_NetworkRel.isEmpty() == false) {
      // Using an enhanced loop to interate over each entry
      for (Map.Entry me : hm_NetworkRel.entrySet()) {
        print(me.getKey() + " is ");
        println(me.getValue());
        fill(200);

        //int idParticle = hm_targets.get(me.getKey());
        //int auxSizeTargetNode = getNodeSizeRelatedToDataTable(idParticle, _nodeNameParameter, _nodeSizeParameterMin, _nodeSizeParameterMax);
        //ellipse(random(0, width), random(0, height), auxSizeTargetNode, auxSizeTargetNode);

        PVector posNode = new PVector(random(0, width), random(0, height));
        ellipse(posNode.x, posNode.y, 10, 10);
      }
    }
}

//-----------------
void draw() {

  //fill(255, 0, 0);
  //ellipse(mouseX, mouseY, 10, 10);

  if (bLoadedData) {
    background(200, 125, 125);

    drawNetwork("betweenesscentrality", 0, 300);
    
    bLoadedData = false;
  }
}

void keyPressed() {

  if (key == 'p') {
    print_ArteDeRobar_TablesContent();
  }
  if (key == 'l') {
    //1rs load CSV
    load_CSV_NetWork_Tables();

    //2nd setup HasMap with CSV data
    setupHashTables();

    createNetwork_ArteDeRobar();

    bLoadedData = true;
  }
}