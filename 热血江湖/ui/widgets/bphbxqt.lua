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
			name = "t",
			posX = 0.5,
			posY = 0.5513893,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.45237,
			sizeY = 0.05555556,
		},
		children = {
		{
			prop = {
				etype = "Label",
				name = "mz",
				varName = "name",
				posX = 0.2458909,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3,
				sizeY = 1,
				text = "玩家名称七个字",
				color = "FF966856",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "sl",
				varName = "diamond",
				posX = 0.7541093,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4481687,
				sizeY = 1,
				text = "绑元数量：999999",
				color = "FF65944D",
				hTextAlign = 1,
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
