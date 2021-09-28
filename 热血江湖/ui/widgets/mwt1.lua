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
			name = "tb1",
			varName = "reward_bg1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.06623822,
			sizeY = 0.1152778,
			image = "djk#ktong",
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "bt1",
				varName = "reward_btn1",
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
				name = "ttb1",
				varName = "reward_icon1",
				posX = 0.4937111,
				posY = 0.5225254,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8111558,
				sizeY = 0.8286139,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "sl1",
				varName = "reward_count1",
				posX = 0.4506058,
				posY = 0.2229131,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9232277,
				sizeY = 0.5099124,
				text = "x1000",
				fontOutlineEnable = true,
				hTextAlign = 2,
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
