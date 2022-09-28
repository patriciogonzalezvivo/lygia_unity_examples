Shader "Filters/Sharpen"
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

            // #define SHARPEN_SAMPLER_FNC(POS_UV) tex2D(tex, clamp(POS_UV, float2(0.01, 0.01), float2(0.99, 0.99)))
            #include "lygia/filter/sharpen.hlsl"

            float4 frag (v2f i) : SV_Target {
                float4 color = float4(0.0, 0.0, 0.0, 1.0);
                float2 pixel = 1.0/_ScreenParams.xy;
                float2 st = i.uv;

                float radius = frac(st.x * 3.0) * 5.0;

                if (st.x < .33)
                    color.rgb = sharpenAdaptive(_MainTex, st, pixel * max(1.0, radius));

                else if (st.x < .66)
                    color.rgb = sharpenContrastAdaptive(_MainTex, st, pixel * max(1.0, radius));

                else 
                    color.rgb = sharpenFast(_MainTex, st, pixel);

                    
                color -= step(.95, frac(radius) ) * 0.1;
                color -= step(.98, frac(st.x * 3.0));

                return color;
            }
            ENDCG
        }
    }
}
