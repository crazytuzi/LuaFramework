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
			name = "zmcyt",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.5390625,
			sizeY = 0.1180556,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dj",
				varName = "showTipsBtn",
				posX = 0.4017499,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7839981,
				sizeY = 0.9111055,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "cyd",
				varName = "isHave",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.975,
				sizeY = 0.9176467,
				image = "b#chd",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "sx",
					posX = 0.5972002,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6306996,
					sizeY = 0.02564103,
					image = "b#xian",
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
				name = "txk",
				varName = "headBg",
				posX = 0.2233109,
				posY = 0.4859269,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.742029,
				sizeY = 1.505882,
				image = "ch/sbdw1",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "cktp",
					varName = "head",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2499999,
					sizeY = 0.5000001,
					image = "tianxiawudi",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "jsm",
				varName = "name_label",
				posX = 0.3633638,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.5109481,
				sizeY = 0.5280567,
				text = "棒槌一共八个汉字",
				color = "FFF1E9D7",
				fontSize = 22,
				fontOutlineEnable = true,
				fontOutlineColor = "FFA47848",
				fontOutlineSize = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xzd",
				varName = "isShow",
				posX = 0.9109424,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05652174,
				sizeY = 0.4588234,
				image = "bg2#suod",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "xzt",
				varName = "equipBtn",
				posX = 0.9004613,
				posY = 0.5000462,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1779356,
				sizeY = 0.8888889,
				disablePressScale = true,
				propagateToChildren = true,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "bt",
					varName = "btnNode",
					posX = 0.5511271,
					posY = 0.4922729,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3176528,
					sizeY = 0.3970587,
					image = "bg2#gx",
					imageNormal = "bg2#gx",
					disablePressScale = true,
					disableClick = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sxt",
				varName = "warnBg",
				posX = 0.6062575,
				posY = 0.4818443,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.09855072,
				sizeY = 0.8117644,
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
