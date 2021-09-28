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
			sizeX = 0.1679688,
			sizeY = 0.125,
		},
		children = {
		{
			prop = {
				etype = "Label",
				name = "z2",
				varName = "pos",
				posX = 0.3731707,
				posY = 0.4972105,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.6048694,
				sizeY = 0.7982667,
				text = "NPC位置",
				color = "FF966856",
				fontOutlineColor = "FFA47848",
				fontOutlineSize = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "scd",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "b#scd1",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "dt3",
				posX = 0.4999999,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.993485,
				sizeY = 0.9876543,
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				disablePressScale = true,
				propagateToChildren = true,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "xy",
					varName = "Trans",
					posX = 0.8371105,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2247198,
					sizeY = 0.54,
					image = "sjdt2#csjt",
					imageNormal = "sjdt2#csjt",
					disablePressScale = true,
					disableClick = true,
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z1",
				varName = "name",
				posX = 0.5755718,
				posY = 0.709094,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.028276,
				sizeY = 0.7982667,
				text = "NPC名称",
				color = "FF804040",
				fontOutlineColor = "FFA47848",
				fontOutlineSize = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z3",
				varName = "status",
				posX = 0.3968019,
				posY = 0.3016083,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6707365,
				sizeY = 0.7982667,
				text = "需攻破外城城门",
				color = "FF966856",
				fontSize = 18,
				fontOutlineColor = "FFA47848",
				fontOutlineSize = 2,
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
