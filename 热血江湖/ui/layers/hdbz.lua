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
				posY = 0.4749998,
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
					etype = "Button",
					name = "gb",
					varName = "closeBtn",
					posX = 0.9659991,
					posY = 0.9355425,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.06600985,
					sizeY = 0.1310345,
					image = "chu1#gb",
					imageNormal = "chu1#gb",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "bjt",
					posX = 0.5,
					posY = 0.5310463,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.863362,
					sizeY = 0.7969544,
					image = "hddt#bj",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
					alpha = 0.6,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl",
					posX = 0.5000001,
					posY = 0.08977316,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8235407,
					sizeY = 0.1216879,
					text = "选择需要补做的活动",
					color = "FF966856",
					fontSize = 22,
					fontOutlineColor = "FF0C3F3C",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb",
					varName = "scrollList",
					posX = 0.5,
					posY = 0.5310463,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8513113,
					sizeY = 0.7849191,
					showScrollBar = false,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "andt",
					posX = 0.8260252,
					posY = 0.08977317,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.04039409,
					sizeY = 0.07068966,
					image = "sz#xzd",
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "xzan",
						varName = "bzts_btn",
						posX = 0.4947014,
						posY = 0.5230752,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.273497,
						sizeY = 1.256469,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xztp",
						varName = "bzts_img",
						posX = 0.5,
						posY = 0.5263543,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						lockHV = true,
						sizeX = 0.7906272,
						sizeY = 0.7906272,
						image = "sz#xzt",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "bzts",
						posX = 3.323175,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 4.194022,
						sizeY = 1.046,
						text = "不再提示",
						color = "FFC93034",
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
				posY = 0.8724046,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.20625,
				sizeY = 0.07222223,
				image = "chu1#top",
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "topz",
					posX = 0.5,
					posY = 0.4996001,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.5151515,
					sizeY = 0.4807692,
					image = "biaoti#hdbz",
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
