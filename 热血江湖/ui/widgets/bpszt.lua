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
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2140625,
			sizeY = 0.1180556,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "b#lbt",
				scale9Left = 0.3,
				scale9Right = 0.6,
				imageNormal = "b#lbt",
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "z",
					varName = "btnName",
					posX = 0.4031653,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7547868,
					sizeY = 0.95,
					text = "修改国家图示",
					color = "FF966856",
					fontSize = 25,
					fontOutlineColor = "FF276C61",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
					wordSpaceAdd = -1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jt",
					posX = 0.8451855,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1569343,
					sizeY = 0.6352939,
					image = "chu1#jiantou",
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
