Shader "Generative/cNoise"
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

            #include "lygia/generative/cnoise.hlsl"

            float4 frag (v2f i) : SV_Target
            {
                float4 color = float4(0.0, 0.0, 0.0, 1.0);
                float2 pixel = 1.0/_ScreenParams;
                float2 st = i.uv;
                
                float d2 = cnoise(float2(st * 5. + _Time.y)) * 0.5 + 0.5;
                float d3 = cnoise(float3(st * 5., _Time.y)) * 0.5 + 0.5;
                
                color += lerp(d2, d3, step(0.5, st.x));

                return color;
            }
            ENDCG
        }
    }
}
