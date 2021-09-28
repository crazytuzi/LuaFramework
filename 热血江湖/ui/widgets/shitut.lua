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
				posX = 0.1351486,
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
				name = "tdj",
				varName = "txtPower",
				posX = 0.3904221,
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
				name = "mz",
				varName = "txtName",
				posX = 0.2542334,
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
				posX = 0.06788978,
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
				etype = "Label",
				name = "tdj3",
				varName = "txtOnline",
				posX = 0.5282826,
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
				name = "tdj4",
				varName = "txtPoint",
				posX = 0.6661432,
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
				etype = "Button",
				name = "bt1",
				varName = "btnChat",
				posX = 0.9243561,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1239078,
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
				varName = "btnDismiss",
				posX = 0.7919707,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1239078,
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
					varName = "txtDismiss",
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
				varName = "imgMorA",
				posX = 0.02119233,
				posY = 0.7117806,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.03977628,
				sizeY = 0.5050505,
				image = "baishi#s",
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
