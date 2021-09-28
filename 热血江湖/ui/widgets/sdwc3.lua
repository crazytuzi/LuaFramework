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
			name = "lbjd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.5,
			sizeY = 0.07,
		},
		children = {
		{
			prop = {
				etype = "Label",
				name = "wz1",
				varName = "exp_lable",
				posX = 0.2533336,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2527098,
				sizeY = 0.8319729,
				text = "55447",
				fontSize = 22,
				fontOutlineEnable = true,
				fontOutlineColor = "FF27221D",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wz2",
				varName = "coin_lable",
				posX = 0.5658291,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2589508,
				sizeY = 0.8319729,
				text = "+6642354",
				fontSize = 22,
				fontOutlineEnable = true,
				fontOutlineColor = "FF27221D",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tb1",
				varName = "exp_icon",
				posX = 0.0723277,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.07225227,
				sizeY = 0.9174892,
				image = "ty#exp",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tb2",
				posX = 0.3874347,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.07225227,
				sizeY = 0.9174892,
				image = "tb#tb_tongqian.png",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "suo",
					posX = 0.5577009,
					posY = 0.2897145,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6487685,
					sizeY = 0.6487685,
					image = "tb#tb_suo.png",
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
