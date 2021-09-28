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
			name = "jd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1734375,
			sizeY = 0.09583333,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dj1",
				varName = "bt",
				posX = 0.1891891,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3108108,
				sizeY = 1,
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dk",
					varName = "grade_icon",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					image = "djk#kbai",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "tp1",
						varName = "item_icon",
						posX = 0.5,
						posY = 0.5209021,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8,
						sizeY = 0.8,
						image = "items#items_gaojijinengshu.png",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wz",
						varName = "item_count",
						posX = 2.599705,
						posY = 0.4954098,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 3.009398,
						sizeY = 0.6274893,
						text = "x22",
						fontSize = 18,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "suo",
						varName = "item_lock",
						posX = 0.1950916,
						posY = 0.2190415,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3157895,
						sizeY = 0.3125,
						image = "tb#suo",
					},
				},
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
