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
			posX = 0.5028733,
			posY = 0.5034661,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.725,
			sizeY = 0.1642832,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "bplbt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "hy#d2",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.6,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "id2",
					varName = "name_label",
					posX = 0.3042201,
					posY = 0.669085,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2026089,
					sizeY = 0.4545346,
					text = "无敌小旋风",
					color = "FF966856",
					fontSize = 24,
					fontOutlineColor = "FF0E2620",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an2",
					varName = "showPosbtn",
					posX = 0.7070358,
					posY = 0.4974559,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1875,
					sizeY = 0.5579795,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "anz2",
						varName = "btn_text",
						posX = 0.493865,
						posY = 0.5454545,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8401152,
						sizeY = 1.00501,
						text = "追 踪",
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
					name = "tb",
					varName = "txb_img",
					posX = 0.07854091,
					posY = 0.466183,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1342417,
					sizeY = 0.8454236,
					image = "zdtx#txd",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "tx",
						varName = "tx_img",
						posX = 0.5054789,
						posY = 0.6925332,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.7210885,
						sizeY = 1.110169,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "djd",
						posX = 0.8479171,
						posY = 0.2300532,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.3371428,
						sizeY = 0.43,
						image = "zdte#djd2",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "dj",
							varName = "level",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.577126,
							sizeY = 1.231579,
							text = "100",
							fontSize = 18,
							fontOutlineEnable = true,
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
					name = "zy",
					varName = "career",
					posX = 0.1675851,
					posY = 0.6690848,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.04849138,
					sizeY = 0.3804406,
					image = "zy#daoke",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zt",
					varName = "state",
					posX = 0.1720097,
					posY = 0.2721399,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.0625,
					sizeY = 0.2451728,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an5",
					varName = "delete_btn",
					posX = 0.8939714,
					posY = 0.4974561,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1875,
					sizeY = 0.5579795,
					image = "chu1#an1",
					imageNormal = "chu1#an1",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "anz4",
						varName = "btn_text3",
						posX = 0.5,
						posY = 0.5454545,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8401152,
						sizeY = 1.00501,
						text = "删 除",
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
					etype = "Label",
					name = "id3",
					varName = "fightpower",
					posX = 0.3042201,
					posY = 0.27214,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2026089,
					sizeY = 0.4545346,
					text = "战力：54548",
					color = "FF966856",
					fontSize = 22,
					fontOutlineColor = "FF0E2620",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "id5",
					varName = "deadTime",
					posX = 0.5086962,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2264489,
					sizeY = 0.4545346,
					text = "击杀时间：3天前",
					color = "FF966856",
					fontSize = 22,
					fontOutlineColor = "FF0E2620",
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
