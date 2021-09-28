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
				posY = 0.5,
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
					posX = 0.5009827,
					posY = 0.5396327,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.238424,
					sizeY = 1.127586,
					image = "huiguid#huiguid",
					scale9Left = 0.45,
					scale9Right = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "bit",
						varName = "titleIcon",
						posX = 0.5460658,
						posY = 0.8907297,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7128081,
						sizeY = 0.2813456,
						image = "huigui#huigui",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "d2",
						posX = 0.5334144,
						posY = 0.09393728,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5000438,
						sizeY = 0.05810398,
						image = "huigui#d2",
						scale9 = true,
						scale9Left = 0.45,
						scale9Right = 0.45,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sj",
						varName = "activeTime",
						posX = 0.5350131,
						posY = 0.09226279,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6558182,
						sizeY = 0.07924166,
						text = "活动时间：",
						color = "FFF8B981",
						fontSize = 24,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sj2",
						varName = "activeInfo",
						posX = 0.5294545,
						posY = 0.02203131,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6558182,
						sizeY = 0.07924166,
						text = "说明",
						color = "FFF75F53",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "a1",
						varName = "tab1",
						posX = 0.9780893,
						posY = 0.7115064,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.04852823,
						sizeY = 0.2278288,
						image = "huigui#kf2",
						imageNormal = "huigui#kf2",
						imagePressed = "huigui#kf1",
						imageDisable = "huigui#kf2",
						disablePressScale = true,
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "ts1",
							varName = "red1",
							posX = 0.8901396,
							posY = 0.9462811,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.4426229,
							sizeY = 0.1879194,
							image = "zdte#hd",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "w1",
							varName = "text1",
							posX = 0.4509098,
							posY = 0.4664921,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.615694,
							sizeY = 0.8652425,
							text = "回归送礼",
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
					name = "a3",
					varName = "tab2",
					posX = 1.079191,
					posY = 0.5250612,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.06009852,
					sizeY = 0.2568966,
					image = "huigui#kf2",
					imageNormal = "huigui#kf2",
					imagePressed = "huigui#kf1",
					imageDisable = "huigui#kf2",
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "ts3",
						varName = "red2",
						posX = 0.8943355,
						posY = 0.9382369,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4426229,
						sizeY = 0.1879194,
						image = "zdte#hd",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "w2",
						varName = "text2",
						posX = 0.4892929,
						posY = 0.466507,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.615694,
						sizeY = 0.8652425,
						text = "携手同行",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a4",
					varName = "tab3",
					posX = 1.063457,
					posY = 0.2680523,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.06009852,
					sizeY = 0.2568966,
					image = "huigui#kf2",
					imageNormal = "huigui#kf2",
					imagePressed = "huigui#kf1",
					imageDisable = "huigui#kf2",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "xhd",
						varName = "red3",
						posX = 0.9077399,
						posY = 0.9434468,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4426229,
						sizeY = 0.1879194,
						image = "zdte#hd",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "w3",
						varName = "text3",
						posX = 0.4509477,
						posY = 0.4799109,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.615694,
						sizeY = 0.8652425,
						text = "充值送礼",
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
					varName = "close",
					posX = 1.057523,
					posY = 0.9131715,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.05418719,
					sizeY = 0.09482758,
					image = "huigui#x",
					imageNormal = "huigui#x",
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "huigui",
					varName = "content1",
					posX = 0.5629499,
					posY = 0.4741797,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8340979,
					sizeY = 0.6713113,
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lb",
						varName = "scroll1",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 1,
						horizontal = true,
						showScrollBar = false,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jinqiu",
					varName = "content2",
					posX = 0.56295,
					posY = 0.4741797,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8340979,
					sizeY = 0.6713113,
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lb2",
						varName = "scroll2",
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
					name = "chongzhi",
					varName = "content3",
					posX = 0.56295,
					posY = 0.4741797,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8340979,
					sizeY = 0.6713113,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dttt",
						posX = 0.1928067,
						posY = 0.5794907,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3290096,
						sizeY = 1.179492,
						image = "huigui#h",
						scale9 = true,
						scale9Left = 0.45,
						scale9Right = 0.45,
						scale9Top = 0.2,
						scale9Bottom = 0.7,
						alpha = 0.6,
					},
					children = {
					{
						prop = {
							etype = "RichText",
							name = "wb1",
							varName = "desc_text",
							posX = 0.5,
							posY = 0.8681818,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8719,
							sizeY = 0.2015892,
							text = "呃呃呃呃呃呃呃呃呃呃呃呃呃呃呃呃呃呃呃",
							color = "FFFFD3B2",
						},
					},
					{
						prop = {
							etype = "RichText",
							name = "wb2",
							varName = "score_text",
							posX = 0.4856665,
							posY = 0.4230926,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9211429,
							sizeY = 0.1452865,
							text = "当前积分10",
							color = "FFFFE400",
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "RichText",
							name = "wb4",
							varName = "az",
							posX = 0.5000001,
							posY = 0.665217,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 0.8719,
							sizeY = 0.2015892,
							text = "123",
							color = "FFFF753F",
						},
					},
					{
						prop = {
							etype = "Button",
							name = "a5",
							varName = "goto_pay_btn",
							posX = 0.5,
							posY = 0.1803401,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6857119,
							sizeY = 0.1393584,
							image = "czan#czan",
							imageNormal = "czan#czan",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "wb3",
								posX = 0.5,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.9352458,
								sizeY = 0.8379022,
								text = "前往充值",
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
					},
				},
				{
					prop = {
						etype = "Image",
						name = "h",
						posX = 0.7093159,
						posY = 0.5794908,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6851414,
						sizeY = 1.179492,
						image = "huigui#h",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
						scale9Top = 0.4,
						scale9Bottom = 0.4,
						alpha = 0.6,
					},
				},
				{
					prop = {
						etype = "Scroll",
						name = "lb3",
						varName = "scroll3",
						posX = 0.7099061,
						posY = 0.5807689,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6768889,
						sizeY = 1.166667,
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "bz",
				varName = "help",
				posX = 0.904803,
				posY = 0.1450274,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0390625,
				sizeY = 0.06944445,
				image = "huigui#bz",
				imageNormal = "huigui#bz",
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "jd",
			varName = "shareGroup",
			posX = 0.7506155,
			posY = 0.2523871,
			anchorX = 0.5,
			anchorY = 0.5,
			visible = false,
			sizeX = 0.5012321,
			sizeY = 0.5007727,
			layoutType = 2,
			layoutTypeW = 3,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "zh",
				varName = "shareBtn",
				posX = 0.8921369,
				posY = 0.09850663,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1932737,
				sizeY = 0.1608625,
				image = "chu1#sn1",
				imageNormal = "chu1#sn1",
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "zhz",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9661626,
					sizeY = 0.9467098,
					text = "召回好友",
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
	gy = {
	},
	gy3 = {
	},
	gy2 = {
	},
	gy4 = {
	},
	gy5 = {
	},
	gy6 = {
	},
	gy7 = {
	},
	gy8 = {
	},
	gy9 = {
	},
	gy10 = {
	},
	gy11 = {
	},
	gy12 = {
	},
	gy13 = {
	},
	gy14 = {
	},
	gy15 = {
	},
	gy16 = {
	},
	gy17 = {
	},
	gy18 = {
	},
	gy19 = {
	},
	gy20 = {
	},
	gy21 = {
	},
	gy22 = {
	},
	gy23 = {
	},
	gy24 = {
	},
	gy25 = {
	},
	gy26 = {
	},
	gy27 = {
	},
	gy28 = {
	},
	gy29 = {
	},
	gy30 = {
	},
	gy31 = {
	},
	gy32 = {
	},
	gy33 = {
	},
	gy34 = {
	},
	gy35 = {
	},
	gy36 = {
	},
	gy37 = {
	},
	gy38 = {
	},
	gy39 = {
	},
	gy40 = {
	},
	gy41 = {
	},
	gy42 = {
	},
	gy43 = {
	},
	gy44 = {
	},
	gy45 = {
	},
	gy46 = {
	},
	gy47 = {
	},
	gy48 = {
	},
	gy49 = {
	},
	gy50 = {
	},
	gy51 = {
	},
	gy52 = {
	},
	gy53 = {
	},
	gy54 = {
	},
	gy55 = {
	},
	gy56 = {
	},
	gy57 = {
	},
	gy58 = {
	},
	gy59 = {
	},
	gy60 = {
	},
	gy61 = {
	},
	gy62 = {
	},
	gy63 = {
	},
	gy64 = {
	},
	gy65 = {
	},
	gy66 = {
	},
	gy67 = {
	},
	gy68 = {
	},
	gy69 = {
	},
	gy70 = {
	},
	gy71 = {
	},
	gy72 = {
	},
	gy73 = {
	},
	gy74 = {
	},
	gy75 = {
	},
	gy76 = {
	},
	gy77 = {
	},
	gy78 = {
	},
	gy79 = {
	},
	gy80 = {
	},
	gy81 = {
	},
	gy82 = {
	},
	gy83 = {
	},
	gy84 = {
	},
	gy85 = {
	},
	gy86 = {
	},
	gy87 = {
	},
	gy88 = {
	},
	gy89 = {
	},
	gy90 = {
	},
	gy91 = {
	},
	gy92 = {
	},
	gy93 = {
	},
	gy94 = {
	},
	gy95 = {
	},
	gy96 = {
	},
	gy97 = {
	},
	gy98 = {
	},
	gy99 = {
	},
	gy100 = {
	},
	gy101 = {
	},
	gy102 = {
	},
	gy103 = {
	},
	gy104 = {
	},
	gy105 = {
	},
	gy106 = {
	},
	gy107 = {
	},
	gy108 = {
	},
	gy109 = {
	},
	gy110 = {
	},
	gy111 = {
	},
	gy112 = {
	},
	gy113 = {
	},
	gy114 = {
	},
	gy115 = {
	},
	gy116 = {
	},
	gy117 = {
	},
	gy118 = {
	},
	gy119 = {
	},
	gy120 = {
	},
	gy121 = {
	},
	gy122 = {
	},
	gy123 = {
	},
	gy124 = {
	},
	gy125 = {
	},
	gy126 = {
	},
	gy127 = {
	},
	gy128 = {
	},
	gy129 = {
	},
	gy130 = {
	},
	gy131 = {
	},
	gy132 = {
	},
	gy133 = {
	},
	gy134 = {
	},
	gy135 = {
	},
	gy136 = {
	},
	gy137 = {
	},
	gy138 = {
	},
	gy139 = {
	},
	gy140 = {
	},
	gy141 = {
	},
	gy142 = {
	},
	gy143 = {
	},
	gy144 = {
	},
	gy145 = {
	},
	gy146 = {
	},
	gy147 = {
	},
	gy148 = {
	},
	gy149 = {
	},
	gy150 = {
	},
	gy151 = {
	},
	gy152 = {
	},
	gy153 = {
	},
	gy154 = {
	},
	gy155 = {
	},
	gy156 = {
	},
	gy157 = {
	},
	gy158 = {
	},
	gy159 = {
	},
	gy160 = {
	},
	gy161 = {
	},
	gy162 = {
	},
	gy163 = {
	},
	gy164 = {
	},
	gy165 = {
	},
	gy166 = {
	},
	gy167 = {
	},
	gy168 = {
	},
	gy169 = {
	},
	gy170 = {
	},
	gy171 = {
	},
	gy172 = {
	},
	gy173 = {
	},
	gy174 = {
	},
	gy175 = {
	},
	gy176 = {
	},
	gy177 = {
	},
	gy178 = {
	},
	gy179 = {
	},
	gy180 = {
	},
	gy181 = {
	},
	gy182 = {
	},
	gy183 = {
	},
	gy184 = {
	},
	gy185 = {
	},
	gy186 = {
	},
	gy187 = {
	},
	gy188 = {
	},
	gy189 = {
	},
	gy190 = {
	},
	gy191 = {
	},
	gy192 = {
	},
	gy193 = {
	},
	gy194 = {
	},
	gy195 = {
	},
	gy196 = {
	},
	gy197 = {
	},
	gy198 = {
	},
	gy199 = {
	},
	gy200 = {
	},
	gy201 = {
	},
	gy202 = {
	},
	gy203 = {
	},
	gy204 = {
	},
	gy205 = {
	},
	gy206 = {
	},
	gy207 = {
	},
	gy208 = {
	},
	gy209 = {
	},
	gy210 = {
	},
	gy211 = {
	},
	gy212 = {
	},
	gy213 = {
	},
	gy214 = {
	},
	gy215 = {
	},
	gy216 = {
	},
	gy217 = {
	},
	gy218 = {
	},
	gy219 = {
	},
	gy220 = {
	},
	gy221 = {
	},
	gy222 = {
	},
	gy223 = {
	},
	gy224 = {
	},
	gy225 = {
	},
	gy226 = {
	},
	gy227 = {
	},
	gy228 = {
	},
	gy229 = {
	},
	gy230 = {
	},
	gy231 = {
	},
	gy232 = {
	},
	gy233 = {
	},
	gy234 = {
	},
	gy235 = {
	},
	gy236 = {
	},
	gy237 = {
	},
	gy238 = {
	},
	gy239 = {
	},
	gy240 = {
	},
	gy241 = {
	},
	gy242 = {
	},
	gy243 = {
	},
	gy244 = {
	},
	gy245 = {
	},
	gy246 = {
	},
	gy247 = {
	},
	gy248 = {
	},
	gy249 = {
	},
	gy250 = {
	},
	gy251 = {
	},
	gy252 = {
	},
	gy253 = {
	},
	gy254 = {
	},
	gy255 = {
	},
	gy256 = {
	},
	gy257 = {
	},
	gy258 = {
	},
	gy259 = {
	},
	gy260 = {
	},
	gy261 = {
	},
	gy262 = {
	},
	gy263 = {
	},
	gy264 = {
	},
	gy265 = {
	},
	gy266 = {
	},
	gy267 = {
	},
	gy268 = {
	},
	gy269 = {
	},
	gy270 = {
	},
	gy271 = {
	},
	gy272 = {
	},
	gy273 = {
	},
	gy274 = {
	},
	gy275 = {
	},
	gy276 = {
	},
	gy277 = {
	},
	gy278 = {
	},
	gy279 = {
	},
	gy280 = {
	},
	gy281 = {
	},
	gy282 = {
	},
	gy283 = {
	},
	gy284 = {
	},
	gy285 = {
	},
	gy286 = {
	},
	gy287 = {
	},
	gy288 = {
	},
	gy289 = {
	},
	gy290 = {
	},
	gy291 = {
	},
	gy292 = {
	},
	gy293 = {
	},
	gy294 = {
	},
	gy295 = {
	},
	gy296 = {
	},
	gy297 = {
	},
	gy298 = {
	},
	gy299 = {
	},
	gy300 = {
	},
	gy301 = {
	},
	gy302 = {
	},
	gy303 = {
	},
	gy304 = {
	},
	gy305 = {
	},
	gy306 = {
	},
	gy307 = {
	},
	gy308 = {
	},
	gy309 = {
	},
	gy310 = {
	},
	gy311 = {
	},
	gy312 = {
	},
	gy313 = {
	},
	gy314 = {
	},
	gy315 = {
	},
	gy316 = {
	},
	gy317 = {
	},
	gy318 = {
	},
	gy319 = {
	},
	gy320 = {
	},
	gy321 = {
	},
	gy322 = {
	},
	gy323 = {
	},
	gy324 = {
	},
	gy325 = {
	},
	gy326 = {
	},
	gy327 = {
	},
	gy328 = {
	},
	gy329 = {
	},
	gy330 = {
	},
	gy331 = {
	},
	gy332 = {
	},
	gy333 = {
	},
	gy334 = {
	},
	gy335 = {
	},
	gy336 = {
	},
	gy337 = {
	},
	gy338 = {
	},
	gy339 = {
	},
	gy340 = {
	},
	gy341 = {
	},
	gy342 = {
	},
	gy343 = {
	},
	gy344 = {
	},
	gy345 = {
	},
	gy346 = {
	},
	gy347 = {
	},
	gy348 = {
	},
	gy349 = {
	},
	gy350 = {
	},
	gy351 = {
	},
	gy352 = {
	},
	gy353 = {
	},
	gy354 = {
	},
	gy355 = {
	},
	gy356 = {
	},
	gy357 = {
	},
	gy358 = {
	},
	gy359 = {
	},
	gy360 = {
	},
	gy361 = {
	},
	gy362 = {
	},
	gy363 = {
	},
	gy364 = {
	},
	gy365 = {
	},
	gy366 = {
	},
	gy367 = {
	},
	gy368 = {
	},
	gy369 = {
	},
	gy370 = {
	},
	gy371 = {
	},
	gy372 = {
	},
	gy373 = {
	},
	gy374 = {
	},
	gy375 = {
	},
	gy376 = {
	},
	gy377 = {
	},
	gy378 = {
	},
	gy379 = {
	},
	gy380 = {
	},
	gy381 = {
	},
	gy382 = {
	},
	gy383 = {
	},
	gy384 = {
	},
	gy385 = {
	},
	gy386 = {
	},
	gy387 = {
	},
	gy388 = {
	},
	gy389 = {
	},
	gy390 = {
	},
	gy391 = {
	},
	gy392 = {
	},
	gy393 = {
	},
	gy394 = {
	},
	gy395 = {
	},
	gy396 = {
	},
	gy397 = {
	},
	gy398 = {
	},
	gy399 = {
	},
	gy400 = {
	},
	gy401 = {
	},
	gy402 = {
	},
	gy403 = {
	},
	gy404 = {
	},
	gy405 = {
	},
	gy406 = {
	},
	gy407 = {
	},
	gy408 = {
	},
	gy409 = {
	},
	gy410 = {
	},
	gy411 = {
	},
	gy412 = {
	},
	gy413 = {
	},
	gy414 = {
	},
	gy415 = {
	},
	gy416 = {
	},
	gy417 = {
	},
	gy418 = {
	},
	gy419 = {
	},
	gy420 = {
	},
	gy421 = {
	},
	gy422 = {
	},
	gy423 = {
	},
	gy424 = {
	},
	gy425 = {
	},
	gy426 = {
	},
	gy427 = {
	},
	gy428 = {
	},
	gy429 = {
	},
	gy430 = {
	},
	gy431 = {
	},
	gy432 = {
	},
	gy433 = {
	},
	gy434 = {
	},
	gy435 = {
	},
	gy436 = {
	},
	gy437 = {
	},
	gy438 = {
	},
	gy439 = {
	},
	gy440 = {
	},
	gy441 = {
	},
	gy442 = {
	},
	gy443 = {
	},
	gy444 = {
	},
	gy445 = {
	},
	gy446 = {
	},
	gy447 = {
	},
	gy448 = {
	},
	gy449 = {
	},
	gy450 = {
	},
	gy451 = {
	},
	gy452 = {
	},
	gy453 = {
	},
	gy454 = {
	},
	gy455 = {
	},
	gy456 = {
	},
	gy457 = {
	},
	gy458 = {
	},
	gy459 = {
	},
	gy460 = {
	},
	gy461 = {
	},
	gy462 = {
	},
	gy463 = {
	},
	gy464 = {
	},
	gy465 = {
	},
	gy466 = {
	},
	gy467 = {
	},
	gy468 = {
	},
	gy469 = {
	},
	gy470 = {
	},
	gy471 = {
	},
	gy472 = {
	},
	gy473 = {
	},
	gy474 = {
	},
	gy475 = {
	},
	gy476 = {
	},
	gy477 = {
	},
	gy478 = {
	},
	gy479 = {
	},
	gy480 = {
	},
	gy481 = {
	},
	gy482 = {
	},
	gy483 = {
	},
	gy484 = {
	},
	gy485 = {
	},
	gy486 = {
	},
	gy487 = {
	},
	gy488 = {
	},
	gy489 = {
	},
	gy490 = {
	},
	gy491 = {
	},
	gy492 = {
	},
	gy493 = {
	},
	gy494 = {
	},
	gy495 = {
	},
	gy496 = {
	},
	gy497 = {
	},
	gy498 = {
	},
	gy499 = {
	},
	gy500 = {
	},
	gy501 = {
	},
	gy502 = {
	},
	gy503 = {
	},
	gy504 = {
	},
	gy505 = {
	},
	gy506 = {
	},
	gy507 = {
	},
	gy508 = {
	},
	gy509 = {
	},
	gy510 = {
	},
	gy511 = {
	},
	gy512 = {
	},
	gy513 = {
	},
	gy514 = {
	},
	gy515 = {
	},
	gy516 = {
	},
	gy517 = {
	},
	gy518 = {
	},
	gy519 = {
	},
	gy520 = {
	},
	gy521 = {
	},
	gy522 = {
	},
	gy523 = {
	},
	gy524 = {
	},
	gy525 = {
	},
	gy526 = {
	},
	gy527 = {
	},
	gy528 = {
	},
	gy529 = {
	},
	gy530 = {
	},
	gy531 = {
	},
	gy532 = {
	},
	gy533 = {
	},
	gy534 = {
	},
	gy535 = {
	},
	gy536 = {
	},
	gy537 = {
	},
	gy538 = {
	},
	gy539 = {
	},
	gy540 = {
	},
	gy541 = {
	},
	gy542 = {
	},
	gy543 = {
	},
	gy544 = {
	},
	gy545 = {
	},
	gy546 = {
	},
	gy547 = {
	},
	gy548 = {
	},
	gy549 = {
	},
	gy550 = {
	},
	gy551 = {
	},
	gy552 = {
	},
	gy553 = {
	},
	gy554 = {
	},
	gy555 = {
	},
	gy556 = {
	},
	gy557 = {
	},
	gy558 = {
	},
	gy559 = {
	},
	gy560 = {
	},
	gy561 = {
	},
	gy562 = {
	},
	gy563 = {
	},
	gy564 = {
	},
	gy565 = {
	},
	gy566 = {
	},
	gy567 = {
	},
	gy568 = {
	},
	gy569 = {
	},
	gy570 = {
	},
	gy571 = {
	},
	gy572 = {
	},
	gy573 = {
	},
	gy574 = {
	},
	gy575 = {
	},
	gy576 = {
	},
	gy577 = {
	},
	gy578 = {
	},
	gy579 = {
	},
	gy580 = {
	},
	gy581 = {
	},
	gy582 = {
	},
	gy583 = {
	},
	gy584 = {
	},
	gy585 = {
	},
	gy586 = {
	},
	gy587 = {
	},
	gy588 = {
	},
	gy589 = {
	},
	gy590 = {
	},
	gy591 = {
	},
	gy592 = {
	},
	gy593 = {
	},
	gy594 = {
	},
	gy595 = {
	},
	gy596 = {
	},
	gy597 = {
	},
	gy598 = {
	},
	gy599 = {
	},
	gy600 = {
	},
	gy601 = {
	},
	gy602 = {
	},
	gy603 = {
	},
	gy604 = {
	},
	gy605 = {
	},
	gy606 = {
	},
	gy607 = {
	},
	gy608 = {
	},
	gy609 = {
	},
	gy610 = {
	},
	gy611 = {
	},
	gy612 = {
	},
	gy613 = {
	},
	gy614 = {
	},
	gy615 = {
	},
	gy616 = {
	},
	gy617 = {
	},
	gy618 = {
	},
	gy619 = {
	},
	gy620 = {
	},
	gy621 = {
	},
	gy622 = {
	},
	gy623 = {
	},
	gy624 = {
	},
	gy625 = {
	},
	gy626 = {
	},
	gy627 = {
	},
	gy628 = {
	},
	gy629 = {
	},
	gy630 = {
	},
	gy631 = {
	},
	gy632 = {
	},
	gy633 = {
	},
	gy634 = {
	},
	gy635 = {
	},
	gy636 = {
	},
	gy637 = {
	},
	gy638 = {
	},
	gy639 = {
	},
	gy640 = {
	},
	gy641 = {
	},
	gy642 = {
	},
	gy643 = {
	},
	gy644 = {
	},
	gy645 = {
	},
	gy646 = {
	},
	gy647 = {
	},
	gy648 = {
	},
	gy649 = {
	},
	gy650 = {
	},
	gy651 = {
	},
	gy652 = {
	},
	gy653 = {
	},
	gy654 = {
	},
	gy655 = {
	},
	gy656 = {
	},
	gy657 = {
	},
	gy658 = {
	},
	gy659 = {
	},
	gy660 = {
	},
	gy661 = {
	},
	gy662 = {
	},
	gy663 = {
	},
	gy664 = {
	},
	gy665 = {
	},
	gy666 = {
	},
	gy667 = {
	},
	gy668 = {
	},
	gy669 = {
	},
	gy670 = {
	},
	gy671 = {
	},
	gy672 = {
	},
	gy673 = {
	},
	gy674 = {
	},
	gy675 = {
	},
	gy676 = {
	},
	gy677 = {
	},
	gy678 = {
	},
	gy679 = {
	},
	gy680 = {
	},
	gy681 = {
	},
	gy682 = {
	},
	gy683 = {
	},
	gy684 = {
	},
	gy685 = {
	},
	gy686 = {
	},
	gy687 = {
	},
	gy688 = {
	},
	gy689 = {
	},
	gy690 = {
	},
	gy691 = {
	},
	gy692 = {
	},
	gy693 = {
	},
	gy694 = {
	},
	gy695 = {
	},
	gy696 = {
	},
	gy697 = {
	},
	gy698 = {
	},
	gy699 = {
	},
	gy700 = {
	},
	gy701 = {
	},
	gy702 = {
	},
	gy703 = {
	},
	gy704 = {
	},
	gy705 = {
	},
	gy706 = {
	},
	gy707 = {
	},
	gy708 = {
	},
	gy709 = {
	},
	gy710 = {
	},
	gy711 = {
	},
	gy712 = {
	},
	gy713 = {
	},
	gy714 = {
	},
	gy715 = {
	},
	gy716 = {
	},
	gy717 = {
	},
	gy718 = {
	},
	gy719 = {
	},
	gy720 = {
	},
	gy721 = {
	},
	gy722 = {
	},
	gy723 = {
	},
	gy724 = {
	},
	gy725 = {
	},
	gy726 = {
	},
	gy727 = {
	},
	gy728 = {
	},
	gy729 = {
	},
	gy730 = {
	},
	gy731 = {
	},
	gy732 = {
	},
	gy733 = {
	},
	gy734 = {
	},
	gy735 = {
	},
	gy736 = {
	},
	gy737 = {
	},
	gy738 = {
	},
	gy739 = {
	},
	gy740 = {
	},
	gy741 = {
	},
	gy742 = {
	},
	gy743 = {
	},
	gy744 = {
	},
	gy745 = {
	},
	gy746 = {
	},
	gy747 = {
	},
	gy748 = {
	},
	gy749 = {
	},
	gy750 = {
	},
	gy751 = {
	},
	gy752 = {
	},
	gy753 = {
	},
	gy754 = {
	},
	gy755 = {
	},
	gy756 = {
	},
	gy757 = {
	},
	gy758 = {
	},
	gy759 = {
	},
	gy760 = {
	},
	gy761 = {
	},
	gy762 = {
	},
	gy763 = {
	},
	gy764 = {
	},
	gy765 = {
	},
	gy766 = {
	},
	gy767 = {
	},
	gy768 = {
	},
	gy769 = {
	},
	gy770 = {
	},
	gy771 = {
	},
	gy772 = {
	},
	gy773 = {
	},
	gy774 = {
	},
	gy775 = {
	},
	gy776 = {
	},
	gy777 = {
	},
	gy778 = {
	},
	gy779 = {
	},
	gy780 = {
	},
	gy781 = {
	},
	gy782 = {
	},
	gy783 = {
	},
	gy784 = {
	},
	gy785 = {
	},
	gy786 = {
	},
	gy787 = {
	},
	gy788 = {
	},
	gy789 = {
	},
	gy790 = {
	},
	gy791 = {
	},
	gy792 = {
	},
	gy793 = {
	},
	gy794 = {
	},
	gy795 = {
	},
	gy796 = {
	},
	gy797 = {
	},
	gy798 = {
	},
	gy799 = {
	},
	gy800 = {
	},
	gy801 = {
	},
	gy802 = {
	},
	gy803 = {
	},
	gy804 = {
	},
	gy805 = {
	},
	gy806 = {
	},
	gy807 = {
	},
	gy808 = {
	},
	gy809 = {
	},
	gy810 = {
	},
	gy811 = {
	},
	gy812 = {
	},
	gy813 = {
	},
	gy814 = {
	},
	gy815 = {
	},
	gy816 = {
	},
	gy817 = {
	},
	gy818 = {
	},
	gy819 = {
	},
	gy820 = {
	},
	gy821 = {
	},
	gy822 = {
	},
	gy823 = {
	},
	gy824 = {
	},
	gy825 = {
	},
	gy826 = {
	},
	gy827 = {
	},
	gy828 = {
	},
	gy829 = {
	},
	gy830 = {
	},
	gy831 = {
	},
	gy832 = {
	},
	gy833 = {
	},
	gy834 = {
	},
	gy835 = {
	},
	gy836 = {
	},
	gy837 = {
	},
	gy838 = {
	},
	gy839 = {
	},
	gy840 = {
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
