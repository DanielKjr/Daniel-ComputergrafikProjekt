Shader "Unlit/WaterShader"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)

        _FoamColor("Foam Color", Color) = (1,1,1,1)
        _FoamDistance("Foam Distance", Float) = 1
        _NoiseTexture("Noise Texture", 2D) = "Black"{}
        _NoiseThreshold("Noise Threshold", Range(0,1)) = 0.7
        _NoiseScroll("Noise Scroll", Vector) = (1,1,0,0)

    }
    SubShader
    {

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

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
                float4 pos : SV_POSITION;
                float4 sceenPosition : TEXCOORD2;
            };


            float _FoamDistance;
            float4 _FoamColor;
            float4 _Color;
            sampler2D _NoiseTexture;
            float4 _NoiseTexture_ST;
            float _NoiseThreshold;
            float4 _NoiseScroll;
            uniform float3 _LightColor0;
            
            samplerCUBE _ReflectionProbe;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _NoiseTexture);
                o.sceenPosition = ComputeScreenPos(o.pos);
                UNITY_TRANSFER_FOG(o, o.pos);
                return o;
            }

            sampler2D _CameraDepthTexture;
            fixed4 frag(v2f i) : SV_Target
            {
                float sceneDepth = LinearEyeDepth(tex2Dproj(_CameraDepthTexture, i.sceenPosition));

                float diff = sceneDepth - i.sceenPosition.w;

                float foam = saturate(diff / _FoamDistance);

                float2 uv = i.uv + _NoiseScroll.xy * _Time.xx;

                float noise = tex2D(_NoiseTexture, uv).r;
                noise = step(_NoiseThreshold * foam, noise);

                float4 color = _Color * (1 - noise) + _FoamColor * noise;
                
                UNITY_APPLY_FOG(i.fogCoord, color);
                return color;
            }
            ENDCG
        }
    }
}