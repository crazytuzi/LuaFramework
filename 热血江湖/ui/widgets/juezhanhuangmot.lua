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
			name = "jjpht",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.671875,
			sizeY = 0.1276596,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tdt",
				varName = "sharder",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "b#lbt",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tpm1",
				varName = "rankImg",
				posX = 0.1414619,
				posY = 0.5139253,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1476744,
				sizeY = 0.6636572,
				image = "cl3#1st",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tpm2",
				varName = "rankLabel",
				posX = 0.1414619,
				posY = 0.4930623,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2469443,
				sizeY = 0.6239706,
				text = "4.",
				color = "FF634624",
				fontSize = 24,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dj1",
				varName = "root1",
				posX = 0.4892868,
				posY = 0.486147,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.09534881,
				sizeY = 0.8921294,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt1",
					varName = "icon1",
					posX = 0.499981,
					posY = 0.5276311,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8108343,
					sizeY = 0.8282878,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an1",
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
					name = "sl1",
					varName = "countLabel1",
					posX = 0.4713808,
					posY = 0.2241536,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8943671,
					sizeY = 0.4424916,
					text = "x555",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo1",
					varName = "lock1",
					posX = 0.2026743,
					posY = 0.2376662,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3384071,
					sizeY = 0.3456846,
					image = "tb#suo",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "bz",
					varName = "leader",
					posX = 0.2071314,
					posY = 0.6864435,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.3733333,
					sizeY = 0.6133333,
					image = "wdh#bz",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dj2",
				varName = "root2",
				posX = 0.5931894,
				posY = 0.4861472,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.09534881,
				sizeY = 0.8921294,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt2",
					varName = "icon2",
					posX = 0.499981,
					posY = 0.5276311,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8108343,
					sizeY = 0.8282878,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an2",
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
					name = "sl2",
					varName = "countLabel2",
					posX = 0.4713808,
					posY = 0.2241536,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8943671,
					sizeY = 0.4424916,
					text = "x555",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo2",
					varName = "lock2",
					posX = 0.2026743,
					posY = 0.2376662,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3384071,
					sizeY = 0.3456846,
					image = "tb#suo",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dj3",
				varName = "root3",
				posX = 0.6970921,
				posY = 0.4861472,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.09534881,
				sizeY = 0.8921294,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt3",
					varName = "icon3",
					posX = 0.499981,
					posY = 0.5276311,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8108343,
					sizeY = 0.8282878,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an3",
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
					name = "sl3",
					varName = "countLabel3",
					posX = 0.4713808,
					posY = 0.2241536,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8943671,
					sizeY = 0.4424916,
					text = "x555",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo3",
					varName = "lock3",
					posX = 0.2026743,
					posY = 0.2376662,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3384071,
					sizeY = 0.3456846,
					image = "tb#suo",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dj4",
				varName = "root4",
				posX = 0.8009947,
				posY = 0.4861472,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.09534881,
				sizeY = 0.8921294,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt4",
					varName = "icon4",
					posX = 0.499981,
					posY = 0.5276311,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8108343,
					sizeY = 0.8282878,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an4",
					varName = "btn4",
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
					name = "sl4",
					varName = "countLabel4",
					posX = 0.4713808,
					posY = 0.2241536,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8943671,
					sizeY = 0.4424916,
					text = "x555",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo4",
					varName = "lock4",
					posX = 0.2026743,
					posY = 0.2376662,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3384071,
					sizeY = 0.3456846,
					image = "tb#suo",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dj5",
				varName = "root5",
				posX = 0.9048973,
				posY = 0.486147,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				lockHV = true,
				sizeX = 0.09534881,
				sizeY = 0.8921294,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt5",
					varName = "icon5",
					posX = 0.499981,
					posY = 0.5276311,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8108343,
					sizeY = 0.8282878,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an5",
					varName = "btn5",
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
					name = "sl5",
					varName = "countLabel5",
					posX = 0.4713808,
					posY = 0.2241536,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8943671,
					sizeY = 0.4424916,
					text = "x555",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo5",
					varName = "lock5",
					posX = 0.2026743,
					posY = 0.2376662,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3384071,
					sizeY = 0.3456846,
					image = "tb#suo",
				},
			},
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
