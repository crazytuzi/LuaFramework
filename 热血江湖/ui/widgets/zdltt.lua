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
			posX = 0.5007812,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2984375,
			sizeY = 0.1227778,
		},
		children = {
		{
			prop = {
				etype = "Grid",
				name = "ltwz",
				varName = "imgUI",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
			children = {
			{
				prop = {
					etype = "RichText",
					name = "ltnr",
					varName = "b",
					posX = 0.6143077,
					posY = 0.479343,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7408669,
					sizeY = 0.8979937,
					text = "谁谁谁：什么什么话。",
					fontOutlineColor = "FF102E21",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "pd",
					varName = "set_image",
					posX = 0.1303339,
					posY = 0.8111596,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1806283,
					sizeY = 0.2375565,
					image = "lt#xt",
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
