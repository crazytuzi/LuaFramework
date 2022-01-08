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
						PositionX = 560,
						PositionY = 355,
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
							height = "110",
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
							width = "110",
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
					height = "70",
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
						PositionX = 982,
						PositionY = 154,
						RightPosition = 60,
						TopPosition = 521,
						relativeToName = "Panel",
						nType = 3,
						nGravity = 3,
						nAlign = 3
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
					height = "94",
					ignoreSize = "True",
					name = "getCardBtn",
					normal = "ui_new/zadan/btn_zadan1.png",
					sizepercentx = "0",
					sizepercenty = "0",
					sizeType = "0",
					srcBlendFunc = "1",
					touchAble = "True",
					UILayoutViewModel = 
					{
						PositionX = 145,
						PositionY = 142,
						LeftPositon = 67,
						TopPosition = 521,
						relativeToName = "Panel",
						nType = 3,
						nGravity = 2,
					},
					UItype = "Button",
					width = "156",
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
							height = "37",
							ignoreSize = "True",
							name = "img_cost",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							texturePath = "ui_new/zadan/img_yincz.png",
							touchAble = "False",
							UILayoutViewModel = 
							{
								PositionX = -45,
								PositionY = -37,
							},
							width = "37",
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
							name = "txt_cost",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							text = "100",
							touchAble = "False",
							UILayoutViewModel = 
							{
								PositionX = 30,
								PositionY = -38,
							},
							width = "38",
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
					height = "94",
					ignoreSize = "True",
					name = "getTenCardBtn",
					normal = "ui_new/zadan/btn_zadan2.png",
					sizepercentx = "0",
					sizepercenty = "0",
					sizeType = "0",
					srcBlendFunc = "1",
					touchAble = "True",
					UILayoutViewModel = 
					{
						PositionX = 339,
						PositionY = 142,
						LeftPositon = 261,
						TopPosition = 521,
						relativeToName = "Panel",
						nType = 3,
					},
					UItype = "Button",
					width = "156",
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
							height = "37",
							ignoreSize = "True",
							name = "img_cost",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							texturePath = "ui_new/zadan/img_yincz.png",
							touchAble = "False",
							UILayoutViewModel = 
							{
								PositionX = -45,
								PositionY = -37,
							},
							width = "37",
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
							name = "txt_cost",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							text = "100",
							touchAble = "False",
							UILayoutViewModel = 
							{
								PositionX = 30,
								PositionY = -38,
							},
							width = "38",
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
			"ui_new/common/icon_bg/pz_bg_jia_124.png",
			"icon/item/1.png",
			"ui_new/shop/okbtn.png",
			"ui_new/zadan/btn_zadan1.png",
			"ui_new/zadan/img_yincz.png",
			"ui_new/zadan/btn_zadan2.png",
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

