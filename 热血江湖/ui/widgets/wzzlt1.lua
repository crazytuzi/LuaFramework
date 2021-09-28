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
			sizeX = 0.6762072,
			sizeY = 0.1388889,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dw",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.042118,
				sizeY = 0.7499999,
				image = "wzzl#dw",
				scale9 = true,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "ms",
				varName = "des",
				posX = 0.5329247,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5341507,
				sizeY = 0.8355334,
				text = "完成五转，获得一个新武功和一个新气功",
				color = "FFBCA185",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "djk",
				varName = "bgRoot",
				posX = 0.8114312,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.0924273,
				sizeY = 0.7999997,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt",
					varName = "headIcon",
					posX = 0.4935085,
					posY = 0.5188183,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8116341,
					sizeY = 0.8363174,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "slz",
					varName = "count",
					posX = 0.5496628,
					posY = 0.231877,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6993256,
					sizeY = 0.8862457,
					text = "x1",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn1",
					varName = "headBtn",
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
					name = "suo",
					varName = "lock",
					posX = 0.2004906,
					posY = 0.2130046,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3500001,
					sizeY = 0.3500001,
					image = "tb#suo",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "ztt",
				varName = "iconBase",
				posX = 0.09975427,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2206702,
				sizeY = 0.52,
				image = "wzzl#an",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "fyz",
					varName = "taskName",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8899318,
					sizeY = 1.012752,
					text = "养心合身",
					color = "FFF4E1C5",
					fontSize = 22,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "ywc",
				varName = "doneImg",
				posX = 0.8898637,
				posY = 0.5099307,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1407201,
				sizeY = 0.7262585,
				image = "huigui#ywc",
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
