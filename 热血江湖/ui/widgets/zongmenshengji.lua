--version = 1
local l_fileType = "node"

local UIUtil = require "ui/common/UIUtil"

--EDITOR elements start tag
local eleRoot = 
{
	prop = {
		etype = "Layer",
		name = "root",
		posX = 0,
		posY = 0,
		anchorX = 0,
		anchorY = 0,
	},
	children = {
	{
		prop = {
			etype = "Image",
			name = "zmsj",
			varName = "clanRoot",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.5625,
			sizeY = 0.6944444,
			image = "a",
			scale9 = true,
			scale9Left = 0.3,
			scale9Right = 0.3,
			scale9Top = 0.3,
			scale9Bottom = 0.3,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt1",
				posX = 0.494449,
				posY = 0.8234766,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9480988,
				sizeY = 0.35,
				image = "g#g_d9.png",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "bj1",
					posX = 0.27308,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2243402,
					sizeY = 0.8685715,
					image = "zm#zm_dw.png",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "bj2",
					posX = 0.7181119,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2243402,
					sizeY = 0.8685715,
					image = "zm#zm_dw.png",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "bjg",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 1.210348,
						sizeY = 1.230197,
						image = "zm#zm_bjg.png",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "fazhen",
					posX = 0.2718544,
					posY = 0.5110912,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2381634,
					sizeY = 0.9281567,
					image = "uieffect/fazhen2.png",
					alpha = 0,
					blendFunc = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zmk",
					varName = "now_icon",
					posX = 0.2741107,
					posY = 0.5059354,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1722874,
					sizeY = 0.7142858,
					image = "zm#33",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "sz6",
						varName = "lvl_icon3",
						posX = 0.6339008,
						posY = 0.4010431,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2622894,
						sizeY = 0.3603451,
						image = "zm#sz8",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "sz8",
						varName = "lvl_icon4",
						posX = 0.366067,
						posY = 0.4010431,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2622894,
						sizeY = 0.3603451,
						image = "zm#sz8",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "nv",
						varName = "now_girl_bg",
						posX = 0.5,
						posY = 0.3108194,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.019163,
						sizeY = 0.5439557,
						image = "zm#nv",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zmk2",
					varName = "next_icon",
					posX = 0.7168632,
					posY = 0.5059355,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1722874,
					sizeY = 0.7142858,
					image = "zm#33",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "sz5",
						varName = "lvl_icon2",
						posX = 0.6339008,
						posY = 0.4010431,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2622894,
						sizeY = 0.3603451,
						image = "zm#sz8",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "sz7",
						varName = "lvl_icon1",
						posX = 0.366067,
						posY = 0.4010431,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2622894,
						sizeY = 0.3603451,
						image = "zm#sz8",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "nv2",
						varName = "next_girl_bg",
						posX = 0.5,
						posY = 0.3108194,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.019163,
						sizeY = 0.5439557,
						image = "zm#nv",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jt",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1422288,
					sizeY = 0.3257143,
					image = "w#w_qhjt.png",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt2",
				posX = 0.494449,
				posY = 0.29,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9480987,
				sizeY = 0.58,
				image = "g#g_dk.png",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "a1",
					varName = "up_lvl_btn",
					posX = 0.5,
					posY = 0.128361,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2217497,
					sizeY = 0.1827133,
					image = "w#w_qq4.png",
					imageNormal = "w#w_qq4.png",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "az1",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7280625,
						sizeY = 0.7695788,
						text = "升 级",
						color = "FFB0FFD9",
						fontSize = 24,
						fontOutlineEnable = true,
						fontOutlineColor = "FF145A4F",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "smd",
					posX = 0.5,
					posY = 1,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4576655,
					sizeY = 0.1275862,
					image = "w#w_smd3.png",
					alpha = 0.6,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "smd2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3588273,
						sizeY = 0.7027028,
						image = "zm#zm_sxcl.png",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "ssm2",
					posX = 0.5,
					posY = 0.4705831,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9851851,
					sizeY = 0.4819672,
					image = "w#w_smd3.png",
					alpha = 0.5,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zsx",
					posX = 0.2877387,
					posY = 0.9957321,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1671554,
					sizeY = 0.03103449,
					image = "w#w_zhuangshixian.png",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zsx2",
					posX = 0.7093597,
					posY = 0.9957322,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1671554,
					sizeY = 0.03103449,
					image = "w#w_zhuangshixian.png",
					flippedX = true,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "ssm",
					posX = 0.5,
					posY = 0.826463,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9851851,
					sizeY = 0.1539674,
					image = "w#w_smd3.png",
					alpha = 0.5,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "ts1",
						varName = "clan_count",
						posX = 0.5493924,
						posY = 0.5714288,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5096585,
						sizeY = 0.9599229,
						text = "123/256",
						color = "FFE7390A",
						fontSize = 24,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "ts14",
						posX = 0.2403279,
						posY = 0.5714288,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.26003,
						sizeY = 0.9599229,
						text = "宗门声望",
						color = "FF9EF2C0",
						fontSize = 24,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "jiahao",
						varName = "get_presgite_btn",
						posX = 0.8387821,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1923954,
						sizeY = 1.014357,
						image = "w#qq4",
						imageNormal = "w#qq4",
						imagePressed = "w#qq2",
						imageDisable = "w#qq1",
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "az2",
							posX = 0.5,
							posY = 0.5207666,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8795429,
							sizeY = 0.7695788,
							text = "获取声望",
							color = "FFB0FFD9",
							fontSize = 22,
							fontOutlineEnable = true,
							fontOutlineColor = "FF145A4F",
							fontOutlineSize = 2,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "ts2",
					posX = 0.244175,
					posY = 0.6118829,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2561777,
					sizeY = 0.1390233,
					text = "资源",
					color = "FF9EF2C0",
					fontSize = 24,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "wpk",
					varName = "itembg1",
					posX = 0.3483428,
					posY = 0.5062206,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1246334,
					sizeY = 0.2931035,
					image = "djk#kcheng",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "wp",
						varName = "itemIcon1",
						posX = 0.5,
						posY = 0.5312501,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.8512452,
						sizeY = 0.8423778,
						image = "items#items_zhongjishengxingshi.png",
					},
				},
				{
					prop = {
						etype = "Button",
						name = "dj3",
						varName = "itemBtn1",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "wpk2",
					varName = "itembg2",
					posX = 0.6141921,
					posY = 0.5062206,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1246334,
					sizeY = 0.2931035,
					image = "djk#kcheng",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "wp2",
						varName = "itemIcon2",
						posX = 0.5,
						posY = 0.5312501,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.8512452,
						sizeY = 0.8423778,
						image = "items#items_zhongjishengxingshi.png",
					},
				},
				{
					prop = {
						etype = "Button",
						name = "dj4",
						varName = "itemBtn2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "ts3",
					varName = "itemCount1",
					posX = 0.4903792,
					posY = 0.520816,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1391112,
					sizeY = 0.1488278,
					text = "10000",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "ts4",
					varName = "itemCount2",
					posX = 0.7827162,
					posY = 0.5208161,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1862388,
					sizeY = 0.1488278,
					text = "10000",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			},
		},
		},
	},
	},
}
--EDITOR elements end tag
--EDITOR animations start tag
local l_animations =
{
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
