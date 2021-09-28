--version = 1
local l_fileType = "node"

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
			etype = "Grid",
			name = "k1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.709375,
			sizeY = 0.6378398,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "db",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9724669,
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
					sizeX = 1.029445,
					sizeY = 1.167134,
					image = "czhd1#banner",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "czsl",
					varName = "CZSL",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6504032,
					sizeY = 0.9669474,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
					alpha = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "hdd",
						posX = 0.5200242,
						posY = 0.4144272,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 1.537508,
						sizeY = 1.00886,
						image = "sbdlbanner#sbdlbanner",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "smd",
							posX = 0.323186,
							posY = 0.1813896,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6182364,
							sizeY = 0.2111007,
							alpha = 0.5,
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "wb10",
								posX = 0.2347302,
								posY = 0.6249384,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.4314432,
								sizeY = 1.02058,
								text = "活动期限：",
								color = "FFF6C07F",
								fontOutlineColor = "FFFDE2FF",
								fontOutlineSize = 2,
								vTextAlign = 1,
							},
						},
						{
							prop = {
								etype = "Label",
								name = "wb11",
								varName = "ActivitiesTime",
								posX = 0.5186717,
								posY = 0.6460691,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.6296438,
								sizeY = 1.02058,
								text = "3天23小时22分钟",
								color = "FF76D646",
								fontOutlineColor = "FFFDE2FF",
								fontOutlineSize = 2,
								vTextAlign = 1,
							},
						},
						{
							prop = {
								etype = "Label",
								name = "wb13",
								varName = "ActivitiesTitle",
								posX = 0.8112466,
								posY = 0.5997086,
								anchorX = 0.5,
								anchorY = 0.5,
								visible = false,
								sizeX = 0.476552,
								sizeY = 0.6565704,
								fontSize = 24,
								fontOutlineEnable = true,
								fontOutlineColor = "FF00335D",
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
						name = "lbk4",
						posX = 0.5712735,
						posY = 0.5368334,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9739665,
						sizeY = 0.3374056,
						scale9Left = 0.3,
						scale9Right = 0.3,
						scale9Top = 0.3,
						scale9Bottom = 0.3,
						alpha = 0.5,
					},
					children = {
					{
						prop = {
							etype = "RichText",
							name = "wb12",
							varName = "ActivitiesContent",
							posX = -0.0137562,
							posY = -1.142972,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.5748332,
							sizeY = 0.6055309,
							text = "普通副本、组队副本掉落翻倍普通副本、组队副本掉落翻倍",
							color = "FFF6C07F",
							fontOutlineColor = "FFFFFFFF",
							fontOutlineSize = 2,
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
