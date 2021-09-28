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
			sizeX = 0.3102708,
			sizeY = 0.05555556,
		},
		children = {
		{
			prop = {
				etype = "Label",
				name = "sx1",
				varName = "name",
				posX = 0.389208,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 1.25,
				text = "属性名字",
				color = "FF966856",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "sx2",
				varName = "count1",
				posX = 0.6181481,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4323778,
				sizeY = 1.25,
				text = "+2000",
				color = "FFF1E9D7",
				fontOutlineEnable = true,
				fontOutlineColor = "FFA47848",
				fontOutlineSize = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "sx3",
				varName = "count2",
				posX = 0.8783292,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3946688,
				sizeY = 1.25,
				text = "+133",
				color = "FF65944D",
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
	ss = {
		sx3 = {
			alpha = {{0, {0.4}}, {700, {1}}, {1300, {0.4}}, },
		},
	},
	c_dakai = {
		{0,"ss", -1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
