Shader "Color/Daltonize"
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
            #include "lygia/color/daltonize.hlsl"

            float4 frag (v2f i) : SV_Target
            {
                float4 color = float4(0.0, 0.0, 0.0, 1.0);
                float2 pixel = 1.0/_ScreenParams;
                float2 st = i.uv;
                
                color = tex2D(_MainTex, st);

                int colorblind_type = int(_Time.y) % 11;

                if (colorblind_type == 0)
                    color = daltonizeProtanope(color);
                else if (colorblind_type == 1)
                    color = daltonizeProtanopia(color);
                else if (colorblind_type == 2)
                    color = daltonizeProtanomaly(color);
                else if (colorblind_type == 3)
                    color = daltonizeDeuteranope(color);
                else if (colorblind_type == 4)
                    color = daltonizeDeuteranopia(color);
                else if (colorblind_type == 5)
                    color = daltonizeDeuteranomaly(color);
                else if (colorblind_type == 6)
                    color = daltonizeTritanope(color);
                else if (colorblind_type == 7)
                    color = daltonizeTritanopia(color);
                else if (colorblind_type == 8)
                    color = daltonizeTritanomaly(color);
                else if (colorblind_type == 9)
                    color = daltonizeAchromatopsia(color);
                else if (colorblind_type == 10)
                    color = daltonizeAchromatomaly(color);

                return color;
            }
            ENDCG
        }
    }
}
