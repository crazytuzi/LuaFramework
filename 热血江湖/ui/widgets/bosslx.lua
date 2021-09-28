--version = 1
local l_fileType = "node"

local UIUtil = require "ui/common/UIUtil"

--EDITOR elements start tag
local eleRoot = 
{
	prop = {
		etype = "Layer",
		name = "root",
		posX = 0,
		posY = 0,
		anchorX = 0,
		anchorY = 0,
	},
	children = {
	{
		prop = {
			etype = "Grid",
			name = "ysjm",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "kk1",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9023438,
				sizeY = 0.9722222,
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.1,
				scale9Bottom = 0.1,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "bj",
					varName = "bossImg",
					posX = 0.4654274,
					posY = 0.4000889,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.4415584,
					sizeY = 0.7314286,
					image = "bossbj#bossbj",
				},
				children = {
				{
					prop = {
						etype = "Particle",
						name = "heiyan",
						sizeXAB = 306,
						sizeYAB = 128,
						posXAB = 399.8842,
						posYAB = 149.203,
						posX = 0.7840867,
						posY = 0.2914121,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6,
						sizeY = 0.25,
						angle = 0,
						angleVariance = 360,
						blendFuncDestination = 771,
						blendFuncSource = 770,
						duration = 999999,
						emitterType = 0,
						finishColorAlpha = 0,
						finishColorBlue = 0,
						finishColorGreen = 0,
						finishColorRed = 0,
						middleColorAlpha = 0.5,
						middleColorBlue = 1,
						middleColorGreen = 1,
						middleColorRed = 1,
						finishParticleSize = 400,
						startParticleSize = 150,
						maxParticles = 10,
						particleLifespan = 3,
						particleLifespanVariance = 1,
						particleLifeMiddle = 0.3,
						sourcePositionVariancex = 250,
						sourcePositionVariancey = 150,
						startColorAlpha = 0,
						textureFileName = "uieffect/065.png",
						useMiddleFrame = true,
					},
				},
				{
					prop = {
						etype = "Particle",
						name = "yanwu",
						sizeXAB = 306,
						sizeYAB = 128,
						posXAB = 399.4383,
						posYAB = 241.3185,
						posX = 0.7832123,
						posY = 0.4713251,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6,
						sizeY = 0.25,
						angle = 0,
						angleVariance = 360,
						duration = 999999,
						emitterType = 0,
						finishColorBlue = 0,
						finishColorGreen = 0,
						finishColorRed = 0,
						middleColorAlpha = 0.7,
						middleColorBlue = 1,
						middleColorGreen = 0.5019608,
						middleColorRed = 0.5019608,
						finishParticleSize = 500,
						startParticleSize = 150,
						gravityy = 10,
						maxParticles = 10,
						particleLifespanVariance = 2,
						particleLifeMiddle = 0.3,
						sourcePositionVariancex = 300,
						sourcePositionVariancey = 100,
						textureFileName = "uieffect/E_yanhuo_66.png",
						useMiddleFrame = true,
					},
				},
				{
					prop = {
						etype = "Particle",
						name = "xx",
						sizeXAB = 306,
						sizeYAB = 128,
						posXAB = 398.1011,
						posYAB = 176.1037,
						posX = 0.7805905,
						posY = 0.3439525,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6,
						sizeY = 0.25,
						duration = 999999,
						emitterType = 0,
						middleColorAlpha = 1,
						middleColorBlue = 1,
						middleColorGreen = 1,
						middleColorRed = 1,
						finishParticleSize = 0,
						finishParticleSizeVariance = 10,
						startParticleSize = 200,
						startParticleSizeVariance = 100,
						middleParticleSize = 0,
						middleParticleSizeVariance = 100,
						gravityy = 20,
						maxParticles = 20,
						particleLifespan = 2,
						particleLifespanVariance = 0.5,
						particleLifeMiddle = 0.3,
						sourcePositionVariancex = 200,
						sourcePositionVariancey = 150,
						textureFileName = "uieffect/d3gd.png",
					},
				},
				{
					prop = {
						etype = "Particle",
						name = "qpx",
						sizeXAB = 306,
						sizeYAB = 128,
						posXAB = 402.559,
						posYAB = 323.6528,
						posX = 0.7893314,
						posY = 0.6321343,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6,
						sizeY = 0.25,
						duration = 999999,
						emitterType = 0,
						finishColorAlpha = 0,
						middleColorAlpha = 1,
						middleColorBlue = 1,
						middleColorGreen = 1,
						middleColorRed = 1,
						finishParticleSize = 0,
						finishParticleSizeVariance = 10,
						startParticleSize = 50,
						startParticleSizeVariance = 20,
						maxParticles = 15,
						particleLifespan = 2,
						particleLifespanVariance = 0.5,
						particleLifeMiddle = 0.5,
						sourcePositionVariancex = 550,
						sourcePositionVariancey = 300,
						startColorAlpha = 0,
						textureFileName = "uieffect/lizi0416111.png",
						useMiddleFrame = true,
					},
				},
				{
					prop = {
						etype = "Particle",
						name = "gy",
						sizeXAB = 306,
						sizeYAB = 128,
						posXAB = 396.3186,
						posYAB = 144.3226,
						posX = 0.7770954,
						posY = 0.2818801,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6,
						sizeY = 0.25,
						duration = 999999,
						emitterType = 0,
						finishColorBlue = 0,
						finishColorGreen = 0,
						finishColorRed = 0,
						middleColorAlpha = 1,
						middleColorBlue = 1,
						middleColorGreen = 1,
						middleColorRed = 1,
						finishParticleSize = 600,
						startParticleSize = 250,
						maxParticles = 10,
						particleLifespan = 3,
						particleLifespanVariance = 1,
						particleLifeMiddle = 0.3,
						textureFileName = "uieffect/036fsg.png",
						useMiddleFrame = true,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "bt",
						varName = "holidayRoot",
						posX = 0.5,
						posY = 0.06476063,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 1,
						sizeY = 0.1237767,
						image = "d#bt",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "sjz",
							varName = "holidayText",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9545929,
							sizeY = 1.092701,
							text = "xxx",
							color = "FFC93034",
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "bosslx",
				varName = "bossUI",
				posX = 0.6218954,
				posY = 0.4502654,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6337768,
				sizeY = 0.8343711,
				image = "a",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "xsk4",
					posX = 0.4865023,
					posY = 0.8967898,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9566907,
					sizeY = 0.1791184,
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
					alpha = 0.7,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lb",
						varName = "bossScroll",
						posX = 0.4821262,
						posY = 0.5092934,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9508365,
						sizeY = 0.9688135,
						horizontal = true,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xsk3",
					varName = "detail",
					posX = 0.7257234,
					posY = 0.4009512,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4474663,
					sizeY = 0.8127546,
					scale9 = true,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
					alpha = 0.7,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "bzm8",
						posX = 0.2355378,
						posY = 0.9495649,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4017448,
						sizeY = 0.1129261,
						text = "刷新时间：",
						color = "FF966856",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "RichText",
						name = "bzm9",
						varName = "refreshTime",
						posX = 0.6698586,
						posY = 0.9215307,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6351913,
						sizeY = 0.1098986,
						text = "12:00;15:00;19:0012:00;15:00;19:00",
						color = "FF65944D",
						fontOutlineColor = "FF27221D",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "bzm10",
						posX = 0.2355377,
						posY = 0.8218745,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4017448,
						sizeY = 0.1129261,
						text = "上次击败：",
						color = "FF966856",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "bzm11",
						varName = "lastTimeKill",
						posX = 0.6698587,
						posY = 0.8218745,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6351913,
						sizeY = 0.1098986,
						text = "服务器第一最人性",
						color = "FF966856",
						fontOutlineColor = "FF27221D",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "bzm12",
						posX = 0.2355378,
						posY = 0.7228572,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4017448,
						sizeY = 0.1129261,
						text = "当前状态：",
						color = "FF966856",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "bzm13",
						varName = "currentState",
						posX = 0.6698587,
						posY = 0.7228569,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6351913,
						sizeY = 0.1098986,
						text = "战斗中",
						color = "FF65944D",
						fontOutlineColor = "FF27221D",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "seach5",
						varName = "startFightBtn",
						posX = 0.77,
						posY = 0.111056,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4490358,
						sizeY = 0.1310777,
						image = "chu1#an1",
						imageNormal = "chu1#an1",
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "wz5",
							posX = 0.5,
							posY = 0.546875,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9345642,
							sizeY = 0.8344491,
							text = "立即前往",
							fontSize = 24,
							fontOutlineEnable = true,
							fontOutlineColor = "FFB35F1D",
							fontOutlineSize = 2,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "smd",
						posX = 0.4979314,
						posY = 0.4233322,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.001109,
						sizeY = 0.4362429,
						scale9 = true,
						scale9Top = 0.3,
						scale9Bottom = 0.3,
						alpha = 0.7,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "zsx",
							posX = 0.5,
							posY = 1.001558,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7732472,
							sizeY = 0.1502348,
							image = "chu1#top3",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "das",
								posX = 0.5,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.8912795,
								sizeY = 0.8998108,
								text = "物品掉落",
								color = "FFF1E9D7",
								fontOutlineEnable = true,
								fontOutlineColor = "FFA47848",
								fontOutlineSize = 2,
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "dj1",
							varName = "drop1",
							posX = 0.197148,
							posY = 0.6822943,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.2476592,
							sizeY = 0.4269829,
							image = "djk#ktong",
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "an1",
								varName = "dropBtn1",
								posX = 0.5,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1,
								sizeY = 1,
							},
						},
						{
							prop = {
								etype = "Image",
								name = "djt1",
								varName = "dropIcon1",
								posX = 0.5,
								posY = 0.539497,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.8,
								sizeY = 0.8,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "dj2",
							varName = "drop2",
							posX = 0.4999516,
							posY = 0.6822942,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.2476592,
							sizeY = 0.4269829,
							image = "djk#ktong",
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "an2",
								varName = "dropBtn2",
								posX = 0.5,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1,
								sizeY = 1,
							},
						},
						{
							prop = {
								etype = "Image",
								name = "djt2",
								varName = "dropIcon2",
								posX = 0.5,
								posY = 0.539497,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.8,
								sizeY = 0.8,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "dj3",
							varName = "drop3",
							posX = 0.8027551,
							posY = 0.6822942,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.2476592,
							sizeY = 0.4269829,
							image = "djk#ktong",
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "an3",
								varName = "dropBtn3",
								posX = 0.5,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1,
								sizeY = 1,
							},
						},
						{
							prop = {
								etype = "Image",
								name = "djt3",
								varName = "dropIcon3",
								posX = 0.5,
								posY = 0.539497,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.8,
								sizeY = 0.8,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "dj4",
							varName = "drop4",
							posX = 0.197148,
							posY = 0.2222829,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.2476592,
							sizeY = 0.4269829,
							image = "djk#ktong",
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "an4",
								varName = "dropBtn4",
								posX = 0.5,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1,
								sizeY = 1,
							},
						},
						{
							prop = {
								etype = "Image",
								name = "djt4",
								varName = "dropIcon4",
								posX = 0.5,
								posY = 0.539497,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.8,
								sizeY = 0.8,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "dj5",
							varName = "drop5",
							posX = 0.4999515,
							posY = 0.2222829,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.2476592,
							sizeY = 0.4269829,
							image = "djk#ktong",
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "an5",
								varName = "dropBtn5",
								posX = 0.5,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1,
								sizeY = 1,
							},
						},
						{
							prop = {
								etype = "Image",
								name = "djt5",
								varName = "dropIcon5",
								posX = 0.5,
								posY = 0.539497,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.8,
								sizeY = 0.8,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "dj6",
							varName = "drop6",
							posX = 0.8027549,
							posY = 0.2222829,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.2476592,
							sizeY = 0.4269829,
							image = "djk#ktong",
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "an6",
								varName = "dropBtn6",
								posX = 0.5,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1,
								sizeY = 1,
							},
						},
						{
							prop = {
								etype = "Image",
								name = "djt6",
								varName = "dropIcon6",
								posX = 0.5,
								posY = 0.539497,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.8,
								sizeY = 0.8,
							},
						},
						},
					},
					},
				},
				{
					prop = {
						etype = "Button",
						name = "seach6",
						varName = "distributeBtn",
						posX = 0.23,
						posY = 0.111056,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4490358,
						sizeY = 0.1310777,
						image = "chu1#an2",
						imageNormal = "chu1#an2",
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "wz6",
							posX = 0.5,
							posY = 0.546875,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9345642,
							sizeY = 0.8344491,
							text = "分配记录",
							fontSize = 24,
							fontOutlineEnable = true,
							fontOutlineColor = "FF2A6953",
							fontOutlineSize = 2,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xsk5",
					varName = "nameAndModel",
					posX = 0.2584453,
					posY = 0.7641165,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4240209,
					sizeY = 0.05992537,
					image = "chu1#top2",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					alpha = 0.7,
				},
				children = {
				{
					prop = {
						etype = "RichText",
						name = "js2",
						varName = "bossName",
						posX = 0.3542851,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.572872,
						sizeY = 1,
						text = "名字五个字",
						color = "FFF1E9D7",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FFA47848",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "RichText",
						name = "js4",
						varName = "bossLvl",
						posX = 0.7664866,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3726595,
						sizeY = 1,
						text = "Lv.100",
						color = "FFF1E9D7",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FFA47848",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Sprite3D",
					name = "mx",
					varName = "bossModel",
					posX = 0.274505,
					posY = 0.1056833,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2879195,
					sizeY = 0.5716816,
				},
			},
			},
		},
		},
	},
	},
}
--EDITOR elements end tag
--EDITOR animations start tag
local l_animations =
{
	c_dakai = {
		{2,"heiyan", 1, 0},
		{2,"yanwu", 1, 0},
		{2,"xx", 1, 0},
		{2,"qpx", 1, 0},
		{2,"gy", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
