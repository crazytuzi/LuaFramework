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
			sizeX = 0.1981117,
			sizeY = 0.05555556,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "zt",
				varName = "icon",
				posX = 0.0944885,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1971741,
				sizeY = 1.25,
				image = "zt#qixue",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "sx1",
				varName = "name",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 1.375,
				text = "属性：",
				color = "FF87EFFF",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "sx2",
				varName = "value",
				posX = 0.8405479,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.4606315,
				sizeY = 1.375,
				text = "600",
				color = "FF87EFFF",
				fontOutlineColor = "FFA47848",
				fontOutlineSize = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "sx3",
				varName = "maxValue",
				posX = 0.8405479,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4606315,
				sizeY = 1.375,
				text = "600",
				color = "FF69FF2E",
				fontOutlineColor = "FFA47848",
				fontOutlineSize = 2,
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
