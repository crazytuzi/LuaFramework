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
				name = "dt",
				posX = 0.5,
				posY = 0.8008952,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3039063,
				sizeY = 0.05972222,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dd",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9999999,
					sizeY = 1,
					image = "cjmz#dt",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zs1",
					posX = 0.5,
					posY = 1.325584,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2313624,
					sizeY = 0.7674419,
					image = "cjmz#zs1",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zs2",
					posX = 0.5,
					posY = -0.2093023,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1388175,
					sizeY = 0.4651163,
					image = "cjmz#zs2",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "guang",
					posX = 0.3382366,
					posY = 0.9700786,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2133676,
					sizeY = 0.08139464,
					image = "cjmz#guang",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "guang2",
					posX = 0.3536608,
					posY = 0.02325582,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2133676,
					sizeY = 0.1627907,
					image = "cjmz#guang",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "z1",
					varName = "img1",
					posX = 0.2817895,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.09254497,
					sizeY = 0.8372094,
					image = "cjmz#di",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "z2",
					varName = "img2",
					posX = 0.3895815,
					posY = 0.4999999,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.09254497,
					sizeY = 0.8372094,
					image = "cjmz#xia3",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "z3",
					varName = "img3",
					posX = 0.4973735,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.09254497,
					sizeY = 0.8372094,
					image = "cjmz#cang",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "z4",
					varName = "img4",
					posX = 0.6051655,
					posY = 0.4999999,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.09254497,
					sizeY = 0.8372094,
					image = "cjmz#bao",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "z5",
					varName = "img5",
					posX = 0.7129575,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.09254497,
					sizeY = 0.8372094,
					image = "cjmz#ku",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "guang4",
					posX = 0.3536608,
					posY = 0.02325582,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2596401,
					sizeY = 0.3720931,
					image = "uieffect/guang01.png",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "guang3",
					posX = 0.3382366,
					posY = 0.9700786,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2596401,
					sizeY = 0.3720931,
					image = "uieffect/guang01.png",
					alpha = 0,
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
	dd = {
		dd = {
			scale = {{0, {1, 0, 1}}, {200, {1,1,1}}, },
			alpha = {{0, {1}}, {3000, {1}}, {3500, {0}}, },
		},
	},
	zs1 = {
		zs1 = {
			move = {{0, {194.5, 43, 0}}, {100, {194.5, 35, 0}}, {150, {194.5, 35, 0}}, {300, {194.5,57.00011,0}}, },
			alpha = {{0, {1}}, {3000, {1}}, {3500, {0}}, },
		},
	},
	zs2 = {
		zs2 = {
			move = {{0, {194.5, -1, 0}}, {100, {194.5, 7, 0}}, {150, {194.5, 7, 0}}, {300, {194.5,-8.999998,0}}, },
			alpha = {{0, {1}}, {3000, {1}}, {3500, {0}}, },
		},
	},
	guang = {
		guang = {
			alpha = {{0, {1}}, {800, {1}}, {1000, {0}}, },
			move = {{0, {125, 41.71338, 0}}, {1000, {265, 41.71338, 0}}, },
		},
	},
	guang2 = {
		guang2 = {
			alpha = {{0, {1}}, {800, {1}}, {1000, {0}}, },
			move = {{0, {125, 1, 0}}, {1000, {265, 1, 0}}, },
		},
	},
	zi = {
		z1 = {
			scale = {{0, {1, 1, 1}}, {100, {1.2, 1.2, 1}}, {200, {1,1,1}}, },
			alpha = {{0, {0}}, {100, {1}}, {2700, {1}}, {3200, {0}}, },
		},
	},
	z2 = {
		z2 = {
			scale = {{0, {1, 1, 1}}, {100, {1.2, 1.2, 1}}, {200, {1,1,1}}, },
			alpha = {{0, {0}}, {100, {1}}, {2550, {1}}, {3050, {0}}, },
		},
	},
	z3 = {
		z3 = {
			scale = {{0, {1, 1, 1}}, {100, {1.2, 1.2, 1}}, {200, {1,1,1}}, },
			alpha = {{0, {0}}, {100, {1}}, {2400, {1}}, {2900, {0}}, },
		},
	},
	z4 = {
		z4 = {
			scale = {{0, {1, 1, 1}}, {100, {1.2, 1.2, 1}}, {200, {1,1,1}}, },
			alpha = {{0, {0}}, {100, {1}}, {2250, {1}}, {2750, {0}}, },
		},
	},
	z5 = {
		z5 = {
			scale = {{0, {1, 1, 1}}, {100, {1.2, 1.2, 1}}, {200, {1,1,1}}, },
			alpha = {{0, {0}}, {100, {1}}, {2100, {1}}, {2600, {0}}, },
		},
	},
	guang3 = {
		guang3 = {
			alpha = {{0, {1}}, {800, {1}}, {1000, {0}}, },
			move = {{0, {125, 41.71338, 0}}, {1000, {265, 41.71338, 0}}, },
		},
	},
	guang4 = {
		guang4 = {
			alpha = {{0, {1}}, {800, {1}}, {1000, {0}}, },
			move = {{0, {125, 1, 0}}, {1000, {265, 1, 0}}, },
		},
	},
	c_dakai = {
		{0,"zs1", 1, 500},
		{0,"zs2", 1, 500},
		{0,"dd", 1, 650},
		{0,"guang", 1, 800},
		{0,"guang2", 1, 800},
		{0,"zi", 1, 900},
		{0,"z2", 1, 1050},
		{0,"z3", 1, 1200},
		{0,"z4", 1, 1350},
		{0,"z5", 1, 1500},
		{0,"guang3", 1, 800},
		{0,"guang4", 1, 800},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
