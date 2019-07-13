/*
Funções auxiliares de variados tipos.
*/

PVector strToVector(String str) {
    String[] pntArr = split(str.replace("(", "").replace(")", ""), ",");
    return new PVector(Integer.parseInt(pntArr[0]), Integer.parseInt(pntArr[1]));
}

float strToFloat(String str) {
    return (float)Double.parseDouble(str);
}

float[][][] assembleFacesFromVertex(float[][] vertex) {
    return new float[][][]{
        {vertex[0], vertex[1], vertex[2], vertex[3], vertex[4], 
        vertex[5], vertex[6], vertex[7]}, 
    {vertex[8], vertex[9], vertex[10], vertex[11], vertex[12], 
    vertex[13], vertex[14], vertex[15]},
                      {vertex[0], vertex[7], vertex[8], vertex[15]},
                      {vertex[7], vertex[15], vertex[14], vertex[6]},
                      {vertex[6], vertex[5], vertex[13], vertex[14]},
                      {vertex[5], vertex[13], vertex[12], vertex[4]},
                      {vertex[3], vertex[4], vertex[12], vertex[11]},
                      {vertex[2], vertex[3], vertex[11], vertex[10]},
                      {vertex[2], vertex[1], vertex[9], vertex[10]},
                      {vertex[0], vertex[8], vertex[9], vertex[1]}};
}

int[] pointsToCp(String p1, String p2, String p3,String p4){
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
