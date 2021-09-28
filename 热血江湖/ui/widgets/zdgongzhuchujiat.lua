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
			sizeX = 0.2088112,
			sizeY = 0.04861111,
		},
		children = {
		{
			prop = {
				etype = "Label",
				name = "djs13",
				varName = "name",
				posX = 0.3843501,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6154141,
				sizeY = 2.126951,
				text = "玩家名称",
				color = "FFFFE431",
				fontSize = 18,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "djs14",
				varName = "score",
				posX = 0.7809958,
				posY = 0.5000007,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4648902,
				sizeY = 2.126951,
				text = "888888",
				color = "FFFFE431",
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
