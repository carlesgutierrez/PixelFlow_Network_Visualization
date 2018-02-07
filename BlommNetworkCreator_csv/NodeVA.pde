class NodeVA extends DwParticle2D {
  int id0, id1;

  NodeVA(int _id, float _px, float _py, float _radius, DwParticle2D.Param _param_particle) {

    super(_id);
    setPosition(_px, _py);
    setRadius(_radius);
    setParamByRef(_param_particle);
  }
  
  void updateParamByRef(DwParticle2D.Param _param_particle){
    setParamByRef(_param_particle);
  }

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