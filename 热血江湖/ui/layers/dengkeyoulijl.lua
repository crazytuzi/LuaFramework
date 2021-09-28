--version = 1
local l_fileType = "layer"

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
		soundEffectOpen = "audio/rxjh/UI/ui_jiangli2.ogg",
	},
	children = {
	{
		prop = {
			etype = "Image",
			name = "ddd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			image = "b#dd",
			scale9 = true,
			scale9Left = 0.2,
			scale9Right = 0.2,
			scale9Top = 0.2,
			scale9Bottom = 0.2,
			alpha = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dd",
				varName = "ok",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "ysjm",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dg",
				posX = 0.5,
				posY = 0.6511362,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1867188,
				sizeY = 0.3319444,
				image = "top#dg2",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "jd",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7800573,
				sizeY = 0.3551357,
				alpha = 0,
				alphaCascade = true,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dt",
					varName = "dt",
					posX = 0.5060092,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6519954,
					sizeY = 1.243656,
					image = "dkylbj2#dkylbj2",
					scale9 = true,
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
					alphaCascade = true,
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb",
					varName = "scroll",
					posX = 0.5,
					posY = 0.3228935,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5132856,
					sizeY = 0.2346521,
					horizontal = true,
					showScrollBar = false,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wb1",
					posX = 0.1880386,
					posY = 0.8278995,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.25,
					text = "卜中",
					color = "FF42C7FF",
					fontSize = 22,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wb2",
					varName = "diceDesc",
					posX = 0.7469741,
					posY = 0.8278995,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4699467,
					sizeY = 0.25,
					text = "巨人",
					color = "FFFFDE42",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb2",
					varName = "diceScroll",
					posX = 0.5,
					posY = 0.6669779,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3505351,
					sizeY = 0.1955434,
					horizontal = true,
					showScrollBar = false,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wb3",
					posX = 0.5000002,
					posY = 0.4915628,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.25,
					text = "奖 励",
					color = "FF382E5F",
					fontOutlineColor = "FFA47848",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xian",
					posX = 0.34,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2204042,
					sizeY = 0.003910868,
					image = "dkyl#xian",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xian2",
					posX = 0.66,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2204042,
					sizeY = 0.003910868,
					image = "dkyl#xian",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dg2",
				posX = 0.5,
				posY = 0.735859,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2820312,
				sizeY = 0.1208333,
				image = "dkyl#jlz",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sz1",
				posX = 0.3705504,
				posY = 0.280831,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0890625,
				sizeY = 0.0125,
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sz2",
				posX = 0.6302946,
				posY = 0.280831,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0890625,
				sizeY = 0.0125,
				alpha = 0,
				flippedX = true,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "xs",
				posX = 0.5,
				posY = 0.2805863,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3881353,
				sizeY = 0.08617477,
				fontSize = 22,
				fontOutlineEnable = true,
				fontOutlineColor = "FF27221D",
				hTextAlign = 1,
				vTextAlign = 1,
				alpha = 0,
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
	zi = {
		dg2 = {
			move = {{0, {640, 1100, 0}}, {300, {640, 500, 0}}, {350, {640, 515, 0}}, {400, {640, 500, 0}}, },
			alpha = {{0, {1}}, },
		},
	},
	guang = {
		dg = {
			rotate = {{0, {0}}, {3000, {180}}, },
			alpha = {{0, {1}}, },
		},
	},
	dg2 = {
		sz1 = {
			alpha = {{0, {0}}, {300, {1}}, },
		},
		sz2 = {
			alpha = {{0, {0}}, {300, {1}}, },
		},
		xs = {
			alpha = {{0, {0}}, {300, {1}}, },
		},
	},
	dk2 = {
		jd = {
			scale = {{0, {0, 0, 1}}, {150, {1.1, 1.1, 1}}, {200, {1,1,1}}, },
			alpha = {{0, {1}}, },
		},
	},
	c_dakai = {
		{0,"zi", 1, 0},
		{0,"guang", -1, 300},
		{0,"dg2", 1, 200},
		{0,"dk2", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
