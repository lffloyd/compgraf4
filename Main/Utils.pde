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