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
			sizeX = 0.5390625,
			sizeY = 0.1180556,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dt3",
				varName = "btn",
				posX = 0.4999999,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.975,
				sizeY = 0.9176467,
				image = "b#chd",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				imageNormal = "b#chd",
				imagePressed = "b#chd",
				imageDisable = "b#chd",
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "xian",
					posX = 0.6506246,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5891464,
					sizeY = 0.02564103,
					image = "b#xian",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt2",
				varName = "pickupImg",
				posX = 0.06733972,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.02028986,
				sizeY = 0.1764705,
				image = "chu1#jt",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z1",
				varName = "nameLabel",
				posX = 0.4020897,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5915828,
				sizeY = 0.7982667,
				text = "称号类型",
				color = "FFF1E9D7",
				fontSize = 22,
				fontOutlineEnable = true,
				fontOutlineColor = "FFA47848",
				fontOutlineSize = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt4",
				varName = "openImg",
				posX = 0.06696964,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.02608696,
				sizeY = 0.2588234,
				image = "chu1#jt2",
				rotation = 90,
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
