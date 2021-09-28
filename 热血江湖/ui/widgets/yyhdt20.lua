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
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.7101563,
			sizeY = 0.6378398,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.8814176,
				posY = 0.4978225,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2400881,
				sizeY = 1.171489,
				image = "czhd1#dt",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "cjsl",
				varName = "CjSl",
				posX = 0.4002649,
				posY = 0.4303669,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7436743,
				sizeY = 0.9755149,
				image = "caishendao#caishendaobanner",
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "hdd",
					posX = 0.6220318,
					posY = 0.5021137,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.257274,
					sizeY = 1.043084,
				},
				children = {
				{
					prop = {
						etype = "RichText",
						name = "gz",
						varName = "des",
						posX = 0.2581686,
						posY = 0.7554915,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4563449,
						sizeY = 0.06198064,
						text = "规则写在这里",
						color = "FFFFF9C4",
						fontOutlineEnable = true,
						fontOutlineColor = "FF440D01",
						fontOutlineSize = 2,
					},
				},
				{
					prop = {
						etype = "RichText",
						name = "sj",
						varName = "actTime",
						posX = 0.2581686,
						posY = 0.6647712,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4563448,
						sizeY = 0.130016,
						text = "规则写在这里",
						color = "FFFFF153",
						fontOutlineEnable = true,
						fontOutlineColor = "FF440D01",
						fontOutlineSize = 2,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "lbk",
					posX = 0.5213782,
					posY = 0.2396631,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.010666,
					sizeY = 0.4210772,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lb",
						varName = "redPackList",
						posX = 0.4654158,
						posY = 0.6341802,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7920118,
						sizeY = 0.9579138,
						horizontal = true,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "bz",
					varName = "helpBtn",
					posX = 0.6393573,
					posY = 0.767255,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.05621301,
					sizeY = 0.08482143,
					image = "xnhb2#bz",
					imageNormal = "xnhb2#bz",
					disablePressScale = true,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "lht",
				posX = 0.884908,
				posY = 0.5141141,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5192519,
				sizeY = 1.215039,
				image = "caishendao#cslh",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "ysz2",
				posX = 0.8891249,
				posY = -0.02148632,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2288228,
				sizeY = 0.06532466,
				image = "caishendao#db",
			},
			children = {
			{
				prop = {
					etype = "RichText",
					name = "ts",
					varName = "des2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.94149,
					sizeY = 1.666667,
					text = "提示文字",
					color = "FFFFF9C4",
					fontOutlineEnable = true,
					fontOutlineColor = "FF440D01",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Sprite3D",
				name = "mx",
				posX = 0.9517437,
				posY = 0.723456,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2381604,
				sizeY = 0.50812,
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
