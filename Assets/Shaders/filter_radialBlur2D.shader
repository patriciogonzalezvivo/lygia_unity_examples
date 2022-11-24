Shader "Filters/RadialBlur"
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

            #include "lygia/sample/clamp2edge.hlsl"
            #define RADIALBLUR_SAMPLER_FNC(TEX, UV) sampleClamp2edge(TEX, UV)
            #include "lygia/filter/radialBlur.hlsl"

            #include "lygia/math/decimation.hlsl"
            #include "lygia/draw/digits.hlsl"

            float4 frag (v2f i) : SV_Target {
                float4 color = float4(0.0, 0.0, 0.0, 1.0);
                float2 pixel = 1.0/_ScreenParams.xy;
                float2 st = i.uv;

                float2 center = float2(0.5, 0.5);

                float cols = 5.0;

                float x = st.x * cols;
                float xi = floor(x);
                float xf = frac(x);
                float strength = max(1.0, xi * 10.0);

                float2 dir = st - center;
                float angle = atan2(dir.y, dir.x);
                angle += _Time.y;
                dir = float2(cos(angle), sin(angle));

                color += radialBlur(_MainTex, st, pixel * dir, strength);

                float2 uv = float2(frac(st.x * cols), st.y * cols) - 0.05;
                uv *= 0.3;

                color += digits(uv, strength, 0.0);
                color -= step(.99, xf);

                return color;
            }
            ENDCG
        }
    }
}
