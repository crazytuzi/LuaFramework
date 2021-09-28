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
			sizeX = 0.5101563,
			sizeY = 0.6125,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "cjsl",
				varName = "CjSl",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
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
					etype = "Image",
					name = "lbk",
					posX = 0.4999731,
					posY = 0.2971421,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.010666,
					sizeY = 0.5868225,
					image = "b#d5",
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
						name = "lb",
						varName = "scroll",
						posX = 0.5,
						posY = 0.5022127,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 0.9661876,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hdd",
					posX = 0.5030629,
					posY = 0.7999627,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.019908,
					sizeY = 0.4278761,
					image = "pinduoduo#pinduoduo",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "smd",
						posX = 0.5,
						posY = 0.3676297,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6183231,
						sizeY = 0.5428975,
						alpha = 0.5,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "wb1",
							posX = -0.08309881,
							posY = 0.1284979,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.4314432,
							sizeY = 0.4372382,
							text = "活动期限：",
							color = "FFFBE8CD",
							fontSize = 18,
							fontOutlineEnable = true,
							fontOutlineColor = "FFB12005",
							fontOutlineSize = 2,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "wb2",
							varName = "ActivitiesTime",
							posX = 0.02740511,
							posY = -0.066216,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6524516,
							sizeY = 0.4372382,
							text = "3天23小时22分钟",
							color = "FFFBE8CD",
							fontSize = 18,
							fontOutlineEnable = true,
							fontOutlineColor = "FFB12005",
							fontOutlineSize = 2,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "RichText",
							name = "wb3",
							varName = "ActivitiesContent",
							posX = 0.5,
							posY = 0.0597226,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6979078,
							sizeY = 0.7292681,
							text = "团购说明，三行文字区域。",
							color = "FFBE491E",
							fontOutlineEnable = true,
							fontOutlineColor = "FFFFF7B9",
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
					name = "sld",
					posX = 0.8455659,
					posY = 0.9446321,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2018073,
					sizeY = 0.1000578,
					image = "d2#xhd",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "lhb",
						varName = "needImg",
						posX = 0.07569733,
						posY = 0.5225382,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.3794197,
						sizeY = 1.133132,
						image = "items4#longhunbi",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "slz",
						varName = "countLabel",
						posX = 0.7048863,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8301098,
						sizeY = 0.9939547,
						text = "66666",
						color = "FFFBE8CD",
						fontSize = 22,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "jia",
						varName = "addBtn",
						posX = 1.113559,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3414778,
						sizeY = 1.065144,
						image = "jjcc#jia",
						imageNormal = "jjcc#jia",
						disablePressScale = true,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "bz",
					varName = "helpBtn",
					posX = 0.9632733,
					posY = 0.6607124,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1041348,
					sizeY = 0.154195,
					image = "chu1#bz",
					imageNormal = "chu1#bz",
					disablePressScale = true,
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
