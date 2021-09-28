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
				name = "czsl",
				varName = "CZSL",
				posX = 0.4004397,
				posY = 0.4281244,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7436743,
				sizeY = 0.9755149,
				image = "ewdlbanner#ewdlbanner",
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "hdd",
					posX = 0.5184976,
					posY = 0.4932747,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.019908,
					sizeY = 1.027438,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "smd",
						posX = 0.6773024,
						posY = 0.8520123,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6183231,
						sizeY = 0.2647895,
						alpha = 0.5,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "wb10",
							posX = -0.2595425,
							posY = -0.335312,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.39753,
							sizeY = 0.337604,
							text = "活动时间：",
							color = "FFF6C07F",
							fontSize = 22,
							fontOutlineColor = "FFFDE2FF",
							fontOutlineSize = 2,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "wb11",
							varName = "ActivitiesTime",
							posX = 0.3863467,
							posY = -0.3353122,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.053332,
							sizeY = 0.337604,
							text = "3天23小时22分钟",
							color = "FF76D646",
							fontSize = 22,
							fontOutlineColor = "FFFDE2FF",
							fontOutlineSize = 2,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "wb13",
							varName = "ActivitiesTitle",
							posX = 0.3320966,
							posY = -0.4876069,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 0.476552,
							sizeY = 0.6565704,
							fontSize = 24,
							fontOutlineEnable = true,
							fontOutlineColor = "FF00335D",
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
					name = "lbk4",
					posX = 0.4940931,
					posY = 0.5249367,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9739665,
					sizeY = 0.2988309,
					scale9 = true,
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
					alpha = 0.5,
				},
				children = {
				{
					prop = {
						etype = "RichText",
						name = "wb12",
						varName = "ActivitiesContent",
						posX = 0.6060201,
						posY = 0.16741,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.645166,
						sizeY = 1.108048,
						text = "通过什么什么副本，有几率获得额外掉落物品。",
						color = "FFF6C07F",
						fontSize = 22,
						fontOutlineColor = "FFFFFFFF",
						fontOutlineSize = 2,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "js",
						posX = 0.2104128,
						posY = 0.5987998,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2434872,
						sizeY = 0.3036204,
						text = "活动介绍：",
						color = "FFF6C07F",
						fontSize = 22,
						fontOutlineColor = "FFFFFFFF",
						fontOutlineSize = 2,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb4",
					varName = "ExtraDropList",
					posX = 0.4955682,
					posY = 0.1268538,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9230769,
					sizeY = 0.1808036,
					horizontal = true,
				},
			},
			},
		},
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
				name = "lht",
				posX = 0.9146512,
				posY = 0.553309,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3623348,
				sizeY = 1.315203,
				image = "czhdlh#lh1",
			},
		},
		{
			prop = {
				etype = "Sprite3D",
				name = "mx",
				posX = 0.934773,
				posY = 0.7210016,
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
