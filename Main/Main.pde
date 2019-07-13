import g4p_controls.*;

int div;
float angle;
float factor;
float current;
boolean isRotating;
float t; //variavel de bezier
boolean isTranslating;

boolean rotationStage;

PVector p1Rot, p2Rot;

GButton btnRot, btnCur;
GTextArea inputRotPt1, inputRotPt2, inputRotAng, inputCtrlPt1, inputCtrlPt2, inputCtrlPt3, inputCtrlPt4;
GLabel labRot1, labRot2, labRot3, labRot4, labCur1, labCur2, labCur3, labCur4;

int OFFSET = 10;
int BTN_WIDTH = 80;
int BTN_HEIGHT = 30;
int LBL_WIDTH = 0;
int LBL_HEIGHT = 0;
int cp[];

float[] observador = {300,200,-150};

float x = 35.26/57.2958;
float y = 45/57.2958;

float tx = 200;
float ty = 200;
float tz = 0;

float[][] vertice = new float[][]{   {100,100,0,1},
                                      {220,100,0,1},
                                      {220,220,0,1},
                                      {180,220,0,1},
                                      {180,180,0,1},
                                      {140,180,0,1},
                                      {140,220,0,1},
                                      {100,220,0,1},
                                      {100,100,120,1},
                                      {220,100,120,1},
                                      {220,220,120,1},
                                      {180,220,120,1},
                                      {180,180,120,1},
                                      {140,180,120,1},
                                      {140,220,120,1},
                                      {100,220,120,1}};


float[][] vertices = projecaoIsometrica(vertice);

float[][] distanciasSorted;

float[][] rotate(float[][] vertex, float ang, PVector axis) {
  Rotation r = new Rotation(ang, axis);
  float[][] result = new float[vertex.length][vertex[0].length];
  for (int i = 0; i < vertex.length; i++) {
    float[] w = r.rotate(vertex[i]);
    result[i] = w;
  }
  return result;
}

float[][] multiplica(float[][] a,float[][] b){
    if (a[0].length != b.length) {
        throw new IllegalArgumentException("Incompatible matrices.");
    }

    float[][] mtx = new float[a.length][b[0].length];

    for (int i = 0; i < a.length; i++) {
        for (int j = 0; j < b[0].length; j++) {
            for (int k = 0; k < a[0].length; k++) {
                mtx[i][j] += a[i][k] * b[k][j];
            }
        }
    }
    return mtx;
}

float[][] projecaoIsometrica(float[][] vertices){
  float[][] rotateX = new float[][]{{cos(y),0,-sin(y),0},
                                  {0,1,0,0},
                                  {sin(y),0,cos(x),0},
                                  {0,0,0,1}};
                                  

  float [][] rotateY = new float[][]{{1,0,0,0},
                                   {0,cos(x),sin(x),0},
                                   {0,-sin(x),cos(x),0},
                                   {0,0,0,1}};
                                   
  float[][] translade = new float[][]{{1,0,0,0},
                                   {0,1,0,0},
                                   {0,0,1,0},
                                   {tx,ty,tz,1}};
  float[][] novosVerticesX = multiplica(vertices, rotateX);
  float[][] novosVerticesY = multiplica(novosVerticesX,rotateY);
  float[][] vertice = multiplica(novosVerticesY,translade);
  return vertice;
}

