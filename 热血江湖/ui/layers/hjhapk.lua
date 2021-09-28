--version = 1
local l_fileType = "layer"

local UIUtil = require "ui/common/UIUtil"

--EDITOR elements start tag
local eleRoot = 
{
	prop = {
		etype = "Layer",
		name = "root",
		varName = "PKLayer",
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
				varName = "PKPanel",
				posX = 0.5007802,
				posY = 0.5013853,
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
			posY = 0.5013869,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.88,
			sizeY = 0.98,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.4991073,
				posY = 0.5933846,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4102419,
				sizeY = 0.495711,
				scale9 = true,
				scale9Left = 0.41,
				scale9Right = 0.37,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "wk",
					posX = 0.5,
					posY = 0.3758372,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.02,
					sizeY = 0.8819806,
					image = "b#db5",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dk",
						posX = 0.5,
						posY = 0.4879258,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8252959,
						sizeY = 0.7169531,
						image = "b#d2",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
						scale9Top = 0.4,
						scale9Bottom = 0.4,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an3",
					varName = "btn4",
					posX = 0.5173247,
					posY = 0.5222293,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.863456,
					sizeY = 0.2887581,
					image = "pk#fwq",
					imageNormal = "pk#fwq",
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an4",
					varName = "btn3",
					posX = 0.5173247,
					posY = 0.2245629,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.863456,
					sizeY = 0.2887581,
					image = "pk#bp",
					imageNormal = "pk#bp",
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "top",
				posX = 0.4991073,
				posY = 0.7386362,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.234375,
				sizeY = 0.07369614,
				image = "chu1#top",
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "topz",
					posX = 0.5,
					posY = 0.5361786,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.5151515,
					sizeY = 0.4807693,
					image = "biaoti#msqh",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "close",
				posX = 0.6805659,
				posY = 0.7108606,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05149147,
				sizeY = 0.07936507,
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
	dk = {
		ysjm = {
			scale = {{0, {0, 0, 1}}, {150, {1.05, 1.05, 1}}, {200, {1,1,1}}, },
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
