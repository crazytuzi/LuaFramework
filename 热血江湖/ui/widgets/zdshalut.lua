--version = 1
local l_fileType = "node"

local UIUtil = require "ui/common/UIUtil"

--EDITOR elements start tag
local eleRoot = 
{
	prop = {
		etype = "Layer",
		name = "root",
		varName = "rootVar",
		posX = 0,
		posY = 0,
		anchorX = 0,
		anchorY = 0,
	},
	children = {
	{
		prop = {
			etype = "Grid",
			name = "pz1",
			varName = "weightRoot",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.3182267,
			sizeY = 0.06944445,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dw",
				varName = "bottom",
				posX = 0.5,
				posY = 0.46,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.042031,
				sizeY = 0.6,
				image = "d2#hong",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt2",
				varName = "iconType",
				posX = 0.3698579,
				posY = 0.4843447,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1227505,
				sizeY = 0.802721,
				image = "zdtx#txd.png",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "txt",
					varName = "icon",
					posX = 0.5054789,
					posY = 0.6925332,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7210885,
					sizeY = 1.110169,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mc1",
					varName = "name",
					posX = -3.12261,
					posY = 0.4496445,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 6.570829,
					sizeY = 2.468651,
					text = "玩家名字七个字",
					color = "FFFFE153",
					fontSize = 18,
					fontOutlineEnable = true,
					fontOutlineColor = "FF561313",
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt3",
				varName = "iconBg",
				posX = 0.625205,
				posY = 0.4843448,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1227505,
				sizeY = 0.802721,
				image = "zdtx#txd.png",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "txt2",
					varName = "icon2",
					posX = 0.5054789,
					posY = 0.6925332,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7210885,
					sizeY = 1.110169,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mc2",
					varName = "name2",
					posX = 4.165416,
					posY = 0.449645,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 6.570829,
					sizeY = 2.468651,
					text = "玩家名字七个字",
					color = "FFFFE153",
					fontSize = 18,
					fontOutlineEnable = true,
					fontOutlineColor = "FF561313",
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "jsz",
				varName = "zhugong",
				posX = 0.5,
				posY = 0.4245401,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.6455875,
				sizeY = 1.323046,
				text = "击杀了",
				fontSize = 18,
				fontOutlineEnable = true,
				fontOutlineColor = "FF561313",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "js",
				posX = 0.5,
				posY = 0.46,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1325706,
				sizeY = 0.5,
				image = "zd#jishaz",
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
	gy4 = {
	},
	gy5 = {
	},
	gy6 = {
	},
	gy7 = {
	},
	gy8 = {
	},
	gy9 = {
	},
	gy10 = {
	},
	gy11 = {
	},
	gy12 = {
	},
	gy13 = {
	},
	gy14 = {
	},
	c_dakai = {
	},
	c_dakai2 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
