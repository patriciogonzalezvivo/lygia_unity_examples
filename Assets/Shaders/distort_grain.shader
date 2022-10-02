Shader "Distort/Grain"
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

            sampler2D   _MainTex;

            // #define BARREL_TYPE float4
            // #define BARREL_SAMPLER_FNC(UV) tex2D(tex, clamp(UV, 0.01, 0.99))
            // #include "lygia/distort/barrel.hlsl"

            // #define CHROMAAB_SAMPLER_FNC(POS_UV) barrel(tex, POS_UV, 0.05)
            #define CHROMAAB_TYPE float4
            #include "lygia/distort/grain.hlsl"
            #include "lygia/draw/digits.hlsl"

            float4 frag (v2f i) : SV_Target {
                float4 color = float4(0.0, 0.0, 0.0, 1.0);
                float2 pixel = 1.0/_ScreenParams;
                float2 st = i.uv;

                color.rgb = grain(_MainTex, st, _ScreenParams, _Time.y, 1.0);

                return color;
            }
            ENDCG
        }
    }
}
