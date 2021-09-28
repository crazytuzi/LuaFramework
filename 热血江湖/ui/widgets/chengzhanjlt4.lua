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
			posX = 0.4869294,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.5578125,
			sizeY = 0.1222222,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "ltb",
				posX = 0.118393,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2380952,
				sizeY = 1,
				image = "chengzhan#zikuang",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "ltb2",
				posX = 0.4288887,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3809524,
				sizeY = 1,
				image = "chengzhan#zikuang",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "ltb3",
				posX = 0.8108131,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3809524,
				sizeY = 1,
				image = "chengzhan#zikuang",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z2",
				varName = "score",
				posX = 0.118393,
				posY = 0.5064977,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2277078,
				sizeY = 0.8444229,
				text = "积 分",
				color = "FFFFFF69",
				fontSize = 22,
				fontOutlineColor = "FF143230",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "djk1",
				varName = "bg1",
				posX = 0.3204663,
				posY = 0.4889499,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1120448,
				sizeY = 0.909091,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt1",
					varName = "icon1",
					posX = 0.4982395,
					posY = 0.5125595,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8460609,
					sizeY = 0.8488647,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo",
					varName = "suo1",
					posX = 0.188023,
					posY = 0.2129717,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3375,
					sizeY = 0.3375002,
					image = "tb#suo",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "slz1",
					varName = "count1",
					posX = 0.566912,
					posY = 0.1943079,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7087876,
					sizeY = 0.7115921,
					text = "x10",
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
					varName = "btn1",
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
				name = "djk2",
				varName = "bg2",
				posX = 0.4316221,
				posY = 0.4889499,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1120448,
				sizeY = 0.909091,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt2",
					varName = "icon2",
					posX = 0.4982395,
					posY = 0.5125595,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8460609,
					sizeY = 0.8488647,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo2",
					varName = "suo2",
					posX = 0.188023,
					posY = 0.2129717,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3375,
					sizeY = 0.3375002,
					image = "tb#suo",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "slz2",
					varName = "count2",
					posX = 0.566912,
					posY = 0.1943079,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7087876,
					sizeY = 0.7115921,
					text = "x10",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
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
			},
		},
		{
			prop = {
				etype = "Image",
				name = "djk3",
				varName = "bg3",
				posX = 0.5427781,
				posY = 0.48895,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1120448,
				sizeY = 0.909091,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt3",
					varName = "icon3",
					posX = 0.4982395,
					posY = 0.5125595,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8460609,
					sizeY = 0.8488647,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo3",
					varName = "suo3",
					posX = 0.188023,
					posY = 0.2129717,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3375,
					sizeY = 0.3375002,
					image = "tb#suo",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "slz3",
					varName = "count3",
					posX = 0.566912,
					posY = 0.1943079,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7087876,
					sizeY = 0.7115921,
					text = "x10",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
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
			},
		},
		{
			prop = {
				etype = "Image",
				name = "djk4",
				varName = "bg4",
				posX = 0.6958521,
				posY = 0.4889499,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1120448,
				sizeY = 0.909091,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt4",
					varName = "icon4",
					posX = 0.4982395,
					posY = 0.5125595,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8460609,
					sizeY = 0.8488647,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo4",
					varName = "suo4",
					posX = 0.188023,
					posY = 0.2129717,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3375,
					sizeY = 0.3375002,
					image = "tb#suo",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "slz4",
					varName = "count4",
					posX = 0.566912,
					posY = 0.1943079,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7087876,
					sizeY = 0.7115921,
					text = "x10",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn4",
					varName = "btn4",
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
				name = "djk5",
				varName = "bg5",
				posX = 0.8105099,
				posY = 0.4889499,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1120448,
				sizeY = 0.909091,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt5",
					varName = "icon5",
					posX = 0.4982395,
					posY = 0.5125595,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8460609,
					sizeY = 0.8488647,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo5",
					varName = "suo5",
					posX = 0.188023,
					posY = 0.2129717,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3375,
					sizeY = 0.3375002,
					image = "tb#suo",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "slz5",
					varName = "count5",
					posX = 0.566912,
					posY = 0.1943079,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7087876,
					sizeY = 0.7115921,
					text = "x10",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn5",
					varName = "btn5",
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
				name = "djk6",
				varName = "bg6",
				posX = 0.9251678,
				posY = 0.48895,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1120448,
				sizeY = 0.909091,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt6",
					varName = "icon6",
					posX = 0.4982395,
					posY = 0.5125595,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8460609,
					sizeY = 0.8488647,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo6",
					varName = "suo6",
					posX = 0.188023,
					posY = 0.2129717,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3375,
					sizeY = 0.3375002,
					image = "tb#suo",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "slz6",
					varName = "count6",
					posX = 0.566912,
					posY = 0.1943079,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7087876,
					sizeY = 0.7115921,
					text = "x10",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn6",
					varName = "btn6",
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
