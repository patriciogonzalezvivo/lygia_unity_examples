Shader "Lighting/RayMarching"
{
    Properties
    {
        _CameraTarget("Camera Target", Vector) = (0, 0, 0, 1)
    }
    SubShader
    {
        // No culling or depth
        Cull Off
        Lighting Off
        Blend One OneMinusSrcAlpha

        Pass
        {
            Tags{ "LIGHTMODE" = "ForwardBase" "RenderType" = "Opaque" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include <UnityLightingCommon.cginc>

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 clipSpacePos : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.clipSpacePos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float3 _CameraTarget;

            #define RESOLUTION _ScreenParams.xy
            #define CAMERA_POSITION _WorldSpaceCameraPos
            #define SCENE_CUBEMAP   _Cube
            #define LIGHT_DIRECTION _WorldSpaceLightPos0.xyz
            #define LIGHT_COLOR     _LightColor0.rgb

            // #include "lygia/lighting/atmosphere.hlsl"

            #define RAYMARCH_SAMPLES 100
            #define RAYMARCH_MULTISAMPLE 4
            #define RAYMARCH_BACKGROUND ( float3(0.7, 0.9, 1.0) + ray.y * 0.8 )
            // #define RAYMARCH_BACKGROUND atmosphere(normal, normalize(u_light))
            #define RAYMARCH_AMBIENT    float3(0.7, 0.9, 1.0)
            // #define RAYMARCH_AMBIENT atmosphere(normal, normalize(u_light))
            // #define RAYMARCH_MATERIAL_MAP
            
            #include "lygia/lighting/raymarch.hlsl"

            #include "lygia/space/ratio.hlsl"
            #include "lygia/sdf.hlsl"

            float checkBoard(float2 uv, float2 _scale) {
                uv = floor(frac(uv * _scale) * 2.0);
                return min(1.0, uv.x + uv.y) - (uv.x * uv.y);
            }

            float4 raymarchMap( in float3 pos ) {
                float4 res = float4(1.0, 1.0, 1.0, 1.0);

                float check = checkBoard(pos.xz, float2(1.0, 1.0));
                res = opUnion( res, float4( 0.5 + float3(check, check, check) * 0.5, planeSDF(pos) ) );

                res = opUnion( res, float4( 1.0, 1.0, 1.0, sphereSDF(    pos-float3( 0.0, 0.60, 0.0), 0.5 ) ) );
                res = opUnion( res, float4( 0.0, 1.0, 1.0, boxSDF(       pos-float3( 2.0, 0.5, 0.0), float3(0.4, 0.4, 0.4) ) ) );
                res = opUnion( res, float4( 0.3, 0.3, 1.0, torusSDF(     pos-float3( 0.0, 0.5, 2.0), float2(0.4,0.1) ) ) );
                res = opUnion( res, float4( 0.3, 0.1, 0.3, capsuleSDF(   pos,float3(-2.3, 0.4,-0.2), float3(-1.6,0.75,0.2), 0.2 ) ) );
                res = opUnion( res, float4( 0.5, 0.3, 0.4, triPrismSDF(  pos-float3(-2.0, 0.50,-2.0), float2(0.5,0.1) ) ) );
                res = opUnion( res, float4( 0.2, 0.2, 0.8, cylinderSDF(  pos-float3( 2.0, 0.50,-2.0), float2(0.2,0.4) ) ) );
                res = opUnion( res, float4( 0.7, 0.5, 0.2, coneSDF(      pos-float3( 0.0, 0.75,-2.0), float3(0.8,0.6,0.6) ) ) );
                res = opUnion( res, float4( 0.4, 0.2, 0.9, hexPrismSDF(  pos-float3(-2.0, 0.60, 2.0), float2(0.5,0.1) ) ) );
                res = opUnion( res, float4( 0.1, 0.3, 0.6, pyramidSDF(   pos-float3( 2.0, 0.10, 2.0), 1.0 ) ) );
                    
                return res;
            }

            float4 frag (v2f i) : SV_Target
            {
                float2 pixel = 1.0/RESOLUTION;
                float2 st = i.clipSpacePos * pixel;
                float2 uv = ratio(st, RESOLUTION);

                float3 color = raymarch(CAMERA_POSITION, _CameraTarget, uv);

                return float4(color, 1);
            }
            ENDCG
        }
    }
}
