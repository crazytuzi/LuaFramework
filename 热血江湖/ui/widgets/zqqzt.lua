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
			name = "jd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.7792356,
			sizeY = 0.1110435,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "sx3",
				varName = "bg3",
				posX = 0.844669,
				posY = 0.5199713,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3007755,
				sizeY = 0.9380708,
				image = "qz#db3",
				scale9Left = 0.4,
				scale9Right = 0.5,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "btn3",
					varName = "btn3",
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
					etype = "Label",
					name = "wen10",
					varName = "prop3",
					posX = 0.3964677,
					posY = 0.6577285,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6625769,
					sizeY = 0.4857199,
					text = "气血：",
					color = "FFFEEACF",
					fontOutlineEnable = true,
					fontOutlineColor = "FFB8956F",
					fontOutlineSize = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wen11",
					varName = "text3",
					posX = 0.3964677,
					posY = 0.3083307,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6625769,
					sizeY = 0.4857199,
					text = "气血：",
					color = "FFFEEACF",
					fontOutlineEnable = true,
					fontOutlineColor = "FFB8956F",
					fontOutlineSize = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wen12",
					varName = "value3",
					posX = 0.8949769,
					posY = 0.6577286,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6625769,
					sizeY = 0.4857199,
					text = "+5000",
					color = "FFFEEACF",
					fontOutlineEnable = true,
					fontOutlineColor = "FFB8956F",
					fontOutlineSize = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wen13",
					varName = "count3",
					posX = 0.8949769,
					posY = 0.3083307,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6625769,
					sizeY = 0.4857199,
					text = "+5000",
					color = "FFFEEACF",
					fontOutlineEnable = true,
					fontOutlineColor = "FFB8956F",
					fontOutlineSize = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "bq3",
					varName = "free3",
					posX = 0.9397148,
					posY = 0.5120482,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1003236,
					sizeY = 0.9733334,
					image = "qz#mf",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hd6",
					varName = "red3",
					posX = 0.9525247,
					posY = 0.845947,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.09000001,
					sizeY = 0.3733334,
					image = "zdte#hd",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sx2",
				varName = "bg2",
				posX = 0.5473815,
				posY = 0.5199714,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3007755,
				sizeY = 0.9380708,
				image = "qz#db3",
				scale9Left = 0.4,
				scale9Right = 0.5,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "btn2",
					varName = "btn2",
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
					etype = "Label",
					name = "wen6",
					varName = "prop2",
					posX = 0.3964677,
					posY = 0.6577285,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6625769,
					sizeY = 0.4857199,
					text = "气血：",
					color = "FFFEEACF",
					fontOutlineEnable = true,
					fontOutlineColor = "FFB8956F",
					fontOutlineSize = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wen7",
					varName = "text2",
					posX = 0.3964677,
					posY = 0.3083307,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6625769,
					sizeY = 0.4857199,
					text = "气血：",
					color = "FFFEEACF",
					fontOutlineEnable = true,
					fontOutlineColor = "FFB8956F",
					fontOutlineSize = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wen8",
					varName = "value2",
					posX = 0.8949769,
					posY = 0.6577286,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6625769,
					sizeY = 0.4857199,
					text = "+5000",
					color = "FFFEEACF",
					fontOutlineEnable = true,
					fontOutlineColor = "FFB8956F",
					fontOutlineSize = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wen9",
					varName = "count2",
					posX = 0.8949769,
					posY = 0.3083307,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6625769,
					sizeY = 0.4857199,
					text = "+5000",
					color = "FFFEEACF",
					fontOutlineEnable = true,
					fontOutlineColor = "FFB8956F",
					fontOutlineSize = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "bq2",
					varName = "free2",
					posX = 0.9397148,
					posY = 0.5120482,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1003236,
					sizeY = 0.9733334,
					image = "qz#mf",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hd5",
					varName = "red2",
					posX = 0.9525247,
					posY = 0.845947,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.09000001,
					sizeY = 0.3733334,
					image = "zdte#hd",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sx1",
				varName = "bg1",
				posX = 0.2500939,
				posY = 0.5199713,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3007755,
				sizeY = 0.9380708,
				image = "qz#db3",
				scale9Left = 0.4,
				scale9Right = 0.5,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "btn",
					varName = "btn1",
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
					etype = "Label",
					name = "wen2",
					varName = "prop1",
					posX = 0.3964678,
					posY = 0.6577285,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6625769,
					sizeY = 0.4857199,
					text = "气血：",
					color = "FFFEEACF",
					fontOutlineEnable = true,
					fontOutlineColor = "FFB8956F",
					fontOutlineSize = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wen3",
					varName = "text1",
					posX = 0.3964678,
					posY = 0.3083307,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6625769,
					sizeY = 0.4857199,
					text = "气血：",
					color = "FFFEEACF",
					fontOutlineEnable = true,
					fontOutlineColor = "FFB8956F",
					fontOutlineSize = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wen4",
					varName = "value1",
					posX = 0.8949769,
					posY = 0.6577286,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6625769,
					sizeY = 0.4857199,
					text = "+5000",
					color = "FFFEEACF",
					fontOutlineEnable = true,
					fontOutlineColor = "FFB8956F",
					fontOutlineSize = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wen5",
					varName = "count1",
					posX = 0.8949769,
					posY = 0.3083307,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6625769,
					sizeY = 0.4857199,
					text = "+5000",
					color = "FFFEEACF",
					fontOutlineEnable = true,
					fontOutlineColor = "FFB8956F",
					fontOutlineSize = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "bq",
					varName = "free1",
					posX = 0.9397148,
					posY = 0.5120482,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1003236,
					sizeY = 0.9733334,
					image = "qz#mf",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hd4",
					varName = "red1",
					posX = 0.9525247,
					posY = 0.845947,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.09000001,
					sizeY = 0.3733334,
					image = "zdte#hd",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dj",
				varName = "number",
				posX = 0.04968298,
				posY = 0.5000895,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.07018096,
				sizeY = 0.8755328,
				image = "qz#1",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xian",
				posX = 0.5,
				posY = 0.02501522,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.05003044,
				image = "qz#fgx",
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
	gy3 = {
	},
	gy2 = {
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
	gy15 = {
	},
	gy16 = {
	},
	gy17 = {
	},
	gy18 = {
	},
	gy19 = {
	},
	gy20 = {
	},
	gy21 = {
	},
	gy22 = {
	},
	gy23 = {
	},
	gy24 = {
	},
	gy25 = {
	},
	gy26 = {
	},
	gy27 = {
	},
	gy28 = {
	},
	gy29 = {
	},
	gy30 = {
	},
	gy31 = {
	},
	gy32 = {
	},
	gy33 = {
	},
	gy34 = {
	},
	gy35 = {
	},
	gy36 = {
	},
	gy37 = {
	},
	gy38 = {
	},
	gy39 = {
	},
	gy40 = {
	},
	gy41 = {
	},
	gy42 = {
	},
	gy43 = {
	},
	gy44 = {
	},
	gy45 = {
	},
	gy46 = {
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
