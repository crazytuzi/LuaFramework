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
			sizeX = 0.07734375,
			sizeY = 0.1375,
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
		},
		{
			prop = {
				etype = "Image",
				name = "dk",
				varName = "gradeIcon",
				posX = 0.5,
				posY = 0.4805826,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.9515225,
				sizeY = 0.9708735,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tp1",
					varName = "icon",
					posX = 0.5000893,
					posY = 0.5417482,
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
					name = "sl",
					varName = "countLabel",
					posX = 0.4999534,
					posY = 0.2136014,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8054652,
					sizeY = 0.3842807,
					text = "99",
					fontSize = 18,
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
				name = "xz",
				varName = "selectImg",
				posX = 0.5,
				posY = 0.5119013,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.9023485,
				sizeY = 0.9392502,
				image = "hd#hd_xzk.png",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dj",
				varName = "hook",
				posX = 0.2983202,
				posY = 0.7823911,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.5431362,
				sizeY = 0.4040404,
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
