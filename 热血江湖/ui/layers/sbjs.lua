--version = 1
local l_fileType = "layer"

local UIUtil = require "ui/common/UIUtil"

--EDITOR elements start tag
local eleRoot = 
{
	prop = {
		etype = "Layer",
		name = "root",
		varName = "Bonuspanel",
		posX = 0,
		posY = 0,
		anchorX = 0,
		anchorY = 0,
		soundEffectOpen = "audio/rxjh/UI/ui_lose.ogg",
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
				name = "dt",
				posX = 0.5007792,
				posY = 0.4829454,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.9742247,
				image = "js#js_dt.png",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "top",
					posX = 0.6240124,
					posY = 0.845461,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3304687,
					sizeY = 0.09266628,
					image = "js#js_sb.png",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "s1",
					posX = 0.2129163,
					posY = 0.7414019,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.234375,
					sizeY = 0.3464293,
					image = "js#js_sbt.png",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tj1",
					varName = "show_difficulty1",
					posX = 0.2106628,
					posY = 0.534829,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2572602,
					sizeY = 0.06450532,
					image = "d#smd2",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "g1",
						posX = 0.3701343,
						posY = 0.5408164,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5252963,
						sizeY = 1.101878,
						text = "副本类型",
						color = "FF9AFFE6",
						fontSize = 26,
						fontOutlineEnable = true,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "g2",
						varName = "difficulty",
						posX = 0.6530238,
						posY = 0.5408164,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4511137,
						sizeY = 1.101878,
						text = "普通",
						color = "FFFFF554",
						fontSize = 26,
						fontOutlineEnable = true,
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tj2",
					varName = "show_difficulty2",
					posX = 0.2106628,
					posY = 0.4551624,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2572602,
					sizeY = 0.06450532,
					image = "d#smd2",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "g3",
						posX = 0.3701343,
						posY = 0.5408164,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5252963,
						sizeY = 1.101878,
						text = "通关时间",
						color = "FF9AFFE6",
						fontSize = 26,
						fontOutlineEnable = true,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "g4",
						varName = "finishTime",
						posX = 0.6530238,
						posY = 0.5408164,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4511137,
						sizeY = 1.101878,
						text = "普通",
						color = "FFFFF554",
						fontSize = 26,
						fontOutlineEnable = true,
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tj3",
					varName = "show_difficulty3",
					posX = 0.2106628,
					posY = 0.3754958,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2572602,
					sizeY = 0.06450532,
					image = "d#smd2",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "g5",
						posX = 0.3701343,
						posY = 0.5408164,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5252963,
						sizeY = 1.101878,
						text = "死亡次数",
						color = "FF9AFFE6",
						fontSize = 26,
						fontOutlineEnable = true,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "g6",
						varName = "deadTimes",
						posX = 0.6530238,
						posY = 0.5408164,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4511137,
						sizeY = 1.101878,
						text = "普通",
						color = "FFFFF554",
						fontSize = 26,
						fontOutlineEnable = true,
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tj4",
					varName = "show_difficulty4",
					posX = 0.2106628,
					posY = 0.2958292,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.2572602,
					sizeY = 0.06450532,
					image = "d#smd2",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "g7",
						posX = 0.3701343,
						posY = 0.5408164,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5252963,
						sizeY = 1.101878,
						text = "杀怪数量",
						color = "FF9AFFE6",
						fontSize = 26,
						fontOutlineEnable = true,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "g8",
						varName = "killMonsters",
						posX = 0.6530238,
						posY = 0.5408164,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4511137,
						sizeY = 1.101878,
						text = "普通",
						color = "FFFFF554",
						fontSize = 26,
						fontOutlineEnable = true,
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "tcsj",
					varName = "daojishi",
					posX = 0.2106628,
					posY = 0.2085756,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2750408,
					sizeY = 0.1309716,
					text = "xx秒后退出副本",
					fontSize = 22,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "kk1",
				posX = 0.6505759,
				posY = 0.6511885,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5335376,
				sizeY = 0.244048,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "hb1",
					posX = 0.1681998,
					posY = 0.8425918,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.07321414,
					sizeY = 0.2845524,
					image = "ty#exp",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hb2",
					posX = 0.4893735,
					posY = 0.8425917,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.07576307,
					sizeY = 0.294459,
					image = "tb#tb_tongqian.png",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "suo",
						posX = 0.672652,
						posY = 0.3037047,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.579814,
						sizeY = 0.579814,
						image = "tb#tb_suo.png",
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z1",
					varName = "expLabel",
					posX = 0.3171868,
					posY = 0.8425917,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2136822,
					sizeY = 0.3482867,
					text = "经验值+duos",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z2",
					varName = "coinLabel",
					posX = 0.6550011,
					posY = 0.8425916,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2136822,
					sizeY = 0.3482867,
					text = "金币值+duos",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb",
					varName = "scroll",
					posX = 0.5331275,
					posY = 0.39779,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8337449,
					sizeY = 0.5340945,
					horizontal = true,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jt1",
					posX = 0.9766168,
					posY = 0.3977902,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.04392849,
					sizeY = 0.2219509,
					image = "cl2#yjt",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jt2",
					posX = 0.08777682,
					posY = 0.3977902,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.04392849,
					sizeY = 0.2219509,
					image = "cl2#yjt",
					flippedX = true,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "tc",
				varName = "exitBtn",
				posX = 0.8926398,
				posY = 0.06947426,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1359375,
				sizeY = 0.09166667,
				image = "chu1#an1",
				imageNormal = "chu1#an1",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "lkz",
					posX = 0.5,
					posY = 0.5454545,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8421121,
					sizeY = 0.9350044,
					text = "退出副本",
					fontSize = 24,
					fontOutlineEnable = true,
					fontOutlineColor = "FFB35F1D",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "kk2",
				posX = 0.6583336,
				posY = 0.3302906,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.5709358,
				sizeY = 0.4046355,
			},
			children = {
			{
				prop = {
					etype = "Grid",
					name = "ts1",
					posX = 0.1622019,
					posY = 0.5082499,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2778488,
					sizeY = 0.9066547,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "kp2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 1.312935,
						sizeY = 1.215253,
						image = "kp#kp",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "topz2",
							posX = 0.5,
							posY = 0.4819767,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.5372046,
							sizeY = 0.3305675,
							text = "装备强化可提升人物属性和战力",
							color = "FF634624",
							fontSize = 22,
							fontOutlineColor = "FF69360B",
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "kp1",
							varName = "cover1",
							posX = 0.4962545,
							posY = 0.6359684,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.5562423,
							sizeY = 0.2762498,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "ds",
							posX = 0.5,
							posY = 0.7428136,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.4838834,
							sizeY = 0.09034266,
							image = "js#zbqh2",
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "ts4",
					posX = 0.5114791,
					posY = 0.5082499,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2778488,
					sizeY = 0.9066547,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "kp7",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 1.312935,
						sizeY = 1.215253,
						image = "kp#kp",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "topz7",
							posX = 0.5,
							posY = 0.4819767,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.5372046,
							sizeY = 0.3305675,
							text = "升级武功可提升攻防能力",
							color = "FF634624",
							fontSize = 22,
							fontOutlineColor = "FF69360B",
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "kp8",
							varName = "cover2",
							posX = 0.4962545,
							posY = 0.6359684,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.5562423,
							sizeY = 0.2762498,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "ds2",
							posX = 0.5,
							posY = 0.7428136,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.4801323,
							sizeY = 0.09034266,
							image = "js#wgsj",
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "ts5",
					posX = 0.8593879,
					posY = 0.5082498,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2778488,
					sizeY = 0.9066547,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "kp9",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 1.312935,
						sizeY = 1.215253,
						image = "kp#kp",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "topz8",
							posX = 0.5,
							posY = 0.4819767,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.5372046,
							sizeY = 0.3305675,
							text = "提升宠物等级可增强其战斗能力",
							color = "FF634624",
							fontSize = 22,
							fontOutlineColor = "FF69360B",
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "kp10",
							varName = "cover3",
							posX = 0.4962545,
							posY = 0.6359684,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.5562423,
							sizeY = 0.2762498,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "ds3",
							posX = 0.5,
							posY = 0.7428136,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.4801323,
							sizeY = 0.09034266,
							image = "js#scts",
						},
					},
					},
				},
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
