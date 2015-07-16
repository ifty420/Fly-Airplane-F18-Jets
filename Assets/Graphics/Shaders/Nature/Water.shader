﻿Shader "Custom/Water" 
{
	Properties 
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_ReflectColor ("Reflection Color", Color) = (1,1,1,0.5)
		_Height ("Bump level", Range (0.0, 1)) = 1
		_MainTex ("Base (RGB) RefStrength (A)", 2D) = "white" {}
		_Cube ("Reflection Cubemap", Cube) = "_Skybox" { TexGen CubeReflect }
		_BumpMap ("Normalmap", 2D) = "bump" {}
	}

	SubShader 
	{
		Tags {"RenderType"="Transparent" "Queue" = "Transparent"}
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Lambert alpha
		#pragma exclude_renderers d3d11_9x

		sampler2D _MainTex;
		sampler2D _BumpMap;
		samplerCUBE _Cube;

		fixed4 _Color;
		fixed4 _ReflectColor;
		fixed _Height;

		struct Input 
		{
			float2 uv_MainTex;
			float2 uv_BumpMap;
			float3 worldRefl;
			INTERNAL_DATA
		};

		void surf (Input IN, inout SurfaceOutput o) 
		{
			fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
			fixed4 c = tex * _Color;
			o.Albedo = c.rgb;
			
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
			
			float3 worldRefl = WorldReflectionVector (IN, o.Normal);
			fixed4 reflcol = texCUBE (_Cube, worldRefl);
			reflcol *= tex.a;
			o.Emission = reflcol.rgb * _ReflectColor.rgb;
			o.Alpha = _Color.a;
		}
		ENDCG
	}

	FallBack "Reflective/VertexLit"
}