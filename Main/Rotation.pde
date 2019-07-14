class Rotation {
    float angle;
    PVector rotationAxis;
    Quaternion q, qConjugate;

    Rotation(float ang, PVector axis) {
        float tempAngle = ang/57.2958;
        angle = tempAngle/2.0;
        axis.normalize();
        rotationAxis = axis;
        q = new Quaternion(cos(angle), rotationAxis.x*sin(angle), 
                        rotationAxis.y*sin(angle), rotationAxis.z*sin(angle));
        qConjugate = q.conjugate();

        println("orig. angle: " + ang);
        println("angle: "+angle);
        println("axis: "+axis);
    }

    float[] rotate(float[] point) {
        Quaternion p = new Quaternion(0., point[0], point[1], point[2]);
        Quaternion rQp = q.crossProduct(p.crossProduct(qConjugate)); 
        return new float[]{rQp.p1, rQp.p2, rQp.p3};
    }
}