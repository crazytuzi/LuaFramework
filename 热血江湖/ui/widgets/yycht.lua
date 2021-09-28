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
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.3375,
			sizeY = 0.2222222,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "db",
				posX = 0.5,
				posY = 0.6187955,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5833334,
				sizeY = 0.7250001,
				image = "chlq#dt",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "ch",
				varName = "titleImg",
				posX = 0.5,
				posY = 0.532162,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.185185,
				sizeY = 0.8000001,
				image = "ch/biyishuangfei",
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "tj",
				varName = "conditionTxt",
				posX = 0.5,
				posY = 0.8965433,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9224573,
				sizeY = 0.3350777,
				text = "结婚x天后可领取",
				color = "FFFFE7C7",
				fontSize = 18,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "plcs2",
				varName = "getBtn",
				posX = 0.5,
				posY = 0.1576909,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2870046,
				sizeY = 0.28125,
				image = "chu1#sn1",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				imageNormal = "chu1#sn1",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "ys4",
					varName = "getLabel",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9120977,
					sizeY = 1.156784,
					text = "领 取",
					color = "FF966856",
					fontSize = 22,
					fontOutlineColor = "FF966856",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "fdz",
				varName = "getImg",
				posX = 0.5,
				posY = 0.1539047,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1898148,
				sizeY = 0.25,
				image = "chlq#yyy",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "fdz2",
				varName = "striveImg",
				posX = 0.5,
				posY = 0.1539047,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.1898148,
				sizeY = 0.25,
				image = "chlq#fdz",
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
	gy = {
	},
	gy3 = {
	},
	gy2 = {
	},
	gy4 = {
	},
	gy5 = {
	},
	gy6 = {
	},
	gy7 = {
	},
	gy8 = {
	},
	gy9 = {
	},
	gy10 = {
	},
	gy11 = {
	},
	gy12 = {
	},
	gy13 = {
	},
	gy14 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
