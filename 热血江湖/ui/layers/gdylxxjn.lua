--version = 1
local l_fileType = "layer"

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
			etype = "Image",
			name = "ddd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1.00382,
			sizeY = 1.006678,
			image = "b#dd",
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dd",
				posX = 0.501165,
				posY = 0.4993107,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9937822,
				sizeY = 0.9931148,
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "ysjm",
			posX = 0.4996093,
			posY = 0.5006931,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1.000699,
			sizeY = 0.9941995,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "background",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9993014,
				sizeY = 1.005834,
				image = "gdyljn#gdyljn",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sm",
				posX = 0.171122,
				posY = 0.8354961,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2065461,
				sizeY = 0.1562069,
				image = "b#pao",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
			},
			children = {
			{
				prop = {
					etype = "RichText",
					name = "wb",
					varName = "skillDesc",
					posX = 0.4735814,
					posY = 0.4821444,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.8943485,
					sizeY = 0.7857029,
					text = "技能名称",
					color = "FFFFD97F",
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb2",
					varName = "scroll",
					posX = 0.4735813,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8943484,
					sizeY = 0.7857029,
				},
			},
			},
		},
		{
			prop = {
				etype = "Sprite3D",
				name = "npc_model",
				varName = "npcModel",
				posX = 0.2887658,
				posY = 0.5014817,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.2159231,
				sizeY = 0.472978,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jn1",
				varName = "skillBg1",
				posX = 0.5085877,
				posY = 0.4728044,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1061758,
				sizeY = 0.1899909,
				image = "guidaoyuling1#jnd",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "select",
					varName = "skillSelect1",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9230755,
					sizeY = 0.8718129,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "icon",
					varName = "skillIcon1",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8823528,
					sizeY = 0.8823531,
					image = "skillnew#gankunmoyin",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "lock",
					varName = "skillLock1",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.9985391,
					sizeY = 0.8955969,
					image = "ji#suo",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn",
					varName = "skillBtn1",
					posX = 0.4852942,
					posY = 0.485294,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "mz",
					varName = "skillName1",
					posX = 0.5,
					posY = 0.02205856,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7941173,
					sizeY = 0.2352941,
					image = "guidaoyuling1#gankunmoyin",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jn2",
				varName = "skillBg2",
				posX = 0.5085877,
				posY = 0.6569223,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0733862,
				sizeY = 0.1313173,
				image = "guidaoyuling1#jndt1",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "select2",
					varName = "skillSelect2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9230755,
					sizeY = 0.8718129,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "icon2",
					varName = "skillIcon2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8510638,
					sizeY = 0.8510635,
					image = "skillnew#mushenwu",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "lock2",
					varName = "skillLock2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.9950055,
					sizeY = 0.8924273,
					image = "ji#suo",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn2",
					varName = "skillBtn2",
					posX = 0.4473892,
					posY = 0.5299551,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "mz2",
					varName = "skillName2",
					posX = 0.5,
					posY = 0.02205856,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.148936,
					sizeY = 0.3404254,
					image = "guidaoyuling1#yuhuojie",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jn3",
				varName = "skillBg3",
				posX = 0.4122943,
				posY = 0.4644345,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0733862,
				sizeY = 0.1313173,
				image = "guidaoyuling1#jndt1",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "select3",
					varName = "skillSelect3",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.217674,
					sizeY = 1.150051,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "icon3",
					varName = "skillIcon3",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8510638,
					sizeY = 0.8510635,
					image = "skillnew#mushenwu",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "lock3",
					varName = "skillLock3",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9950055,
					sizeY = 0.8924274,
					image = "ji#suo",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn3",
					varName = "skillBtn3",
					posX = 0.4473892,
					posY = 0.5299551,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9308392,
					sizeY = 0.903199,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "mz3",
					varName = "skillName3",
					posX = 0.5,
					posY = 0.02205856,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.148936,
					sizeY = 0.3404254,
					image = "guidaoyuling1#mushenwu",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jn4",
				varName = "skillBg4",
				posX = 0.6063978,
				posY = 0.4644345,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0733862,
				sizeY = 0.1313173,
				image = "guidaoyuling1#jndt1",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "select4",
					varName = "skillSelect4",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.217674,
					sizeY = 1.150051,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "icon4",
					varName = "skillIcon4",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8510638,
					sizeY = 0.8510635,
					image = "skillnew#mushenwu",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "lock4",
					varName = "skillLock4",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 1.031915,
					sizeY = 0.9255316,
					image = "ji#suo",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn4",
					varName = "skillBtn4",
					posX = 0.4473892,
					posY = 0.5299551,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9308392,
					sizeY = 0.903199,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "mz4",
					varName = "skillName4",
					posX = 0.5,
					posY = 0.02205856,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.148936,
					sizeY = 0.3404254,
					image = "guidaoyuling1#pushuizhou",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "learnBtn",
				posX = 0.5097428,
				posY = 0.1331931,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1075603,
				sizeY = 0.06834115,
				image = "chu1#an1",
				imageNormal = "chu1#an1",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "name",
					varName = "learnText",
					posX = 0.4962216,
					posY = 0.5200156,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8125014,
					sizeY = 0.6399936,
					text = "学习天眼术",
					fontSize = 18,
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
				etype = "RichText",
				name = "tj",
				varName = "needReputation",
				posX = 0.505846,
				posY = 0.07909124,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2883866,
				sizeY = 0.08263053,
				text = "所需声望：xx",
				color = "FFADADAD",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "tips",
				varName = "tips",
				posX = 0.5077943,
				posY = 0.2761502,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.2501953,
				sizeY = 0.1032075,
				text = "玩法简单说明",
				color = "FFFFAC4B",
			},
		},
		{
			prop = {
				etype = "Scroll",
				name = "lb",
				varName = "descScroll",
				posX = 0.5077943,
				posY = 0.2566246,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2576324,
				sizeY = 0.1617852,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "closeBtn",
				posX = 0.6865873,
				posY = 0.7249171,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1007108,
				sizeY = 0.1327142,
				image = "baiguiyuling#guanbi",
				imageNormal = "baiguiyuling#guanbi",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "biaoti",
				posX = 0.5064759,
				posY = 0.8410707,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2115708,
				sizeY = 0.1173473,
				image = "guidaoyuling1#jsjn",
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "ysjm1",
				posX = 0.5,
				posY = 0.7690032,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "gc",
					posX = 0.5,
					posY = 0.4986111,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1,
					sizeY = 0.08888889,
					image = "uieffect/sjfs.png",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jiantou",
					posX = 0.4982291,
					posY = 0.4688689,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2272727,
					sizeY = 0.3628118,
					image = "uieffect/jiantou2.png",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jiantou2",
					posX = 0.4982291,
					posY = 0.4688689,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2272727,
					sizeY = 0.3628118,
					image = "uieffect/jiantou1.png",
					alpha = 0,
					blendFunc = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "guang4",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2272727,
					sizeY = 0.3628118,
					image = "uieffect/guang2.png",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "guang3",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2272727,
					sizeY = 0.3628118,
					image = "uieffect/guang2.png",
					alpha = 0,
					blendFunc = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "guang2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2272727,
					sizeY = 0.3628118,
					image = "uieffect/guang2.png",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "guang1",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1987166,
					sizeY = 0.3172257,
					image = "uieffect/guang.png",
					alpha = 0,
					rotation = 20,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "guang",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = -0.2074006,
					sizeY = -0.3310886,
					image = "uieffect/guang.png",
					effect = "particles",
					alpha = 0,
					blendFunc = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "wc",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1429688,
					sizeY = 0.09027778,
					image = "bp#cz",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Particle",
					name = "ttttt5",
					sizeXAB = 768.5369,
					sizeYAB = 178.9559,
					posXAB = 953.5284,
					posYAB = 382.7769,
					posX = 0.7444237,
					posY = 0.5347363,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.25,
					angle = 0,
					duration = 1,
					emitterType = 0,
					emissionRate = 100,
					finishColorBlue = 0,
					finishColorGreen = 0,
					finishColorRed = 0,
					middleColorAlpha = 1,
					middleColorBlue = 1,
					middleColorGreen = 1,
					middleColorRed = 1,
					rotationStart = 30,
					rotationStartVariance = 30,
					finishParticleSize = 10,
					finishParticleSizeVariance = 15,
					startParticleSize = 40,
					startParticleSizeVariance = 20,
					middleParticleSize = 40,
					middleParticleSizeVariance = 10,
					gravityy = 200,
					maxParticles = 7,
					maxRadius = 50,
					minRadius = 50,
					particleLifespan = 1,
					particleLifeMiddle = 0.4,
					rotatePerSecond = 60,
					sourcePositionVariancex = 180,
					sourcePositionVariancey = 80,
					sourcePositionx = 50,
					sourcePositiony = 50,
					textureFileName = "uieffect/star.png",
					useMiddleFrame = true,
				},
			},
			{
				prop = {
					etype = "Particle",
					name = "ttttt6",
					sizeXAB = 768.5369,
					sizeYAB = 178.9559,
					posXAB = 905.8471,
					posYAB = 324.0341,
					posX = 0.7071987,
					posY = 0.4526731,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.25,
					angle = 0,
					angleVariance = 360,
					duration = 1,
					emitterType = 0,
					emissionRate = 100,
					finishColorBlue = 0,
					finishColorGreen = 0,
					finishColorRed = 0,
					middleColorAlpha = 1,
					middleColorBlue = 1,
					middleColorGreen = 1,
					middleColorRed = 1,
					rotationStart = 30,
					rotationStartVariance = 30,
					finishParticleSize = 10,
					finishParticleSizeVariance = 15,
					startParticleSize = 40,
					startParticleSizeVariance = 20,
					middleParticleSize = 40,
					middleParticleSizeVariance = 10,
					gravityy = 100,
					maxParticles = 7,
					maxRadius = 50,
					minRadius = 50,
					particleLifespan = 1,
					particleLifeMiddle = 0.4,
					rotatePerSecond = 60,
					sourcePositionVariancex = 50,
					sourcePositionVariancey = 50,
					sourcePositionx = 100,
					sourcePositiony = 100,
					speed = 100,
					textureFileName = "uieffect/811.png",
					useMiddleFrame = true,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "bao1",
					posX = 0.5008854,
					posY = 0.5028288,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2272727,
					sizeY = 0.3628118,
					image = "uieffect/004guangyun.png",
					alpha = 0,
					blendFunc = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "bao",
					posX = 0.5008854,
					posY = 0.5028288,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2272727,
					sizeY = 0.3628118,
					image = "uieffect/016fangshe.png",
					alpha = 0,
					blendFunc = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "sj",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1429688,
					sizeY = 0.09027778,
					image = "guidaoyuling1#xuexiwanc",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "sj2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1429688,
					sizeY = 0.09027778,
					image = "guidaoyuling1#xuexiwanc",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "sj3",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1429688,
					sizeY = 0.09027778,
					image = "guidaoyuling1#xuexiwanc",
					alpha = 0,
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "jqtx",
				posX = 0.5,
				posY = 0.7829809,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.8,
				sizeY = 0.8,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "bao3",
					posX = 0.5038109,
					posY = 0.4820316,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2530461,
					sizeY = 0.4039557,
					image = "uieffect/shanguang_00058.png",
					alpha = 0,
					blendFunc = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "bao4",
					posX = 0.5008854,
					posY = 0.4855348,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2840909,
					sizeY = 0.4535147,
					image = "uieffect/004guangyun.png",
					alpha = 0,
					blendFunc = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "bao6",
					posX = 0.5,
					posY = 0.4861332,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2840909,
					sizeY = 0.4535147,
					image = "uieffect/028_guangyun.png",
					alpha = 0,
					blendFunc = 1,
				},
			},
			{
				prop = {
					etype = "Particle",
					name = "lizi",
					sizeXAB = 614.8295,
					sizeYAB = 143.1647,
					posXAB = 818.6149,
					posYAB = 350.2981,
					posX = 0.7988702,
					posY = 0.6117046,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.25,
					angle = 0,
					angleVariance = 360,
					duration = 0.5,
					emissionRate = 1000,
					finishParticleSize = 0,
					startParticleSize = 200,
					startParticleSizeVariance = 30,
					maxParticles = 10,
					maxRadius = 40,
					maxRadiusVariance = 40,
					minRadius = 150,
					minRadiusVariance = 100,
					particleLifespan = 0.5,
					startColorBlue = 1,
					startColorGreen = 1,
					startColorRed = 1,
					textureFileName = "uieffect/lizi041161121.png",
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
	wc = {
		guang = {
			alpha = {{0, {1}}, {1200, {1}}, {1500, {0}}, },
			rotate = {{0, {360}}, {1500, {90}}, },
		},
		guang2 = {
			alpha = {{0, {1}}, {1200, {1}}, {1600, {0}}, },
		},
		guang1 = {
			rotate = {{0, {360}}, {1500, {-90}}, },
			alpha = {{0, {1}}, {1200, {1}}, {1500, {0}}, },
		},
		guang3 = {
			alpha = {{0, {1}}, {1200, {1}}, {1500, {0}}, },
			scale = {{0, {3, 0.1, 1}}, },
		},
		guang4 = {
			alpha = {{0, {1}}, {1200, {1}}, {1500, {0}}, },
			scale = {{0, {2, 0.1, 1}}, },
		},
	},
	ziti = {
		wc = {
			alpha = {{0, {1}}, {1200, {1}}, {1500, {0}}, },
			scale = {{0, {2, 2, 1}}, {150, {1,1,1}}, },
		},
	},
	baozha = {
		bao = {
			scale = {{0, {0, 0, 1}}, {150, {4.5, 4.5, 1}}, },
			alpha = {{0, {1}}, {50, {1}}, {150, {0}}, },
		},
		bao1 = {
			alpha = {{0, {0.5}}, {50, {0.5}}, {200, {0}}, },
			scale = {{0, {3.5, 3.5, 1}}, {50, {4, 4, 1}}, {200, {1, 1, 1}}, },
		},
	},
	jiantou = {
		jiantou = {
			move = {{0, {564.1985,371.7679,0}}, {800, {564.1985, 410, 0}}, },
			alpha = {{0, {0}}, {100, {1}}, {600, {1}}, {800, {0}}, },
		},
		jiantou2 = {
			move = {{0, {564.1985,371.7679,0}}, {800, {564.1985, 410, 0}}, },
			alpha = {{0, {0}}, {100, {1}}, {600, {1}}, {800, {0}}, },
		},
	},
	sj = {
		sj = {
			scale = {{0, {12, 12, 1}}, {150, {1,1,1}}, },
			alpha = {{0, {1}}, {2200, {1}}, {3000, {0}}, },
		},
	},
	sj2 = {
		sj2 = {
			scale = {{0, {8, 8, 1}}, {150, {1,1,1}}, },
			alpha = {{0, {1}}, {150, {1}}, {200, {0}}, },
		},
	},
	sj3 = {
		sj3 = {
			alpha = {{0, {1}}, {300, {0}}, },
			scale = {{0, {1,1,1}}, {300, {2, 2, 1}}, },
		},
	},
	gc = {
		gc = {
			scale = {{0, {1,1,1}}, {50, {3, 3, 1}}, {1200, {3.5, 3.5, 1}}, },
			alpha = {{0, {1}}, {1200, {0}}, },
		},
	},
	bao = {
		bao3 = {
			scale = {{0, {1, 1, 1}}, {150, {2, 2, 1}}, },
			alpha = {{0, {1}}, {500, {0}}, },
		},
	},
	bao2 = {
		bao4 = {
			scale = {{0, {1, 1, 1}}, {200, {8, 8, 1}}, },
			alpha = {{50, {1}}, {200, {0}}, },
		},
	},
	bao4 = {
		bao6 = {
			alpha = {{0, {1}}, {500, {0}}, },
			scale = {{0, {0, 0, 1}}, {50, {1, 1, 1}}, {500, {1.5, 1.5, 1}}, },
		},
	},
	c_desad = {
		{0,"sj", 1, 0},
		{0,"sj2", 1, 50},
		{0,"sj3", 1, 150},
		{0,"gc", 1, 150},
		{0,"baozha", 1, 150},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
