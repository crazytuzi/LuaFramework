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
			sizeX = 0.9032026,
			sizeY = 0.9026825,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.63316,
				sizeY = 0.8,
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
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.322412,
					sizeY = 1.142428,
					image = "hjhafx#fxdt",
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.2,
					scale9Bottom = 0.7,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "d5",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6615368,
						sizeY = 0.7895632,
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
						scale9Top = 0.4,
						scale9Bottom = 0.4,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "hua",
						posX = 0.9127587,
						posY = 0.5553023,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1716897,
						sizeY = 0.6402863,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "tp3",
							posX = 0.60899,
							posY = 0.4999963,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.2119153,
							sizeY = 1.056755,
							image = "hjhafx#zs2",
						},
					},
					{
						prop = {
							etype = "Button",
							name = "a1",
							varName = "peacePage",
							posX = 0.61511,
							posY = 0.6912448,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.5843726,
							sizeY = 0.2772267,
							image = "hjhafx#hpfx2",
							imageNormal = "hjhafx#hpfx2",
							imagePressed = "hjhafx#hpfx1",
							imageDisable = "hjhafx#hpfx2",
							disablePressScale = true,
							soundEffectClick = "audio/rxjh/UI/anniu.ogg",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "yz",
								posX = 0.499558,
								posY = 0.5000002,
								anchorX = 0.5,
								anchorY = 0.5,
								visible = false,
								sizeX = 0.3136712,
								sizeY = 0.8094339,
								color = "FFEBC6B4",
								fontSize = 22,
								fontOutlineColor = "FF51361C",
								fontOutlineSize = 2,
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						{
							prop = {
								etype = "Image",
								name = "tp2",
								varName = "peaceIcon",
								posX = 0.4905685,
								posY = -0.04811542,
								anchorX = 0.5,
								anchorY = 0.5,
								visible = false,
								sizeX = 0.8584907,
								sizeY = 0.9901959,
							},
						},
						},
					},
					{
						prop = {
							etype = "Button",
							name = "a2",
							varName = "fightPage",
							posX = 0.61511,
							posY = 0.3666922,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.5843726,
							sizeY = 0.2772267,
							image = "hjhafx#zdfx2",
							imageNormal = "hjhafx#zdfx2",
							imagePressed = "hjhafx#zdfx1",
							imageDisable = "hjhafx#zdfx2",
							disablePressScale = true,
							soundEffectClick = "audio/rxjh/UI/anniu.ogg",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "yz2",
								posX = 0.499558,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.3136712,
								sizeY = 0.8094339,
								color = "FFEBC6B4",
								fontSize = 22,
								fontOutlineColor = "FF51361C",
								fontOutlineSize = 2,
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						{
							prop = {
								etype = "Image",
								name = "tp1",
								varName = "fightIcon",
								posX = 0.4905689,
								posY = 0.2358291,
								anchorX = 0.5,
								anchorY = 0.5,
								visible = false,
								sizeX = 0.8584906,
								sizeY = 0.9901959,
							},
						},
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb",
					varName = "scroll",
					posX = 0.5545542,
					posY = 0.4951993,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7746878,
					sizeY = 0.7238872,
					showScrollBar = false,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "closeBtn",
				posX = 0.7922282,
				posY = 0.8087978,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.04584381,
				sizeY = 0.08154707,
				image = "feisheng#gb",
				imageNormal = "feisheng#gb",
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
			scale = {{0, {0.3, 0.3, 1}}, {150, {1.1, 1.1, 1}}, {200, {1,1,1}}, },
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
