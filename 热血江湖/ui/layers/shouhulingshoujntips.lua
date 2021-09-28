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
			posX = 0.4992199,
			posY = 0.5013853,
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
					sizeX = 0.9091503,
					sizeY = 0.9072321,
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
						name = "d5",
						posX = 0.5,
						posY = 0.2165771,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9043959,
						sizeY = 0.3057177,
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
							name = "top2",
							posX = 0.5,
							posY = 1,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.5265415,
							sizeY = 0.2367343,
							image = "chu1#top2",
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "d6",
						posX = 0.5,
						posY = 0.5913035,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9043959,
						sizeY = 0.3430798,
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
						scale9Top = 0.4,
						scale9Bottom = 0.4,
					},
					children = {
					{
						prop = {
							etype = "RichText",
							name = "desc1",
							varName = "desc1",
							posX = 0.5,
							posY = 0.4920339,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9071919,
							sizeY = 0.8964925,
							color = "FF966856",
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "dw",
						posX = 0.5153362,
						posY = 0.8541758,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.6338923,
						sizeY = 0.1773134,
						image = "sblz#dw",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "djd",
					varName = "cover",
					posX = 0.2721128,
					posY = 0.8186807,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1908657,
					sizeY = 0.1495587,
					image = "zdjn#bai",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "djt",
						varName = "icon",
						posX = 0.5075853,
						posY = 0.4995144,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.7899687,
						sizeY = 0.8038135,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a2",
					varName = "close_btn",
					posX = 0.8809667,
					posY = 0.8996203,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.151296,
					sizeY = 0.1149048,
					image = "baishi#x",
					imageNormal = "baishi#x",
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z5",
					varName = "name",
					posX = 0.6173495,
					posY = 0.8183302,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4299048,
					sizeY = 0.1250911,
					text = "技能名称",
					color = "FF6F41C5",
					fontSize = 24,
					fontOutlineColor = "FFFCEBCF",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "xjxg",
					varName = "nextTitle",
					posX = 0.5,
					posY = 0.3779057,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3511388,
					sizeY = 0.09518068,
					text = "技能效果",
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
						name = "smwz",
						varName = "desc2",
						posX = 0.5,
						posY = -1.058084,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 2.044943,
						sizeY = 2.391539,
						text = "文字描述边上",
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
