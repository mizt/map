#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"

#include <metal_stdlib>
using namespace metal;

#define vec2 float2
#define vec3 float3
#define vec4 float4
#define ivec2 int2
#define ivec3 int3
#define ivec4 int4
#define mat2 float2x2
#define mat3 float3x3
#define mat4 float4x4

#define mod fmod
#define atan 6.28318530718-atan2

constexpr sampler _nearest(coord::normalized, address::clamp_to_edge, filter::nearest);
constexpr sampler _linear(coord::normalized, address::clamp_to_edge, filter::linear);

struct VertInOut {
    float4 pos[[position]];
    float2 texcoord[[user(texturecoord)]];
};

struct FragmentShaderArguments {
    device float *time[[id(0)]];
    device float2 *resolution[[id(1)]];
    device float2 *mouse[[id(2)]];
    texture2d<float> o0[[id(3)]];
    texture2d<float> o1[[id(4)]];
    texture2d<float> o2[[id(5)]];
    texture2d<float> o3[[id(6)]];
    texture2d<float> s0[[id(7)]];
    texture2d<float> s1[[id(8)]];
    texture2d<float> s2[[id(9)]];
    texture2d<float> s3[[id(10)]];
};

vertex VertInOut vertexShader(constant float4 *pos[[buffer(0)]],constant packed_float2  *texcoord[[buffer(1)]],uint vid[[vertex_id]]) {
    VertInOut outVert;
    outVert.pos = pos[vid];
    outVert.texcoord = float2(texcoord[vid][0],1-texcoord[vid][1]);
    return outVert;
}

fragment float4 fragmentShader(VertInOut inFrag[[stage_in]],constant FragmentShaderArguments &args[[buffer(0)]]) {
    
    float time = args.time[0];
    float2 resolution = args.resolution[0];
    float2 mouse = args.mouse[0];
    float2 gl_FragCoord = inFrag.pos.xy;
    vec4 c = vec4(1,0,0,1);
    vec2 st = gl_FragCoord.xy/resolution.xy;   
        
    float wet = 1.0; 
    float dry = 1.0-wet; 
    
    float4  map = args.s1.sample(_nearest,inFrag.texcoord);    
    float x = ((((int(map.a*255.0))<<8|(int(map.b*255.0)))-32767.)*0.25)/(resolution.x-1.0);
    float y = ((((int(map.g*255.0))<<8|(int(map.r*255.0)))-32767.)*0.25)/(resolution.y-1.0);
    return float4(args.s0.sample(_linear,vec2(inFrag.texcoord.x*dry+x*wet,inFrag.texcoord.y*dry+y*wet)));
    
}

#pragma clang diagnostic pop
