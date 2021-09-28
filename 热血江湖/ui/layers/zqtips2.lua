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
			etype = "Button",
			name = "an",
			varName = "closeBtn",
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
			etype = "Grid",
			name = "ysjm",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.88,
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
				sizeX = 0.6295558,
				sizeY = 0.4813315,
				image = "b#db5",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "zd",
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
					name = "db1",
					posX = 0.2500968,
					posY = 0.4178973,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4631862,
					sizeY = 0.7345991,
					image = "b#d2",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "top",
						posX = 0.5,
						posY = 1,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.566279,
						sizeY = 0.1459887,
						image = "chu1#top2",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "z2",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9618692,
							sizeY = 1.12546,
							text = "属性区间",
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
				},
			},
			{
				prop = {
					etype = "Image",
					name = "db2",
					posX = 0.75,
					posY = 0.4178973,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4631862,
					sizeY = 0.7345991,
					image = "b#d2",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "top2",
						posX = 0.5,
						posY = 1,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.566279,
						sizeY = 0.1459887,
						image = "chu1#top2",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "z4",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9618692,
							sizeY = 1.12546,
							text = "等级效果",
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
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dw2",
					posX = 0.5000001,
					posY = 0.8604574,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9499999,
					sizeY = 0.005771028,
					image = "b#xian",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z1",
					varName = "enhanceLvlLabel",
					posX = 0.7499999,
					posY = 0.917968,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3688603,
					sizeY = 0.1445523,
					text = "洗练等级：15",
					color = "FF65944D",
					fontSize = 22,
					fontOutlineColor = "FF27221D",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z3",
					varName = "steedName",
					posX = 0.2500967,
					posY = 0.917968,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4575537,
					sizeY = 0.1445523,
					text = "什么宠物",
					color = "FF966856",
					fontSize = 22,
					fontOutlineColor = "FF27221D",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xian",
					posX = 0.4996448,
					posY = 0.4253197,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3677462,
					sizeY = 0.01441575,
					image = "b#xian2",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					rotation = 90,
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb1",
					varName = "attrScroll",
					posX = 0.2500968,
					posY = 0.397717,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4476999,
					sizeY = 0.6769853,
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb2",
					varName = "descScroll",
					posX = 0.7500001,
					posY = 0.397717,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4476999,
					sizeY = 0.6769853,
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
