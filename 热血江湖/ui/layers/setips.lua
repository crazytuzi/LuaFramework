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
			etype = "Image",
			name = "t",
			varName = "img",
			posX = 0.5,
			posY = 0.2828287,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.5125,
			sizeY = 0.08611111,
			image = "d#tst",
			layoutType = 5,
			layoutTypeW = 5,
		},
		children = {
		{
			prop = {
				etype = "RichText",
				name = "z1",
				varName = "tipWord",
				posX = 0.320173,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8649175,
				sizeY = 0.8427415,
				text = "您正在遭受玩家攻击，是否切换到善恶模式？",
				color = "FFFFF554",
				fontSize = 22,
				fontOutlineColor = "FF102E21",
				hTextAlign = 2,
				vTextAlign = 1,
				layoutType = 5,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "btn",
				varName = "attackBtn",
				posX = 0.8310097,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.278507,
				sizeY = 0.6762936,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "hjg",
				posX = 0.8545994,
				posY = 0.5031068,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1978466,
				sizeY = 1.016753,
				text = "点击切换",
				color = "FF00FF00",
				fontSize = 22,
				fontUnderlineEnable = true,
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
