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
			name = "jie",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.4203123,
			sizeY = 0.05277778,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "jdtd",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7899632,
				sizeY = 0.8421053,
				image = "chu1#jdd",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
			},
			children = {
			{
				prop = {
					etype = "LoadingBar",
					name = "jdt",
					varName = "expbar",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9681942,
					sizeY = 0.6250001,
					image = "tong#jdt",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "jyz",
					varName = "expbarCount",
					posX = 0.4999999,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7763522,
					sizeY = 1.880983,
					text = "9999999/99999999",
					fontOutlineEnable = true,
					fontOutlineColor = "FF567D23",
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
