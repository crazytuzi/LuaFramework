﻿local t = 
{
	version = 1,
	components = 
	{
		
		{
			anchorPoint = "False",
			anchorPointX = "0",
			anchorPointY = "0",
			backGroundScale9Enable = "False",
			bgColorOpacity = "50",
			bIsOpenClipping = "False",
			classname = "MEPanel",
			colorType = "0;SingleColor:#FFE6E6E6;GraduallyChangingColorStart:#FFFFFFFF;GraduallyChangingColorEnd:#FFFFFFFF;vectorX:0;vectorY:0",
			DesignHeight = "640",
			DesignType = "0",
			DesignWidth = "960",
			dstBlendFunc = "771",
			height = "64",
			ignoreSize = "False",
			name = "Panel",
			sizepercentx = "100",
			sizepercenty = "100",
			sizeType = "1",
			srcBlendFunc = "1",
			touchAble = "False",
			UILayoutViewModel = 
			{
				nType = 3,
			},
			uipanelviewmodel = 
			{
				Layout="Relative",
				nType = "3"
			},
			width = "960",
			ZOrder = "1",
			components = 
			{
				
				{
					anchorPoint = "False",
					anchorPointX = "0",
					anchorPointY = "0",
					backGroundScale9Enable = "False",
					bgColorOpacity = "50",
					bIsOpenClipping = "False",
					classname = "MEPanel",
					colorType = "0;SingleColor:#FFE6E6E6;GraduallyChangingColorStart:#00000000;GraduallyChangingColorEnd:#00000000;vectorX:0;vectorY:0",
					DesignHeight = "640",
					DesignType = "0",
					DesignWidth = "960",
					dstBlendFunc = "771",
					height = "64",
					ignoreSize = "False",
					name = "panel_head",
					sizepercentx = "100",
					sizepercenty = "100",
					sizeType = "1",
					srcBlendFunc = "1",
					touchAble = "False",
					UILayoutViewModel = 
					{
						relativeToName = "Panel",
						nType = 3,
						nGravity = 6,
						nAlign = 2
					},
					uipanelviewmodel = 
					{
						Layout="Relative",
						nType = "3"
					},
					width = "960",
					ZOrder = "1",
					components = 
					{
						
						{
							anchorPoint = "False",
							anchorPointX = "0.5",
							anchorPointY = "0.5",
							backGroundScale9Enable = "False",
							classname = "MEImage",
							dstBlendFunc = "771",
							height = "69",
							ignoreSize = "True",
							name = "img_bg",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							texturePath = "ui_new/common/bg_top_bar.png",
							touchAble = "False",
							UILayoutViewModel = 
							{
								PositionX = 480,
								PositionY = 605,
								relativeToName = "panel_head",
								nType = 3,
								nGravity = 6,
								nAlign = 2
							},
							width = "1129",
							ZOrder = "1",
							components = 
							{
								
								{
									anchorPoint = "False",
									anchorPointX = "0.5",
									anchorPointY = "0.5",
									backGroundScale9Enable = "False",
									classname = "MEImage",
									dstBlendFunc = "771",
									height = "64",
									ignoreSize = "True",
									name = "img_title",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									texturePath = "ui_new/common/xx_jsxl_title.png",
									touchAble = "False",
									UILayoutViewModel = 
									{
										PositionX = -240,
										PositionY = -4,
										LeftPositon = 103,
										relativeToName = "panel_head",
									},
									width = "64",
									ZOrder = "1",
								},
								{
									anchorPoint = "False",
									anchorPointX = "0.5",
									anchorPointY = "0.5",
									backGroundScale9Enable = "False",
									classname = "MEImage",
									dstBlendFunc = "771",
									height = "36",
									ignoreSize = "True",
									name = "img_res_bg_1",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									texturePath = "ui_new/common/bg_res.png",
									touchAble = "False",
									UILayoutViewModel = 
									{
										PositionX = -205,
										PositionY = -2,
										RightPosition = 511,
										TopPosition = 19,
										relativeToName = "panel_head",
										nGravity = 3,
										nAlign = 3
									},
									width = "181",
									ZOrder = "1",
									components = 
									{
										
										{
											anchorPoint = "False",
											anchorPointX = "0.5",
											anchorPointY = "0.5",
											backGroundScale9Enable = "False",
											classname = "MEImage",
											dstBlendFunc = "771",
											height = "45",
											ignoreSize = "True",
											name = "img_res_icon_1",
											sizepercentx = "0",
											sizepercenty = "0",
											sizeType = "0",
											srcBlendFunc = "1",
											texturePath = "ui_new/common/icon_coin.png",
											touchAble = "False",
											UILayoutViewModel = 
											{
												PositionX = -86,
												PositionY = 1,
											},
											width = "44",
											ZOrder = "1",
										},
										{
											anchorPoint = "False",
											anchorPointX = "1",
											anchorPointY = "0.5",
											classname = "MELabel",
											ColorMixing = "#FFF0F8FF",
											compPath = "luacomponents.common.MEIconLabel",
											dstBlendFunc = "771",
											FontColor = "#FFFFFFFF",
											fontName = "simhei",
											fontShadow = 
											{
												IsShadow = false,
												ShadowColor = "#FFFFFFFF",
												ShadowAlpha = 255,
												OffsetX = 0,
												OffsetY = 0,
											},
											fontSize = "28",
											fontStroke = 
											{
												IsStroke = false,
												StrokeColor = "#FFE6E6E6",
												StrokeSize = 1,
											},
											height = "28",
											IconLayout = "1",
											ignoreSize = "True",
											name = "txt_number_1",
											nGap = "0",
											nIconAlign = "1",
											nTextAlign = "1",
											sizepercentx = "0",
											sizepercenty = "0",
											sizeType = "0",
											srcBlendFunc = "1",
											text = "555555",
											touchAble = "False",
											touchScaleEnable = "False",
											UILayoutViewModel = 
											{
												PositionX = 40,
											},
											width = "84",
											ZOrder = "1",
										},
										{
											anchorPoint = "False",
											anchorPointX = "0.5",
											anchorPointY = "0.5",
											backGroundScale9Enable = "False",
											classname = "MEButton",
											ClickHighLightEnabled = "True",
											dstBlendFunc = "771",
											flipX = "False",
											flipY = "False",
											height = "29",
											HitType = 
											{
												nHitType = 1,
												nXpos = -140,
												nYpos = -5,
												nHitWidth = 176,
												nHitHeight = 37
											},
											ignoreSize = "True",
											name = "btn_add_1",
											normal = "ui_new/common/add.png",
											sizepercentx = "0",
											sizepercenty = "0",
											sizeType = "0",
											srcBlendFunc = "1",
											touchAble = "True",
											UILayoutViewModel = 
											{
												PositionX = 68,
											},
											UItype = "Button",
											width = "27",
											ZOrder = "1",
										},
									},
								},
								{
									anchorPoint = "False",
									anchorPointX = "0.5",
									anchorPointY = "0.5",
									backGroundScale9Enable = "False",
									classname = "MEImage",
									dstBlendFunc = "771",
									height = "36",
									ignoreSize = "True",
									name = "img_res_bg_2",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									texturePath = "ui_new/common/bg_res.png",
									touchAble = "False",
									UILayoutViewModel = 
									{
										PositionY = -2,
										RightPosition = 305,
										TopPosition = 19,
										relativeToName = "panel_head",
										nGravity = 3,
										nAlign = 3
									},
									width = "181",
									ZOrder = "1",
									components = 
									{
										
										{
											anchorPoint = "False",
											anchorPointX = "0.5",
											anchorPointY = "0.5",
											backGroundScale9Enable = "False",
											classname = "MEImage",
											dstBlendFunc = "771",
											height = "45",
											ignoreSize = "True",
											name = "img_res_icon_2",
											sizepercentx = "0",
											sizepercenty = "0",
											sizeType = "0",
											srcBlendFunc = "1",
											texturePath = "ui_new/common/icon_coin.png",
											touchAble = "False",
											UILayoutViewModel = 
											{
												PositionX = -90,
												PositionY = 2,
											},
											width = "44",
											ZOrder = "1",
										},
										{
											anchorPoint = "False",
											anchorPointX = "1",
											anchorPointY = "0.5",
											classname = "MELabel",
											ColorMixing = "#FFF0F8FF",
											compPath = "luacomponents.common.MEIconLabel",
											dstBlendFunc = "771",
											FontColor = "#FFFFFFFF",
											fontName = "simhei",
											fontShadow = 
											{
												IsShadow = false,
												ShadowColor = "#FFFFFFFF",
												ShadowAlpha = 255,
												OffsetX = 0,
												OffsetY = 0,
											},
											fontSize = "28",
											fontStroke = 
											{
												IsStroke = false,
												StrokeColor = "#FFE6E6E6",
												StrokeSize = 1,
											},
											height = "28",
											IconLayout = "1",
											ignoreSize = "True",
											name = "txt_number_2",
											nGap = "0",
											nIconAlign = "1",
											nTextAlign = "1",
											sizepercentx = "0",
											sizepercenty = "0",
											sizeType = "0",
											srcBlendFunc = "1",
											text = "555555",
											touchAble = "False",
											touchScaleEnable = "False",
											UILayoutViewModel = 
											{
												PositionX = 40,
											},
											width = "84",
											ZOrder = "1",
										},
										{
											anchorPoint = "False",
											anchorPointX = "0.5",
											anchorPointY = "0.5",
											backGroundScale9Enable = "False",
											classname = "MEButton",
											ClickHighLightEnabled = "True",
											dstBlendFunc = "771",
											flipX = "False",
											flipY = "False",
											height = "29",
											HitType = 
											{
												nHitType = 1,
												nXpos = -143,
												nYpos = -4,
												nHitWidth = 177,
												nHitHeight = 36
											},
											ignoreSize = "True",
											name = "btn_add_2",
											normal = "ui_new/common/add.png",
											sizepercentx = "0",
											sizepercenty = "0",
											sizeType = "0",
											srcBlendFunc = "1",
											touchAble = "True",
											UILayoutViewModel = 
											{
												PositionX = 69,
											},
											UItype = "Button",
											width = "27",
											ZOrder = "1",
										},
									},
								},
								{
									anchorPoint = "False",
									anchorPointX = "0.5",
									anchorPointY = "0.5",
									backGroundScale9Enable = "False",
									classname = "MEImage",
									dstBlendFunc = "771",
									height = "36",
									ignoreSize = "True",
									name = "img_res_bg_3",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									texturePath = "ui_new/common/bg_res.png",
									touchAble = "False",
									UILayoutViewModel = 
									{
										PositionX = 208,
										PositionY = -1,
										RightPosition = 97,
										TopPosition = 18,
										relativeToName = "panel_head",
										nGravity = 3,
										nAlign = 3
									},
									width = "181",
									ZOrder = "1",
									components = 
									{
										
										{
											anchorPoint = "False",
											anchorPointX = "0.5",
											anchorPointY = "0.5",
											backGroundScale9Enable = "False",
											classname = "MEImage",
											dstBlendFunc = "771",
											height = "45",
											ignoreSize = "True",
											name = "img_res_icon_3",
											sizepercentx = "0",
											sizepercenty = "0",
											sizeType = "0",
											srcBlendFunc = "1",
											texturePath = "ui_new/common/icon_coin.png",
											touchAble = "False",
											UILayoutViewModel = 
											{
												PositionX = -90,
												PositionY = 1,
											},
											width = "44",
											ZOrder = "1",
										},
										{
											anchorPoint = "False",
											anchorPointX = "1",
											anchorPointY = "0.5",
											classname = "MELabel",
											ColorMixing = "#FFF0F8FF",
											compPath = "luacomponents.common.MEIconLabel",
											dstBlendFunc = "771",
											FontColor = "#FFFFFFFF",
											fontName = "simhei",
											fontShadow = 
											{
												IsShadow = false,
												ShadowColor = "#FFFFFFFF",
												ShadowAlpha = 255,
												OffsetX = 0,
												OffsetY = 0,
											},
											fontSize = "28",
											fontStroke = 
											{
												IsStroke = false,
												StrokeColor = "#FFE6E6E6",
												StrokeSize = 1,
											},
											height = "28",
											IconLayout = "1",
											ignoreSize = "True",
											name = "txt_number_3",
											nGap = "0",
											nIconAlign = "1",
											nTextAlign = "1",
											sizepercentx = "0",
											sizepercenty = "0",
											sizeType = "0",
											srcBlendFunc = "1",
											text = "888888",
											touchAble = "False",
											touchScaleEnable = "False",
											UILayoutViewModel = 
											{
												PositionX = 47,
											},
											width = "84",
											ZOrder = "1",
										},
										{
											anchorPoint = "False",
											anchorPointX = "0.5",
											anchorPointY = "0.5",
											backGroundScale9Enable = "False",
											classname = "MEButton",
											ClickHighLightEnabled = "True",
											dstBlendFunc = "771",
											flipX = "False",
											flipY = "False",
											height = "29",
											HitType = 
											{
												nHitType = 1,
												nXpos = -142,
												nYpos = -4,
												nHitWidth = 179,
												nHitHeight = 35
											},
											ignoreSize = "True",
											name = "btn_add_3",
											normal = "ui_new/common/add.png",
											sizepercentx = "0",
											sizepercenty = "0",
											sizeType = "0",
											srcBlendFunc = "1",
											touchAble = "True",
											UILayoutViewModel = 
											{
												PositionX = 66,
												PositionY = 1,
											},
											UItype = "Button",
											width = "27",
											ZOrder = "1",
										},
									},
								},
							},
						},
						{
							anchorPoint = "False",
							anchorPointX = "0.5",
							anchorPointY = "0.5",
							backGroundScale9Enable = "False",
							classname = "MEButton",
							ClickHighLightEnabled = "True",
							dstBlendFunc = "771",
							flipX = "False",
							flipY = "False",
							height = "58",
							HitType = 
							{
								nHitType = 1,
								nXpos = -2,
								nYpos = -2,
								nHitWidth = 103,
								nHitHeight = 62
							},
							ignoreSize = "True",
							name = "btn_return",
							normal = "ui_new/common/xx_fanhui_btn.png",
							pressed = "ui_new/common/xx_fanhui_btn.png",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							touchAble = "True",
							UILayoutViewModel = 
							{
								PositionX = 52,
								PositionY = 586,
								LeftPositon = 2,
								TopPosition = 25,
								relativeToName = "panel_head",
								nType = 3,
							},
							UItype = "Button",
							width = "100",
							ZOrder = "1",
						},
						{
							anchorPoint = "False",
							anchorPointX = "0.5",
							anchorPointY = "0.5",
							backGroundScale9Enable = "False",
							classname = "MEButton",
							ClickHighLightEnabled = "True",
							dstBlendFunc = "771",
							flipX = "False",
							flipY = "False",
							height = "73",
							ignoreSize = "True",
							name = "btn_chat",
							normal = "ui_new/common/chat.png",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							touchAble = "True",
							UILayoutViewModel = 
							{
								PositionX = 908,
								PositionY = 578,
								RightPosition = 16,
								TopPosition = 25,
								relativeToName = "panel_head",
								nType = 3,
								nGravity = 3,
								nAlign = 3
							},
							UItype = "Button",
							width = "72",
							ZOrder = "1",
						},
						{
							anchorPoint = "False",
							anchorPointX = "0",
							anchorPointY = "0",
							backGroundScale9Enable = "False",
							bgColorOpacity = "50",
							bIsOpenClipping = "False",
							classname = "MEPanel",
							colorType = "0;SingleColor:#FFE6E6E6;GraduallyChangingColorStart:#FFFFFFFF;GraduallyChangingColorEnd:#FFFFFFFF;vectorX:0;vectorY:0",
							DesignHeight = "640",
							DesignType = "0",
							DesignWidth = "960",
							dstBlendFunc = "771",
							height = "0",
							ignoreSize = "False",
							name = "panel_block",
							sizepercentx = "100",
							sizepercenty = "0",
							sizeType = "1",
							srcBlendFunc = "1",
							touchAble = "False",
							UILayoutViewModel = 
							{
								PositionY = 640,
								relativeToName = "panel_head",
								nType = 3,
							},
							uipanelviewmodel = 
							{
								Layout="Absolute",
								nType = "0"
							},
							width = "960",
							ZOrder = "1",
						},
					},
				},
			},
		},
	},
	actions = 
	{
		
	},
	respaths = 
	{
		textures = 
		{
			"ui_new/common/bg_top_bar.png",
			"ui_new/common/xx_jsxl_title.png",
			"ui_new/common/bg_res.png",
			"ui_new/common/icon_coin.png",
			"ui_new/common/add.png",
			"ui_new/common/xx_fanhui_btn.png",
			"ui_new/common/chat.png",
		},
		armatures = 
		{
			
		},
		movieclips = 
		{
			
		},
	},
}
return t

