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
			name = "jid",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1015625,
			sizeY = 0.1687915,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "cl1",
				varName = "costtextbg",
				posX = 0.5,
				posY = 0.6234261,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.6153846,
				sizeY = 0.6444159,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "wp2",
					varName = "costIcon",
					posX = 0.4947425,
					posY = 0.5468019,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8,
					sizeY = 0.8,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "wwe1",
					varName = "costbtn",
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
		{
			prop = {
				etype = "Label",
				name = "cl3",
				varName = "costtext",
				posX = 0.5,
				posY = 0.212006,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9059572,
				sizeY = 0.4460071,
				text = "5/10",
				color = "FF634624",
				fontSize = 22,
				fontOutlineColor = "FF102E21",
				hTextAlign = 1,
				vTextAlign = 1,
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
