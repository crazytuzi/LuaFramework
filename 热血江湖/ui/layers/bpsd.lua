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
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
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
						name = "db3",
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
					etype = "Button",
					name = "shx",
					varName = "refresh_btn",
					posX = 0.1646429,
					posY = 0.9018819,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1809286,
					sizeY = 0.09295141,
					propagateToChildren = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "shxz",
						posX = 0.8803967,
						posY = 0.5000011,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.15252,
						sizeY = 0.9142867,
						text = "立即刷新",
						color = "FF966856",
						fontSize = 22,
						fontOutlineColor = "FF0E3B2F",
						fontOutlineSize = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "fsa",
						posX = 0.1415796,
						posY = 0.4629024,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2395959,
						sizeY = 0.7605012,
						image = "te#sx",
						imageNormal = "te#sx",
						disableClick = true,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "tsz",
					posX = 0.356187,
					posY = 0.9018818,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.26345,
					sizeY = 0.09962725,
					text = "下次自动刷新时间：",
					color = "FF966856",
					fontSize = 22,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "tsz2",
					varName = "refreshTime",
					posX = 0.586778,
					posY = 0.9018818,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1734571,
					sizeY = 0.09962725,
					text = "明日21点",
					color = "FF966856",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "db2",
					posX = 0.1852715,
					posY = 0.4358295,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.2852445,
					sizeY = 0.8251818,
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
						name = "lbt2",
						varName = "item_scroll2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.99,
						sizeY = 0.98,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "db",
					posX = 0.4999782,
					posY = 0.4633781,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.838165,
					sizeY = 0.7873256,
					image = "b#d2",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lbt",
						varName = "item_scroll",
						posX = 0.5,
						posY = 0.4999999,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9705898,
						sizeY = 0.9762198,
						showScrollBar = false,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dw2",
					posX = 0.8713318,
					posY = 0.9018818,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1602609,
					sizeY = 0.06551724,
					image = "d2#xhd",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "bg",
						varName = "contri_value",
						posX = 0.5843666,
						posY = 0.4936842,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6500971,
						sizeY = 1.386121,
						text = "999999",
						color = "FF966856",
						fontSize = 24,
						fontOutlineColor = "FF804000",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "bgb",
						varName = "contri_icon",
						posX = 0.1492374,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.3073805,
						sizeY = 1.315789,
						image = "tb#tb_tongqian.png",
					},
				},
				{
					prop = {
						etype = "Button",
						name = "test",
						varName = "money_root",
						posX = 0.4943936,
						posY = 0.5118054,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.969336,
						sizeY = 0.8785705,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "close_btn",
					posX = 0.9650654,
					posY = 0.9355491,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.06600985,
					sizeY = 0.1310345,
					image = "chu1#gb",
					imageNormal = "chu1#gb",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "zuo",
					varName = "addPage",
					posX = 0.9980296,
					posY = 0.4173765,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.04236453,
					sizeY = 0.09310345,
					image = "chu1#jiantou",
					imageNormal = "chu1#jiantou",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "zuo2",
					varName = "subPage",
					posX = 0,
					posY = 0.4173765,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.04236453,
					sizeY = 0.09310345,
					image = "chu1#jiantou",
					imageNormal = "chu1#jiantou",
					flippedX = true,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dw3",
					varName = "currencyIcon2",
					posX = 0.703028,
					posY = 0.9018818,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1602609,
					sizeY = 0.06551724,
					image = "d2#xhd",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "bg2",
						varName = "contri_value2",
						posX = 0.5843666,
						posY = 0.4936842,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6500971,
						sizeY = 1.386121,
						text = "999999",
						color = "FF966856",
						fontSize = 24,
						fontOutlineColor = "FF804000",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "bgb2",
						varName = "contri_icon2",
						posX = 0.1492374,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.3073805,
						sizeY = 1.315789,
						image = "tb#tb_tongqian.png",
					},
				},
				{
					prop = {
						etype = "Button",
						name = "test2",
						varName = "money_root2",
						posX = 0.4943936,
						posY = 0.5118054,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.969336,
						sizeY = 0.8785705,
					},
				},
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
					varName = "shopName",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.5113636,
					sizeY = 0.4807692,
					image = "biaoti#bpsc",
				},
			},
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "tswb",
				varName = "discount_desc",
				posX = 0.6052949,
				posY = 0.05757848,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5210192,
				sizeY = 0.1776901,
				text = "提示文本",
				hTextAlign = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "tswb2",
				varName = "specialText",
				posX = 0.3752043,
				posY = 0.05757848,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.48046,
				sizeY = 0.1776901,
				text = "提示文本",
				vTextAlign = 1,
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
