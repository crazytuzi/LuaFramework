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
			etype = "Button",
			name = "aaa",
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
			etype = "Grid",
			name = "ysjm",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2516415,
			sizeY = 0.5978336,
			hTextAlign = 1,
			vTextAlign = 1,
			layoutType = 5,
			layoutTypeW = 5,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "db",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
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
					name = "db2",
					posX = 0.5077477,
					posY = 0.6727936,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7531832,
					sizeY = 0.46156,
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
						name = "wqd",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.9286304,
						sizeY = 0.3869294,
						text = "您手慢了，红包已经被抢完了哦！",
						color = "FF966856",
						fontSize = 22,
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
				etype = "Button",
				name = "an",
				posX = 0.5,
				posY = 0.2264145,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.540203,
				sizeY = 0.1533314,
				image = "chu1#an1",
				imageNormal = "chu1#an1",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "w",
					posX = 0.494268,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					text = "确认",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FFB35F1D",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
					autoWrap = false,
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
