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
			sizeX = 0.0703125,
			sizeY = 0.1388889,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dj1",
				varName = "bg",
				posX = 0.5,
				posY = 0.58,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.9,
				sizeY = 0.8100002,
				image = "djk#kbai",
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "ban",
					varName = "btn",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					effect = "btnRwd0",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "djt1",
					varName = "icon",
					posX = 0.4986848,
					posY = 0.522688,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7460668,
					sizeY = 0.7568947,
					image = "imgRwd0",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl1",
					varName = "count",
					posX = 0.5,
					posY = -0.07670979,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 2.032826,
					sizeY = 0.6960544,
					image = "txtRwd0Num",
					text = "x55",
					fontSize = 18,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo",
					varName = "lock",
					posX = 0.2132257,
					posY = 0.2238212,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3191488,
					sizeY = 0.3191489,
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
