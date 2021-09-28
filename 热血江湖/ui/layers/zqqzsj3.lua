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
				sizeX = 0.3356418,
				sizeY = 0.7614998,
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
					sizeX = 1.093276,
					sizeY = 0.716465,
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
						name = "dww",
						posX = 0.5,
						posY = 0.8136653,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9043959,
						sizeY = 0.241839,
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
						etype = "Image",
						name = "d5",
						posX = 0.5,
						posY = 0.4173822,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9043959,
						sizeY = 0.4193095,
						image = "b#d2",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
						scale9Top = 0.4,
						scale9Bottom = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "top1",
							posX = 0.5,
							posY = 0.8248053,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6615031,
							sizeY = 0.1942755,
							image = "chu1#top3",
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "djd",
					varName = "item_bg",
					posX = 0.2115952,
					posY = 0.722014,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2001762,
					sizeY = 0.1805647,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "djt",
						varName = "skillIcon",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9302326,
						sizeY = 0.8080809,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "an",
						varName = "item_btn",
						posX = 0.5005332,
						posY = 0.5272427,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.935298,
						sizeY = 0.9554245,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wbk",
						varName = "skillLvl",
						posX = 3.10743,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 2.356593,
						sizeY = 0.553995,
						text = "10/10",
						color = "FF966856",
						fontSize = 22,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "jnk",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.069767,
						sizeY = 0.9292931,
						image = "zqqz#jnk",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a2",
					varName = "close",
					posX = 0.5,
					posY = 0.2203521,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3375064,
					sizeY = 0.1003137,
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
						posX = 0.4927007,
						posY = 0.5090909,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8313926,
						sizeY = 0.963034,
						text = "确 定",
						fontSize = 22,
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
					name = "z5",
					varName = "skillName",
					posX = 0.5002627,
					posY = 0.7220141,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2550871,
					sizeY = 0.125091,
					text = "坚固",
					color = "FF65944D",
					fontSize = 24,
					fontOutlineColor = "FFFCEBCF",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "dqxg",
					varName = "curTitle",
					posX = 0.5,
					posY = 0.5356326,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3511388,
					sizeY = 0.09518068,
					text = "当前效果",
					color = "FFF1E9D7",
					fontOutlineEnable = true,
					fontOutlineColor = "FFA47848",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
				children = {
				{
					prop = {
						etype = "RichText",
						name = "sxz2",
						varName = "curEffect",
						posX = 0.5,
						posY = -0.888788,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 2.354071,
						sizeY = 1.912773,
						text = "文字描述四行文字描述四行文字描述四行文字描述四行文字描述四行文字描述四行文字描述四行文字描述四行文字描述四行",
						color = "FF966856",
						hTextAlign = 1,
						vTextAlign = 1,
						lineSpace = -3,
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
