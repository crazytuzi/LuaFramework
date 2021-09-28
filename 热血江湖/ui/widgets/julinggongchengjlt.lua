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
			sizeX = 0.07723847,
			sizeY = 0.1357842,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "djk",
				varName = "bg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9507892,
				sizeY = 0.961493,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt",
					varName = "img",
					posX = 0.5146075,
					posY = 0.5253119,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.820405,
					sizeY = 0.8366063,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "slz",
					posX = 0.5624266,
					posY = 0.1641128,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.7035766,
					sizeY = 0.7941148,
					text = "x10",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "tbn",
					varName = "btn",
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
