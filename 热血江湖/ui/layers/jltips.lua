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
				sizeY = 0.4857416,
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
					etype = "Grid",
					name = "tp3",
					posX = 0.259058,
					posY = 0.5059067,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6474815,
					sizeY = 0.2982801,
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
						sizeX = 0.7256047,
						sizeY = 2.67491,
						image = "b#db5",
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
							name = "dw1",
							posX = 0.5053977,
							posY = 0.5726596,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.5051318,
							sizeY = 0.4622943,
							image = "jlsq#dw1",
						},
					},
					{
						prop = {
							etype = "Scroll",
							name = "lb",
							varName = "OriginalLab",
							posX = 0.5,
							posY = 0.5749499,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9174265,
							sizeY = 0.4651156,
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "tpz5",
						varName = "name1",
						posX = 0.5,
						posY = 1.557708,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6438599,
						sizeY = 0.3855708,
						text = "原属性",
						color = "FFA05C21",
						fontSize = 24,
						fontOutlineColor = "FF00152E",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "a2",
						varName = "loseBtn",
						posX = 0.5,
						posY = -0.3741608,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.4425783,
						sizeY = 0.5751607,
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
							posX = 0.4931551,
							posY = 0.5469565,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8313926,
							sizeY = 0.9422306,
							text = "放 弃",
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
			{
				prop = {
					etype = "Grid",
					name = "tp4",
					posX = 0.740942,
					posY = 0.5059067,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6474815,
					sizeY = 0.2982801,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "fg4",
						posX = 0.5,
						posY = 0.5000001,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.7256047,
						sizeY = 2.67491,
						image = "b#db5",
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
							name = "dw2",
							posX = 0.5053978,
							posY = 0.5726596,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.5051318,
							sizeY = 0.4622943,
							image = "jlsq#dw2",
						},
					},
					{
						prop = {
							etype = "Scroll",
							name = "lb2",
							varName = "NewLab",
							posX = 0.5,
							posY = 0.5749499,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9174265,
							sizeY = 0.4651156,
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "tpz7",
						varName = "name2",
						posX = 0.5,
						posY = 1.557708,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6438599,
						sizeY = 0.3855708,
						text = "新属性",
						color = "FFA05C21",
						fontSize = 24,
						fontOutlineColor = "FF00152E",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "a3",
						varName = "saveBtn",
						posX = 0.5,
						posY = -0.3741607,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.4425783,
						sizeY = 0.5751607,
						image = "chu1#an1",
						imageNormal = "chu1#an1",
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "wz3",
							varName = "ok_word2",
							posX = 0.5,
							posY = 0.5469564,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8313926,
							sizeY = 0.9422306,
							text = "保 存",
							fontSize = 24,
							fontOutlineEnable = true,
							fontOutlineColor = "FFB35F1D",
							fontOutlineSize = 2,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hua",
					posX = 0.6374477,
					posY = 0.3805093,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9021739,
					sizeY = 0.7367021,
					image = "hua1#hua1",
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
