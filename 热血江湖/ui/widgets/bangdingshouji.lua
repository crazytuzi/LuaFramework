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
				name = "shouchong",
				varName = "ShouChong",
				posX = 0.5,
				posY = 0.4977324,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.0107,
				sizeY = 1.027438,
				image = "bangding#bangding",
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dr",
					posX = 0.5,
					posY = 0.3236704,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.985418,
					sizeY = 0.4902861,
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
						etype = "Label",
						name = "sjh",
						posX = 0.3744457,
						posY = 0.8327309,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2010421,
						sizeY = 0.25,
						text = "手机号：",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "srk",
						posX = 0.3848691,
						posY = 0.8507366,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.255242,
						sizeY = 0.2160715,
					},
					children = {
					{
						prop = {
							etype = "EditBox",
							name = "sr1",
							sizeXAB = 166,
							sizeYAB = 48.00001,
							posXAB = 181.9999,
							posYAB = 24,
							varName = "editBox1",
							posX = 1.096385,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1,
							sizeY = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "sjh2",
							varName = "number",
							posX = 1.230598,
							posY = 0.4359747,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.229392,
							sizeY = 0.9128571,
							text = "12345678901",
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "srk2",
						posX = 0.3848691,
						posY = 0.6166626,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.255242,
						sizeY = 0.2160715,
					},
					children = {
					{
						prop = {
							etype = "EditBox",
							name = "sr2",
							sizeXAB = 166,
							sizeYAB = 48.00001,
							posXAB = 181.9999,
							posYAB = 29.99996,
							varName = "editBox2",
							posX = 1.096385,
							posY = 0.6249991,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1,
							sizeY = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "sjh3",
							varName = "verifyCode",
							posX = 1.230598,
							posY = 0.6249991,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.229392,
							sizeY = 0.9128571,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sjh4",
						posX = 0.3775209,
						posY = 0.6436713,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2010421,
						sizeY = 0.25,
						text = "验证码：",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "sn",
						varName = "codeBtn",
						posX = 0.7378935,
						posY = 0.6527992,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1314915,
						sizeY = 0.1800596,
						image = "chu1#sn1",
						imageNormal = "chu1#sn1",
						disablePressScale = true,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "sjh5",
							varName = "codeBtnText",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9188959,
							sizeY = 1.517669,
							text = "获 取",
							color = "FF966856",
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
					etype = "Button",
					name = "an8",
					varName = "getBtn",
					posX = 0.5,
					posY = 0.0769012,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2197013,
					sizeY = 0.121386,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "z2",
						varName = "getBtnText",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.016411,
						sizeY = 0.8880838,
						text = "绑 定",
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
					etype = "Scroll",
					name = "lb",
					varName = "scroll",
					posX = 0.5,
					posY = 0.2488258,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.1765614,
					horizontal = true,
					showScrollBar = false,
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
