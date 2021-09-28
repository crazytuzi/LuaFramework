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
			name = "k2",
			posX = 0.4999999,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.225,
			sizeY = 0.1505783,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "jt",
				varName = "currentEmail",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5578151,
				sizeY = 0.5898261,
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dd1",
				varName = "state",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.013889,
				sizeY = 0.9869357,
				image = "yj#yj1",
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "djk1",
				varName = "iconSlot",
				posX = 0.1786543,
				posY = 0.4925237,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.3263889,
				sizeY = 0.8670276,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt1",
					varName = "emailIcon",
					posX = 0.5,
					posY = 0.5105124,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.712766,
					sizeY = 0.7021277,
					image = "yj#xin1",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "sm1",
				varName = "sendTime",
				posX = 0.6555353,
				posY = 0.2667608,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6165432,
				sizeY = 0.4538373,
				text = "2015-06-30",
				color = "FFAE6C4B",
				fontSize = 16,
				fontOutlineColor = "FF0E2E2D",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "sm2",
				varName = "mailTitle",
				posX = 0.6555354,
				posY = 0.7134128,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6165432,
				sizeY = 0.4538373,
				text = "biaoti",
				color = "FF966856",
				fontSize = 22,
				fontOutlineColor = "FF183935",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "sm3",
				varName = "deleteTime",
				posX = 0.6555353,
				posY = 0.4772835,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6165432,
				sizeY = 0.4538373,
				text = "20小时后删除",
				color = "FFCE3E29",
				fontSize = 16,
				fontOutlineColor = "FF0E2E2D",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "fj",
				varName = "haveAnnex",
				posX = 0.8812904,
				posY = 0.3424346,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.125,
				sizeY = 0.3320532,
				image = "yj#fj",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "new",
				varName = "newImg",
				posX = 0.05807009,
				posY = 0.7648121,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1215278,
				sizeY = 0.4611849,
				image = "yj#new",
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
