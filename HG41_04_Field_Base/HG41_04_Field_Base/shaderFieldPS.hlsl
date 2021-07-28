

#include "shaderNoise.hlsl"

Texture2D		g_Texture : register(t0);
SamplerState	g_SamplerState : register(s0);


// �萔�o�b�t�@
cbuffer ConstatntBuffer : register(b0)
{
    matrix World;
    matrix View;
    matrix Projection;

    float4 CameraPosition;
}

struct LIGHT {
	float4 Direction;
	float4 Diffuse;
	float4 Ambient;
};

cbuffer LightBuffer:register(b1) {
	LIGHT Light;
}

//=============================================================================
// �s�N�Z���V�F�[�_
//=============================================================================
void main( in  float4 inPosition		: SV_POSITION,
            in float4 inWorldPosition   : POSITION0,
			in  float4 inNormal			: NORMAL0,
			in  float4 inDiffuse		: COLOR0,
			in  float2 inTexCoord		: TEXCOORD0,

			out float4 outDiffuse		: SV_Target )
{
    
//	outDiffuse = g_Texture.Sample(g_SamplerState, inTexCoord);
//�n�`�̍������Ƃɕ`�悳���e�N�X�`����ύX����	
	float soil = fbm2(inTexCoord*0.1, 16);

	if (soil < 0.15)//���̍����ȉ��Ȃ炠�炩���ߗp�ӂ���Ă����e�N�X�`��
		outDiffuse = g_Texture.Sample(g_SamplerState, inTexCoord);
	else {//���ȏ�ł���΃v���V�[�W�����e�N�X�`���𒣂�t����
		outDiffuse.rgb = (fbm2(inTexCoord*0.1, 16)*0.5+0.5)*float3(0.7, 0.9, 0.4)*random2(inTexCoord)*2.0;
		outDiffuse.a = 1.0;
	}
	float3 difx = fbm3(float3(0.001,0.0,0.0),10);

	
	float dx = sin((inTexCoord.x - 0.001)*0.3)*4.0 -
		sin((inTexCoord.x - 0.001)*0.3)*4.0;

	dx = fbm2((inTexCoord + float2(0.001, 0.0))*0.05,10)*10.0
		- fbm2((inTexCoord - float2(0.001, 0.0))*0.05,10)*10.0;
	
	dx = dispMap(inTexCoord + float2(0.001, 0.0))
		- dispMap(inTexCoord - float2(0.001, 0.0));

	float dz = 0.0;

	dz= fbm2((inTexCoord + float2(0.0, 0.001))*0.05,10)*10.0
		- fbm2((inTexCoord - float2(0.0, 0.001))*0.05,10)*10.0;

	dz = dispMap(inTexCoord + float2(0.0, 0.001))
		- dispMap(inTexCoord - float2(0.0, 0.001));
	float2 rand = fbm2(inTexCoord*0.5,10)+0.5;

	if (inWorldPosition.y+rand.y> 0.5) {
		outDiffuse.rgb = (1.0, 1.0, 1.0);
	}

	float3 normal = float3(-dx, 0.001,-dz);
	normal = normalize(normal);

	float3 lightDir = Light.Direction.xyz;
	lightDir = normalize(lightDir);

	float light = saturate(0.5 - dot(normal,lightDir)*0.9);
	outDiffuse.rgb *= light;


	/*float MaxHeight = 10.0;
	float MinHeight = 0.0;
	float alpha = clamp((inWorldPosition.y - MinHeight) / (MaxHeight - MinHeight), 0.0, 1.0);
	outDiffuse.rgb = outDiffuse.rgb*alpha*float3(0.3, 0.3, 0.3)*(1.0 - alpha);�������Â��`�悷�邽�߁B���̍����ȉ��ł���ΈÂ��`��B
*/
	float fog = distance(CameraPosition.xyz, inWorldPosition.xyz)*0.03;
	fog = saturate(fog);//��C�U�����N����

	outDiffuse.rgb = outDiffuse.rgb*(1.0 - fog)+float3(0.52, 0.63, 1.0)*fog;


}
