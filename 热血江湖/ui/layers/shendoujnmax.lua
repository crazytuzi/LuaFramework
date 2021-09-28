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
				sizeX = 0.3574807,
				sizeY = 0.7978032,
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
					sizeY = 0.7788729,
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
						name = "cdd",
						posX = 0.5085531,
						posY = 0.4126309,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9043958,
						sizeY = 0.4023464,
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
							name = "top5",
							posX = 0.5,
							posY = 0.9941308,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.4406478,
							sizeY = 0.1999896,
							image = "chu1#top2",
							scale9 = true,
							scale9Left = 0.4,
							scale9Right = 0.4,
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "taz5",
								posX = 0.5,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.7293959,
								sizeY = 1.718751,
								text = "技能效果",
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
							etype = "RichText",
							name = "wb2",
							varName = "desc",
							posX = 0.4999999,
							posY = 0.4470694,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8581811,
							sizeY = 0.8285623,
							color = "FF966856",
						},
					},
					},
				},
				{
					prop = {
						etype = "Button",
						name = "tsf",
						varName = "help",
						posX = 0.9141746,
						posY = 0.2578663,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.07539975,
						sizeY = 0.07367551,
						image = "tong#tsf",
						imageNormal = "tong#tsf",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "djd",
					varName = "item_bg",
					posX = 0.1854128,
					posY = 0.7466989,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1857618,
					sizeY = 0.1479758,
					image = "shendou#jnk",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "djt",
						varName = "icon",
						posX = 0.4882353,
						posY = 0.5117647,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.8823528,
						sizeY = 0.8823528,
						image = "qiling#huo",
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z1",
					varName = "name",
					posX = 0.6822948,
					posY = 0.7444056,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6189634,
					sizeY = 0.1250911,
					text = "道具名字一二三",
					color = "FF966856",
					fontSize = 24,
					fontOutlineColor = "FF27221D",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a2",
					varName = "close",
					posX = 0.5,
					posY = 0.197936,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3456958,
					sizeY = 0.1044535,
					image = "chu1#an1",
					imageNormal = "chu1#an1",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wz2",
						varName = "ok_word",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8313926,
						sizeY = 0.963034,
						text = "确 定",
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
			{
				prop = {
					etype = "Label",
					name = "zt",
					posX = 0.6837895,
					posY = 0.7444056,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4483631,
					sizeY = 0.1927832,
					text = "满级",
					color = "FFC93034",
					hTextAlign = 2,
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
	dk = {
		ysjm = {
			scale = {{0, {0.3, 0.3, 1}}, {150, {1.1, 1.1, 1}}, {200, {1,1,1}}, },
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
