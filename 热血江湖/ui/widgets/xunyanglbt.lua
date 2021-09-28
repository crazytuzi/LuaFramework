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
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.06640625,
			sizeY = 0.1138889,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "a",
				varName = "selectBtn",
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
				name = "dk",
				varName = "iconBg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "djk#ktong",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tb",
				varName = "icon",
				posX = 0.5,
				posY = 0.5121951,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.798663,
				sizeY = 0.8278824,
				image = "tx#xiaoxiangf",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt1",
				varName = "levelIcon",
				posX = 0.204729,
				posY = 0.1967108,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.4235294,
				sizeY = 0.4390244,
				image = "suic#djk",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "dj",
					varName = "level",
					posX = 0.4722222,
					posY = 0.4722222,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 2.440272,
					sizeY = 1.500868,
					text = "15",
					color = "FFFFE7AF",
					fontSize = 18,
					fontOutlineEnable = true,
					fontOutlineColor = "FF975E1F",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xz",
				varName = "selectImg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 1.080555,
				sizeY = 1.120087,
				image = "djk#xz",
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
