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
			name = "pifu",
			varName = "root",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1976456,
			sizeY = 0.1708333,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "db",
				varName = "back",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9881955,
				sizeY = 0.9430896,
				image = "b#scd1",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "btn",
				varName = "btn",
				posX = 0.5,
				posY = 0.5007493,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8152581,
				sizeY = 0.9707577,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "djt",
				varName = "icon",
				posX = 0.5029572,
				posY = 0.5224476,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9842427,
				sizeY = 0.9918701,
				image = "biaoche#ma1",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "djk",
				varName = "nameBg",
				posX = 0.4999951,
				posY = 0.3149536,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.960526,
				sizeY = 0.4715448,
				image = "biaoche#z1",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz",
				varName = "name",
				posX = 0.4957405,
				posY = 0.1909148,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8431898,
				sizeY = 0.3179136,
				text = "皮肤名字",
				color = "FF966856",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "syz",
				varName = "isUse",
				posX = 0.9136671,
				posY = 0.6664433,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.136506,
				sizeY = 0.585366,
				image = "biaoche#syz",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "hd",
				varName = "red",
				posX = 0.9340984,
				posY = 0.8409057,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.1067251,
				sizeY = 0.2276423,
				image = "zdte#hd",
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
