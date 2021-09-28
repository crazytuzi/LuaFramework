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
			name = "k1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.07421875,
			sizeY = 0.1319444,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dj1",
				varName = "btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dk",
					varName = "iconbg",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 1,
					sizeY = 0.9789477,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "tp1",
						varName = "icon",
						posX = 0.5,
						posY = 0.5190447,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8,
						sizeY = 0.8207375,
						image = "items#items_gaojijinengshu.png",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "suo",
						posX = 0.1741398,
						posY = 0.2101733,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.2947369,
						sizeY = 0.3010753,
						image = "tb#suo",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sl",
						varName = "count",
						posX = 0.5548774,
						posY = 0.2028991,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7308626,
						sizeY = 0.3074981,
						text = "x11",
						fontOutlineEnable = true,
						hTextAlign = 2,
						vTextAlign = 1,
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
