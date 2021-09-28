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
			name = "zu",
			posX = 0.8703415,
			posY = 0.9216314,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2282431,
			sizeY = 0.03888889,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "barbg",
				posX = 0.5341582,
				posY = 0.428759,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5291905,
				sizeY = 0.5,
				image = "hudxlzm#hdxlzmbg2",
			},
		},
		{
			prop = {
				etype = "LoadingBar",
				name = "bar",
				varName = "target",
				posX = 0.5341585,
				posY = 0.428759,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5291905,
				sizeY = 0.5,
				image = "hudxlzm#hdxlzmbg1",
				percent = 80,
			},
		},
		{
			prop = {
				etype = "LoadingBar",
				name = "bar1",
				varName = "current",
				posX = 0.5341585,
				posY = 0.428759,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5291905,
				sizeY = 0.5,
				image = "hudxlzm#hdxlzmbg3",
				percent = 40,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "cc5",
				varName = "value",
				posX = 0.885308,
				posY = 0.4287593,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2157934,
				sizeY = 1.964286,
				text = "20%",
				color = "FFFFEBBC",
				fontSize = 18,
				hTextAlign = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "cc6",
				varName = "name",
				posX = 0.1466859,
				posY = 0.4287593,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2909411,
				sizeY = 1.964286,
				text = "伤害增加",
				color = "FFFFEBBC",
				fontSize = 18,
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
