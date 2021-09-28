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
				sizeX = 0.3979214,
				sizeY = 0.4517038,
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
					posX = 0.5,
					posY = 0.5007034,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.890251,
					sizeY = 0.3916728,
					image = "b#d2",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hua",
					posX = 0.5411637,
					posY = 0.442089,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9777371,
					sizeY = 0.8517135,
					image = "hua1#hua1",
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "z1",
					varName = "des",
					posX = 0.5,
					posY = 0.5007035,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8627434,
					sizeY = 0.3916728,
					text = "技能效果",
					color = "FF966856",
					fontOutlineColor = "FF27221D",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a1",
					varName = "close",
					posX = 0.5,
					posY = 0.1016705,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2846825,
					sizeY = 0.1691128,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "f1",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8313926,
						sizeY = 0.9422305,
						text = "确 定",
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
					etype = "Image",
					name = "jnk2",
					posX = 0.3279236,
					posY = 0.8418874,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1727728,
					sizeY = 0.2784615,
					image = "anqi#cheng",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "jnt2",
						varName = "img",
						posX = 0.5078723,
						posY = 0.5030413,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.7583685,
						sizeY = 0.7369052,
						image = "xinjue#bati",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "mc",
						varName = "name",
						posX = 2.530886,
						posY = 0.7095146,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 2.788569,
						sizeY = 0.8178665,
						text = "心诀名称",
						color = "FF966856",
						fontSize = 22,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "mc2",
						varName = "unlock_des",
						posX = 2.530886,
						posY = 0.3043112,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 2.788569,
						sizeY = 0.8178665,
						text = "lv60（已满级）",
						color = "FF65944D",
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mjz",
					varName = "tips",
					posX = 0.5,
					posY = 0.2390568,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.25,
					text = "恭喜您已满级",
					color = "FFC93034",
					hTextAlign = 1,
					vTextAlign = 1,
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
