Shader "Animation/Easing"
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

            #include "lygia/draw/circle.hlsl"
            #include "lygia/space/ratio.hlsl"
            #include "lygia/space/scale.hlsl"
            #include "lygia/animation/easing.hlsl"

            float4 frag (v2f i) : SV_Target
            {
                float4 color = float4(0.0, 0.0, 0.0, 1.0);
                float2 pixel = 1.0/_ScreenParams;
                float2 st = i.uv;
                float pct = frac(_Time.y * 0.25);
                st = scale(st, 1.1);

                float rows = 11.0;
                float row = floor(st.y * rows);

                st.x += 0.5;

                if (row == 0)
                    pct = pct < 0.5 ? linearOut(pct * 2.0) : linearIn( (1.0-pct) * 2.0 );
                else if (row == 1)
                    pct = pct < 0.5 ? exponentialOut(pct * 2.0) : exponentialIn( (1.0-pct) * 2.0 );
                else if (row == 2)
                    pct = pct < 0.5 ? quinticOut(pct * 2.0) : quinticIn( (1.0-pct) * 2.0 );
                else if (row == 3)
                    pct = pct < 0.5 ? quarticOut(pct * 2.0) : quarticIn( (1.0-pct) * 2.0 );
                else if (row == 4)
                    pct = pct < 0.5 ? cubicOut(pct * 2.0) : cubicIn( (1.0-pct) * 2.0 );
                else if (row == 5)
                    pct = pct < 0.5 ? circularOut(pct * 2.0) : circularIn( (1.0-pct) * 2.0 );
                else if (row == 6)
                    pct = pct < 0.5 ? quadraticOut(pct * 2.0) : quadraticIn( (1.0-pct) * 2.0 );
                else if (row == 7)
                    pct = pct < 0.5 ? sineOut(pct * 2.0) : sineIn( (1.0-pct) * 2.0 );
                else if (row == 8)
                    pct = pct < 0.5 ? elasticOut(pct * 2.0) : elasticIn( (1.0-pct) * 2.0 );
                else if (row == 9)
                    pct = pct < 0.5 ? bounceOut(pct * 2.0) : bounceIn( (1.0-pct) * 2.0 );
                else if (row == 10)
                    pct = pct < 0.5 ? backOut(pct * 2.0) : backIn( (1.0-pct) * 2.0 );
                
                st.x -= pct;

                st.y = frac(st.y * rows);
                st = ratio(st, float2(rows, 1.0));

                color += circle(st, 0.2) * step(0.0, row) * step(row, 10.);

                return color;
            }
            ENDCG
        }
    }
}

