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
			scale9Left = 0.4,
			scale9Right = 0.4,
			scale9Top = 0.4,
			scale9Bottom = 0.4,
			alpha = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "a",
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
				etype = "Grid",
				name = "y1",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4764159,
				sizeY = 0.4940821,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "p1",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					image = "b#cs",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.2,
					scale9Bottom = 0.7,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "w11",
						varName = "descLabel",
						posX = 0.5524752,
						posY = 0.8155227,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9580595,
						sizeY = 0.1452335,
						text = "任务表述：击杀xx怪物100次",
						color = "FF966856",
						fontSize = 22,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "hua",
						posX = 0.6408206,
						posY = 0.4017859,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8166446,
						sizeY = 0.7786605,
						image = "hua1#hua1",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "closeBtn",
					posX = 0.9420434,
					posY = 0.9041306,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1065902,
					sizeY = 0.1770961,
					image = "baishi#x",
					imageNormal = "baishi#x",
					disablePressScale = true,
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "y2",
				posX = 0.5,
				posY = 0.5777215,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5,
				sizeY = 0.1499661,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "p3",
					posX = 0.590516,
					posY = 0.4323162,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6609375,
					sizeY = 0.2963633,
					image = "chu1#jdd",
					scale9 = true,
					scale9Left = 0.2,
					scale9Right = 0.2,
				},
				children = {
				{
					prop = {
						etype = "LoadingBar",
						name = "jd",
						varName = "processBar",
						posX = 0.4999978,
						posY = 0.5019873,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.969267,
						sizeY = 0.6249999,
						image = "tong#jdt",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "w24",
						varName = "processLabel",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6,
						sizeY = 0.9451803,
						text = "55/100",
						fontOutlineEnable = true,
						fontOutlineColor = "FF5B7838",
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
					name = "w2",
					posX = 0.2406652,
					posY = 0.4412405,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2942,
					sizeY = 0.5927351,
					text = "任务进度:",
					color = "FF966856",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "w23",
					posX = 0.5,
					posY = 0.361301,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.6,
					sizeY = 0.25,
					text = "(击杀100次后不交任务，进度条仍然继续)",
					color = "FFC93034",
					fontSize = 18,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "y3",
				posX = 0.5,
				posY = 0.4070982,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5,
				sizeY = 0.2995083,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "an1",
					varName = "goBtn",
					posX = 0.25,
					posY = 0.2129024,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2265625,
					sizeY = 0.2550476,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "w31",
						posX = 0.5,
						posY = 0.5363636,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 1,
						text = "前 往",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FF2A6953",
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
					name = "an2",
					varName = "cancelBtn",
					posX = 0.75,
					posY = 0.2129024,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2265625,
					sizeY = 0.2550476,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "w32",
						posX = 0.5,
						posY = 0.5363636,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 1,
						text = "放 弃",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FF2A6953",
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
					name = "db",
					posX = 0.55,
					posY = 0.6015639,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5680775,
					sizeY = 0.3941645,
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
						etype = "Label",
						name = "w3",
						posX = -0.1172982,
						posY = 0.8639295,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.372349,
						sizeY = 0.7148865,
						text = "获得奖励:",
						color = "FF966856",
						fontSize = 22,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Scroll",
						name = "lb",
						varName = "scroll",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9811294,
						sizeY = 1,
						horizontal = true,
						showScrollBar = false,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an3",
					varName = "rewardBtn",
					posX = 0.5,
					posY = 0.2129024,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					lockHV = true,
					sizeX = 0.2265625,
					sizeY = 0.2550476,
					image = "chu1#an1",
					imageNormal = "chu1#an1",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "w33",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 1,
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
				name = "ch",
				posX = 0.748798,
				posY = 0.4750441,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1945312,
				sizeY = 0.4027778,
				image = "dfw7#dfw7",
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
