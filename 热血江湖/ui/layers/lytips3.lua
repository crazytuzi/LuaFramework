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
				varName = "globel_btn",
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
			etype = "Grid",
			name = "ysjm",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.65,
			sizeY = 0.9,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.6437403,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4139127,
				sizeY = 0.7603754,
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "zz3",
					posX = 0.4906718,
					posY = 0.05484083,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9475744,
					sizeY = 0.1076535,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "zz1",
					posX = 0.5013652,
					posY = 0.851371,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9798784,
					sizeY = 0.3048587,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "wk1",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.03,
					sizeY = 1.03,
					image = "b#db5",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mz1",
					varName = "equip_name",
					posX = 0.7291394,
					posY = 0.9264205,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.802144,
					sizeY = 0.09107108,
					text = "魂玉",
					color = "FF966856",
					fontSize = 22,
					fontOutlineColor = "FF27221D",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zbd1",
					varName = "equip_bg",
					posX = 0.1665938,
					posY = 0.8661461,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.272958,
					sizeY = 0.1907765,
					image = "djk#kzi",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "zbt1",
						varName = "equip_icon",
						posX = 0.4894737,
						posY = 0.5416668,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.8241493,
						sizeY = 0.8155648,
						image = "ls#ls_jinggangtoukui.png",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zld1",
					posX = 0.7085671,
					posY = 0.834066,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8072587,
					sizeY = 0.06494518,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "zl2",
						varName = "power_value",
						posX = 0.5495934,
						posY = 0.4502198,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6562645,
						sizeY = 1.177395,
						text = "123456",
						color = "FFFFD97F",
						fontOutlineEnable = true,
						fontOutlineColor = "FF895F30",
						fontOutlineSize = 2,
						vTextAlign = 1,
						colorTL = "FFF3EE30",
						colorTR = "FFF3EE30",
						colorBR = "FFE77676",
						colorBL = "FFE77676",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zhan",
						posX = 0.09778165,
						posY = 0.4687939,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1258993,
						sizeY = 1,
						image = "tong#zl",
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mz2",
					varName = "level_label",
					posX = 0.7460091,
					posY = 0.9264205,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2058296,
					sizeY = 0.09590948,
					color = "FF65944D",
					fontSize = 22,
					fontOutlineColor = "FF400000",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dk1",
					posX = 0.5,
					posY = 0.4441924,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9350918,
					sizeY = 0.6384301,
					image = "b#d2",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb",
					varName = "scroll",
					posX = 0.498372,
					posY = 0.4422528,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.95,
					sizeY = 0.6260967,
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "mz6",
					varName = "get_label",
					posX = 0.5134292,
					posY = 0.06298557,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8730637,
					sizeY = 0.1243313,
					text = "40级开启",
					color = "FF65944D",
					fontOutlineColor = "FF400000",
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
