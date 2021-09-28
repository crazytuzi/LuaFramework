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
				image = "b#dd",
				alpha = 0.7,
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
				sizeX = 0.4726563,
				sizeY = 0.6986111,
				image = "guiying#bj",
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
					posY = 0.6004898,
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
					posX = 0.5132024,
					posY = 0.5828445,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8231404,
					sizeY = 0.5506958,
					image = "hua1#hua1",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a2",
					varName = "showLeaderBtn",
					posX = 0.5,
					posY = 0.09293884,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2876033,
					sizeY = 0.1312127,
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
						text = "揭露",
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
					etype = "Button",
					name = "an3",
					varName = "close",
					posX = 0.9326077,
					posY = 0.9280953,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.107438,
					sizeY = 0.1252485,
					image = "baishi#x",
					imageNormal = "baishi#x",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tp",
					posX = 0.5031174,
					posY = 0.235881,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8798046,
					sizeY = 0.1663301,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wb",
						varName = "ownClue",
						posX = 0.5079152,
						posY = 0.6373652,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9780028,
						sizeY = 0.6573912,
						text = "当前尚未收集全部线索",
						color = "FFC00000",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wb2",
						posX = 0.4752149,
						posY = 0.2508253,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3546097,
						sizeY = 0.6573912,
						text = "揭露成功率为：",
						color = "FF966856",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wb3",
						varName = "successRate",
						posX = 0.7151446,
						posY = 0.2508253,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2529565,
						sizeY = 0.6573912,
						text = "80%",
						color = "FFC00000",
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb",
					varName = "clueScroll",
					posX = 0.5,
					posY = 0.5966403,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8285009,
					sizeY = 0.5845068,
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
