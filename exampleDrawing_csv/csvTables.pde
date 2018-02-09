
import java.util.Map;

//Local Vars
Table table_targets;
Table table_edges;

// Note the HashMap's "key" is a String and "value" is an Integer
HashMap<String, Integer> hm_targets = new HashMap<String, Integer>();
HashMap<String, Integer> hm_NetworkRel = new HashMap<String, Integer>();

//------------------------------------
void setupHashTables() {

  //TARGETS will contain all the desired info about each node.
  int auxCounterTargets = 0;
  for (TableRow row : table_targets.rows()) {
    String id_targets = row.getString("Id"); //Source or 
    hm_targets.put(id_targets, auxCounterTargets);
    auxCounterTargets++;
  }

  //EDGES ? That's not necesary. Use just table_edges
}


//--------------------------------------
void load_CSV_NetWork_Tables() {
  table_targets = loadTable("artederobar_Targets.csv", "header");
  println(table_targets.getRowCount() + " total rows in table"); 

  table_edges = loadTable("artederobar_Edges.csv", "header");
  println(table_edges.getRowCount() + " total rows in table");

  setupHashTables();
}


//------------------------------------
void print_ArteDeRobar_HastMap() {

  // Using an enhanced loop to iterate over each entry
  for (Map.Entry me : hm_targets.entrySet()) {
    print(me.getKey() + " is ");
    println(me.getValue());
  }

  //int val = hm_targets.get("VB1D4mdJri0");
  //print("Tests\n Looking for VB1D4mdJri0 -->");
  //println(val);

  //Boolean found = hm_targets.containsKey("VB1D4mdJri0");
  //print("exist VB1D4mdJri0 ? -->");
  //println(found);
}

//------------------------------------
void print_ArteDeRobar_TablesContent() {
  //Load Id into hashMap
  for (TableRow row : table_targets.rows()) {

    String id = row.getString("Id"); //getInt
    String label = row.getString("Label");
    String seedrank = row.getString("seedrank");
    String viewcount = row.getString("viewcount");
    String likecount = row.getString("likecount");

    println("Target id["+id+"]: seedrank["+seedrank+"] viewcount["+viewcount+"] likecount["+likecount+"] -> "+label);
  }

  //Print Content edges
  //Source , "Target" , "Type" , "Id"  //Rest not used: "Label",  "timeset" , "Weight" , "filter_cluster 4"
  for (TableRow row : table_edges.rows()) {

    String source_edges = row.getString("Source");
    String target_edges = row.getString("Target"); //getInt
    String type_edges = row.getString("Type");
    int id_edges = row.getInt("Id");

    println("Edges id["+id_edges+"]: Source["+source_edges+"] -> target["+target_edges+"] // type ["+type_edges+"]");
  }
}
//--------------------------------------
int getNodeSizeRelatedToDataTable(int idTable, String parameterName, int _MinRefSize, int _MaxRefSize) {
  //Get a desired value from Targets and map it between min, max radius
  TableRow rowDesiredData = table_targets.getRow(idTable);
  int auxDesiredData = rowDesiredData.getInt(parameterName);
  int mapedNodeSize = (int)map((float)auxDesiredData, (float)_MinRefSize, (float)_MaxRefSize, slider_minNodeSize, slider_maxNodeSize);

  return mapedNodeSize;
}

//-------------------------------------
void createNetwork_ArteDeRobar() {

  hm_NetworkRel.clear();

  //For each item of the Edges
  int counterAuxEdges = 0;
  for (TableRow row : table_edges.rows()) {  
    String source_edges = row.getString("Source");
    String target_edges = row.getString("Target");

    //exist SOURCE?
    Boolean foundSource = hm_NetworkRel.containsKey(source_edges);
    Boolean foundTarget = hm_NetworkRel.containsKey(target_edges);
    //Find the Target and Source in the hasmap, this order is equivalent to particles
    int idParticleTarget = 0;
    if (foundTarget)idParticleTarget = hm_targets.get(target_edges);
    int idParticleSource = 0;
    if (foundSource)idParticleSource = hm_targets.get(source_edges);

    if (foundSource == false) { //Found Source -> Not --> Add source (HashMap & particles)
      hm_NetworkRel.put(source_edges, counterAuxEdges); 
      counterAuxEdges++;
      //idParticleSource = hm_targets.get(source_edges);
      //int auxSizeTargetNode = getNodeSizeRelatedToDataTable(idParticleSource, _nodeNameParameter, _nodeSizeParameterMin, _nodeSizeParameterMax);

    }
    if (foundTarget == false) {
      //Source Yes & Found Target -> Not --> Add target (HashMap & particles)
      hm_NetworkRel.put(target_edges, counterAuxEdges);
      counterAuxEdges++;
      //idParticleTarget = hm_targets.get(source_edges);
      //int auxSizeTargetNode = getNodeSizeRelatedToDataTable(idParticleTarget, _nodeNameParameter, _nodeSizeParameterMin, _nodeSizeParameterMax);
    }
  }
}