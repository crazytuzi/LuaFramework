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
			height = "30",
			ignoreSize = "False",
			name = "Panel",
			sizepercentx = "75",
			sizepercenty = "20",
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
			width = "758",
			ZOrder = "1",
			components = 
			{
				
				{
					anchorPoint = "False",
					anchorPointX = "0",
					anchorPointY = "0.5",
					backGroundScale9Enable = "False",
					classname = "MEImage",
					dstBlendFunc = "771",
					height = "2",
					ignoreSize = "False",
					name = "img_spilt_left",
					sizepercentx = "100",
					sizepercenty = "30",
					sizeType = "0",
					srcBlendFunc = "1",
					texturePath = "ui_new/chat/line.png",
					touchAble = "False",
					UILayoutViewModel = 
					{
						PositionY = 12,
					},
					width = "310",
					ZOrder = "1",
				},
				{
					anchorPoint = "False",
					anchorPointX = "1",
					anchorPointY = "0.5",
					backGroundScale9Enable = "False",
					classname = "MEImage",
					dstBlendFunc = "771",
					height = "2",
					ignoreSize = "False",
					name = "img_spilt_right",
					sizepercentx = "48",
					sizepercenty = "30",
					sizeType = "0",
					srcBlendFunc = "1",
					texturePath = "ui_new/chat/line.png",
					touchAble = "False",
					UILayoutViewModel = 
					{
						PositionX = 758,
						PositionY = 12,
					},
					width = "310",
					ZOrder = "1",
				},
				{
					anchorPoint = "False",
					anchorPointX = "0.5",
					anchorPointY = "0.5",
					classname = "MELabel",
					ColorMixing = "#FF00BFFF",
					compPath = "luacomponents.common.MEIconLabel",
					dstBlendFunc = "771",
					FontColor = "#FF00BFFF",
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
						IsStroke = true,
						StrokeColor = "#FF000000",
						StrokeSize = 1,
					},
					height = "22",
					IconLayout = "1",
					ignoreSize = "True",
					name = "txt_timestamp",
					nGap = "0",
					nIconAlign = "1",
					nTextAlign = "1",
					sizepercentx = "0",
					sizepercenty = "0",
					sizeType = "0",
					srcBlendFunc = "1",
					text = "2014-06-24",
					touchAble = "False",
					touchScaleEnable = "False",
					UILayoutViewModel = 
					{
						PositionX = 381,
						PositionY = 18,
					},
					width = "110",
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
			"ui_new/chat/line.png",
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

