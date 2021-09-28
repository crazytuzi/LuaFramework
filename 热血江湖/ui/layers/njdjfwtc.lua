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
				varName = "close_btn",
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
				sizeX = 0.3125,
				sizeY = 0.4689241,
				scale9 = true,
				scale9Left = 0.41,
				scale9Right = 0.37,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "cr",
					varName = "pushBag_Btn",
					posX = 1.093885,
					posY = 0.1507298,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2775,
					sizeY = 0.1569787,
					image = "tong#an",
					imageNormal = "tong#an",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "cewz",
						varName = "pushLabel",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9022217,
						sizeY = 0.8757463,
						text = "提取",
						color = "FFA7582D",
						fontSize = 24,
						fontOutlineColor = "FF624311",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "cs",
					varName = "equipBtn",
					posX = 1.093885,
					posY = 0.3669485,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2775,
					sizeY = 0.1569787,
					image = "tong#an",
					imageNormal = "tong#an",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "cewz2",
						varName = "equipLabel",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9022217,
						sizeY = 0.8757463,
						text = "装备",
						color = "FFA7582D",
						fontSize = 24,
						fontOutlineColor = "FF624311",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "wk",
					posX = 0.5,
					posY = 0.5022358,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.951775,
					sizeY = 1.025528,
					image = "b#db5",
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
						name = "dww",
						posX = 0.5,
						posY = 0.4908382,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9043959,
						sizeY = 0.2912245,
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
						name = "xhd",
						posX = 0.5662463,
						posY = 0.8114132,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5804943,
						sizeY = 0.2137219,
						image = "d2#xhd",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "djd",
					varName = "item_bg",
					posX = 0.1915,
					posY = 0.8212929,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2375,
					sizeY = 0.2754532,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "djt",
						varName = "item_icon",
						posX = 0.5,
						posY = 0.5459611,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.8158965,
						sizeY = 0.8,
						image = "items#xueping1.png",
					},
				},
				{
					prop = {
						etype = "Button",
						name = "wpan",
						posX = 0.4952771,
						posY = 0.5251675,
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
					etype = "Label",
					name = "z5",
					varName = "itemName_label",
					posX = 0.6409958,
					posY = 0.8709282,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.611493,
					sizeY = 0.1504553,
					text = "冷血符文：",
					color = "FF966856",
					fontSize = 22,
					fontOutlineColor = "FFFCEBCF",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "hqtj",
					varName = "get_label",
					posX = 0.4865159,
					posY = 0.1895847,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8016725,
					sizeY = 0.2500001,
					text = "通过巴拉巴拉获取",
					color = "FF65944D",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "gjlsm",
					varName = "itemDesc_label",
					posX = 0.5012459,
					posY = 0.4944928,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8311326,
					sizeY = 0.266938,
					text = "攻击+5\n攻击+5",
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
