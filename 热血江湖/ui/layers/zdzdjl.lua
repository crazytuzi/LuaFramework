--version = 1
local l_fileType = "layer"

local UIUtil = require "ui/common/UIUtil"

--EDITOR elements start tag
local eleRoot = 
{
	prop = {
		etype = "Layer",
		name = "root",
		varName = "dyjd_root",
		posX = 0,
		posY = 0,
		anchorX = 0,
		anchorY = 0,
	},
	children = {
	{
		prop = {
			etype = "Grid",
			name = "xjd",
			posX = 0.1755276,
			posY = 0.6261908,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.35,
			sizeY = 0.75,
			layoutType = 7,
			layoutTypeW = 7,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "sq",
				varName = "closeBtn",
				posX = 0.4595196,
				posY = 0.6756486,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1026786,
				sizeY = 0.08518519,
				image = "zdte#suojin",
				imageNormal = "zdte#suojin",
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "sq2",
				varName = "openBtn",
				posX = 0.05223214,
				posY = 0.6737968,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.1026786,
				sizeY = 0.08518519,
				image = "zdte#suojin",
				imageNormal = "zdte#suojin",
				disablePressScale = true,
				flippedX = true,
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "jd1",
			posX = 0.1755276,
			posY = 0.6261908,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.35,
			sizeY = 0.75,
			layoutType = 7,
			layoutTypeW = 7,
		},
		children = {
		{
			prop = {
				etype = "Grid",
				name = "dyjd",
				varName = "teamRoot",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				layoutType = 7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "gg",
					posX = 0.3186943,
					posY = 0.4113893,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6122284,
					sizeY = 0.4403085,
					image = "b#rwd",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Grid",
						name = "d2",
						posX = 0.5230163,
						posY = 0.9096753,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 1.037395,
						sizeY = 0.1808855,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "djs4",
							varName = "time_label2",
							posX = 0.4935463,
							posY = 0.2644233,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9254679,
							sizeY = 1.578259,
							text = "驻地似乎出现了几个调皮的精灵，请各位大侠找到他们。",
							fontSize = 18,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "RichText",
							name = "djs5",
							varName = "time",
							posX = 0.4753985,
							posY = -0.79493,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8891725,
							sizeY = 1.578259,
							text = "时间持续时间：",
							fontSize = 18,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "RichText",
							name = "djs6",
							varName = "number",
							posX = 0.4753985,
							posY = -1.493891,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8891725,
							sizeY = 1.578259,
							text = "剩余精灵数量：",
							fontSize = 18,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "RichText",
							name = "djs7",
							varName = "desc",
							posX = 0.4753985,
							posY = -3.422486,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8891725,
							sizeY = 2.011829,
							text = "其他描述其他描述其他描述其他描述其他描述其他描述其他描述其他描述其他描述",
							fontSize = 18,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "RichText",
							name = "djs8",
							varName = "selfCount",
							posX = 0.4753985,
							posY = -2.192851,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8891725,
							sizeY = 1.578259,
							text = "个人精灵数量：",
							fontSize = 18,
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
					name = "buffd",
					varName = "buffdRoot",
					posX = 0.4408794,
					posY = 0.6793346,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8797015,
					sizeY = 0.1148148,
					alpha = 0.5,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "zudui",
						varName = "team",
						posX = 0.3483617,
						posY = 0.5000002,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2385144,
						sizeY = 0.7419356,
						image = "zd#zd_an.png",
						imageNormal = "zd#zd_an.png",
						disablePressScale = true,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "ptz2",
							posX = 0.5,
							posY = 0.4812944,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9581574,
							sizeY = 0.91834,
							text = "队 伍",
							color = "FF634624",
							fontSize = 22,
							fontOutlineColor = "FF5D430E",
							fontOutlineSize = 2,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Button",
						name = "renwu",
						varName = "taskBtn",
						posX = 0.1233733,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2385144,
						sizeY = 0.7419356,
						image = "zd#zd_an.png",
						imageNormal = "zd#zd_an.png",
						disablePressScale = true,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "ptz3",
							posX = 0.5,
							posY = 0.4812944,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9581574,
							sizeY = 0.91834,
							text = "任 务",
							color = "FF634624",
							fontSize = 22,
							fontOutlineColor = "FF5D430E",
							fontOutlineSize = 2,
							hTextAlign = 1,
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
	},
	},
}
--EDITOR elements end tag
--EDITOR animations start tag
local l_animations =
{
	chu = {
		dyjd = {
			moveP = {{0, {-0.3, 0.5, 0}}, {300, {0.5, 0.5, 0}}, },
		},
	},
	ru = {
		dyjd = {
			moveP = {{0, {0.5, 0.5, 0}}, {200, {-0.3, 0.5, 0}}, },
		},
	},
	c_chu = {
		{0,"chu", 1, 0},
	},
	c_ru = {
		{0,"ru", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
