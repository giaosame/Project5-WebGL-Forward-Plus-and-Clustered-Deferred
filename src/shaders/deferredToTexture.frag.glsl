#version 100
#extension GL_EXT_draw_buffers: enable
precision highp float;
uniform sampler2D u_colmap;
uniform sampler2D u_normap;

varying vec3 v_position;
varying vec3 v_normal;
varying vec2 v_uv;

vec3 applyNormalMap(vec3 geomnor, vec3 normap) {
    normap = normap * 2.0 - 1.0;
    vec3 up = normalize(vec3(0.001, 1, 0.001));
    vec3 surftan = normalize(cross(geomnor, up));
    vec3 surfbinor = cross(geomnor, surftan);
    return normap.y * surftan + normap.x * surfbinor + normap.z * geomnor;
}

vec2 compressNormal(vec3 normal)
{
    return vec2(normal.x / (normal.z + 1.0), normal.y / (normal.z + 1.0));
}

void main() {
    vec3 norm = applyNormalMap(v_normal, vec3(texture2D(u_normap, v_uv)));
    vec3 col = vec3(texture2D(u_colmap, v_uv));

    // Populate your g-buffer
    norm = normalize(norm);

    // Unoptimized
    // // color
    // gl_FragData[0] = vec4(col.x, col.y, col.z, 0.0);
    // // normal
    // gl_FragData[1] = vec4(norm.x, norm.y, norm.z, 0.0);
    // // position
    // gl_FragData[2] = vec4(v_position.x, v_position.y, v_position.z, 0.0);

    // Optimized
    // color 
    gl_FragData[0] = vec4(col.x, col.y, col.z, v_position.z);
    // normal + position
    vec2 compressedNorm = compressNormal(norm);
    gl_FragData[1] = vec4(compressedNorm.x, compressedNorm.y, v_position.x, v_position.y);
}