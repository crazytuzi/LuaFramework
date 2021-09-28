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
				varName = "closeBtn",
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
				posX = 0.472699,
				posY = 0.512447,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.3148438,
				sizeY = 0.8291667,
				image = "xnhb2#hbd",
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.2,
				scale9Bottom = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dj1",
					posX = 0.4682033,
					posY = 0.4990472,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1488834,
					sizeY = 0.1005025,
					image = "tb#yuanbao",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "suo",
						posX = 0.6996506,
						posY = 0.3252777,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4375,
						sizeY = 0.4375001,
						image = "tb#suo",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "slz",
						varName = "diamondCnt",
						posX = 2.762696,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 3.095372,
						sizeY = 0.8904363,
						text = "555",
						color = "FFFFF9C4",
						fontSize = 22,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dj2",
					posX = 0.4682033,
					posY = 0.3785325,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1488834,
					sizeY = 0.1005025,
					image = "tb#tongqian",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "suo2",
						posX = 0.6996506,
						posY = 0.3252777,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4375,
						sizeY = 0.4375001,
						image = "tb#suo",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "slz2",
						varName = "coinCnt",
						posX = 2.762696,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 3.095372,
						sizeY = 0.8904363,
						text = "555",
						color = "FFFFF9C4",
						fontSize = 22,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "ts",
					varName = "desc",
					posX = 0.5866848,
					posY = 0.2953807,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8969542,
					sizeY = 0.25,
					text = "2018年2月21号可领",
					color = "FFFFF9C4",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "yjzb",
					varName = "getBtn",
					posX = 0.5867064,
					posY = 0.1835494,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.4317617,
					sizeY = 0.1105528,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "ys2",
						varName = "btnText",
						posX = 0.5,
						posY = 0.5151515,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9120977,
						sizeY = 1.156784,
						text = "确 定",
						fontSize = 24,
						fontOutlineEnable = true,
						fontOutlineColor = "FF347468",
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
	gy = {
	},
	gy3 = {
	},
	gy2 = {
	},
	gy4 = {
	},
	gy5 = {
	},
	gy6 = {
	},
	gy7 = {
	},
	gy8 = {
	},
	gy9 = {
	},
	gy10 = {
	},
	gy11 = {
	},
	gy12 = {
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
