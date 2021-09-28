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
			posX = 0.4992188,
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
				posY = 0.4791665,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7929688,
				sizeY = 0.8055556,
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "das",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4696729,
					sizeY = 0.6041788,
					image = "b#cs",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.1,
					scale9Bottom = 0.8,
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "k1",
					varName = "baseSetPanel",
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
						name = "hua",
						posX = 0.6318944,
						posY = 0.3312809,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.2547297,
						sizeY = 0.2479523,
						image = "hua1#hua1",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "d9",
						posX = 0.5014762,
						posY = 0.5731983,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4436059,
						sizeY = 0.3838511,
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
						etype = "Button",
						name = "zx2",
						varName = "editor",
						posX = 0.5,
						posY = 0.2800986,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1605911,
						sizeY = 0.1103448,
						image = "chu1#an2",
						imageNormal = "chu1#an2",
						disablePressScale = true,
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "h2",
							posX = 0.5,
							posY = 0.546875,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9086144,
							sizeY = 1.137135,
							text = "修 改",
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
				{
					prop = {
						etype = "Label",
						name = "jsmc",
						varName = "player_name",
						posX = 0.5206892,
						posY = 0.4315145,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3481977,
						sizeY = 0.08952476,
						color = "FF966856",
						fontSize = 22,
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "EditBox",
						name = "srk",
						sizeXAB = 433.288,
						sizeYAB = 159.7371,
						posXAB = 510.4954,
						posYAB = 350.9243,
						varName = "edit_box",
						posX = 0.5029511,
						posY = 0.6050419,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4268847,
						sizeY = 0.2754088,
						text = "请输入：",
						color = "FF966856",
						fontSize = 24,
						phText = "请输入：",
						phColor = "FF966856",
						phFontSize = 24,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "close_btn",
					posX = 0.7329607,
					posY = 0.7582638,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.04334975,
					sizeY = 0.1086207,
					image = "bgb#gb",
					imageNormal = "bgb#gb",
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
