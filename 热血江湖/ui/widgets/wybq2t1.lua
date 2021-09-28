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
			sizeX = 0.5304688,
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
				image = "wybq2#lbt",
				scale9Left = 0.4,
				scale9Right = 0.4,
				imageNormal = "wybq2#lbt",
				imagePressed = "wybq2#lbt",
				imageDisable = "wybq2#lbt",
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "xian",
					posX = 0.5930041,
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
				posX = 0.9091099,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.04418261,
				sizeY = 0.6117645,
				image = "wybq2#sq1",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z1",
				varName = "nameLabel",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.664066,
				sizeY = 0.7982667,
				text = "功能",
				color = "FFF8C84A",
				fontSize = 26,
				fontOutlineEnable = true,
				fontOutlineColor = "FF8C4300",
				fontOutlineSize = 2,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt4",
				varName = "openImg",
				posX = 0.9116852,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.0765832,
				sizeY = 0.3647057,
				image = "wybq2#dk1",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tb",
				varName = "img",
				posX = 0.09387414,
				posY = 0.5117647,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1030928,
				sizeY = 0.8235291,
				image = "tb#wg",
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
