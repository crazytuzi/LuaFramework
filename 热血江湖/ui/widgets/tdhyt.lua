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
			posX = 0.5000002,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.6223677,
			sizeY = 0.1375,
		},
		children = {
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
				sizeY = 1,
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
					posX = 0.2532378,
					posY = 0.2680176,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1528637,
					sizeY = 0.6205857,
					text = "Lv.40",
					color = "FF966856",
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
				posX = 0.1401698,
				posY = 0.2781449,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.05021148,
				sizeY = 0.4040405,
				image = "zy#daoke",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tdj",
				varName = "txtOnline",
				posX = 0.3839339,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1528637,
				sizeY = 0.6205857,
				text = "线上",
				color = "FF966856",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz",
				varName = "txtName",
				posX = 0.2542334,
				posY = 0.691919,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2813294,
				sizeY = 0.6205857,
				text = "你是一大",
				color = "FF966856",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "txd",
				varName = "imgHeadBgrd",
				posX = 0.06286861,
				posY = 0.4471484,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1407411,
				sizeY = 0.9090909,
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
		{
			prop = {
				etype = "Label",
				name = "tdj3",
				varName = "txtHistoryActv",
				posX = 0.5579863,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1528637,
				sizeY = 0.6205857,
				text = "12345",
				color = "FF966856",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tdj4",
				varName = "txtHistoryPoint",
				posX = 0.7320387,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1528637,
				sizeY = 0.6205857,
				text = "66446",
				color = "FF966856",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tdj5",
				varName = "txtScore",
				posX = 0.9060911,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1528637,
				sizeY = 0.6205857,
				text = "66446",
				color = "FF966856",
				hTextAlign = 1,
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
