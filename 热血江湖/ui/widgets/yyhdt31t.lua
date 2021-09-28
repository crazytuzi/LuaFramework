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
			name = "k1",
			varName = "itemRoot",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.6785716,
			sizeY = 0.15,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "bpsdt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9977022,
				sizeY = 0.9537036,
				scale9Left = 0.45,
				scale9Right = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "zc",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					image = "czhd#lb2",
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
						name = "xzzs2",
						posX = 0.07054187,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1384761,
						sizeY = 1.009709,
						image = "czhd#lb2zs",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xz",
					varName = "root_bg",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					image = "czhd#lb1",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "xzzs",
						posX = 0.07054189,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1384761,
						sizeY = 1.009709,
						image = "czhd#lb1zs",
					},
				},
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "bt",
					varName = "GoalContent",
					posX = 0.06970031,
					posY = 0.4922974,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1370976,
					sizeY = 1.008052,
					text = "充值1000元宝可获得",
					color = "FFC0C0C0",
					fontSize = 22,
					fontOutlineColor = "FF634624",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "cdd",
					varName = "Whole",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 1,
					sizeY = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "wpk",
					varName = "item_bg",
					posX = 0.2281412,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.09231737,
					sizeY = 0.7766991,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "an1",
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
						name = "wp",
						varName = "item_icon",
						posX = 0.5,
						posY = 0.538703,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8,
						sizeY = 0.8,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "sld",
						varName = "count_bg",
						posX = 0.5,
						posY = 0.2395833,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8526314,
						sizeY = 0.2708333,
						image = "sc#sc_sld.png",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "suo",
						varName = "item_suo",
						posX = 0.2062823,
						posY = 0.2403662,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3684211,
						sizeY = 0.3645834,
						image = "tb#suo",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "zz",
						varName = "item_count",
						posX = 0.5257913,
						posY = 0.2088165,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7744884,
						sizeY = 0.4154173,
						text = "99",
						fontSize = 18,
						fontOutlineEnable = true,
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "ylqt",
						varName = "alreadyGet1",
						posX = 0.4936416,
						posY = 0.5481949,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.9484282,
						sizeY = 0.926211,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "wpk2",
					varName = "item_bg2",
					posX = 0.354246,
					posY = 0.5000001,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					lockHV = true,
					sizeX = 0.09231737,
					sizeY = 0.7766992,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "an2",
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
						name = "wp2",
						varName = "item_icon2",
						posX = 0.5,
						posY = 0.538703,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8,
						sizeY = 0.8,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "sld2",
						varName = "count_bg2",
						posX = 0.5,
						posY = 0.2395833,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8526314,
						sizeY = 0.2708333,
						image = "sc#sc_sld.png",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "suo2",
						varName = "item_suo2",
						posX = 0.2062823,
						posY = 0.2403662,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3684211,
						sizeY = 0.3645834,
						image = "tb#suo",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "zz2",
						varName = "item_count2",
						posX = 0.5257913,
						posY = 0.2088163,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7744884,
						sizeY = 0.4154173,
						text = "99",
						fontSize = 18,
						fontOutlineEnable = true,
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "ylqt2",
						varName = "alreadyGet2",
						posX = 0.4936416,
						posY = 0.5481949,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.9484282,
						sizeY = 0.926211,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "wpk3",
					varName = "item_bg3",
					posX = 0.4803507,
					posY = 0.5000002,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					lockHV = true,
					sizeX = 0.09231737,
					sizeY = 0.7766992,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "an3",
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
						name = "wp3",
						varName = "item_icon3",
						posX = 0.5,
						posY = 0.538703,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8,
						sizeY = 0.8,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "sld3",
						varName = "count_bg3",
						posX = 0.5,
						posY = 0.2395833,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8526314,
						sizeY = 0.2708333,
						image = "sc#sc_sld.png",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "suo3",
						varName = "item_suo3",
						posX = 0.2062823,
						posY = 0.2403662,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3684211,
						sizeY = 0.3645834,
						image = "tb#suo",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "zz3",
						varName = "item_count3",
						posX = 0.5257913,
						posY = 0.2088163,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7744884,
						sizeY = 0.4154173,
						text = "99",
						fontSize = 18,
						fontOutlineEnable = true,
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "ylqt3",
						varName = "alreadyGet3",
						posX = 0.4936416,
						posY = 0.5481949,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.9484282,
						sizeY = 0.926211,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "lq",
					varName = "GetBtn",
					posX = 0.8804429,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1569395,
					sizeY = 0.6213593,
					image = "chu1#fy2",
					imageNormal = "chu1#fy2",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "lqz",
						varName = "GetBtnText",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8247252,
						sizeY = 1.143941,
						text = "领 取",
						fontSize = 24,
						fontOutlineEnable = true,
						fontOutlineColor = "FF8F4E1B",
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
					name = "ylq",
					varName = "GetImage",
					posX = 0.8804429,
					posY = 0.4999999,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					lockHV = true,
					sizeX = 0.1546316,
					sizeY = 0.7837172,
					image = "czt#ylq",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wz",
					varName = "Count",
					posX = 0.6952915,
					posY = 0.5000001,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2450573,
					sizeY = 0.541853,
					text = "（100/500）",
					color = "FFE22500",
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
	jn6 = {
	},
	bj = {
	},
	jn7 = {
	},
	bj2 = {
	},
	jn8 = {
	},
	bj3 = {
	},
	jn9 = {
	},
	bj4 = {
	},
	jn10 = {
	},
	bj5 = {
	},
	jn11 = {
	},
	bj6 = {
	},
	jn12 = {
	},
	bj7 = {
	},
	jn13 = {
	},
	bj8 = {
	},
	jn14 = {
	},
	bj9 = {
	},
	jn15 = {
	},
	bj10 = {
	},
	jn16 = {
	},
	bj11 = {
	},
	jn17 = {
	},
	bj12 = {
	},
	jn18 = {
	},
	bj13 = {
	},
	jn19 = {
	},
	bj14 = {
	},
	jn20 = {
	},
	bj15 = {
	},
	jn21 = {
	},
	bj16 = {
	},
	jn22 = {
	},
	bj17 = {
	},
	jn23 = {
	},
	bj18 = {
	},
	jn24 = {
	},
	bj19 = {
	},
	jn25 = {
	},
	bj20 = {
	},
	jn26 = {
	},
	bj21 = {
	},
	jn27 = {
	},
	bj22 = {
	},
	jn28 = {
	},
	bj23 = {
	},
	jn29 = {
	},
	bj24 = {
	},
	jn30 = {
	},
	bj25 = {
	},
	jn31 = {
	},
	bj26 = {
	},
	jn32 = {
	},
	bj27 = {
	},
	jn33 = {
	},
	bj28 = {
	},
	jn34 = {
	},
	bj29 = {
	},
	jn35 = {
	},
	bj30 = {
	},
	jn36 = {
	},
	bj31 = {
	},
	jn37 = {
	},
	bj32 = {
	},
	jn38 = {
	},
	bj33 = {
	},
	jn39 = {
	},
	bj34 = {
	},
	jn40 = {
	},
	bj35 = {
	},
	jn41 = {
	},
	bj36 = {
	},
	jn42 = {
	},
	bj37 = {
	},
	jn43 = {
	},
	bj38 = {
	},
	jn44 = {
	},
	bj39 = {
	},
	jn45 = {
	},
	bj40 = {
	},
	jn46 = {
	},
	bj41 = {
	},
	jn47 = {
	},
	bj42 = {
	},
	jn48 = {
	},
	bj43 = {
	},
	jn49 = {
	},
	bj44 = {
	},
	jn50 = {
	},
	bj45 = {
	},
	jn51 = {
	},
	bj46 = {
	},
	jn52 = {
	},
	bj47 = {
	},
	jn53 = {
	},
	bj48 = {
	},
	jn54 = {
	},
	bj49 = {
	},
	jn55 = {
	},
	bj50 = {
	},
	jn56 = {
	},
	bj51 = {
	},
	jn57 = {
	},
	bj52 = {
	},
	jn58 = {
	},
	bj53 = {
	},
	jn59 = {
	},
	bj54 = {
	},
	jn60 = {
	},
	bj55 = {
	},
	jn61 = {
	},
	bj56 = {
	},
	jn62 = {
	},
	bj57 = {
	},
	jn63 = {
	},
	bj58 = {
	},
	jn64 = {
	},
	bj59 = {
	},
	jn65 = {
	},
	bj60 = {
	},
	jn66 = {
	},
	bj61 = {
	},
	jn67 = {
	},
	bj62 = {
	},
	jn68 = {
	},
	bj63 = {
	},
	jn69 = {
	},
	bj64 = {
	},
	jn70 = {
	},
	bj65 = {
	},
	jn71 = {
	},
	bj66 = {
	},
	jn72 = {
	},
	bj67 = {
	},
	jn73 = {
	},
	bj68 = {
	},
	jn74 = {
	},
	bj69 = {
	},
	jn75 = {
	},
	bj70 = {
	},
	jn76 = {
	},
	bj71 = {
	},
	jn77 = {
	},
	bj72 = {
	},
	jn78 = {
	},
	bj73 = {
	},
	jn79 = {
	},
	bj74 = {
	},
	jn80 = {
	},
	bj75 = {
	},
	jn81 = {
	},
	bj76 = {
	},
	jn82 = {
	},
	bj77 = {
	},
	jn83 = {
	},
	bj78 = {
	},
	jn84 = {
	},
	bj79 = {
	},
	jn85 = {
	},
	bj80 = {
	},
	jn86 = {
	},
	bj81 = {
	},
	jn87 = {
	},
	bj82 = {
	},
	jn88 = {
	},
	bj83 = {
	},
	jn89 = {
	},
	bj84 = {
	},
	jn90 = {
	},
	bj85 = {
	},
	jn91 = {
	},
	bj86 = {
	},
	jn92 = {
	},
	bj87 = {
	},
	jn93 = {
	},
	bj88 = {
	},
	jn94 = {
	},
	bj89 = {
	},
	jn95 = {
	},
	bj90 = {
	},
	jn96 = {
	},
	bj91 = {
	},
	jn97 = {
	},
	bj92 = {
	},
	jn98 = {
	},
	bj93 = {
	},
	jn99 = {
	},
	bj94 = {
	},
	jn100 = {
	},
	bj95 = {
	},
	jn101 = {
	},
	bj96 = {
	},
	jn102 = {
	},
	bj97 = {
	},
	jn103 = {
	},
	bj98 = {
	},
	jn104 = {
	},
	bj99 = {
	},
	jn105 = {
	},
	bj100 = {
	},
	jn106 = {
	},
	bj101 = {
	},
	jn107 = {
	},
	bj102 = {
	},
	jn108 = {
	},
	bj103 = {
	},
	jn109 = {
	},
	bj104 = {
	},
	jn110 = {
	},
	bj105 = {
	},
	jn111 = {
	},
	bj106 = {
	},
	jn112 = {
	},
	bj107 = {
	},
	jn113 = {
	},
	bj108 = {
	},
	jn114 = {
	},
	bj109 = {
	},
	jn115 = {
	},
	bj110 = {
	},
	jn116 = {
	},
	bj111 = {
	},
	jn117 = {
	},
	bj112 = {
	},
	jn118 = {
	},
	bj113 = {
	},
	jn119 = {
	},
	bj114 = {
	},
	jn120 = {
	},
	bj115 = {
	},
	jn121 = {
	},
	bj116 = {
	},
	jn122 = {
	},
	bj117 = {
	},
	jn123 = {
	},
	bj118 = {
	},
	jn124 = {
	},
	bj119 = {
	},
	jn125 = {
	},
	bj120 = {
	},
	jn126 = {
	},
	bj121 = {
	},
	jn127 = {
	},
	bj122 = {
	},
	jn128 = {
	},
	bj123 = {
	},
	jn129 = {
	},
	bj124 = {
	},
	jn130 = {
	},
	bj125 = {
	},
	jn131 = {
	},
	bj126 = {
	},
	jn132 = {
	},
	bj127 = {
	},
	jn133 = {
	},
	bj128 = {
	},
	jn134 = {
	},
	bj129 = {
	},
	jn135 = {
	},
	bj130 = {
	},
	jn136 = {
	},
	bj131 = {
	},
	jn137 = {
	},
	bj132 = {
	},
	jn138 = {
	},
	bj133 = {
	},
	jn139 = {
	},
	bj134 = {
	},
	jn140 = {
	},
	bj135 = {
	},
	jn141 = {
	},
	bj136 = {
	},
	jn142 = {
	},
	bj137 = {
	},
	jn143 = {
	},
	bj138 = {
	},
	jn144 = {
	},
	bj139 = {
	},
	jn145 = {
	},
	bj140 = {
	},
	jn146 = {
	},
	bj141 = {
	},
	jn147 = {
	},
	bj142 = {
	},
	jn148 = {
	},
	bj143 = {
	},
	jn149 = {
	},
	bj144 = {
	},
	jn150 = {
	},
	bj145 = {
	},
	jn151 = {
	},
	bj146 = {
	},
	jn152 = {
	},
	bj147 = {
	},
	jn153 = {
	},
	bj148 = {
	},
	jn154 = {
	},
	bj149 = {
	},
	jn155 = {
	},
	bj150 = {
	},
	jn156 = {
	},
	bj151 = {
	},
	jn157 = {
	},
	bj152 = {
	},
	jn158 = {
	},
	bj153 = {
	},
	jn159 = {
	},
	bj154 = {
	},
	jn160 = {
	},
	bj155 = {
	},
	jn161 = {
	},
	bj156 = {
	},
	jn162 = {
	},
	bj157 = {
	},
	jn163 = {
	},
	bj158 = {
	},
	jn164 = {
	},
	bj159 = {
	},
	jn165 = {
	},
	bj160 = {
	},
	jn166 = {
	},
	bj161 = {
	},
	jn167 = {
	},
	bj162 = {
	},
	jn168 = {
	},
	bj163 = {
	},
	jn169 = {
	},
	bj164 = {
	},
	jn170 = {
	},
	bj165 = {
	},
	jn171 = {
	},
	bj166 = {
	},
	jn172 = {
	},
	bj167 = {
	},
	jn173 = {
	},
	bj168 = {
	},
	jn174 = {
	},
	bj169 = {
	},
	jn175 = {
	},
	bj170 = {
	},
	jn176 = {
	},
	bj171 = {
	},
	jn177 = {
	},
	bj172 = {
	},
	jn178 = {
	},
	bj173 = {
	},
	jn179 = {
	},
	bj174 = {
	},
	jn180 = {
	},
	bj175 = {
	},
	jn181 = {
	},
	bj176 = {
	},
	jn182 = {
	},
	bj177 = {
	},
	jn183 = {
	},
	bj178 = {
	},
	jn184 = {
	},
	bj179 = {
	},
	jn185 = {
	},
	bj180 = {
	},
	c_hld = {
	},
	c_hld2 = {
	},
	c_hld3 = {
	},
	c_hld4 = {
	},
	c_hld5 = {
	},
	c_hld6 = {
	},
	c_hld7 = {
	},
	c_hld8 = {
	},
	c_hld9 = {
	},
	c_hld10 = {
	},
	c_hld11 = {
	},
	c_hld12 = {
	},
	c_hld13 = {
	},
	c_hld14 = {
	},
	c_hld15 = {
	},
	c_hld16 = {
	},
	c_hld17 = {
	},
	c_hld18 = {
	},
	c_hld19 = {
	},
	c_hld20 = {
	},
	c_hld21 = {
	},
	c_hld22 = {
	},
	c_hld23 = {
	},
	c_hld24 = {
	},
	c_hld25 = {
	},
	c_hld26 = {
	},
	c_hld27 = {
	},
	c_hld28 = {
	},
	c_hld29 = {
	},
	c_hld30 = {
	},
	c_hld31 = {
	},
	c_hld32 = {
	},
	c_hld33 = {
	},
	c_hld34 = {
	},
	c_hld35 = {
	},
	c_hld36 = {
	},
	c_hld37 = {
	},
	c_hld38 = {
	},
	c_hld39 = {
	},
	c_hld40 = {
	},
	c_hld41 = {
	},
	c_hld42 = {
	},
	c_hld43 = {
	},
	c_hld44 = {
	},
	c_hld45 = {
	},
	c_hld46 = {
	},
	c_hld47 = {
	},
	c_hld48 = {
	},
	c_hld49 = {
	},
	c_hld50 = {
	},
	c_hld51 = {
	},
	c_hld52 = {
	},
	c_hld53 = {
	},
	c_hld54 = {
	},
	c_hld55 = {
	},
	c_hld56 = {
	},
	c_hld57 = {
	},
	c_hld58 = {
	},
	c_hld59 = {
	},
	c_hld60 = {
	},
	c_hld61 = {
	},
	c_hld62 = {
	},
	c_hld63 = {
	},
	c_hld64 = {
	},
	c_hld65 = {
	},
	c_hld66 = {
	},
	c_hld67 = {
	},
	c_hld68 = {
	},
	c_hld69 = {
	},
	c_hld70 = {
	},
	c_hld71 = {
	},
	c_hld72 = {
	},
	c_hld73 = {
	},
	c_hld74 = {
	},
	c_hld75 = {
	},
	c_hld76 = {
	},
	c_hld77 = {
	},
	c_hld78 = {
	},
	c_hld79 = {
	},
	c_hld80 = {
	},
	c_hld81 = {
	},
	c_hld82 = {
	},
	c_hld83 = {
	},
	c_hld84 = {
	},
	c_hld85 = {
	},
	c_hld86 = {
	},
	c_hld87 = {
	},
	c_hld88 = {
	},
	c_hld89 = {
	},
	c_hld90 = {
	},
	c_hld91 = {
	},
	c_hld92 = {
	},
	c_hld93 = {
	},
	c_hld94 = {
	},
	c_hld95 = {
	},
	c_hld96 = {
	},
	c_hld97 = {
	},
	c_hld98 = {
	},
	c_hld99 = {
	},
	c_hld100 = {
	},
	c_hld101 = {
	},
	c_hld102 = {
	},
	c_hld103 = {
	},
	c_hld104 = {
	},
	c_hld105 = {
	},
	c_hld106 = {
	},
	c_hld107 = {
	},
	c_hld108 = {
	},
	c_hld109 = {
	},
	c_hld110 = {
	},
	c_hld111 = {
	},
	c_hld112 = {
	},
	c_hld113 = {
	},
	c_hld114 = {
	},
	c_hld115 = {
	},
	c_hld116 = {
	},
	c_hld117 = {
	},
	c_hld118 = {
	},
	c_hld119 = {
	},
	c_hld120 = {
	},
	c_hld121 = {
	},
	c_hld122 = {
	},
	c_hld123 = {
	},
	c_hld124 = {
	},
	c_hld125 = {
	},
	c_hld126 = {
	},
	c_hld127 = {
	},
	c_hld128 = {
	},
	c_hld129 = {
	},
	c_hld130 = {
	},
	c_hld131 = {
	},
	c_hld132 = {
	},
	c_hld133 = {
	},
	c_hld134 = {
	},
	c_hld135 = {
	},
	c_hld136 = {
	},
	c_hld137 = {
	},
	c_hld138 = {
	},
	c_hld139 = {
	},
	c_hld140 = {
	},
	c_hld141 = {
	},
	c_hld142 = {
	},
	c_hld143 = {
	},
	c_hld144 = {
	},
	c_hld145 = {
	},
	c_hld146 = {
	},
	c_hld147 = {
	},
	c_hld148 = {
	},
	c_hld149 = {
	},
	c_hld150 = {
	},
	c_hld151 = {
	},
	c_hld152 = {
	},
	c_hld153 = {
	},
	c_hld154 = {
	},
	c_hld155 = {
	},
	c_hld156 = {
	},
	c_hld157 = {
	},
	c_hld158 = {
	},
	c_hld159 = {
	},
	c_hld160 = {
	},
	c_hld161 = {
	},
	c_hld162 = {
	},
	c_hld163 = {
	},
	c_hld164 = {
	},
	c_hld165 = {
	},
	c_hld166 = {
	},
	c_hld167 = {
	},
	c_hld168 = {
	},
	c_hld169 = {
	},
	c_hld170 = {
	},
	c_hld171 = {
	},
	c_hld172 = {
	},
	c_hld173 = {
	},
	c_hld174 = {
	},
	c_hld175 = {
	},
	c_hld176 = {
	},
	c_hld177 = {
	},
	c_hld178 = {
	},
	c_hld179 = {
	},
	c_hld180 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
