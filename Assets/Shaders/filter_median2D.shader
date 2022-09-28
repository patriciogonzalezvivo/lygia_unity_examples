Shader "Filters/Median"
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

            // #define MEDIAN_SAMPLER_FNC(POS_UV) tex2D(tex, clamp(POS_UV, float2(0.01, 0.01), float2(0.99, 0.99)))
            // #include "lygia/filter/median.hlsl"

            #include "lygia/draw/digits.hlsl"
            #include "lygia/draw/stroke.hlsl"

            float4 frag (v2f i) : SV_Target {
                float4 color = float4(0.0, 0.0, 0.0, 1.0);
                float2 pixel = 1.0/_ScreenParams.xy;
                float2 st = i.uv;

                float radius = frac(st.x * 2.0) * 4.0;

                // color.rgb = lerp(   median3(_MainTex, st, pixel * max(1., floor(radius))).rgb,
                //                     median5(_MainTex, st, pixel * max(1., floor(radius))).rgb, 
                //                     step(.5, st.x));

                color.rgb += digits(st - float2(0.01 + 0.5 * step(.5, st.x), 0.01), lerp(3., 5., step(.5, st.x)), 0.0);
                color.rgb -= stroke(st.x, .5, pixel.x * 2.0);

                color -= step(1.0 - pixel.x * 5., frac(radius)) * 0.1;

                return color;
            }
            ENDCG
        }
    }
}
