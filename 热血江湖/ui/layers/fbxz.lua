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
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3943422,
				sizeY = 0.3811519,
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
					etype = "Button",
					name = "zss",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "kk",
					varName = "pannel1",
					posX = 0.5020779,
					posY = 0.6383771,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.8977282,
					sizeY = 0.5968922,
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
						varName = "desc1",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.963879,
						sizeY = 1.018178,
						text = "50级开启的新地图需要下载新的游戏包",
						color = "FF634624",
						fontSize = 22,
						fontOutlineColor = "FF27221D",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "kk2",
					varName = "pannel2",
					posX = 0.5020779,
					posY = 0.6383772,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8977282,
					sizeY = 0.5968922,
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
						name = "z3",
						varName = "desc2",
						posX = 0.4999999,
						posY = 0.6782338,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.963879,
						sizeY = 0.6495011,
						text = "资源下载完成！",
						color = "FF966856",
						fontSize = 22,
						fontOutlineColor = "FF27221D",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "jd1",
						varName = "processBar",
						posX = 0.5,
						posY = 0.1416113,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9379092,
						sizeY = 0.1953545,
						image = "chu1#jdd",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
					},
					children = {
					{
						prop = {
							etype = "LoadingBar",
							name = "jdt",
							varName = "progressBar",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9647059,
							sizeY = 0.6250001,
							image = "tong#jdt",
							percent = 1000,
							imageHead = "ty#guang",
						},
					},
					{
						prop = {
							etype = "RichText",
							name = "dz",
							varName = "barValue",
							posX = 0.4976798,
							posY = 1.32125,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8301919,
							sizeY = 1.930469,
							text = "100%",
							color = "FF966856",
							fontSize = 22,
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
					name = "hua",
					posX = 0.6658543,
					posY = 0.3678628,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.826986,
					sizeY = 0.7118605,
					image = "hua1#hua1",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a1",
					varName = "downloadBtn",
					posX = 0.75,
					posY = 0.1585513,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.322927,
					sizeY = 0.2332112,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "f1",
						varName = "no_name",
						posX = 0.5,
						posY = 0.546875,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8313926,
						sizeY = 0.9422305,
						text = "下载",
						fontSize = 24,
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
					name = "a2",
					varName = "pauseBtn",
					posX = 0.25,
					posY = 0.1585513,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.322927,
					sizeY = 0.2332112,
					image = "chu1#an1",
					imageNormal = "chu1#an1",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "f2",
						varName = "no_name2",
						posX = 0.5,
						posY = 0.546875,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8313926,
						sizeY = 0.9422305,
						text = "暂停下载",
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
					etype = "Button",
					name = "cs",
					varName = "rewardBtn",
					posX = 0.1749546,
					posY = 0.8171539,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1901901,
					sizeY = 0.1821962,
					image = "ty#sn1",
					imageNormal = "ty#sn1",
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
