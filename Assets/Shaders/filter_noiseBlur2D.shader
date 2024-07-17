Shader "Filters/NoiseBlur"
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

            Texture2D   _MainTex;

            // #define NOISEBLUR_SAMPLER_FNC(POS_UV) tex2D(tex, clamp(POS_UV, float2(0.01, 0.01), float2(0.99, 0.99)))
            #include "lygia/filter/noiseBlur.hlsl"
            #include "lygia/draw/digits.hlsl"

            float4 frag (v2f i) : SV_Target {
                float4 color = float4(0.0, 0.0, 0.0, 1.0);
                float2 pixel = 1.0/_ScreenParams.xy;
                float2 st = i.uv;

                float ix = floor(st.x * 5.0);
                float radius = max(1.0, ix * 4.0);

                color.rgb += noiseBlur(_MainTex, st, pixel, radius).rgb;

                color += digits(st - float2(ix/5.0 + 0.01, 0.01), radius, 0.0);
                color -= step(.99, frac(st.x * 5.0));

                return color;
            }
            ENDCG
        }
    }
}
