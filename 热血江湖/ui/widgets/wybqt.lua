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
			name = "lbjd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2117188,
			sizeY = 0.1331599,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "a",
				varName = "mod_btn",
				posX = 0.5164835,
				posY = 0.4999997,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9760739,
				sizeY = 0.95,
				image = "b#scd1",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				imageNormal = "b#scd1",
				imagePressed = "b#scd2",
				imageDisable = "b#scd1",
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz",
				varName = "name",
				posX = 0.4586381,
				posY = 0.6437842,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5838173,
				sizeY = 0.5584114,
				text = "宠物",
				fontSize = 24,
				fontOutlineEnable = true,
				fontOutlineColor = "FF6F3A14",
				vTextAlign = 1,
				colorTL = "FFFFDC4E",
				colorTR = "FFFFDC4E",
				colorBR = "FFFF6F28",
				colorBL = "FFFF6F28",
				useQuadColor = true,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt2",
				varName = "re_image",
				posX = 0.06548944,
				posY = 0.6134786,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.103321,
				sizeY = 0.7301164,
				image = "wybq#tj",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jdt",
				posX = 0.5221404,
				posY = 0.2288135,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9372692,
				sizeY = 0.2503256,
				image = "chu1#jdd2",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "LoadingBar",
					name = "jt",
					varName = "fight_bar",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9645669,
					sizeY = 0.5833334,
					image = "wybq#jdt",
					percent = 50,
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
