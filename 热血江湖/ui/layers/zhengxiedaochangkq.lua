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
				varName = "bg",
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
				posY = 0.4791665,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7929688,
				sizeY = 0.8055556,
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "kk2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					image = "b#db1",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "zs1",
						posX = 0.02057244,
						posY = 0.1628659,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.05421687,
						sizeY = 0.3755943,
						image = "zhu#zs1",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zs2",
						posX = 0.9442027,
						posY = 0.1851488,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1592083,
						sizeY = 0.4057052,
						image = "zhu#zs2",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "db2",
						posX = 0.5,
						posY = 0.4921793,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9363168,
						sizeY = 0.959002,
						image = "b#db3",
						scale9 = true,
						scale9Left = 0.47,
						scale9Right = 0.47,
					},
				},
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "kk1",
					varName = "email_info",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9999999,
					sizeY = 0.9601052,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "g2",
						posX = 0.6608639,
						posY = 0.5537426,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5419355,
						sizeY = 0.7850897,
						image = "b#d3",
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
							name = "bj",
							varName = "cartoon",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6416276,
							sizeY = 0.8549783,
						},
					},
					{
						prop = {
							etype = "Grid",
							name = "kkk1",
							varName = "emailDesc",
							posX = 0.4991493,
							posY = 0.4956102,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.979108,
							sizeY = 0.995095,
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "zsd",
								posX = 0.5,
								posY = 0.1317849,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1.01336,
								sizeY = 0.2524179,
								image = "d2#dw1",
								scale9 = true,
								scale9Left = 0.4,
								scale9Right = 0.4,
							},
							children = {
							{
								prop = {
									etype = "Scroll",
									name = "lbt",
									varName = "itemScroll",
									posX = 0.5016524,
									posY = 0.5,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.9484782,
									sizeY = 0.8272648,
									horizontal = true,
									showScrollBar = false,
								},
							},
							{
								prop = {
									etype = "Image",
									name = "tops",
									posX = 0.5,
									posY = 1,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.3408042,
									sizeY = 0.3278323,
									image = "chu1#top2",
								},
								children = {
								{
									prop = {
										etype = "Label",
										name = "wz3",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 0.9550098,
										sizeY = 1.635144,
										text = "活动奖励",
										color = "FFF1E9D7",
										fontOutlineEnable = true,
										fontOutlineColor = "FFA47848",
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
								etype = "Label",
								name = "wz1",
								varName = "fromNameTitle",
								posX = 0.201807,
								posY = 0.8463468,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.2624294,
								sizeY = 0.1053487,
								text = "参加条件：",
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
								etype = "Label",
								name = "wz2",
								varName = "fromName",
								posX = 0.647182,
								posY = 0.8463468,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.676514,
								sizeY = 0.1554175,
								text = "达成二转",
								color = "FFC76F34",
								fontSize = 22,
								vTextAlign = 1,
							},
						},
						{
							prop = {
								etype = "Button",
								name = "an1",
								varName = "ok",
								posX = 0.5,
								posY = -0.09466664,
								anchorX = 0.5,
								anchorY = 0.5,
								lockHV = true,
								sizeX = 0.2937056,
								sizeY = 0.1379179,
								image = "chu1#an2",
								imageNormal = "chu1#an2",
								soundEffectClick = "audio/rxjh/UI/anniu.ogg",
							},
							children = {
							{
								prop = {
									etype = "Label",
									name = "j1",
									varName = "getWord",
									posX = 0.5,
									posY = 0.5,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.9322476,
									sizeY = 1.09296,
									text = "确 定",
									fontOutlineEnable = true,
									fontOutlineColor = "FF347468",
									fontOutlineSize = 2,
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
				{
					prop = {
						etype = "Image",
						name = "g1",
						posX = 0.203251,
						posY = 0.5314623,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3044335,
						sizeY = 0.8296505,
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
						scale9Top = 0.4,
						scale9Bottom = 0.4,
						alpha = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "dw1",
							posX = 0.487796,
							posY = 0.466367,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.750073,
							sizeY = 0.6926407,
							image = "d2#dw2",
							scale9 = true,
							scale9Left = 0.4,
							scale9Right = 0.4,
							scale9Top = 0.4,
							scale9Bottom = 0.4,
							rotation = 270,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "wf",
							varName = "des",
							posX = 0.5,
							posY = 0.01378644,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8999664,
							sizeY = 0.25,
							text = "正派玩家与邪派玩家互为对手，一决高下",
							color = "FF966856",
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
		{
			prop = {
				etype = "Image",
				name = "top",
				posX = 0.5,
				posY = 0.8751824,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.20625,
				sizeY = 0.07222223,
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
					posY = 0.4996001,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3143939,
					sizeY = 0.4807692,
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
