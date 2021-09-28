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
			sizeX = 1,
			sizeY = 1,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.5166668,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7929688,
				sizeY = 0.8055556,
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
					name = "kk2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8738916,
					sizeY = 1.058621,
					image = "fsjybj#fsjybj",
					scale9Left = 0.45,
					scale9Right = 0.45,
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "kk1",
					varName = "email_info",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9999999,
					sizeY = 0.9601052,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lb1",
						varName = "effectScroll",
						posX = 0.1478733,
						posY = 0.379844,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1081966,
						sizeY = 0.7996039,
						showScrollBar = false,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "g2",
						posX = 0.548687,
						posY = 0.4712331,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6540986,
						sizeY = 0.6453283,
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
						scale9Top = 0.4,
						scale9Bottom = 0.4,
						alpha = 0.7,
					},
					children = {
					{
						prop = {
							etype = "Sprite3D",
							name = "mx",
							varName = "model",
							posX = 0.35432,
							posY = 0.05874171,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.2863936,
							sizeY = 0.6928744,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "wb1",
							varName = "name",
							posX = 0.844915,
							posY = 0.8094869,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3425176,
							sizeY = 0.2500001,
							text = "名字",
							color = "FFFFCC00",
							fontSize = 22,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "RichText",
							name = "fwb",
							varName = "desc",
							posX = 0.844915,
							posY = 0.4145512,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3425176,
							sizeY = 0.6433278,
							text = "描述",
							color = "FFFFFE9E",
							hTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Button",
						name = "an1",
						varName = "unlockBtn",
						posX = 0.7742954,
						posY = 0.03983587,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1506494,
						sizeY = 0.1041552,
						image = "chu1#an2",
						imageNormal = "chu1#an2",
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "j1",
							varName = "unlockName",
							posX = 0.5,
							posY = 0.5363637,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9322476,
							sizeY = 1.09296,
							text = "启动",
							fontSize = 22,
							fontOutlineEnable = true,
							fontOutlineColor = "FF347468",
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
						name = "djk",
						varName = "itemBg",
						posX = 0.2699037,
						posY = 0.04641153,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.07671885,
						sizeY = 0.1398367,
						image = "djk#ktong",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "djt",
							varName = "icon",
							posX = 0.4986861,
							posY = 0.5148354,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8310277,
							sizeY = 0.8363385,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "suo",
							varName = "suo",
							posX = 0.1919069,
							posY = 0.2238214,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3191489,
							sizeY = 0.319149,
							image = "tb#suo",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "mzs",
							varName = "itemName",
							posX = 1.980367,
							posY = 0.7325698,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.733808,
							sizeY = 0.5920595,
							text = "名称",
							color = "FFFFFE9E",
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "mzs2",
							varName = "count",
							posX = 1.980367,
							posY = 0.2450315,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.733808,
							sizeY = 0.5920595,
							text = "0/1",
							color = "FFFFFE9E",
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "djan",
							varName = "itemBtn",
							posX = 0.7642046,
							posY = 0.5042249,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.383311,
							sizeY = 0.8363385,
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "close",
					posX = 0.8922844,
					posY = 0.7995591,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.05221675,
					sizeY = 0.09137931,
					image = "feisheng#gb",
					imageNormal = "feisheng#gb",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
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
	dk = {
		ysjm = {
			scale = {{0, {0.3, 0.3, 1}}, {150, {1.05, 1.05, 1}}, {200, {1,1,1}}, },
		},
	},
	c_dakai = {
		{0,"dk", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
