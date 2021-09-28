--version = 1
local l_fileType = "node"

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
			name = "k1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.471875,
			sizeY = 0.1527778,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "bfsqt",
				varName = "bg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 1,
				sizeY = 1.036363,
				image = "heka#xuehuad",
				scale9 = true,
				scale9Left = 0.2,
				scale9Right = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "js",
					varName = "name",
					posX = 0.4261267,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6211584,
					sizeY = 0.6570855,
					text = "by    xxxxxxxxxx",
					color = "FF521C0E",
					fontSize = 22,
					fontOutlineColor = "FF17372F",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn",
					varName = "btn",
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
				etype = "Button",
				name = "an1",
				varName = "brick_btn",
				posX = 0.7205356,
				posY = 0.3814769,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1661081,
				sizeY = 0.6187004,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an2",
				varName = "flower_btn",
				posX = 0.8977791,
				posY = 0.3814769,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1665859,
				sizeY = 0.6187004,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "z1",
				posX = 0.586578,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05629139,
				sizeY = 0.2636363,
				image = "bgb#cai",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "wz",
					varName = "brick_num",
					posX = 2.955335,
					posY = 0.5418934,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 3.513959,
					sizeY = 1.267833,
					text = "x10",
					color = "FF734634",
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "z2",
				posX = 0.7671416,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05629139,
				sizeY = 0.3818181,
				image = "bgb#zan",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "wz2",
					varName = "flower_num",
					posX = 2.955335,
					posY = 0.5418934,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 3.513959,
					sizeY = 1.267833,
					text = "x10",
					color = "FF734634",
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
