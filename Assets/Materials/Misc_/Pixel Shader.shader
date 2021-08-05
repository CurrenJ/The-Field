Shader "Hidden/Pixel Shader" {
    Properties {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _pixelAmt ("Pixelation", Range (1, 1024)) = 512
    }
    SubShader {
        Pass {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"

            uniform sampler2D _MainTex;
            uniform float _pixelAmt;

            float4 frag(v2f_img i) : COLOR {
                float4 c = tex2D(_MainTex, float2(uint2(i.uv * _pixelAmt)) / _pixelAmt);
                
                float lum = c.r*.3 + c.g*.59 + c.b*.11;
                float3 bw = float3( lum, lum, lum ); 
                
                float4 result = c;
                //result.rgb = lerp(c.rgb, bw, _bwBlend);
                return result;
            }
            ENDCG
        }
    }
}