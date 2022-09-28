Shader "Color/Dither"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

            sampler2D _MainTex;
            #define BLUENOISE_TEXTURE _MainTex
            #define DITHER_FNC ditherVlachos
            // #define DITHER_FNC ditherTriangleNoise
            // #define DITHER_FNC ditherInterleavedGradientNoise
            // #define DITHER_FNC ditherShift
            // #define DITHER_FNC ditherBlueNoise
            #include "lygia/color/dither.hlsl"

            float4 frag (v2f i, float4 fragCoord : SV_POSITION) : SV_Target
            {
                float4 color = float4(0.0, 0.0, 0.0, 1.0);
                float2 pixel = 1.0/_ScreenParams;
                float2 uv = i.uv;
                
                // compress
                const float c0 = 32.0;    
                float2 its = lerp( float2(0.0, 0.0), float2(1.0, 1.0) / c0, uv );
                color.rgb += lerp(float3(its.x, its.x, its.x), float3(its.x, its.y, 0.0), step(uv.y, sin(_Time.y * 0.1)) );

                color.rgb = dither(color.rgb, fragCoord.xy);

                // compress
                color.rgb = floor( color.rgb * 255.0 ) / 255.0;
                color.rgb *= c0;

                return color;
            }
            ENDCG
        }
    }
}
