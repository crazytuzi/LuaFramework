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
			name = "ren",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1849561,
			sizeY = 0.04457698,
		},
		children = {
		{
			prop = {
				etype = "Label",
				name = "mc",
				varName = "playerName",
				posX = 0.5412686,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9343582,
				sizeY = 1.960267,
				text = "玩家名称",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "tr",
				varName = "kickBtn",
				posX = 0.799904,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1355703,
				sizeY = 1,
				image = "zdte#ti",
				imageNormal = "zdte#ti",
				disablePressScale = true,
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
