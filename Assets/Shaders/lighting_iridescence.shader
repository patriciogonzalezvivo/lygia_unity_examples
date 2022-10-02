Shader "Lighting/Iridescence"
{
    Properties
    {
        _Thickness ("Thickness", Range(0.001,1.0) ) = 0.05
    }
    SubShader
    {
        // ZWrite Off 
        // ZTest Always

        Cull Off
        Lighting Off
        Blend One OneMinusSrcAlpha

        Pass
        {
            Tags{ "LIGHTMODE" = "ForwardBase" "RenderType" = "Opaque" }

            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            struct v2f
            {
                float4 vertex : TEXCOORD2;
                float4 pos : SV_POSITION;
                float4 color : COLOR;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
                SHADOW_COORDS(1)
            };

            float _Thickness;

            v2f vert (appdata_full v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.vertex = v.vertex;//mul(unity_ObjectToWorld, v.vertex);
                o.color = v.color;
                o.normal = v.normal;//UnityObjectToWorldNormal(v.normal);
                o.texcoord = v.texcoord;
                TRANSFER_SHADOW(o)
                return o;
            }


            #include "lygia/lighting/material.hlsl"
            #include "lygia/lighting/material/new.hlsl"
            
            // #define SCENE_CUBEMAP _Cube
            #include "lygia/lighting/pbr.hlsl"
            #include "lygia/color/space/linear2gamma.hlsl"

            #include "lygia/lighting/iridescence.hlsl"

            float4 frag (v2f i) : SV_Target
            {
                float4 color = float4(0.0, 0.0, 0.0, 1.0);
                float2 pixel = 1.0/_ScreenParams;
                float2 st = i.texcoord;

                float3 V = normalize(_WorldSpaceCameraPos.xyz - i.vertex);
                float3 N = normalize(i.normal);

                float cosA = 1.0-dot(N, V);

                Material mat = materialNew();
                mat.albedo.rgb = i.color.rgb * 0.2;
                mat.position = i.vertex.xyz;
                mat.normal = i.normal;
                mat.roughness = 0.001;
                mat.metallic = 0.1;
                mat.shadow = SHADOW_ATTENUATION(i);
                color = pbr(mat);

                color.rgb += iridescence(cosA, _Thickness);

                return color;
            }
            ENDCG
        }
        
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }

}
