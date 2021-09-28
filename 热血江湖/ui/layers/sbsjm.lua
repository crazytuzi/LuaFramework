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
			sizeX = 1,
			sizeY = 1,
			image = "b#dd",
			scale9 = true,
			scale9Left = 0.2,
			scale9Right = 0.2,
			scale9Top = 0.2,
			scale9Bottom = 0.2,
			alpha = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dd",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "kk",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			layoutType = 5,
			layoutTypeW = 5,
		},
		children = {
		{
			prop = {
				etype = "Grid",
				name = "kong",
				varName = "kong",
				posX = 0.4032844,
				posY = 0.09853137,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1070313,
				sizeY = 0.06666667,
			},
		},
		},
	},
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
				name = "dt",
				posX = 0.5,
				posY = 0.4513885,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3984375,
				sizeY = 0.8611111,
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "wasd",
					posX = 0.5,
					posY = 0.5564515,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 0.7603773,
					image = "b#cs",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.2,
					scale9Bottom = 0.7,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "tswb2",
						varName = "tips",
						posX = 0.5,
						posY = 0.5849311,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7443666,
						sizeY = 0.1447436,
						text = "在神兵变身后自动依次施放技能",
						color = "FFC93034",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "kk1",
					posX = 0.5,
					posY = 0.7571911,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8635877,
					sizeY = 0.2246099,
					image = "b#d2",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "x1",
						varName = "now_label",
						posX = 0.3465345,
						posY = 0.7866575,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2855532,
						sizeY = 0.278841,
						text = "等级：",
						color = "FF966856",
						fontSize = 22,
						fontOutlineColor = "FF402B00",
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "x2",
						varName = "skill_lvl",
						posX = 0.6603864,
						posY = 0.7866575,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2855534,
						sizeY = 0.278841,
						text = "10级",
						color = "FF966856",
						fontSize = 22,
						fontOutlineColor = "FF402B00",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "RichText",
						name = "wb1",
						varName = "skill_desc",
						posX = 0.5,
						posY = 0.3543607,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9727883,
						sizeY = 0.5920838,
						text = "13231231231323123123132312312313231231231323123123132312312313",
						color = "FF966856",
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
				etype = "Grid",
				name = "dh",
				posX = 0.5,
				posY = 0.3569433,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3890625,
				sizeY = 0.4694445,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dg",
					posX = 0.4869009,
					posY = 0.5000016,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.6344997,
					sizeY = 0.9115104,
					image = "top#top_dg.png",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "max",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7198666,
					sizeY = 0.842091,
					image = "top#top_d1.png",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "mm",
						posX = 0.4895934,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3737863,
						sizeY = 0.2599895,
						image = "top#manji",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "x3",
						posX = 0.2501217,
						posY = 0.395598,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1051091,
						sizeY = 0.1337574,
						image = "top#top_xx.png",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "x4",
						posX = 0.3202535,
						posY = 0.7589161,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.07791215,
						sizeY = 0.09914774,
						image = "top#top_xx.png",
						alpha = 0.6,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "x5",
						posX = 0.6137581,
						posY = 0.6516484,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.09966308,
						sizeY = 0.1268271,
						image = "top#top_xx.png",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "x6",
						posX = 0.7072654,
						posY = 0.3056266,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1431648,
						sizeY = 0.1821855,
						image = "top#top_xx.png",
						alpha = 0.8,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "x7",
						posX = 0.4397338,
						posY = 0.2364247,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.06703404,
						sizeY = 0.08530471,
						image = "top#top_xx.png",
						alpha = 0.7,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "dian1",
						posX = 0.06831103,
						posY = 0.3695921,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.03833021,
						sizeY = 0.04974475,
						image = "top#top_xx2.png",
						alpha = 0.3,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "dian2",
						posX = 0.003378459,
						posY = 0.7502149,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.04698094,
						sizeY = 0.06097163,
						image = "top#top_xx2.png",
						alpha = 0.25,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "dian3",
						posX = 0.06311565,
						posY = 0.8817009,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.05433132,
						sizeY = 0.07051091,
						image = "top#top_xx2.png",
						alpha = 0.32,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "dian4",
						posX = 0.2189608,
						posY = 0.9024621,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.04366454,
						sizeY = 0.05666763,
						image = "top#top_xx2.png",
						alpha = 0.63,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "dian5",
						posX = 0.2968734,
						posY = 0.6533246,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.0576539,
						sizeY = 0.07482296,
						image = "top#top_xx2.png",
						alpha = 0.63,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "dian6",
						posX = 0.5280461,
						posY = 0.937062,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1109687,
						sizeY = 0.1440147,
						image = "top#top_xx2.png",
						alpha = 0.22,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "dian7",
						posX = 0.7436307,
						posY = 0.9370661,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.03098417,
						sizeY = 0.04021113,
						image = "top#top_xx2.png",
						alpha = 0.5,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "dian8",
						posX = 0.7436336,
						posY = 0.667172,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.04165776,
						sizeY = 0.05406327,
						image = "top#top_xx2.png",
						alpha = 0.46,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "dian9",
						posX = 0.8968775,
						posY = 0.4837845,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.03633073,
						sizeY = 0.04714987,
						image = "top#top_xx2.png",
						alpha = 0.26,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "dian10",
						posX = 0.8553202,
						posY = 0.2138905,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.07899269,
						sizeY = 0.1025164,
						image = "top#top_xx2.png",
						alpha = 0.7,
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "top",
				posX = 0.5,
				posY = 0.8278954,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.20625,
				sizeY = 0.07222223,
				image = "chu1#top",
				scale9Left = 0.45,
				scale9Right = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "sbjn",
					varName = "skill_name",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6063727,
					sizeY = 0.8529374,
					text = "技能名称",
					color = "FF7F4920",
					fontSize = 24,
					fontOutlineColor = "FF27221D",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "close_btn",
				posX = 0.6863115,
				posY = 0.7811964,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05234375,
				sizeY = 0.1055556,
				image = "chu1#gb",
				imageNormal = "chu1#gb",
				soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
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
	dk = {
		ysjm = {
			scale = {{0, {0.3, 0.3, 1}}, {150, {1.1, 1.1, 1}}, {200, {1,1,1}}, },
		},
	},
	max = {
		dh = {
			scale = {{0, {0, 0, 1}}, {300, {1.1, 1.1, 1}}, {400, {1,1,1}}, },
		},
	},
	xzh = {
		dg = {
			rotate = {{0, {0}}, {4000, {180}}, },
		},
		x3 = {
			alpha = {{0, {1}}, {600, {0.5}}, {1600, {0.8}}, {2500, {1}}, },
		},
		x4 = {
			alpha = {{0, {0.6}}, {600, {1}}, {1600, {0.8}}, {2500, {0.6}}, },
		},
		x5 = {
			alpha = {{0, {1}}, {600, {0.5}}, {1600, {0.8}}, {2500, {1}}, },
		},
		x6 = {
			alpha = {{0, {0.8}}, {600, {0.6}}, {1600, {1}}, {2500, {0.8}}, },
		},
		x7 = {
			alpha = {{0, {0.7}}, {600, {0.3}}, {1600, {0.5}}, {2500, {0.7}}, },
		},
	},
	c_dakai = {
		{0,"dk", 1, 0},
		{0,"max", 1, 0},
		{0,"xzh", -1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
