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
				name = "dt",
				posX = 0.5,
				posY = 0.4791665,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7929688,
				sizeY = 0.8055556,
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
					name = "kk2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					image = "b#db1",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "zs1",
						posX = 0.02057244,
						posY = 0.1628659,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.05421687,
						sizeY = 0.3755943,
						image = "zhu#zs1",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zs2",
						posX = 0.9442027,
						posY = 0.1851488,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1592083,
						sizeY = 0.4057052,
						image = "zhu#zs2",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "db2",
						posX = 0.5,
						posY = 0.4921793,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9363168,
						sizeY = 0.959002,
						image = "b#db3",
						scale9 = true,
						scale9Left = 0.47,
						scale9Right = 0.47,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dk2",
					posX = 0.7001676,
					posY = 0.5120986,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4927858,
					sizeY = 0.7056931,
					image = "b#d5",
					scale9 = true,
					scale9Left = 0.41,
					scale9Right = 0.37,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lb2",
						varName = "scroll",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9616584,
						sizeY = 0.9682155,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dt2",
					posX = 0.2484359,
					posY = 0.5120984,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3929881,
					sizeY = 0.7056931,
					image = "b#d2",
					scale9 = true,
					scale9Left = 0.41,
					scale9Right = 0.37,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lb",
						varName = "scroll2",
						posX = 0.5,
						posY = 0.4958057,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9661615,
						sizeY = 0.9769018,
					},
				},
				{
					prop = {
						etype = "Grid",
						name = "tsk",
						posX = 0.4993894,
						posY = 0.4974572,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7809007,
						sizeY = 0.7685961,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "wzts",
							varName = "noItemTips",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7551304,
							sizeY = 0.25,
							text = "暂无可出售物品",
							color = "FF966856",
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
					name = "a1",
					varName = "select_all",
					posX = 0.2481959,
					posY = 0.09705132,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1211823,
					sizeY = 0.1,
					image = "chu1#an3",
					imageNormal = "chu1#an3",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "h1",
						posX = 0.5,
						posY = 0.5517241,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8716368,
						sizeY = 1.102895,
						text = "全 选",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FF347468",
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
					varName = "ronglian",
					posX = 0.8761485,
					posY = 0.09705132,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1211823,
					sizeY = 0.1,
					image = "chu1#an4",
					imageNormal = "chu1#an4",
					soundEffectClick = "audio/rxjh/UI/sold.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "h2",
						posX = 0.5,
						posY = 0.5517241,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.008326,
						sizeY = 0.9713849,
						text = "一键熔炼",
						fontSize = 22,
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
					etype = "Image",
					name = "wp1",
					varName = "ingotRoot",
					posX = 0.6596055,
					posY = 0.0970513,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.182266,
					sizeY = 0.06551724,
					image = "d#tyd",
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "sl2",
						varName = "diamond_lable",
						posX = 0.6029358,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8165973,
						sizeY = 1.583725,
						text = "654564",
						color = "FFFFFF00",
						fontSize = 24,
						fontOutlineEnable = true,
						fontOutlineColor = "FF804000",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "tb2",
						varName = "money_icon",
						posX = 0.1843229,
						posY = 0.507603,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.2702703,
						sizeY = 1.315789,
						image = "tb#tb_yuanbao.png",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "suo",
							varName = "suo",
							posX = 0.6226413,
							posY = 0.3341078,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.5185357,
							sizeY = 0.5185354,
							image = "tb#tb_suo.png",
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tsd",
					varName = "type_desc",
					posX = 0.6799161,
					posY = 0.174709,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2932808,
					sizeY = 0.08793104,
					image = "b#tsd1",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					alpha = 0.7,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "tsz",
						varName = "get_desc",
						posX = 0.5,
						posY = 0.5978702,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.017267,
						sizeY = 0.8613203,
						text = "出售心法可获得心法能量",
						color = "FFFEDB45",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "closeBtn",
					posX = 0.965064,
					posY = 0.9338347,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.06600985,
					sizeY = 0.1310345,
					image = "chu1#gb",
					imageNormal = "chu1#gb",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "tswb",
					varName = "desc",
					posX = 0.5,
					posY = 0.9059541,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7868844,
					sizeY = 0.1542191,
					text = "熔炼提示",
					color = "FFC93034",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "top",
				posX = 0.5,
				posY = 0.8765713,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.20625,
				sizeY = 0.07222223,
				image = "chu1#top",
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "topz",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5151515,
					sizeY = 0.4807692,
					image = "biaoti#plcs",
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
	dk = {
		ysjm = {
			scale = {{0, {0.3, 0.3, 1}}, {150, {1.05, 1.05, 1}}, {200, {1,1,1}}, },
		},
	},
	c_dakai = {
		{0,"dk", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
