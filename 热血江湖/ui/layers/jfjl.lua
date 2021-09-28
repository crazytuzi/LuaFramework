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
			scale9Left = 0.4,
			scale9Right = 0.4,
			scale9Top = 0.4,
			scale9Bottom = 0.4,
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
				posY = 0.500693,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7929688,
				sizeY = 0.7279713,
				scale9 = true,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dw1",
					posX = 0.5,
					posY = 0,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 0.06486825,
					image = "d2#jzd2",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dw2",
					posX = 0.5,
					posY = 0.9942763,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 0.06486825,
					image = "d2#jzd2",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					flippedY = true,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "das",
					posX = 0.5,
					posY = 0.480921,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.01,
					sizeY = 1.013089,
					image = "b#db3",
					scale9 = true,
					scale9Left = 0.47,
					scale9Right = 0.47,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jzz3",
					posX = 0.9988484,
					posY = 0.5019051,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.07093596,
					sizeY = 1.156191,
					image = "jz#jz1",
					flippedX = true,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jzz2",
					posX = 0.002463773,
					posY = 0.5019051,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.07093596,
					sizeY = 1.156191,
					image = "jz#jz1",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "db",
				posX = 0.5,
				posY = 0.4576371,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7929688,
				sizeY = 0.7279713,
				scale9 = true,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "smd",
					posX = 0.5078694,
					posY = -0.04690456,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9526536,
					sizeY = 0.109147,
					image = "a",
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
					alpha = 0.7,
				},
				children = {
				{
					prop = {
						etype = "RichText",
						name = "gz",
						varName = "desc",
						posX = 0.5,
						posY = 0.6776636,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.000482,
						sizeY = 1.029032,
						text = "在竞技场挑战对手的过程中，每次胜利获得3积分，失败获得2积分（积分在每天5:00重置）",
						fontOutlineColor = "FF27221D",
						hTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "dqjf",
					varName = "curIntegral",
					posX = 0.2024645,
					posY = 1.109982,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2645892,
					sizeY = 0.08404876,
					text = "当前积分：299",
					color = "FFC5FF5F",
					fontSize = 24,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb2",
					varName = "scroll",
					posX = 0.5009872,
					posY = 0.5477244,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9580319,
					sizeY = 0.9047391,
					horizontal = true,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "top",
				posX = 0.5,
				posY = 0.8790902,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2351563,
				sizeY = 0.07222223,
				image = "jz#top3",
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tt2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.5647839,
					sizeY = 0.4807692,
					image = "biaoti#jjjc",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "close",
				posX = 0.9024495,
				posY = 0.7962519,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.04453125,
				sizeY = 0.1069444,
				image = "ty#gb2",
				imageNormal = "ty#gb2",
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
