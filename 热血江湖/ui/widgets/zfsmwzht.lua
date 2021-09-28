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
			name = "mw",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.226971,
			sizeY = 0.1319444,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "bb3",
				varName = "quality",
				posX = 0.1959382,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3269966,
				sizeY = 1,
				image = "djk#kzi",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "b3",
					varName = "icon",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8229166,
					sizeY = 0.8125,
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "cc3",
				varName = "name",
				posX = 0.6158211,
				posY = 0.7365524,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4763305,
				sizeY = 0.4729042,
				text = "者·水密文",
				color = "FFFF7E2D",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "cc4",
				varName = "level",
				posX = 0.623005,
				posY = 0.3441382,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4757111,
				sizeY = 0.4658756,
				text = "（3级）",
				color = "FFFF7E2D",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "gxd",
				posX = 0.8776503,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1032621,
				sizeY = 0.3157896,
				image = "chu1#gxd",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dj",
					varName = "flag",
					posX = 0.5999999,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 1.266667,
					sizeY = 1.133333,
					image = "chu1#dj",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btns",
					varName = "btn",
					posX = 0.8178713,
					posY = 0.518774,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 2.234143,
					sizeY = 1.967733,
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
	gy = {
	},
	gy2 = {
	},
	gy3 = {
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
	gy43 = {
	},
	gy44 = {
	},
	gy45 = {
	},
	gy46 = {
	},
	gy47 = {
	},
	gy48 = {
	},
	gy49 = {
	},
	gy50 = {
	},
	gy51 = {
	},
	gy52 = {
	},
	gy53 = {
	},
	gy54 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
