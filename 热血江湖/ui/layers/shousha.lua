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
		closeAfterOpenAni = true,
	},
	children = {
	{
		prop = {
			etype = "Grid",
			name = "ysjm",
			posX = 0.6156301,
			posY = 0.6861146,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "mo",
				posX = 0.5234382,
				posY = 0.5083334,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.620866,
				sizeY = 0.551881,
				image = "uieffect/mo.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "shou",
				posX = 0.378325,
				posY = 0.5221954,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2,
				sizeY = 0.3555556,
				image = "uieffect/shou.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sha",
				posX = 0.4703137,
				posY = 0.4888888,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2,
				sizeY = 0.3555556,
				image = "uieffect/sha.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "yibai",
				posX = 0.6162542,
				posY = 0.513883,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2,
				sizeY = 0.3555556,
				image = "uieffect/yibai.png",
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
	shou = {
		shou = {
			scale = {{0, {8, 8, 1}}, {100, {0.7, 0.7, 1}}, {150, {1,1,1}}, },
			alpha = {{0, {1}}, {600, {1}}, {900, {0}}, },
		},
	},
	sha = {
		sha = {
			scale = {{0, {8, 8, 1}}, {100, {0.7, 0.7, 1}}, {150, {1,1,1}}, },
			alpha = {{0, {1}}, {450, {1}}, {750, {0}}, },
		},
	},
	yibai = {
		yibai = {
			move = {{0, {788.8054, 1200, 0}}, {100, {788.8054, 350, 0}}, {150, {788.8054,369.9958,0}}, },
			alpha = {{0, {0}}, {50, {1}}, {700, {1}}, {900, {0}}, },
		},
	},
	mo = {
		mo = {
			alpha = {{0, {1}}, {500, {1}}, {1000, {0}}, },
		},
	},
	c_dakai = {
		{0,"shou", 1, 0},
		{0,"sha", 1, 100},
		{0,"yibai", 1, 100},
		{0,"mo", 1, 100},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
