Shader "Unlit/Phon"
{
     Properties
    {
	    _Color("Diffuse Material Color", Color) = (1,1,1,1)
	    _SpecColor("Specular Material Color", Color) = (1,1,1,1)
	    _Shininess("Shininess",  Range(1,2000)) = 10      
		_SpecularStrength("Specular Strength", Range(0,1)) = 1
    }
    SubShader
    {
        tags{"RenderType" = "Opaque" }
        Pass
        { 
            Tags { "LightMode" = "ForwardBase" } // directional light
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;                
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 worldPos : Texcoord0;
                float3 normal : NORMAL;
                SHADOW_COORDS(5)
            };

            float4 _Color;
            float3 _SpecColor;
            float _Shininess;            
			float _SpecularStrength;
            uniform float3 _LightColor0;


            float4 _RimColor;
            float _RimPower;
            float _RimIntensity;
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed shadow = SHADOW_ATTENUATION(i);
          
                float3 l = normalize(_WorldSpaceLightPos0.xyz - i.worldPos * _WorldSpaceLightPos0.w);
                float3 n = normalize(i.normal);
                float3 v = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 r = reflect(-l, n);
                float3 h = (l+v)/length(l+v);
                float dotNl = dot(n, l);
                float maxDotNl = max(0,dotNl);
                float3 ambient =  UNITY_LIGHTMODEL_AMBIENT * _Color;
                float3 diffuse = _LightColor0 * _Color * maxDotNl;
                float3 specular = maxDotNl* _LightColor0 * _SpecColor * pow(max(0, dot(r, v)), _Shininess) * _SpecularStrength;
                
                return float4(ambient+ (diffuse + specular)*shadow,1);
            }
            ENDCG
        }
        Pass
        {
	        Tags { "LightMode" = "ForwardAdd"  }// not directional light
	        Blend One One // additive blending 
	        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag            
            #pragma multi_compile_fwdadd
                 
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;                
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 worldPos : Texcoord0;
                float3 normal : NORMAL;
                SHADOW_COORDS(5)
            };
                float4 _Color;
                float3 _SpecColor;
                float _Shininess;
			    float _SpecularStrength;

                uniform float3 _LightColor0;
                
                v2f vert(appdata v)
                {
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.worldPos = mul(unity_ObjectToWorld, v.vertex);                    
                    o.normal = UnityObjectToWorldNormal(v.normal);
                    TRANSFER_SHADOW(o);
                    return o;
                }
                fixed4 frag(v2f i) : SV_Target
                {
                    fixed shadow = SHADOW_ATTENUATION(i);
                    float attenuation = 1.0 / length(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
                    
                    float3 l = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz * _WorldSpaceLightPos0.w);
                    float3 n = normalize(i.normal);
                    float3 v = normalize(_WorldSpaceCameraPos - i.worldPos.xyz);
                    float3 r = reflect(-l, n);
                    float3 h = (l+v)/length(l+v);
                    float dotNl = dot(n, l);
                    float maxDotNl = max(0,dotNl);
                    float3 diffuse = maxDotNl*attenuation*_LightColor0 * _Color.xyz;
                   
                    float3 specular = maxDotNl*attenuation* _LightColor0 * _SpecColor.xyz * pow(max(0, dot(r, v)), _Shininess) * _SpecularStrength;
                     //float3    = attenuation* GetTranslucence(n,v,l) * _LightColor0.xyz;                     
                    return float4((diffuse + specular)*shadow,1);
                }
                ENDCG
        }
   UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"   
    }
}
