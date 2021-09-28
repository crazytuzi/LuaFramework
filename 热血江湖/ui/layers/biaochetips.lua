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
				varName = "globel_bt",
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
			sizeX = 0.3793512,
			sizeY = 0.6,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "a2",
				varName = "sale",
				posX = 0.8138596,
				posY = 0.2111064,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2285976,
				sizeY = 0.1226852,
				image = "tong#an",
				imageNormal = "tong#an",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "z2",
					varName = "label1",
					posX = 0.4999999,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.029292,
					sizeY = 0.7566044,
					text = "装备",
					color = "FFA7582D",
					fontSize = 24,
					fontOutlineColor = "FF624311",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.3621211,
				posY = 0.4942205,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7009373,
				sizeY = 0.7510809,
				scale9 = true,
				scale9Left = 0.41,
				scale9Right = 0.37,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "wk",
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
					etype = "Image",
					name = "dk1",
					posX = 0.4999999,
					posY = 0.4246166,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9073173,
					sizeY = 0.49231,
					image = "b#d2",
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
						name = "top",
						posX = 0.5,
						posY = 0.8562545,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6023144,
						sizeY = 0.2253686,
						image = "chu1#top2",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "topz",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.665309,
							sizeY = 1.012432,
							text = "皮肤效果",
							color = "FFF1E9D7",
							fontOutlineEnable = true,
							fontOutlineColor = "FFA47848",
							fontOutlineSize = 2,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Scroll",
						name = "lb",
						posX = 0.5,
						posY = 0.3687539,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9500112,
						sizeY = 0.7,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xhd",
					posX = 0.6232078,
					posY = 0.8261548,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6493244,
					sizeY = 0.2280664,
					image = "d2#xhd",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mz8",
					varName = "itemName_label",
					posX = 0.7269029,
					posY = 0.885466,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8021439,
					sizeY = 0.1254289,
					text = "名字写六七个zi",
					fontSize = 22,
					fontOutlineColor = "FF27221D",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zbd2",
					varName = "item_bg",
					posX = 0.1776286,
					posY = 0.8202282,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2791214,
					sizeY = 0.2958699,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "zbt2",
						varName = "item_icon",
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
					etype = "RichText",
					name = "mz13",
					varName = "get_label",
					posX = 0.5088143,
					posY = 0.0922845,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9139998,
					sizeY = 0.190768,
					text = "获得途径:",
					color = "FF1F822F",
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
