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
			name = "nd4",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.200793,
			sizeY = 0.3064411,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "xnd4",
				varName = "btn",
				posX = 0.4883276,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8948892,
				sizeY = 0.965384,
				image = "fb2#kn2",
				imageNormal = "fb2#kn2",
				imagePressed = "fb2#kn4",
				imageDisable = "fb2#kn1",
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "tl3",
				varName = "root3_desc2",
				posX = 0.4980922,
				posY = 0.6849568,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8604418,
				sizeY = 0.2402129,
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
