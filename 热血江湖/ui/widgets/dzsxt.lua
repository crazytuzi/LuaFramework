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
			name = "dzsxt",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.0859375,
			sizeY = 0.1388889,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "ta1",
				varName = "item_btn",
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
				etype = "Image",
				name = "wpk",
				varName = "item_bg",
				posX = 0.5,
				posY = 0.47,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.8996213,
				sizeY = 1,
				image = "djk#klan",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "wp",
					varName = "item_icon",
					posX = 0.5037631,
					posY = 0.5376549,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8,
					sizeY = 0.8,
					image = "items#items_baoshinengliang.png",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl",
					varName = "item_count",
					posX = 0.4806333,
					posY = 0.2603954,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7949767,
					sizeY = 0.3993428,
					text = "x100",
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xzk",
				varName = "is_select",
				posX = 0.499979,
				posY = 0.5049554,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8349904,
				sizeY = 0.9085732,
				image = "w#w_wpzz.png",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dj",
					posX = 0.5434746,
					posY = 0.5549524,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.6304668,
					sizeY = 0.4741245,
					image = "w#w_dj.png",
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
