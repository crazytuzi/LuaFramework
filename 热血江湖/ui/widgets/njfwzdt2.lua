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
			etype = "Grid",
			name = "ysjm",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.88,
			sizeY = 0.98,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4261363,
				sizeY = 0.3543084,
				image = "b#cs",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.25,
				scale9Bottom = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "kk",
					posX = 0.5,
					posY = 0.6197952,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8855633,
					sizeY = 0.5989999,
					image = "b#d2",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "z1",
					varName = "times_desc",
					posX = 0.5,
					posY = 0.4086338,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8238425,
					sizeY = 0.1861207,
					text = "添加获得经验：100",
					color = "FF65944D",
					fontSize = 22,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a1",
					varName = "cancel",
					posX = 0.2484894,
					posY = 0.1690169,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3395834,
					sizeY = 0.256,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "f1",
						varName = "no_name",
						posX = 0.5,
						posY = 0.546875,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8313926,
						sizeY = 0.963034,
						text = "取 消",
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
			{
				prop = {
					etype = "Button",
					name = "a2",
					varName = "ok",
					posX = 0.7540076,
					posY = 0.1690169,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3395834,
					sizeY = 0.256,
					image = "chu1#an1",
					imageNormal = "chu1#an1",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "f2",
						varName = "yes_name",
						posX = 0.5,
						posY = 0.546875,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8313926,
						sizeY = 0.963034,
						text = "确 定",
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
					name = "k1",
					posX = 0.5,
					posY = 0.6158709,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7666667,
					sizeY = 0.42,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "sld",
						posX = 0.3640641,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6657609,
						sizeY = 0.6666667,
						image = "sl#sld",
					},
				},
				{
					prop = {
						etype = "Button",
						name = "jian",
						varName = "jian",
						posX = 0.1059266,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1494565,
						sizeY = 0.6666667,
						image = "sl#jian",
						imageNormal = "sl#jian",
						disablePressScale = true,
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sl",
						varName = "use_count",
						posX = 0.364327,
						posY = 0.5048466,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4089706,
						sizeY = 0.58996,
						text = "231/999",
						fontSize = 26,
						fontOutlineEnable = true,
						fontOutlineColor = "FF43261D",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "jia",
						varName = "jia",
						posX = 0.6240963,
						posY = 0.4999999,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1494565,
						sizeY = 0.6666667,
						image = "sl#jia",
						imageNormal = "sl#jia",
						disablePressScale = true,
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
				},
				{
					prop = {
						etype = "Button",
						name = "max",
						varName = "max",
						posX = 0.8605369,
						posY = 0.4905361,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2282609,
						sizeY = 0.7904762,
						image = "sl#max",
						imageNormal = "sl#max",
						disablePressScale = true,
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "xq",
					posX = 0.4002412,
					posY = 0.8433958,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.25,
					text = "选择使用数量：",
					color = "FF966856",
					fontSize = 22,
					vTextAlign = 1,
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
	dk = {
		ysjm = {
			scale = {{0, {0.3, 0.3, 1}}, {150, {1.1, 1.1, 1}}, {200, {1,1,1}}, },
		},
	},
	c_dakai = {
		{0,"dk", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
