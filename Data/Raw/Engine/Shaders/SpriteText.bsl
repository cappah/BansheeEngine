Parameters =
{
	mat4x4 	gWorldTransform;
	float	gInvViewportWidth;
	float	gInvViewportHeight;
	color	gTint;
	
	Sampler2D	gMainTexSamp : alias("gMainTexture");
	Texture2D	gMainTexture;
};

Blocks = 
{
	Block GUIParams : auto("GUIParams");
};

Technique =
{
	Language = "HLSL11";
	
	Pass =
	{
		Target = 
		{
			Blend = true;
			Color = { SRCA, SRCIA, ADD };
			WriteMask = RGB;
		};	
	
		DepthRead = false;
		DepthWrite = false;
		
		Common =
		{
			cbuffer GUIParams
			{
				float4x4 gWorldTransform;
				float gInvViewportWidth;
				float gInvViewportHeight;
				float4 gTint;
			}	
		};
		
		Vertex =
		{
			void main(
				in float3 inPos : POSITION,
				in float2 uv : TEXCOORD0,
				out float4 oPosition : SV_Position,
				out float2 oUv : TEXCOORD0)
			{
				float4 tfrmdPos = mul(gWorldTransform, float4(inPos.xy, 0, 1));

				float tfrmdX = -1.0f + (tfrmdPos.x * gInvViewportWidth);
				float tfrmdY = 1.0f - (tfrmdPos.y * gInvViewportHeight);

				oPosition = float4(tfrmdX, tfrmdY, 0, 1);
				oUv = uv;
			}
		};
		
		Fragment =
		{
			SamplerState gMainTexSamp : register(s0);
			Texture2D gMainTexture : register(t0);

			float4 main(in float4 inPos : SV_Position, float2 uv : TEXCOORD0) : SV_Target
			{
				float4 color = float4(gTint.rgb, gMainTexture.Sample(gMainTexSamp, uv).r * gTint.a);
				return color;
			}
		};
	};
};

Technique =
{
	Language = "GLSL";
	
	Pass =
	{
		Target = 
		{
			Blend = true;
			Color = { SRCA, SRCIA, ADD };
			WriteMask = RGB;
		};
		
		DepthRead = false;
		DepthWrite = false;
		
		Common =
		{
			layout (binding = 0, std140) uniform GUIParams
			{
				mat4 gWorldTransform;
				float gInvViewportWidth;
				float gInvViewportHeight;
				vec4 gTint;
			};			
		};			
		
		Vertex =
		{
			layout (location = 0) in vec3 bs_position;
			layout (location = 1) in vec2 bs_texcoord0;
			
			layout (location = 0) out vec2 texcoord0;

			out gl_PerVertex
			{
				vec4 gl_Position;
			};
			
			void main()
			{
				vec4 tfrmdPos = gWorldTransform * vec4(bs_position.xy, 0, 1);

				float tfrmdX = -1.0f + (tfrmdPos.x * gInvViewportWidth);
				float tfrmdY = 1.0f - (tfrmdPos.y * gInvViewportHeight);

				gl_Position = vec4(tfrmdX, tfrmdY, 0, 1);
				texcoord0 = bs_texcoord0;
			}
		};
		
		Fragment =
		{
			layout (binding = 1) uniform sampler2D gMainTexture;
			
			layout (location = 0) in vec2 texcoord0;
			layout (location = 0) out vec4 fragColor;

			void main()
			{
				vec4 color = vec4(gTint.rgb, texture(gMainTexture, texcoord0.st).r * gTint.a);
				fragColor = color;
			}
		};
	};
};