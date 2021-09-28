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
				varName = "imgBK",
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
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6638203,
				sizeY = 0.6765009,
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
					name = "hua",
					posX = 0.7608396,
					posY = 0.2926871,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5860961,
					sizeY = 0.5686943,
					image = "hua1#hua1",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a2",
					varName = "closeBtn",
					posX = 0.5,
					posY = 0.08088084,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2047806,
					sizeY = 0.1355012,
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
						sizeY = 0.9422306,
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
					name = "db1",
					posX = 0.5000002,
					posY = 0.5133157,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9482002,
					sizeY = 0.6989521,
					image = "b#d5",
					scale9 = true,
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lb",
						varName = "master_scroll",
						posX = 0.5000001,
						posY = 0.5011224,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9887726,
						sizeY = 0.9625648,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "top",
					posX = 0.5,
					posY = 1.000114,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3107015,
					sizeY = 0.1067585,
					image = "chu1#top",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "topz",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3219698,
						sizeY = 0.4615385,
						image = "biaoti#baishi",
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wb",
					posX = 0.5,
					posY = 0.9058343,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.25,
					text = "点击条目可以查看师父的详细资讯",
					color = "FF966856",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "sx",
					varName = "refreshBtn",
					posX = 0.9406361,
					posY = 0.9058344,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.05178359,
					sizeY = 0.08417497,
					image = "te#sx",
					imageNormal = "te#sx",
					disablePressScale = true,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wb2",
					posX = 0.8170302,
					posY = 0.9058344,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1836768,
					sizeY = 0.1147498,
					text = "换一换",
					color = "FF966856",
					hTextAlign = 2,
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
