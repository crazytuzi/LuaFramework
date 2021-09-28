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
			sizeX = 0.3304687,
			sizeY = 0.05555556,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt4",
				varName = "propertyBg2",
				posX = 0.5,
				posY = 0.05,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9,
				sizeY = 0.04202786,
				image = "b#xian",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z1",
				varName = "propertyName",
				posX = 0.3418349,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2882399,
				sizeY = 0.7982667,
				text = "气血:",
				color = "FF966856",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z2",
				varName = "propertyValue",
				posX = 0.6563849,
				posY = 0.5000004,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2396372,
				sizeY = 0.8510796,
				text = "123123",
				color = "FFF1E9D7",
				fontOutlineEnable = true,
				fontOutlineColor = "FFA47848",
				fontOutlineSize = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tb",
				varName = "propertyIcon",
				posX = 0.1194656,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.08274233,
				sizeY = 0.8749999,
				image = "zt#qixue",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jt",
				posX = 0.4765173,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.03309693,
				sizeY = 0.375,
				image = "chu1#jt",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sjt",
				varName = "imgflag",
				posX = 0.7903435,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.07092199,
				sizeY = 0.7499999,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z3",
				varName = "chazhi",
				posX = 0.9443082,
				posY = 0.5000004,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2396372,
				sizeY = 0.8510796,
				text = "+111",
				color = "FF966856",
				fontOutlineColor = "FF5B7838",
				fontOutlineSize = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt5",
				varName = "propertyBg1",
				posX = 0.5,
				posY = 0.05,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9,
				sizeY = 0.04202786,
				image = "b#xian",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
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
