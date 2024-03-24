Shader "Unlit/PathShader"
{
    Properties
    {
        _Color("Diffuse Material Color", Color) = (1,1,1,1)
        _SpecColor("Specular Material Color", Color) = (1,1,1,1)
        _Shininess("Shininess", Range(1,2000)) = 10
        _SpecularStrength("Specular Strength", Range(0,1)) = 1

        _SubsurfaceDistortion("Subsurface Distortion", Float) = -0.2
        _SubsurfacePower("Subsurface Power", Float) = 2
        _SubsurfaceScale("Subsurface Scale", Float) = 1

        [MaterialToggle] _isToggled("use translucency", Int) = 0
        [MaterialToggle] _isBlinn("use blinn", Int) = 0
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
            }
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
                float3 normal : Texcoord1;
                SHADOW_COORDS(5)
            };


            uniform float4 _LightColor0;

            float3 ambientLight(float3 baseColor)
            {
                return UNITY_LIGHTMODEL_AMBIENT * baseColor;
            }

            float4 diffuseLight(float3 n, float3 l, float4 baseColor, float attenuation)
            {
                float dotNl = dot(n, l);
                float maxDotNl = max(0, dotNl);
                return _LightColor0 * baseColor * maxDotNl * attenuation;
            }

            float3 specularHighLight(float3 n, float3 l, float3 v, float _Shininess, float _SpecularStrength,
  float3 _SpecColor, float attenuation)
            {
                float3 r = reflect(-l, n);
                float dotNl = dot(n, l);
                float maxDotNl = max(0, dotNl);
                return maxDotNl * attenuation * _LightColor0 * _SpecColor.xyz * pow(max(0, dot(r, v)), _Shininess) *
                    _SpecularStrength;
            }

            float3 specularBlinn(float3 n, float3 l, float3 v, float _Shininess, float _SpecularStrength,
                                        float3 _SpecColor, float attenuation)
            {
                float maxDotNl = max(0, dot(n, l));
                float3 h = (l + v) / length(l + v);
                return maxDotNl * attenuation * _LightColor0 * _SpecColor.xyz * pow(max(0, dot(h, n)), _Shininess) *
                    _SpecularStrength;
            }

            float GetTranslucence(float3 n, float3 l, float3 v, float _SubsurfaceDistortion, float _SubsurfacePower,
                      float _SubsurfaceScale, float attenuation)
            {
                float3 H = normalize(l + n * _SubsurfaceDistortion);
                float I = attenuation * pow(saturate(dot(v, -H)), _SubsurfacePower) * _SubsurfaceScale;
                return I;
            }

            float4 _Color;
            float3 _SpecColor;
            float _Shininess;
            float _SpecularStrength;
            int _isBlinn;

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
                float attenuation = 1;
                // w is 0 for directional lights
                float3 l = normalize(_WorldSpaceLightPos0.xyz - i.worldPos * _WorldSpaceLightPos0.w);

                float3 n = normalize(i.normal);
                float3 v = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 ambient = ambientLight(_Color);
                float3 diffuse = diffuseLight(n, l, _Color, attenuation);
                //not pretty, but gets the job done :)
                float3 specular = 0;
                if (_isBlinn == 0)
                {
                    specular = specularHighLight(n, l, v, _Shininess, _SpecularStrength, _SpecColor, attenuation);
                }
                else
                {
                    specular = specularBlinn(n, l, v, _Shininess, _SpecularStrength, _SpecColor, attenuation);
                }
                return float4(ambient + (diffuse + specular) * shadow, 1);
            }
            ENDCG
        }
        Pass
        {
            Tags
            {
                "LightMode" = "ForwardAdd"
            }// not directional light
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

            float _SubsurfaceDistortion;
            float _SubsurfacePower;
            float _SubsurfaceScale;
            int _isToggled;


            uniform float4 _LightColor0;

            float3 ambientLight(float3 baseColor)
            {
                return UNITY_LIGHTMODEL_AMBIENT * baseColor;
            }

            float4 diffuseLight(float3 n, float3 l, float4 baseColor, float attenuation)
            {
                float dotNl = dot(n, l);
                float maxDotNl = max(0, dotNl);
                return _LightColor0 * baseColor * maxDotNl * attenuation;
            }

            float3 specularHighLight(float3 n, float3 l, float3 v, float _Shininess, float _SpecularStrength,
                float3 _SpecColor, float attenuation)
            {
                float3 r = reflect(-l, n);
                float dotNl = dot(n, l);
                float maxDotNl = max(0, dotNl);
                return maxDotNl * attenuation * _LightColor0 * _SpecColor.xyz * pow(max(0, dot(r, v)), _Shininess) *
                    _SpecularStrength;
            }

            float3 specularBlinn(float3 n, float3 l, float3 v, float _Shininess, float _SpecularStrength,
               float3 _SpecColor, float attenuation)
            {
                float maxDotNl = max(0, dot(n, l));
                float3 h = (l + v) / length(l + v);
                return maxDotNl * attenuation * _LightColor0 * _SpecColor.xyz * pow(max(0, dot(h, n)), _Shininess) *
                    _SpecularStrength;
            }

            float GetTranslucence(float3 n, float3 l, float3 v, float _SubsurfaceDistortion, float _SubsurfacePower,
                               float _SubsurfaceScale, float attenuation)
            {
                float3 H = normalize(l + n * _SubsurfaceDistortion);
                float I = attenuation * pow(saturate(dot(v, -H)), _SubsurfacePower) * _SubsurfaceScale;
                return I;
            }

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
                float3 ambient = ambientLight(_Color);
                float3 diffuse = diffuseLight(n, l, _Color, attenuation);
                float3 specular = specularHighLight(n, l, v, _Shininess, _SpecularStrength, _SpecColor, attenuation);

                float3 translucence = _isToggled * GetTranslucence(n, l, v, _SubsurfaceDistortion, _SubsurfacePower,
                                                                   _SubsurfaceScale, attenuation) * _LightColor0.xyz;
                return float4((diffuse + specular + translucence) * shadow, 1);
            }
            ENDCG
        }
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
    //    Properties
    //    {
    //        _MainTex ("Texture", 2D) = "white" {}
    //        _Intensity ("Intensity", Range(0,1)) = 0
    //        _Color("Color", Color) = (1,1,1,1)
    //        _NoiseR ("Noise R", Range(0,1))= 1
    //        _NoiseG ("Noise G", Range(0,1))= 1
    //        _NoiseB ("Noise B", Range(0,1))= 1
    //    }
    //    SubShader
    //    {
    //        Tags { "RenderType"="Opaque" }
    //        LOD 100
    //
    //        Pass
    //        {
    //            CGPROGRAM
    //            #pragma vertex vert
    //            #pragma fragment frag
    //         
    //
    //            #include "UnityCG.cginc"
    //
    //            struct appdata
    //            {
    //                float4 vertex : POSITION;
    //                float2 uv : TEXCOORD0;
    //            };
    //
    //            struct v2f
    //            {
    //                float2 uv : TEXCOORD0;
    //                float4 vertex : SV_POSITION;
    //                float4 color : COLOR;
    //            };
    //
    //            sampler2D _MainTex;
    //         
    //            float _Intensity;
    //            float _NoiseR;
    //            float _NoiseG;
    //            float _NoiseB;
    //            float4 _MainTex_ST;
    //            float4 _Color;
    //            v2f vert (appdata v)
    //            {
    //                v2f o;
    //               
    //
    //      
    //                o.vertex = UnityObjectToClipPos(v.vertex);
    //                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    //                return o;
    //            }
    //
    //            fixed4 frag (v2f i) : SV_Target
    //            {
    //                // sample the texture
    //                fixed4 col = tex2D(_MainTex, i.uv);
    //                col.r *= _NoiseR;
    //                col.b *= _NoiseB;
    //                col.g *= _NoiseG;
    //                
    //                
    //                col = lerp(_Color, col, _Intensity);
    //                return col;
    //            }
    //            ENDCG
    //        }
    //    }
}