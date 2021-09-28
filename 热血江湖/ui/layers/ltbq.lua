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
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dd",
				posX = 0.7480498,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5039004,
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
			sizeX = 0.88,
			sizeY = 0.98,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dn",
				posX = 0.7057701,
				posY = 0.6196356,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4282054,
				sizeY = 0.4599993,
				image = "b#cs",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.2,
				scale9Bottom = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dt2",
					posX = 0.5,
					posY = 0.6450832,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8969666,
					sizeY = 0.5803404,
					scale9 = true,
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "das",
						posX = 0.578449,
						posY = 0.1524204,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.151087,
						sizeY = 1.470555,
						image = "hua1#hua1",
					},
				},
				{
					prop = {
						etype = "Grid",
						name = "bq",
						varName = "root1",
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
							name = "da4",
							posX = 0.4999996,
							posY = 0.2576669,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.026529,
							sizeY = 0.8692272,
							image = "b#d2",
							scale9 = true,
							scale9Left = 0.4,
							scale9Right = 0.4,
							scale9Top = 0.4,
							scale9Bottom = 0.4,
						},
					},
					{
						prop = {
							etype = "Scroll",
							name = "lb2",
							varName = "bqScroll",
							posX = 0.4999996,
							posY = 0.2603291,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9796143,
							sizeY = 0.8426985,
						},
					},
					{
						prop = {
							etype = "Scroll",
							name = "hx",
							varName = "emoji_scroll",
							posX = 0.3738626,
							posY = 0.8805043,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7545928,
							sizeY = 0.3822381,
							horizontal = true,
							showScrollBar = false,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "yxq",
							varName = "valid",
							posX = 0.7099869,
							posY = 0.7596002,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6,
							sizeY = 0.25,
							text = "有效期：888天",
							color = "FF966856",
							fontSize = 18,
							hTextAlign = 2,
							vTextAlign = 1,
							wordSpaceAdd = -2,
						},
					},
					},
				},
				{
					prop = {
						etype = "Grid",
						name = "zb",
						varName = "root2",
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
							name = "da3",
							posX = 0.4999996,
							posY = 0.4204833,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.026529,
							sizeY = 1.19486,
							image = "b#d2",
							scale9 = true,
							scale9Left = 0.4,
							scale9Right = 0.4,
							scale9Top = 0.4,
							scale9Bottom = 0.4,
						},
					},
					{
						prop = {
							etype = "Scroll",
							name = "lb3",
							varName = "equipScroll",
							posX = 0.4999996,
							posY = 0.4193463,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9796143,
							sizeY = 1.160733,
						},
					},
					},
				},
				{
					prop = {
						etype = "Grid",
						name = "cyhf",
						varName = "root3",
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
							name = "da2",
							posX = 0.4999996,
							posY = 0.4204833,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.026529,
							sizeY = 1.19486,
							image = "b#d2",
							scale9 = true,
							scale9Left = 0.4,
							scale9Right = 0.4,
							scale9Top = 0.4,
							scale9Bottom = 0.4,
						},
					},
					{
						prop = {
							etype = "Scroll",
							name = "lb4",
							varName = "cyScroll",
							posX = 0.4999998,
							posY = 0.4193463,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9796143,
							sizeY = 1.160733,
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb1",
					varName = "scroll",
					posX = 0.5,
					posY = 0.1421756,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9142277,
					sizeY = 0.2754665,
					horizontal = true,
					showScrollBar = false,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "close",
				posX = 0.8985007,
				posY = 0.8144633,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05770596,
				sizeY = 0.08928571,
				image = "baishi#x",
				imageNormal = "baishi#x",
				soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
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
