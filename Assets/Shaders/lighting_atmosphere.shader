Shader "Lighting/Atmosphere"
{
    Properties
    {
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            #ifndef PROJECTION_MODE
            #define PROJECTION_MODE 1
            #endif
            #include "lygia/space/fisheye2xyz.hlsl"
            #include "lygia/space/equirect2xyz.hlsl"

            // #define ATMOSPHERE_FAST
            #include "lygia/lighting/atmosphere.hlsl"

            #ifndef TONEMAP_FNC
            #define TONEMAP_FNC tonemapLinear
            // #define TONEMAP_FNC tonemapDebug
            // #define TONEMAP_FNC tonemapAces
            // #define TONEMAP_FNC tonemapFilmic
            // #define TONEMAP_FNC tonemapReinhard
            // #define TONEMAP_FNC tonemapReinhardJodie
            // #define TONEMAP_FNC tonemapUncharted
            // #define TONEMAP_FNC tonemapUncharted2
            // #define TONEMAP_FNC tonemapUnreal
            #endif
            #include "lygia/color/tonemap.hlsl"

            float3 cart2viewSpace(float2 uv) {
                float HalfFovV = PI / 6.0;
                float sc = cos(HalfFovV) / sin(HalfFovV);
                float2 scale = float2(sc, sc);

                float3 dir = float3(0.0, 0.0, 0.0);
                dir.z = 0.01;
                dir.xy = (uv * 2.0 - 1.0) / scale * dir.z;
                dir = normalize(dir);
                dir.xz /= sqrt(1.0 - dir.y * dir.y);
                dir.xz *= sqrt(1.0 - dir.y * dir.y);
                return dir;
            }


            float4 frag (v2f i) : SV_Target
            {
                float4 color = float4(0.0, 0.0, 0.0, 1.0);
                float2 pixel = 1.0/_ScreenParams;
                float2 st = i.uv;

                float2 sun = float2(cos(_Time.y) * 0.5 + 0.5, 0.5);

            #if PROJECTION_MODE == 0
                float3 eye_dir = equirect2xyz(st);
                float3 sun_dir = equirect2xyz(sun);
            #elif PROJECTION_MODE == 1
                float3 eye_dir = fisheye2xyz(st);
                float3 sun_dir = fisheye2xyz(sun);
            #else
                float3 eye_dir = cart2viewSpace(st);
                float3 sun_dir = cart2viewSpace(sun);
            #endif

                color.rgb = atmosphere(eye_dir, sun_dir);
                // color = tonemap(color);

                return color;
            }
            ENDCG
        }
    }
}
