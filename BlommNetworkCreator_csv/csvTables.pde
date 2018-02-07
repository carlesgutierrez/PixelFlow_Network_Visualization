
import java.util.Map;

//Local Vars
Table table_targets;
Table table_edges;

// Note the HashMap's "key" is a String and "value" is an Integer
HashMap<String, Integer> hm_targets = new HashMap<String, Integer>();


//------------------------------------
void setupHashTables() {

  //TARGETS
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
  
  int val = hm_targets.get("VB1D4mdJri0");
  print("Tests\n Looking for VB1D4mdJri0 -->");
  println(val);
  
  Boolean found = hm_targets.containsKey("VB1D4mdJri0");
  print("exist VB1D4mdJri0 ? -->");
  println(found);
  
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

//-------------------------------------
void createNetwork_ArteDeRobar(){
  
  HashMap<String, Integer> hm_AuxEdges = new HashMap<String, Integer>();
  
  //For each item of the Edges
  int counterAuxEdges = 0;
   for (TableRow row : table_edges.rows()) {  
     String source_edges = row.getString("Source");
     String target_edges = row.getString("Target");
   
    //exist SOURCE?
    Boolean foundSource = hm_AuxEdges.containsKey(source_edges);
        if(foundSource == false){
          //ifnot --> Add it into HastMap 
          hm_AuxEdges.put(source_edges, counterAuxEdges);
          //and Create Node "SOURCE"
          //TODO
          
        }else{ //ifYes
          //exist TARGET?
          Boolean foundTarget = hm_AuxEdges.containsKey(target_edges);
          if(foundTarget == true){
            //ifYes --> Link both. From TARGET to SOURCE.
            //TODO
          }else{
             //ifnot --> Add TARGET into same HastMap 
             hm_AuxEdges.put(target_edges, counterAuxEdges);
             //and Create Node "SOURCE"
             //TODO
          }
                        
        }
       

                
     counterAuxEdges++;
   }
}