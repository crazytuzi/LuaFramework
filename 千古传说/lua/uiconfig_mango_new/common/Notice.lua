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
								PositionY = 132,
							},
							visible = "False",
							width = "500",
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
								PositionY = -130,
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
							ColorMixing = "#FF8B0000",
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
							fontSize = "30",
							fontStroke = 
							{
								IsStroke = false,
								StrokeColor = "#FF5E1F18",
								StrokeSize = 2,
							},
							height = "30",
							IconLayout = "1",
							ignoreSize = "True",
							name = "txt_biaoti",
							nGap = "0",
							nIconAlign = "1",
							nTextAlign = "1",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							text = "标题",
							touchAble = "False",
							touchScaleEnable = "False",
							UILayoutViewModel = 
							{
								PositionY = 134,
							},
							width = "60",
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
							name = "Btn_close",
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
								PositionX = 285,
								PositionY = 144,
							},
							UItype = "Button",
							width = "75",
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
							name = "txt_message1",
							nGap = "0",
							nIconAlign = "1",
							nTextAlign = "1",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							text = "TextLable",
							touchAble = "False",
							touchScaleEnable = "False",
							UILayoutViewModel = 
							{
								PositionX = -204,
								PositionY = 57,
							},
							width = "108",
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
							name = "txt_message2",
							nGap = "0",
							nIconAlign = "1",
							nTextAlign = "1",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							text = "TextLable",
							touchAble = "False",
							touchScaleEnable = "False",
							UILayoutViewModel = 
							{
								PositionX = -204,
								PositionY = 27,
							},
							width = "108",
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
							name = "txt_message3",
							nGap = "0",
							nIconAlign = "1",
							nTextAlign = "1",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							text = "TextLable",
							touchAble = "False",
							touchScaleEnable = "False",
							UILayoutViewModel = 
							{
								PositionX = -204,
								PositionY = -3,
							},
							width = "108",
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
							name = "txt_message4",
							nGap = "0",
							nIconAlign = "1",
							nTextAlign = "1",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							text = "TextLable",
							touchAble = "False",
							touchScaleEnable = "False",
							UILayoutViewModel = 
							{
								PositionX = -204,
								PositionY = -33,
							},
							width = "108",
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
							name = "txt_message5",
							nGap = "0",
							nIconAlign = "1",
							nTextAlign = "1",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							text = "TextLable",
							touchAble = "False",
							touchScaleEnable = "False",
							UILayoutViewModel = 
							{
								PositionX = -204,
								PositionY = -63,
							},
							width = "108",
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
			"ui_new/common/bg_biaoti2.png",
			"ui_new/common/btn_ok.png",
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

