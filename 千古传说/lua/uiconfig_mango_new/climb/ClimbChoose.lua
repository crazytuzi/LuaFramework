local t = 
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
					name = "Panel_Content",
					sizepercentx = "0",
					sizepercenty = "0",
					sizeType = "0",
					srcBlendFunc = "1",
					touchAble = "False",
					UILayoutViewModel = 
					{
						PositionX = 560,
						PositionY = 359,
						relativeToName = "Panel",
						nType = 3,
						nGravity = 6,
						nAlign = 5
					},
					uipanelviewmodel = 
					{
						Layout="Absolute",
						nType = "0"
					},
					width = "960",
					ZOrder = "1",
					components = 
					{
						
						{
							anchorPoint = "False",
							anchorPointX = "0.5",
							anchorPointY = "0.5",
							backGroundScale9Enable = "True;capInsetsX:0;capInsetsY:0;capInsetsWidth:0;capInsetsHeight:0",
							classname = "MEImage",
							dstBlendFunc = "771",
							height = "432",
							ignoreSize = "False",
							name = "Image_ClimbGoal_1",
							scaleX = "1.2",
							scaleY = "1.2",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							texturePath = "ui_new/common/bg_h.png",
							touchAble = "False",
							UILayoutViewModel = 
							{
								LeftPositon = 247,
								TopPosition = 143,
								relativeToName = "Panel",
							},
							width = "625",
							ZOrder = "1",
						},
						{
							anchorPoint = "False",
							anchorPointX = "0.5",
							anchorPointY = "0.5",
							backGroundScale9Enable = "True;capInsetsX:0;capInsetsY:0;capInsetsWidth:0;capInsetsHeight:0",
							classname = "MEImage",
							dstBlendFunc = "771",
							height = "116",
							ignoreSize = "False",
							name = "img_shengli",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							texturePath = "ui_new/climb/btn_tiaozhan_press.png",
							touchAble = "False",
							UILayoutViewModel = 
							{
								PositionY = 128,
							},
							width = "600",
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
									height = "66",
									ignoreSize = "True",
									name = "img_shengli",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									texturePath = "ui_new/climb/img_zhandou.png",
									touchAble = "False",
									UILayoutViewModel = 
									{
										PositionX = -100,
									},
									width = "359",
									ZOrder = "1",
								},
								{
									anchorPoint = "False",
									anchorPointX = "0.5",
									anchorPointY = "0.5",
									backGroundScale9Enable = "False",
									classname = "MEImage",
									dstBlendFunc = "771",
									height = "32",
									ignoreSize = "True",
									name = "img_dilu",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									texturePath = "ui_new/climb/img_wlsj.png",
									touchAble = "False",
									UILayoutViewModel = 
									{
										PositionX = 107,
										PositionY = -30,
									},
									width = "28",
									ZOrder = "1",
									components = 
									{
										
										{
											anchorPoint = "False",
											anchorPointX = "0",
											anchorPointY = "0",
											classname = "MELabel",
											ColorMixing = "#FF000000",
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
											fontSize = "26",
											fontStroke = 
											{
												IsStroke = false,
												StrokeColor = "#FFE6E6E6",
												StrokeSize = 1,
											},
											height = "26",
											IconLayout = "1",
											ignoreSize = "True",
											name = "txt_num",
											nGap = "0",
											nIconAlign = "1",
											nTextAlign = "1",
											sizepercentx = "0",
											sizepercenty = "0",
											sizeType = "0",
											srcBlendFunc = "1",
											text = "x10",
											touchAble = "False",
											touchScaleEnable = "False",
											UILayoutViewModel = 
											{
												PositionX = 18,
												PositionY = -14,
											},
											width = "39",
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
									height = "31",
									ignoreSize = "True",
									name = "img_shitou",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									texturePath = "ui_new/climb/img_wlsz.png",
									touchAble = "False",
									UILayoutViewModel = 
									{
										PositionX = 107,
									},
									width = "34",
									ZOrder = "1",
									components = 
									{
										
										{
											anchorPoint = "False",
											anchorPointX = "0",
											anchorPointY = "0",
											classname = "MELabel",
											ColorMixing = "#FF000000",
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
											fontSize = "26",
											fontStroke = 
											{
												IsStroke = false,
												StrokeColor = "#FFE6E6E6",
												StrokeSize = 1,
											},
											height = "26",
											IconLayout = "1",
											ignoreSize = "True",
											name = "txt_num",
											nGap = "0",
											nIconAlign = "1",
											nTextAlign = "1",
											sizepercentx = "0",
											sizepercenty = "0",
											sizeType = "0",
											srcBlendFunc = "1",
											text = "x1",
											touchAble = "False",
											touchScaleEnable = "False",
											UILayoutViewModel = 
											{
												PositionX = 18,
												PositionY = -14,
											},
											width = "26",
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
									height = "81",
									ignoreSize = "True",
									name = "img_shengli-Copy1",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									texturePath = "ui_new/climb/btn_gouxuan_press.png",
									touchAble = "False",
									UILayoutViewModel = 
									{
										PositionX = 236,
									},
									width = "105",
									ZOrder = "1",
								},
								{
									anchorPoint = "False",
									anchorPointX = "0.5",
									anchorPointY = "0.5",
									backGroundScale9Enable = "False",
									classname = "MEImage",
									ColorMixing = "#FFFFA500",
									dstBlendFunc = "771",
									height = "27",
									ignoreSize = "True",
									name = "Image_ClimbGoal_1",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									texturePath = "ui_new/Ys_common/name_di.png",
									touchAble = "False",
									UILayoutViewModel = 
									{
										PositionX = 130,
										PositionY = 30,
									},
									width = "111",
									ZOrder = "1",
								},
								{
									anchorPoint = "False",
									anchorPointX = "0.5",
									anchorPointY = "0.5",
									classname = "METextArea",
									ColorMixing = "#FF000000",
									dstBlendFunc = "771",
									fontName = "simhei",
									fontShadow = 
									{
										IsShadow = false,
										ShadowColor = "#FFFFFFFF",
										ShadowAlpha = 255,
										OffsetX = 0,
										OffsetY = 0,
									},
									fontSize = "26",
									fontStroke = 
									{
										IsStroke = false,
										StrokeColor = "#FFE6E6E6",
										StrokeSize = 1,
									},
									hAlignment = "0",
									height = "26",
									ignoreSize = "True",
									name = "TextArea_ClimbGoal_1",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									text = "奖励：",
									touchAble = "False",
									touchScaleEnable = "False",
									UILayoutViewModel = 
									{
										PositionX = 133,
										PositionY = 30,
									},
									vAlignment = "0",
									width = "78",
									ZOrder = "1",
								},
							},
						},
						{
							anchorPoint = "False",
							anchorPointX = "0.5",
							anchorPointY = "0.5",
							backGroundScale9Enable = "True;capInsetsX:0;capInsetsY:0;capInsetsWidth:0;capInsetsHeight:0",
							classname = "MEButton",
							ClickHighLightEnabled = "True",
							dstBlendFunc = "771",
							flipX = "False",
							flipY = "False",
							height = "116",
							ignoreSize = "False",
							name = "btn_tiaomu1",
							normal = "ui_new/mission/img_bg_cell_title.png",
							pressed = "ui_new/mission/img_bg_cell_title.png",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							touchAble = "True",
							UILayoutViewModel = 
							{
								
							},
							UItype = "Button",
							width = "600",
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
									height = "98",
									ignoreSize = "True",
									name = "img_tiaozhan1",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									texturePath = "ui_new/climb/img_tiaomu1.png",
									touchAble = "False",
									UILayoutViewModel = 
									{
										PositionX = -240,
									},
									width = "98",
									ZOrder = "1",
								},
								{
									anchorPoint = "False",
									anchorPointX = "0",
									anchorPointY = "1",
									classname = "METextArea",
									ColorMixing = "#FF000000",
									dstBlendFunc = "771",
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
									hAlignment = "0",
									height = "80",
									ignoreSize = "False",
									name = "txt_shuoming",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									text = "上阵侠客存活4个",
									touchAble = "False",
									touchScaleEnable = "False",
									UILayoutViewModel = 
									{
										PositionX = -190,
										PositionY = 40,
									},
									vAlignment = "1",
									width = "264",
									ZOrder = "1",
								},
								{
									anchorPoint = "False",
									anchorPointX = "0.5",
									anchorPointY = "0.5",
									backGroundScale9Enable = "False",
									classname = "MEImage",
									dstBlendFunc = "771",
									height = "32",
									ignoreSize = "True",
									name = "img_dilu",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									texturePath = "ui_new/climb/img_wlsj.png",
									touchAble = "False",
									UILayoutViewModel = 
									{
										PositionX = 107,
										PositionY = -30,
									},
									width = "28",
									ZOrder = "1",
									components = 
									{
										
										{
											anchorPoint = "False",
											anchorPointX = "0",
											anchorPointY = "0",
											classname = "MELabel",
											ColorMixing = "#FF000000",
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
											fontSize = "26",
											fontStroke = 
											{
												IsStroke = false,
												StrokeColor = "#FFE6E6E6",
												StrokeSize = 1,
											},
											height = "26",
											IconLayout = "1",
											ignoreSize = "True",
											name = "txt_num",
											nGap = "0",
											nIconAlign = "1",
											nTextAlign = "1",
											sizepercentx = "0",
											sizepercenty = "0",
											sizeType = "0",
											srcBlendFunc = "1",
											text = "x10",
											touchAble = "False",
											touchScaleEnable = "False",
											UILayoutViewModel = 
											{
												PositionX = 18,
												PositionY = -14,
											},
											width = "39",
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
									height = "31",
									ignoreSize = "True",
									name = "img_shitou",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									texturePath = "ui_new/climb/img_wlsz.png",
									touchAble = "False",
									UILayoutViewModel = 
									{
										PositionX = 107,
									},
									width = "34",
									ZOrder = "1",
									components = 
									{
										
										{
											anchorPoint = "False",
											anchorPointX = "0",
											anchorPointY = "0",
											classname = "MELabel",
											ColorMixing = "#FF000000",
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
											fontSize = "26",
											fontStroke = 
											{
												IsStroke = false,
												StrokeColor = "#FFE6E6E6",
												StrokeSize = 1,
											},
											height = "26",
											IconLayout = "1",
											ignoreSize = "True",
											name = "txt_num",
											nGap = "0",
											nIconAlign = "1",
											nTextAlign = "1",
											sizepercentx = "0",
											sizepercenty = "0",
											sizeType = "0",
											srcBlendFunc = "1",
											text = "x1",
											touchAble = "False",
											touchScaleEnable = "False",
											UILayoutViewModel = 
											{
												PositionX = 18,
												PositionY = -14,
											},
											width = "26",
											ZOrder = "1",
										},
									},
								},
								{
									anchorPoint = "False",
									anchorPointX = "0.5",
									anchorPointY = "0.5",
									backGroundScale9Enable = "False",
									backGroundSelectedTexture = "ui_new/climb/btn_gouxuan.png",
									backGroundTexture = "ui_new/climb/btn_gouxuan.png",
									classname = "MECheckBox",
									clickType = "0",
									dstBlendFunc = "771",
									frontCrossTexture = "ui_new/climb/btn_gouxuan_press.png",
									height = "81",
									ignoreSize = "True",
									name = "btn_xuanzhong",
									selectedState = "False",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									tableAttribute = "False",
									touchAble = "True",
									UILayoutViewModel = 
									{
										PositionX = 236,
									},
									width = "105",
									ZOrder = "1",
								},
								{
									anchorPoint = "False",
									anchorPointX = "0.5",
									anchorPointY = "0.5",
									backGroundScale9Enable = "False",
									classname = "MEImage",
									ColorMixing = "#FFFFA500",
									dstBlendFunc = "771",
									height = "27",
									ignoreSize = "True",
									name = "Image_ClimbGoal_1",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									texturePath = "ui_new/Ys_common/name_di.png",
									touchAble = "False",
									UILayoutViewModel = 
									{
										PositionX = 130,
										PositionY = 30,
									},
									width = "111",
									ZOrder = "1",
								},
								{
									anchorPoint = "False",
									anchorPointX = "0.5",
									anchorPointY = "0.5",
									classname = "METextArea",
									ColorMixing = "#FF000000",
									dstBlendFunc = "771",
									fontName = "simhei",
									fontShadow = 
									{
										IsShadow = false,
										ShadowColor = "#FFFFFFFF",
										ShadowAlpha = 255,
										OffsetX = 0,
										OffsetY = 0,
									},
									fontSize = "26",
									fontStroke = 
									{
										IsStroke = false,
										StrokeColor = "#FFE6E6E6",
										StrokeSize = 1,
									},
									hAlignment = "0",
									height = "26",
									ignoreSize = "True",
									name = "TextArea_ClimbGoal_1",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									text = "奖励：",
									touchAble = "False",
									touchScaleEnable = "False",
									UILayoutViewModel = 
									{
										PositionX = 133,
										PositionY = 30,
									},
									vAlignment = "0",
									width = "78",
									ZOrder = "1",
								},
							},
						},
						{
							anchorPoint = "False",
							anchorPointX = "0.5",
							anchorPointY = "0.5",
							backGroundScale9Enable = "True;capInsetsX:0;capInsetsY:0;capInsetsWidth:0;capInsetsHeight:0",
							classname = "MEButton",
							ClickHighLightEnabled = "True",
							dstBlendFunc = "771",
							flipX = "False",
							flipY = "False",
							height = "116",
							ignoreSize = "False",
							name = "btn_tiaomu2",
							normal = "ui_new/mission/img_bg_cell_title.png",
							pressed = "ui_new/mission/img_bg_cell_title.png",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							touchAble = "True",
							UILayoutViewModel = 
							{
								PositionY = -128,
							},
							UItype = "Button",
							width = "600",
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
									height = "98",
									ignoreSize = "True",
									name = "img_tiaozhan1",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									texturePath = "ui_new/climb/img_tiaomu2.png",
									touchAble = "False",
									UILayoutViewModel = 
									{
										PositionX = -240,
									},
									width = "98",
									ZOrder = "1",
								},
								{
									anchorPoint = "False",
									anchorPointX = "0",
									anchorPointY = "1",
									classname = "METextArea",
									ColorMixing = "#FF000000",
									dstBlendFunc = "771",
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
									hAlignment = "0",
									height = "80",
									ignoreSize = "False",
									name = "txt_shuoming",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									text = "上阵侠客存活4个",
									touchAble = "False",
									touchScaleEnable = "False",
									UILayoutViewModel = 
									{
										PositionX = -190,
										PositionY = 40,
									},
									vAlignment = "1",
									width = "264",
									ZOrder = "1",
								},
								{
									anchorPoint = "False",
									anchorPointX = "0.5",
									anchorPointY = "0.5",
									backGroundScale9Enable = "False",
									classname = "MEImage",
									dstBlendFunc = "771",
									height = "32",
									ignoreSize = "True",
									name = "img_dilu",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									texturePath = "ui_new/climb/img_wlsj.png",
									touchAble = "False",
									UILayoutViewModel = 
									{
										PositionX = 107,
										PositionY = -30,
									},
									width = "28",
									ZOrder = "1",
									components = 
									{
										
										{
											anchorPoint = "False",
											anchorPointX = "0",
											anchorPointY = "0",
											classname = "MELabel",
											ColorMixing = "#FF000000",
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
											fontSize = "26",
											fontStroke = 
											{
												IsStroke = false,
												StrokeColor = "#FFE6E6E6",
												StrokeSize = 1,
											},
											height = "26",
											IconLayout = "1",
											ignoreSize = "True",
											name = "txt_num",
											nGap = "0",
											nIconAlign = "1",
											nTextAlign = "1",
											sizepercentx = "0",
											sizepercenty = "0",
											sizeType = "0",
											srcBlendFunc = "1",
											text = "x10",
											touchAble = "False",
											touchScaleEnable = "False",
											UILayoutViewModel = 
											{
												PositionX = 18,
												PositionY = -14,
											},
											width = "39",
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
									height = "31",
									ignoreSize = "True",
									name = "img_shitou",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									texturePath = "ui_new/climb/img_wlsz.png",
									touchAble = "False",
									UILayoutViewModel = 
									{
										PositionX = 107,
									},
									width = "34",
									ZOrder = "1",
									components = 
									{
										
										{
											anchorPoint = "False",
											anchorPointX = "0",
											anchorPointY = "0",
											classname = "MELabel",
											ColorMixing = "#FF000000",
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
											fontSize = "26",
											fontStroke = 
											{
												IsStroke = false,
												StrokeColor = "#FFE6E6E6",
												StrokeSize = 1,
											},
											height = "26",
											IconLayout = "1",
											ignoreSize = "True",
											name = "txt_num",
											nGap = "0",
											nIconAlign = "1",
											nTextAlign = "1",
											sizepercentx = "0",
											sizepercenty = "0",
											sizeType = "0",
											srcBlendFunc = "1",
											text = "x1",
											touchAble = "False",
											touchScaleEnable = "False",
											UILayoutViewModel = 
											{
												PositionX = 18,
												PositionY = -14,
											},
											width = "26",
											ZOrder = "1",
										},
									},
								},
								{
									anchorPoint = "False",
									anchorPointX = "0.5",
									anchorPointY = "0.5",
									backGroundScale9Enable = "False",
									backGroundSelectedTexture = "ui_new/climb/btn_gouxuan.png",
									backGroundTexture = "ui_new/climb/btn_gouxuan.png",
									classname = "MECheckBox",
									clickType = "0",
									dstBlendFunc = "771",
									frontCrossTexture = "ui_new/climb/btn_gouxuan_press.png",
									height = "81",
									ignoreSize = "True",
									name = "btn_xuanzhong",
									selectedState = "False",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									tableAttribute = "False",
									touchAble = "True",
									UILayoutViewModel = 
									{
										PositionX = 236,
									},
									width = "105",
									ZOrder = "1",
								},
								{
									anchorPoint = "False",
									anchorPointX = "0.5",
									anchorPointY = "0.5",
									backGroundScale9Enable = "False",
									classname = "MEImage",
									ColorMixing = "#FFFFA500",
									dstBlendFunc = "771",
									height = "27",
									ignoreSize = "True",
									name = "Image_ClimbGoal_1",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									texturePath = "ui_new/Ys_common/name_di.png",
									touchAble = "False",
									UILayoutViewModel = 
									{
										PositionX = 130,
										PositionY = 30,
									},
									width = "111",
									ZOrder = "1",
								},
								{
									anchorPoint = "False",
									anchorPointX = "0.5",
									anchorPointY = "0.5",
									classname = "METextArea",
									ColorMixing = "#FF000000",
									dstBlendFunc = "771",
									fontName = "simhei",
									fontShadow = 
									{
										IsShadow = false,
										ShadowColor = "#FFFFFFFF",
										ShadowAlpha = 255,
										OffsetX = 0,
										OffsetY = 0,
									},
									fontSize = "26",
									fontStroke = 
									{
										IsStroke = false,
										StrokeColor = "#FFE6E6E6",
										StrokeSize = 1,
									},
									hAlignment = "0",
									height = "26",
									ignoreSize = "True",
									name = "TextArea_ClimbGoal_1",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									text = "奖励：",
									touchAble = "False",
									touchScaleEnable = "False",
									UILayoutViewModel = 
									{
										PositionX = 133,
										PositionY = 30,
									},
									vAlignment = "0",
									width = "78",
									ZOrder = "1",
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
							height = "44",
							ignoreSize = "True",
							name = "btn_qiehuan",
							normal = "ui_new/climb/btn_qiehuan.png",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							touchAble = "True",
							UILayoutViewModel = 
							{
								PositionX = -235,
								PositionY = -248,
							},
							UItype = "Button",
							width = "129",
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
									height = "24",
									ignoreSize = "True",
									name = "img_tu",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									texturePath = "ui_new/climb/bg_txt.png",
									touchAble = "False",
									UILayoutViewModel = 
									{
										PositionX = 1,
										PositionY = -38,
									},
									width = "142",
									ZOrder = "1",
								},
								{
									anchorPoint = "False",
									anchorPointX = "0.5",
									anchorPointY = "0.5",
									backGroundScale9Enable = "False",
									classname = "MEImage",
									dstBlendFunc = "771",
									height = "47",
									ignoreSize = "True",
									name = "img_res_icon",
									scaleX = "0.8",
									scaleY = "0.8",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									texturePath = "ui_new/common/xx_yuanbao_icon.png",
									touchAble = "False",
									UILayoutViewModel = 
									{
										PositionX = -54,
										PositionY = -38,
									},
									width = "46",
									ZOrder = "1",
								},
								{
									anchorPoint = "False",
									anchorPointX = "1",
									anchorPointY = "0.5",
									classname = "MELabel",
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
									name = "txt_price",
									nGap = "0",
									nIconAlign = "1",
									nTextAlign = "1",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									text = "10000",
									touchAble = "False",
									touchScaleEnable = "False",
									UILayoutViewModel = 
									{
										PositionX = 60,
										PositionY = -38,
									},
									width = "60",
									ZOrder = "1",
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
							height = "44",
							ignoreSize = "True",
							name = "btn_kaishi",
							normal = "ui_new/climb/btn_kaishi.png",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							touchAble = "True",
							UILayoutViewModel = 
							{
								PositionX = 235,
								PositionY = -248,
							},
							UItype = "Button",
							width = "129",
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
							height = "194",
							ignoreSize = "True",
							name = "btn_close",
							normal = "ui_new/common/common_close2_icon.png",
							scaleX = "0.8",
							scaleY = "0.8",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							touchAble = "True",
							UILayoutViewModel = 
							{
								PositionX = 342,
								PositionY = 188,
							},
							UItype = "Button",
							width = "75",
							ZOrder = "1",
						},
					},
				},
			},
		},
	},
	actions = 
	{
		Action0 = 
		{
			name = "Action0",
			FPS = 24,
			duration = 0.21,
			looptimes = 1,
			autoplay = false,
			{
				id = "btn_tiaomu1_Panel_Content_Panel-ClimbChoose_Group_beiku_climb_Game",
				name = "Panel.Panel_Content.btn_tiaomu1",
				frames = 
				{
					
					{
						alpha = 255,
						color = 
						{
							r=255,
							g=255,
							b=255,
							 a=255,
						},
						dstBlendFunc = 771,
						frame = 0,
						percentenable = false,
						perposition = 
						{
							x=0,
							y=2.81,
						},
						position = 
						{
							x=0,
							y=18,
						},
						rotate = 0,
						scale = 
						{
							x=1,
							y=1,
						},
						srcBlendFunc = 1,
						tweenToNext = true,
						visible = true,
					},
					{
						alpha = 255,
						color = 
						{
							r=255,
							g=255,
							b=255,
							 a=255,
						},
						dstBlendFunc = 771,
						frame = 2,
						percentenable = false,
						perposition = 
						{
							x=-9.78,
							y=2.81,
						},
						position = 
						{
							x=20,
							y=18,
						},
						rotate = 0,
						scale = 
						{
							x=1,
							y=1,
						},
						srcBlendFunc = 1,
						tweenToNext = true,
						visible = true,
					},
					{
						alpha = 255,
						color = 
						{
							r=255,
							g=255,
							b=255,
							 a=255,
						},
						dstBlendFunc = 771,
						frame = 4,
						percentenable = false,
						perposition = 
						{
							x=-97.81,
							y=2.81,
						},
						position = 
						{
							x=-939,
							y=18,
						},
						rotate = 0,
						scale = 
						{
							x=1,
							y=1,
						},
						srcBlendFunc = 1,
						tweenToNext = true,
						visible = true,
					},
				},
			},
			{
				id = "btn_tiaomu2_Panel_Content_Panel-ClimbChoose_Group_beiku_climb_Game",
				name = "Panel.Panel_Content.btn_tiaomu2",
				frames = 
				{
					
					{
						alpha = 255,
						color = 
						{
							r=255,
							g=255,
							b=255,
							 a=255,
						},
						dstBlendFunc = 771,
						frame = 0,
						percentenable = false,
						perposition = 
						{
							x=0,
							y=-19.37,
						},
						position = 
						{
							x=0,
							y=-124,
						},
						rotate = 0,
						scale = 
						{
							x=1,
							y=1,
						},
						srcBlendFunc = 1,
						tweenToNext = true,
						visible = true,
					},
					{
						alpha = 255,
						color = 
						{
							r=255,
							g=255,
							b=255,
							 a=255,
						},
						dstBlendFunc = 771,
						frame = 1,
						percentenable = false,
						perposition = 
						{
							x=0,
							y=-19.37,
						},
						position = 
						{
							x=0,
							y=-124,
						},
						rotate = 0,
						scale = 
						{
							x=1,
							y=1,
						},
						srcBlendFunc = 1,
						tweenToNext = true,
						visible = true,
					},
					{
						alpha = 255,
						color = 
						{
							r=255,
							g=255,
							b=255,
							 a=255,
						},
						dstBlendFunc = 771,
						frame = 3,
						percentenable = false,
						perposition = 
						{
							x=3.13,
							y=-17.97,
						},
						position = 
						{
							x=20,
							y=-124,
						},
						rotate = 0,
						scale = 
						{
							x=1,
							y=1,
						},
						srcBlendFunc = 1,
						tweenToNext = true,
						visible = true,
					},
					{
						alpha = 255,
						color = 
						{
							r=255,
							g=255,
							b=255,
							 a=255,
						},
						dstBlendFunc = 771,
						frame = 5,
						percentenable = false,
						perposition = 
						{
							x=-99.58,
							y=-19.37,
						},
						position = 
						{
							x=-956,
							y=-124,
						},
						rotate = 0,
						scale = 
						{
							x=1,
							y=1,
						},
						srcBlendFunc = 1,
						tweenToNext = true,
						visible = true,
					},
				},
			},
		},
		Action1 = 
		{
			name = "Action1",
			FPS = 24,
			duration = 0.29,
			looptimes = 1,
			autoplay = false,
			{
				id = "btn_tiaomu1_Panel_Content_Panel-ClimbChoose_Group_beiku_climb_Game",
				name = "Panel.Panel_Content.btn_tiaomu1",
				frames = 
				{
					
					{
						alpha = 255,
						color = 
						{
							r=255,
							g=255,
							b=255,
							 a=255,
						},
						dstBlendFunc = 771,
						frame = 0,
						percentenable = false,
						perposition = 
						{
							x=0,
							y=2.81,
						},
						position = 
						{
							x=990,
							y=18,
						},
						rotate = 0,
						scale = 
						{
							x=1,
							y=1,
						},
						srcBlendFunc = 1,
						tweenToNext = true,
						visible = true,
					},
					{
						alpha = 255,
						color = 
						{
							r=255,
							g=255,
							b=255,
							 a=255,
						},
						dstBlendFunc = 771,
						frame = 2,
						percentenable = false,
						perposition = 
						{
							x=0,
							y=2.81,
						},
						position = 
						{
							x=-20,
							y=18,
						},
						rotate = 0,
						scale = 
						{
							x=1,
							y=1,
						},
						srcBlendFunc = 1,
						tweenToNext = true,
						visible = true,
					},
					{
						alpha = 255,
						color = 
						{
							r=255,
							g=255,
							b=255,
							 a=255,
						},
						dstBlendFunc = 771,
						frame = 4,
						percentenable = false,
						perposition = 
						{
							x=0,
							y=2.81,
						},
						position = 
						{
							x=10,
							y=18,
						},
						rotate = 0,
						scale = 
						{
							x=1,
							y=1,
						},
						srcBlendFunc = 1,
						tweenToNext = true,
						visible = true,
					},
					{
						alpha = 255,
						color = 
						{
							r=255,
							g=255,
							b=255,
							 a=255,
						},
						dstBlendFunc = 771,
						frame = 6,
						percentenable = false,
						perposition = 
						{
							x=0,
							y=2.81,
						},
						position = 
						{
							x=0,
							y=18,
						},
						rotate = 0,
						scale = 
						{
							x=1,
							y=1,
						},
						srcBlendFunc = 1,
						tweenToNext = true,
						visible = true,
					},
				},
			},
			{
				id = "btn_tiaomu2_Panel_Content_Panel-ClimbChoose_Group_beiku_climb_Game",
				name = "Panel.Panel_Content.btn_tiaomu2",
				frames = 
				{
					
					{
						alpha = 255,
						color = 
						{
							r=255,
							g=255,
							b=255,
							 a=255,
						},
						dstBlendFunc = 771,
						frame = 1,
						percentenable = false,
						perposition = 
						{
							x=0,
							y=-19.37,
						},
						position = 
						{
							x=990,
							y=-124,
						},
						rotate = 0,
						scale = 
						{
							x=1,
							y=1,
						},
						srcBlendFunc = 1,
						tweenToNext = true,
						visible = true,
					},
					{
						alpha = 255,
						color = 
						{
							r=255,
							g=255,
							b=255,
							 a=255,
						},
						dstBlendFunc = 771,
						frame = 3,
						percentenable = false,
						perposition = 
						{
							x=103.13,
							y=-19.37,
						},
						position = 
						{
							x=-20,
							y=-124,
						},
						rotate = 0,
						scale = 
						{
							x=1,
							y=1,
						},
						srcBlendFunc = 1,
						tweenToNext = true,
						visible = true,
					},
					{
						alpha = 255,
						color = 
						{
							r=255,
							g=255,
							b=255,
							 a=255,
						},
						dstBlendFunc = 771,
						frame = 5,
						percentenable = false,
						perposition = 
						{
							x=103.13,
							y=-19.37,
						},
						position = 
						{
							x=10,
							y=-124,
						},
						rotate = 0,
						scale = 
						{
							x=1,
							y=1,
						},
						srcBlendFunc = 1,
						tweenToNext = true,
						visible = true,
					},
					{
						alpha = 255,
						color = 
						{
							r=255,
							g=255,
							b=255,
							 a=255,
						},
						dstBlendFunc = 771,
						frame = 7,
						percentenable = false,
						perposition = 
						{
							x=1.04,
							y=-19.37,
						},
						position = 
						{
							x=0,
							y=-124,
						},
						rotate = 0,
						scale = 
						{
							x=1,
							y=1,
						},
						srcBlendFunc = 1,
						tweenToNext = true,
						visible = true,
					},
				},
			},
		},
	},
	respaths = 
	{
		textures = 
		{
			"ui_new/common/bg_h.png",
			"ui_new/climb/btn_tiaozhan_press.png",
			"ui_new/climb/img_zhandou.png",
			"ui_new/climb/img_wlsj.png",
			"ui_new/climb/img_wlsz.png",
			"ui_new/climb/btn_gouxuan_press.png",
			"ui_new/Ys_common/name_di.png",
			"ui_new/mission/img_bg_cell_title.png",
			"ui_new/climb/img_tiaomu1.png",
			"ui_new/climb/btn_gouxuan.png",
			"ui_new/climb/img_tiaomu2.png",
			"ui_new/climb/btn_qiehuan.png",
			"ui_new/climb/bg_txt.png",
			"ui_new/common/xx_yuanbao_icon.png",
			"ui_new/climb/btn_kaishi.png",
			"ui_new/common/common_close2_icon.png",
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

