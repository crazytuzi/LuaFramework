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
			etype = "Button",
			name = "zd1",
			varName = "bt",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.121875,
			sizeY = 0.0875,
			image = "czhd#yqcg",
			imageNormal = "czhd#yqcg",
			imageDisable = "czhd#yqcg",
			disablePressScale = true,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "tp",
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
				etype = "Image",
				name = "xz",
				varName = "choose",
				posX = 0.4951506,
				posY = 0.494622,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9999999,
				sizeY = 1,
				image = "czhd#yqdl",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xhd",
				varName = "redPonit",
				posX = 0.9185401,
				posY = 0.7898545,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1410256,
				sizeY = 0.3650794,
				image = "czhd#hd",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "Z",
				varName = "TitleName",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.195001,
				sizeY = 0.6305317,
				text = "买赠",
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
	jn6 = {
	},
	bj = {
	},
	c_hld = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
