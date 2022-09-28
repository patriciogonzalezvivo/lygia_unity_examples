Shader "Generative/Noised"
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

            #include "lygia/generative/noised.hlsl"

            float4 frag (v2f i) : SV_Target
            {
                float4 color = float4(0.0, 0.0, 0.0, 1.0);
                float2 pixel = 1.0/_ScreenParams;
                float2 st = i.uv;

                float2 d2 = noised(float2(st * 5. + _Time.y)).yz * 0.5 + 0.5;
                float3 d3 = noised(float3(st * 5., _Time.y)).yzw * 0.5 + 0.5;
                
                color.rgb += lerp(float3(d2,0.0), d3, step(0.5, st.x));
                
                return color;
            }
            ENDCG
        }
    }
}
