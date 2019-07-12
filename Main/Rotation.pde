class Rotation {
    float angle;
    PVector rotationAxis;
    Quaternion q, qConjugate;

    Rotation(float ang, PVector axis) {
        angle = ang;
        axis.normalize();
        rotationAxis = axis;
        q = new Quaternion(cos(ang/2), rotationAxis.x*sin(ang/2), 
                        rotationAxis.y*sin(ang/2), rotationAxis.z*sin(ang/2));
        qConjugate = q.conjugate();
    }

    float[] rotate(float[] point) {
        Quaternion p = new Quaternion(0., point[0], point[1], point[2]);
        Quaternion rQp = q.crossProduct(p.crossProduct(qConjugate)); 
        return new float[]{rQp.p1, rQp.p2, rQp.p3};
    }
}