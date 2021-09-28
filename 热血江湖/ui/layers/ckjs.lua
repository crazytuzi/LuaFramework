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
				sizeX = 0.5515625,
				sizeY = 0.7194445,
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
					name = "wk",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9185745,
					sizeY = 0.8006645,
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
					etype = "Image",
					name = "jqd",
					posX = 0.5,
					posY = 0.5744359,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8349025,
					sizeY = 0.4803738,
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
						name = "jj",
						varName = "tst",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.974106,
						sizeY = 0.9379456,
						text = "jianjie",
						color = "FF966856",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an1",
					varName = "cancel_btn",
					posX = 0.9329255,
					posY = 0.8394672,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.09490085,
					sizeY = 0.1467181,
					image = "chu1#gb",
					imageNormal = "chu1#gb",
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an2",
					varName = "marry_btn",
					posX = 0.2765706,
					posY = 0.1904828,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2464589,
					sizeY = 0.1274131,
					image = "chu1#an1",
					imageNormal = "chu1#an1",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "anz2",
						posX = 0.5,
						posY = 0.546875,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.958208,
						sizeY = 1.00501,
						text = "我要结婚",
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
					etype = "Image",
					name = "top",
					posX = 0.5,
					posY = 0.9036365,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3739377,
					sizeY = 0.1003861,
					image = "chu1#top",
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "tt",
						varName = "title_desc",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.5151515,
						sizeY = 0.4807692,
						image = "biaoti#ckxt",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an3",
					varName = "buy_btn",
					posX = 0.724,
					posY = 0.1904828,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2464589,
					sizeY = 0.1274131,
					image = "chu1#an1",
					imageNormal = "chu1#an1",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "anz3",
						varName = "buy_title",
						posX = 0.5,
						posY = 0.546875,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.958208,
						sizeY = 1.00501,
						text = "元宝解锁",
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
					etype = "Image",
					name = "yb",
					varName = "buyCost",
					posX = 0.6739337,
					posY = 0.2937525,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.06373936,
					sizeY = 0.08687258,
					image = "tb#yuanbao",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "ybs",
						varName = "buyNum",
						posX = 2.402188,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 2.540757,
						sizeY = 0.9015108,
						text = "x500",
						color = "FF966856",
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
			scale = {{0, {0, 0, 1}}, {150, {1.05, 1.05, 1}}, {200, {1,1,1}}, },
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
