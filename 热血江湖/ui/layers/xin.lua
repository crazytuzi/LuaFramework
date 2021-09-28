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
			posX = 0.5015603,
			posY = 0.5041607,
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
				lockHV = true,
				sizeX = 0.3104295,
				sizeY = 0.6309595,
				image = "xin#xin",
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.25,
				scale9Bottom = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "xjmc",
					varName = "ItemName",
					posX = 0.5151002,
					posY = 0.9006203,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.25,
					text = "信件道具名",
					color = "FF911D02",
					fontSize = 26,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "nrlb",
					varName = "Scroll",
					posX = 0.5151002,
					posY = 0.5258189,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8263085,
					sizeY = 0.6230049,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "jqrw",
					varName = "getTask",
					posX = 0.5151002,
					posY = 0.1238738,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3875678,
					sizeY = 0.1166654,
					image = "ty#xjan",
					imageNormal = "ty#xjan",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "jqrwwz",
						posX = 0.5031598,
						posY = 0.5118237,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8634923,
						sizeY = 0.8191843,
						text = "接取任务",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FF347468",
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
					name = "gb",
					varName = "closeBtn",
					posX = 0.9530823,
					posY = 0.9705617,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2265007,
					sizeY = 0.198111,
					image = "chu1#gb",
					imageNormal = "chu1#gb",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
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
