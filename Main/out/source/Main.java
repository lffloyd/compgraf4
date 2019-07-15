import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import g4p_controls.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Main extends PApplet {



int div;
float angle;
float factor;
float current;
boolean isRotating, isTranslating;
float t; //variavel de bezier

boolean rotationStage, translationStage;

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

float x = 35.26f/57.2958f;
float y = 45/57.2958f;

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

public float[][] multiplica(float[][] a,float[][] b){
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

public float[][] projecaoIsometrica(float[][] vertices){
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

public float[][] centroid(float[][][] faces){
  float[][] facesCentroid = new float[10][4];
  float maxX = -9999.f;
  float maxY = -9999.f;
  float maxZ = -9999.f;
  float minX = 9999.f;
  float minY = 9999.f;
  float minZ = 9999.f;

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

public float[][] insertionSort(float[][] vetor) {
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

public float distanciaVetorial(float[] v1, float[] v2){
  float dist = sqrt( (pow(v1[0] - v2[0], 2)) + (pow(v1[1] - v2[1], 2)) + (pow(v1[2] - v2[2], 2)));
  return dist;
}

public float[][] distanciaFaceObservador(float[][] centr, float[] obser){
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

public void paintersAlgorithm(float[][] dists, PShape[] faces){
  for(int i = faces.length -1; i >= 0; i--){
    int faceNum = (int)dists[i][1];
    shape(faces[faceNum],0,0);
  }
}

public PShape[] buildObject(float[][][] fs) {
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
  
  //Luzes

  luzDirecional(figura, vertices);

  //Luzes
  

  return figura;
}

public void setup(){
  
  background(255, 255, 255);

  drawUI();

  isRotating = false;
  rotationStage = true;
  isTranslating = false;
  translationStage = false;

  frameRate(30);
}

public void drawUI() {
    String rot1 = "Insira eixo de rotação:";
    labRot1 = new GLabel(this, 1050, 0, 130, 20, rot1);
    labRot1.setOpaque(true);

    String rot2 = "Início";
    labRot2 = new GLabel(this, 1050, 30, 130, 20, rot2);
    labRot2.setOpaque(true);

    inputRotPt1 = new GTextArea(this, 1050, 50, 130, 60, G4P.SCROLLBARS_BOTH | G4P.SCROLLBARS_AUTOHIDE);
    inputRotPt1.setText("(200,100,50)", 310);

    String rot3 = "Fim";
    labRot3 = new GLabel(this, 1050, 110, 130, 20, rot3);
    labRot3.setOpaque(true);

    inputRotPt2 = new GTextArea(this, 1050, 130, 130, 60, G4P.SCROLLBARS_BOTH | G4P.SCROLLBARS_AUTOHIDE);
    inputRotPt2.setText("(300,650,0)", 310);

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
    inputCtrlPt1.setText("(50,50,0)", 310);

    String cur2 = "2º ponto de controle:";
    labCur2 = new GLabel(this, 900, 80, 130, 20, cur2);
    labCur2.setOpaque(true);

    inputCtrlPt2 = new GTextArea(this, 900, 100, 130, 60, G4P.SCROLLBARS_BOTH | G4P.SCROLLBARS_AUTOHIDE);
    inputCtrlPt2.setText("(500,200,0)", 310);

    String cur3 = "3º ponto de controle:";
    labCur3 = new GLabel(this, 900, 160, 130, 20, cur3);
    labCur3.setOpaque(true);

    inputCtrlPt3 = new GTextArea(this, 900, 180, 130, 60, G4P.SCROLLBARS_BOTH | G4P.SCROLLBARS_AUTOHIDE);
    inputCtrlPt3.setText("(50,350,0)", 310);

    String cur4 = "4º ponto de controle:";
    labCur4 = new GLabel(this, 900, 240, 130, 20, cur4);
    labCur4.setOpaque(true);

    inputCtrlPt4 = new GTextArea(this, 900, 260, 130, 60, G4P.SCROLLBARS_BOTH | G4P.SCROLLBARS_AUTOHIDE);
    inputCtrlPt4.setText("(500,500,0)", 310);

    btnCur = new GButton(this, 900, 300, 130, 30, "Transladar");
}

public void drawAxis() {
  stroke(255, 0, 0);
  line(p1Rot.x, p1Rot.y, p2Rot.x, p2Rot.y);
  stroke(0, 0, 0);
}

public void drawRegularObject() {
  PShape[] figura = buildObject(assembleFacesFromVertex(vertices));
  paintersAlgorithm(distanciasSorted, figura);
}


public void animateObjectTranslation() {
  if (t <= 1) {
    PVector q = getBezierPoint(t, cp);

    float[][] currentCentroids = centroid(assembleFacesFromVertex(vertices));
    float[] face1Centroid = currentCentroids[0];
    PVector p = new PVector(face1Centroid[0], face1Centroid[1]);

    PShape[] figura = buildObject(assembleFacesFromVertex(vertices));

    for(int i=0; i<10;i++) shape(figura[i], q.x-p.x,q.y-p.y);
  
    t += 0.005f;
  } else {
    isTranslating = false;
    translationStage = false;
  }
}

public void animateObjectRotation() {
  // println("Current: " + current);
  // println("Angle: " + angle);
  // println("Factor: " + factor);
  
  PShape[] figura;
  
  if (current <= angle) {
    PVector p = new PVector(p1Rot.x, p1Rot.y, p1Rot.z);
    PVector q = new PVector(p2Rot.x, p2Rot.y, p2Rot.z);
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

//LUZES

float[] cor = {50, 250, 150};
float RA = 0.8f;
float IA = 1;
float ID = 0.7f;
float RD = 0.7f;


public void luzDirecional(PShape[] figura, float[][] vertices){

  float[][] normais = calculaNormal(assembleFacesFromVertex(vertices));


  int i = 0;

  for(PShape f : figura){

    PVector u = new PVector(normais[i][0], normais[i][1], normais[i][2]);
    PVector v = new PVector(observador[0], observador[1], observador[2]);

    float anguloRadianos = PVector.angleBetween(u, v);
    float cosTeta = cos(anguloRadianos);

    float ilumAmbiente = RA*IA;
    float ilumDifusa = ID * RD * cosTeta;
  
    float coeficienteI = ilumAmbiente + ilumDifusa;
    println("COR: " + coeficienteI);
    
    f.setFill(color(cor[0] * coeficienteI, cor[1] * coeficienteI, cor[2] * coeficienteI));

    i++;
  }
}

//LUZES

public void draw(){
  background(255,255,255);

  calculaNormal(assembleFacesFromVertex(vertices));


  //luzDirecional(buildObject(assembleFacesFromVertex(vertices)));
   
  if (isRotating && rotationStage) {
    animateObjectRotation();
    drawAxis();
  }
  if (isTranslating && translationStage) {
    drawBezier(cp);
    animateObjectTranslation();
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
      div = 50;
      factor = angle / div;
      current = 0.f;
      isRotating = true;
      isTranslating = false;
      print("P1: " + p1Rot);
      print("P2: " + p2Rot);
      print("Ângulo: " + angle);
    } else if(button == btnCur) {
      t = 0;
      cp = pointsToCp(inputCtrlPt1.getText(0), inputCtrlPt2.getText(0),
           inputCtrlPt3.getText(0), inputCtrlPt4.getText(0));
      isTranslating = true;
      translationStage = true;
      isRotating = false;
    }
  }
}
class Quaternion {
    float p0, p1, p2, p3;

    Quaternion() {
        p0 = 0.f; p1 = 0.f; p2 = 0.f; p3 = 0.f;
    }

    Quaternion(float a, float b, float c, float d) {
        p0 = a; p1 = b; p2 = c; p3 = d;
    }
    
    public float norm() {
        return sqrt(p0*p0 + p1*p1 + p2*p2 + p3*p3);
    }

    public Quaternion normalize() {
        float pNorm = this.norm();
        p0 *= pNorm; p1 *= pNorm; p2 *= pNorm; p3 *= pNorm;
        return this;
    }

    public Quaternion conjugate() {
        return new Quaternion(this.p0, -this.p1, -this.p2, -this.p3);
    }

    public Quaternion crossProduct(Quaternion b) {
        Quaternion a = this;
        float r0 = a.p0*b.p0 - a.p1*b.p1 - a.p2*b.p2 - a.p3*b.p3;
        float r1 = a.p0*b.p1 + a.p1*b.p0 + a.p2*b.p3 - a.p3*b.p2;
        float r2 = a.p0*b.p2 - a.p1*b.p3 + a.p2*b.p0 + a.p3*b.p1;
        float r3 = a.p0*b.p3 + a.p1*b.p2 - a.p2*b.p1 + a.p3*b.p0;
        return new Quaternion(r0, r1, r2, r3);
    }

    public Quaternion scalarProduct(float scalar) {
        p0 *= scalar; p1 *= scalar; p2 *= scalar; p3 *= scalar;
        return this;
    }

    public PVector to3DVector() {
        return new PVector(p1, p2, p3);
    }
}
class Rotation {
    float angle;
    PVector rotationAxis;
    Quaternion q, qConjugate;

    Rotation(float ang, PVector axis) {
        float tempAngle = ang/57.2958f;
        angle = tempAngle/2.0f;
        axis.normalize();
        rotationAxis = axis;
        q = new Quaternion(cos(angle), rotationAxis.x*sin(angle), 
                        rotationAxis.y*sin(angle), rotationAxis.z*sin(angle));
        qConjugate = q.conjugate();

        println("orig. angle: " + ang);
        println("angle: "+angle);
        println("axis: "+axis);
    }

    public float[] rotate(float[] point) {
        Quaternion p = new Quaternion(0.f, point[0], point[1], point[2]);
        Quaternion rQp = q.crossProduct(p.crossProduct(qConjugate)); 
        return new float[]{rQp.p1, rQp.p2, rQp.p3};
    }
}
/*
Funções auxiliares de variados tipos.
*/

public PVector strToVector(String str) {
    String[] pntArr = split(str.replace("(", "").replace(")", ""), ",");
    return new PVector(Integer.parseInt(pntArr[0]), Integer.parseInt(pntArr[1]), Integer.parseInt(pntArr[2]));
}

public float strToFloat(String str) {
    return (float)Double.parseDouble(str);
}

public float[][][] assembleFacesFromVertex(float[][] vertex) {
    return new float[][][]{
                      {vertex[0], vertex[1], vertex[2], vertex[3], vertex[4], vertex[5], vertex[6], vertex[7]}, //OK
                      {vertex[15], vertex[14], vertex[13], vertex[12], vertex[11], vertex[10], vertex[9], vertex[8]}, //OK
                      {vertex[8], vertex[0], vertex[7], vertex[15]}, // OK
                      {vertex[15], vertex[14], vertex[6], vertex[7]}, //OK
                      {vertex[5], vertex[13], vertex[14], vertex[6]}, //OK
                      {vertex[13], vertex[12], vertex[4], vertex[5]}, //OK
                      {vertex[12], vertex[4], vertex[3], vertex[11]}, //OK
                      {vertex[11], vertex[10], vertex[2], vertex[3]}, //OK
                      {vertex[1], vertex[9], vertex[10], vertex[2]}, //OK
                      {vertex[0], vertex[8], vertex[9], vertex[1]}}; //OK
}

public float[][] calculaNormal(float[][][] faces){
  float[][] normais = new float[faces.length][3];

  int i = 0;
  for(float[][] vertices : faces){
    float[] v1 = vertices[0];
    float[] v2 = vertices[1];
    float[] v3 = vertices[2];

    PVector p1 = new PVector(v1[0], v1[1], v1[2]);
    PVector p2 = new PVector(v2[0], v2[1], v2[2]);
    PVector p3 = new PVector(v3[0], v3[1], v3[2]);

    p1.sub(p2);
    p3.sub(p2);
    
    PVector n = p3.cross(p1);

    //n.normalize();
    
    normais[i][0] = n.x;
    normais[i][1] = n.y;
    normais[i][2] = n.z;

    //println("X: " + n.x + " Y: " + n.y + " Z: " + n.z);

    i++;
  }
  return normais;
}



public int[] pointsToCp(String p1, String p2, String p3,String p4){
  int cp[] = new int[12];
  String[] p1Str = split(p1.replace("(", "").replace(")", ""), ",");
  String[] p2Str = split(p2.replace("(", "").replace(")", ""), ",");
  String[] p3Str = split(p3.replace("(", "").replace(")", ""), ",");
  String[] p4Str = split(p4.replace("(", "").replace(")", ""), ",");
  
  for (int i = 0; i<3; i++){
    cp[i] = Integer.parseInt(p1Str[i]);
    cp[i+3] = Integer.parseInt(p2Str[i]);
    cp[i+6] = Integer.parseInt(p3Str[i]);
    cp[i+9] = Integer.parseInt(p4Str[i]);
  }
  
  return cp;
}

public void drawBezier(int[] cp) {
  stroke(255,0,0);
  for(float i = 0; i<1; i = i + 0.0015f){
      float posXp = (float) (Math.pow((1-i), 3)*cp[0] + 3*Math.pow((1-i), 2)*i*cp[3] + 3*(1-i)*Math.pow(i, 2)*cp[6] + Math.pow(i, 3)*cp[9]);
      float posYp = (float) (Math.pow((1-i), 3)*cp[1] + 3*Math.pow((1-i), 2)*i*cp[4] + 3*(1-i)*Math.pow(i, 2)*cp[7] + Math.pow(i, 3)*cp[10]);
      float posZp = (float) (Math.pow((1-i), 3)*cp[2] + 3*Math.pow((1-i), 2)*i*cp[5] + 3*(1-i)*Math.pow(i, 2)*cp[8] + Math.pow(i, 3)*cp[11]);
      point(posXp + 25, posYp + 25);
  }
  stroke(0, 0, 0);
}

public float[][] translateObjectThroughBezier(float[][] vertex, PVector translation) {
  float[][] result = new float[vertex.length][vertex[0].length];
  for (int i = 0; i < vertex.length; i++) {
    float[] w = translate(vertex[i], translation);
    result[i] = w;
  }
  return result;
}

public PVector getBezierPoint(float t, int[] cp) {
  int posXp = (int) (Math.pow((1-t), 3)*cp[0] + 3*Math.pow((1-t), 2)*t*cp[3] + 3*(1-t)*Math.pow(t, 2)*cp[6] + Math.pow(t, 3)*cp[9]);
  int posYp = (int) (Math.pow((1-t), 3)*cp[1] + 3*Math.pow((1-t), 2)*t*cp[4] + 3*(1-t)*Math.pow(t, 2)*cp[7] + Math.pow(t, 3)*cp[10]);
  int posZp = (int) (Math.pow((1-t), 3)*cp[2] + 3*Math.pow((1-t), 2)*t*cp[5] + 3*(1-t)*Math.pow(t, 2)*cp[8] + Math.pow(t, 3)*cp[11]);
  return new PVector(posXp, posYp, posZp);
}

public float[] translate(float[] v, PVector dist) {
  PVector w = new PVector(v[0], v[1]);
  w.add(dist);
  return new float[]{ w.x, w.y, v[2] };
}

public float[][] rotate(float[][] vertex, float ang, PVector axis) {
  Rotation r = new Rotation(ang, axis);
  float[][] result = new float[vertex.length][vertex[0].length];
  for (int i = 0; i < vertex.length; i++) {
    float[] w = r.rotate(vertex[i]);
    result[i] = w;
  }
  return result;
}
  public void settings() {  size(1200, 700); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Main" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
