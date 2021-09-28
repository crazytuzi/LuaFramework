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
			etype = "Image",
			name = "aaa",
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
				name = "sss",
				varName = "closeBtn",
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
			etype = "Grid",
			name = "ysjm",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.4375,
			sizeY = 0.3680556,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "db",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "b#cs",
				scale9 = true,
				scale9Left = 0.47,
				scale9Right = 0.47,
				scale9Top = 0.2,
				scale9Bottom = 0.6,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dh",
					posX = 0.3279594,
					posY = 0.4137066,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5508813,
					sizeY = 0.2644333,
					image = "b#d2",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "sm",
						varName = "label",
						posX = 0.5142009,
						posY = 0.4999996,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9715977,
						sizeY = 1,
						text = "您被酒店老板拉人酒店入住，消耗1次掷骰子机会。",
						color = "FF8F61AC",
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hd",
					posX = 0.8964255,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7285714,
					sizeY = 1.188679,
					image = "dfw1#dfw1",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "gx",
					posX = 0.2070423,
					posY = 0.6696005,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2792739,
					sizeY = 0.25,
					text = "很遗憾 您获得了",
					color = "FF966856",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "xg",
					posX = 0.4641559,
					posY = 0.6696004,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2286872,
					sizeY = 0.25,
					text = "免费住店",
					color = "FF8F61AC",
					fontSize = 26,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "ddd",
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
				name = "wz",
				posX = 0.5,
				posY = -0.1330279,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.25,
				text = "点击任意空白位置关闭",
				hTextAlign = 1,
				vTextAlign = 1,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "zs1",
					posX = 1.028895,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3392857,
					sizeY = 0.135849,
					image = "tong#zsx2",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zs2",
					posX = -0.028895,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3392857,
					sizeY = 0.135849,
					image = "tong#zsx2",
					flippedX = true,
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
