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
			name = "kj",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2084172,
			sizeY = 0.05555556,
		},
		children = {
		{
			prop = {
				etype = "RichText",
				name = "w1",
				varName = "desc",
				posX = 0.6949614,
				posY = 0.4999992,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7150332,
				sizeY = 1.3053,
				text = "12345",
				color = "FFD7B886",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "w2",
				varName = "title",
				posX = 0.1804344,
				posY = 0.4999992,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3442821,
				sizeY = 0.7606891,
				text = "任务一：",
				color = "FFD7B886",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an3",
				varName = "taskBtn",
				posX = 0.6744224,
				posY = 0.5249338,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6511549,
				sizeY = 0.8671829,
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
	gy55 = {
	},
	gy56 = {
	},
	c_dakai = {
	},
	c_dakai2 = {
	},
	c_dakai3 = {
	},
	c_dakai4 = {
	},
	c_dakai5 = {
	},
	c_dakai6 = {
	},
	c_dakai7 = {
	},
	c_dakai8 = {
	},
	c_dakai9 = {
	},
	c_dakai10 = {
	},
	c_dakai11 = {
	},
	c_dakai12 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
