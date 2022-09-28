Shader "Color/Luma&Luminance"
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
            #include "lygia/color/luma.hlsl"
            #include "lygia/color/luminance.hlsl"
            #include "lygia/color/space.hlsl"

            float4 frag (v2f i) : SV_Target
            {
                float4 color = float4(0.0, 0.0, 0.0, 1.0);
                float2 pixel = 1.0/_ScreenParams;
                float2 st = i.uv;
                
                color = tex2D(_MainTex, st);

                color = gamma2linear(color);

                if (st.y < 0.5) {
                    float l = luma(color);
                    color.rgb = float3(l, l, l);
                }
                else {
                    float l = luminance(color);
                    color.rgb = float3(l, l, l);
                }

                color = linear2gamma(color);

                return color;
            }
            ENDCG
        }
    }
}
