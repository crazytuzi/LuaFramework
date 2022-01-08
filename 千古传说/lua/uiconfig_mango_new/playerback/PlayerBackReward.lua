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
			sizepercentx = "100",
			sizepercenty = "100",
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
					backGroundScale9Enable = "True;capInsetsX:0;capInsetsY:0;capInsetsWidth:0;capInsetsHeight:0",
					classname = "MEImage",
					dstBlendFunc = "771",
					height = "364",
					ignoreSize = "False",
					name = "bg",
					sizepercentx = "0",
					sizepercenty = "0",
					sizeType = "0",
					srcBlendFunc = "1",
					texturePath = "ui_new/common/bg_h.png",
					touchAble = "False",
					UILayoutViewModel = 
					{
						PositionX = 480,
						PositionY = 320,
						relativeToName = "Panel",
						nType = 3,
						nGravity = 6,
						nAlign = 5
					},
					width = "486",
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
							height = "68",
							ignoreSize = "False",
							name = "bg_title",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							texturePath = "ui_new/common/bg_biaoti2.png",
							touchAble = "False",
							UILayoutViewModel = 
							{
								PositionY = 168,
							},
							width = "490",
							ZOrder = "1",
						},
						{
							anchorPoint = "False",
							anchorPointX = "0.5",
							anchorPointY = "0.5",
							backGroundScale9Enable = "False",
							classname = "MEImage",
							dstBlendFunc = "771",
							height = "63",
							ignoreSize = "True",
							name = "img_wenben",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							texturePath = "ui_new/back/img_zhjl.png",
							touchAble = "False",
							UILayoutViewModel = 
							{
								PositionY = 168,
								LeftPositon = -97,
								TopPosition = 388,
								relativeToName = "Panel",
							},
							width = "200",
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
							height = "70",
							ignoreSize = "True",
							name = "btn_ok",
							normal = "ui_new/rolebook/btn_queding.png",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							touchAble = "True",
							UILayoutViewModel = 
							{
								PositionY = -76,
							},
							UItype = "Button",
							width = "156",
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
							height = "74",
							HitType = 
							{
								nHitType = 2,
								nRadius = 100,
							},
							ignoreSize = "True",
							name = "btn_close",
							normal = "ui_new/common/common_close2_icon.png",
							scaleX = "0.9",
							scaleY = "0.9",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							touchAble = "True",
							UILayoutViewModel = 
							{
								PositionX = 211,
								PositionY = 170,
								LeftPositon = 240,
								TopPosition = 382,
								relativeToName = "Panel",
							},
							UItype = "Button",
							width = "72",
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
							name = "img_di1",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							texturePath = "ui_new/qiyu/yqm_shurukuang.png",
							touchAble = "False",
							UILayoutViewModel = 
							{
								PositionY = 38,
								LeftPositon = 458,
								TopPosition = 124,
								relativeToName = "Panel",
							},
							width = "350",
							ZOrder = "1",
							components = 
							{
								
								{
									anchorPoint = "False",
									anchorPointX = "0.5",
									anchorPointY = "0.5",
									classname = "MELabel",
									ColorMixing = "#00FFFFFF",
									compPath = "luacomponents.common.MEIconLabel",
									dstBlendFunc = "771",
									FontColor = "#FF808080",
									fontName = "simhei",
									fontShadow = 
									{
										IsShadow = false,
										ShadowColor = "#FFFFFFFF",
										ShadowAlpha = 255,
										OffsetX = 0,
										OffsetY = 0,
									},
									fontSize = "30",
									fontStroke = 
									{
										IsStroke = false,
										StrokeColor = "#FFE6E6E6",
										StrokeSize = 1,
									},
									height = "30",
									IconLayout = "1",
									ignoreSize = "True",
									name = "txt_inviteddesc",
									nGap = "0",
									nIconAlign = "1",
									nTextAlign = "1",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									text = "请输入好友邀请码",
									touchAble = "False",
									touchScaleEnable = "False",
									UILayoutViewModel = 
									{
										LeftPositon = -48,
										TopPosition = 497,
										relativeToName = "Panel",
									},
									width = "240",
									ZOrder = "1",
								},
								{
									anchorPoint = "False",
									anchorPointX = "0.5",
									anchorPointY = "0.5",
									classname = "METextField",
									ColorMixing = "#FF000000",
									CursorEnabled = "True",
									dstBlendFunc = "771",
									fontName = "simhei",
									fontSize = "32",
									hAlignment = "0",
									height = "0",
									HitType = 
									{
										nHitType = 1,
										nXpos = -155,
										nYpos = -30,
										nHitWidth = 350,
										nHitHeight = 60
									},
									ignoreSize = "False",
									KeyBoradType = "0",
									maxLengthEnable = "False",
									name = "txt_shurukuang1",
									passwordEnable = "False",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "770",
									touchAble = "False",
									UILayoutViewModel = 
									{
										PositionX = -21,
										PositionY = 1,
										LeftPositon = 477,
										TopPosition = 136,
									},
									vAlignment = "0",
									width = "0",
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
							height = "40",
							ignoreSize = "True",
							name = "img_res_icon",
							scaleX = "0.7",
							scaleY = "0.7",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							texturePath = "ui_new/common/xx_yuanbao_icon.png",
							touchAble = "False",
							UILayoutViewModel = 
							{
								PositionX = 48,
								PositionY = -125,
							},
							width = "53",
							ZOrder = "1",
						},
						{
							anchorPoint = "False",
							anchorPointX = "0",
							anchorPointY = "0",
							classname = "MELabel",
							compPath = "luacomponents.common.MEIconLabel",
							dstBlendFunc = "771",
							FontColor = "#FF3D3D3D",
							fontName = "simhei",
							fontShadow = 
							{
								IsShadow = false,
								ShadowColor = "#FFFFFFFF",
								ShadowAlpha = 255,
								OffsetX = 0,
								OffsetY = 0,
							},
							fontSize = "20",
							fontStroke = 
							{
								IsStroke = false,
								StrokeColor = "#FFE6E6E6",
								StrokeSize = 1,
							},
							height = "20",
							IconLayout = "1",
							ignoreSize = "True",
							name = "txt_huode",
							nGap = "0",
							nIconAlign = "1",
							nTextAlign = "1",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							text = "成功输入可获得",
							touchAble = "False",
							touchScaleEnable = "False",
							UILayoutViewModel = 
							{
								PositionX = -113,
								PositionY = -136,
							},
							width = "140",
							ZOrder = "1",
							components = 
							{
								
								{
									anchorPoint = "False",
									anchorPointX = "0",
									anchorPointY = "0",
									classname = "MELabel",
									compPath = "luacomponents.common.MEIconLabel",
									dstBlendFunc = "771",
									FontColor = "#FF3D3D3D",
									fontName = "simhei",
									fontShadow = 
									{
										IsShadow = false,
										ShadowColor = "#FFFFFFFF",
										ShadowAlpha = 255,
										OffsetX = 0,
										OffsetY = 0,
									},
									fontSize = "20",
									fontStroke = 
									{
										IsStroke = false,
										StrokeColor = "#FFE6E6E6",
										StrokeSize = 1,
									},
									height = "20",
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
									text = "x100",
									touchAble = "False",
									touchScaleEnable = "False",
									UILayoutViewModel = 
									{
										PositionX = 182,
										PositionY = -1,
									},
									width = "40",
									ZOrder = "1",
								},
							},
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
			"ui_new/common/bg_h.png",
			"ui_new/common/bg_biaoti2.png",
			"ui_new/back/img_zhjl.png",
			"ui_new/rolebook/btn_queding.png",
			"ui_new/common/common_close2_icon.png",
			"ui_new/qiyu/yqm_shurukuang.png",
			"ui_new/common/xx_yuanbao_icon.png",
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

