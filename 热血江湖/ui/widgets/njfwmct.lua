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
			name = "zclbjd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1992188,
			sizeY = 0.1222222,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "ann",
				varName = "LangBtn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9333331,
				sizeY = 0.9772729,
				image = "njfw#fy1",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				imageNormal = "njfw#fy1",
				imagePressed = "njfw#fy2",
				imageDisable = "njfw#fy1",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "bk",
				varName = "bg",
				posX = 0.5149238,
				posY = 0.4997934,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9647056,
				sizeY = 1.056818,
				image = "njfw#zzz",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xzts",
				varName = "sign",
				posX = 0.1188937,
				posY = 0.5619401,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.1529411,
				sizeY = 0.8636365,
				image = "njfw#sxz",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "fwmcwz",
				varName = "LangName",
				posX = 0.5,
				posY = 0.501859,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9408177,
				sizeY = 0.8481492,
				text = "艾利之语",
				color = "FFECAC94",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xzts2",
				varName = "upred",
				posX = 0.9036272,
				posY = 0.8341757,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.1058823,
				sizeY = 0.3181819,
				image = "zdte#hd",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "kqh",
				varName = "cutSign",
				posX = 0.1188937,
				posY = 0.5619401,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.1529411,
				sizeY = 0.8636365,
				image = "njfw#kqh",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xingxing",
				varName = "star",
				posX = 0.363042,
				posY = 0.7888322,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.462745,
				sizeY = 0.2613637,
				image = "njfw#5dian",
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
