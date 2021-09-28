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
			name = "lbjd",
			varName = "root1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2234375,
			sizeY = 0.1388889,
		},
		children = {
		{
			prop = {
				etype = "Grid",
				name = "hh",
				varName = "rootNode",
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
					etype = "Button",
					name = "a",
					varName = "itemBtn",
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
					name = "tb",
					varName = "Bg",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1.008696,
					image = "qr#db1",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xzk",
					varName = "isSelect",
					posX = 0.5000001,
					posY = 0.5000001,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 1,
					sizeY = 1.008696,
					image = "qr#db2",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					effect = "isSelect",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dt6",
					varName = "itemBg",
					posX = 0.2300162,
					posY = 0.4846678,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4212762,
					sizeY = 1.08328,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "txt",
						varName = "itemIcon",
						posX = 0.4047669,
						posY = 0.5136592,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9710753,
						sizeY = 1.052359,
						image = "qr#dao",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tj",
					varName = "ask",
					posX = 0.6048036,
					posY = 0.2889835,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4195804,
					sizeY = 0.17,
					image = "qr#tj1",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mz",
					varName = "desc",
					posX = 0.7860641,
					posY = 0.715166,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7821016,
					sizeY = 0.4329703,
					text = "描述文字",
					color = "FF966856",
					fontSize = 22,
					fontOutlineColor = "FFC17E30",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "fgt",
					posX = 0.6885028,
					posY = 0.56,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5,
					sizeY = 0.14,
					image = "d2#fgt",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xh",
					varName = "redPoint",
					posX = 0.9537975,
					posY = 0.8693975,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.09440559,
					sizeY = 0.28,
					image = "zdte#hd",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sl",
				varName = "isFinish",
				posX = 0.289151,
				posY = 0.3190379,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2867133,
				sizeY = 0.61,
				image = "ty#xzjt",
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
