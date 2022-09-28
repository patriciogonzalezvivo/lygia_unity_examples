Shader "Color/Mix"
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

            // the texture needs to be the mixbox_lut.png
            sampler2D _MainTex;
            #define MIXBOX_LUT _MainTex
            #include "lygia/color/mixBox.hlsl"

            #include "lygia/math/mix.hlsl"
            #include "lygia/color/mixOklab.hlsl"


            float4 frag (v2f i) : SV_Target
            {
                float4 color = float4(0.0, 0.0, 0.0, 1.0);
                float2 pixel = 1.0/_ScreenParams;
                float2 st = i.uv;
                
                float3 A = float3(0.9333, 0.9451, 0.0588);
                float3 B = float3(0.0824, 0.1686, 0.5529);
                float pct = st.x;

                if (st.y < 0.33) 
                    color.rgb = mix(A, B, pct);
                else if (st.y < 0.66)
                    color.rgb = mixOklab(A, B, pct);
                else
                    color.rgb = mixBox(A, B, st.x);

                return color;
            }
            ENDCG
        }
    }
}
