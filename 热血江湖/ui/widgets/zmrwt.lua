--version = 1
local l_fileType = "node"

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
			etype = "Grid",
			name = "zmrwt",
			posX = 0.501269,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2382813,
			sizeY = 0.1527778,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an1",
				varName = "select_btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dt",
					varName = "skill_bg",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.98,
					sizeY = 0.95,
					image = "g#g_c4.png",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "txk",
					posX = 0.2029739,
					posY = 0.4818837,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3278688,
					sizeY = 0.8727271,
					image = "zm#dzk",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "tx",
						varName = "head_icon",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.8,
						sizeY = 0.8333333,
						image = "tx#tx_hongjun.png",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "djd",
						posX = 0.1436744,
						posY = 0.1967913,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3368421,
						sizeY = 0.34375,
						image = "w#w_djd2.png",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "dj",
							varName = "level_label",
							posX = 0.5030556,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9374992,
							sizeY = 1.2553,
							text = "90",
							fontOutlineEnable = true,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "g",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.74,
						sizeY = 0.8125,
						image = "zm#dzg",
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "jsm",
					varName = "name_label",
					posX = 0.5955678,
					posY = 0.7271186,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4004495,
					sizeY = 0.3637387,
					text = "张翠山",
					color = "FFBBFFED",
					fontSize = 24,
					fontOutlineEnable = true,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "sx1",
					varName = "skill1",
					posX = 0.4456758,
					posY = 0.3249746,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.147541,
					sizeY = 0.4090908,
					image = "zm#zm_jn1.png",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "z1",
						varName = "name1",
						posX = 0.8704806,
						posY = 0.2142281,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8396332,
						sizeY = 0.8437369,
						text = "9",
						fontSize = 24,
						fontOutlineEnable = true,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "sx2",
					varName = "skill2",
					posX = 0.648587,
					posY = 0.3249746,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.147541,
					sizeY = 0.4090908,
					image = "zm#zm_jn2.png",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "z2",
						varName = "name2",
						posX = 0.8704806,
						posY = 0.2142281,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8396332,
						sizeY = 0.8437369,
						text = "10",
						fontSize = 24,
						fontOutlineEnable = true,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "sx3",
					varName = "skill3",
					posX = 0.8514981,
					posY = 0.3249746,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.147541,
					sizeY = 0.4090908,
					image = "zm#zm_jn1.png",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "z3",
						varName = "name3",
						posX = 0.8704806,
						posY = 0.2142281,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8396332,
						sizeY = 0.8437369,
						text = "10",
						fontSize = 24,
						fontOutlineEnable = true,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zz",
					varName = "is_select",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.98,
					sizeY = 0.95,
					image = "g#g_zzt.png",
					scale9 = true,
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
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
