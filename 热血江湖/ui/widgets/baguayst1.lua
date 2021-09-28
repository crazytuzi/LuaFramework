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
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.09609868,
			sizeY = 0.1250005,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "btns",
				varName = "baguaBtn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9058201,
				sizeY = 0.9880765,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "daoj",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.6910215,
				sizeY = 0.9444404,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "daojt",
					varName = "icon",
					posX = 0.4968076,
					posY = 0.515521,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9882353,
					sizeY = 1,
					image = "yishu#li",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xzk",
				varName = "select",
				posX = 0.4674816,
				posY = 0.5555555,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				lockHV = true,
				sizeX = 0.8698741,
				sizeY = 1.188884,
				image = "yishu#xz",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dengj",
				varName = "zhuanjing",
				posX = 0.7434701,
				posY = 0.233815,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3495756,
				sizeY = 0.4777758,
				image = "yishu#djfang",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "djz",
					varName = "count",
					posX = 0.4767442,
					posY = 0.4534884,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.676119,
					sizeY = 1.266021,
					text = "10",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 1,
					vTextAlign = 1,
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
	gy = {
	},
	gy2 = {
	},
	gy3 = {
	},
	gy4 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
