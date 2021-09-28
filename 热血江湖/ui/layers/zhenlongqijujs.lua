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
				varName = "imgBK",
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
				posX = 0.461778,
				posY = 0.5152509,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6179688,
				sizeY = 0.7805555,
				image = "zlqjbj2#zlqjbj2",
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.25,
				scale9Bottom = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "kk",
					posX = 0.561215,
					posY = 0.4238144,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6878711,
					sizeY = 0.217125,
					image = "zlqj#di1",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lb",
						varName = "scroll",
						posX = 0.5,
						posY = 0.4581738,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.977987,
						sizeY = 0.8018004,
						horizontal = true,
						showScrollBar = false,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "top",
						posX = 0.5,
						posY = 1,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3914678,
						sizeY = 0.2868282,
						image = "zlqj#top",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "topz",
							posX = 0.5,
							posY = 0.4444444,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7240281,
							sizeY = 1.525356,
							text = "当前收获",
							color = "FF7D95C3",
							fontOutlineEnable = true,
							fontOutlineColor = "FF1E3D6B",
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
					etype = "RichText",
					name = "z1",
					varName = "desc",
					posX = 0.5616179,
					posY = 0.6343537,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6795015,
					sizeY = 0.1443882,
					text = "气力不足，是时候该休息了。",
					color = "FFC2E6FE",
					fontSize = 22,
					fontOutlineColor = "FF27221D",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a1",
					varName = "endBtn",
					posX = 0.5605854,
					posY = 0.1885634,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2225031,
					sizeY = 0.1120997,
					image = "zlqj#an",
					imageNormal = "zlqj#an",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "f1",
						varName = "endText",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9545952,
						sizeY = 1.147523,
						text = "就到这里",
						color = "FF613623",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FFF5D781",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "toop",
					varName = "titleIcon",
					posX = 0.5605906,
					posY = 0.79662,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3906447,
					sizeY = 0.2259787,
					image = "zlqj#wmtg",
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
