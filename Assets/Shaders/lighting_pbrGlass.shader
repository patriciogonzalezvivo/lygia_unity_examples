Shader "Lighting/glass"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _Cube ("Cubemap", CUBE) = "" {}
        _Roughtness ("Roughtness", Range(0.001,1.0) ) = 0.05
        _Metallic ("Metallic", Range(0.001,1.0) ) = 0.05
        _Ior ("Ior", Vector ) = (1.524, 1.517, 1.515)
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

            sampler2D _MainTex;
            samplerCUBE _Cube;

            float   _Roughtness;
            float   _Metallic;
            float3  _Ior;

            v2f vert (appdata_full v)
            {
                v2f o;
                o.vertex = v.vertex;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.color = v.color;
                o.normal = v.normal;
                o.texcoord = v.texcoord;
                TRANSFER_SHADOW(o)
                return o;
            }

            #include "lygia/lighting/material.hlsl"
            #include "lygia/lighting/material/new.hlsl"
            
            #define SCENE_CUBEMAP _Cube
            #define LIGHT_DIRECTION _WorldSpaceLightPos0.xyz

            // #include "lygia/lighting/atmosphere.hlsl"
            // #define ENVMAP_FNC(NORM, ROUGHNESS, METALLIC) atmosphere(NORM, normalize(_WorldSpaceLightPos0.xyz))

            #include "lygia/lighting/pbrGlass.hlsl"
            #include "lygia/color/space/linear2gamma.hlsl"

            float4 frag (v2f i) : SV_Target
            {
                float4 color = float4(0.0, 0.0, 0.0, 1.0);
                float2 pixel = 1.0/_ScreenParams;
                float2 st = i.texcoord;

                float4 tex = tex2D(_MainTex, st);

                Material mat = materialNew();
                mat.albedo.rgb = lerp(i.color, tex, tex.a);
                mat.position = i.vertex.xyz;
                mat.normal = i.normal;
                mat.ior = _Ior;
                mat.roughness = _Roughtness;
                mat.metallic = _Metallic;
                // mat.shadow = SHADOW_ATTENUATION(i);

                color = pbrGlass(mat);
                color = linear2gamma(color);

                return color;
            }
            ENDCG
        }
        
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }

}
