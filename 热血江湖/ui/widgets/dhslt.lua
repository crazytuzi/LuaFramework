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
			name = "jd1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.07536867,
			sizeY = 0.1652121,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "djd",
				varName = "item_bg",
				posX = 0.5,
				posY = 0.5756603,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.974377,
				sizeY = 0.79023,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt",
					varName = "item_icon",
					posX = 0.5,
					posY = 0.5251277,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8,
					sizeY = 0.8,
					image = "items#xueping1.png",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo2",
					varName = "item_lock",
					posX = 0.1978613,
					posY = 0.2257828,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3157895,
					sizeY = 0.3125,
					image = "tb#suo",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z5",
					varName = "item_count",
					posX = 0.5,
					posY = -0.09822303,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.141933,
					sizeY = 0.3938436,
					text = "道具类型",
					color = "FF65944D",
					fontSize = 18,
					fontOutlineColor = "FFFCEBCF",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn",
					varName = "bt",
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
