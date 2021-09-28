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
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.43125,
				sizeY = 0.4791667,
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
					sizeX = 1.02,
					sizeY = 1.03,
					image = "b#cs",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.2,
					scale9Bottom = 0.7,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "das",
						posX = 0.5,
						posY = 0.4457868,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9013953,
						sizeY = 0.4112581,
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
							etype = "RichText",
							name = "msz",
							varName = "desc",
							posX = 0.5238528,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8542333,
							sizeY = 0.8676124,
							text = "描述这里",
							color = "FF634624",
							fontSize = 22,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "hua",
						posX = 0.6134822,
						posY = 0.4016669,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8844842,
						sizeY = 0.7795132,
						image = "hua1#hua1",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a1",
					varName = "close_btn",
					posX = 0.9760062,
					posY = 0.9204842,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1213768,
					sizeY = 0.2202899,
					image = "chu1#gb",
					imageNormal = "chu1#gb",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a2",
					varName = "ok",
					posX = 0.5,
					posY = 0.1156271,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3152174,
					sizeY = 0.1913043,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wz2",
						varName = "ok_word",
						posX = 0.5,
						posY = 0.5454545,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8313926,
						sizeY = 0.9422306,
						text = "重 修",
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
					etype = "Grid",
					name = "tp3",
					posX = 0.5,
					posY = 0.821743,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.557971,
					sizeY = 0.2608696,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "fg3",
						posX = 0.5,
						posY = 0.5000001,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.042897,
						sizeY = 0.8666666,
						image = "sui#mr",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "tpk3",
						posX = 0.2084004,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.2750809,
						sizeY = 0.9245611,
						image = "djk#ktong",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "tpt3",
							varName = "icon",
							posX = 0.5058762,
							posY = 0.5213982,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8117532,
							sizeY = 0.8390664,
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "tpz5",
						varName = "name",
						posX = 0.662571,
						posY = 0.6794178,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.598536,
						sizeY = 0.5180486,
						text = "伤害加深",
						color = "FF966856",
						fontSize = 24,
						fontOutlineColor = "FF00152E",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "tpz6",
						varName = "level",
						posX = 0.6552696,
						posY = 0.3616177,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5839333,
						sizeY = 0.4553001,
						text = "Lv.5",
						color = "FF65944D",
						fontOutlineColor = "FF00152E",
						vTextAlign = 1,
					},
				},
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
			scale = {{0, {0, 0, 1}}, {150, {1.1, 1.1, 1}}, {200, {1,1,1}}, },
		},
	},
	gy = {
	},
	gy2 = {
	},
	gy3 = {
	},
	gy4 = {
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
