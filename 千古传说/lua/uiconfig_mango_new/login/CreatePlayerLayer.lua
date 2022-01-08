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
			colorType = "0;SingleColor:#FFE6E6E6;GraduallyChangingColorStart:#00000000;GraduallyChangingColorEnd:#00000000;vectorX:0;vectorY:0",
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
					height = "640",
					ignoreSize = "True",
					name = "bg",
					sizepercentx = "0",
					sizepercenty = "0",
					sizeType = "0",
					srcBlendFunc = "1",
					texturePath = "bg_jpg/cjjs_bj_bg.jpg",
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
					width = "1136",
					ZOrder = "1",
					components = 
					{
						
						{
							anchorPoint = "False",
							anchorPointX = "0.5",
							anchorPointY = "0",
							backGroundScale9Enable = "False",
							classname = "MEImage",
							dstBlendFunc = "771",
							height = "504",
							ignoreSize = "True",
							name = "img_role",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							texturePath = "icon/rolebig/10001.png",
							touchAble = "False",
							UILayoutViewModel = 
							{
								PositionX = -209,
								PositionY = -182,
							},
							width = "475",
							ZOrder = "1",
						},
						{
							anchorPoint = "False",
							anchorPointX = "0.5",
							anchorPointY = "0.5",
							backGroundScale9Enable = "False",
							classname = "MEImage",
							dstBlendFunc = "771",
							height = "85",
							ignoreSize = "True",
							name = "Image_CreatePlayerLayer_1(3)",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							texturePath = "ui_new/createplayer/cjjs_jsmc_icon.png",
							touchAble = "False",
							UILayoutViewModel = 
							{
								PositionX = -190,
								PositionY = -244,
							},
							width = "564",
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
									height = "49",
									HitType = 
									{
										nHitType = 1,
										nXpos = -20,
										nYpos = -50,
										nHitWidth = 100,
										nHitHeight = 150
									},
									ignoreSize = "True",
									name = "btn_roll",
									normal = "ui_new/createplayer/cjjs_sj_icon.png",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									touchAble = "True",
									UILayoutViewModel = 
									{
										PositionX = 209,
										PositionY = -1,
									},
									UItype = "Button",
									width = "48",
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
									fontSize = "26",
									hAlignment = "0",
									height = "26",
									HitType = 
									{
										nHitType = 1,
										nXpos = -100,
										nYpos = -50,
										nHitWidth = 320,
										nHitHeight = 150
									},
									ignoreSize = "True",
									KeyBoradType = "0",
									maxLengthEnable = "True;maxLength:16",
									name = "playernameInput",
									passwordEnable = "False",
									placeHolder = "请输入名称",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									touchAble = "True",
									UILayoutViewModel = 
									{
										PositionX = 4,
										PositionY = 1,
									},
									vAlignment = "0",
									width = "130",
									ZOrder = "9",
								},
							},
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
					height = "207",
					ignoreSize = "True",
					name = "createOkBtn",
					normal = "ui_new/createplayer/cjjs_qd_btn.png",
					sizepercentx = "0",
					sizepercenty = "0",
					sizeType = "0",
					srcBlendFunc = "1",
					touchAble = "True",
					UILayoutViewModel = 
					{
						PositionX = 1005,
						PositionY = 104,
						relativeToName = "Panel",
						nType = 3,
						nGravity = 3,
						nAlign = 9
					},
					UItype = "Button",
					width = "230",
					ZOrder = "1",
				},
				{
					anchorPoint = "False",
					anchorPointX = "0.5",
					anchorPointY = "0.5",
					backGroundScale9Enable = "False",
					classname = "MEImage",
					dstBlendFunc = "771",
					height = "72",
					ignoreSize = "True",
					name = "Image_CreatePlayerLayer_1",
					sizepercentx = "0",
					sizepercenty = "0",
					sizeType = "0",
					srcBlendFunc = "1",
					texturePath = "ui_new/createplayer/cjjs_cjjs_title.png",
					touchAble = "False",
					UILayoutViewModel = 
					{
						PositionX = 158,
						PositionY = 669,
						TopPosition = 5,
						relativeToName = "Panel",
						nType = 3,
					},
					width = "317",
					ZOrder = "1",
				},
				{
					anchorPoint = "False",
					anchorPointX = "0.5",
					anchorPointY = "0.5",
					backGroundScale9Enable = "False",
					classname = "MEImage",
					dstBlendFunc = "771",
					height = "533",
					ignoreSize = "True",
					name = "Image_CreatePlayerLayer_1(4)",
					sizepercentx = "0",
					sizepercenty = "0",
					sizeType = "0",
					srcBlendFunc = "1",
					texturePath = "ui_new/createplayer/cjjs_smd_icon.png",
					touchAble = "False",
					UILayoutViewModel = 
					{
						PositionX = 832,
						PositionY = 334,
						RightPosition = 90,
						BottomPosition = 67,
						relativeToName = "Panel",
						nType = 3,
						nGravity = 3,
						nAlign = 9
					},
					width = "395",
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
							height = "143",
							ignoreSize = "True",
							name = "btn_role_1",
							normal = "ui_new/createplayer/cjjs_txd_off_btn.png",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							touchAble = "True",
							UILayoutViewModel = 
							{
								PositionX = -50,
								PositionY = 186,
							},
							UItype = "Button",
							width = "146",
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
									height = "95",
									ignoreSize = "True",
									name = "img_icon_1",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									texturePath = "icon/head/10002.png",
									touchAble = "False",
									UILayoutViewModel = 
									{
										PositionY = 6,
									},
									width = "95",
									ZOrder = "1",
								},
								{
									anchorPoint = "False",
									anchorPointX = "0.5",
									anchorPointY = "0.5",
									backGroundScale9Enable = "False",
									classname = "MEImage",
									dstBlendFunc = "771",
									height = "29",
									ignoreSize = "True",
									name = "Image_CreatePlayerLayer_1",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									texturePath = "ui_new/createplayer/cjjs_scgj_word.png",
									touchAble = "False",
									UILayoutViewModel = 
									{
										PositionX = 12,
										PositionY = -65,
									},
									width = "142",
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
							height = "143",
							ignoreSize = "True",
							name = "img_choice",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							texturePath = "ui_new/createplayer/cjjs_txd_on_btn.png",
							touchAble = "False",
							UILayoutViewModel = 
							{
								PositionX = -50,
								PositionY = 186,
							},
							width = "146",
							ZOrder = "10",
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
							height = "143",
							ignoreSize = "True",
							name = "btn_role_2",
							normal = "ui_new/createplayer/cjjs_txd_off_btn.png",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							touchAble = "True",
							UILayoutViewModel = 
							{
								PositionX = 111,
								PositionY = 118,
							},
							UItype = "Button",
							width = "146",
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
									height = "95",
									ignoreSize = "True",
									name = "img_icon_2",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									texturePath = "icon/head/10002.png",
									touchAble = "False",
									UILayoutViewModel = 
									{
										PositionY = 6,
									},
									width = "95",
									ZOrder = "1",
								},
								{
									anchorPoint = "False",
									anchorPointX = "0.5",
									anchorPointY = "0.5",
									backGroundScale9Enable = "False",
									classname = "MEImage",
									dstBlendFunc = "771",
									height = "29",
									ignoreSize = "True",
									name = "Image_CreatePlayerLayer_2",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									texturePath = "ui_new/createplayer/cjjs_sczl_word.png",
									touchAble = "False",
									UILayoutViewModel = 
									{
										PositionX = 12,
										PositionY = -65,
									},
									width = "142",
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
							height = "143",
							ignoreSize = "True",
							name = "btn_role_3",
							normal = "ui_new/createplayer/cjjs_txd_off_btn.png",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							touchAble = "True",
							UILayoutViewModel = 
							{
								PositionX = 110,
								PositionY = -50,
							},
							UItype = "Button",
							width = "146",
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
									height = "95",
									ignoreSize = "True",
									name = "img_icon_3",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									texturePath = "icon/head/10002.png",
									touchAble = "False",
									UILayoutViewModel = 
									{
										PositionY = 6,
									},
									width = "95",
									ZOrder = "1",
								},
								{
									anchorPoint = "False",
									anchorPointX = "0.5",
									anchorPointY = "0.5",
									backGroundScale9Enable = "False",
									classname = "MEImage",
									dstBlendFunc = "771",
									height = "29",
									ignoreSize = "True",
									name = "Image_CreatePlayerLayer_3",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									texturePath = "ui_new/createplayer/cjjs_sckz_word.png",
									touchAble = "False",
									UILayoutViewModel = 
									{
										PositionX = 2,
										PositionY = -65,
									},
									width = "142",
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
							height = "143",
							ignoreSize = "True",
							name = "btn_role_4",
							normal = "ui_new/createplayer/cjjs_txd_off_btn.png",
							sizepercentx = "0",
							sizepercenty = "0",
							sizeType = "0",
							srcBlendFunc = "1",
							touchAble = "True",
							UILayoutViewModel = 
							{
								PositionX = -17,
								PositionY = -141,
							},
							UItype = "Button",
							width = "146",
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
									height = "95",
									ignoreSize = "True",
									name = "img_icon_4",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									texturePath = "icon/head/10002.png",
									touchAble = "False",
									UILayoutViewModel = 
									{
										PositionY = 6,
									},
									width = "95",
									ZOrder = "1",
								},
								{
									anchorPoint = "False",
									anchorPointX = "0.5",
									anchorPointY = "0.5",
									backGroundScale9Enable = "False",
									classname = "MEImage",
									dstBlendFunc = "771",
									height = "29",
									ignoreSize = "True",
									name = "Image_CreatePlayerLayer_4",
									sizepercentx = "0",
									sizepercenty = "0",
									sizeType = "0",
									srcBlendFunc = "1",
									texturePath = "ui_new/createplayer/cjjs_scfy_word.png",
									touchAble = "False",
									UILayoutViewModel = 
									{
										PositionX = 2,
										PositionY = -65,
									},
									width = "142",
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
			"bg_jpg/cjjs_bj_bg.jpg",
			"icon/rolebig/10001.png",
			"ui_new/createplayer/cjjs_jsmc_icon.png",
			"ui_new/createplayer/cjjs_sj_icon.png",
			"ui_new/createplayer/cjjs_qd_btn.png",
			"ui_new/createplayer/cjjs_cjjs_title.png",
			"ui_new/createplayer/cjjs_smd_icon.png",
			"ui_new/createplayer/cjjs_txd_off_btn.png",
			"icon/head/10002.png",
			"ui_new/createplayer/cjjs_scgj_word.png",
			"ui_new/createplayer/cjjs_txd_on_btn.png",
			"ui_new/createplayer/cjjs_sczl_word.png",
			"ui_new/createplayer/cjjs_sckz_word.png",
			"ui_new/createplayer/cjjs_scfy_word.png",
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

