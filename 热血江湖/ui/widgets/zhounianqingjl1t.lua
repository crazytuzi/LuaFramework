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
			sizeX = 0.0703125,
			sizeY = 0.125,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "zbd2",
				varName = "item_bg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.99,
				sizeY = 0.99,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "zbt2",
					varName = "item_icon",
					posX = 0.4894737,
					posY = 0.5416668,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.8241493,
					sizeY = 0.8155648,
					image = "ls#ls_jinggangtoukui.png",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl",
					varName = "count",
					posX = 0.4919803,
					posY = 0.1943065,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8795741,
					sizeY = 0.4420237,
					text = "x15",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn",
					varName = "btn",
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
					name = "suo",
					varName = "lockImg",
					posX = 0.1703693,
					posY = 0.2088341,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.2731946,
					sizeY = 0.2798803,
					image = "tb#suo",
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
