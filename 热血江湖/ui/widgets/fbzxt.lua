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
			name = "jie",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1994946,
			sizeY = 0.05012288,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "jdd",
				posX = 0.7106924,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5777855,
				sizeY = 0.5819032,
				image = "shtj#jdd",
			},
			children = {
			{
				prop = {
					etype = "LoadingBar",
					name = "jdt",
					varName = "damageBar",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					image = "shtj#sh1",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mb9",
				varName = "damageNum",
				posX = 0.7089605,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5821109,
				sizeY = 1.270867,
				text = "888888888",
				fontSize = 18,
				fontOutlineColor = "FF27221D",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mb10",
				varName = "name",
				posX = 0.3345563,
				posY = 0.5000008,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6623191,
				sizeY = 1.035176,
				text = "名字六七个字",
				color = "FFFDB0B0",
				fontSize = 18,
				fontOutlineColor = "FF27221D",
				vTextAlign = 1,
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
	gy = {
	},
	gy2 = {
	},
	gy3 = {
	},
	gy4 = {
	},
	gy5 = {
	},
	gy6 = {
	},
	gy7 = {
	},
	gy8 = {
	},
	gy9 = {
	},
	gy10 = {
	},
	gy11 = {
	},
	gy12 = {
	},
	gy13 = {
	},
	gy14 = {
	},
	c_dakai = {
	},
	c_dakai2 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
