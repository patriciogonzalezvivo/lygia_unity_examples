Shader "Animation/Sprite"
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

            #include "lygia/math/decimation.hlsl"
            #include "lygia/space/scale.hlsl"
            #include "lygia/sample/sprite.hlsl"
            #include "lygia/animation/spriteLoop.hlsl"

            float4 frag (v2f i) : SV_Target
            {
                float4 color = float4(0.0, 0.0, 0.0, 1.0);
                float2 pixel = 1.0/_ScreenParams;
                float2 st = i.uv;

                float2 grid = float2(10.0, 7.0);

                // st = decimation(st, float2(50., 35.));
                color = tex2D(_MainTex, st);
                // st = scale(st, 0.8);

                // color = sampleSprite(_MainTex, st, grid, 41.);

                // float time = u_time * 6.0;
                float time = mod(_Time.y * 6.0, 48.0);
                if (time < 6.0)
                    color = spriteLoop(_MainTex, st, grid, 0., 2., time);
                else if (time < 12.0)
                    color = spriteLoop(_MainTex, st, grid, 3., 6., time);
                else if (time < 18.0)
                    color = spriteLoop(_MainTex, st, grid, 13., 16., time);
                else if (time < 24.0)
                    color = spriteLoop(_MainTex, st, grid, 23., 26., time);
                else if (time < 30.0)
                    color = spriteLoop(_MainTex, st, grid, 33., 36., time);
                else if (time < 36.0)
                    color = spriteLoop(_MainTex, st, grid, 43., 46., time);
                else if (time < 42.0)
                    color = spriteLoop(_MainTex, st, grid, 50., 53., time);
                else
                    color = spriteLoop(_MainTex, st, grid, 60., 65., time);
                

                return color;
            }
            ENDCG
        }
    }
}
