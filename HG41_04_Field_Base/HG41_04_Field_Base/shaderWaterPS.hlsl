

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
    float4 Parameter;

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

    outDiffuse = 1.0;

	float2 windWay;
	windWay = float2(1.0, 1.0);//��B
	windWay.x = -1.3;
	windWay.y = 3.4;
	float waveHeight = 0.05;
	int test = 6;
	test = 20;
	float dx = sin((inTexCoord.x - 0.001)*0.3)*4.0 -
		sin((inTexCoord.x - 0.001)*0.3)*4.0;

	dx = fbm2((inTexCoord + float2(0.001, 0.0))*waveHeight, test, Parameter.x*windWay.x)
		- fbm2((inTexCoord - float2(0.001, 0.0))*waveHeight, test, Parameter.x*windWay.x);


	float dz = 0.0;
	//Param.x����Z����ƃX�v���C�g�̗��ꂪ�����Ȃ�B
	//float2�Ɋ|�����Ă��鐔����傫������Ƃ��ׂ����g�ɂł���
	dz = fbm2((inTexCoord + float2(0.0, 0.001))*waveHeight, test, Parameter.x*windWay.y)
		- fbm2((inTexCoord - float2(0.0, 0.001))*waveHeight, test, Parameter.x*windWay.y);



	float3 normal = float3(-dx, 0.001, -dz);//y�̐�����傫������Ɖ��ʂ��傫���Ȃ�B
	normal = normalize(normal);

	float3 lightDir = float3(1.0, -1.0, 1.0);
	lightDir = normalize(lightDir);

	float3 eyev = inWorldPosition.xyz - CameraPosition.xyz;
	eyev = normalize(eyev);
/*	//�t�H��
	float3 ref = reflect(lightDir, normal);

	float spec = saturate(-dot(ref, eyev));
	spec = pow(spec, 20);
	outDiffuse.rgb = spec * 1.0;*/
	//�t���l���̎�

	float fresnel = saturate(1.0 + dot(eyev, normal));
	fresnel = 0.05 + (1.0 - 0.05)*pow(fresnel, 5);

	outDiffuse.rgb = float3(0.0, 0.1, 0.1)*(1.0 - fresnel)
		+ float3(0.55, 0.65, 1.0)*fresnel;

	outDiffuse.a = 0.75;
	//float depth = distance(CameraPosition.xyz, inWorldPosition.xyz)*0.03;
	//depth= saturate(depth);
	//outDiffuse.a = abs(depth-1.0);

}
