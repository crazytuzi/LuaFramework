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
			height = "640",
			ignoreSize = "False",
			name = "Panel",
			PanelRelativeSizeModel = 
			{
				PanelRelativeEnable = true,
			},
			sizepercentx = "0",
			sizepercenty = "0",
			sizeType = "0",
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
					anchorPointX = "0.5",
					anchorPointY = "0.5",
					backGroundScale9Enable = "False",
					classname = "MEImage",
					dstBlendFunc = "771",
					height = "64",
					ignoreSize = "True",
					name = "Image_sevenDaysLayer_1",
					sizepercentx = "0",
					sizepercenty = "0",
					sizeType = "0",
					srcBlendFunc = "770",
					texturePath = "ui_new/sevendays/七日福利2.png",
					touchAble = "False",
					UILayoutViewModel = 
					{
						PositionX = 483,
						PositionY = 316,
						LeftPositon = 451,
						TopPosition = 292,
						relativeToName = "Panel",
						nType = 3,
					},
					visible = "False",
					width = "64",
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
					height = "58",
					ignoreSize = "True",
					name = "btn_close",
					normal = "ui_new/common/xx_fanhui_btn.png",
					sizepercentx = "0",
					sizepercenty = "0",
					sizeType = "0",
					srcBlendFunc = "1",
					touchAble = "True",
					UILayoutViewModel = 
					{
						PositionX = 52,
						PositionY = 599,
						LeftPositon = 2,
						TopPosition = 12,
						relativeToName = "Panel",
						nType = 3,
					},
					UItype = "Button",
					width = "100",
					ZOrder = "4",
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
					height = "640",
					ignoreSize = "False",
					name = "panel_content",
					sizepercentx = "0",
					sizepercenty = "0",
					sizeType = "0",
					srcBlendFunc = "1",
					touchAble = "False",
					UILayoutViewModel = 
					{
						PositionX = -89,
						PositionY = 5,
						TopPosition = -5,
						relativeToName = "Panel",
						nType = 3,
						nGravity = 6,
						nAlign = 2
					},
					uipanelviewmodel = 
					{
						Layout="Absolute",
						nType = "0"
					},
					width = "1138",
					ZOrder = "1",
					components = 
					{
						
						{
							anchorPoint = "False",
							anchorPointX = "0.5",
							anchorPointY = "0",
							backGroundScale9Enable = "False",
							classname = "MEImage",
							dstBlendFunc = "771",
							height = "609",
							ignoreSize = "True",
							name = "Img_bg",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							texturePath = "ui_new/Ys_common/7day_di.png",
							touchAble = "False",
							UILayoutViewModel = 
							{
								PositionX = 571,
								PositionY = 1,
								LeftPositon = 175,
								TopPosition = 93,
								relativeToName = "Panel",
							},
							width = "1136",
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
							height = "620",
							ignoreSize = "False",
							name = "Panel_day",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							touchAble = "False",
							UILayoutViewModel = 
							{
								PositionX = -2,
								PositionY = 4,
								TopPosition = 98,
								relativeToName = "Panel",
							},
							uipanelviewmodel = 
							{
								Layout="Absolute",
								nType = "0"
							},
							width = "190",
							ZOrder = "1",
							components = 
							{
								
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
									height = "99",
									ignoreSize = "True",
									name = "btn_day1",
									normal = "ui_new/sevendays/tab1.png",
									pressed = "ui_new/sevendays/tab1b.png",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									touchAble = "True",
									UILayoutViewModel = 
									{
										PositionX = 206,
										PositionY = 497,
									},
									UItype = "Button",
									width = "108",
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
									height = "130",
									ignoreSize = "True",
									name = "btn_day2",
									normal = "ui_new/sevendays/tab2.png",
									pressed = "ui_new/sevendays/tab2b.png",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									touchAble = "True",
									UILayoutViewModel = 
									{
										PositionX = 322,
										PositionY = 503,
									},
									UItype = "Button",
									width = "123",
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
									height = "131",
									ignoreSize = "True",
									name = "btn_day3",
									normal = "ui_new/sevendays/tab3.png",
									pressed = "ui_new/sevendays/tab3b.png",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									touchAble = "True",
									UILayoutViewModel = 
									{
										PositionX = 448,
										PositionY = 503,
									},
									UItype = "Button",
									width = "123",
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
									height = "99",
									ignoreSize = "True",
									name = "btn_day4",
									normal = "ui_new/sevendays/tab4.png",
									pressed = "ui_new/sevendays/tab4b.png",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									touchAble = "True",
									UILayoutViewModel = 
									{
										PositionX = 572,
										PositionY = 497,
									},
									UItype = "Button",
									width = "108",
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
									height = "99",
									ignoreSize = "True",
									name = "btn_day5",
									normal = "ui_new/sevendays/tab5.png",
									pressed = "ui_new/sevendays/tab5b.png",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									touchAble = "True",
									UILayoutViewModel = 
									{
										PositionX = 690,
										PositionY = 497,
									},
									UItype = "Button",
									width = "108",
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
									height = "99",
									ignoreSize = "True",
									name = "btn_day6",
									normal = "ui_new/sevendays/tab6.png",
									pressed = "ui_new/sevendays/tab6b.png",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									touchAble = "True",
									UILayoutViewModel = 
									{
										PositionX = 808,
										PositionY = 497,
									},
									UItype = "Button",
									width = "108",
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
									height = "130",
									ignoreSize = "True",
									name = "btn_day7",
									normal = "ui_new/sevendays/tab7.png",
									pressed = "ui_new/sevendays/tab7b.png",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									touchAble = "True",
									UILayoutViewModel = 
									{
										PositionX = 929,
										PositionY = 503,
									},
									UItype = "Button",
									width = "123",
									ZOrder = "1",
								},
							},
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
							height = "433",
							ignoreSize = "False",
							name = "Panel_title",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							touchAble = "False",
							UILayoutViewModel = 
							{
								PositionX = 161,
								PositionY = 18,
							},
							uipanelviewmodel = 
							{
								Layout="Absolute",
								nType = "0"
							},
							width = "167",
							ZOrder = "1",
						},
						{
							anchorPoint = "False",
							anchorPointX = "0.5",
							anchorPointY = "0.5",
							backGroundScale9Enable = "False",
							classname = "MEImage",
							dstBlendFunc = "771",
							height = "4",
							ignoreSize = "True",
							name = "img_line",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "770",
							texturePath = "ui_new/sevendays/bg_tabxian.png",
							touchAble = "False",
							UILayoutViewModel = 
							{
								PositionX = 569,
								PositionY = 523,
								relativeToName = "Panel",
							},
							visible = "False",
							width = "762",
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
							height = "399",
							ignoreSize = "False",
							name = "Panel_Area",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							touchAble = "False",
							UILayoutViewModel = 
							{
								PositionX = 353,
								PositionY = 33,
								relativeToName = "Panel",
							},
							uipanelviewmodel = 
							{
								Layout="Absolute",
								nType = "0"
							},
							width = "636",
							ZOrder = "1",
						},
						{
							anchorPoint = "False",
							anchorPointX = "0.5",
							anchorPointY = "0.5",
							backGroundScale9Enable = "True;capInsetsX:0;capInsetsY:0;capInsetsWidth:0;capInsetsHeight:0",
							classname = "MEImage",
							dstBlendFunc = "771",
							height = "37",
							ignoreSize = "False",
							name = "Image_sevenDaysLayer_1",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							texturePath = "ui_new/array/js-renshu.png",
							touchAble = "False",
							UILayoutViewModel = 
							{
								PositionX = 569,
								PositionY = 610,
							},
							width = "330",
							ZOrder = "1",
						},
						{
							anchorPoint = "False",
							anchorPointX = "0",
							anchorPointY = "0",
							classname = "MELabel",
							compPath = "luacomponents.common.MEIconLabel",
							dstBlendFunc = "771",
							FontColor = "#FF000000",
							fontName = "simhei",
							fontShadow = 
							{
								IsShadow = false,
								ShadowColor = "#FFFFFFFF",
								ShadowAlpha = 255,
								OffsetX = 0,
								OffsetY = 0,
							},
							fontSize = "22",
							fontStroke = 
							{
								IsStroke = false,
								StrokeColor = "#FFE6E6E6",
								StrokeSize = 1,
							},
							height = "22",
							IconLayout = "1",
							ignoreSize = "True",
							name = "txt_timedesc",
							nGap = "0",
							nIconAlign = "1",
							nTextAlign = "1",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							text = "离活动结束:",
							touchAble = "False",
							touchScaleEnable = "False",
							UILayoutViewModel = 
							{
								PositionX = 417,
								PositionY = 599,
							},
							width = "121",
							ZOrder = "1",
						},
						{
							anchorPoint = "False",
							anchorPointX = "0",
							anchorPointY = "0",
							classname = "MELabel",
							compPath = "luacomponents.common.MEIconLabel",
							dstBlendFunc = "771",
							FontColor = "#FFBA492F",
							fontName = "simhei",
							fontShadow = 
							{
								IsShadow = false,
								ShadowColor = "#FFFFFFFF",
								ShadowAlpha = 255,
								OffsetX = 0,
								OffsetY = 0,
							},
							fontSize = "22",
							fontStroke = 
							{
								IsStroke = false,
								StrokeColor = "#FFE6E6E6",
								StrokeSize = 1,
							},
							height = "22",
							IconLayout = "1",
							ignoreSize = "True",
							name = "txt_timecount",
							nGap = "0",
							nIconAlign = "1",
							nTextAlign = "1",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							text = "X天X小时X分钟X秒",
							touchAble = "False",
							touchScaleEnable = "False",
							UILayoutViewModel = 
							{
								PositionX = 545,
								PositionY = 599,
							},
							width = "176",
							ZOrder = "1",
						},
						{
							anchorPoint = "False",
							anchorPointX = "0.5",
							anchorPointY = "0.5",
							backGroundScale9Enable = "False",
							classname = "MEImage",
							dstBlendFunc = "771",
							height = "50",
							ignoreSize = "True",
							name = "Image_sevenDaysLayer_2",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							texturePath = "ui_new/Ys_common/7day_tiao.png",
							touchAble = "False",
							UILayoutViewModel = 
							{
								PositionX = 570,
								PositionY = 27,
								LeftPositon = 1,
								TopPosition = 583,
								relativeToName = "Panel",
							},
							width = "961",
							ZOrder = "2",
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
					height = "74",
					ignoreSize = "True",
					name = "btn_title",
					normal = "ui_new/sevendays/stab1.png",
					pressed = "ui_new/sevendays/stab1b.png",
					sizepercentx = "0",
					sizepercenty = "0",
					sizeType = "0",
					srcBlendFunc = "1",
					touchAble = "True",
					UILayoutViewModel = 
					{
						PositionX = 329,
						PositionY = 679,
						LeftPositon = 246,
						TopPosition = -76,
						relativeToName = "Panel",
						nType = 3,
					},
					UItype = "Button",
					width = "166",
					ZOrder = "1",
					components = 
					{
						
						{
							anchorPoint = "False",
							anchorPointX = "0.5",
							anchorPointY = "0.5",
							classname = "MELabel",
							compPath = "luacomponents.common.MEIconLabel",
							dstBlendFunc = "771",
							FontColor = "#FF000000",
							fontName = "simhei",
							fontShadow = 
							{
								IsShadow = false,
								ShadowColor = "#FFFFFFFF",
								ShadowAlpha = 255,
								OffsetX = 0,
								OffsetY = 0,
							},
							fontSize = "24",
							fontStroke = 
							{
								IsStroke = false,
								StrokeColor = "#FFE6E6E6",
								StrokeSize = 1,
							},
							height = "24",
							IconLayout = "1",
							ignoreSize = "True",
							name = "txt_title",
							nGap = "0",
							nIconAlign = "1",
							nTextAlign = "1",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							text = "已完成(11)",
							touchAble = "False",
							touchScaleEnable = "False",
							UILayoutViewModel = 
							{
								PositionY = -7,
							},
							width = "120",
							ZOrder = "1",
						},
						{
							anchorPoint = "False",
							anchorPointX = "0.5",
							anchorPointY = "0.5",
							backGroundScale9Enable = "False",
							classname = "MEImage",
							dstBlendFunc = "771",
							height = "48",
							ignoreSize = "True",
							name = "img_yuzhui",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							texturePath = "ui_new/Ys_common/yuzhui.png",
							touchAble = "False",
							UILayoutViewModel = 
							{
								PositionX = -1,
								PositionY = -53,
							},
							width = "24",
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
			"ui_new/sevendays/七日福利2.png",
			"ui_new/common/xx_fanhui_btn.png",
			"ui_new/Ys_common/7day_di.png",
			"ui_new/sevendays/tab1b.png",
			"ui_new/sevendays/tab1.png",
			"ui_new/sevendays/tab2b.png",
			"ui_new/sevendays/tab2.png",
			"ui_new/sevendays/tab3b.png",
			"ui_new/sevendays/tab3.png",
			"ui_new/sevendays/tab4b.png",
			"ui_new/sevendays/tab4.png",
			"ui_new/sevendays/tab5b.png",
			"ui_new/sevendays/tab5.png",
			"ui_new/sevendays/tab6b.png",
			"ui_new/sevendays/tab6.png",
			"ui_new/sevendays/tab7b.png",
			"ui_new/sevendays/tab7.png",
			"ui_new/sevendays/bg_tabxian.png",
			"ui_new/array/js-renshu.png",
			"ui_new/Ys_common/7day_tiao.png",
			"ui_new/sevendays/stab1b.png",
			"ui_new/sevendays/stab1.png",
			"ui_new/Ys_common/yuzhui.png",
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

