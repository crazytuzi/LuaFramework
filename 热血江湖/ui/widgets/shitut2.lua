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
			sizeX = 0.6874385,
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
					posX = 0.2896039,
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
				posX = 0.1715166,
				posY = 0.2781449,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.05114094,
				sizeY = 0.4545455,
				image = "zy#daoke",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz",
				varName = "txtName",
				posX = 0.2905995,
				posY = 0.691919,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2813294,
				sizeY = 0.6205857,
				text = "你是一个大大草包",
				color = "FF966856",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "txd",
				varName = "imgHeadBgrd",
				posX = 0.1042568,
				posY = 0.4673504,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1344978,
				sizeY = 0.959596,
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
				etype = "Button",
				name = "bt1",
				varName = "btn02",
				posX = 0.8913976,
				posY = 0.60101,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1409217,
				sizeY = 0.5858586,
				image = "chu1#sn1",
				imageNormal = "chu1#sn1",
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "btz1",
					varName = "txtBtn02",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7501845,
					sizeY = 0.7795336,
					text = "私 聊",
					color = "FF914A15",
					fontSize = 22,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "bt2",
				varName = "btn01",
				posX = 0.7317362,
				posY = 0.60101,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1409217,
				sizeY = 0.5858586,
				image = "chu1#sn1",
				imageNormal = "chu1#sn1",
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "btz2",
					varName = "txtBtn01",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7501845,
					sizeY = 0.7795336,
					text = "解 除",
					color = "FF914A15",
					fontSize = 22,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "st",
				varName = "imgMsgType",
				posX = 0.03823934,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.04091275,
				sizeY = 0.7676768,
				image = "baishi#baishi",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tdj3",
				varName = "txtTime",
				posX = 0.8722326,
				posY = 0.1873378,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2312903,
				sizeY = 0.6205857,
				text = "30分钟前",
				color = "FF966856",
				fontSize = 18,
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
