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
			sizeX = 0.9991395,
			sizeY = 1.001132,
			image = "b#dd",
			scale9 = true,
			scale9Left = 0.45,
			scale9Right = 0.45,
			scale9Top = 0.45,
			scale9Bottom = 0.45,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an",
				posX = 0.5003901,
				posY = 0.5020767,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9968768,
				sizeY = 0.9875355,
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "ysjm",
			posX = 0.5,
			posY = 0.5013869,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt2",
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
					name = "kk3",
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
						name = "zs3",
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
						name = "zs4",
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
						name = "db3",
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
					name = "g2",
					posX = 0.5,
					posY = 0.5372843,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8665553,
					sizeY = 0.780221,
					image = "b#d5",
					scale9 = true,
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
					alpha = 0.9,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lb2",
						varName = "scroll",
						posX = 0.5,
						posY = 0.4962766,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9915382,
						sizeY = 0.9796129,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb2",
					varName = "close2",
					posX = 0.9660492,
					posY = 0.9338418,
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
					etype = "Label",
					name = "zzz2",
					varName = "tips",
					posX = 0.5000002,
					posY = 0.08743979,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.1215158,
					text = "主动离开会武不计次数，每周日05:00重置任务",
					color = "FFC93034",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "xan1",
					varName = "ok",
					posX = 0.8590393,
					posY = 0.09204776,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1517241,
					sizeY = 0.1,
					image = "chu1#fy2",
					imageNormal = "chu1#fy2",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "xwb1",
						posX = 0.5030825,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9789115,
						sizeY = 0.8778639,
						text = "领取奖励",
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
			},
		},
		{
			prop = {
				etype = "Image",
				name = "top2",
				posX = 0.5,
				posY = 0.8765713,
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
					etype = "Label",
					name = "wz2",
					varName = "title2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.9,
					sizeY = 0.9382726,
					text = "会武奖励",
					color = "FF7F4920",
					fontSize = 24,
					fontOutlineColor = "FF7F4920",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
					colorTL = "FFC0FFEC",
					colorTR = "FFC0FFEC",
					colorBR = "FF59E3D4",
					colorBL = "FF59E3D4",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "topz",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5151515,
					sizeY = 0.4807692,
					image = "biaoti#hwjl",
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
