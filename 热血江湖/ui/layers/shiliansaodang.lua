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
				sizeX = 0.6328125,
				sizeY = 0.7118669,
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
					name = "hua",
					posX = 0.5,
					posY = 0.8209782,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9881986,
					sizeY = 0.3356922,
					image = "rcb#dw",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a2",
					varName = "sureBtn",
					posX = 0.8574443,
					posY = 0.1220786,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1952862,
					sizeY = 0.1170631,
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
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8313926,
						sizeY = 0.9422306,
						text = "一键扫荡",
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
					etype = "Image",
					name = "db1",
					posX = 0.5,
					posY = 0.5596131,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9116181,
					sizeY = 0.6568334,
					image = "b#d2",
					scale9 = true,
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lb",
						varName = "scroll",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9882957,
						sizeY = 0.9625649,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "top",
					posX = 0.5040882,
					posY = 0.9372479,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3728395,
					sizeY = 0.06828679,
					image = "baishi#biaoti",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wb2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6116014,
						sizeY = 1.428571,
						text = "试炼扫荡",
						color = "FF6E4228",
						fontSize = 22,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wb",
					varName = "desc",
					posX = 0.1854976,
					posY = 0.1602571,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2419838,
					sizeY = 0.1314213,
					text = "累计消耗：",
					color = "FF966856",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "tapz",
					varName = "tips",
					posX = 0.503697,
					posY = 0.08067849,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8783827,
					sizeY = 0.1130774,
					text = "一键扫荡为当前可扫荡的最高难度",
					color = "FFC93034",
					fontOutlineColor = "FFA47848",
					fontOutlineSize = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wb3",
					varName = "coinNum",
					posX = 0.34541,
					posY = 0.1602571,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1910436,
					sizeY = 0.1314213,
					text = "x666",
					color = "FF966856",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wb4",
					varName = "vitNum",
					posX = 0.5110919,
					posY = 0.1602571,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2267892,
					sizeY = 0.1314213,
					text = "x555",
					color = "FF966856",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tb1",
					posX = 0.2152796,
					posY = 0.159128,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.0617284,
					sizeY = 0.09755257,
					image = "tb#yuanbao",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "suo",
						posX = 0.6798328,
						posY = 0.3403631,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.5599999,
						sizeY = 0.56,
						image = "tb#suo",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tb2",
					posX = 0.3658985,
					posY = 0.159128,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.0617284,
					sizeY = 0.09755257,
					image = "tb#tl",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "close_btn",
				posX = 0.7940623,
				posY = 0.8175762,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05078125,
				sizeY = 0.0875,
				image = "baishi#x",
				imageNormal = "baishi#x",
				disablePressScale = true,
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
