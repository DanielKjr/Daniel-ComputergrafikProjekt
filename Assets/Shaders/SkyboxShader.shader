Shader "Unlit/SkyboxShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1)

    }
    SubShader
    {
        Tags { "LightMode"="ForwardBase" }
        Blend One OneMinusSrcAlpha
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
         
            #pragma multi_compile_fog
            #pragma multi_compile_fwdbasealpha

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
           
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            fixed4 _Color;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
          
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                UNITY_APPLY_FOG(i.fogCoord, _Color);
                return _Color;
            }
            ENDCG
        }
    }
Fallback "Diffuse"
}
