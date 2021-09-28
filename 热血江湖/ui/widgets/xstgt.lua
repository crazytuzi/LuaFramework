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
			sizeX = 0.09453125,
			sizeY = 0.1916667,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "xz",
				varName = "select",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.9999998,
				image = "sc#xz",
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "dj1",
				varName = "btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.030928,
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
					posY = 0.6039577,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.7615702,
					sizeY = 0.6739129,
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
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xk",
					varName = "zhekou",
					posX = 0.3239001,
					posY = 0.8490863,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6333057,
					sizeY = 0.3260869,
					image = "sc#7z",
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
