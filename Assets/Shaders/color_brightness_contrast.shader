Shader "Color/Brightness&Contrast"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Brightness ("Brightness", Range(-1, 1)) = 0.0
        _Contrast ("Contrast", Range(0, 2)) = 1.0
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
            float _Brightness;
            float _Contrast;
            #include "lygia/color/brightnessContrast.hlsl"
            #include "lygia/color/brightnessMatrix.hlsl"
            #include "lygia/color/contrast.hlsl"
            #include "lygia/color/contrastMatrix.hlsl"

            float4 frag (v2f i) : SV_Target
            {
                float4 color = float4(0.0, 0.0, 0.0, 1.0);
                float2 pixel = 1.0/_ScreenParams;
                float2 st = i.uv;
                
                color = tex2D(_MainTex, st);

                if (st.y < 0.33) {
                    color = brightnessContrast(color, _Brightness, _Contrast);
                }
                if (st.y < 0.66) {
                    float4x4 bc = mul(brightnessMatrix(_Brightness), contrastMatrix(_Contrast));
                    color = mul(bc, color);
                }
                else {
                    color = contrast(color, _Contrast);
                    color = mul(brightnessMatrix(_Brightness), color);
                }

                return color;
            }
            ENDCG
        }
    }
}
