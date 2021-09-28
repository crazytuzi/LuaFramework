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
				name = "cjsl",
				varName = "CjSl",
				posX = 0.5,
				posY = 0.4928946,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 1.018377,
				sizeY = 1.018377,
				image = "hhsw#hhsw",
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "cz",
					varName = "chongzhi",
					posX = 0.2793112,
					posY = 0.1488403,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.287218,
					sizeY = 0.1425059,
					image = "czan#czan",
					imageNormal = "czan#czan",
					disablePressScale = true,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wza",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7838668,
						sizeY = 0.780164,
						text = "储 值",
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
					etype = "Sprite3D",
					name = "mx",
					varName = "model",
					posX = 0.7460746,
					posY = 0.155604,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3575825,
					sizeY = 0.800006,
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
