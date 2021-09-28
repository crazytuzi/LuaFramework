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
			alpha = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dd",
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
			etype = "Grid",
			name = "ysjm",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "kk1",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9023438,
				sizeY = 0.9722222,
				image = "g#dt2.png",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.1,
				scale9Bottom = 0.1,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "zz",
					posX = 0.5,
					posY = 0.8885087,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9883751,
					sizeY = 0.08085481,
					image = "w#w_dw.png",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt4",
				posX = 0.5000002,
				posY = 0.9233332,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.890625,
				sizeY = 0.1,
				image = "g#g_topd.png",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "g2",
					posX = 0.1319578,
					posY = 0.2003955,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1883489,
					sizeY = 0.3827161,
					image = "w#w_cdd.png",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "lm2",
					posX = 0.1319578,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1829926,
					sizeY = 0.9964024,
					image = "zm#zm_zongmenrenwu.png",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "wp1",
					varName = "actionRoot",
					posX = 0.4902945,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1788474,
					sizeY = 0.7086167,
					image = "g#g_f1.png",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "d1",
						posX = 0.1320232,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3124915,
						sizeY = 1.1,
						image = "w#w_zsd.png",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sl1",
						varName = "action_value",
						posX = 0.4915339,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5564139,
						sizeY = 0.8239378,
						text = "3421万",
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
						name = "tb1",
						varName = "action_icon",
						posX = 0.1299749,
						posY = 0.507603,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.2418701,
						sizeY = 0.9690956,
						image = "zm#zm_xingdongli.png",
					},
				},
				{
					prop = {
						etype = "Button",
						name = "j1",
						varName = "addAction_btn",
						posX = 0.9012117,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2207115,
						sizeY = 0.9800001,
						image = "w#w_jia4.png",
						imageNormal = "w#w_jia4.png",
						imagePressed = "w#w_jia2.png",
						imageDisable = "w#w_jia4.png",
						disablePressScale = true,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "wp2",
					posX = 0.692937,
					posY = 0.5000007,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1608838,
					sizeY = 0.7086167,
					image = "g#g_f1.png",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "d2",
						posX = 0.1320232,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3124915,
						sizeY = 1.1,
						image = "w#w_zsd.png",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sl2",
						varName = "herb_value",
						posX = 0.5581592,
						posY = 0.5000009,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6411085,
						sizeY = 0.8239378,
						text = "3421万",
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
						name = "tb2",
						varName = "herb_icon",
						posX = 0.1299749,
						posY = 0.507603,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.2688763,
						sizeY = 0.9690956,
						image = "zm#zm_yaocao.png",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "wp3",
					posX = 0.8881366,
					posY = 0.5000004,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1608838,
					sizeY = 0.7086167,
					image = "g#g_f1.png",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "d3",
						posX = 0.1320232,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3124915,
						sizeY = 1.1,
						image = "w#w_zsd.png",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sl3",
						varName = "iron_value",
						posX = 0.5581592,
						posY = 0.5000009,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6411085,
						sizeY = 0.8239378,
						text = "3421万",
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
						name = "tb3",
						varName = "iron_icon",
						posX = 0.1299749,
						posY = 0.507603,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.2688763,
						sizeY = 0.9690956,
						image = "zm#zm_xuantie.png",
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "zmy",
				varName = "clanRoot",
				posX = 0.3990164,
				posY = 0.8279327,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6824715,
				sizeY = 0.09567583,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "a1",
					varName = "getTask_btn",
					posX = 0.1599867,
					posY = 0.3984557,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.234671,
					sizeY = 1.132296,
					image = "w#w_aa4.png",
					imageNormal = "w#w_aa4.png",
					imagePressed = "w#w_aa2.png",
					imageDisable = "w#w_aa4.png",
					disablePressScale = true,
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
						sizeX = 0.8226202,
						sizeY = 0.575636,
						text = "接取任务",
						color = "FFFBFFCC",
						fontSize = 26,
						fontOutlineEnable = true,
						fontOutlineColor = "FF51361C",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a2",
					varName = "desition_btn",
					posX = 0.376787,
					posY = 0.3984555,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.234671,
					sizeY = 1.132296,
					image = "w#w_aa4.png",
					imageNormal = "w#w_aa4.png",
					imagePressed = "w#w_aa2.png",
					imageDisable = "w#w_aa4.png",
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "az2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8226202,
						sizeY = 0.575636,
						text = "宗主决策",
						color = "FFFBFFCC",
						fontSize = 26,
						fontOutlineEnable = true,
						fontOutlineColor = "FF51361C",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a3",
					varName = "result_btn",
					posX = 0.5935874,
					posY = 0.3984556,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.234671,
					sizeY = 1.132296,
					image = "w#w_aa4.png",
					imageNormal = "w#w_aa4.png",
					imagePressed = "w#w_aa2.png",
					imageDisable = "w#w_aa4.png",
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "az3",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8226202,
						sizeY = 0.575636,
						text = "任务报告",
						color = "FFFBFFCC",
						fontSize = 26,
						fontOutlineEnable = true,
						fontOutlineColor = "FF51361C",
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
				name = "fzmy",
				varName = "otherRoot",
				posX = 0.3990164,
				posY = 0.8279327,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.6824715,
				sizeY = 0.09567583,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "a4",
					varName = "exchangeClan_btn",
					posX = 0.1074153,
					posY = 0.5144052,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1339342,
					sizeY = 0.7403472,
					image = "w#w_ss4.png",
					imageNormal = "w#w_ss4.png",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "az5",
						posX = 0.5,
						posY = 0.5392156,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.000177,
						sizeY = 0.8456007,
						text = "切换宗门",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FF69360B",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "zmmz",
					posX = 0.4520987,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1931425,
					sizeY = 0.5960085,
					text = "当前宗门",
					color = "FF3E9386",
					fontSize = 22,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "zmmz2",
					varName = "clanName_label",
					posX = 0.693813,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2491417,
					sizeY = 0.5960085,
					text = "一二三四五怄气",
					color = "FF98FFDC",
					fontSize = 24,
					fontOutlineEnable = true,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "zjd",
				varName = "new_root",
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
				name = "wk2",
				posX = 0.4996096,
				posY = 0.4999996,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9039825,
				sizeY = 0.9706288,
				image = "g#g_wk.png",
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
					name = "hh",
					posX = 0.04529356,
					posY = 0.9414505,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1322274,
					sizeY = 0.1316443,
					image = "w#w_hehua.png",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "y2",
					posX = 0.9692256,
					posY = 0.02142051,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1175354,
					sizeY = 0.1416607,
					image = "w#w_yun.png",
					flippedX = true,
				},
			},
			{
				prop = {
					etype = "Sprite3D",
					name = "mx",
					varName = "hero_module",
					posX = 0.2550735,
					posY = 0.2244408,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2824913,
					sizeY = 0.5110427,
				},
			},
			},
		},
		},
	},
	{
		prop = {
			etype = "Button",
			name = "gb",
			varName = "onCloseBtn",
			posX = 0.9609603,
			posY = 0.9256893,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.04453125,
			sizeY = 0.07916667,
			image = "chu1#gb",
			imageNormal = "chu1#gb",
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
	guang = {
		guang = {
			alpha = {{0, {0}}, {100, {1}}, {300, {0}}, },
			move = {{0, {561.0784, 0, 0}}, {200, {561.0784,342.0438,0}}, },
		},
		kuang = {
			alpha = {{0, {1}}, {300, {0}}, },
		},
		shua = {
			move = {{0, {563.5392,191.9085,0}}, {300, {563.5392, 500, 0}}, },
			alpha = {{0, {0}}, {100, {1}}, {300, {0}}, },
		},
	},
	guang2 = {
		guang2 = {
			alpha = {{0, {0}}, {100, {1}}, {300, {0}}, },
			move = {{0, {561.0784, 0, 0}}, {200, {561.0784,342.0438,0}}, },
		},
		kuang2 = {
			alpha = {{0, {1}}, {300, {0}}, },
		},
		shua2 = {
			move = {{0, {563.5392,191.9085,0}}, {300, {563.5392, 500, 0}}, },
			alpha = {{0, {0}}, {100, {1}}, {300, {0}}, },
		},
	},
	guang3 = {
		guang3 = {
			alpha = {{0, {0}}, {100, {1}}, {300, {0}}, },
			move = {{0, {561.0784, 0, 0}}, {200, {561.0784,342.0438,0}}, },
		},
		kuang3 = {
			alpha = {{0, {1}}, {300, {0}}, },
		},
		shua3 = {
			move = {{0, {563.5392,191.9085,0}}, {300, {563.5392, 500, 0}}, },
			alpha = {{0, {0}}, {100, {1}}, {300, {0}}, },
		},
	},
	c_shuaxin = {
		{0,"guang", 1, 0},
		{2,"lizi", 1, 0},
	},
	c_shuaxin2 = {
		{0,"guang2", 1, 0},
		{2,"lizi2", 1, 0},
	},
	c_shuaxin3 = {
		{0,"guang3", 1, 0},
		{2,"lizi3", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
