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
				name = "z2",
				posX = 0.5,
				posY = 0.4638885,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.9188007,
				sizeY = 0.9355062,
				image = "a",
				scale9 = true,
				scale9Left = 0.41,
				scale9Right = 0.37,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "db",
					posX = 0.6220188,
					posY = 0.4905233,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6549055,
					sizeY = 0.8787524,
					image = "chengzhanbj2#chengzhanbj2",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "top",
						posX = 0.5,
						posY = 0.8357232,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4128737,
						sizeY = 0.3024178,
						image = "chengzhan#chengzhan",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dt1",
					posX = 0.620959,
					posY = 0.3177334,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6629893,
					sizeY = 0.5276653,
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
						name = "tst",
						posX = 0.5012825,
						posY = 0.5828466,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.988477,
						sizeY = 0.3343749,
						image = "chengzhan#sld",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
						scale9Top = 0.4,
						scale9Bottom = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "dz10",
							varName = "state",
							posX = 0.5,
							posY = 0.4846757,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.251541,
							sizeY = 0.851963,
							text = "城战时间提示",
							color = "FFFBF798",
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "dz9",
							varName = "desc",
							posX = 0.5,
							posY = 0.7791832,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8104976,
							sizeY = 0.851963,
							text = "城战状态提示",
							color = "FF39E5FF",
							fontSize = 22,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "dz11",
							varName = "desc2",
							posX = 0.5,
							posY = 0.1901682,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.251541,
							sizeY = 0.851963,
							text = "城战时间提示2",
							color = "FFFBF798",
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Button",
						name = "cj2",
						varName = "join",
						posX = 0.51026,
						posY = 0.1831184,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2475252,
						sizeY = 0.1744432,
						image = "chengzhan#baoming1",
						imageNormal = "chengzhan#baoming1",
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "asc2",
							varName = "join_text",
							posX = 0.5,
							posY = 0.53125,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 1.003805,
							sizeY = 0.9757967,
							text = "报 名",
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
				{
					prop = {
						etype = "Image",
						name = "ppcg",
						varName = "match",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.1757044,
						sizeY = 0.1181712,
						image = "bpz#ppcg",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "ph",
					varName = "bidShowBtn",
					posX = 0.8735224,
					posY = 0.1564019,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.07907727,
					sizeY = 0.1291636,
					image = "jjcc#gs",
					imageNormal = "jjcc#gs",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "ph2",
					varName = "rewardBtn",
					posX = 0.3633347,
					posY = 0.1564019,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.07907727,
					sizeY = 0.1291636,
					image = "jjcc#jl",
					imageNormal = "jjcc#jl",
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "ztk",
					varName = "schedule",
					posX = 0.620959,
					posY = 0.5480216,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6629893,
					sizeY = 0.5113611,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "lx",
						posX = 0.5,
						posY = 0.5348396,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9901009,
						sizeY = 0.05806617,
						image = "chengzhan#xian1",
					},
					children = {
					{
						prop = {
							etype = "LoadingBar",
							name = "jdt",
							varName = "progressBar",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1,
							sizeY = 0.9999999,
							image = "chengzhan#xian2",
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zt1",
						posX = 0.15,
						posY = 0.5318837,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.227005,
						sizeY = 0.2990408,
						image = "chengzhan#zt1",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "xz1",
							varName = "stateImg1",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 1,
							sizeY = 0.9999999,
							image = "chengzhan#zt2",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "ztz1",
							posX = 0.5169492,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7390243,
							sizeY = 1.101337,
							text = "占城报名",
							color = "FF855BBF",
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
						name = "zt2",
						posX = 0.3833334,
						posY = 0.5318837,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.227005,
						sizeY = 0.2990408,
						image = "chengzhan#zt1",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "xz2",
							varName = "stateImg2",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 1,
							sizeY = 0.9999999,
							image = "chengzhan#zt2",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "ztz2",
							posX = 0.5169492,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7390243,
							sizeY = 1.101337,
							text = "竞速占城",
							color = "FF855BBF",
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
						name = "zt3",
						posX = 0.6166667,
						posY = 0.5318837,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.227005,
						sizeY = 0.2990408,
						image = "chengzhan#zt1",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "xz3",
							varName = "stateImg3",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 1,
							sizeY = 0.9999999,
							image = "chengzhan#zt2",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "ztz3",
							posX = 0.5169492,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7390243,
							sizeY = 1.101337,
							text = "夺城竞标",
							color = "FF855BBF",
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
						name = "zt4",
						posX = 0.85,
						posY = 0.5318837,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.227005,
						sizeY = 0.2990408,
						image = "chengzhan#zt1",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "xz4",
							varName = "stateImg4",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 1,
							sizeY = 0.9999999,
							image = "chengzhan#zt2",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "ztz4",
							posX = 0.5169492,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7390243,
							sizeY = 1.101337,
							text = "争锋夺城",
							color = "FF855BBF",
							fontSize = 22,
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
					name = "ph3",
					varName = "blessBtn",
					posX = 0.4703955,
					posY = 0.1564019,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.07907727,
					sizeY = 0.1291636,
					image = "jjcc#czzg",
					imageNormal = "jjcc#czzg",
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb",
					varName = "scroll",
					posX = 0.6231094,
					posY = 0.5696557,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.2434808,
					horizontal = true,
					showScrollBar = false,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "ph4",
					varName = "finish_btn",
					posX = 0.4716709,
					posY = 0.1556597,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.08162814,
					sizeY = 0.1336175,
					image = "jjcc#shouzhan",
					imageNormal = "jjcc#shouzhan",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "hd",
						varName = "finish_red_point",
						posX = 0.8118282,
						posY = 0.810346,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2903225,
						sizeY = 0.3218391,
						image = "zdte#hd",
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an6",
				varName = "toHelp",
				posX = 0.9346552,
				posY = 0.1131345,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05,
				sizeY = 0.0875,
				image = "tong#bz",
				imageNormal = "tong#bz",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
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
