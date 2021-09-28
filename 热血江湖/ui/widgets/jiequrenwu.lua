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
			etype = "Grid",
			name = "jiequrenwu",
			varName = "taskRoot",
			posX = 0.4969059,
			posY = 0.4514294,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.9359624,
			sizeY = 0.8225504,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "db1",
				posX = 0.5033388,
				posY = 0.4663751,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.891665,
				sizeY = 0.8878694,
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
					etype = "Scroll",
					name = "lb1",
					varName = "child_scroll",
					posX = 0.1472416,
					posY = 0.5019726,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2855155,
					sizeY = 0.9799424,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xh1",
					posX = 0.8709176,
					posY = 0.8100516,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2433903,
					sizeY = 0.2231658,
					image = "g#g_zmrwd.png",
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
						name = "xhzz",
						posX = 0.5,
						posY = 0.9973004,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6984732,
						sizeY = 0.2140912,
						image = "zm#zm_dg.png",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "cdd",
						posX = 0.5,
						posY = 0.8478251,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.812977,
						sizeY = 0.2695652,
						image = "w#w_cdd.png",
						alpha = 0.2,
						flippedY = true,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zs1",
						posX = 0.1835297,
						posY = 0.9948123,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3432826,
						sizeY = 0.07826087,
						image = "w#w_zhuangshixian.png",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zs2",
						posX = 0.8469696,
						posY = 0.9948122,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3432826,
						sizeY = 0.07826087,
						image = "w#w_zhuangshixian.png",
						flippedX = true,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xhz",
						posX = 0.5,
						posY = 0.9774714,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2442748,
						sizeY = 0.226087,
						image = "zm#zm_xiaohao.png",
					},
				},
				{
					prop = {
						etype = "RichText",
						name = "rwtj",
						varName = "child_count",
						posX = 0.5,
						posY = 0.6338363,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8442085,
						sizeY = 0.4090437,
						text = "普通弟子：150",
						color = "FF5AF6D3",
						fontSize = 24,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "rwtj2",
						varName = "commonChild_label",
						posX = 0.5,
						posY = 0.372967,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8442085,
						sizeY = 0.4090437,
						text = "剩余123456人",
						color = "FF388774",
						fontSize = 22,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xh2",
					posX = 0.8709176,
					posY = 0.5012526,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2433903,
					sizeY = 0.2935265,
					image = "g#g_zmrwd.png",
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
						name = "xhzz2",
						posX = 0.5,
						posY = 0.9973004,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6984732,
						sizeY = 0.2140912,
						image = "zm#zm_dg.png",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "cdd2",
						posX = 0.5,
						posY = 0.8478251,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.812977,
						sizeY = 0.2695652,
						image = "w#w_cdd.png",
						alpha = 0.2,
						flippedY = true,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zs3",
						posX = 0.1835297,
						posY = 0.9948123,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3432826,
						sizeY = 0.0595011,
						image = "w#w_zhuangshixian.png",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zs4",
						posX = 0.8469696,
						posY = 0.9948122,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3432826,
						sizeY = 0.0595011,
						image = "w#w_zhuangshixian.png",
						flippedX = true,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xhz2",
						posX = 0.5,
						posY = 0.9774714,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2442748,
						sizeY = 0.171892,
						image = "zm#zm_huode.png",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "jy1",
						posX = 0.1792373,
						posY = 0.6719181,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1689811,
						sizeY = 0.2926995,
						image = "zm#zm_exp.png",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "jys",
							varName = "exp_count",
							posX = 2.343509,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 2.345847,
							sizeY = 0.960366,
							text = "123456",
							fontOutlineEnable = true,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xt1",
						posX = 0.6050093,
						posY = 0.3087685,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1689811,
						sizeY = 0.2926995,
						image = "zm#zm_xuantie.png",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "jys2",
							varName = "iron_count",
							posX = 2.134832,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.928492,
							sizeY = 0.960366,
							text = "x200",
							fontOutlineEnable = true,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "cy1",
						posX = 0.1792374,
						posY = 0.3087687,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1689811,
						sizeY = 0.2926995,
						image = "zm#zm_yaocao.png",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "jys3",
							varName = "herb_count",
							posX = 2.134832,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.928492,
							sizeY = 0.960366,
							text = "200",
							fontOutlineEnable = true,
							vTextAlign = 1,
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xian",
					posX = 0.31,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5036731,
					sizeY = 0.06015773,
					image = "w#w_cdd.png",
					rotation = 90,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xian2",
					posX = 0.73,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4919237,
					sizeY = 0.06015774,
					image = "w#w_cdd.png",
					rotation = -90,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tb",
				varName = "task_bg_icon",
				posX = 0.5220213,
				posY = 0.7219018,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.375616,
				sizeY = 0.2515888,
				image = "zm#zm_rwt1.png",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "mzd3",
				posX = 0.6329088,
				posY = 0.8624954,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.156924,
				sizeY = 0.03374887,
				image = "zm#zm_btd.png",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xx1",
				varName = "star4",
				posX = 0.6540009,
				posY = 0.8604631,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.03171869,
				sizeY = 0.06416357,
				image = "ty#xx",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "txk1",
				varName = "childRoot1",
				posX = 0.394109,
				posY = 0.4878261,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1327177,
				sizeY = 0.2701624,
				image = "zm#zm_dzd1.png",
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "txa",
					varName = "outBtn1",
					posX = 0.4962549,
					posY = 0.5202577,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8174351,
					sizeY = 0.7737314,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tx",
					varName = "headIcon1",
					posX = 0.4941142,
					posY = 0.5285401,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.4645164,
					sizeY = 0.4616134,
					image = "tx#tx_hongjunf.png",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mz",
					varName = "childName1",
					posX = 0.5,
					posY = 0.1449898,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7273045,
					sizeY = 0.239962,
					text = "张翠山",
					color = "FF68DFBA",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jxz1",
					varName = "ingIcon1",
					posX = 0.5,
					posY = 0.56875,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8238992,
					sizeY = 0.6625001,
					image = "zm#zm_dzsy.png",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "txk2",
				varName = "childRoot2",
				posX = 0.5212162,
				posY = 0.4878261,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1327177,
				sizeY = 0.2701624,
				image = "zm#zm_dzd1.png",
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "txa2",
					varName = "outBtn2",
					posX = 0.4962549,
					posY = 0.4705061,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8174351,
					sizeY = 0.8738616,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tx2",
					varName = "headIcon2",
					posX = 0.4941142,
					posY = 0.5285401,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.4645164,
					sizeY = 0.4616134,
					image = "tx#tx_hongjun.png",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mz2",
					varName = "childName2",
					posX = 0.5,
					posY = 0.1449898,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7273045,
					sizeY = 0.239962,
					text = "张翠山",
					color = "FF68DFBA",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jxz2",
					varName = "ingIcon2",
					posX = 0.5,
					posY = 0.56875,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8238992,
					sizeY = 0.6625001,
					image = "zm#zm_dzsy.png",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "txk3",
				varName = "childRoot3",
				posX = 0.6479059,
				posY = 0.4878261,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.131883,
				sizeY = 0.2667854,
				image = "zm#zm_dzd3.png",
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "txa3",
					varName = "outBtn3",
					posX = 0.4962549,
					posY = 0.4738743,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8174351,
					sizeY = 0.8671256,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tx3",
					varName = "headIcon3",
					posX = 0.4941142,
					posY = 0.5285401,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.4645164,
					sizeY = 0.4616134,
					image = "a",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mz3",
					varName = "childName3",
					posX = 0.5,
					posY = 0.145148,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7273045,
					sizeY = 0.239962,
					color = "FF68DFBA",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jxz3",
					varName = "ingIcon3",
					posX = 0.5,
					posY = 0.56875,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8238992,
					sizeY = 0.6625001,
					image = "zm#zm_dzsy.png",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "db2",
				posX = 0.5196455,
				posY = 0.19213,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3857197,
				sizeY = 0.2888006,
				image = "g#g_d1.png",
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
					name = "mzd",
					posX = 0.2385842,
					posY = 0.809365,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4068344,
					sizeY = 0.1578595,
					image = "zm#zm_btd.png",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "tit",
					posX = 0.2005282,
					posY = 0.8067885,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.354482,
					sizeY = 0.2710398,
					text = "任务内容:",
					color = "FF89FFD4",
					fontSize = 24,
					fontOutlineEnable = true,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "rwms",
					varName = "taskDesc_label",
					posX = 0.5,
					posY = 0.3393809,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9568843,
					sizeY = 0.6083417,
					text = "宗门外还有大量土地需要荒芜，为了宗门的大业考虑，宗主希望你带领精英弟子以及普通弟子前往垦荒种植些小麦。",
					color = "FF63C2A8",
					fontSize = 22,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "wp4",
					posX = 0.792315,
					posY = 0.7938992,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.324657,
					sizeY = 0.2882497,
					image = "g#g_f1.png",
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "d4",
						posX = 0.1520197,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3866011,
						sizeY = 1.11558,
						image = "w#w_zsd.png",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "lx1",
							varName = "task_icon",
							posX = 0.4813211,
							posY = 0.5055725,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.7745846,
							sizeY = 0.8168346,
							image = "tx#tx_hongjun.png",
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "rwlx",
					varName = "task_desc",
					posX = 0.8278159,
					posY = 0.8043238,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2752043,
					sizeY = 0.2973885,
					text = "开荒",
					color = "FF5AF6D3",
					fontSize = 24,
					fontOutlineEnable = true,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "rwcs",
				varName = "get_count_label",
				posX = 0.788253,
				posY = 0.9593354,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2951511,
				sizeY = 0.1030156,
				text = "已接取次数：0/10",
				color = "FFC2F9E8",
				fontSize = 24,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xx2",
				varName = "star2",
				posX = 0.5977898,
				posY = 0.8604631,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.03171869,
				sizeY = 0.06416357,
				image = "ty#xx",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xx3",
				varName = "star3",
				posX = 0.6258953,
				posY = 0.8604631,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.03171869,
				sizeY = 0.06416357,
				image = "ty#xx",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xx4",
				varName = "star1",
				posX = 0.5696842,
				posY = 0.8604631,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.03171869,
				sizeY = 0.06416357,
				image = "ty#xx",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xx5",
				varName = "star5",
				posX = 0.6821064,
				posY = 0.8604631,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.03171869,
				sizeY = 0.06416357,
				image = "ty#xx",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "mzd2",
				posX = 0.4202504,
				posY = 0.8624955,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.156924,
				sizeY = 0.03374887,
				image = "zm#zm_btd.png",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "rwm",
				varName = "taskName_label",
				posX = 0.4068187,
				posY = 0.863154,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1787879,
				sizeY = 0.07888681,
				text = "开荒三亩地",
				color = "FFCAFF8C",
				fontSize = 24,
				fontOutlineEnable = true,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "jq",
				varName = "getRoot",
				posX = 0.8366663,
				posY = 0.1831272,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2266667,
				sizeY = 0.3135468,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "wcsj",
					varName = "time_label",
					posX = 0.5,
					posY = 0.5939277,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9192629,
					sizeY = 0.3067638,
					text = "1小时25分",
					fontSize = 24,
					fontOutlineEnable = true,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wcsj2",
					posX = 0.5,
					posY = 0.7972035,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8347042,
					sizeY = 0.2550742,
					text = "预计完成时间：",
					color = "FF82D9BF",
					fontSize = 22,
					fontOutlineEnable = true,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an3",
					varName = "get_btn",
					posX = 0.5,
					posY = 0.2891726,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.5045038,
					sizeY = 0.2584901,
					image = "w#w_ee4.png",
					imageNormal = "w#w_ee4.png",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "az",
						varName = "get_label",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6716112,
						sizeY = 0.7685403,
						text = "接 取",
						color = "FFF1FFB0",
						fontSize = 24,
						fontOutlineEnable = true,
						fontOutlineColor = "FF69360B",
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
				etype = "Grid",
				name = "jxz",
				varName = "IngRoot",
				posX = 0.8366663,
				posY = 0.1831272,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.2266667,
				sizeY = 0.3135468,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "wcsj3",
					varName = "time_label2",
					posX = 0.5,
					posY = 0.5939277,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9192629,
					sizeY = 0.3067638,
					text = "剩余1小时25分钟",
					color = "FFF93A55",
					fontSize = 24,
					fontOutlineEnable = true,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wcsj4",
					posX = 0.5,
					posY = 0.7972035,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8347042,
					sizeY = 0.2550742,
					text = "进行中....",
					color = "FFF93A55",
					fontSize = 22,
					fontOutlineEnable = true,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an4",
					varName = "get_btn2",
					posX = 0.5,
					posY = 0.2891726,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.5045038,
					sizeY = 0.2584901,
					image = "w#w_qq4.png",
					imageNormal = "w#w_qq4.png",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "az4",
						varName = "get_label2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6716112,
						sizeY = 0.7685403,
						text = "放 弃",
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
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "lqjl",
				varName = "finishRoot",
				posX = 0.8366663,
				posY = 0.1831272,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.2266667,
				sizeY = 0.3135468,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "an5",
					varName = "get_btn3",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.5045038,
					sizeY = 0.2584901,
					image = "w#w_ee4.png",
					imageNormal = "w#w_ee4.png",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "az6",
						varName = "get_label3",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 1,
						text = "领取奖励",
						color = "FFF1FFB0",
						fontSize = 24,
						fontOutlineEnable = true,
						fontOutlineColor = "FF69360B",
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
				etype = "Button",
				name = "td",
				varName = "move_btn",
				posX = 0.02624934,
				posY = 0.8482599,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.06093327,
				sizeY = 0.1232616,
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
