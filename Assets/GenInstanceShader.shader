Shader "Custom/GenInstanceShader"
    {
        Properties
        {
            [NoScaleOffset]_MainTex("_MainTex", 2D) = "white" {}
            [NoScaleOffset]_Cam("Cam", 2D) = "white" {}
            [NoScaleOffset]_Flower("_Flower", 2D) = "white" {}
            _Color("Color", Color) = (0, 0, 0, 0)
            [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
            [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
            [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
        }
        SubShader
        {
            Tags
            {
                "RenderPipeline"="UniversalPipeline"
                "RenderType"="Opaque"
                "UniversalMaterialType" = "Unlit"
                "Queue"="AlphaTest"
            }
            Pass
            {
                Name "Pass"
                Tags
                {
                    // LightMode: <None>
                }
    
                // Render State
                Cull Off
                Blend One Zero
                ZTest LEqual
                ZWrite On
    
                // Debug
                // <None>
    
                // --------------------------------------------------
                // Pass
    
                HLSLPROGRAM
    
                // Pragmas
                #pragma target 2.0
                #pragma only_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma multi_compile_fog
                #pragma vertex vert
                #pragma fragment frag
    
                #if SHADER_TARGET >= 35 && (defined(SHADER_API_D3D11) || defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE) || defined(SHADER_API_XBOXONE) || defined(SHADER_API_PSSL) || defined(SHADER_API_VULKAN) || defined(SHADER_API_METAL))
                    #define UNITY_SUPPORT_INSTANCING
                #endif
                #if defined(UNITY_SUPPORT_INSTANCING) && defined(INSTANCING_ON)
                    #define UNITY_HYBRID_V1_INSTANCING_ENABLED
                #endif
                #if defined(UNITY_HYBRID_V1_INSTANCING_ENABLED)
                #define HYBRID_V1_CUSTOM_ADDITIONAL_MATERIAL_VARS \
                UNITY_DEFINE_INSTANCED_PROP(float4, _Color_Array)
                #define _Color UNITY_ACCESS_INSTANCED_PROP(unity_Builtins0, _Color_Array)
                #endif
    
                // Keywords
                #pragma multi_compile _ LIGHTMAP_ON
                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                #pragma shader_feature _ _SAMPLE_GI
                // GraphKeywords: <None>
    
                // Defines
                #define _AlphaClip 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define VARYINGS_NEED_NORMAL_WS
                #define VARYINGS_NEED_TANGENT_WS
                #define VARYINGS_NEED_TEXCOORD0
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_UNLIT
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    float4 uv0 : TEXCOORD0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float3 normalWS;
                    float4 tangentWS;
                    float4 texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 WorldSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 WorldSpaceTangent;
                    float3 ObjectSpaceBiTangent;
                    float3 WorldSpaceBiTangent;
                    float4 uv0;
                    float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 WorldSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 WorldSpaceTangent;
                    float3 ObjectSpaceBiTangent;
                    float3 WorldSpaceBiTangent;
                    float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float3 interp0 : TEXCOORD0;
                    float4 interp1 : TEXCOORD1;
                    float4 interp2 : TEXCOORD2;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
    
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.normalWS;
                    output.interp1.xyzw =  input.tangentWS;
                    output.interp2.xyzw =  input.texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.normalWS = input.interp0.xyz;
                    output.tangentWS = input.interp1.xyzw;
                    output.texCoord0 = input.interp2.xyzw;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
    
                // --------------------------------------------------
                // Graph
    
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_TexelSize;
                float4 _Cam_TexelSize;
                float4 _Flower_TexelSize;
                #ifdef UNITY_HYBRID_V1_INSTANCING_ENABLED
                float4 _Color_dummy;
                #else
                float4 _Color;
                #endif
                CBUFFER_END
                
                // Object and Global properties
                TEXTURE2D(_MainTex);
                SAMPLER(sampler_MainTex);
                TEXTURE2D(_Cam);
                SAMPLER(sampler_Cam);
                TEXTURE2D(_CameraDepthTexture);
                SAMPLER(sampler_CameraDepthTexture);
                float4 _CameraDepthTexture_TexelSize;
                TEXTURE2D(_Flower);
                SAMPLER(sampler_Flower);
                SAMPLER(_SampleTexture2D_0da5d3967df94ec3a8d3c19710f40a03_Sampler_3_Linear_Repeat);
                SAMPLER(_SampleTexture2D_b1927a2dcc874807842ad7b61935960f_Sampler_3_Linear_Repeat);
    
                // Graph Functions
                
                void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Multiply_float(float4x4 A, float4 B, out float4 Out)
                {
                    Out = mul(A, B);
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void ComputeScreenPos_float(float4 clipPos, out float4 Out)
                {
                    Out = ComputeScreenPos(clipPos, _ProjectionParams.x);
                    Out.xyz /= Out.w;
                }
                
                void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
                {
                     float randomno =  frac(sin(dot(Seed, float2(12.9898, 78.233)))*43758.5453);
                     Out = lerp(Min, Max, randomno);
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Sine_float(float In, out float Out)
                {
                    Out = sin(In);
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_RadialShear_float(float2 UV, float2 Center, float2 Strength, float2 Offset, out float2 Out)
                {
                    float2 delta = UV - Center;
                    float delta2 = dot(delta.xy, delta.xy);
                    float2 delta_offset = delta2 * Strength;
                    Out = UV + float2(delta.y, -delta.x) * delta_offset + Offset;
                }
                
                void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
                {
                    Out = A * B;
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    float3 _Multiply_4c91474db29a4557b80b68089353e1b7_Out_2;
                    Unity_Multiply_float(IN.ObjectSpacePosition, float3(length(float3(UNITY_MATRIX_M[0].x, UNITY_MATRIX_M[1].x, UNITY_MATRIX_M[2].x)),
                                             length(float3(UNITY_MATRIX_M[0].y, UNITY_MATRIX_M[1].y, UNITY_MATRIX_M[2].y)),
                                             length(float3(UNITY_MATRIX_M[0].z, UNITY_MATRIX_M[1].z, UNITY_MATRIX_M[2].z))), _Multiply_4c91474db29a4557b80b68089353e1b7_Out_2);
                    float _Split_f54ffde290cd4959bd080850dc332a8f_R_1 = _Multiply_4c91474db29a4557b80b68089353e1b7_Out_2[0];
                    float _Split_f54ffde290cd4959bd080850dc332a8f_G_2 = _Multiply_4c91474db29a4557b80b68089353e1b7_Out_2[1];
                    float _Split_f54ffde290cd4959bd080850dc332a8f_B_3 = _Multiply_4c91474db29a4557b80b68089353e1b7_Out_2[2];
                    float _Split_f54ffde290cd4959bd080850dc332a8f_A_4 = 0;
                    float4 _Vector4_d33c01c367e24344a30de44a4000487b_Out_0 = float4(_Split_f54ffde290cd4959bd080850dc332a8f_R_1, _Split_f54ffde290cd4959bd080850dc332a8f_G_2, _Split_f54ffde290cd4959bd080850dc332a8f_B_3, 0);
                    float4 _Multiply_6c3dad42daf24f3986eb875ffecd66f0_Out_2;
                    Unity_Multiply_float(UNITY_MATRIX_I_V, _Vector4_d33c01c367e24344a30de44a4000487b_Out_0, _Multiply_6c3dad42daf24f3986eb875ffecd66f0_Out_2);
                    float3 _Add_5a3195e766294c8ea5d43066d7bc1526_Out_2;
                    Unity_Add_float3((_Multiply_6c3dad42daf24f3986eb875ffecd66f0_Out_2.xyz), SHADERGRAPH_OBJECT_POSITION, _Add_5a3195e766294c8ea5d43066d7bc1526_Out_2);
                    float3 _Transform_391d7cb107d54e0899e4c9012f3d6136_Out_1 = TransformWorldToObject(_Add_5a3195e766294c8ea5d43066d7bc1526_Out_2.xyz);
                    description.Position = _Transform_391d7cb107d54e0899e4c9012f3d6136_Out_1;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float3 BaseColor;
                    float Alpha;
                    float AlphaClipThreshold;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float3 _Transform_b78ea2b3dbc7451b80eb5531d00d5279_Out_1 = TransformObjectToWorld(float3 (0, 0, 0).xyz);
                    float4 _Multiply_f83c6fbbc6d646149774b6655ede1c57_Out_2;
                    Unity_Multiply_float(UNITY_MATRIX_VP, (float4(_Transform_b78ea2b3dbc7451b80eb5531d00d5279_Out_1, 1.0)), _Multiply_f83c6fbbc6d646149774b6655ede1c57_Out_2);
                    float4 _CustomFunction_f6dba3fe50fc4bdf82de4da94331b354_Out_1;
                    ComputeScreenPos_float(_Multiply_f83c6fbbc6d646149774b6655ede1c57_Out_2, _CustomFunction_f6dba3fe50fc4bdf82de4da94331b354_Out_1);
                    float4 _SampleTexture2D_0da5d3967df94ec3a8d3c19710f40a03_RGBA_0 = SAMPLE_TEXTURE2D(_Cam, sampler_Cam, (_CustomFunction_f6dba3fe50fc4bdf82de4da94331b354_Out_1.xy));
                    float _SampleTexture2D_0da5d3967df94ec3a8d3c19710f40a03_R_4 = _SampleTexture2D_0da5d3967df94ec3a8d3c19710f40a03_RGBA_0.r;
                    float _SampleTexture2D_0da5d3967df94ec3a8d3c19710f40a03_G_5 = _SampleTexture2D_0da5d3967df94ec3a8d3c19710f40a03_RGBA_0.g;
                    float _SampleTexture2D_0da5d3967df94ec3a8d3c19710f40a03_B_6 = _SampleTexture2D_0da5d3967df94ec3a8d3c19710f40a03_RGBA_0.b;
                    float _SampleTexture2D_0da5d3967df94ec3a8d3c19710f40a03_A_7 = _SampleTexture2D_0da5d3967df94ec3a8d3c19710f40a03_RGBA_0.a;
                    float4 _UV_de8cad64e78b451aa23d66a4f2e117c5_Out_0 = IN.uv0;
                    float _RandomRange_b7803f7c583246e9894249e552dd3d41_Out_3;
                    Unity_RandomRange_float((SHADERGRAPH_OBJECT_POSITION.xy), -1, 1, _RandomRange_b7803f7c583246e9894249e552dd3d41_Out_3);
                    float _Add_f1cba1785b284950acf50b4c52edbafa_Out_2;
                    Unity_Add_float(_RandomRange_b7803f7c583246e9894249e552dd3d41_Out_3, IN.TimeParameters.x, _Add_f1cba1785b284950acf50b4c52edbafa_Out_2);
                    float _Sine_bf5b87a253d4421eb573a2d80a6898c8_Out_1;
                    Unity_Sine_float(_Add_f1cba1785b284950acf50b4c52edbafa_Out_2, _Sine_bf5b87a253d4421eb573a2d80a6898c8_Out_1);
                    float _Multiply_acb1670fefea4ba98112d83602c7a06c_Out_2;
                    Unity_Multiply_float(_Sine_bf5b87a253d4421eb573a2d80a6898c8_Out_1, 0.1, _Multiply_acb1670fefea4ba98112d83602c7a06c_Out_2);
                    float2 _RadialShear_6014ff781696454cb15171a54b13ab40_Out_4;
                    Unity_RadialShear_float((_UV_de8cad64e78b451aa23d66a4f2e117c5_Out_0.xy), float2 (0, 0), (_Multiply_acb1670fefea4ba98112d83602c7a06c_Out_2.xx), float2 (0, 0), _RadialShear_6014ff781696454cb15171a54b13ab40_Out_4);
                    float4 _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, _RadialShear_6014ff781696454cb15171a54b13ab40_Out_4);
                    float _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_R_4 = _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_RGBA_0.r;
                    float _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_G_5 = _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_RGBA_0.g;
                    float _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_B_6 = _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_RGBA_0.b;
                    float _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_A_7 = _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_RGBA_0.a;
                    float4 _Multiply_f27f7760116049268aba7615ebe270f5_Out_2;
                    Unity_Multiply_float(_SampleTexture2D_0da5d3967df94ec3a8d3c19710f40a03_RGBA_0, _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_RGBA_0, _Multiply_f27f7760116049268aba7615ebe270f5_Out_2);
                    surface.BaseColor = (_Multiply_f27f7760116049268aba7615ebe270f5_Out_2.xyz);
                    surface.Alpha = _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_A_7;
                    surface.AlphaClipThreshold = 0.5;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
                    output.ObjectSpaceTangent =          input.tangentOS;
                    output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
                    output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                    output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                    output.ObjectSpacePosition =         input.positionOS;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                	float3 unnormalizedNormalWS = input.normalWS;
                    const float renormFactor = 1.0 / length(unnormalizedNormalWS);
                
                	// use bitangent on the fly like in hdrp
                	// IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
                    float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
                	float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
                
                    output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
                    output.ObjectSpaceNormal =           normalize(mul(output.WorldSpaceNormal, (float3x3) UNITY_MATRIX_M));           // transposed multiplication by inverse matrix to handle normal scale
                
                	// to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
                	// This is explained in section 2.2 in "surface gradient based bump mapping framework"
                    output.WorldSpaceTangent =           renormFactor*input.tangentWS.xyz;
                	output.WorldSpaceBiTangent =         renormFactor*bitang;
                
                    output.ObjectSpaceTangent =          TransformWorldToObjectDir(output.WorldSpaceTangent);
                    output.ObjectSpaceBiTangent =        TransformWorldToObjectDir(output.WorldSpaceBiTangent);
                    output.uv0 =                         input.texCoord0;
                    output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
    
                // --------------------------------------------------
                // Main
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"
    
                ENDHLSL
            }
            Pass
            {
                Name "ShadowCaster"
                Tags
                {
                    "LightMode" = "ShadowCaster"
                }
    
                // Render State
                Cull Off
                Blend One Zero
                ZTest LEqual
                ZWrite On
                ColorMask 0
    
                // Debug
                // <None>
    
                // --------------------------------------------------
                // Pass
    
                HLSLPROGRAM
    
                // Pragmas
                #pragma target 2.0
                #pragma only_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma vertex vert
                #pragma fragment frag
    
                #if SHADER_TARGET >= 35 && (defined(SHADER_API_D3D11) || defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE) || defined(SHADER_API_XBOXONE) || defined(SHADER_API_PSSL) || defined(SHADER_API_VULKAN) || defined(SHADER_API_METAL))
                    #define UNITY_SUPPORT_INSTANCING
                #endif
                #if defined(UNITY_SUPPORT_INSTANCING) && defined(INSTANCING_ON)
                    #define UNITY_HYBRID_V1_INSTANCING_ENABLED
                #endif
                #if defined(UNITY_HYBRID_V1_INSTANCING_ENABLED)
                #define HYBRID_V1_CUSTOM_ADDITIONAL_MATERIAL_VARS \
                UNITY_DEFINE_INSTANCED_PROP(float4, _Color_Array)
                #define _Color UNITY_ACCESS_INSTANCED_PROP(unity_Builtins0, _Color_Array)
                #endif
    
                // Keywords
                // PassKeywords: <None>
                // GraphKeywords: <None>
    
                // Defines
                #define _AlphaClip 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define VARYINGS_NEED_TEXCOORD0
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_SHADOWCASTER
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    float4 uv0 : TEXCOORD0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float4 texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                    float4 uv0;
                    float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 WorldSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 WorldSpaceTangent;
                    float3 ObjectSpaceBiTangent;
                    float3 WorldSpaceBiTangent;
                    float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float4 interp0 : TEXCOORD0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
    
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    output.positionCS = input.positionCS;
                    output.interp0.xyzw =  input.texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.texCoord0 = input.interp0.xyzw;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
    
                // --------------------------------------------------
                // Graph
    
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_TexelSize;
                float4 _Cam_TexelSize;
                float4 _Flower_TexelSize;
                #ifdef UNITY_HYBRID_V1_INSTANCING_ENABLED
                float4 _Color_dummy;
                #else
                float4 _Color;
                #endif
                CBUFFER_END
                
                // Object and Global properties
                TEXTURE2D(_MainTex);
                SAMPLER(sampler_MainTex);
                TEXTURE2D(_Cam);
                SAMPLER(sampler_Cam);
                TEXTURE2D(_CameraDepthTexture);
                SAMPLER(sampler_CameraDepthTexture);
                float4 _CameraDepthTexture_TexelSize;
                TEXTURE2D(_Flower);
                SAMPLER(sampler_Flower);
                SAMPLER(_SampleTexture2D_b1927a2dcc874807842ad7b61935960f_Sampler_3_Linear_Repeat);
    
                // Graph Functions
                
                void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Multiply_float(float4x4 A, float4 B, out float4 Out)
                {
                    Out = mul(A, B);
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
                {
                     float randomno =  frac(sin(dot(Seed, float2(12.9898, 78.233)))*43758.5453);
                     Out = lerp(Min, Max, randomno);
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Sine_float(float In, out float Out)
                {
                    Out = sin(In);
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_RadialShear_float(float2 UV, float2 Center, float2 Strength, float2 Offset, out float2 Out)
                {
                    float2 delta = UV - Center;
                    float delta2 = dot(delta.xy, delta.xy);
                    float2 delta_offset = delta2 * Strength;
                    Out = UV + float2(delta.y, -delta.x) * delta_offset + Offset;
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    float3 _Multiply_4c91474db29a4557b80b68089353e1b7_Out_2;
                    Unity_Multiply_float(IN.ObjectSpacePosition, float3(length(float3(UNITY_MATRIX_M[0].x, UNITY_MATRIX_M[1].x, UNITY_MATRIX_M[2].x)),
                                             length(float3(UNITY_MATRIX_M[0].y, UNITY_MATRIX_M[1].y, UNITY_MATRIX_M[2].y)),
                                             length(float3(UNITY_MATRIX_M[0].z, UNITY_MATRIX_M[1].z, UNITY_MATRIX_M[2].z))), _Multiply_4c91474db29a4557b80b68089353e1b7_Out_2);
                    float _Split_f54ffde290cd4959bd080850dc332a8f_R_1 = _Multiply_4c91474db29a4557b80b68089353e1b7_Out_2[0];
                    float _Split_f54ffde290cd4959bd080850dc332a8f_G_2 = _Multiply_4c91474db29a4557b80b68089353e1b7_Out_2[1];
                    float _Split_f54ffde290cd4959bd080850dc332a8f_B_3 = _Multiply_4c91474db29a4557b80b68089353e1b7_Out_2[2];
                    float _Split_f54ffde290cd4959bd080850dc332a8f_A_4 = 0;
                    float4 _Vector4_d33c01c367e24344a30de44a4000487b_Out_0 = float4(_Split_f54ffde290cd4959bd080850dc332a8f_R_1, _Split_f54ffde290cd4959bd080850dc332a8f_G_2, _Split_f54ffde290cd4959bd080850dc332a8f_B_3, 0);
                    float4 _Multiply_6c3dad42daf24f3986eb875ffecd66f0_Out_2;
                    Unity_Multiply_float(UNITY_MATRIX_I_V, _Vector4_d33c01c367e24344a30de44a4000487b_Out_0, _Multiply_6c3dad42daf24f3986eb875ffecd66f0_Out_2);
                    float3 _Add_5a3195e766294c8ea5d43066d7bc1526_Out_2;
                    Unity_Add_float3((_Multiply_6c3dad42daf24f3986eb875ffecd66f0_Out_2.xyz), SHADERGRAPH_OBJECT_POSITION, _Add_5a3195e766294c8ea5d43066d7bc1526_Out_2);
                    float3 _Transform_391d7cb107d54e0899e4c9012f3d6136_Out_1 = TransformWorldToObject(_Add_5a3195e766294c8ea5d43066d7bc1526_Out_2.xyz);
                    description.Position = _Transform_391d7cb107d54e0899e4c9012f3d6136_Out_1;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float Alpha;
                    float AlphaClipThreshold;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float4 _UV_de8cad64e78b451aa23d66a4f2e117c5_Out_0 = IN.uv0;
                    float _RandomRange_b7803f7c583246e9894249e552dd3d41_Out_3;
                    Unity_RandomRange_float((SHADERGRAPH_OBJECT_POSITION.xy), -1, 1, _RandomRange_b7803f7c583246e9894249e552dd3d41_Out_3);
                    float _Add_f1cba1785b284950acf50b4c52edbafa_Out_2;
                    Unity_Add_float(_RandomRange_b7803f7c583246e9894249e552dd3d41_Out_3, IN.TimeParameters.x, _Add_f1cba1785b284950acf50b4c52edbafa_Out_2);
                    float _Sine_bf5b87a253d4421eb573a2d80a6898c8_Out_1;
                    Unity_Sine_float(_Add_f1cba1785b284950acf50b4c52edbafa_Out_2, _Sine_bf5b87a253d4421eb573a2d80a6898c8_Out_1);
                    float _Multiply_acb1670fefea4ba98112d83602c7a06c_Out_2;
                    Unity_Multiply_float(_Sine_bf5b87a253d4421eb573a2d80a6898c8_Out_1, 0.1, _Multiply_acb1670fefea4ba98112d83602c7a06c_Out_2);
                    float2 _RadialShear_6014ff781696454cb15171a54b13ab40_Out_4;
                    Unity_RadialShear_float((_UV_de8cad64e78b451aa23d66a4f2e117c5_Out_0.xy), float2 (0, 0), (_Multiply_acb1670fefea4ba98112d83602c7a06c_Out_2.xx), float2 (0, 0), _RadialShear_6014ff781696454cb15171a54b13ab40_Out_4);
                    float4 _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, _RadialShear_6014ff781696454cb15171a54b13ab40_Out_4);
                    float _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_R_4 = _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_RGBA_0.r;
                    float _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_G_5 = _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_RGBA_0.g;
                    float _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_B_6 = _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_RGBA_0.b;
                    float _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_A_7 = _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_RGBA_0.a;
                    surface.Alpha = _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_A_7;
                    surface.AlphaClipThreshold = 0.5;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
                    output.ObjectSpaceTangent =          input.tangentOS;
                    output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
                    output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                    output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                    output.ObjectSpacePosition =         input.positionOS;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                
                
                
                
                    output.uv0 =                         input.texCoord0;
                    output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
    
                // --------------------------------------------------
                // Main
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
    
                ENDHLSL
            }
            Pass
            {
                Name "DepthOnly"
                Tags
                {
                    "LightMode" = "DepthOnly"
                }
    
                // Render State
                Cull Off
                Blend One Zero
                ZTest LEqual
                ZWrite On
                ColorMask 0
    
                // Debug
                // <None>
    
                // --------------------------------------------------
                // Pass
    
                HLSLPROGRAM
    
                // Pragmas
                #pragma target 2.0
                #pragma only_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma vertex vert
                #pragma fragment frag
    
                #if SHADER_TARGET >= 35 && (defined(SHADER_API_D3D11) || defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE) || defined(SHADER_API_XBOXONE) || defined(SHADER_API_PSSL) || defined(SHADER_API_VULKAN) || defined(SHADER_API_METAL))
                    #define UNITY_SUPPORT_INSTANCING
                #endif
                #if defined(UNITY_SUPPORT_INSTANCING) && defined(INSTANCING_ON)
                    #define UNITY_HYBRID_V1_INSTANCING_ENABLED
                #endif
                #if defined(UNITY_HYBRID_V1_INSTANCING_ENABLED)
                #define HYBRID_V1_CUSTOM_ADDITIONAL_MATERIAL_VARS \
                UNITY_DEFINE_INSTANCED_PROP(float4, _Color_Array)
                #define _Color UNITY_ACCESS_INSTANCED_PROP(unity_Builtins0, _Color_Array)
                #endif
    
                // Keywords
                // PassKeywords: <None>
                // GraphKeywords: <None>
    
                // Defines
                #define _AlphaClip 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define VARYINGS_NEED_TEXCOORD0
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_DEPTHONLY
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    float4 uv0 : TEXCOORD0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float4 texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                    float4 uv0;
                    float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 WorldSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 WorldSpaceTangent;
                    float3 ObjectSpaceBiTangent;
                    float3 WorldSpaceBiTangent;
                    float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float4 interp0 : TEXCOORD0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
    
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    output.positionCS = input.positionCS;
                    output.interp0.xyzw =  input.texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.texCoord0 = input.interp0.xyzw;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
    
                // --------------------------------------------------
                // Graph
    
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_TexelSize;
                float4 _Cam_TexelSize;
                float4 _Flower_TexelSize;
                #ifdef UNITY_HYBRID_V1_INSTANCING_ENABLED
                float4 _Color_dummy;
                #else
                float4 _Color;
                #endif
                CBUFFER_END
                
                // Object and Global properties
                TEXTURE2D(_MainTex);
                SAMPLER(sampler_MainTex);
                TEXTURE2D(_Cam);
                SAMPLER(sampler_Cam);
                TEXTURE2D(_CameraDepthTexture);
                SAMPLER(sampler_CameraDepthTexture);
                float4 _CameraDepthTexture_TexelSize;
                TEXTURE2D(_Flower);
                SAMPLER(sampler_Flower);
                SAMPLER(_SampleTexture2D_b1927a2dcc874807842ad7b61935960f_Sampler_3_Linear_Repeat);
    
                // Graph Functions
                
                void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Multiply_float(float4x4 A, float4 B, out float4 Out)
                {
                    Out = mul(A, B);
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
                {
                     float randomno =  frac(sin(dot(Seed, float2(12.9898, 78.233)))*43758.5453);
                     Out = lerp(Min, Max, randomno);
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Sine_float(float In, out float Out)
                {
                    Out = sin(In);
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_RadialShear_float(float2 UV, float2 Center, float2 Strength, float2 Offset, out float2 Out)
                {
                    float2 delta = UV - Center;
                    float delta2 = dot(delta.xy, delta.xy);
                    float2 delta_offset = delta2 * Strength;
                    Out = UV + float2(delta.y, -delta.x) * delta_offset + Offset;
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    float3 _Multiply_4c91474db29a4557b80b68089353e1b7_Out_2;
                    Unity_Multiply_float(IN.ObjectSpacePosition, float3(length(float3(UNITY_MATRIX_M[0].x, UNITY_MATRIX_M[1].x, UNITY_MATRIX_M[2].x)),
                                             length(float3(UNITY_MATRIX_M[0].y, UNITY_MATRIX_M[1].y, UNITY_MATRIX_M[2].y)),
                                             length(float3(UNITY_MATRIX_M[0].z, UNITY_MATRIX_M[1].z, UNITY_MATRIX_M[2].z))), _Multiply_4c91474db29a4557b80b68089353e1b7_Out_2);
                    float _Split_f54ffde290cd4959bd080850dc332a8f_R_1 = _Multiply_4c91474db29a4557b80b68089353e1b7_Out_2[0];
                    float _Split_f54ffde290cd4959bd080850dc332a8f_G_2 = _Multiply_4c91474db29a4557b80b68089353e1b7_Out_2[1];
                    float _Split_f54ffde290cd4959bd080850dc332a8f_B_3 = _Multiply_4c91474db29a4557b80b68089353e1b7_Out_2[2];
                    float _Split_f54ffde290cd4959bd080850dc332a8f_A_4 = 0;
                    float4 _Vector4_d33c01c367e24344a30de44a4000487b_Out_0 = float4(_Split_f54ffde290cd4959bd080850dc332a8f_R_1, _Split_f54ffde290cd4959bd080850dc332a8f_G_2, _Split_f54ffde290cd4959bd080850dc332a8f_B_3, 0);
                    float4 _Multiply_6c3dad42daf24f3986eb875ffecd66f0_Out_2;
                    Unity_Multiply_float(UNITY_MATRIX_I_V, _Vector4_d33c01c367e24344a30de44a4000487b_Out_0, _Multiply_6c3dad42daf24f3986eb875ffecd66f0_Out_2);
                    float3 _Add_5a3195e766294c8ea5d43066d7bc1526_Out_2;
                    Unity_Add_float3((_Multiply_6c3dad42daf24f3986eb875ffecd66f0_Out_2.xyz), SHADERGRAPH_OBJECT_POSITION, _Add_5a3195e766294c8ea5d43066d7bc1526_Out_2);
                    float3 _Transform_391d7cb107d54e0899e4c9012f3d6136_Out_1 = TransformWorldToObject(_Add_5a3195e766294c8ea5d43066d7bc1526_Out_2.xyz);
                    description.Position = _Transform_391d7cb107d54e0899e4c9012f3d6136_Out_1;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float Alpha;
                    float AlphaClipThreshold;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float4 _UV_de8cad64e78b451aa23d66a4f2e117c5_Out_0 = IN.uv0;
                    float _RandomRange_b7803f7c583246e9894249e552dd3d41_Out_3;
                    Unity_RandomRange_float((SHADERGRAPH_OBJECT_POSITION.xy), -1, 1, _RandomRange_b7803f7c583246e9894249e552dd3d41_Out_3);
                    float _Add_f1cba1785b284950acf50b4c52edbafa_Out_2;
                    Unity_Add_float(_RandomRange_b7803f7c583246e9894249e552dd3d41_Out_3, IN.TimeParameters.x, _Add_f1cba1785b284950acf50b4c52edbafa_Out_2);
                    float _Sine_bf5b87a253d4421eb573a2d80a6898c8_Out_1;
                    Unity_Sine_float(_Add_f1cba1785b284950acf50b4c52edbafa_Out_2, _Sine_bf5b87a253d4421eb573a2d80a6898c8_Out_1);
                    float _Multiply_acb1670fefea4ba98112d83602c7a06c_Out_2;
                    Unity_Multiply_float(_Sine_bf5b87a253d4421eb573a2d80a6898c8_Out_1, 0.1, _Multiply_acb1670fefea4ba98112d83602c7a06c_Out_2);
                    float2 _RadialShear_6014ff781696454cb15171a54b13ab40_Out_4;
                    Unity_RadialShear_float((_UV_de8cad64e78b451aa23d66a4f2e117c5_Out_0.xy), float2 (0, 0), (_Multiply_acb1670fefea4ba98112d83602c7a06c_Out_2.xx), float2 (0, 0), _RadialShear_6014ff781696454cb15171a54b13ab40_Out_4);
                    float4 _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, _RadialShear_6014ff781696454cb15171a54b13ab40_Out_4);
                    float _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_R_4 = _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_RGBA_0.r;
                    float _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_G_5 = _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_RGBA_0.g;
                    float _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_B_6 = _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_RGBA_0.b;
                    float _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_A_7 = _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_RGBA_0.a;
                    surface.Alpha = _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_A_7;
                    surface.AlphaClipThreshold = 0.5;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
                    output.ObjectSpaceTangent =          input.tangentOS;
                    output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
                    output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                    output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                    output.ObjectSpacePosition =         input.positionOS;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                
                
                
                
                    output.uv0 =                         input.texCoord0;
                    output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
    
                // --------------------------------------------------
                // Main
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
    
                ENDHLSL
            }
        }
        SubShader
        {
            Tags
            {
                "RenderPipeline"="UniversalPipeline"
                "RenderType"="Opaque"
                "UniversalMaterialType" = "Unlit"
                "Queue"="AlphaTest"
            }
            Pass
            {
                Name "Pass"
                Tags
                {
                    // LightMode: <None>
                }
    
                // Render State
                Cull Off
                Blend One Zero
                ZTest LEqual
                ZWrite On
    
                // Debug
                // <None>
    
                // --------------------------------------------------
                // Pass
    
                HLSLPROGRAM
    
                // Pragmas
                #pragma target 4.5
                #pragma exclude_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma multi_compile_fog
                #pragma multi_compile _ DOTS_INSTANCING_ON
                #pragma vertex vert
                #pragma fragment frag
    
                #if SHADER_TARGET >= 35 && (defined(SHADER_API_D3D11) || defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE) || defined(SHADER_API_XBOXONE) || defined(SHADER_API_PSSL) || defined(SHADER_API_VULKAN) || defined(SHADER_API_METAL))
                    #define UNITY_SUPPORT_INSTANCING
                #endif
                #if defined(UNITY_SUPPORT_INSTANCING) && defined(INSTANCING_ON)
                    #define UNITY_HYBRID_V1_INSTANCING_ENABLED
                #endif
                #if defined(UNITY_HYBRID_V1_INSTANCING_ENABLED)
                #define HYBRID_V1_CUSTOM_ADDITIONAL_MATERIAL_VARS \
                UNITY_DEFINE_INSTANCED_PROP(float4, _Color_Array)
                #define _Color UNITY_ACCESS_INSTANCED_PROP(unity_Builtins0, _Color_Array)
                #endif
    
                // Keywords
                #pragma multi_compile _ LIGHTMAP_ON
                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                #pragma shader_feature _ _SAMPLE_GI
                // GraphKeywords: <None>
    
                // Defines
                #define _AlphaClip 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define VARYINGS_NEED_NORMAL_WS
                #define VARYINGS_NEED_TANGENT_WS
                #define VARYINGS_NEED_TEXCOORD0
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_UNLIT
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    float4 uv0 : TEXCOORD0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float3 normalWS;
                    float4 tangentWS;
                    float4 texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 WorldSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 WorldSpaceTangent;
                    float3 ObjectSpaceBiTangent;
                    float3 WorldSpaceBiTangent;
                    float4 uv0;
                    float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 WorldSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 WorldSpaceTangent;
                    float3 ObjectSpaceBiTangent;
                    float3 WorldSpaceBiTangent;
                    float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float3 interp0 : TEXCOORD0;
                    float4 interp1 : TEXCOORD1;
                    float4 interp2 : TEXCOORD2;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
    
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.normalWS;
                    output.interp1.xyzw =  input.tangentWS;
                    output.interp2.xyzw =  input.texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.normalWS = input.interp0.xyz;
                    output.tangentWS = input.interp1.xyzw;
                    output.texCoord0 = input.interp2.xyzw;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
    
                // --------------------------------------------------
                // Graph
    
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_TexelSize;
                float4 _Cam_TexelSize;
                float4 _Flower_TexelSize;
                #ifdef UNITY_HYBRID_V1_INSTANCING_ENABLED
                float4 _Color_dummy;
                #else
                float4 _Color;
                #endif
                CBUFFER_END
                
                // Object and Global properties
                TEXTURE2D(_MainTex);
                SAMPLER(sampler_MainTex);
                TEXTURE2D(_Cam);
                SAMPLER(sampler_Cam);
                TEXTURE2D(_CameraDepthTexture);
                SAMPLER(sampler_CameraDepthTexture);
                float4 _CameraDepthTexture_TexelSize;
                TEXTURE2D(_Flower);
                SAMPLER(sampler_Flower);
                SAMPLER(_SampleTexture2D_0da5d3967df94ec3a8d3c19710f40a03_Sampler_3_Linear_Repeat);
                SAMPLER(_SampleTexture2D_b1927a2dcc874807842ad7b61935960f_Sampler_3_Linear_Repeat);
    
                // Graph Functions
                
                void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Multiply_float(float4x4 A, float4 B, out float4 Out)
                {
                    Out = mul(A, B);
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void ComputeScreenPos_float(float4 clipPos, out float4 Out)
                {
                    Out = ComputeScreenPos(clipPos, _ProjectionParams.x);
                    Out.xyz /= Out.w;
                }
                
                void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
                {
                     float randomno =  frac(sin(dot(Seed, float2(12.9898, 78.233)))*43758.5453);
                     Out = lerp(Min, Max, randomno);
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Sine_float(float In, out float Out)
                {
                    Out = sin(In);
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_RadialShear_float(float2 UV, float2 Center, float2 Strength, float2 Offset, out float2 Out)
                {
                    float2 delta = UV - Center;
                    float delta2 = dot(delta.xy, delta.xy);
                    float2 delta_offset = delta2 * Strength;
                    Out = UV + float2(delta.y, -delta.x) * delta_offset + Offset;
                }
                
                void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
                {
                    Out = A * B;
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    float3 _Multiply_4c91474db29a4557b80b68089353e1b7_Out_2;
                    Unity_Multiply_float(IN.ObjectSpacePosition, float3(length(float3(UNITY_MATRIX_M[0].x, UNITY_MATRIX_M[1].x, UNITY_MATRIX_M[2].x)),
                                             length(float3(UNITY_MATRIX_M[0].y, UNITY_MATRIX_M[1].y, UNITY_MATRIX_M[2].y)),
                                             length(float3(UNITY_MATRIX_M[0].z, UNITY_MATRIX_M[1].z, UNITY_MATRIX_M[2].z))), _Multiply_4c91474db29a4557b80b68089353e1b7_Out_2);
                    float _Split_f54ffde290cd4959bd080850dc332a8f_R_1 = _Multiply_4c91474db29a4557b80b68089353e1b7_Out_2[0];
                    float _Split_f54ffde290cd4959bd080850dc332a8f_G_2 = _Multiply_4c91474db29a4557b80b68089353e1b7_Out_2[1];
                    float _Split_f54ffde290cd4959bd080850dc332a8f_B_3 = _Multiply_4c91474db29a4557b80b68089353e1b7_Out_2[2];
                    float _Split_f54ffde290cd4959bd080850dc332a8f_A_4 = 0;
                    float4 _Vector4_d33c01c367e24344a30de44a4000487b_Out_0 = float4(_Split_f54ffde290cd4959bd080850dc332a8f_R_1, _Split_f54ffde290cd4959bd080850dc332a8f_G_2, _Split_f54ffde290cd4959bd080850dc332a8f_B_3, 0);
                    float4 _Multiply_6c3dad42daf24f3986eb875ffecd66f0_Out_2;
                    Unity_Multiply_float(UNITY_MATRIX_I_V, _Vector4_d33c01c367e24344a30de44a4000487b_Out_0, _Multiply_6c3dad42daf24f3986eb875ffecd66f0_Out_2);
                    float3 _Add_5a3195e766294c8ea5d43066d7bc1526_Out_2;
                    Unity_Add_float3((_Multiply_6c3dad42daf24f3986eb875ffecd66f0_Out_2.xyz), SHADERGRAPH_OBJECT_POSITION, _Add_5a3195e766294c8ea5d43066d7bc1526_Out_2);
                    float3 _Transform_391d7cb107d54e0899e4c9012f3d6136_Out_1 = TransformWorldToObject(_Add_5a3195e766294c8ea5d43066d7bc1526_Out_2.xyz);
                    description.Position = _Transform_391d7cb107d54e0899e4c9012f3d6136_Out_1;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float3 BaseColor;
                    float Alpha;
                    float AlphaClipThreshold;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float3 _Transform_b78ea2b3dbc7451b80eb5531d00d5279_Out_1 = TransformObjectToWorld(float3 (0, 0, 0).xyz);
                    float4 _Multiply_f83c6fbbc6d646149774b6655ede1c57_Out_2;
                    Unity_Multiply_float(UNITY_MATRIX_VP, (float4(_Transform_b78ea2b3dbc7451b80eb5531d00d5279_Out_1, 1.0)), _Multiply_f83c6fbbc6d646149774b6655ede1c57_Out_2);
                    float4 _CustomFunction_f6dba3fe50fc4bdf82de4da94331b354_Out_1;
                    ComputeScreenPos_float(_Multiply_f83c6fbbc6d646149774b6655ede1c57_Out_2, _CustomFunction_f6dba3fe50fc4bdf82de4da94331b354_Out_1);
                    float4 _SampleTexture2D_0da5d3967df94ec3a8d3c19710f40a03_RGBA_0 = SAMPLE_TEXTURE2D(_Cam, sampler_Cam, (_CustomFunction_f6dba3fe50fc4bdf82de4da94331b354_Out_1.xy));
                    float _SampleTexture2D_0da5d3967df94ec3a8d3c19710f40a03_R_4 = _SampleTexture2D_0da5d3967df94ec3a8d3c19710f40a03_RGBA_0.r;
                    float _SampleTexture2D_0da5d3967df94ec3a8d3c19710f40a03_G_5 = _SampleTexture2D_0da5d3967df94ec3a8d3c19710f40a03_RGBA_0.g;
                    float _SampleTexture2D_0da5d3967df94ec3a8d3c19710f40a03_B_6 = _SampleTexture2D_0da5d3967df94ec3a8d3c19710f40a03_RGBA_0.b;
                    float _SampleTexture2D_0da5d3967df94ec3a8d3c19710f40a03_A_7 = _SampleTexture2D_0da5d3967df94ec3a8d3c19710f40a03_RGBA_0.a;
                    float4 _UV_de8cad64e78b451aa23d66a4f2e117c5_Out_0 = IN.uv0;
                    float _RandomRange_b7803f7c583246e9894249e552dd3d41_Out_3;
                    Unity_RandomRange_float((SHADERGRAPH_OBJECT_POSITION.xy), -1, 1, _RandomRange_b7803f7c583246e9894249e552dd3d41_Out_3);
                    float _Add_f1cba1785b284950acf50b4c52edbafa_Out_2;
                    Unity_Add_float(_RandomRange_b7803f7c583246e9894249e552dd3d41_Out_3, IN.TimeParameters.x, _Add_f1cba1785b284950acf50b4c52edbafa_Out_2);
                    float _Sine_bf5b87a253d4421eb573a2d80a6898c8_Out_1;
                    Unity_Sine_float(_Add_f1cba1785b284950acf50b4c52edbafa_Out_2, _Sine_bf5b87a253d4421eb573a2d80a6898c8_Out_1);
                    float _Multiply_acb1670fefea4ba98112d83602c7a06c_Out_2;
                    Unity_Multiply_float(_Sine_bf5b87a253d4421eb573a2d80a6898c8_Out_1, 0.1, _Multiply_acb1670fefea4ba98112d83602c7a06c_Out_2);
                    float2 _RadialShear_6014ff781696454cb15171a54b13ab40_Out_4;
                    Unity_RadialShear_float((_UV_de8cad64e78b451aa23d66a4f2e117c5_Out_0.xy), float2 (0, 0), (_Multiply_acb1670fefea4ba98112d83602c7a06c_Out_2.xx), float2 (0, 0), _RadialShear_6014ff781696454cb15171a54b13ab40_Out_4);
                    float4 _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, _RadialShear_6014ff781696454cb15171a54b13ab40_Out_4);
                    float _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_R_4 = _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_RGBA_0.r;
                    float _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_G_5 = _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_RGBA_0.g;
                    float _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_B_6 = _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_RGBA_0.b;
                    float _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_A_7 = _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_RGBA_0.a;
                    float4 _Multiply_f27f7760116049268aba7615ebe270f5_Out_2;
                    Unity_Multiply_float(_SampleTexture2D_0da5d3967df94ec3a8d3c19710f40a03_RGBA_0, _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_RGBA_0, _Multiply_f27f7760116049268aba7615ebe270f5_Out_2);
                    surface.BaseColor = (_Multiply_f27f7760116049268aba7615ebe270f5_Out_2.xyz);
                    surface.Alpha = _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_A_7;
                    surface.AlphaClipThreshold = 0.5;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
                    output.ObjectSpaceTangent =          input.tangentOS;
                    output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
                    output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                    output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                    output.ObjectSpacePosition =         input.positionOS;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                	float3 unnormalizedNormalWS = input.normalWS;
                    const float renormFactor = 1.0 / length(unnormalizedNormalWS);
                
                	// use bitangent on the fly like in hdrp
                	// IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
                    float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
                	float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
                
                    output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
                    output.ObjectSpaceNormal =           normalize(mul(output.WorldSpaceNormal, (float3x3) UNITY_MATRIX_M));           // transposed multiplication by inverse matrix to handle normal scale
                
                	// to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
                	// This is explained in section 2.2 in "surface gradient based bump mapping framework"
                    output.WorldSpaceTangent =           renormFactor*input.tangentWS.xyz;
                	output.WorldSpaceBiTangent =         renormFactor*bitang;
                
                    output.ObjectSpaceTangent =          TransformWorldToObjectDir(output.WorldSpaceTangent);
                    output.ObjectSpaceBiTangent =        TransformWorldToObjectDir(output.WorldSpaceBiTangent);
                    output.uv0 =                         input.texCoord0;
                    output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
    
                // --------------------------------------------------
                // Main
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"
    
                ENDHLSL
            }
            Pass
            {
                Name "ShadowCaster"
                Tags
                {
                    "LightMode" = "ShadowCaster"
                }
    
                // Render State
                Cull Off
                Blend One Zero
                ZTest LEqual
                ZWrite On
                ColorMask 0
    
                // Debug
                // <None>
    
                // --------------------------------------------------
                // Pass
    
                HLSLPROGRAM
    
                // Pragmas
                #pragma target 4.5
                #pragma exclude_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma multi_compile _ DOTS_INSTANCING_ON
                #pragma vertex vert
                #pragma fragment frag
    
                #if SHADER_TARGET >= 35 && (defined(SHADER_API_D3D11) || defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE) || defined(SHADER_API_XBOXONE) || defined(SHADER_API_PSSL) || defined(SHADER_API_VULKAN) || defined(SHADER_API_METAL))
                    #define UNITY_SUPPORT_INSTANCING
                #endif
                #if defined(UNITY_SUPPORT_INSTANCING) && defined(INSTANCING_ON)
                    #define UNITY_HYBRID_V1_INSTANCING_ENABLED
                #endif
                #if defined(UNITY_HYBRID_V1_INSTANCING_ENABLED)
                #define HYBRID_V1_CUSTOM_ADDITIONAL_MATERIAL_VARS \
                UNITY_DEFINE_INSTANCED_PROP(float4, _Color_Array)
                #define _Color UNITY_ACCESS_INSTANCED_PROP(unity_Builtins0, _Color_Array)
                #endif
    
                // Keywords
                // PassKeywords: <None>
                // GraphKeywords: <None>
    
                // Defines
                #define _AlphaClip 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define VARYINGS_NEED_TEXCOORD0
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_SHADOWCASTER
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    float4 uv0 : TEXCOORD0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float4 texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                    float4 uv0;
                    float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 WorldSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 WorldSpaceTangent;
                    float3 ObjectSpaceBiTangent;
                    float3 WorldSpaceBiTangent;
                    float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float4 interp0 : TEXCOORD0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
    
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    output.positionCS = input.positionCS;
                    output.interp0.xyzw =  input.texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.texCoord0 = input.interp0.xyzw;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
    
                // --------------------------------------------------
                // Graph
    
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_TexelSize;
                float4 _Cam_TexelSize;
                float4 _Flower_TexelSize;
                #ifdef UNITY_HYBRID_V1_INSTANCING_ENABLED
                float4 _Color_dummy;
                #else
                float4 _Color;
                #endif
                CBUFFER_END
                
                // Object and Global properties
                TEXTURE2D(_MainTex);
                SAMPLER(sampler_MainTex);
                TEXTURE2D(_Cam);
                SAMPLER(sampler_Cam);
                TEXTURE2D(_CameraDepthTexture);
                SAMPLER(sampler_CameraDepthTexture);
                float4 _CameraDepthTexture_TexelSize;
                TEXTURE2D(_Flower);
                SAMPLER(sampler_Flower);
                SAMPLER(_SampleTexture2D_b1927a2dcc874807842ad7b61935960f_Sampler_3_Linear_Repeat);
    
                // Graph Functions
                
                void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Multiply_float(float4x4 A, float4 B, out float4 Out)
                {
                    Out = mul(A, B);
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
                {
                     float randomno =  frac(sin(dot(Seed, float2(12.9898, 78.233)))*43758.5453);
                     Out = lerp(Min, Max, randomno);
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Sine_float(float In, out float Out)
                {
                    Out = sin(In);
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_RadialShear_float(float2 UV, float2 Center, float2 Strength, float2 Offset, out float2 Out)
                {
                    float2 delta = UV - Center;
                    float delta2 = dot(delta.xy, delta.xy);
                    float2 delta_offset = delta2 * Strength;
                    Out = UV + float2(delta.y, -delta.x) * delta_offset + Offset;
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    float3 _Multiply_4c91474db29a4557b80b68089353e1b7_Out_2;
                    Unity_Multiply_float(IN.ObjectSpacePosition, float3(length(float3(UNITY_MATRIX_M[0].x, UNITY_MATRIX_M[1].x, UNITY_MATRIX_M[2].x)),
                                             length(float3(UNITY_MATRIX_M[0].y, UNITY_MATRIX_M[1].y, UNITY_MATRIX_M[2].y)),
                                             length(float3(UNITY_MATRIX_M[0].z, UNITY_MATRIX_M[1].z, UNITY_MATRIX_M[2].z))), _Multiply_4c91474db29a4557b80b68089353e1b7_Out_2);
                    float _Split_f54ffde290cd4959bd080850dc332a8f_R_1 = _Multiply_4c91474db29a4557b80b68089353e1b7_Out_2[0];
                    float _Split_f54ffde290cd4959bd080850dc332a8f_G_2 = _Multiply_4c91474db29a4557b80b68089353e1b7_Out_2[1];
                    float _Split_f54ffde290cd4959bd080850dc332a8f_B_3 = _Multiply_4c91474db29a4557b80b68089353e1b7_Out_2[2];
                    float _Split_f54ffde290cd4959bd080850dc332a8f_A_4 = 0;
                    float4 _Vector4_d33c01c367e24344a30de44a4000487b_Out_0 = float4(_Split_f54ffde290cd4959bd080850dc332a8f_R_1, _Split_f54ffde290cd4959bd080850dc332a8f_G_2, _Split_f54ffde290cd4959bd080850dc332a8f_B_3, 0);
                    float4 _Multiply_6c3dad42daf24f3986eb875ffecd66f0_Out_2;
                    Unity_Multiply_float(UNITY_MATRIX_I_V, _Vector4_d33c01c367e24344a30de44a4000487b_Out_0, _Multiply_6c3dad42daf24f3986eb875ffecd66f0_Out_2);
                    float3 _Add_5a3195e766294c8ea5d43066d7bc1526_Out_2;
                    Unity_Add_float3((_Multiply_6c3dad42daf24f3986eb875ffecd66f0_Out_2.xyz), SHADERGRAPH_OBJECT_POSITION, _Add_5a3195e766294c8ea5d43066d7bc1526_Out_2);
                    float3 _Transform_391d7cb107d54e0899e4c9012f3d6136_Out_1 = TransformWorldToObject(_Add_5a3195e766294c8ea5d43066d7bc1526_Out_2.xyz);
                    description.Position = _Transform_391d7cb107d54e0899e4c9012f3d6136_Out_1;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float Alpha;
                    float AlphaClipThreshold;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float4 _UV_de8cad64e78b451aa23d66a4f2e117c5_Out_0 = IN.uv0;
                    float _RandomRange_b7803f7c583246e9894249e552dd3d41_Out_3;
                    Unity_RandomRange_float((SHADERGRAPH_OBJECT_POSITION.xy), -1, 1, _RandomRange_b7803f7c583246e9894249e552dd3d41_Out_3);
                    float _Add_f1cba1785b284950acf50b4c52edbafa_Out_2;
                    Unity_Add_float(_RandomRange_b7803f7c583246e9894249e552dd3d41_Out_3, IN.TimeParameters.x, _Add_f1cba1785b284950acf50b4c52edbafa_Out_2);
                    float _Sine_bf5b87a253d4421eb573a2d80a6898c8_Out_1;
                    Unity_Sine_float(_Add_f1cba1785b284950acf50b4c52edbafa_Out_2, _Sine_bf5b87a253d4421eb573a2d80a6898c8_Out_1);
                    float _Multiply_acb1670fefea4ba98112d83602c7a06c_Out_2;
                    Unity_Multiply_float(_Sine_bf5b87a253d4421eb573a2d80a6898c8_Out_1, 0.1, _Multiply_acb1670fefea4ba98112d83602c7a06c_Out_2);
                    float2 _RadialShear_6014ff781696454cb15171a54b13ab40_Out_4;
                    Unity_RadialShear_float((_UV_de8cad64e78b451aa23d66a4f2e117c5_Out_0.xy), float2 (0, 0), (_Multiply_acb1670fefea4ba98112d83602c7a06c_Out_2.xx), float2 (0, 0), _RadialShear_6014ff781696454cb15171a54b13ab40_Out_4);
                    float4 _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, _RadialShear_6014ff781696454cb15171a54b13ab40_Out_4);
                    float _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_R_4 = _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_RGBA_0.r;
                    float _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_G_5 = _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_RGBA_0.g;
                    float _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_B_6 = _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_RGBA_0.b;
                    float _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_A_7 = _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_RGBA_0.a;
                    surface.Alpha = _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_A_7;
                    surface.AlphaClipThreshold = 0.5;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
                    output.ObjectSpaceTangent =          input.tangentOS;
                    output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
                    output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                    output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                    output.ObjectSpacePosition =         input.positionOS;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                
                
                
                
                    output.uv0 =                         input.texCoord0;
                    output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
    
                // --------------------------------------------------
                // Main
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
    
                ENDHLSL
            }
            Pass
            {
                Name "DepthOnly"
                Tags
                {
                    "LightMode" = "DepthOnly"
                }
    
                // Render State
                Cull Off
                Blend One Zero
                ZTest LEqual
                ZWrite On
                ColorMask 0
    
                // Debug
                // <None>
    
                // --------------------------------------------------
                // Pass
    
                HLSLPROGRAM
    
                // Pragmas
                #pragma target 4.5
                #pragma exclude_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma multi_compile _ DOTS_INSTANCING_ON
                #pragma vertex vert
                #pragma fragment frag
    
                #if SHADER_TARGET >= 35 && (defined(SHADER_API_D3D11) || defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE) || defined(SHADER_API_XBOXONE) || defined(SHADER_API_PSSL) || defined(SHADER_API_VULKAN) || defined(SHADER_API_METAL))
                    #define UNITY_SUPPORT_INSTANCING
                #endif
                #if defined(UNITY_SUPPORT_INSTANCING) && defined(INSTANCING_ON)
                    #define UNITY_HYBRID_V1_INSTANCING_ENABLED
                #endif
                #if defined(UNITY_HYBRID_V1_INSTANCING_ENABLED)
                #define HYBRID_V1_CUSTOM_ADDITIONAL_MATERIAL_VARS \
                UNITY_DEFINE_INSTANCED_PROP(float4, _Color_Array)
                #define _Color UNITY_ACCESS_INSTANCED_PROP(unity_Builtins0, _Color_Array)
                #endif
    
                // Keywords
                // PassKeywords: <None>
                // GraphKeywords: <None>
    
                // Defines
                #define _AlphaClip 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define VARYINGS_NEED_TEXCOORD0
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_DEPTHONLY
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    float4 uv0 : TEXCOORD0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float4 texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                    float4 uv0;
                    float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 WorldSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 WorldSpaceTangent;
                    float3 ObjectSpaceBiTangent;
                    float3 WorldSpaceBiTangent;
                    float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float4 interp0 : TEXCOORD0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
    
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    output.positionCS = input.positionCS;
                    output.interp0.xyzw =  input.texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.texCoord0 = input.interp0.xyzw;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
    
                // --------------------------------------------------
                // Graph
    
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_TexelSize;
                float4 _Cam_TexelSize;
                float4 _Flower_TexelSize;
                #ifdef UNITY_HYBRID_V1_INSTANCING_ENABLED
                float4 _Color_dummy;
                #else
                float4 _Color;
                #endif
                CBUFFER_END
                
                // Object and Global properties
                TEXTURE2D(_MainTex);
                SAMPLER(sampler_MainTex);
                TEXTURE2D(_Cam);
                SAMPLER(sampler_Cam);
                TEXTURE2D(_CameraDepthTexture);
                SAMPLER(sampler_CameraDepthTexture);
                float4 _CameraDepthTexture_TexelSize;
                TEXTURE2D(_Flower);
                SAMPLER(sampler_Flower);
                SAMPLER(_SampleTexture2D_b1927a2dcc874807842ad7b61935960f_Sampler_3_Linear_Repeat);
    
                // Graph Functions
                
                void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Multiply_float(float4x4 A, float4 B, out float4 Out)
                {
                    Out = mul(A, B);
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
                {
                     float randomno =  frac(sin(dot(Seed, float2(12.9898, 78.233)))*43758.5453);
                     Out = lerp(Min, Max, randomno);
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Sine_float(float In, out float Out)
                {
                    Out = sin(In);
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_RadialShear_float(float2 UV, float2 Center, float2 Strength, float2 Offset, out float2 Out)
                {
                    float2 delta = UV - Center;
                    float delta2 = dot(delta.xy, delta.xy);
                    float2 delta_offset = delta2 * Strength;
                    Out = UV + float2(delta.y, -delta.x) * delta_offset + Offset;
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    float3 _Multiply_4c91474db29a4557b80b68089353e1b7_Out_2;
                    Unity_Multiply_float(IN.ObjectSpacePosition, float3(length(float3(UNITY_MATRIX_M[0].x, UNITY_MATRIX_M[1].x, UNITY_MATRIX_M[2].x)),
                                             length(float3(UNITY_MATRIX_M[0].y, UNITY_MATRIX_M[1].y, UNITY_MATRIX_M[2].y)),
                                             length(float3(UNITY_MATRIX_M[0].z, UNITY_MATRIX_M[1].z, UNITY_MATRIX_M[2].z))), _Multiply_4c91474db29a4557b80b68089353e1b7_Out_2);
                    float _Split_f54ffde290cd4959bd080850dc332a8f_R_1 = _Multiply_4c91474db29a4557b80b68089353e1b7_Out_2[0];
                    float _Split_f54ffde290cd4959bd080850dc332a8f_G_2 = _Multiply_4c91474db29a4557b80b68089353e1b7_Out_2[1];
                    float _Split_f54ffde290cd4959bd080850dc332a8f_B_3 = _Multiply_4c91474db29a4557b80b68089353e1b7_Out_2[2];
                    float _Split_f54ffde290cd4959bd080850dc332a8f_A_4 = 0;
                    float4 _Vector4_d33c01c367e24344a30de44a4000487b_Out_0 = float4(_Split_f54ffde290cd4959bd080850dc332a8f_R_1, _Split_f54ffde290cd4959bd080850dc332a8f_G_2, _Split_f54ffde290cd4959bd080850dc332a8f_B_3, 0);
                    float4 _Multiply_6c3dad42daf24f3986eb875ffecd66f0_Out_2;
                    Unity_Multiply_float(UNITY_MATRIX_I_V, _Vector4_d33c01c367e24344a30de44a4000487b_Out_0, _Multiply_6c3dad42daf24f3986eb875ffecd66f0_Out_2);
                    float3 _Add_5a3195e766294c8ea5d43066d7bc1526_Out_2;
                    Unity_Add_float3((_Multiply_6c3dad42daf24f3986eb875ffecd66f0_Out_2.xyz), SHADERGRAPH_OBJECT_POSITION, _Add_5a3195e766294c8ea5d43066d7bc1526_Out_2);
                    float3 _Transform_391d7cb107d54e0899e4c9012f3d6136_Out_1 = TransformWorldToObject(_Add_5a3195e766294c8ea5d43066d7bc1526_Out_2.xyz);
                    description.Position = _Transform_391d7cb107d54e0899e4c9012f3d6136_Out_1;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float Alpha;
                    float AlphaClipThreshold;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float4 _UV_de8cad64e78b451aa23d66a4f2e117c5_Out_0 = IN.uv0;
                    float _RandomRange_b7803f7c583246e9894249e552dd3d41_Out_3;
                    Unity_RandomRange_float((SHADERGRAPH_OBJECT_POSITION.xy), -1, 1, _RandomRange_b7803f7c583246e9894249e552dd3d41_Out_3);
                    float _Add_f1cba1785b284950acf50b4c52edbafa_Out_2;
                    Unity_Add_float(_RandomRange_b7803f7c583246e9894249e552dd3d41_Out_3, IN.TimeParameters.x, _Add_f1cba1785b284950acf50b4c52edbafa_Out_2);
                    float _Sine_bf5b87a253d4421eb573a2d80a6898c8_Out_1;
                    Unity_Sine_float(_Add_f1cba1785b284950acf50b4c52edbafa_Out_2, _Sine_bf5b87a253d4421eb573a2d80a6898c8_Out_1);
                    float _Multiply_acb1670fefea4ba98112d83602c7a06c_Out_2;
                    Unity_Multiply_float(_Sine_bf5b87a253d4421eb573a2d80a6898c8_Out_1, 0.1, _Multiply_acb1670fefea4ba98112d83602c7a06c_Out_2);
                    float2 _RadialShear_6014ff781696454cb15171a54b13ab40_Out_4;
                    Unity_RadialShear_float((_UV_de8cad64e78b451aa23d66a4f2e117c5_Out_0.xy), float2 (0, 0), (_Multiply_acb1670fefea4ba98112d83602c7a06c_Out_2.xx), float2 (0, 0), _RadialShear_6014ff781696454cb15171a54b13ab40_Out_4);
                    float4 _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_RGBA_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, _RadialShear_6014ff781696454cb15171a54b13ab40_Out_4);
                    float _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_R_4 = _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_RGBA_0.r;
                    float _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_G_5 = _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_RGBA_0.g;
                    float _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_B_6 = _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_RGBA_0.b;
                    float _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_A_7 = _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_RGBA_0.a;
                    surface.Alpha = _SampleTexture2D_b1927a2dcc874807842ad7b61935960f_A_7;
                    surface.AlphaClipThreshold = 0.5;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
                    output.ObjectSpaceTangent =          input.tangentOS;
                    output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
                    output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                    output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                    output.ObjectSpacePosition =         input.positionOS;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                
                
                
                
                    output.uv0 =                         input.texCoord0;
                    output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
    
                // --------------------------------------------------
                // Main
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
    
                ENDHLSL
            }
        }
        FallBack "Hidden/Shader Graph/FallbackError"
    }
