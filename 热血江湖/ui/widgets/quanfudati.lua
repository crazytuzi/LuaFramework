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
				etype = "Image",
				name = "czsl",
				varName = "CZSL",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "b#d5",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
				alpha = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "hd",
					posX = 0.5,
					posY = 0.3664775,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9739665,
					sizeY = 0.6973568,
					scale9 = true,
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
					alpha = 0.5,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "fae",
					posX = 0.5,
					posY = 0.346058,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8974539,
					sizeY = 0.3124115,
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
						etype = "Image",
						name = "top",
						posX = 0.5,
						posY = 0.9863064,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5522174,
						sizeY = 0.2612985,
						image = "chu1#top2",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "lbk4",
					posX = 0.5,
					posY = 0.5124391,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9739665,
					sizeY = 0.3374056,
					scale9 = true,
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
					alpha = 0.5,
				},
				children = {
				{
					prop = {
						etype = "RichText",
						name = "wb12",
						varName = "ActivitiesContent",
						posX = 0.6083109,
						posY = 0.7054569,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7283627,
						sizeY = 0.39098,
						text = "回答问题、答对越多、奖励越多。",
						color = "FF634624",
						fontSize = 22,
						fontOutlineColor = "FF00335D",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wza",
						posX = 0.1805391,
						posY = 0.8010774,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2434872,
						sizeY = 0.3036204,
						text = "活动介绍：",
						color = "FF634624",
						fontSize = 22,
						fontOutlineColor = "FF00335D",
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hdd",
					posX = 0.5061256,
					posY = 0.8391087,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 1.012117,
					sizeY = 0.3125184,
					image = "czt#hddt4",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "smd",
						posX = 0.7435668,
						posY = 0.6491526,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6182364,
						sizeY = 0.3651182,
						alpha = 0.5,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "wb10",
							posX = -0.03708182,
							posY = -7.705963,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.448608,
							sizeY = 0.6774076,
							text = "活动开启时间：",
							color = "FFC93034",
							fontSize = 24,
							fontOutlineColor = "FF00335D",
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "wb11",
							varName = "ActivitiesTime",
							posX = 0.4931542,
							posY = -7.705963,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6425622,
							sizeY = 0.6774076,
							text = "3天23小时22分钟",
							color = "FFC93034",
							fontSize = 24,
							fontOutlineColor = "FF00335D",
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "wb13",
							varName = "ActivitiesTitle",
							posX = 0.3320966,
							posY = -0.4876069,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 0.476552,
							sizeY = 0.6565704,
							fontSize = 24,
							fontOutlineEnable = true,
							fontOutlineColor = "FF00335D",
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "topt",
						posX = 0.8571284,
						posY = 0.3833821,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1376884,
						sizeY = 0.3119998,
						image = "czt#keju",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an",
					posX = 0.5,
					posY = 0.09694856,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2664625,
					sizeY = 0.1496599,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wz",
						varName = "Join",
						posX = 0.5,
						posY = 0.5151515,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9266993,
						sizeY = 0.8737805,
						text = "参 加",
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
					etype = "Label",
					name = "wza2",
					posX = 0.5,
					posY = 0.4956327,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6169793,
					sizeY = 0.1904954,
					text = "参与活动获取丰厚大奖",
					color = "FFF1E9D7",
					fontOutlineEnable = true,
					fontOutlineColor = "FFA47848",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dj1",
					varName = "item_bg",
					posX = 0.2538077,
					posY = 0.3279211,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1378254,
					sizeY = 0.2062299,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "ck1",
						varName = "Btn1",
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
						name = "djt1",
						varName = "item_icon",
						posX = 0.5,
						posY = 0.5439816,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8,
						sizeY = 0.8,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dj2",
					varName = "item_bg2",
					posX = 0.4168885,
					posY = 0.3279211,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					lockHV = true,
					sizeX = 0.1378254,
					sizeY = 0.2062299,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "ck2",
						varName = "Btn2",
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
						name = "djt2",
						varName = "item_icon2",
						posX = 0.5,
						posY = 0.5439816,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8,
						sizeY = 0.8,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dj3",
					varName = "item_bg3",
					posX = 0.5799692,
					posY = 0.3279211,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					lockHV = true,
					sizeX = 0.1378254,
					sizeY = 0.2062299,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "ck3",
						varName = "Btn3",
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
						name = "djt3",
						varName = "item_icon3",
						posX = 0.5,
						posY = 0.5439816,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8,
						sizeY = 0.8,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dj4",
					varName = "item_bg4",
					posX = 0.7430501,
					posY = 0.3279211,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					lockHV = true,
					sizeX = 0.1378254,
					sizeY = 0.2062299,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "ck4",
						varName = "Btn4",
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
						name = "djt4",
						varName = "item_icon4",
						posX = 0.5,
						posY = 0.5439816,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8,
						sizeY = 0.8,
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
