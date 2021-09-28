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
			lockHV = true,
			sizeX = 0.2578125,
			sizeY = 0.2103841,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "jt",
				varName = "is_show",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7175618,
				sizeY = 0.7711288,
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.2,
				scale9Bottom = 0.2,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "a",
				varName = "select1_btn",
				posX = 0.4859464,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9614763,
				sizeY = 1,
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "t1",
				varName = "bg",
				posX = 0.4973958,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9212121,
				sizeY = 0.9638456,
				image = "fb#sk4",
				scale9Left = 0.33,
				scale9Right = 0.33,
				scale9Top = 0.33,
				scale9Bottom = 0.33,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tb",
				varName = "icon",
				posX = 0.5095222,
				posY = 0.5066,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.7692307,
				sizeY = 0.726185,
				image = "fbt#longtingya",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt2",
				varName = "is_lock",
				posX = 0.7911279,
				posY = 0.4891406,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1205882,
				sizeY = 0.2691156,
				image = "ty#suo",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz",
				varName = "name",
				posX = 0.5021825,
				posY = 0.5000002,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6769047,
				sizeY = 0.4379887,
				text = "副本名字",
				color = "FF745226",
				fontSize = 24,
				fontOutlineEnable = true,
				fontOutlineColor = "FFF1E9D7",
				fontOutlineSize = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zs",
				posX = 0.91146,
				posY = 0.7637629,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05151515,
				sizeY = 0.2838723,
				image = "fb#zs",
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
