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
			name = "jiedian2",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.046875,
			sizeY = 0.08333351,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "shu2",
				varName = "icon",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 1.000002,
				sizeY = 1,
				image = "tb#yuanbao",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "suo",
					varName = "suo",
					posX = 0.6666666,
					posY = 0.3166674,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.4499991,
					sizeY = 0.4499991,
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
