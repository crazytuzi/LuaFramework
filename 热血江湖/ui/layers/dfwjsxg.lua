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
					posX = 0.3145889,
					posY = 0.3930047,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5241404,
					sizeY = 0.3058371,
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
						text = "接下来的3次投掷骰子时将会出现3个骰子，可前进3-18步。",
						color = "FF498353",
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hd",
					posX = 0.941068,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7946429,
					sizeY = 1.15849,
					image = "dfw4#dfw4",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "gx",
					posX = 0.1924458,
					posY = 0.6696005,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2500808,
					sizeY = 0.25,
					text = "恭喜 您获得了",
					color = "FF966856",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "xg",
					posX = 0.4284419,
					posY = 0.6696004,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2286872,
					sizeY = 0.25,
					text = "急速效果",
					color = "FF498353",
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
				posY = -0.1292543,
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
