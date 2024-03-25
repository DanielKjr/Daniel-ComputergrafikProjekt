Shader "Unlit/PostProcessFogAmplifierShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FogStrength("Fog strength", Range(0, 2)) = 1
        _Size("Size", Range(0,2)) = 0.5
        _XMovement("X moevement", Range(1, 5)) = 1
        _YMovement("Y moevement", Range(0, 5)) = 0
    }
    SubShader
    {
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

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _Size;
            float _FogStrength;
            float _XMovement;
            float _YMovement;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
    
            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                // color + brightness for at gøre det lysere
                col = col + _FogStrength;
                float glareSize = _Size * _ScreenParams.y;
                //saturate clamper værdien mellem 0 og 1
                float distance = saturate(
                    length(i.uv * _ScreenParams.xy - float2(_ScreenParams.x / _XMovement, _ScreenParams.y / _YMovement))
                    / glareSize);
                //interpoler lineært mellem a og b ved w
                col = lerp(col, 0, distance);
                return col;
            }
            ENDCG
        }
    }
}