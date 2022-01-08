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
					classname = "MEButton",
					ClickHighLightEnabled = "True",
					dstBlendFunc = "771",
					flipX = "False",
					flipY = "False",
					height = "140",
					ignoreSize = "True",
					name = "btn_base",
					normal = "ui_new/bloodybattle/ymg_di.png",
					pressed = "ui_new/bloodybattle/ymg_di.png",
					scaleX = "0.9",
					scaleY = "0.9",
					sizepercentx = "0",
					sizepercenty = "0",
					sizeType = "0",
					srcBlendFunc = "1",
					touchAble = "True",
					UILayoutViewModel = 
					{
						PositionX = 50,
						PositionY = 61,
					},
					UItype = "Button",
					width = "133",
					ZOrder = "1",
				},
				{
					anchorPoint = "False",
					anchorPointX = "0.5",
					anchorPointY = "0.5",
					classname = "MELabel",
					compPath = "luacomponents.common.MEIconLabel",
					dstBlendFunc = "771",
					FontColor = "#FFFFF4B4",
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
					name = "txt_name",
					nGap = "0",
					nIconAlign = "1",
					nTextAlign = "1",
					sizepercentx = "0",
					sizepercenty = "0",
					sizeType = "0",
					srcBlendFunc = "1",
					text = "可挑战",
					touchAble = "False",
					touchScaleEnable = "False",
					UILayoutViewModel = 
					{
						PositionX = 50,
						PositionY = 13,
					},
					width = "60",
					ZOrder = "1",
				},
				{
					anchorPoint = "False",
					anchorPointX = "0.5",
					anchorPointY = "0.5",
					backGroundScale9Enable = "False",
					classname = "MEImage",
					dstBlendFunc = "771",
					height = "130",
					ignoreSize = "True",
					name = "img_boss",
					scaleX = "0.58",
					scaleY = "0.58",
					sizepercentx = "0",
					sizepercenty = "0",
					sizeType = "0",
					srcBlendFunc = "1",
					texturePath = "icon/head/10001.png",
					touchAble = "False",
					UILayoutViewModel = 
					{
						PositionX = 50,
						PositionY = 74,
					},
					width = "130",
					ZOrder = "1",
				},
				{
					anchorPoint = "False",
					anchorPointX = "0.5",
					anchorPointY = "0.5",
					backGroundScale9Enable = "False",
					classname = "MEImage",
					dstBlendFunc = "771",
					height = "56",
					ignoreSize = "True",
					name = "img_num",
					sizepercentx = "0",
					sizepercenty = "0",
					sizeType = "0",
					srcBlendFunc = "1",
					texturePath = "ui_new/mission/gk_1.png",
					touchAble = "False",
					UILayoutViewModel = 
					{
						PositionX = 14,
						PositionY = 110,
					},
					width = "56",
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
			"ui_new/bloodybattle/ymg_di.png",
			"icon/head/10001.png",
			"ui_new/mission/gk_1.png",
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

