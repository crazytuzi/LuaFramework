--version = 1
local l_fileType = "layer"

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
			name = "ddd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			image = "b#dd",
			scale9 = true,
			scale9Left = 0.2,
			scale9Right = 0.2,
			scale9Top = 0.2,
			scale9Bottom = 0.2,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "zad",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				disablePressScale = true,
			},
		},
		},
	},
	{
		prop = {
			etype = "Scroll",
			name = "lb",
			varName = "bg_scroll",
			posX = 0.5,
			posY = 0.4635379,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 0.9270759,
			horizontal = true,
		},
	},
	{
		prop = {
			etype = "Image",
			name = "zzt",
			posX = 0.5,
			posY = 0.4663109,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 0.9326218,
			image = "zd#zd_zz.png",
			scale9 = true,
			scale9Left = 0.45,
			scale9Right = 0.45,
			scale9Top = 0.45,
			scale9Bottom = 0.45,
			alpha = 0.8,
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "jd2",
			posX = 0.5,
			posY = 0.1,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 0.2,
			layoutType = 2,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dtb",
				varName = "pos_btn",
				posX = 0.5439808,
				posY = 0.4374999,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.08203125,
				sizeY = 0.6041667,
				image = "zm#zm_xs.png",
				imageNormal = "zm#zm_xs.png",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "a1",
				varName = "task_btn",
				posX = 0.826669,
				posY = 0.4374998,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.078125,
				sizeY = 0.6388889,
				image = "zm#zm_rw.png",
				imageNormal = "zm#zm_rw.png",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "hd",
					varName = "task_point",
					posX = 0.9094653,
					posY = 0.868942,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2,
					sizeY = 0.2282609,
					image = "zdte#hd",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "a2",
				varName = "grob_btn",
				posX = 0.7330906,
				posY = 0.4374999,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.078125,
				sizeY = 0.6319444,
				image = "zm#zm_dk.png",
				imageNormal = "zm#zm_dk.png",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "a3",
				varName = "battle_report",
				posX = 0.354871,
				posY = 0.4374999,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.078125,
				sizeY = 0.6041667,
				image = "zm#zm_zb.png",
				imageNormal = "zm#zm_zb.png",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "a4",
				varName = "rank_btn",
				posX = 0.6395123,
				posY = 0.4374999,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.078125,
				sizeY = 0.6319444,
				image = "zm#zm_ph1.png",
				imageNormal = "zm#zm_ph1.png",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "qih2",
				varName = "clanr_btn",
				posX = 0.9338588,
				posY = 0.4374999,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.078125,
				sizeY = 0.6822612,
				image = "zm#zm_fb.png",
				imageNormal = "zm#zm_fb.png",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "qih",
				varName = "exchange_btn",
				posX = 0.9338588,
				posY = 0.4374999,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.078125,
				sizeY = 0.6822612,
				image = "zm#zm_qh.png",
				imageNormal = "zm#zm_qh.png",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "a5",
				varName = "army_situation",
				posX = 0.4484493,
				posY = 0.4374999,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.078125,
				sizeY = 0.6319444,
				image = "zm#zm_jq1.png",
				imageNormal = "zm#zm_jq1.png",
			},
		},
		},
	},
	{
		prop = {
			etype = "Image",
			name = "btk",
			posX = 0.5,
			posY = 0.9194159,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 0.1544992,
			image = "bp#bp_top2.png",
			scale9 = true,
			scale9Left = 0.45,
			scale9Right = 0.45,
			layoutType = 8,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "mzd2",
				posX = 0.1458367,
				posY = 0.7105993,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2709198,
				sizeY = 0.4495412,
				image = "w#w_mzd.png",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "cyd",
				posX = 0.1201671,
				posY = 0.3077627,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1974702,
				sizeY = 0.3394495,
				image = "w#w_smd3.png",
				alpha = 0.7,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z11",
				varName = "monster_name",
				posX = 0.1663406,
				posY = 0.3239832,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1681147,
				sizeY = 0.3658874,
				text = "宗主：我是谁谁谁啊",
				color = "FFB0FFD9",
				fontOutlineEnable = true,
				fontOutlineColor = "FF0E3B2F",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "bmz",
				varName = "clan_name",
				posX = 0.1952325,
				posY = 0.7304304,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2053037,
				sizeY = 0.4276728,
				text = "宗门名字",
				color = "FFFFF554",
				fontSize = 26,
				fontOutlineEnable = true,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "wp4",
				posX = 0.898056,
				posY = 0.6791223,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1608975,
				sizeY = 0.4587156,
				image = "g#g_f1.png",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "d4",
					posX = 0.1320232,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2851925,
					sizeY = 1.1,
					image = "w#w_zsd.png",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl4",
					varName = "iron_label",
					posX = 0.5581592,
					posY = 0.5000009,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6411085,
					sizeY = 0.8239378,
					text = "994245",
					color = "FFFFFF00",
					fontSize = 24,
					fontOutlineEnable = true,
					fontOutlineColor = "FF804000",
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tb4",
					varName = "iron_icon",
					posX = 0.1269764,
					posY = 0.4877726,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2385053,
					sizeY = 0.9626203,
					image = "zm#zm_xuantie.png",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "bt3",
					varName = "iron_tips_btn",
					posX = 0.4897326,
					posY = 0.5195974,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9672745,
					sizeY = 0.8965399,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "wp5",
				posX = 0.7050136,
				posY = 0.6791221,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1608975,
				sizeY = 0.4587156,
				image = "g#g_f1.png",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "d5",
					posX = 0.1320232,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2851925,
					sizeY = 1.1,
					image = "w#w_zsd.png",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl5",
					varName = "herb_label",
					posX = 0.5581592,
					posY = 0.5000009,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6411085,
					sizeY = 0.8239378,
					text = "994245",
					color = "FFFFFF00",
					fontSize = 24,
					fontOutlineEnable = true,
					fontOutlineColor = "FF804000",
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tb5",
					varName = "herb_icon",
					posX = 0.1299749,
					posY = 0.507603,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2385053,
					sizeY = 0.9626203,
					image = "zm#zm_yaocao.png",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "bt2",
					varName = "herb_tips_btn",
					posX = 0.4885223,
					posY = 0.5195974,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9648532,
					sizeY = 0.8965399,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "wp6",
				varName = "actionRoot",
				posX = 0.5119712,
				posY = 0.679122,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1608975,
				sizeY = 0.4587156,
				image = "g#g_f1.png",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "d6",
					posX = 0.1320232,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2851925,
					sizeY = 1.1,
					image = "w#w_zsd.png",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl6",
					varName = "action_label",
					posX = 0.4915339,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5564139,
					sizeY = 0.8239378,
					text = "994245",
					color = "FFFFFF00",
					fontSize = 24,
					fontOutlineEnable = true,
					fontOutlineColor = "FF804000",
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tb6",
					varName = "action_icon",
					posX = 0.1269764,
					posY = 0.4877726,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2385053,
					sizeY = 0.9626203,
					image = "zm#zm_xingdongli.png",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "jh",
					varName = "add_action",
					posX = 0.8980327,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2185009,
					sizeY = 0.9798684,
					image = "w#w_jia4.png",
					imageNormal = "w#w_jia4.png",
					imagePressed = "w#w_jia2.png",
					imageDisable = "w#w_jia4.png",
					disablePressScale = true,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "bt",
					varName = "action_tips_btn",
					posX = 0.3830866,
					posY = 0.5195974,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7539818,
					sizeY = 0.8965399,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "up_lvl_btn",
				posX = 0.0831064,
				posY = 0.5047067,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1614524,
				sizeY = 0.933386,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "mjd",
				varName = "exp_icon",
				posX = 0.04429583,
				posY = 0.5005983,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.08151903,
				sizeY = 0.99789,
				image = "zm#33",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "sz",
					varName = "level_icon1",
					posX = 0.366067,
					posY = 0.4010431,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2622894,
					sizeY = 0.3603451,
					image = "zm#sz8",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "sz2",
					varName = "level_icon2",
					posX = 0.6339008,
					posY = 0.4010431,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2622894,
					sizeY = 0.3603451,
					image = "zm#sz8",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "nv",
					varName = "girl_bg",
					posX = 0.5,
					posY = 0.3108194,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 1.019163,
					sizeY = 0.5439557,
					image = "zm#nv",
				},
			},
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "jd1",
			posX = 0.0413072,
			posY = 0.6318147,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.07500448,
			sizeY = 0.4267479,
			layoutType = 7,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "zy1",
				varName = "shoutu_root",
				posX = 0.5,
				posY = 0.8851064,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.7261955,
				sizeY = 0.2269064,
				image = "zm#kst",
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "an1",
					varName = "shoutu_btn",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "msd",
					posX = 0.5,
					posY = -0.0824423,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.37704,
					sizeY = 0.3382888,
					image = "d#sld3",
					alpha = 0.7,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "z1",
						varName = "shoutu_time",
						posX = 0.5,
						posY = 0.4346939,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.208062,
						sizeY = 1.469805,
						text = "收徒 3:30",
						color = "FFFEDB45",
						fontOutlineEnable = true,
						fontOutlineColor = "FF102E21",
						hTextAlign = 1,
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zy2",
				varName = "contest_root",
				posX = 0.5,
				posY = 0.5765131,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.7261955,
				sizeY = 0.2269064,
				image = "zm#kbw",
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "an2",
					varName = "contest_btn",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "msd2",
					posX = 0.5,
					posY = -0.0824423,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.37704,
					sizeY = 0.3382888,
					image = "d#sld3",
					alpha = 0.7,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "z4",
						varName = "contest_time",
						posX = 0.5,
						posY = 0.4346939,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.208062,
						sizeY = 1.469805,
						text = "收徒 3:30",
						color = "FFFEDB45",
						fontOutlineEnable = true,
						fontOutlineColor = "FF102E21",
						hTextAlign = 1,
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zy3",
				varName = "enemy_root",
				posX = 0.5,
				posY = 0.2679197,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.7261955,
				sizeY = 0.2269064,
				image = "zm#diqing",
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "an3",
					varName = "enemy_btn",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "msd3",
					posX = 0.5,
					posY = -0.0824423,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.37704,
					sizeY = 0.3382888,
					image = "d#sld3",
					alpha = 0.7,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "z5",
						varName = "shoutu_time3",
						posX = 0.5,
						posY = 0.4346939,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.208062,
						sizeY = 1.469805,
						text = "敌情",
						color = "FFFEDB45",
						fontOutlineEnable = true,
						fontOutlineColor = "FF102E21",
						hTextAlign = 1,
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zy4",
				varName = "attck_root",
				posX = 0.5,
				posY = -0.04067357,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.7261955,
				sizeY = 0.2269064,
				image = "zm#xingjun",
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "an4",
					varName = "attack_btn",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "msd4",
					posX = 0.5,
					posY = -0.0824423,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.37704,
					sizeY = 0.3382888,
					image = "d#sld3",
					alpha = 0.7,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "z6",
						varName = "attack_label",
						posX = 0.5,
						posY = 0.4346939,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.208062,
						sizeY = 1.469805,
						text = "行军",
						color = "FFFEDB45",
						fontOutlineEnable = true,
						fontOutlineColor = "FF102E21",
						hTextAlign = 1,
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zy5",
				varName = "help_root",
				posX = 0.5,
				posY = -0.3492669,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.7261955,
				sizeY = 0.2269064,
				image = "zm#xingjun",
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "an5",
					varName = "help_btn",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "msd5",
					posX = 0.5,
					posY = -0.0824423,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.37704,
					sizeY = 0.3382888,
					image = "d#sld3",
					alpha = 0.7,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "z7",
						varName = "attack_label2",
						posX = 0.5,
						posY = 0.4346939,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.208062,
						sizeY = 1.469805,
						text = "支援",
						color = "FFFEDB45",
						fontOutlineEnable = true,
						fontOutlineColor = "FF102E21",
						hTextAlign = 1,
					},
				},
				},
			},
			},
		},
		},
	},
	{
		prop = {
			etype = "Button",
			name = "t",
			varName = "onCloseBtn",
			posX = 0.06243786,
			posY = 0.09095004,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.0609375,
			sizeY = 0.08333334,
		},
	},
	},
}
--EDITOR elements end tag
--EDITOR animations start tag
local l_animations =
{
	tc = {
		zb1 = {
			rotate = {{0, {0}}, {500, {300}}, },
		},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
