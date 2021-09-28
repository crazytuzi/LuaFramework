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
			name = "scczt",
			varName = "itemRoot",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1482762,
			sizeY = 0.1069444,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "play_btn",
				posX = 0.5,
				posY = 0.5238096,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9,
				sizeY = 0.9,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tx1",
				varName = "pet_iconBg",
				posX = 0.2162288,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.4057037,
				sizeY = 1,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "txt1",
					varName = "pet_icon",
					posX = 0.5,
					posY = 0.5131912,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.83,
					sizeY = 0.83,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xx1",
					varName = "start_icon",
					posX = 0.1922056,
					posY = 0.2100606,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3246756,
					sizeY = 0.3246754,
					image = "tb#suo",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "zl2",
				varName = "pet_power",
				posX = 0.9838516,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.068226,
				sizeY = 0.5711706,
				text = "654321",
				color = "FF966856",
				fontOutlineColor = "FF400000",
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
