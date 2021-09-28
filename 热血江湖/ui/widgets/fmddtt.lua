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
			sizeX = 0.2398438,
			sizeY = 0.1125,
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
				sizeX = 0.993485,
				sizeY = 0.9876543,
				image = "b#scd1",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				imageNormal = "b#scd1",
				imagePressed = "b#scd2",
				imageDisable = "b#scd1",
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt2",
				varName = "pickup",
				posX = 0.8383374,
				posY = 0.4826389,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.0456026,
				sizeY = 0.1851852,
				image = "chu1#jt",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z1",
				varName = "name",
				posX = 0.3731707,
				posY = 0.5075834,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6048694,
				sizeY = 0.7982667,
				text = "人物",
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
				varName = "open",
				posX = 0.8383374,
				posY = 0.4826389,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.05863191,
				sizeY = 0.2716049,
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
