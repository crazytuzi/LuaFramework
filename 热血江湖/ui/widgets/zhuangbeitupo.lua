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
			etype = "Image",
			name = "z3",
			varName = "max_view",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.4446167,
			sizeY = 0.8472222,
			scale9 = true,
			scale9Left = 0.41,
			scale9Right = 0.37,
			scale9Top = 0.4,
			scale9Bottom = 0.4,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt2",
				posX = 0.4988681,
				posY = 0.75,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9435938,
				sizeY = 0.4294534,
				image = "b#d4",
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
					name = "top4",
					posX = 0.5,
					posY = 0.9017377,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3463635,
					sizeY = 0.1374221,
					image = "chu1#top2",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "topz",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7056674,
						sizeY = 1.047195,
						text = "详情",
						color = "FFF1E9D7",
						fontOutlineEnable = true,
						fontOutlineColor = "FFA47848",
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
					name = "zb9",
					posX = 0.2561291,
					posY = 0.5996656,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1839434,
					sizeY = 0.3817354,
					disablePressScale = true,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "pjd9",
						varName = "grade_icon",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9516184,
						sizeY = 0.9399819,
						image = "djk#ktong",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zbt9",
						varName = "equip_icon",
						posX = 0.5,
						posY = 0.5087036,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8,
						sizeY = 0.8,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "qhz9",
						varName = "qh_level",
						posX = 0.4342432,
						posY = 0.2310104,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7248785,
						sizeY = 0.3761843,
						text = "+11",
						fontOutlineEnable = true,
						fontOutlineColor = "FF27221D",
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "zbm",
					varName = "equip_name",
					posX = 0.256129,
					posY = 0.2983959,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4258526,
					sizeY = 0.1837038,
					text = "装备名称",
					fontSize = 22,
					fontOutlineColor = "FF27221D",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "md2",
					varName = "max_desc2",
					posX = 0.6587481,
					posY = 0.514711,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3780204,
					sizeY = 0.182641,
					image = "bs#dw",
					alpha = 0.7,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "sx1",
						varName = "propName1",
						posX = 0.3374111,
						posY = 0.6261365,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5082383,
						sizeY = 1.196121,
						text = "战力：",
						color = "FF966856",
						fontOutlineColor = "FF27221D",
						vTextAlign = 1,
						colorTL = "FFFFD060",
						colorTR = "FFFFD060",
						colorBR = "FFF2441C",
						colorBL = "FFF2441C",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sxz1",
						varName = "propValue1",
						posX = 1.029046,
						posY = 0.6261366,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8726735,
						sizeY = 1.150013,
						text = "33333333",
						color = "FFFFD97F",
						fontOutlineEnable = true,
						fontOutlineColor = "FF895F30",
						fontOutlineSize = 2,
						vTextAlign = 1,
						colorTL = "FFFFD060",
						colorTR = "FFFFD060",
						colorBR = "FFF2441C",
						colorBL = "FFF2441C",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "md1",
					varName = "max_desc1",
					posX = 0.6587481,
					posY = 0.7225403,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3780204,
					sizeY = 0.1717776,
					image = "bs#dw",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "qe3",
						varName = "qh_equip_lv3",
						posX = 0.3701567,
						posY = 0.5916363,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5574697,
						sizeY = 1.049401,
						text = "等级：",
						color = "FF966856",
						fontSize = 22,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "qhdja5",
						varName = "lv_icon1",
						posX = 0.6842259,
						posY = 0.548874,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1242718,
						sizeY = 0.8626186,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "qhdja6",
						varName = "lv_icon2",
						posX = 0.7736701,
						posY = 0.5710647,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1242718,
						sizeY = 0.8626186,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "qhdja7",
						varName = "lv_icon5",
						posX = 0.533609,
						posY = 0.5488763,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1242718,
						sizeY = 0.8626186,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "md3",
					varName = "prop1",
					posX = 0.6587481,
					posY = 0.3486943,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3780204,
					sizeY = 0.182641,
					image = "bs#dw",
					alpha = 0.7,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "sx2",
						varName = "propName2",
						posX = 0.3374111,
						posY = 0.6261365,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5082383,
						sizeY = 1.196121,
						text = "物理：",
						color = "FF966856",
						fontOutlineColor = "FF27221D",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sxz2",
						varName = "propValue2",
						posX = 1.029046,
						posY = 0.6261364,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8726736,
						sizeY = 1.150013,
						text = "33333333",
						color = "FFF1E9D7",
						fontOutlineEnable = true,
						fontOutlineColor = "FFA47848",
						fontOutlineSize = 2,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "md4",
					varName = "prop2",
					posX = 0.6587481,
					posY = 0.1826776,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3780204,
					sizeY = 0.182641,
					image = "bs#dw",
					alpha = 0.7,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "sx3",
						varName = "propName3",
						posX = 0.3374111,
						posY = 0.6261364,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5082383,
						sizeY = 1.196121,
						text = "物理：",
						color = "FF966856",
						fontOutlineColor = "FF27221D",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sxz3",
						varName = "propValue3",
						posX = 1.029046,
						posY = 0.6261364,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8726736,
						sizeY = 1.150013,
						text = "33333333",
						color = "FFF1E9D7",
						fontOutlineEnable = true,
						fontOutlineColor = "FFA47848",
						fontOutlineSize = 2,
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
				name = "dt1",
				posX = 0.5000001,
				posY = 0.291326,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9435937,
				sizeY = 0.283141,
				image = "b#d4",
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
					name = "top3",
					posX = 0.5,
					posY = 0.8597474,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3736657,
					sizeY = 0.2084347,
					image = "chu1#top2",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "toz",
						posX = 0.5,
						posY = 0.4722222,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6399879,
						sizeY = 1.666666,
						text = "所需材料",
						color = "FFF1E9D7",
						fontOutlineEnable = true,
						fontOutlineColor = "FFA47848",
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
					name = "an1",
					varName = "breakBtn",
					posX = 0.5,
					posY = -0.2916901,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3043801,
					sizeY = 0.3589708,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "ann1",
						varName = "increase_label1",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9120977,
						sizeY = 0.9366539,
						text = "突破",
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
					etype = "Scroll",
					name = "lb3",
					varName = "item_scroll",
					posX = 0.5,
					posY = 0.3959449,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9467255,
					sizeY = 0.6994289,
					horizontal = true,
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tsz",
				posX = 0.5,
				posY = 0.4852463,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.25,
				text = "突破后可继续升级",
				color = "FFC93034",
				fontSize = 22,
				hTextAlign = 1,
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
