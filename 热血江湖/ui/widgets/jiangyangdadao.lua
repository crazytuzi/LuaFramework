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
				name = "bjt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9023438,
				sizeY = 0.9722222,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "bjt2",
					posX = 0.6133745,
					posY = 0.4542848,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.673593,
					sizeY = 0.8128572,
					image = "jyddd#jyddd",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jianghukz",
				posX = 0.6031446,
				posY = 0.4502654,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6337768,
				sizeY = 0.8343711,
				image = "a",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Scroll",
					name = "lb",
					varName = "scroll",
					posX = 0.5,
					posY = 0.47319,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9292203,
					sizeY = 0.6680677,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tp",
					varName = "diamondRoot",
					posX = 0.7224538,
					posY = 0.09032056,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.216524,
					sizeY = 0.1183719,
					image = "dl#g",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "yb",
						varName = "diamondIcon",
						posX = 0.3007415,
						posY = 0.5000001,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2846543,
						sizeY = 0.7031203,
						image = "tb#yuanbao",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "sz",
							varName = "diamondTxt",
							posX = 1.807742,
							posY = 0.4865211,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.738115,
							sizeY = 0.7961738,
							text = "x555",
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "suo",
							posX = 0.6596374,
							posY = 0.3402534,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.5599999,
							sizeY = 0.56,
							image = "tb#suo",
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "sx",
					varName = "refreshBtn",
					posX = 0.867969,
					posY = 0.08453593,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.17874,
					sizeY = 0.09155265,
					image = "chu1#an1",
					imageNormal = "chu1#an1",
					disablePressScale = true,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "xzz",
						posX = 0.5,
						posY = 0.5363636,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.766323,
						sizeY = 0.9986905,
						text = "刷 新",
						fontSize = 22,
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
				etype = "Button",
				name = "ba",
				varName = "helpBtn",
				posX = 0.9338424,
				posY = 0.1075652,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05,
				sizeY = 0.0875,
				image = "tong#bz",
				imageNormal = "tong#bz",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
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
