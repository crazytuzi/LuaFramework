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
			name = "jd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2117188,
			sizeY = 0.1111111,
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
				sizeX = 0.9,
				sizeY = 0.9,
				image = "jy#jdd",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "xian",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 0.02777778,
					image = "jy#xian",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "qmd3",
				posX = 0.5,
				posY = 0.2766494,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8671585,
				sizeY = 0.3,
				image = "jy#jdt1",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "LoadingBar",
					name = "qmdt3",
					varName = "rateBar",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					image = "jy#jdt2",
					scale9Left = 0.3,
					scale9Right = 0.3,
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mc10",
				varName = "name",
				posX = 0.3194817,
				posY = 0.6939599,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4789153,
				sizeY = 1.669596,
				text = "苹果：",
				color = "FF966856",
				fontSize = 18,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mc11",
				varName = "leftTime",
				posX = 0.6419766,
				posY = 0.6939608,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5412558,
				sizeY = 1.669596,
				text = "剩余：",
				color = "FF966856",
				fontSize = 18,
				hTextAlign = 2,
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
	c_dakai2 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
