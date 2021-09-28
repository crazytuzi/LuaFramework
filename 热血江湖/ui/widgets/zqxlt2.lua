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
			etype = "Image",
			name = "xzk2",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.1423946,
			sizeY = 0.07319881,
			scale9Left = 0.4,
			scale9Right = 0.4,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dd",
				varName = "clickBt",
				posX = 0.5,
				posY = 0.4905208,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.01403,
				sizeY = 1.100504,
				image = "chu1#fy1",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				imageNormal = "chu1#fy1",
				imagePressed = "chu1#fy2",
				imageDisable = "chu1#fy1",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wb6",
				varName = "txt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.166754,
				sizeY = 1.361699,
				text = "第一条属性",
				color = "FF966856",
				fontSize = 22,
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
