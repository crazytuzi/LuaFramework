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
			sizeX = 0.1835938,
			sizeY = 0.2083333,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "ans",
				varName = "btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8382977,
				sizeY = 0.9933335,
				image = "jy#an2",
				scale9Left = 0.4,
				scale9Right = 0.4,
				imageNormal = "jy#an2",
				imagePressed = "jy#an1",
				imageDisable = "jy#an2",
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tb1",
				varName = "icon",
				posX = 0.5,
				posY = 0.6530815,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.5352812,
				sizeY = 0.8386078,
				image = "jy#tudi",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mc",
				varName = "name",
				posX = 0.5793805,
				posY = 0.180468,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8300022,
				sizeY = 0.7218713,
				text = "房屋",
				color = "FF966856",
				fontSize = 22,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mc2",
				varName = "desc",
				posX = 0.6128515,
				posY = 0.1804681,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4370346,
				sizeY = 0.7218713,
				text = "Lv1",
				color = "FF65944D",
				hTextAlign = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mc3",
				varName = "sub_name",
				posX = 0.5,
				posY = 0.180468,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.7218713,
				color = "FF966856",
				fontSize = 22,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xian",
				posX = 0.5,
				posY = 0.3,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8,
				sizeY = 0.01333334,
				image = "jy#xian",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
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
