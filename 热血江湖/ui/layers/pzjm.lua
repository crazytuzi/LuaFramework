--version = 1
local l_fileType = "layer"

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
			etype = "MutiTouch",
			name = "ddck",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "zjd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			layoutType = 1,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "hfan",
				varName = "restoreBtn",
				posX = 0.04603176,
				posY = 0.07842661,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.053125,
				sizeY = 0.1055556,
				image = "lt#cx",
				imageNormal = "lt#cx",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "pzan",
				varName = "snapShotBtn",
				posX = 0.1213597,
				posY = 0.07842661,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.053125,
				sizeY = 0.1055556,
				image = "lt#pz",
				imageNormal = "lt#pz",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "pzan2",
				varName = "ShareBtn",
				posX = 0.1966877,
				posY = 0.0784266,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.053125,
				sizeY = 0.1055556,
				image = "lt#fx2",
				imageNormal = "lt#fx2",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
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
