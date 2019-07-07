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

    println(" MaxX: "+ maxX + " MaxY: "+maxY + " MaxZ: "+maxZ);
    println(" MinX: "+ minX + " MinY: "+minY + " MaxZ: "+minZ);
    println(" MedX: "+ medX + " MedY: "+medY + " MedZ: "+medZ);

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
                                      
float[][][] arestas = new float[][][]{{vertices[0],vertices[1]},
                                      {vertices[1],vertices[2]},
                                      {vertices[2],vertices[3]},
                                      {vertices[3],vertices[4]},
                                      {vertices[4], vertices[5]},
                                      {vertices[5], vertices[6]},
                                      {vertices[6], vertices[7]},
                                      {vertices[7], vertices[0]},
                                      {vertices[8], vertices[9]},
                                      {vertices[9], vertices[10]},
                                      {vertices[10], vertices[11]},
                                      {vertices[11], vertices[12]},
                                      {vertices[12], vertices[13]},
                                      {vertices[13], vertices[14]},
                                      {vertices[14], vertices[15]},
                                      {vertices[15], vertices[8]},
                                      {vertices[0], vertices[8]},
                                      {vertices[7], vertices[15]},
                                      {vertices[6], vertices[14]},
                                      {vertices[5], vertices[13]},
                                      {vertices[4], vertices[12]},
                                      {vertices[3], vertices[11]},
                                      {vertices[2], vertices[10]},
                                      {vertices[1], vertices[9]}};

float[][][][] faces = { {arestas[0], arestas[1], arestas[2], arestas[3], arestas[4], arestas[5], arestas[6], arestas[7]},      //F1
                        {arestas[8], arestas[9], arestas[10], arestas[11], arestas[12], arestas[13], arestas[14], arestas[15]},//F2
                        {arestas[7], arestas[16], arestas[15], arestas[17], null, null, null, null},                           //F3 
                        {arestas[6], arestas[17], arestas[14], arestas[18], null, null, null, null},                           //F4
                        {arestas[5], arestas[19], arestas[13], arestas[18], null, null, null, null},                           //F5
                        {arestas[4], arestas[19], arestas[12], arestas[20], null, null, null, null},                           //F6
                        {arestas[3], arestas[20], arestas[11], arestas[21], null, null, null, null},                           //F7
                        {arestas[2], arestas[21], arestas[10], arestas[22], null, null, null, null},                           //F8
                        {arestas[1], arestas[23], arestas[9], arestas[22], null, null, null, null},                            //F9
                        {arestas[0], arestas[16], arestas[8], arestas[23], null, null, null, null}};                           //F10

float[][][] faces2 = {{vertices[0], vertices[1], vertices[2], vertices[3], vertices[4], vertices[5], vertices[6], vertices[7]},
                      {vertices[8], vertices[9], vertices[10], vertices[11], vertices[12], vertices[13], vertices[14], vertices[15]},
                      {vertices[0], vertices[7], vertices[8], vertices[15]},
                      {vertices[7], vertices[15], vertices[14], vertices[6]},
                      {vertices[6], vertices[5], vertices[13], vertices[14]},
                      {vertices[5], vertices[13], vertices[12], vertices[4]},
                      {vertices[3], vertices[4], vertices[12], vertices[11]},
                      {vertices[2], vertices[3], vertices[11], vertices[10]},
                      {vertices[2], vertices[1], vertices[9], vertices[10]},
                      {vertices[0], vertices[8], vertices[9], vertices[1]}};







PShape f1, f2, f3, f4, f5, f6, f7, f8, f9, f10;
PShape[] figura = {f1, f2, f3, f4, f5, f6, f7, f8, f9, f10};
float[][] distanciasSorted;

void setup(){
  float[][] centroides = centroid(faces2);
  
  println("----------CENTROIDES-------------");
  for(float[] i : centroides){
    for(float j : i){
      print(j + " ");
    }
    println();
  }
    println("----------CENTROIDES-------------\n\n");

  float[][] distancias = distanciaFaceObservador(centroides, observador);
    println("----------DISTANCIAS-------------");
  for(float[] i : distancias){
    for(float j : i){
      print(j + " ");
    }
    println();
  }
    println("----------DISTANCIAS-------------\n\n");

  distanciasSorted = insertionSort(distancias);
    println("----------DISTANCIAS-------------");
  for(float[] i : distanciasSorted){
    for(float j : i){
      print(j + " ");
    }
    println();
  }
    println("----------DISTANCIAS-------------\n\n");


  
  size(800,600);
  background(255,255,255);

  int i = 0;
  for(float[][] vs : faces2){
    figura[i] = createShape();
    figura[i].beginShape();
    for(float[] v : vs){
      print(v[0], v[1] , i + "\n");
      figura[i].vertex(v[0], v[1]);
      
    }
    figura[i].endShape(CLOSE);
    i++;
  }
}
 
void draw(){
  paintersAlgorithm(distanciasSorted, figura);
}
