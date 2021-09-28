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
			sizeX = 0.1934319,
			sizeY = 0.1042019,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "a1",
				varName = "btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7027667,
				sizeY = 0.8797024,
				image = "chu1#an2",
				imageNormal = "chu1#an2",
				soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "f1",
					varName = "btnName",
					posX = 0.5057301,
					posY = 0.5468748,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9639333,
					sizeY = 0.9422305,
					text = "取 消",
					fontSize = 24,
					fontOutlineEnable = true,
					fontOutlineColor = "FF2A6953",
					fontOutlineSize = 2,
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
