Shader "Unlit/Phon"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Diffuse Material Color", Color) = (1,1,1,1)
        _SpecColor("Specular Material Color", Color) = (1,1,1,1)
        _Shininess("Shininess", Range(0,1)) = 1
        _SpecularStrength("Specular Strength", Range(0,1)) = 0
    }
    SubShader
    {
        tags
        {
            "RenderType" = "Opaque"
        }
        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase"
            } // directional light
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #pragma multi_compile_fog
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"


            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 worldPos : TEXCOORD1;
                float3 normal : NORMAL;
                float2 uv: TEXCOORD0;
                UNITY_FOG_COORDS(2)
                SHADOW_COORDS(5)
            };

            float4 _Color;
            float3 _SpecColor;
            float _Shininess;
            float _SpecularStrength;
            uniform float3 _LightColor0;

            sampler2D _MainTex;
            float3 _MainTex_ST;


            float4 _RimColor;
            float _RimPower;
            float _RimIntensity;

            v2f vert(appdata v)
            {
                v2f o;
                o.uv = v.uv;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                TRANSFER_SHADOW(o);
                UNITY_TRANSFER_FOG(o, o.pos);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed shadow = SHADOW_ATTENUATION(i);
                fixed4 col = tex2D(_MainTex, i.uv);
                float3 l = normalize(_WorldSpaceLightPos0.xyz - i.worldPos * _WorldSpaceLightPos0.w);
                float3 n = normalize(i.normal);
                float3 v = normalize(_WorldSpaceCameraPos - i.worldPos);

                // float3 r = reflect(-l, n);
                float3 h = (l+v)/length(l+v);
                float maxDotNl = max(0, dot(n, l));
                
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT * _Color;
                float3 diffuse = _LightColor0 * _Color * maxDotNl;
                float3 specular = maxDotNl* _LightColor0 * _SpecColor * pow(max(0, dot(n, h)), _Shininess) * _SpecularStrength;
                
               
                col *= float4(ambient + (diffuse + specular) * shadow, 1);
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }

        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}