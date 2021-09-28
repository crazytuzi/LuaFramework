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
			etype = "Grid",
			name = "ysjm",
			varName = "drugiconroot",
			posX = 0.7288561,
			posY = 0.9294646,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.08133358,
			sizeY = 0.1266614,
			layoutType = 8,
			layoutTypeW = 8,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "rk",
				varName = "openBtn",
				posX = 0.327101,
				posY = 0.5086136,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.6819908,
				sizeY = 0.8772294,
				image = "guidaoyuling1#ylrk1",
				imageNormal = "guidaoyuling1#ylrk1",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "sm",
				varName = "guideBtn",
				posX = 1.095547,
				posY = 0.5086136,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.7684403,
				sizeY = 0.8772294,
				image = "guidaoyuling1#shuoming",
				imageNormal = "guidaoyuling1#shuoming",
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
