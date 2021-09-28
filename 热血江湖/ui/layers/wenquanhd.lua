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
				sizeX = 0.5078125,
				sizeY = 0.5277778,
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
					posX = 0.6859583,
					posY = 0.3792106,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.7661538,
					sizeY = 0.7289473,
					image = "hua1#hua1",
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "top",
					posX = 0.5,
					posY = 1.001038,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4061539,
					sizeY = 0.1368421,
					image = "chu1#top",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "tioz",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5151514,
						sizeY = 0.4807692,
						image = "biaoti#yqhd",
					},
				},
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "ms1",
					varName = "tips",
					posX = 0.5,
					posY = 0.8021903,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8836542,
					sizeY = 0.25,
					text = "miaoshu1",
					color = "FF966856",
					fontSize = 22,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dw",
					posX = 0.5000001,
					posY = 0.5020728,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8575432,
					sizeY = 0.3299255,
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
						etype = "RichText",
						name = "ms2",
						varName = "desc",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9226986,
						sizeY = 0.8600217,
						text = "miaoshu1",
						color = "FF966856",
						fontSize = 22,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "yjzb",
					varName = "btn",
					posX = 0.5,
					posY = 0.1993003,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2676923,
					sizeY = 0.1736842,
					image = "chu1#an1",
					imageNormal = "chu1#an1",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "ys2",
						varName = "btnTitle",
						posX = 0.5,
						posY = 0.5454545,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9120977,
						sizeY = 1.156784,
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
					name = "djs",
					varName = "time",
					posX = 0.5,
					posY = 0.07438368,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.25,
					text = "倒计时",
					color = "FFC93034",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "ya1",
					posX = 0.0008200777,
					posY = 0.06912501,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2015385,
					sizeY = 0.1789474,
					image = "ya#y1",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "ya2",
					posX = 1.040649,
					posY = 0.07175285,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2107692,
					sizeY = 0.1657895,
					image = "ya#y2",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "closeBtn",
				posX = 0.7293202,
				posY = 0.7220285,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05078125,
				sizeY = 0.0875,
				image = "baishi#x",
				imageNormal = "baishi#x",
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
	gy13 = {
	},
	gy14 = {
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
