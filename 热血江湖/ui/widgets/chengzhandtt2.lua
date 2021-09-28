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
			name = "k2",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.1679688,
			sizeY = 0.05933314,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt5",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.95,
				sizeY = 0.8333334,
				alpha = 0.3,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z2",
				varName = "name",
				posX = 0.6202562,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7871113,
				sizeY = 0.7982667,
				text = "NPC名字123",
				color = "FFF1C58F",
				fontSize = 18,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "a1",
				varName = "selectBtn",
				posX = 0.3608979,
				posY = 0.5086626,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6553105,
				sizeY = 0.8839806,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "a2",
				varName = "transBtn",
				posX = 0.8669832,
				posY = 0.5086626,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2600329,
				sizeY = 0.8839806,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tx",
				varName = "flagImg",
				posX = 0.1352332,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.09771985,
				sizeY = 0.4918033,
				image = "chengzhan#binggongchang",
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
