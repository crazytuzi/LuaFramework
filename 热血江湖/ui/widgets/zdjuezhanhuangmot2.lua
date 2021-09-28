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
			sizeY = 0.07638889,
		},
		children = {
		{
			prop = {
				etype = "Label",
				name = "mc",
				varName = "name",
				posX = 0.470428,
				posY = 0.6999998,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8809935,
				sizeY = 1,
				text = "英雄名称",
				color = "FFEAD3AC",
				fontSize = 18,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "LoadingBar",
				name = "jdt",
				varName = "hpBar",
				posX = 0.3466028,
				posY = 0.2458108,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6210755,
				sizeY = 0.2909091,
				image = "zd#xt",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xk",
				posX = 0.3466027,
				posY = 0.2458107,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6285583,
				sizeY = 0.3272727,
				image = "zd#xk",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tx",
				varName = "life1",
				posX = 0.5450385,
				posY = 0.6814615,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1010183,
				sizeY = 0.4545455,
				image = "zd#shengming",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tx2",
				varName = "life2",
				posX = 0.6460599,
				posY = 0.6814615,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1010183,
				sizeY = 0.4545455,
				image = "zd#shengming",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tx3",
				varName = "life3",
				posX = 0.7470787,
				posY = 0.6814615,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1010183,
				sizeY = 0.4545455,
				image = "zd#shengming",
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
