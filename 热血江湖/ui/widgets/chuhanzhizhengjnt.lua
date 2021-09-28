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
			name = "jie",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1953125,
			sizeY = 0.4694445,
		},
		children = {
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
				image = "b#zbd",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dw",
					posX = 0.5,
					posY = 0.6229251,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.038291,
					sizeY = 0.1912981,
					image = "sblz#dw",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "sblz",
					posX = 0.5,
					posY = 0.02735499,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.52,
					sizeY = 0.7337277,
					image = "sblz#fgx",
					rotation = 270,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "txd",
				posX = 0.5,
				posY = 0.8106468,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.5567012,
				sizeY = 0.3365843,
				image = "zdtx#txd",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tx",
					varName = "icon",
					posX = 0.491365,
					posY = 0.6721144,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.6896486,
					sizeY = 1.061765,
					image = "jstx2#daonan",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mc",
				varName = "name",
				posX = 0.5,
				posY = 0.6216746,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6274852,
				sizeY = 0.306497,
				text = "兵种名称",
				color = "FF81453B",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mc2",
				varName = "desc",
				posX = 0.4999998,
				posY = 0.3892345,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8660719,
				sizeY = 0.3160467,
				text = "兵种介绍",
				color = "FFAE824B",
				fontSize = 18,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jnd",
				posX = 0.1508984,
				posY = 0.1193622,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.22,
				sizeY = 0.1627219,
				image = "zdjn#bai",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "jnt",
					varName = "skillIcon",
					posX = 0.5020061,
					posY = 0.4988365,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.803563,
					sizeY = 0.8123809,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "jnan",
					varName = "skillBtn",
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
				etype = "Image",
				name = "jnd2",
				posX = 0.3851085,
				posY = 0.1193622,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.22,
				sizeY = 0.1627219,
				image = "zdjn#bai",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "jnt2",
					varName = "skillIcon1",
					posX = 0.5020061,
					posY = 0.4988365,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.803563,
					sizeY = 0.8123809,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "jnan2",
					varName = "skillBtn1",
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
				etype = "Image",
				name = "jnd3",
				posX = 0.6193186,
				posY = 0.1193622,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.22,
				sizeY = 0.1627219,
				image = "zdjn#bai",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "jnt3",
					varName = "skillIcon2",
					posX = 0.5020061,
					posY = 0.4988365,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.803563,
					sizeY = 0.8123809,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "jnan3",
					varName = "skillBtn2",
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
				etype = "Image",
				name = "jnd4",
				posX = 0.8535287,
				posY = 0.1193622,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.22,
				sizeY = 0.1627219,
				image = "zdjn#bai",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "jnt4",
					varName = "skillIcon3",
					posX = 0.5020061,
					posY = 0.4988365,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.803563,
					sizeY = 0.8123809,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "jnan4",
					varName = "skillBtn3",
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
