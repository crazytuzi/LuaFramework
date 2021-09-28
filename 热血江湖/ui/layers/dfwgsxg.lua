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
					posX = 0.3912472,
					posY = 0.1817016,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6631964,
					sizeY = 0.1770312,
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
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9431959,
						sizeY = 1,
						text = "接下来的3次投掷骰子时只能前进一步。",
						color = "FFC93034",
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hd",
					posX = 0.6553534,
					posY = 0.7000008,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7196429,
					sizeY = 0.8301886,
					image = "dfw2#dfw2",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "gx",
					posX = 0.2035256,
					posY = 0.3870414,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2500808,
					sizeY = 0.25,
					text = "您获得了",
					color = "FF966856",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "xg",
					posX = 0.3535193,
					posY = 0.3870415,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2286872,
					sizeY = 0.25,
					text = "龟速效果",
					color = "FFC93034",
					fontSize = 26,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "w",
					posX = 0.1690476,
					posY = 0.5187514,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1769865,
					sizeY = 0.25,
					text = "很遗憾",
					color = "FF966856",
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
				posY = -0.0688768,
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
