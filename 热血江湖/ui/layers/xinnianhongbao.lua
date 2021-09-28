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
				varName = "closeBtn",
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
				posY = 0.4902777,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7757813,
				sizeY = 1.041667,
				image = "jsj#dt",
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "gb",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					effect = "close",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
					roundButton = true,
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "kk1",
					varName = "kk1",
					posX = 0.5,
					posY = 0.4913747,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9999999,
					sizeY = 0.9601052,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "an1",
						varName = "getBtn",
						posX = 0.5,
						posY = 0.2704231,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1792548,
						sizeY = 0.09860028,
						image = "jsj#an",
						imageNormal = "jsj#an",
						disablePressScale = true,
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "znz",
							posX = 0.5,
							posY = 0.506135,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 0.8918369,
							sizeY = 0.5276888,
							color = "FFF1E9D7",
							fontSize = 24,
							fontOutlineEnable = true,
							fontOutlineColor = "FF99320F",
							fontOutlineSize = 2,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Sprite3D",
						name = "mx",
						varName = "model",
						posX = -0.01630951,
						posY = 0.02966541,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3221862,
						sizeY = 0.8500016,
					},
				},
				{
					prop = {
						etype = "RichText",
						name = "mswz",
						varName = "desc",
						posX = 0.4999743,
						posY = 0.6065393,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.5453597,
						sizeY = 0.2777306,
						color = "FFFFFF80",
						fontSize = 24,
						hTextAlign = 1,
						vTextAlign = 1,
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
	dk = {
		ysjm = {
			scale = {{0, {0.3, 0.3, 1}}, {150, {1.05, 1.05, 1}}, {200, {1,1,1}}, },
		},
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
