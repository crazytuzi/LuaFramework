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
					posY = 0.616967,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8902509,
					sizeY = 0.5934542,
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
					etype = "Image",
					name = "hua",
					posX = 0.5,
					posY = 0.567944,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.0375,
					sizeY = 1.108,
					image = "hua1#hua1",
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "z1",
					varName = "desc",
					posX = 0.5041608,
					posY = 0.7128356,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8238425,
					sizeY = 0.4416505,
					text = "发现您有大量可以领取的成就奖励，是否一键领取？",
					color = "FF966856",
					fontSize = 22,
					fontOutlineColor = "FF27221D",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a1",
					varName = "onlyReward",
					posX = 0.2505727,
					posY = 0.1570169,
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
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8313926,
						sizeY = 0.9422305,
						text = "单独领取",
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
					varName = "allReward",
					posX = 0.7540076,
					posY = 0.1570169,
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
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8313926,
						sizeY = 0.9422306,
						text = "一键领取",
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
					name = "yq",
					posX = 0.3307393,
					posY = 0.4419741,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.0625,
					sizeY = 0.12,
					image = "chu1#gxd",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dj",
						varName = "useItem",
						posX = 0.5603157,
						posY = 0.499998,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.266667,
						sizeY = 1.133333,
						image = "chu1#dj",
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wb",
					posX = 0.6874723,
					posY = 0.4440219,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.25,
					text = "本次登录不再提示",
					color = "FFC93034",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an3",
					varName = "useItemBtn",
					posX = 0.3484311,
					posY = 0.4481078,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1747368,
					sizeY = 0.1757589,
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
