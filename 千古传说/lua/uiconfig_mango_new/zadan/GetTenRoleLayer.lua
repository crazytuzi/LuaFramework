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
					classname = "MEImage",
					dstBlendFunc = "771",
					height = "359",
					ignoreSize = "True",
					name = "tenBgImg",
					sizepercentx = "0",
					sizepercenty = "0",
					sizeType = "0",
					srcBlendFunc = "1",
					texturePath = "ui_new/shop/shibg.png",
					touchAble = "False",
					UILayoutViewModel = 
					{
						PositionX = 480,
						PositionY = 336,
						TopPosition = 125,
						relativeToName = "Panel",
						nType = 3,
						nGravity = 6,
						nAlign = 2
					},
					width = "798",
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
							name = "titleImg",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							texturePath = "ui_new/zadan/img_zdcg.png",
							touchAble = "False",
							UILayoutViewModel = 
							{
								PositionX = -5,
								PositionY = 219,
							},
							width = "336",
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
						PositionX = 793,
						PositionY = 84,
						RightPosition = 89,
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
						PositionY = 72,
						LeftPositon = 67,
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
						PositionY = 72,
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
			"ui_new/shop/shibg.png",
			"ui_new/zadan/img_zdcg.png",
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

