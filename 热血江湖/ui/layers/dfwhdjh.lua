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
				name = "dddd",
				varName = "closeBtn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				disablePressScale = true,
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
					posX = 0.4999999,
					posY = 0.8428196,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6828067,
					sizeY = 0.1808362,
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
						posX = 0.227217,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.39763,
						sizeY = 1,
						text = "您额外获得了1次",
						color = "FF966856",
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "w",
						posX = 0.8662152,
						posY = 0.4999998,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2243245,
						sizeY = 1,
						text = "的机会。",
						color = "FF966856",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "xg",
						posX = 0.5912501,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.282249,
						sizeY = 1,
						text = "投掷骰子",
						color = "FFFF7E2D",
						fontSize = 26,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hd",
					posX = 0.5,
					posY = 0.2588711,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9,
					sizeY = 0.7886792,
					image = "dfw3#dfw3",
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
				posY = -0.215804,
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
