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
				posY = 0.4791665,
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
					sizeX = 0.7960591,
					sizeY = 0.862069,
					image = "b#cs",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.2,
					scale9Bottom = 0.7,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "close",
					posX = 0.8657219,
					posY = 0.8735815,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.0640394,
					sizeY = 0.1086207,
					image = "baishi#x",
					imageNormal = "baishi#x",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
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
					sizeX = 1,
					sizeY = 1,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "bj",
						posX = 0.3268797,
						posY = 0.4414615,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.3954091,
						sizeY = 0.6475699,
						image = "yxbj#yxbj",
					},
					children = {
					{
						prop = {
							etype = "Sprite3D",
							name = "mx",
							varName = "hero_module",
							posX = 0.488053,
							posY = 0.1314055,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.5540137,
							sizeY = 0.6632114,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "ch",
							varName = "item_bg",
							posX = 0.488053,
							posY = 1.033405,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 1.132743,
							sizeY = 0.3026005,
							image = "ch/zuiwomeirenxi",
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "cht",
								varName = "item_icon",
								posX = 0.5,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.2500001,
								sizeY = 0.5,
							},
						},
						},
					},
					{
						prop = {
							etype = "Sprite3D",
							name = "tx",
							varName = "titleSpr",
							posX = 0.488053,
							posY = 0.1314055,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.5540137,
							sizeY = 0.6632114,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "di",
						posX = 0.6991798,
						posY = 0.5900452,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3413096,
						sizeY = 0.4760976,
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
							name = "to1",
							posX = 0.5,
							posY = 1,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.5369061,
							sizeY = 0.1303702,
							image = "chu1#top2",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "toz",
								posX = 0.5,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.6891448,
								sizeY = 1.306146,
								text = "称号属性",
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
							varName = "scroll",
							posX = 0.5,
							posY = 0.475857,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1,
							sizeY = 0.9,
						},
					},
					{
						prop = {
							etype = "RichText",
							name = "tj",
							varName = "get_label",
							posX = 0.5008631,
							posY = -0.284931,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9902048,
							sizeY = 0.25,
							text = "启动条件：xxxxx",
							color = "FF65944D",
							fontSize = 22,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "tj2",
							varName = "itemGrade_lable",
							posX = 0.5008631,
							posY = -0.09088632,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9902048,
							sizeY = 0.25,
							text = "时效：xxxxxx",
							color = "FFC93034",
							fontSize = 22,
							vTextAlign = 1,
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "tj3",
					varName = "desc",
					posX = 0.5,
					posY = 0.0318925,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8801091,
					sizeY = 0.2067604,
					text = "此称号为动态称号，装备此称号后只显示此称号",
					color = "FFFF8000",
					hTextAlign = 1,
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
