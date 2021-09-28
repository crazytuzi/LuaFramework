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
		soundEffectOpen = "audio/rxjh/UI/ui_jiangli2.ogg",
	},
	children = {
	{
		prop = {
			etype = "Image",
			name = "ddd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			image = "b#dd",
			scale9 = true,
			scale9Left = 0.2,
			scale9Right = 0.2,
			scale9Top = 0.2,
			scale9Bottom = 0.2,
			alpha = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dd",
				varName = "ok",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
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
				name = "dg",
				posX = 0.5,
				posY = 0.6497473,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1867188,
				sizeY = 0.3319444,
				image = "top#dg2",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt",
				varName = "dt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.7800574,
				sizeY = 0.3027778,
				image = "d#diban",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
				alpha = 0,
				alphaCascade = true,
			},
			children = {
			{
				prop = {
					etype = "Grid",
					name = "jl1",
					varName = "award",
					posX = 0.5,
					posY = 0.4747435,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1959775,
					sizeY = 0.9479876,
					alphaCascade = true,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "jlz",
						posX = 0.5,
						posY = 0.8381632,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.963137,
						sizeY = 0.25,
						text = "仔细鉴定后，您获得了：",
						color = "FF634624",
						fontSize = 24,
						fontOutlineColor = "FF27221D",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "wp1",
						varName = "item_bg",
						posX = 0.5,
						posY = 0.4951612,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4854907,
						sizeY = 0.4500116,
						image = "djk#ktong",
						alphaCascade = true,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "djt1",
							varName = "item_icon",
							posX = 0.5000003,
							posY = 0.5357412,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8000003,
							sizeY = 0.8118517,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "suo",
							varName = "bindIcon",
							posX = 0.1951795,
							posY = 0.2385602,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3157895,
							sizeY = 0.3225807,
							image = "tb#suo",
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "mz",
						varName = "item_desc",
						posX = 0.5,
						posY = 0.2048332,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 0.25,
						text = "什么道具x100",
						color = "FF634624",
						fontSize = 22,
						fontOutlineColor = "FF27221D",
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
				etype = "Image",
				name = "dg2",
				posX = 0.5,
				posY = 0.6705808,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1726563,
				sizeY = 0.08888889,
				image = "top#lqcg",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sz1",
				posX = 0.3705504,
				posY = 0.3266647,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0890625,
				sizeY = 0.0125,
				image = "tong#zsx2",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sz2",
				posX = 0.6302946,
				posY = 0.3266647,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0890625,
				sizeY = 0.0125,
				image = "tong#zsx2",
				alpha = 0,
				flippedX = true,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "xs",
				posX = 0.5,
				posY = 0.32642,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3881353,
				sizeY = 0.08617477,
				text = "点击空白区域继续",
				fontSize = 22,
				fontOutlineEnable = true,
				fontOutlineColor = "FF27221D",
				hTextAlign = 1,
				vTextAlign = 1,
				alpha = 0,
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
	zi = {
		dg2 = {
			move = {{0, {640, 1100, 0}}, {300, {640,482.8182,0}}, {350, {640, 500, 0}}, {400, {640,482.8182,0}}, },
			alpha = {{0, {1}}, },
		},
	},
	guang = {
		dg = {
			rotate = {{0, {0}}, {3000, {180}}, },
			alpha = {{0, {1}}, },
		},
	},
	dt = {
		dt = {
			scale = {{0, {0, 0, 1}}, {150, {1.1, 1.1, 1}}, {200, {1,1,1}}, },
			alpha = {{0, {1}}, },
		},
	},
	dg2 = {
		sz1 = {
			alpha = {{0, {0}}, {300, {1}}, },
		},
		sz2 = {
			alpha = {{0, {0}}, {300, {1}}, },
		},
		xs = {
			alpha = {{0, {0}}, {300, {1}}, },
		},
	},
	c_dakai = {
		{0,"zi", 1, 0},
		{0,"guang", -1, 300},
		{0,"dt", 1, 0},
		{0,"dg2", 1, 200},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
