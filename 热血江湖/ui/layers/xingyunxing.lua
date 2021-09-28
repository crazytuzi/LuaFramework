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
				varName = "imgBK",
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
				sizeX = 0.4571975,
				sizeY = 0.5350656,
				image = "b#cs",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.25,
				scale9Bottom = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "kk",
					posX = 0.5,
					posY = 0.6589416,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.78724,
					sizeY = 0.2298181,
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
						name = "z1",
						varName = "desc",
						posX = 0.5,
						posY = 0.4999996,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9283833,
						sizeY = 0.8944348,
						text = "完成帮派任务概率获得幸运星，赠送给他人可获得奖励（大地图点击玩家头像赠送，送给同职业玩家，奖励翻倍）",
						color = "FFF95C2E",
						fontOutlineColor = "FF27221D",
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hua",
					posX = 0.6603714,
					posY = 0.4097911,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8509725,
					sizeY = 0.7978333,
					image = "hua1#hua1",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a2",
					varName = "ok",
					posX = 0.5,
					posY = 0.1189695,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.261288,
					sizeY = 0.1505527,
					image = "chu1#an1",
					imageNormal = "chu1#an1",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "f2",
						varName = "yes_name",
						posX = 0.5,
						posY = 0.546875,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8313926,
						sizeY = 0.9422306,
						text = "我知道了",
						fontSize = 22,
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
					name = "cs",
					varName = "remainNum",
					posX = 0.5,
					posY = 0.9210198,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.1911381,
					text = "剩余次数：2",
					color = "FFF95C2E",
					fontSize = 22,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "cs2",
					varName = "state",
					posX = 0.5,
					posY = 0.828713,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.1911381,
					text = "（大地图点击玩家头像赠送）",
					color = "FF966856",
					fontSize = 18,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "kk2",
					posX = 0.5,
					posY = 0.3454442,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7872401,
					sizeY = 0.2592237,
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
						etype = "Scroll",
						name = "lb",
						varName = "scroll",
						posX = 0.5,
						posY = 0.4281459,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 0.8562909,
						horizontal = true,
						showScrollBar = false,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "jl",
						posX = 0.5,
						posY = 1,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4037309,
						sizeY = 0.3604859,
						image = "chu1#top2",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "topz",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8850538,
							sizeY = 0.9950985,
							text = "获得奖励",
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
				},
			},
			{
				prop = {
					etype = "Image",
					name = "top",
					posX = 0.5,
					posY = 1.06766,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.808253,
					sizeY = 0.3867646,
					image = "mztop#top",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "xyx",
						posX = 0.5,
						posY = 0.533557,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2980973,
						sizeY = 0.5033557,
						image = "hy#xyx",
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
