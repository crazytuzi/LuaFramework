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
			name = "jd1",
			posX = 0.1755276,
			posY = 0.6261908,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.35,
			sizeY = 0.75,
			layoutType = 7,
			layoutTypeW = 7,
		},
		children = {
		{
			prop = {
				etype = "Grid",
				name = "dyjd",
				varName = "teamRoot",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				layoutType = 7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "gg",
					posX = 0.3120088,
					posY = 0.503685,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5988573,
					sizeY = 0.4289251,
					image = "b#rwd",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lb",
						varName = "scoll",
						posX = 0.5,
						posY = 0.4371446,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9712391,
						sizeY = 0.8399963,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "mb",
						posX = 0.5,
						posY = 0.9242829,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9004714,
						sizeY = 0.25,
						text = "副本目标",
						color = "FFFFFF80",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "ysjm",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "tst",
				varName = "coutRoot",
				posX = 0.5,
				posY = 0.785641,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5125,
				sizeY = 0.08611111,
				image = "d#tst",
			},
			children = {
			{
				prop = {
					etype = "RichText",
					name = "fwb",
					varName = "count",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8539661,
					sizeY = 1.042848,
					color = "FFFFF554",
					fontSize = 22,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "jd",
			posX = 0.5,
			posY = 0.35,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 0.7,
			layoutType = 3,
			layoutTypeW = 3,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				varName = "areaRoot",
				posX = 0.4150329,
				posY = 0.2618061,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3884243,
				sizeY = 0.09676135,
				image = "zd#ltd",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "RichText",
					name = "bc",
					varName = "areaTxt",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9377523,
					sizeY = 0.8497785,
					text = "tishiyu",
					color = "FFFFFF80",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "xsysjm",
			varName = "roleInfoUI",
			posX = 0.5,
			posY = 0.75,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 0.5,
			layoutType = 8,
			layoutTypeW = 8,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "fw",
				varName = "reverseBt",
				posX = 0.7285303,
				posY = 0.8632978,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.04765625,
				sizeY = 0.2,
				image = "zdsjzh#fuwei",
				imageNormal = "zdsjzh#fuwei",
				disablePressScale = true,
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
