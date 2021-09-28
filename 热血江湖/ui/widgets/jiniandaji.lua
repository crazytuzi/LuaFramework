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
			sizeX = 0.5101563,
			sizeY = 0.6125,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "cz",
				varName = "chongzhi",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.6,
				sizeY = 0.25,
			},
		},
		{
			prop = {
				etype = "Sprite3D",
				name = "mx",
				varName = "model",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.6,
				sizeY = 0.25,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "czsl",
				varName = "CZSL",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
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
					name = "fas",
					posX = 0.4954058,
					posY = 0.5090704,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 1.03,
					sizeY = 1.033645,
					image = "chongzhifanli#chongzhifanli",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wz",
						posX = 0.5051453,
						posY = 0.8132697,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8269501,
						sizeY = 0.1622486,
						text = "本次测试期间进行储值,将会在公测时进行储值返还！",
						color = "FF60FF00",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "RichText",
						name = "fwa",
						varName = "dfas",
						posX = 0.5037175,
						posY = 0.5240939,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9366252,
						sizeY = 0.25,
						text = "1.公测返还元宝数量为<c=fffe1616>本次测试储值获得元宝数量*1.5，贵族点返还储值获得元宝数量*1<c=ff563d2b> （例：本次测试储值300元宝，公测时将返还300*1.5=450元宝，以及300*1=300贵族经验！）\n",
						color = "FF563D2B",
						lineSpace = 4,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wz2",
						posX = 0.4383481,
						posY = 0.6358681,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8269501,
						sizeY = 0.1622486,
						text = "【储值公测返还说明】",
						color = "FFFE1616",
					},
				},
				{
					prop = {
						etype = "RichText",
						name = "fwa2",
						varName = "asd",
						posX = 0.5037175,
						posY = 0.3288462,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9366252,
						sizeY = 0.25,
						text = "2.公测时只有<c=fffe1616>登录本次测试时使用的平台帐号才能获得以上返利<c=ff563d2b>，使用游客帐号登六的少侠请务必邦定平台帐护，并请妥善保管本次测试的帐号。\n此外，官方将以2017年7月29日21:00的竞技场排行榜为基准，对各服排名前30的少侠给予奖励，奖励将在公测开启后以邮件形式发送，请各位少侠届时以本次测试时使用的平台帐号登录游戏喔。",
						color = "FF563D2B",
						lineSpace = 4,
					},
				},
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
