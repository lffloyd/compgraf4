class Quaternion {
    float p0, p1, p2, p3;

    Quaternion() {
        p0 = 0.; p1 = 0.; p2 = 0.; p3 = 0.;
    }

    Quaternion(float a, float b, float c, float d) {
        p0 = a; p1 = b; p2 = c; p3 = d;
    }
    
    float norm() {
        return sqrt(p0*p0 + p1*p1 + p2*p2 + p3*p3);
    }

    Quaternion normalize() {
        float pNorm = this.norm();
        p0 *= pNorm; p1 *= pNorm; p2 *= pNorm; p3 *= pNorm;
        return this;
    }

    Quaternion conjugate() {
        return new Quaternion(this.p0, -this.p1, -this.p2, -this.p3);
    }

    Quaternion crossProduct(Quaternion b) {
        Quaternion a = this;
        float r0 = a.p0*b.p0 - a.p1*b.p1 - a.p2*b.p2 - a.p3*b.p3;
        float r1 = a.p0*b.p1 + a.p1*b.p0 + a.p2*b.p3 - a.p3*b.p2;
        float r2 = a.p0*b.p2 - a.p1*b.p3 + a.p2*b.p0 + a.p3*b.p1;
        float r3 = a.p0*b.p3 + a.p1*b.p2 - a.p2*b.p1 + a.p3*b.p0;
        return new Quaternion(r0, r1, r2, r3);
    }

    Quaternion scalarProduct(float scalar) {
        p0 *= scalar; p1 *= scalar; p2 *= scalar; p3 *= scalar;
        return this;
    }

    PVector to3DVector() {
        return new PVector(p1, p2, p3);
    }
}