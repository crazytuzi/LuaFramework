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
			name = "k",
			posX = 0.5,
			posY = 0.4999996,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2257812,
			sizeY = 0.105381,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an1",
				posX = 0.2560468,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4740303,
				sizeY = 0.764422,
				image = "chu1#fy1",
				imageNormal = "chu1#fy1",
				imagePressed = "chu1#fy2",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "wb1",
					posX = 0.4972138,
					posY = 0.5082794,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8890842,
					sizeY = 0.7057384,
					text = "人物列表",
					fontSize = 24,
					fontOutlineEnable = true,
					fontOutlineColor = "FFA47848",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an2",
				posX = 0.7454889,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4740303,
				sizeY = 0.764422,
				image = "chu1#fy1",
				imageNormal = "chu1#fy1",
				imagePressed = "chu1#fy2",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "wb2",
					posX = 0.4972138,
					posY = 0.5082794,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8890842,
					sizeY = 0.7057384,
					text = "人物列表",
					fontSize = 24,
					fontOutlineEnable = true,
					fontOutlineColor = "FFA47848",
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
