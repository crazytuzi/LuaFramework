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
			sizeX = 1,
			sizeY = 1,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.500693,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6349576,
				sizeY = 0.7279713,
				image = "b#jzd",
				scale9 = true,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Grid",
					name = "k1",
					posX = 0.5,
					posY = 0.4923684,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.001397,
					sizeY = 0.8689771,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "czsl",
						varName = "CZSL",
						posX = 0.5,
						posY = 0.489022,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 1,
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
							name = "hdd",
							posX = 0.5073722,
							posY = 0.840081,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.927386,
							sizeY = 0.3455704,
							image = "czt#hddt2",
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "smd",
								posX = 0.7280532,
								posY = 0.7890065,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.5038083,
								sizeY = 0.3755935,
								image = "d#smd3",
							},
							children = {
							{
								prop = {
									etype = "Label",
									name = "wb10",
									posX = 0.3487615,
									posY = 0.5,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.4564617,
									sizeY = 0.7248285,
									text = "累积线上时间：",
									color = "FF5E006F",
									fontSize = 22,
									fontOutlineEnable = true,
									fontOutlineColor = "FFFDE2FF",
									fontOutlineSize = 2,
									vTextAlign = 1,
								},
							},
							{
								prop = {
									etype = "Label",
									name = "wb11",
									varName = "ActivitiesTime",
									posX = 0.7711417,
									posY = 0.4999996,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.4314432,
									sizeY = 0.7248285,
									text = "800分钟",
									color = "FF5E006F",
									fontSize = 22,
									fontOutlineEnable = true,
									fontOutlineColor = "FFFDE2FF",
									fontOutlineSize = 2,
									vTextAlign = 1,
								},
							},
							},
						},
						{
							prop = {
								etype = "Image",
								name = "topt",
								posX = 0.8516335,
								posY = 0.3901579,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.2424541,
								sizeY = 0.324025,
								image = "czt#zaixianlingjiang",
							},
						},
						{
							prop = {
								etype = "Label",
								name = "wb13",
								varName = "ActivitiesTitle",
								posX = 0.5251141,
								posY = 0.2159147,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.3955753,
								sizeY = 0.4061177,
								fontSize = 24,
								fontOutlineEnable = true,
								fontOutlineColor = "FF00335D",
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "lbk4",
							posX = 0.5,
							posY = 0.3780716,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.926128,
							sizeY = 0.7214705,
							image = "h#d3",
							scale9 = true,
							scale9Left = 0.3,
							scale9Right = 0.3,
							scale9Top = 0.3,
							scale9Bottom = 0.3,
							alpha = 0.7,
						},
						children = {
						{
							prop = {
								etype = "Scroll",
								name = "lb4",
								varName = "ExchangeGiftList",
								posX = 0.5,
								posY = 0.4995568,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1,
								sizeY = 0.9664534,
							},
						},
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
				etype = "Image",
				name = "top",
				posX = 0.5,
				posY = 0.881868,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.38125,
				sizeY = 0.1083333,
				image = "jz#top3",
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tz",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.147541,
					sizeY = 0.371795,
					image = "jz#lj",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jzz",
				posX = 0.1742221,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.07734375,
				sizeY = 0.8291667,
				image = "jz#jz1",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jzz2",
				posX = 0.794006,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.09296875,
				sizeY = 0.8291667,
				image = "jz#jz2",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "closeBtn",
				posX = 0.8172993,
				posY = 0.8351973,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.04453125,
				sizeY = 0.1069444,
				image = "ty#gb2",
				imageNormal = "ty#gb2",
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
