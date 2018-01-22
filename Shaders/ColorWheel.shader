#define pi  3.14159265358979323846
#define pi2 6.283185307179585

#define TWO_PI 6.28318530718

//  Function from Iñigo Quiles
//  https://www.shadertoy.com/view/MsS3Wc
vec3 hsb2rgb( in vec3 c ){
    vec3 rgb = clamp(abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),
                             6.0)-3.0)-1.0,
                     0.0,
                     1.0 );
    rgb = rgb*rgb*(3.0-2.0*rgb);
    return c.z * mix( vec3(1.0), rgb, c.y);
}

kernel vec4 circularGradientKernel(vec2 center, float radius) {
    vec2 point = destCoord() - center;
    float distanceSqr = point.x * point.x + point.y * point.y;
    float radiusSqr = radius * radius;
    float angle = mod(atan(point.y, point.x) * -1.0 + pi2, pi2);
    vec3 color = hsb2rgb(vec3((angle/pi2),1.0,1.0));
    return vec4(color,1.0);
}