float[][] centroid(float[][][] faces){
  float[][] facesCentroid = new float[10][4];
  float maxX = -9999.;
  float maxY = -9999.;
  float maxZ = -9999.;
  float minX = 9999.;
  float minY = 9999.;
  float minZ = 9999.;

  float medX;
  float medY;
  float medZ;

  int i = 0;
  for(float[][] vs : faces){
    for(float[] v : vs){
      if(v[0] > maxX) maxX = v[0];
      if(v[1] > maxY) maxY = v[1];
      if(v[2] > maxZ) maxZ = v[2];
      if(v[0] < minX) minX = v[0];
      if(v[1] < minY) minY = v[1];
      if(v[2] < minZ) minZ = v[2];
    }
    medX = (maxX + minX) /2;
    medY = (maxY + minY) /2;
    medZ = (maxZ + minZ) /2;

    // println(" MaxX: "+ maxX + " MaxY: "+maxY + " MaxZ: "+maxZ);
    // println(" MinX: "+ minX + " MinY: "+minY + " MaxZ: "+minZ);
    // println(" MedX: "+ medX + " MedY: "+medY + " MedZ: "+medZ);

    facesCentroid[i][0] = medX;
    facesCentroid[i][1] = medY;
    facesCentroid[i][2] = medZ;
    facesCentroid[i][3] = i;

    maxX = -99999999;
    maxY = -99999999;
    maxZ = -99999999;
    minX = 99999999;
    minY = 99999999;
    minZ = 99999999;

    i++;
    }
  return facesCentroid;
}

float[][] insertionSort(float[][] vetor) {
    int j;
    float[] key;
    int i;
    
    for (j = 1; j < vetor.length; j++)
    {
      key = vetor[j];
      for (i = j - 1; (i >= 0) && (vetor[i][0] > key[0]); i--)
      {
         vetor[i + 1] = vetor[i];
       }
        vetor[i + 1] = key;
    }
    return vetor;
}

float distanciaVetorial(float[] v1, float[] v2){
  float dist = sqrt( (pow(v1[0] - v2[0], 2)) + (pow(v1[1] - v2[1], 2)) + (pow(v1[2] - v2[2], 2)));
  return dist;
}

float[][] distanciaFaceObservador(float[][] centr, float[] obser){
  float[][] dists = new float[10][2];
  int i = 0;
  float dist = 0;
  for(float[] cen : centr){
    dist = distanciaVetorial(cen, obser);
    dists[i][0] = dist;
    dists[i][1] = cen[3];
    i++;
  }
  return dists;
}

void paintersAlgorithm(float[][] dists, PShape[] faces){
  for(int i = faces.length -1; i >= 0; i--){
    int faceNum = (int)dists[i][1];
    shape(faces[faceNum],0,0);
  }
}

PShape[] buildObject(float[][][] fs) {
  PShape[] figura = new PShape[10];

  float[][] centroides = centroid(fs);
  float[][] distancias = distanciaFaceObservador(centroides, observador);
  
  distanciasSorted = insertionSort(distancias);

  int i = 0;
  for(float[][] vs : fs){
    figura[i] = createShape();
    figura[i].beginShape();
    for(float[] v : vs){
      figura[i].vertex(v[0], v[1]);
    }
    figura[i].endShape(CLOSE);
    i++;
  }

  return figura;
}

void setup(){
  size(1200, 700);
  background(255, 255, 255);

  drawUI();

  isRotating = false;
  rotationStage = true;

  frameRate(30);
}

