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
			name = "jd1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.234375,
			sizeY = 0.09027778,
			alphaCascade = true,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dms",
				varName = "bg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "d#bt",
				alpha = 0.75,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "ms1",
				varName = "desc",
				posX = 0.6091136,
				posY = 0.7615382,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.114699,
				sizeY = 1.068703,
				text = "01.击杀陈尚必",
				color = "FF634624",
				vTextAlign = 1,
				alphaCascade = true,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wc",
				varName = "state",
				posX = 0.817039,
				posY = 0.2846156,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4254846,
				sizeY = 1.386983,
				text = "进行中",
				color = "FF029133",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "ms2",
				varName = "count",
				posX = 0.463978,
				posY = 0.2846156,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6444298,
				sizeY = 1.068703,
				text = "100/100",
				color = "FFF01818",
				vTextAlign = 1,
				alphaCascade = true,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xian",
				posX = 0.5,
				posY = -0.01538461,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.07692306,
				image = "b#xian2",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
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
	gy2 = {
	},
	gy3 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
