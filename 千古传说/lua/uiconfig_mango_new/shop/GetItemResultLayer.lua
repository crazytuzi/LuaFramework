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
					name = "panel_effect",
					sizepercentx = "100",
					sizepercenty = "100",
					sizeType = "1",
					srcBlendFunc = "1",
					touchAble = "True",
					UILayoutViewModel = 
					{
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
					name = "img_quality_bg",
					sizepercentx = "0",
					sizepercenty = "0",
					sizeType = "0",
					srcBlendFunc = "1",
					texturePath = "ui_new/common/icon_bg/pz_bg_jia_124.png",
					touchAble = "False",
					UILayoutViewModel = 
					{
						PositionX = 499,
						PositionY = 359,
						relativeToName = "Panel",
						nType = 3,
						nGravity = 6,
						nAlign = 5
					},
					width = "130",
					ZOrder = "10",
					components = 
					{
						
						{
							anchorPoint = "False",
							anchorPointX = "0.5",
							anchorPointY = "0.5",
							backGroundScale9Enable = "False",
							classname = "MEImage",
							dstBlendFunc = "771",
							height = "130",
							ignoreSize = "True",
							name = "img_icon",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							texturePath = "icon/item/1.png",
							touchAble = "False",
							UILayoutViewModel = 
							{
								
							},
							width = "130",
							ZOrder = "1",
						},
						{
							anchorPoint = "False",
							anchorPointX = "1",
							anchorPointY = "0.5",
							classname = "MELabelBMFont",
							dstBlendFunc = "771",
							fileNameData = "font/num_202.fnt",
							height = "27",
							ignoreSize = "True",
							name = "txt_num",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							text = "50",
							touchAble = "False",
							UILayoutViewModel = 
							{
								PositionX = 55,
								PositionY = -48,
							},
							width = "31",
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
					height = "45",
					ignoreSize = "True",
					name = "getCardBtn",
					normal = "ui_new/shop/zmj.png",
					sizepercentx = "0",
					sizepercenty = "0",
					sizeType = "0",
					srcBlendFunc = "1",
					touchAble = "True",
					UILayoutViewModel = 
					{
						PositionX = 139,
						PositionY = 175,
						LeftPositon = 60,
						TopPosition = 521,
						relativeToName = "Panel",
						nType = 3,
						nGravity = 2,
					},
					UItype = "Button",
					width = "158",
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
							height = "28",
							ignoreSize = "False",
							name = "Image_GetItemResultLayer_1",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							texturePath = "ui_new/shop/zmyi.png",
							touchAble = "False",
							UILayoutViewModel = 
							{
								PositionX = 2,
								PositionY = -45,
								LeftPositon = 78,
								TopPosition = 503,
								relativeToName = "Panel",
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
							height = "46",
							ignoreSize = "True",
							name = "yuanbaoImg",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							texturePath = "ui_new/common/xx_yuanbao_icon.png",
							touchAble = "False",
							UILayoutViewModel = 
							{
								PositionX = -46,
								PositionY = -46,
							},
							width = "45",
							ZOrder = "1",
						},
						{
							anchorPoint = "False",
							anchorPointX = "1",
							anchorPointY = "0.5",
							classname = "MELabelBMFont",
							dstBlendFunc = "771",
							fileNameData = "font/num_31.fnt",
							height = "27",
							ignoreSize = "True",
							name = "yuanbaoLabel",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							text = "100",
							touchAble = "False",
							UILayoutViewModel = 
							{
								PositionX = 57,
								PositionY = -49,
							},
							width = "38",
							ZOrder = "1",
						},
						{
							anchorPoint = "False",
							anchorPointX = "0.5",
							anchorPointY = "0.5",
							backGroundScale9Enable = "False",
							classname = "MEImage",
							dstBlendFunc = "771",
							height = "30",
							ignoreSize = "True",
							name = "zhaomutool",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							texturePath = "ui_new/common/zm_cha_icon.png",
							touchAble = "False",
							UILayoutViewModel = 
							{
								PositionX = -42,
								PositionY = -35,
							},
							visible = "False",
							width = "46",
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
					height = "45",
					ignoreSize = "True",
					name = "returnBtn",
					normal = "ui_new/shop/okbtn.png",
					sizepercentx = "0",
					sizepercenty = "0",
					sizeType = "0",
					srcBlendFunc = "1",
					touchAble = "True",
					UILayoutViewModel = 
					{
						PositionX = 863,
						PositionY = 175,
						RightPosition = 60,
						TopPosition = 521,
						relativeToName = "Panel",
						nType = 3,
						nGravity = 3,
						nAlign = 3
					},
					UItype = "Button",
					width = "149",
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
			"ui_new/common/icon_bg/pz_bg_jia_124.png",
			"icon/item/1.png",
			"ui_new/shop/zmj.png",
			"ui_new/shop/zmyi.png",
			"ui_new/common/xx_yuanbao_icon.png",
			"ui_new/common/zm_cha_icon.png",
			"ui_new/shop/okbtn.png",
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

