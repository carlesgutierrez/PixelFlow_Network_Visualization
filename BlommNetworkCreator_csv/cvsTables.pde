Table table_targets;
Table table_edges;

void load_CSV_NetWork_Tables() {
  table_targets = loadTable("artederobar_Targets.csv", "header");
  println(table_targets.getRowCount() + " total rows in table"); 

  table_edges = loadTable("artederobar_Edges.csv", "header");
  println(table_edges.getRowCount() + " total rows in table");
}

//------------------------------------
void print_ArteDeRobar_TablesContent() {
  //Print once the content
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