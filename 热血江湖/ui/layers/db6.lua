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
			name = "xxysjm",
			posX = 0.5,
			posY = 0.35,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 0.7,
			layoutType = 2,
			layoutTypeW = 2,
		},
		children = {
		{
			prop = {
				etype = "Sprite3D",
				name = "mx",
				varName = "npcmodule",
				posX = 0.1189844,
				posY = -0.3464527,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2238505,
				sizeY = 1.275682,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt5",
				posX = 0.5,
				posY = 0.1550934,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.25,
				sizeY = 0.3101867,
				image = "l#db",
				scale9 = true,
				scale9Left = 0.35,
				scale9Right = 0.6,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt1",
				posX = 0.5,
				posY = 0.1550934,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.3101867,
				scale9 = true,
				scale9Left = 0.35,
				scale9Right = 0.6,
			},
			children = {
			{
				prop = {
					etype = "RichText",
					name = "db",
					varName = "dialogue",
					posX = 0.4340919,
					posY = 0.4028113,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4500425,
					sizeY = 0.6705377,
					text = "这里写的文字对白",
					fontSize = 24,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "top",
					varName = "taskTips2",
					posX = 0.4200523,
					posY = 0.845082,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4219633,
					sizeY = 0.4054169,
					text = "运镖完成",
					color = "FFFFFF00",
					fontSize = 26,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "k1",
				posX = 0.6296695,
				posY = 0.2020548,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7273214,
				sizeY = 0.386621,
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "an",
					varName = "ensure_btn",
					posX = 0.8375319,
					posY = 0.3749264,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3302946,
					sizeY = 0.7582827,
					propagateToChildren = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "an2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5300903,
						sizeY = 0.4331445,
						image = "chu1#an1",
						imageNormal = "chu1#an1",
						disableClick = true,
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "ff",
						varName = "ensure_lable",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.084064,
						sizeY = 0.9609028,
						text = "完 成",
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
			},
		},
		{
			prop = {
				etype = "Image",
				name = "js1",
				varName = "npc_icon",
				posX = 0.0367071,
				posY = 0.3058804,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				lockHV = true,
				sizeX = 0.04964647,
				sizeY = 0.1260862,
				image = "js1.png",
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
