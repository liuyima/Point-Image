Shader "Custom/c_s" {
    Properties {
        _MainTex ("Base (RGB)", 2D) = "white" {} 
		_Width("每个方形点宽度",FLOAT) = 0.25
    }                                            
                                                 

    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Pass{
            Blend Off Lighting Off Cull Off ZWrite Off ZTest Off AlphaTest Off
            CGPROGRAM
            #pragma target 5.0
            #pragma vertex vert 
			#pragma geometry Geom
            #pragma fragment frag 
            #include "UnityCG.cginc"

			struct Data
			{
				float3 pos;
				float3 velocity;
				float3 uv;
			};

            StructuredBuffer<Data> dataBuffer;//存有点位置

            sampler2D _MainTex;
			float _Width;

            struct vertIN{
                uint id : SV_VertexID;
            };

            struct vertOUT{
                float4 pos : SV_POSITION;
                float3 uv : TEXCOORD0;
				float3 velocity:TEXCOORD1;
            };

            vertOUT vert(vertIN i){
				vertOUT o;
                float3 pos = dataBuffer[i.id].pos ; //存储点的位置,P buffer中在compute shader以放置了点位置

                o.pos = float4(pos ,1);

                o.uv = dataBuffer[i.id].uv; 
				o.velocity = dataBuffer[i.id].velocity;

                return o;
            }

			//将存储的点转为面片
			[maxvertexcount(4)]
			void Geom(point vertOUT p[1],inout TriangleStream<vertOUT> triStream)
			{
				vertOUT os[4];
				os[0].pos =  mul(UNITY_MATRIX_VP,p[0].pos + float4(_Width,_Width,0,0));
				os[1].pos =  mul(UNITY_MATRIX_VP,p[0].pos + float4(-_Width,_Width,0,0));
				os[2].pos =  mul(UNITY_MATRIX_VP,p[0].pos + float4(_Width,-_Width,0,0));
				os[3].pos =  mul(UNITY_MATRIX_VP,p[0].pos + float4(-_Width,-_Width,0,0));
				os[0].uv = p[0].uv;
				os[1].uv = p[0].uv;
				os[2].uv = p[0].uv;
				os[3].uv = p[0].uv;
				os[0].velocity = p[0].velocity;
				os[1].velocity = p[0].velocity;
				os[2].velocity = p[0].velocity;
				os[3].velocity = p[0].velocity;

				triStream.Append(os[0]);
				triStream.Append(os[1]);
				triStream.Append(os[2]);
				triStream.Append(os[3]);
			}

            fixed4 frag(vertOUT ou):COLOR{

                fixed4 c = tex2D(_MainTex,ou.uv);
				c+= half4( ou.velocity,0);
                return c;

            }
            ENDCG
        }
    } 
}