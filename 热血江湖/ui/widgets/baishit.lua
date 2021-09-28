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
			name = "jjpht",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.3109375,
			sizeY = 0.1513889,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "bt",
				varName = "applyBtn",
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
				name = "tdt",
				varName = "sharder",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.9999999,
				image = "b#lbt",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.6,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "tdj2",
					varName = "txtLevel",
					posX = 0.6192949,
					posY = 0.2863408,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2579708,
					sizeY = 0.6205857,
					text = "Lv.40",
					color = "FF966856",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "ttxk",
				varName = "imgCls",
				posX = 0.3809756,
				posY = 0.3056284,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1130653,
				sizeY = 0.412844,
				image = "zy#daoke",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz",
				varName = "txtName",
				posX = 0.7157338,
				posY = 0.6919193,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.757677,
				sizeY = 0.6205857,
				text = "你是一个大大草包",
				color = "FF966856",
				fontSize = 22,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "txd",
				varName = "imgHeadBgrd",
				posX = 0.1857511,
				posY = 0.4398144,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.3130056,
				sizeY = 0.9174311,
				image = "zdtx#txd.png",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tx",
					varName = "imgHeadIcon",
					posX = 0.5054789,
					posY = 0.6925332,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7210885,
					sizeY = 1.110169,
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