void drawUI() {
    String rot1 = "Insira eixo de rotação:";
    labRot1 = new GLabel(this, 1050, 0, 130, 20, rot1);
    labRot1.setOpaque(true);

    String rot2 = "Início";
    labRot2 = new GLabel(this, 1050, 30, 130, 20, rot2);
    labRot2.setOpaque(true);

    inputRotPt1 = new GTextArea(this, 1050, 50, 130, 60, G4P.SCROLLBARS_BOTH | G4P.SCROLLBARS_AUTOHIDE);
    inputRotPt1.setText("(200,100)", 310);

    String rot3 = "Fim";
    labRot3 = new GLabel(this, 1050, 110, 130, 20, rot3);
    labRot3.setOpaque(true);

    inputRotPt2 = new GTextArea(this, 1050, 130, 130, 60, G4P.SCROLLBARS_BOTH | G4P.SCROLLBARS_AUTOHIDE);
    inputRotPt2.setText("(300,650)", 310);

    String rot4 = "Ângulo";
    labRot4 = new GLabel(this, 1050, 190, 130, 20, rot4);
    labRot4.setOpaque(true);

    inputRotAng = new GTextArea(this, 1050, 210, 130, 60, G4P.SCROLLBARS_BOTH | G4P.SCROLLBARS_AUTOHIDE);
    inputRotAng.setText("90", 310);

    btnRot = new GButton(this, 1050, 270, 130, 30, "Rotacionar");  
    
    String cur1 = "1º ponto de controle:";
    labCur1 = new GLabel(this, 900, 0, 130, 20, cur1);
    labCur1.setOpaque(true);
    
    inputCtrlPt1 = new GTextArea(this, 900, 20, 130, 60, G4P.SCROLLBARS_BOTH | G4P.SCROLLBARS_AUTOHIDE);
    inputCtrlPt1.setText("(1,2,3)", 310);

    String cur2 = "2º ponto de controle:";
    labCur2 = new GLabel(this, 900, 80, 130, 20, cur2);
    labCur2.setOpaque(true);

    inputCtrlPt2 = new GTextArea(this, 900, 100, 130, 60, G4P.SCROLLBARS_BOTH | G4P.SCROLLBARS_AUTOHIDE);
    inputCtrlPt2.setText("(4,5,6)", 310);

    String cur3 = "3º ponto de controle:";
    labCur3 = new GLabel(this, 900, 160, 130, 20, cur3);
    labCur3.setOpaque(true);

    inputCtrlPt3 = new GTextArea(this, 900, 180, 130, 60, G4P.SCROLLBARS_BOTH | G4P.SCROLLBARS_AUTOHIDE);
    inputCtrlPt3.setText("(7,8,9)", 310);

    String cur4 = "4º ponto de controle:";
    labCur4 = new GLabel(this, 900, 240, 130, 20, cur4);
    labCur4.setOpaque(true);

    inputCtrlPt4 = new GTextArea(this, 900, 260, 130, 60, G4P.SCROLLBARS_BOTH | G4P.SCROLLBARS_AUTOHIDE);
    inputCtrlPt4.setText("(10,11,12)", 310);

    btnCur = new GButton(this, 900, 300, 130, 30, "Transladar");
}

void drawAxis() {
  stroke(255, 0, 0);
  line(p1Rot.x, p1Rot.y, p2Rot.x, p2Rot.y);
  stroke(0, 0, 0);
}

void drawRegularObject() {
  PShape[] figura = buildObject(assembleFacesFromVertex(vertices));
  paintersAlgorithm(distanciasSorted, figura);
}

void animateObjectRotation() {
  // println("Current: " + current);
  // println("Angle: " + angle);
  // println("Factor: " + factor);
  
  PShape[] figura;
  
  if (current <= angle/2) {
    PVector p = new PVector(p1Rot.x, p1Rot.y);
    PVector q = new PVector(p2Rot.x, p2Rot.y);
    current += factor;
    vertices = rotate(vertices, factor, q.sub(p));
    figura = buildObject(assembleFacesFromVertex(vertices));
    paintersAlgorithm(distanciasSorted, figura);
  }
  else {
    isRotating = false;
    rotationStage = false;
  }
}

void draw(){
  background(255,255,255);

  if (isRotating) {
    animateObjectRotation();
    drawAxis();
  }
  else {
    drawRegularObject();
  }
}

public void handleButtonEvents(GButton button, GEvent event) {
  if (event == GEvent.CLICKED) {
    if (button == btnRot) {
      p1Rot = strToVector(inputRotPt1.getText(0));
      p2Rot = strToVector(inputRotPt2.getText(0));
      angle = strToFloat(inputRotAng.getText(0));
      div = (int)(6*angle);
      factor = angle / div;
      current = 0.;
      isRotating = true;
      print("P1: " + p1Rot);
      print("P2: " + p2Rot);
      print("Ângulo: " + angle);
    }else if(button == btnCur){
      cp = pointsToCp(inputCtrlPt1.getText(0), inputCtrlPt2.getText(0), inputCtrlPt3.getText(0), inputCtrlPt4.getText(0));
    }
  }
}
