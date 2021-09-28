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
			posY = 0.5618064,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.4181303,
			sizeY = 0.1388889,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "xz",
				varName = "selectBtn",
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
				name = "db",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "b#lbt",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.6,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dk",
				varName = "bg",
				posX = 0.09148668,
				posY = 0.4890266,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1588171,
				sizeY = 0.85,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt",
					varName = "icon",
					posX = 0.5047552,
					posY = 0.5174118,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8238148,
					sizeY = 0.8342174,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn",
					varName = "btn",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz",
				varName = "name",
				posX = 0.4833719,
				posY = 0.7573961,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6040543,
				sizeY = 0.4494653,
				text = "什么材料",
				color = "FF966856",
				fontSize = 22,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz2",
				varName = "count",
				posX = 0.6530489,
				posY = 0.7573961,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.376805,
				sizeY = 0.4494653,
				text = "x55",
				color = "FF65944D",
				fontSize = 22,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xzk",
				varName = "selectImg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 1.037145,
				sizeY = 1.181235,
				image = "djk#xz",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "ms",
				varName = "desc",
				posX = 0.5710446,
				posY = 0.3461368,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7793996,
				sizeY = 0.5046707,
				text = "可生产蓝色 紫色石头",
				color = "FF966856",
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
