import g4p_controls.*;

int div;
float angle;
float factor;
float current;
boolean isRotating = true;

PVector p, q;

GButton gBtn;
GTextArea textSample;

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

  gBtn = new GButton(this, x, 2, 66, 20, "Rotationar");
  textSample = new GTextArea(this, 80, 20, 290, 300, G4P.SCROLLBARS_BOTH | G4P.SCROLLBARS_AUTOHIDE);
  textSample.setText("Insira o ponto inicial", 310);

  p = new PVector(150, 250);
  q = new PVector(250, 350);
  
  angle = 30.;
  div = (int)(3*angle);
  factor = angle / div;
  current = 0.;

  frameRate(30);
}

void drawAxis() {
  stroke(255, 0, 0);
  line(p.x, p.y, q.x, q.y);
  stroke(0, 0, 0);
}

void animateObjectRotation() {
  println("Current: " + current);
  println("Angle: " + angle);
  println("Factor: " + factor);
  
  PShape[] figura;
  
  if (current <= angle) {
    isRotating = true;
    current += factor;
    float[][] vs = rotate(vertices, current, q.sub(p));
    float[][][] facesObj = {{vs[0], vs[1], vs[2], vs[3], vs[4], vs[5], vs[6], vs[7]}, 
    {vs[8], vs[9], vs[10], vs[11], vs[12], vs[13], vs[14], vs[15]},
                      {vs[0], vs[7], vs[8], vs[15]},
                      {vs[7], vs[15], vs[14], vs[6]},
                      {vs[6], vs[5], vs[13], vs[14]},
                      {vs[5], vs[13], vs[12], vs[4]},
                      {vs[3], vs[4], vs[12], vs[11]},
                      {vs[2], vs[3], vs[11], vs[10]},
                      {vs[2], vs[1], vs[9], vs[10]},
                      {vs[0], vs[8], vs[9], vs[1]}};
    figura = buildObject(facesObj);
  }
  else {
    isRotating = false;
    float[][] vs = rotate(vertices, angle, q.sub(p));
    float[][][] facesObj = {{vs[0], vs[1], vs[2], vs[3], vs[4], vs[5], vs[6], vs[7]},
                      {vs[8], vs[9], vs[10], vs[11], vs[12], vs[13], vs[14], vs[15]},
                      {vs[0], vs[7], vs[8], vs[15]},
                      {vs[7], vs[15], vs[14], vs[6]},
                      {vs[6], vs[5], vs[13], vs[14]},
                      {vs[5], vs[13], vs[12], vs[4]},
                      {vs[3], vs[4], vs[12], vs[11]},
                      {vs[2], vs[3], vs[11], vs[10]},
                      {vs[2], vs[1], vs[9], vs[10]},
                      {vs[0], vs[8], vs[9], vs[1]}};
    figura = buildObject(facesObj);
  }
  
  paintersAlgorithm(distanciasSorted, figura);
}

void draw(){
  background(255,255,255);

  drawAxis();
  animateObjectRotation();
}