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
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
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
					sizeX = 1,
					sizeY = 1,
					image = "b#db1",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "zs1",
						posX = 0.02057244,
						posY = 0.1628659,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.05421687,
						sizeY = 0.3755943,
						image = "zhu#zs1",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zs2",
						posX = 0.9442027,
						posY = 0.1851488,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1592083,
						sizeY = 0.4057052,
						image = "zhu#zs2",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "db2",
						posX = 0.5,
						posY = 0.4921793,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9363168,
						sizeY = 0.959002,
						image = "b#db3",
						scale9 = true,
						scale9Left = 0.47,
						scale9Right = 0.47,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dj",
					varName = "leadImg",
					posX = 0.7818403,
					posY = 0.4932485,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3156613,
					sizeY = 0.9225838,
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "jd1",
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
						name = "db1",
						posX = 0.5,
						posY = 0.5017636,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8813089,
						sizeY = 0.8434408,
						image = "b#d5",
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
							name = "gzz",
							varName = "rule",
							posX = 0.8119624,
							posY = 0.4943551,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3402775,
							sizeY = 0.9557695,
							text = "规则文字规则文字规则文字规则文字规则文字规则文字规则文字规则文字规则文字规则文字",
							color = "FF966856",
						},
					},
					{
						prop = {
							etype = "Scroll",
							name = "lb",
							varName = "scroll",
							posX = 0.3091914,
							posY = 0.4943551,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6025978,
							sizeY = 0.9557697,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "bt",
							posX = 0.8099801,
							posY = 0.09693813,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3778078,
							sizeY = 0.1816338,
							image = "d#bt",
							alpha = 0.7,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "sx",
							posX = 0.62,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.003353721,
							sizeY = 1,
							image = "b#shuxian",
							scale9 = true,
							scale9Top = 0.4,
							scale9Bottom = 0.4,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "desc1",
							varName = "desc1",
							posX = 0.8119624,
							posY = 0.1304556,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6,
							sizeY = 0.25,
							text = "夺旗只在争夺分线开启",
							color = "FFC93034",
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "desc2",
							varName = "desc2",
							posX = 0.8119625,
							posY = 0.05909693,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6,
							sizeY = 0.25,
							text = "距离结束还有5:39:23秒",
							color = "FFC93034",
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
					etype = "Button",
					name = "gb",
					varName = "close_btn",
					posX = 0.9648742,
					posY = 0.9315518,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.06600985,
					sizeY = 0.1310345,
					image = "chu1#gb",
					imageNormal = "chu1#gb",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "top",
				posX = 0.5,
				posY = 0.8765713,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.20625,
				sizeY = 0.07222223,
				image = "chu1#top",
				scale9Left = 0.45,
				scale9Right = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "td2",
					posX = 0.4988506,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.6363636,
					sizeY = 0.4807692,
					image = "biaoti#top",
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
