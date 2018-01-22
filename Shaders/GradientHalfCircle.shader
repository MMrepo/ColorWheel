kernel vec4 circularGradientKernel(__color startColor, __color endColor, vec2 center, float radius) {
    vec2 point = destCoord() - center;
    float pi = 3.14159265358979323846;
    float pi2 = pi * 2.0;
    float distanceSqr = point.x * point.x + point.y * point.y;
    float radiusSqr = radius * radius;
    float angle = mod(atan(point.y, point.x) + pi/2.0, pi);
    return distanceSqr < radiusSqr ? mix(startColor, endColor, angle/pi) : vec4(0.0, 0.0, 0.0, 1.0);
}


