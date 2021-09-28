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
			name = "k1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.45,
			sizeY = 0.06388889,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "bt",
				varName = "bg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "d#bt",
				alpha = 0.5,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wz1",
				varName = "rank",
				posX = 0.1013485,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2604167,
				sizeY = 1,
				text = "第一名：",
				color = "FF875E3D",
				fontOutlineColor = "FF2E1410",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dj1",
				varName = "reward1",
				posX = 0.2393876,
				posY = 0.4667118,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.07291666,
				sizeY = 0.9130436,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt1",
					varName = "rewardIcon1",
					posX = 0.5,
					posY = 0.537037,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8,
					sizeY = 0.8,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl1",
					varName = "rewardCount1",
					posX = 1.826947,
					posY = 0.5562323,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.582124,
					sizeY = 1.030928,
					text = "x10000",
					color = "FF875E3D",
					fontSize = 18,
					fontOutlineColor = "FF2E1410",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo",
					posX = 0.2643296,
					posY = 0.3229533,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.4735363,
					sizeY = 0.4686036,
					image = "tb#tb_suo.png",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn",
					varName = "bt1",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dj2",
				varName = "reward2",
				posX = 0.4430876,
				posY = 0.4667115,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.07291666,
				sizeY = 0.9130437,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt2",
					varName = "rewardIcon2",
					posX = 0.5,
					posY = 0.537037,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8,
					sizeY = 0.8,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl2",
					varName = "rewardCount2",
					posX = 1.826947,
					posY = 0.5562323,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.582124,
					sizeY = 1.030928,
					text = "x10000",
					color = "FF875E3D",
					fontSize = 18,
					fontOutlineColor = "FF2E1410",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn2",
					varName = "bt2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dj3",
				varName = "reward3",
				posX = 0.6467876,
				posY = 0.4667115,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.07291666,
				sizeY = 0.9130437,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt3",
					varName = "rewardIcon3",
					posX = 0.5,
					posY = 0.537037,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8,
					sizeY = 0.8,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl3",
					varName = "rewardCount3",
					posX = 1.826947,
					posY = 0.5562323,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.582124,
					sizeY = 1.030928,
					text = "x10000",
					color = "FF875E3D",
					fontSize = 18,
					fontOutlineColor = "FF2E1410",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo2",
					posX = 0.2643296,
					posY = 0.3229533,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4735363,
					sizeY = 0.4686036,
					image = "tb#tb_suo.png",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn3",
					varName = "bt3",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dj4",
				varName = "reward4",
				posX = 0.8504875,
				posY = 0.4667115,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.07291666,
				sizeY = 0.9130437,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt4",
					varName = "rewardIcon4",
					posX = 0.5,
					posY = 0.537037,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8,
					sizeY = 0.8,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl4",
					varName = "rewardCount4",
					posX = 1.826947,
					posY = 0.5562323,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.582124,
					sizeY = 1.030928,
					text = "x10000",
					color = "FF875E3D",
					fontSize = 18,
					fontOutlineColor = "FF2E1410",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn4",
					varName = "bt4",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dj5",
				varName = "reward5",
				posX = 0.8504875,
				posY = 0.4667115,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.07291666,
				sizeY = 0.9130437,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt5",
					varName = "rewardIcon5",
					posX = 0.5,
					posY = 0.537037,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8,
					sizeY = 0.8,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl5",
					varName = "rewardCount5",
					posX = 1.826947,
					posY = 0.5562323,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.582124,
					sizeY = 1.030928,
					text = "x10000",
					color = "FF875E3D",
					fontSize = 18,
					fontOutlineColor = "FF2E1410",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn5",
					varName = "bt5",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "pm",
				varName = "rankImage",
				posX = 0.1013485,
				posY = 0.480818,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1590391,
				sizeY = 0.9565216,
				image = "cl3#1st",
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
