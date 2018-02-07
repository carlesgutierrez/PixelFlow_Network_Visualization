
import java.util.Map;

//Local Vars
Table table_targets;
Table table_edges;

// Note the HashMap's "key" is a String and "value" is an Integer
HashMap<String, Integer> hm_targets = new HashMap<String, Integer>();
HashMap<String, Integer> hm_edges = new HashMap<String, Integer>();

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