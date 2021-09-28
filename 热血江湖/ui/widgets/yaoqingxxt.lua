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
			name = "jd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.4804688,
			sizeY = 0.1067695,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "ab",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "yaoqing#lb",
				scale9 = true,
				scale9Left = 0.25,
				scale9Right = 0.7,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "ac",
				varName = "bg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 1,
				sizeY = 1,
				image = "yaoqing#lb2",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "aa",
				varName = "desc",
				posX = 0.3683826,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6612929,
				sizeY = 0.9836779,
				text = "说你那个",
				color = "FF966856",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "ty",
				varName = "yesBtn",
				posX = 0.7644917,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1350482,
				sizeY = 0.5463483,
				image = "yaoqing#ty",
				imageNormal = "yaoqing#ty",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "ty1",
					varName = "yesTxt",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6813043,
					sizeY = 0.8529949,
					text = "同意",
					color = "FF966856",
					fontSize = 22,
					fontOutlineColor = "FF2A6953",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "jj",
				varName = "noBtn",
				posX = 0.9098971,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1350482,
				sizeY = 0.5463483,
				image = "yaoqing#qx",
				imageNormal = "yaoqing#qx",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "jj1",
					varName = "noTxt",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6813043,
					sizeY = 0.8529949,
					text = "拒绝",
					color = "FF966856",
					fontSize = 22,
					fontOutlineColor = "FFB35F1D",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
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
	zdbd = {
		bd3 = {
			scale = {{0, {1,1,1}}, {100, {3, 3, 1}}, },
			alpha = {{0, {1}}, {50, {1}}, {100, {0}}, },
		},
	},
	zdbk = {
		bk2 = {
			alpha = {{0, {1}}, {400, {1}}, {1000, {0}}, },
		},
		bk7 = {
			alpha = {{0, {1}}, {500, {1}}, {1000, {0}}, },
		},
	},
	zdk = {
		bk8 = {
			scale = {{0, {5, 5, 1}}, {50, {3, 3, 1}}, {100, {1,1,1}}, },
			alpha = {{0, {1}}, {150, {1}}, {200, {0}}, },
		},
	},
	zdsztx = {
		bd4 = {
			scale = {{0, {1,1,1}}, {50, {1, 0.7, 1}}, {300, {0.8, 0.4, 1}}, },
			alpha = {{0, {1}}, {150, {1}}, {500, {0}}, },
		},
		ld4 = {
			scale = {{0, {0.3, 0.3, 1}}, {150, {1.5, 1.5, 1}}, },
			alpha = {{0, {1}}, {50, {1}}, {200, {0}}, },
		},
	},
	kuang = {
		kuang = {
			alpha = {{0, {1}}, {800, {1}}, {1000, {0}}, },
		},
	},
	ss = {
		ss = {
			alpha = {{0, {1}}, {400, {0}}, },
			scale = {{0, {1, 0, 1}}, {200, {1,1,1}}, },
			move = {{0, {430.314,471.7226,0}}, {300, {430.314, 505, 0}}, },
		},
	},
	bk9 = {
		bk9 = {
			alpha = {{0, {1}}, {300, {1}}, {600, {0}}, },
		},
	},
	bao = {
		bao = {
			scale = {{0, {3, 3, 1}}, {100, {3, 3, 1}}, },
			alpha = {{0, {1}}, {100, {0}}, },
		},
	},
	bao1 = {
		bao3 = {
			scale = {{0, {3, 3, 1}}, {100, {3, 3, 1}}, },
			alpha = {{0, {0}}, {500, {0}}, },
		},
		bao4 = {
			alpha = {{0, {1}}, {100, {1}}, {800, {0}}, },
		},
	},
	bao5 = {
		bao5 = {
			scale = {{0, {1,1,1}}, {150, {10, 10, 1}}, },
			alpha = {{0, {1}}, {100, {0}}, },
		},
		bao6 = {
			scale = {{0, {3, 3, 1}}, {500, {5, 5, 1}}, },
			alpha = {{0, {1}}, {500, {0}}, },
		},
	},
	bao7 = {
		bao7 = {
			scale = {{0, {1,1,1}}, {100, {8, 8, 1}}, },
			alpha = {{0, {1}}, {100, {0}}, },
		},
	},
	bao8 = {
		bao8 = {
			scale = {{0, {1, 1, 1}}, {400, {3, 3, 1}}, },
			alpha = {{0, {1}}, {400, {0}}, },
		},
	},
	c_zdqh = {
		{0,"zdbk", 1, 0},
		{0,"bao", 1, 150},
		{0,"bao1", 1, 200},
		{0,"bao5", 1, 200},
		{0,"bao8", 1, 150},
		{2,"lizi", 1, 250},
		{2,"lizi2", 1, 250},
		{2,"lz3", 1, 200},
		{2,"lz43", 1, 150},
		{2,"lz4", 1, 200},
	},
	c_lx = {
		{2,"lizi", 1, 0},
		{2,"lizi2", 1, 0},
		{0,"kuang", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
