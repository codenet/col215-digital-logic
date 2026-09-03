int float_equal(float x, float y) {
    return fabs(x - y) < FLT_EPSILON;
}
