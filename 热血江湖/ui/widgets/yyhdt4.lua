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
			sizeX = 0.6902719,
			sizeY = 0.6378398,
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
				sizeX = 1.028806,
				sizeY = 1.167134,
				image = "czhd1#banner",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "shouchong",
				varName = "ShouChong",
				posX = 0.3993396,
				posY = 0.4281244,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7436743,
				sizeY = 0.9755149,
				image = "lbdh#lbdhbannrt",
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
					posX = 0.5002827,
					posY = 0.2568154,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.997797,
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
						etype = "Image",
						name = "srd",
						posX = 0.5,
						posY = 0.6318126,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6582549,
						sizeY = 0.291375,
						image = "lbdh#dk",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
					},
					children = {
					{
						prop = {
							etype = "EditBox",
							name = "sr",
							sizeXAB = 395.2422,
							sizeYAB = 52.46411,
							posXAB = 219.0453,
							posYAB = 21.15253,
							varName = "editBox",
							posX = 0.5075568,
							posY = 0.3305084,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9158284,
							sizeY = 0.8197518,
							color = "FFF6C07F",
							fontSize = 24,
							phText = "在此处输入兑换码",
							phColor = "FFF6C07F",
							phFontSize = 24,
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
					varName = "GetBtn",
					posX = 0.5,
					posY = 0.131477,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2573964,
					sizeY = 0.1473214,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "z4",
						varName = "GetBtnText",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.016411,
						sizeY = 0.8880838,
						text = "兑 换",
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
		{
			prop = {
				etype = "Image",
				name = "dt",
				varName = "CZSL",
				posX = 0.8814176,
				posY = 0.4978225,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2400881,
				sizeY = 1.171489,
				image = "czhd1#dt",
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "lht",
				posX = 0.9201517,
				posY = 0.553309,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4323477,
				sizeY = 1.208506,
				image = "czhdlh#lh4",
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
