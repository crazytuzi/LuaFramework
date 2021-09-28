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
			name = "k1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.709375,
			sizeY = 0.6378398,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				varName = "CZSL",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7885463,
				sizeY = 0.7512336,
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
					etype = "Image",
					name = "hdd",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 1.269553,
					sizeY = 1.553623,
					image = "、",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "d",
						posX = 0.3945615,
						posY = 0.472055,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7292741,
						sizeY = 0.7711114,
						image = "czhd#dc",
						scale9 = true,
						scale9Left = 0.45,
						scale9Right = 0.45,
						scale9Top = 0.45,
						scale9Bottom = 0.45,
						alphaCascade = true,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "d1",
						posX = 0.3956592,
						posY = 0.04553148,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7336683,
						sizeY = 0.0596047,
						image = "czhd1#xinxi",
						scale9 = true,
						scale9Left = 0.45,
						scale9Right = 0.45,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "z",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6627636,
							sizeY = 0.9390225,
							image = "czhd1#20bei",
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "z4",
						varName = "ActivitiesContent",
						posX = 0.3945616,
						posY = 0.04510614,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.7336684,
						sizeY = 0.08855903,
						color = "FFF1E9D7",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FFA47848",
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
				etype = "Scroll",
				name = "lb2",
				varName = "fundGiftList",
				posX = 0.394431,
				posY = 0.4706551,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7257193,
				sizeY = 0.8891245,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "lhd",
				posX = 0.8814176,
				posY = 0.4978225,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2400881,
				sizeY = 1.171489,
				image = "czhd1#dt",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "lht",
				posX = 0.9146512,
				posY = 0.553309,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3623348,
				sizeY = 1.315203,
				image = "czhdlh#lh1",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "ysz2",
				posX = 0.8817759,
				posY = 0.189498,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2486248,
				sizeY = 0.5313072,
				image = "czhd1#db",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "z2",
					varName = "ActivitiesTime",
					posX = 0.5054809,
					posY = 0.5384593,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8968804,
					sizeY = 0.2895346,
					text = "活动时限",
					color = "FFF6C07F",
					fontSize = 22,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gm",
					varName = "buyBtn",
					posX = 0.3829951,
					posY = 0.1497556,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6201515,
					sizeY = 0.2254098,
					image = "chu1#an1",
					imageNormal = "chu1#an1",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "gmz",
						varName = "buyBtnText",
						posX = 0.4974011,
						posY = 0.5170173,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8893417,
						sizeY = 0.8017158,
						text = "购 买",
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
					name = "gm2",
					varName = "cztz",
					posX = 0.8394789,
					posY = 0.1532921,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1993344,
					sizeY = 0.1844262,
					image = "daxia#jia",
					imageNormal = "daxia#jia",
				},
			},
			},
		},
		{
			prop = {
				etype = "Sprite3D",
				name = "mx",
				posX = 0.9517437,
				posY = 0.723456,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2381604,
				sizeY = 0.50812,
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
	jn6 = {
	},
	bj = {
	},
	jn7 = {
	},
	bj2 = {
	},
	jn8 = {
	},
	bj3 = {
	},
	jn9 = {
	},
	bj4 = {
	},
	jn10 = {
	},
	bj5 = {
	},
	jn11 = {
	},
	bj6 = {
	},
	jn12 = {
	},
	bj7 = {
	},
	jn13 = {
	},
	bj8 = {
	},
	jn14 = {
	},
	bj9 = {
	},
	jn15 = {
	},
	bj10 = {
	},
	jn16 = {
	},
	bj11 = {
	},
	jn17 = {
	},
	bj12 = {
	},
	c_hld = {
	},
	c_hld2 = {
	},
	c_hld3 = {
	},
	c_hld4 = {
	},
	c_hld5 = {
	},
	c_hld6 = {
	},
	c_hld7 = {
	},
	c_hld8 = {
	},
	c_hld9 = {
	},
	c_hld10 = {
	},
	c_hld11 = {
	},
	c_hld12 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
