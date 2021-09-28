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
			lockHV = true,
			sizeX = 0.06121508,
			sizeY = 0.1088269,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "djt",
				varName = "icon_bg",
				posX = 0.5,
				posY = 0.4838181,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.981707,
				sizeY = 0.9817064,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djk",
					varName = "item_icon",
					posX = 0.5026884,
					posY = 0.5212724,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8402775,
					sizeY = 0.8416974,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btns",
					varName = "bt",
					posX = 0.5046585,
					posY = 0.5230674,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.009317,
					sizeY = 0.9538652,
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
	gy = {
	},
	gy3 = {
	},
	gy2 = {
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
	gy15 = {
	},
	gy16 = {
	},
	gy17 = {
	},
	gy18 = {
	},
	gy19 = {
	},
	gy20 = {
	},
	gy21 = {
	},
	gy22 = {
	},
	gy23 = {
	},
	gy24 = {
	},
	gy25 = {
	},
	gy26 = {
	},
	gy27 = {
	},
	gy28 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
