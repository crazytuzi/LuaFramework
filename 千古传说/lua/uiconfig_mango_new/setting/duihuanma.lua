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
			sizepercentx = "0",
			sizepercenty = "0",
			sizeType = "0",
			srcBlendFunc = "1",
			touchAble = "False",
			UILayoutViewModel = 
			{
				
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
					backGroundScale9Enable = "False",
					classname = "MEImage",
					dstBlendFunc = "771",
					height = "431",
					ignoreSize = "True",
					name = "bg",
					sizepercentx = "51",
					sizepercenty = "35",
					sizeType = "0",
					srcBlendFunc = "1",
					texturePath = "ui_new/common/bg_h.png",
					touchAble = "False",
					UILayoutViewModel = 
					{
						PositionX = 480,
						PositionY = 480,
					},
					width = "625",
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
					normal = "ui_new/common/common_close_icon.png",
					sizepercentx = "0",
					sizepercenty = "0",
					sizeType = "0",
					srcBlendFunc = "1",
					touchAble = "True",
					UILayoutViewModel = 
					{
						PositionX = 769,
						PositionY = 607,
					},
					UItype = "Button",
					width = "75",
					ZOrder = "3",
				},
				{
					anchorPoint = "False",
					anchorPointX = "0",
					anchorPointY = "0",
					classname = "MELabel",
					ColorMixing = "#00FFFFFF",
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
					name = "Test",
					nGap = "0",
					nIconAlign = "1",
					nTextAlign = "1",
					sizepercentx = "0",
					sizepercenty = "0",
					sizeType = "0",
					srcBlendFunc = "1",
					text = "请输入兑换码：",
					touchAble = "False",
					touchScaleEnable = "False",
					UILayoutViewModel = 
					{
						PositionX = 257,
						PositionY = 557,
					},
					width = "168",
					ZOrder = "1",
				},
				{
					anchorPoint = "False",
					anchorPointX = "0",
					anchorPointY = "0.5",
					backGroundScale9Enable = "False",
					classname = "MEImage",
					dstBlendFunc = "771",
					height = "50",
					ignoreSize = "False",
					name = "img_input_bg",
					sizepercentx = "0",
					sizepercenty = "0",
					sizeType = "0",
					srcBlendFunc = "1",
					texturePath = "ui_new/chat/input.png",
					touchAble = "True",
					UILayoutViewModel = 
					{
						PositionX = 260,
						PositionY = 523,
					},
					width = "440",
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
							height = "88",
							ignoreSize = "True",
							name = "bg_niantie",
							normal = "ui_new/qiyu/btn_niantie.png",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							touchAble = "True",
							UILayoutViewModel = 
							{
								PositionX = 145,
								PositionY = 47,
							},
							UItype = "Button",
							width = "120",
							ZOrder = "1",
						},
					},
				},
				{
					anchorPoint = "False",
					anchorPointX = "0",
					anchorPointY = "0.5",
					classname = "METextField",
					ColorMixing = "#FF000000",
					CursorEnabled = "True",
					dstBlendFunc = "771",
					fontName = "simhei",
					fontSize = "30",
					hAlignment = "1",
					height = "36",
					ignoreSize = "False",
					KeyBoradType = "0",
					maxLengthEnable = "True;maxLength:155",
					name = "txt_input",
					passwordEnable = "False",
					placeHolder = "点击输入兑换码",
					sizepercentx = "0",
					sizepercenty = "0",
					sizeType = "0",
					srcBlendFunc = "1",
					touchAble = "True",
					UILayoutViewModel = 
					{
						PositionX = 268,
						PositionY = 523,
					},
					vAlignment = "0",
					width = "420",
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
					height = "45",
					ignoreSize = "True",
					name = "Button_duihuanma_1",
					normal = "ui_new/setting/btn_duihuan.png",
					sizepercentx = "0",
					sizepercenty = "0",
					sizeType = "0",
					srcBlendFunc = "1",
					touchAble = "True",
					UILayoutViewModel = 
					{
						PositionX = 480,
						PositionY = 374,
					},
					UItype = "Button",
					width = "158",
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
					name = "txt_duihuanma",
					nGap = "0",
					nIconAlign = "1",
					nTextAlign = "1",
					sizepercentx = "0",
					sizepercenty = "0",
					sizeType = "0",
					srcBlendFunc = "1",
					text = "关注官方微信：jyqxz2015，更多好礼等你来拿！",
					touchAble = "False",
					touchScaleEnable = "False",
					UILayoutViewModel = 
					{
						PositionX = 264,
						PositionY = 466,
					},
					width = "430",
					ZOrder = "1",
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
			"ui_new/common/common_close_icon.png",
			"ui_new/chat/input.png",
			"ui_new/qiyu/btn_niantie.png",
			"ui_new/setting/btn_duihuan.png",
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

