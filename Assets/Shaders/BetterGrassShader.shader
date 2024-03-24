Shader "Unlit/BetterGrassShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("BlendColor", Color) = (1,1,1)
        _Intensity ("Intensity", Range(0,1)) = 1

        _WindMovement("WindMovement", Range(0,1))= 0
        _WindStrength("Wind strength", Range(0,1 ))= 0
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque" "Queue" = "Transparent" 
        }
        LOD 100


        Pass
        {
            Tags{"LightMode" = "ForwardBase"}
            ZWrite On
//            ZTest Always
            //zwrite og ztest til always kræver en renderqueue til geometry omkring 1999 men så vises en hvid kasse på den ene siden uden for framebuffer
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #pragma multi_compile_fwdbase


            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;

            float4 _MainTex_ST;
            float4 _Color;
            float _Intensity;
            float _WindStrength;
            float _WindMovement;
        
            

            v2f vert(appdata v)
            {
                v2f o;

                //worldspace matrix
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                
                float2 uv = worldPos * _WindMovement * _Time;

                //sample texturemap, frac removes all but the last decimal values
                float2 displacement = tex2Dlod(_MainTex, float4(frac(uv.x), frac(uv.y), frac(worldPos.z), frac(worldPos.w)));
                displacement -= 0.5;
                displacement *= _WindStrength;

                //add values to the world position
                float4 modifiedWPos = float4(worldPos.x + displacement.x, worldPos.y, worldPos.z, worldPos.w);
                float uvY = v.uv.y / 2;

                worldPos = lerp(modifiedWPos, worldPos, uvY);

                
                //multiply the view projection with the position
                o.vertex = mul(UNITY_MATRIX_VP, worldPos);
                //downscale the uv map
                o.uv = TRANSFORM_TEX(v.uv, _MainTex) ;
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

            
                col *= _Color * _Intensity;

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
            //double side rendering
            Cull Off


        }
        pass
        {


            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
            CGPROGRAM
            #pragma target 3.0

            #pragma vertex vert
            #pragma fragment frag


            #include "AutoLight.cginc"
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                SHADOW_COORDS(5)
                float4 shadowCoord : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;

            v2f vert(appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.shadowCoord = ComputeScreenPos(o.vertex);
                TRANSFER_SHADOW(o);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 texColor = tex2D(_MainTex, i.uv);
                fixed4 shadow = SHADOW_ATTENUATION(i);

                
                return shadow;
            }
            ENDCG

        }


    }
    Fallback "Diffuse"

}