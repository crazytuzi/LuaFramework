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
			name = "k1",
			varName = "killPanel",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			layoutType = 9,
			layoutTypeW = 9,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "bao",
				posX = 0.8502054,
				posY = 0.8383282,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1,
				sizeY = 0.1777778,
				image = "uieffect/SoundWave.png",
				alpha = 0,
				blendFunc = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "md",
				posX = 0.8697048,
				posY = 0.8286265,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1710937,
				sizeY = 0.1277778,
				image = "kill#modi",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sz1",
				varName = "num1",
				posX = 0.820567,
				posY = 0.8355593,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05390625,
				sizeY = 0.1236111,
				image = "kill#8",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sz2",
				varName = "num2",
				posX = 0.8498073,
				posY = 0.8411149,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05390625,
				sizeY = 0.1236111,
				image = "kill#8",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sz3",
				varName = "num3",
				posX = 0.8790476,
				posY = 0.8480594,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05390625,
				sizeY = 0.1236111,
				image = "kill#8",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "ki",
				posX = 0.9282023,
				posY = 0.8258527,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.04453125,
				sizeY = 0.05138889,
				image = "kill#kill",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "ki2",
				posX = 0.9282023,
				posY = 0.8258527,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.04453125,
				sizeY = 0.05138889,
				image = "kill#kill",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sz4",
				varName = "num4",
				posX = 0.8322672,
				posY = 0.8383331,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05390625,
				sizeY = 0.1236111,
				image = "kill#8",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sz5",
				varName = "num5",
				posX = 0.8689078,
				posY = 0.8425133,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05390625,
				sizeY = 0.1236111,
				image = "kill#8",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "combo",
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
					name = "kuang",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2,
					sizeY = 0.3555556,
					image = "uieffect/RingGlowWhite411.png",
					alpha = 0,
					blendFunc = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "shuzi",
					posX = 0.4992199,
					posY = 0.530505,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1,
					sizeY = 0.1777778,
					image = "uieffect/1.png",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "shuzi2",
					posX = 0.4992199,
					posY = 0.530505,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1,
					sizeY = 0.1777778,
					image = "uieffect/1.png",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "yingwen",
					posX = 0.4991385,
					posY = 0.4298292,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1592761,
					sizeY = 0.1375672,
					image = "uieffect/BOSS.png",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "yingwen2",
					posX = 0.4991385,
					posY = 0.4298292,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1592761,
					sizeY = 0.1375672,
					image = "uieffect/BOSS.png",
					alpha = 0,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "lszg",
				posX = 0.810427,
				posY = 0.7440441,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1601563,
				sizeY = 0.07916667,
				image = "kill#lsxg",
				alpha = 0,
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
	mid = {
		md = {
			scale = {{0, {0.3, 0.3, 1}}, {50, {1.2, 1.2, 1}}, {150, {1,1,1}}, },
			alpha = {{0, {1}}, },
		},
	},
	sz2 = {
		sz2 = {
			scale = {{0, {2.5, 2.5, 1}}, {100, {0.7, 0.7, 1}}, {150, {1,1,1}}, },
			alpha = {{0, {1}}, },
		},
	},
	ki2 = {
		ki2 = {
			scale = {{0, {1.5, 1.5, 1}}, {400, {2, 2, 1}}, },
			alpha = {{0, {1}}, {400, {0}}, },
		},
	},
	bao = {
		bao = {
			scale = {{0, {1,1,1}}, {100, {2.5, 2, 1}}, },
			alpha = {{0, {1}}, {100, {1}}, {150, {0}}, },
		},
	},
	sz1 = {
		sz1 = {
			scale = {{0, {2.5, 2.5, 1}}, {100, {0.7, 0.7, 1}}, {150, {1,1,1}}, },
			alpha = {{0, {1}}, },
		},
	},
	sz3 = {
		sz3 = {
			scale = {{0, {2.5, 2.5, 1}}, {100, {0.7, 0.7, 1}}, {150, {1,1,1}}, },
			alpha = {{0, {1}}, },
		},
	},
	ki = {
		ki = {
			alpha = {{0, {1}}, },
		},
	},
	sz4 = {
		sz4 = {
			scale = {{0, {2.5, 2.5, 1}}, {100, {0.7, 0.7, 1}}, {150, {1,1,1}}, },
			alpha = {{0, {1}}, },
		},
	},
	sz5 = {
		sz5 = {
			scale = {{0, {2.5, 2.5, 1}}, {100, {0.7, 0.7, 1}}, {150, {1,1,1}}, },
			alpha = {{0, {1}}, },
		},
	},
	zg = {
		lszg = {
			alpha = {{0, {0}}, {1000, {1}}, {4000, {1}}, {4500, {0}}, },
		},
	},
	c_combo = {
		{0,"mid", 1, 50},
		{0,"bao", 1, 0},
		{0,"ki", 1, 0},
		{0,"ki2", 1, 50},
		{0,"sz2", 1, 0},
	},
	c_combo2 = {
		{0,"mid", 1, 50},
		{0,"bao", 1, 0},
		{0,"ki", 1, 0},
		{0,"ki2", 1, 50},
		{0,"sz4", 1, 0},
		{0,"sz5", 1, 0},
	},
	c_combo3 = {
		{0,"mid", 1, 50},
		{0,"ki2", 1, 50},
		{0,"sz2", 1, 0},
		{0,"bao", 1, 0},
		{0,"sz1", 1, 0},
		{0,"sz3", 1, 0},
		{0,"ki", 1, 0},
	},
	c_zg = {
		{0,"zg", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
