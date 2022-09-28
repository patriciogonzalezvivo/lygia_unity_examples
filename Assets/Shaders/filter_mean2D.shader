Shader "Filters/Mean"
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

            // #define MEAN_SAMPLER_FNC(POS_UV) tex2D(tex, clamp(POS_UV, float2(0.01, 0.01), float2(0.99, 0.99)))
            #include "lygia/filter/mean.hlsl"

            #include "lygia/draw/digits.hlsl"
            #include "lygia/draw/stroke.hlsl"

            float4 frag (v2f i) : SV_Target {
                float4 color = float4(0.0, 0.0, 0.0, 1.0);
                float2 pixel = 1.0/_ScreenParams.xy;
                float2 st = i.uv;

                float ix = floor(st.x * 5.0);
                float radius = max(0.1, ix * 0.5);
                

                color += mean(_MainTex, st, pixel * radius);

                color -= step(st.y, 0.05) * 0.5;
                color = clamp(color, float4(0., 0., 0., 1.), float4(1., 1., 1., 1.));
                color += digits(st - float2(ix/5.0 + 0.01, 0.01), radius);
                color -= step(.98, frac(st.x * 5.0));

                return color;
            }
            ENDCG
        }
    }
}
