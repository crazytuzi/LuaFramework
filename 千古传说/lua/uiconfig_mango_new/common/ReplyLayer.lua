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
					sizepercentx = "0",
					sizepercenty = "0",
					sizeType = "0",
					srcBlendFunc = "1",
					texturePath = "ui_new/common/common_tips1_bg.png",
					touchAble = "False",
					UILayoutViewModel = 
					{
						PositionX = 512,
						PositionY = 300,
					},
					width = "625",
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
							height = "51",
							ignoreSize = "True",
							name = "bg_title",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							texturePath = "ui_new/common/img_czqr.png",
							touchAble = "False",
							UILayoutViewModel = 
							{
								PositionY = 100,
							},
							width = "188",
							ZOrder = "1",
						},
					},
				},
				{
					anchorPoint = "False",
					anchorPointX = "0.5",
					anchorPointY = "0.5",
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
					fontSize = "24",
					fontStroke = 
					{
						IsStroke = false,
						StrokeColor = "#FFE6E6E6",
						StrokeSize = 1,
					},
					height = "20",
					IconLayout = "1",
					ignoreSize = "False",
					name = "txt_content",
					nGap = "0",
					nIconAlign = "1",
					nTextAlign = "1",
					sizepercentx = "0",
					sizepercenty = "0",
					sizeType = "0",
					srcBlendFunc = "1",
					text = "是否花费20宝购买10点体力？",
					touchAble = "False",
					touchScaleEnable = "False",
					UILayoutViewModel = 
					{
						PositionX = 512,
						PositionY = 333,
					},
					width = "400",
					ZOrder = "1",
				},
				{
					anchorPoint = "False",
					anchorPointX = "0.5",
					anchorPointY = "0.5",
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
					name = "txt_des",
					nGap = "0",
					nIconAlign = "1",
					nTextAlign = "1",
					sizepercentx = "0",
					sizepercenty = "0",
					sizeType = "0",
					srcBlendFunc = "1",
					text = "是否确认进行此项操作？",
					touchAble = "False",
					touchScaleEnable = "False",
					UILayoutViewModel = 
					{
						PositionX = 512,
						PositionY = 300,
					},
					width = "264",
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
					name = "btn_ok",
					normal = "ui_new/common/btn_ok.png",
					sizepercentx = "0",
					sizepercenty = "0",
					sizeType = "0",
					srcBlendFunc = "1",
					touchAble = "True",
					UILayoutViewModel = 
					{
						PositionX = 622,
						PositionY = 205,
					},
					UItype = "Button",
					width = "149",
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
					name = "btn_cancel",
					normal = "ui_new/common/btn_cancel.png",
					sizepercentx = "0",
					sizepercenty = "0",
					sizeType = "0",
					srcBlendFunc = "1",
					touchAble = "True",
					UILayoutViewModel = 
					{
						PositionX = 402,
						PositionY = 205,
					},
					UItype = "Button",
					width = "149",
					ZOrder = "1",
				},
				{
					anchorPoint = "False",
					anchorPointX = "0.5",
					anchorPointY = "0.5",
					classname = "MELabel",
					ColorMixing = "#00FFFFFF",
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
					fontSize = "36",
					fontStroke = 
					{
						IsStroke = true,
						StrokeColor = "#FF73200E",
						StrokeSize = 2,
					},
					height = "36",
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
					text = "操作确认",
					touchAble = "False",
					touchScaleEnable = "False",
					UILayoutViewModel = 
					{
						PositionX = 512,
						PositionY = 423,
					},
					visible = "False",
					width = "144",
					ZOrder = "1",
				},
				{
					anchorPoint = "False",
					anchorPointX = "0.5",
					anchorPointY = "0.5",
					backGroundScale9Enable = "False",
					classname = "MEImage",
					dstBlendFunc = "771",
					height = "43",
					ignoreSize = "True",
					name = "Image_ReplyLayer_1",
					sizepercentx = "0",
					sizepercenty = "0",
					sizeType = "0",
					srcBlendFunc = "1",
					texturePath = "ui_new/common/img_henghuawen.png",
					touchAble = "False",
					UILayoutViewModel = 
					{
						PositionX = 370,
						PositionY = 400,
					},
					width = "90",
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
							flipX = "True",
							height = "43",
							ignoreSize = "True",
							name = "Image_ReplyLayer_1",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							texturePath = "ui_new/common/img_henghuawen.png",
							touchAble = "False",
							UILayoutViewModel = 
							{
								PositionX = 276,
							},
							width = "90",
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
			"ui_new/common/common_tips1_bg.png",
			"ui_new/common/img_czqr.png",
			"ui_new/common/btn_ok.png",
			"ui_new/common/btn_cancel.png",
			"ui_new/common/img_henghuawen.png",
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

