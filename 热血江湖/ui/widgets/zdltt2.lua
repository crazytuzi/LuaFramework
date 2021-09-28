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
			name = "layoutRoot",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2984375,
			sizeY = 0.1027778,
		},
		children = {
		{
			prop = {
				etype = "Grid",
				name = "ltwz",
				varName = "bg",
				posX = 0.5,
				posY = 1,
				anchorX = 0.5,
				anchorY = 1,
				sizeX = 1,
				sizeY = 1,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "pd",
					varName = "set_image",
					posX = 0.1303339,
					posY = 0.7313513,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1806283,
					sizeY = 0.2837837,
					image = "lt#xt",
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "ltnr2",
					varName = "content",
					posX = 0.5189152,
					posY = 0.5405406,
					anchorX = 0.5,
					anchorY = 1,
					sizeX = 0.9316517,
					sizeY = 0.5675675,
					text = "hua",
					fontOutlineColor = "FF102E21",
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "ltnr",
					varName = "fromName",
					posX = 0.614311,
					posY = 0.731351,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7408669,
					sizeY = 0.4729729,
					text = "mingzi",
					fontOutlineColor = "FF27221D",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "vip",
					varName = "vipIcon",
					posX = 0.2909126,
					posY = 0.7023439,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.08900523,
					sizeY = 0.4594594,
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
