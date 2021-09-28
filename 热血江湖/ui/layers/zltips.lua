--version = 1
local l_fileType = "layer"

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
			name = "ysjm",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "t",
				varName = "powerpanel",
				posX = 0.5133833,
				posY = 0.2522902,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.2945312,
				sizeY = 0.07916667,
				image = "zd#zld",
				alpha = 0,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "zl",
					posX = 0.2387476,
					posY = 0.4116758,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2201592,
					sizeY = 0.9298245,
					image = "zd#zl",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jt",
					varName = "powericon",
					posX = 0.6840061,
					posY = 0.3419733,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.07957561,
					sizeY = 0.5263157,
					image = "chu1#ss",
					alpha = 0,
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z1",
				varName = "tipWord",
				posX = 0.5253806,
				posY = 0.2384012,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.08972029,
				sizeY = 0.07012361,
				text = "665577",
				color = "FFFEDB45",
				fontSize = 26,
				fontOutlineEnable = true,
				fontOutlineColor = "FF62441D",
				vTextAlign = 1,
				alpha = 0,
				layoutType = 5,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z2",
				varName = "changeWord",
				posX = 0.6057752,
				posY = 0.2384012,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0848823,
				sizeY = 0.07012361,
				text = "+105",
				color = "FFACFC43",
				fontSize = 26,
				fontOutlineEnable = true,
				fontOutlineColor = "FF62441D",
				hTextAlign = 1,
				vTextAlign = 1,
				alpha = 0,
				layoutType = 5,
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
	zl = {
		zl = {
			scale = {{0, {0.7, 0.7, 1}}, {100, {1,1,1}}, },
			alpha = {{0, {1}}, {1550, {1}}, {2050, {0}}, },
			move = {{0, {45.36147,19.58992,0}}, {1550, {45.36147,19.58992,0}}, {2050, {45.36147, 40, 0}}, },
		},
	},
	z1 = {
		z1 = {
			alpha = {{0, {1}}, {1500, {1}}, {2000, {0}}, },
			move = {{0, {638.4858,181.6489,0}}, {1500, {638.4858,181.6489,0}}, {2000, {638.4858, 258, 0}}, },
		},
	},
	jt = {
		jt = {
			scale = {{0, {0.7, 0.7, 1}}, {100, {1,1,1}}, },
			alpha = {{0, {1}}, {1500, {1}}, {2000, {0}}, },
			move = {{0, {202.2909,20.38888,0}}, {1500, {202.2909,20.38888,0}}, {2000, {202.2909, 40, 0}}, },
		},
	},
	t = {
		t = {
			scale = {{0, {1, 0, 1}}, {200, {1,1,1}}, },
			alpha = {{0, {1}}, {1500, {1}}, {2000, {0}}, },
			move = {{0, {657.1307,181.6489,0}}, {1500, {657.1307,181.6489,0}}, {2000, {657.1307, 240, 0}}, },
		},
	},
	z2 = {
		z2 = {
			alpha = {{0, {1}}, {1500, {1}}, {2000, {0}}, },
			move = {{0, {755.3934,182.649,0}}, {1500, {755.3934,182.649,0}}, {2000, {755.3934, 258, 0}}, },
		},
	},
	zll = {
		zl = {
			scale = {{0, {15, 15, 1}}, {150, {1,1,1}}, },
			alpha = {{0, {1}}, {1600, {1}}, {2100, {0}}, },
		},
	},
	z11 = {
		z1 = {
			alpha = {{0, {1}}, {1500, {1}}, {2000, {0}}, },
			scale = {{0, {1,1,1}}, {100, {1.2, 1.2, 1}}, {150, {1,1,1}}, },
		},
	},
	t1 = {
		t = {
			alpha = {{0, {1}}, {1500, {1}}, {2000, {0}}, },
			scale = {{0, {1, 0, 1}}, {100, {1,1,1}}, },
		},
	},
	jt1 = {
		jt = {
			scale = {{0, {0.7, 0.7, 1}}, {100, {1,1,1}}, },
			alpha = {{0, {1}}, {1500, {1}}, {2000, {0}}, },
		},
	},
	z22 = {
		z2 = {
			alpha = {{0, {1}}, {1500, {1}}, {2000, {0}}, },
		},
	},
	c_dakai = {
		{0,"zll", 1, 0},
		{0,"z11", 1, 100},
		{0,"t1", 1, 100},
		{0,"jt1", 1, 100},
		{0,"z22", 1, 100},
	},
	c_sds = {
		{0,"zll", 1, 0},
		{0,"z11", 1, 100},
		{0,"t1", 1, 100},
		{0,"jt1", 1, 100},
		{0,"z22", 1, 100},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
