--version = 1
local l_fileType = "layer"

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
			varName = "root",
			posX = 0.296572,
			posY = 0.5188217,
			anchorX = 0,
			anchorY = 0,
			sizeX = 0.234626,
			sizeY = 0.2123567,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "buffd",
				posX = 0.1929497,
				posY = 0.2257536,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5217934,
				sizeY = 0.3989619,
				image = "b#lvk",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "wz",
					varName = "text",
					posX = 0.5,
					posY = 0.6397239,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9177115,
					sizeY = 0.6581126,
					text = "留发的个字够",
					fontSize = 22,
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
