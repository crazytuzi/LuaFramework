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
				varName = "close_btn",
				posX = 0.5000001,
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
				etype = "Button",
				name = "gb",
				posX = 0.485178,
				posY = 0.5015166,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6972954,
				sizeY = 0.6686084,
				soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "meili",
				varName = "UIRoot",
				posX = 0.5101402,
				posY = 0.5804234,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.7682143,
				sizeY = 0.8236111,
				image = "tzdb#tzdb",
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "wz1",
					varName = "roleName",
					posX = 0.4754227,
					posY = 0.584675,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.227413,
					sizeY = 0.1108723,
					text = "玩家名字：",
					color = "FF43261D",
					fontSize = 22,
					fontOutlineColor = "FF112927",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wz3",
					posX = 0.4754229,
					posY = 0.3051096,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.227413,
					sizeY = 0.1108723,
					text = "战胜奖励：",
					color = "FF43261D",
					fontSize = 22,
					fontOutlineColor = "FF112927",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "msz",
					varName = "desc",
					posX = 0.5836357,
					posY = 0.4368656,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4438385,
					sizeY = 0.2272832,
					text = "描述写在这",
					color = "FF634624",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tyd",
					posX = 0.5896661,
					posY = 0.1814273,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4867011,
					sizeY = 0.1743408,
					image = "d#tyd",
					alpha = 0.3,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an",
					varName = "goFight",
					posX = 0.761129,
					posY = 0.1745248,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1657659,
					sizeY = 0.1079258,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					disablePressScale = true,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "anz",
						varName = "btnName",
						posX = 0.5,
						posY = 0.546875,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8696096,
						sizeY = 0.8270338,
						text = "前往挑战",
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
					etype = "Sprite3D",
					name = "mx",
					varName = "model",
					posX = 0.1583854,
					posY = 0.1522505,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2933537,
					sizeY = 0.6715643,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jjdt2",
					posX = 0.1861543,
					posY = 0.09623806,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2827173,
					sizeY = 0.0539629,
					image = "tzs#mzd",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wz2",
						varName = "npcName",
						posX = 0.4424464,
						posY = 0.46875,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7321527,
						sizeY = 1.470574,
						text = "玩家名字：",
						color = "FFFFFF00",
						fontSize = 22,
						fontOutlineColor = "FF112927",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb",
					varName = "scroll",
					posX = 0.5285937,
					posY = 0.180253,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3062871,
					sizeY = 0.1512566,
					horizontal = true,
					showScrollBar = false,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "hyt",
				varName = "titleImg",
				posX = 0.4797212,
				posY = 0.7357242,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3617187,
				sizeY = 0.1722222,
				image = "tzs#tzs",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "hyt2",
				varName = "winImg",
				posX = 0.4797212,
				posY = 0.7357242,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.196875,
				sizeY = 0.08333334,
				image = "tzs#zdsl",
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
