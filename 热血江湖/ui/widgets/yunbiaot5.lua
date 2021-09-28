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
			etype = "Image",
			name = "ybnr",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1682969,
			sizeY = 0.5356871,
			image = "b#d4",
			scale9 = true,
			scale9Left = 0.45,
			scale9Right = 0.45,
			scale9Top = 0.45,
			scale9Bottom = 0.45,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "tp7",
				varName = "bg",
				posX = 0.5,
				posY = 0.8201632,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.4363568,
				sizeY = 0.2437161,
				image = "djk#kcheng",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tb7",
					varName = "icon",
					posX = 0.5,
					posY = 0.5208402,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8,
					sizeY = 0.8,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zhuozi",
				posX = 0.5000003,
				posY = 0.6213347,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9132369,
				sizeY = 0.1529707,
				image = "bpyb#zhuo3",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "bmz25",
				varName = "des",
				posX = 0.5,
				posY = 0.5043213,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.640452,
				sizeY = 0.2313567,
				text = "押镖内容",
				color = "FF7146B0",
				fontSize = 26,
				fontOutlineColor = "FF27221D",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zd",
				posX = 0.5,
				posY = 0.3401015,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.122675,
				sizeY = 0.4148359,
				image = "bpyb#d",
				scale9 = true,
				scale9Left = 0.2,
				scale9Right = 0.2,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "exp13",
				posX = 0.3022713,
				posY = 0.3906133,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2321047,
				sizeY = 0.1270435,
				image = "ty#exp",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "bmz26",
					varName = "exp",
					posX = 2.142314,
					posY = 0.5087143,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.893828,
					sizeY = 1.234668,
					text = "x5000",
					color = "FF8C573A",
					fontOutlineColor = "FF27221D",
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "exp14",
				posX = 0.3022713,
				posY = 0.308491,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2321047,
				sizeY = 0.1270435,
				image = "tb#tongqian",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "bmz27",
					varName = "money",
					posX = 2.142314,
					posY = 0.5087137,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.893828,
					sizeY = 1.234668,
					text = "x5000",
					color = "FF8C573A",
					fontOutlineColor = "FF27221D",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo7",
					posX = 0.6998047,
					posY = 0.3403279,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					lockHV = true,
					sizeX = 0.5,
					sizeY = 0.499841,
					image = "tb#suo",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "bt11",
				varName = "go",
				posX = 0.5,
				posY = 0.1184759,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.8077243,
				sizeY = 0.165,
				image = "chu1#an2",
				imageNormal = "chu1#an2",
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "btz14",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9994108,
					sizeY = 0.9126199,
					text = "前 往",
					fontSize = 24,
					fontOutlineEnable = true,
					fontOutlineColor = "FF2A6953",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
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
