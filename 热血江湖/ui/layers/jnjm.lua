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
			name = "jdk",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			layoutType = 8,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "padtop",
				varName = "padtop",
				posX = 0.5,
				posY = 0.9406416,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 1,
				sizeY = 0.1152778,
				image = "h#qd",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				alphaCascade = true,
				layoutType = 8,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "uu2",
					posX = 0.1849927,
					posY = 0.5602064,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2257813,
					sizeY = 0.7710842,
					image = "ty#pad2",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "uu1",
					posX = 0.169735,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.07109375,
					sizeY = 0.4337349,
					image = "ji#wg",
				},
			},
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
				posX = 0.4933696,
				posY = 0.4577084,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8890625,
				sizeY = 0.8666667,
				image = "h#db",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "k2",
				varName = "skill_root",
				posX = 0.5670766,
				posY = 0.4462167,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7472093,
				sizeY = 0.8430555,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dt2",
					posX = 0.4832706,
					posY = 0.5128247,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9740649,
					sizeY = 0.9474155,
					image = "h#d2",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
					alpha = 0.7,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lb",
						varName = "scroll",
						posX = 0.5003834,
						posY = 0.5004981,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9993619,
						sizeY = 0.9851154,
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "f1",
				varName = "skill_menu",
				posX = 0.1240512,
				posY = 0.4525055,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1404017,
				sizeY = 0.8506796,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dt1",
					posX = 0.5333864,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7845791,
					sizeY = 0.919567,
					image = "h#dw2",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "hh",
						posX = 0.5,
						posY = 0.9415989,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.218117,
						sizeY = 0.07243185,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "s1",
							posX = 0.5,
							posY = 0.575,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.003432,
							sizeY = 1,
							text = "武功栏",
							color = "FF911D02",
							fontSize = 24,
							fontOutlineColor = "FF112926",
							hTextAlign = 1,
							vTextAlign = 1,
							colorTL = "FFB7FFF7",
							colorTR = "FFB7FFF7",
							colorBR = "FF52D7B0",
							colorBL = "FF52D7B0",
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "hs",
						posX = 0.5,
						posY = 0.4909075,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2127659,
						sizeY = 0.5585234,
						image = "b#dd",
						scale9 = true,
						scale9Left = 0.2,
						scale9Right = 0.2,
						scale9Top = 0.2,
						scale9Bottom = 0.2,
						alpha = 0.2,
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "qh7",
				varName = "xinfa_btn",
				posX = 0.9646873,
				posY = 0.5633264,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0640625,
				sizeY = 0.1958333,
				image = "tong#yq1",
				imageNormal = "tong#yq1",
				imagePressed = "chu1#yq2",
				imageDisable = "tong#yq1",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "xhd1",
					varName = "red_point_1",
					posX = 0.6680423,
					posY = 0.791844,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3292683,
					sizeY = 0.1985816,
					image = "zdte#hd",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "yz2",
					posX = 0.4442066,
					posY = 0.4447284,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4580076,
					sizeY = 0.8378806,
					text = "气功",
					color = "FFFBFFCC",
					fontSize = 26,
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
				name = "qh8",
				varName = "skill_btn",
				posX = 0.9646873,
				posY = 0.7447988,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0640625,
				sizeY = 0.1958333,
				image = "tong#yq1",
				imageNormal = "tong#yq1",
				imagePressed = "chu1#yq2",
				imageDisable = "tong#yq1",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "xhd2",
					varName = "red_point_2",
					posX = 0.6680423,
					posY = 0.791844,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3292683,
					sizeY = 0.1985816,
					image = "zdte#hd",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "yz",
					posX = 0.4442066,
					posY = 0.4447284,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4580076,
					sizeY = 0.8378806,
					text = "武功",
					color = "FFFBFFCC",
					fontSize = 26,
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
				name = "qh9",
				varName = "jueji_btn",
				posX = 0.9646873,
				posY = 0.3818538,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0640625,
				sizeY = 0.1958333,
				image = "tong#yq1",
				imageNormal = "tong#yq1",
				imagePressed = "chu1#yq2",
				imageDisable = "tong#yq1",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "xhd3",
					varName = "red_point_3",
					posX = 0.6680423,
					posY = 0.791844,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3292683,
					sizeY = 0.1985816,
					image = "zdte#hd",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "yz3",
					posX = 0.4442066,
					posY = 0.4447284,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4580076,
					sizeY = 0.8378806,
					text = "绝技",
					color = "FFFBFFCC",
					fontSize = 26,
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
				etype = "Image",
				name = "xian1",
				varName = "xian",
				posX = 0.08181932,
				posY = 0.8612125,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.04391268,
				sizeY = 0.009706705,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jn1",
				varName = "skill_pos1",
				posX = 0.1287387,
				posY = 0.7034186,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.06484375,
				sizeY = 0.1138889,
				image = "jn#jnd2",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "jnk1",
					varName = "skill1",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.168675,
					sizeY = 1.060976,
					image = "jn#jnbai",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "t1",
					varName = "skill1Small",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.8433735,
					sizeY = 0.8536593,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zzz2",
					varName = "lock3",
					posX = 0.5457217,
					posY = 0.5043908,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.8915663,
					sizeY = 0.9390243,
					image = "jn#jng",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jn2",
				varName = "skill_pos2",
				posX = 0.1287387,
				posY = 0.5499839,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.06484375,
				sizeY = 0.1138889,
				image = "jn#jnd2",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "jnk2",
					varName = "skill2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.168675,
					sizeY = 1.060976,
					image = "jn#jnbai",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "t2",
					varName = "skill2Small",
					posX = 0.4999999,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.8433735,
					sizeY = 0.8536593,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zzz3",
					posX = 0.5457217,
					posY = 0.5043908,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.8915663,
					sizeY = 0.9390243,
					image = "jn#jng",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jn3",
				varName = "skill_pos3",
				posX = 0.1287387,
				posY = 0.3965492,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.06484375,
				sizeY = 0.1138889,
				image = "jn#jnd2",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "jnk3",
					varName = "skill3",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.168675,
					sizeY = 1.060976,
					image = "jn#jnbai",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "t3",
					varName = "skill3Small",
					posX = 0.4999999,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.8433735,
					sizeY = 0.8536593,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zzz4",
					posX = 0.5457217,
					posY = 0.5043908,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.8915663,
					sizeY = 0.9390243,
					image = "jn#jng",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jn4",
				varName = "skill_pos4",
				posX = 0.1287387,
				posY = 0.2431144,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.06484375,
				sizeY = 0.1138889,
				image = "jn#jnd2",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "jnk4",
					varName = "skill4",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.168675,
					sizeY = 1.060976,
					image = "jn#jnbai",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "t4",
					varName = "skill4Small",
					posX = 0.4999999,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.8433735,
					sizeY = 0.8536593,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zzz5",
					posX = 0.5457217,
					posY = 0.5043908,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.8915663,
					sizeY = 0.9390243,
					image = "jn#jng",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "a1",
				varName = "move_btn",
				posX = 0.0586862,
				posY = 0.8910236,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.07613727,
				sizeY = 0.135355,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sjtop",
				varName = "sjtop",
				posX = 0.1365246,
				posY = 0.8161361,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2648438,
				sizeY = 0.3138889,
				image = "ty#zs",
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "hh2",
					posX = 0.4987741,
					posY = 0.8420042,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2684365,
					sizeY = 0.159292,
					image = "ji#wg",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "bz",
				varName = "help_btn",
				posX = 0.9611872,
				posY = 0.1089541,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.04765625,
				sizeY = 0.09166667,
				image = "tong#bz",
				imageNormal = "tong#bz",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "bz2",
				varName = "trPreviewBtn",
				posX = 0.9564996,
				posY = 0.2033993,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05,
				sizeY = 0.0875,
				image = "ty#yulan",
				imageNormal = "ty#yulan",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "close_btn",
				posX = 0.9352205,
				posY = 0.8868529,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0703125,
				sizeY = 0.125,
				image = "chu1#gb",
				imageNormal = "chu1#gb",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "padzs",
				varName = "padzs",
				posX = 0.05545116,
				posY = 0.8730147,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.028125,
				sizeY = 0.1,
				image = "ty#pad1",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "dca",
				varName = "skillPre_btn",
				posX = 0.1287259,
				posY = 0.1062026,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1273438,
				sizeY = 0.08888889,
				image = "chu1#an2",
				imageNormal = "chu1#an2",
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "dcz",
					varName = "skillPreBtn_txt",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9309287,
					sizeY = 0.733375,
					text = "汇出组合",
					fontSize = 24,
					fontOutlineEnable = true,
					fontOutlineColor = "FF2A6953",
					fontOutlineSize = 2,
					hTextAlign = 1,
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
	tc1 = {
		jn1 = {
			alpha = {{0, {0}}, },
		},
		jn2 = {
			alpha = {{0, {0}}, },
		},
		jn3 = {
			alpha = {{0, {0}}, },
		},
		jn4 = {
			alpha = {{0, {0}}, },
		},
		f1 = {
			alpha = {{0, {0}}, },
		},
		k2 = {
			move = {{0, {540.2433,326.6106,0}}, },
			scale = {{0, {1,1,1}}, },
		},
	},
	tc2 = {
		k2 = {
			move = {{0, {611.6229,326.6106,0}}, },
			scale = {{0, {1,1,1}}, },
		},
		f1 = {
			alpha = {{0, {1}}, },
		},
		jn1 = {
			alpha = {{0, {1}}, },
		},
		jn2 = {
			alpha = {{0, {1}}, },
		},
		jn3 = {
			alpha = {{0, {1}}, },
		},
		jn4 = {
			alpha = {{0, {1}}, },
		},
	},
	gy = {
	},
	gy3 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
