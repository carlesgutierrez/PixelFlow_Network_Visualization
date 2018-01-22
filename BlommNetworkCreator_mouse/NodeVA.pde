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