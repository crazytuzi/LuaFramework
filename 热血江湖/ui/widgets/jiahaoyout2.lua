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
			name = "k2",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.5447938,
			sizeY = 0.1593264,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an3",
				varName = "globel_btn",
				posX = 0.3095093,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6190187,
				sizeY = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "bplbt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.995517,
				sizeY = 1,
				image = "hy#d1",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "id2",
					varName = "name_label",
					posX = 0.5800872,
					posY = 0.6989933,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4655889,
					sizeY = 0.4545346,
					text = "无敌小旋风旋风",
					color = "FF966856",
					fontSize = 22,
					fontOutlineColor = "FF0E2620",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an2",
					varName = "apply_btn",
					posX = 0.8374538,
					posY = 0.2611171,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1771798,
					sizeY = 0.5056008,
					image = "chu1#an3",
					imageNormal = "chu1#an3",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "anz2",
						varName = "btn_text",
						posX = 0.5,
						posY = 0.5344828,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.101681,
						sizeY = 1.00501,
						text = "加为好友",
						fontOutlineEnable = true,
						fontOutlineColor = "FF347468",
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
					name = "ms",
					varName = "isfriend",
					posX = 0.8286352,
					posY = 0.6858872,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2865177,
					sizeY = 0.4456149,
					text = "一加我为好友",
					color = "FF966856",
					fontOutlineColor = "FF0E2620",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tb",
					varName = "txb_img",
					posX = 0.1366162,
					posY = 0.4577288,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2108022,
					sizeY = 1.028636,
					image = "zdtx#txd",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "tx2",
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
						posX = 0.7836995,
						posY = 0.2500532,
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
							sizeX = 1.5814,
							sizeY = 1.266296,
							text = "100",
							fontSize = 18,
							fontOutlineEnable = true,
							fontOutlineColor = "FF0E2620",
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
					posX = 0.3010085,
					posY = 0.6856859,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.0645313,
					sizeY = 0.3922765,
					image = "zy#daoke",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "id3",
					varName = "fightpower",
					posX = 0.5015373,
					posY = 0.251664,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4655889,
					sizeY = 0.4545346,
					text = "战力：123456",
					color = "FF966856",
					fontOutlineColor = "FF0E2620",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dui",
					varName = "duihao",
					posX = 0.8374538,
					posY = 0.5168378,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.1181199,
					sizeY = 0.5317525,
					image = "ty#xzjt",
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
