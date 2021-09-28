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
			lockHV = true,
			sizeX = 0.3034195,
			sizeY = 0.06068389,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt3",
				varName = "propertyBg1",
				posX = 0.4917656,
				posY = 0.06006857,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9335307,
				sizeY = 0.0126307,
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
				varName = "value",
				posX = 0.5406138,
				posY = 0.5336335,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2882399,
				sizeY = 0.7982667,
				text = "40000",
				color = "FFF1E9D7",
				fontOutlineEnable = true,
				fontOutlineColor = "FFA47848",
				fontOutlineSize = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z2",
				varName = "addValue",
				posX = 0.7830259,
				posY = 0.533634,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2136459,
				sizeY = 0.8510796,
				text = "123123",
				color = "FF76D646",
				fontOutlineEnable = true,
				fontOutlineColor = "FF5B7838",
				fontOutlineSize = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tb",
				varName = "propImage",
				posX = 0.1194656,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.09514562,
				sizeY = 0.8457391,
				image = "zt#gongji",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jt",
				varName = "jiantou",
				posX = 0.6296641,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.02966102,
				sizeY = 0.282486,
				image = "chu1#jt",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z3",
				varName = "name",
				posX = 0.324511,
				posY = 0.5524659,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2882399,
				sizeY = 0.7982667,
				text = "气血",
				color = "FF966856",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt4",
				varName = "propertyBg2",
				posX = 0.4856682,
				posY = 0.06006791,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9213362,
				sizeY = 0.0126307,
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
	gy = {
	},
	gy3 = {
	},
	gy2 = {
	},
	gy4 = {
	},
	gy5 = {
	},
	gy6 = {
	},
	gy7 = {
	},
	gy8 = {
	},
	gy9 = {
	},
	gy10 = {
	},
	gy11 = {
	},
	gy12 = {
	},
	gy13 = {
	},
	gy14 = {
	},
	gy15 = {
	},
	gy16 = {
	},
	gy17 = {
	},
	gy18 = {
	},
	gy19 = {
	},
	gy20 = {
	},
	gy21 = {
	},
	gy22 = {
	},
	gy23 = {
	},
	gy24 = {
	},
	gy25 = {
	},
	gy26 = {
	},
	gy27 = {
	},
	gy28 = {
	},
	gy29 = {
	},
	gy30 = {
	},
	gy31 = {
	},
	gy32 = {
	},
	gy33 = {
	},
	gy34 = {
	},
	gy35 = {
	},
	gy36 = {
	},
	gy37 = {
	},
	gy38 = {
	},
	gy39 = {
	},
	gy40 = {
	},
	gy41 = {
	},
	gy42 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
