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
			etype = "Image",
			name = "wpk4",
			varName = "item_bg4",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.07421875,
			sizeY = 0.1291667,
			image = "djk#ktong",
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an4",
				varName = "Btn4",
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
				name = "wp4",
				varName = "item_icon4",
				posX = 0.5,
				posY = 0.538703,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8,
				sizeY = 0.8,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sld4",
				varName = "count_bg4",
				posX = 0.5,
				posY = 0.2395833,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8526314,
				sizeY = 0.2708333,
				image = "sc#sc_sld.png",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "suo4",
				varName = "item_suo4",
				posX = 0.1852297,
				posY = 0.2296135,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3157895,
				sizeY = 0.3225806,
				image = "tb#suo",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "zz4",
				varName = "item_count4",
				posX = 0.5257913,
				posY = 0.2588165,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7744884,
				sizeY = 0.4154173,
				text = "99",
				fontOutlineEnable = true,
				hTextAlign = 2,
				vTextAlign = 1,
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
	diguang34 = {
		diguang34 = {
			rotate = {{0, {0}}, {4000, {180}}, {6000, {270}}, {8000, {0}}, },
			alpha = {{0, {1}}, },
		},
	},
	diguang31 = {
		diguang31 = {
			alpha = {{0, {1}}, },
		},
	},
	diguang33 = {
		diguang33 = {
			rotate = {{0, {0}}, {5000, {-180}}, {7500, {-270}}, {10000, {0}}, },
			alpha = {{0, {1}}, },
		},
	},
	diguang35 = {
		diguang35 = {
			rotate = {{0, {0}}, {4000, {180}}, {6000, {270}}, {8000, {0}}, },
			alpha = {{0, {1}}, },
		},
	},
	diguang32 = {
		diguang32 = {
			alpha = {{0, {1}}, },
		},
	},
	diguang36 = {
		diguang36 = {
			rotate = {{0, {0}}, {5000, {-180}}, {7500, {-270}}, {10000, {0}}, },
			alpha = {{0, {1}}, },
		},
	},
	diguang38 = {
		diguang38 = {
			rotate = {{0, {0}}, {4000, {180}}, {6000, {270}}, {8000, {0}}, },
			alpha = {{0, {1}}, },
		},
	},
	diguang37 = {
		diguang37 = {
			alpha = {{0, {1}}, },
		},
	},
	diguang39 = {
		diguang39 = {
			rotate = {{0, {0}}, {5000, {-180}}, {7500, {-270}}, {10000, {0}}, },
			alpha = {{0, {1}}, },
		},
	},
	diguang41 = {
		diguang41 = {
			rotate = {{0, {0}}, {4000, {180}}, {6000, {270}}, {8000, {0}}, },
			alpha = {{0, {1}}, },
		},
	},
	diguang40 = {
		diguang40 = {
			alpha = {{0, {1}}, },
		},
	},
	diguang42 = {
		diguang42 = {
			rotate = {{0, {0}}, {5000, {-180}}, {7500, {-270}}, {10000, {0}}, },
			alpha = {{0, {1}}, },
		},
	},
	diguang44 = {
		diguang44 = {
			rotate = {{0, {0}}, {4000, {180}}, {6000, {270}}, {8000, {0}}, },
			alpha = {{0, {1}}, },
		},
	},
	diguang43 = {
		diguang43 = {
			alpha = {{0, {1}}, },
		},
	},
	diguang45 = {
		diguang45 = {
			rotate = {{0, {0}}, {5000, {-180}}, {7500, {-270}}, {10000, {0}}, },
			alpha = {{0, {1}}, },
		},
	},
	bx11 = {
		bx11 = {
			rotate = {{0, {0}}, {50, {10}}, {100, {0}}, {150, {-10}}, {200, {0}}, {1000, {0}}, },
		},
	},
	diguang47 = {
		diguang47 = {
			rotate = {{0, {0}}, {4000, {180}}, {6000, {270}}, {8000, {0}}, },
			alpha = {{0, {1}}, },
		},
	},
	diguang46 = {
		diguang46 = {
			alpha = {{0, {1}}, },
		},
	},
	diguang48 = {
		diguang48 = {
			rotate = {{0, {0}}, {5000, {-180}}, {7500, {-270}}, {10000, {0}}, },
			alpha = {{0, {1}}, },
		},
	},
	bx10 = {
		bx10 = {
			rotate = {{0, {0}}, {50, {10}}, {100, {0}}, {150, {-10}}, {200, {0}}, {1000, {0}}, },
		},
	},
	bx9 = {
		bx9 = {
			rotate = {{0, {0}}, {50, {10}}, {100, {0}}, {150, {-10}}, {200, {0}}, {1000, {0}}, },
		},
	},
	bx8 = {
		bx8 = {
			rotate = {{0, {0}}, {50, {10}}, {100, {0}}, {150, {-10}}, {200, {0}}, {1000, {0}}, },
		},
	},
	bx7 = {
		bx7 = {
			rotate = {{0, {0}}, {50, {10}}, {100, {0}}, {150, {-10}}, {200, {0}}, {1000, {0}}, },
		},
	},
	bx6 = {
		bx6 = {
			rotate = {{0, {0}}, {50, {10}}, {100, {0}}, {150, {-10}}, {200, {0}}, {1000, {0}}, },
		},
	},
	c_bx6 = {
		{0,"diguang46", -1, 0},
		{0,"diguang47", -1, 0},
		{0,"diguang48", -1, 0},
		{0,"bx11", -1, 0},
		{2,"qianlz16", 1, 0},
	},
	c_bx5 = {
		{0,"diguang43", -1, 0},
		{0,"diguang44", -1, 0},
		{0,"diguang45", -1, 0},
		{0,"bx10", -1, 0},
		{2,"qianlz15", 1, 0},
	},
	c_bx4 = {
		{0,"diguang40", -1, 0},
		{0,"diguang41", -1, 0},
		{0,"diguang42", -1, 0},
		{0,"bx9", -1, 0},
		{2,"qianlz14", 1, 0},
	},
	c_bx3 = {
		{0,"diguang37", -1, 0},
		{0,"diguang38", -1, 0},
		{0,"diguang39", -1, 0},
		{0,"bx8", -1, 0},
		{2,"qianlz13", 1, 0},
	},
	c_bx2 = {
		{0,"diguang34", -1, 0},
		{0,"diguang35", -1, 0},
		{0,"diguang36", -1, 0},
		{0,"bx7", -1, 0},
		{2,"qianlz12", 1, 0},
	},
	c_bx = {
		{0,"diguang31", -1, 0},
		{0,"diguang32", -1, 0},
		{0,"diguang33", -1, 0},
		{0,"bx6", -1, 0},
		{2,"qianlz11", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
