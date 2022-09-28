Shader "Color/Palettes"
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

            #include "lygia/color/palette/chroma.hlsl"
            #include "lygia/color/palette/fire.hlsl"
            #include "lygia/color/palette/heatmap.hlsl"
            #include "lygia/color/palette/spectrum.hlsl"

            float4 frag (v2f i) : SV_Target
            {
                float4 color = float4(0.0, 0.0, 0.0, 1.0);
                float2 pixel = 1.0/_ScreenParams;
                float2 st = i.uv;
                
                float pct = st.x;

                if (st.y < 0.25) 
                    color.rgb = chroma(pct);
                else if (st.y < 0.5)
                    color.rgb = spectrum(pct);
                else if (st.y < 0.75)
                    color.rgb = heatmap(pct);
                else
                    color.rgb = fire(pct);

                return color;
            }
            ENDCG
        }
    }
}
