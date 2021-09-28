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
			name = "aaa",
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
				name = "bbbb",
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
				etype = "Grid",
				name = "y1",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4441643,
				sizeY = 0.4440795,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "b1",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					image = "b#cs",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.25,
					scale9Bottom = 0.7,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "b11",
						posX = 0.6824655,
						posY = 0.5060489,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8144796,
						sizeY = 0.9995878,
						image = "hua1#hua1",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "b2",
					posX = 0.5,
					posY = 0.6107721,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8692365,
					sizeY = 0.5401812,
					image = "b#d2",
					scale9 = true,
					scale9Left = 0.2,
					scale9Right = 0.2,
					scale9Top = 0.2,
					scale9Bottom = 0.2,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "b21",
						varName = "itemBg",
						posX = 0.12,
						posY = 0.6055892,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1902113,
						sizeY = 0.5442459,
						image = "djk#kbai",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "b211",
							varName = "itemIcon",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8510637,
							sizeY = 0.8510638,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "w211",
							varName = "itemCount",
							posX = 0.7124224,
							posY = 0.1846435,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6,
							sizeY = 0.3627777,
							text = "999",
							fontOutlineEnable = true,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "w21",
						varName = "itemName",
						posX = 0.12,
						posY = 0.1704495,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.178785,
						sizeY = 0.25,
						text = "资料名称",
						color = "FF966856",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "b22",
						posX = 0.5,
						posY = 0.6055892,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4957634,
						sizeY = 0.4052895,
						image = "sl#sld",
					},
					children = {
					{
						prop = {
							etype = "Button",
							name = "a211",
							varName = "jian",
							posX = 0.1142856,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.2244898,
							sizeY = 1,
							image = "sl#jian",
							imageNormal = "sl#jian",
						},
					},
					{
						prop = {
							etype = "Button",
							name = "a212",
							varName = "jia",
							posX = 0.8857152,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.2244898,
							sizeY = 1,
							image = "sl#jia",
							imageNormal = "sl#jia",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "w212",
							varName = "donateCount",
							posX = 0.5040816,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6,
							sizeY = 1,
							text = "0",
							fontSize = 26,
							fontOutlineEnable = true,
							fontOutlineColor = "FF2E1410",
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Button",
						name = "b23",
						varName = "max",
						posX = 0.88,
						posY = 0.6055891,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.169976,
						sizeY = 0.4805575,
						image = "sl#max",
						imageNormal = "sl#max",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "cs",
						varName = "leftTimes",
						posX = 0.5,
						posY = -0.1184458,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.6,
						sizeY = 0.25,
						text = "剩余次数：0",
						color = "FF966856",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "b3",
					posX = 0.5,
					posY = 1,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4643551,
					sizeY = 0.1626335,
					image = "chu1#top",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "b31",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5113637,
						sizeY = 0.4807694,
						image = "biaoti#jxcl",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "b4",
					varName = "donateBtn",
					posX = 0.5,
					posY = 0.1219753,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3060523,
					sizeY = 0.2064195,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "w31",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 1,
						text = "捐献",
						fontSize = 26,
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
					name = "bg",
					varName = "money_icon",
					posX = 0.5182621,
					posY = 0.4409602,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.08794606,
					sizeY = 0.1563784,
					image = "tb#banggong",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "z3",
						varName = "getCount",
						posX = 2.261822,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 2.087753,
						sizeY = 0.8111176,
						text = "333",
						color = "FF966856",
						fontSize = 22,
						fontOutlineColor = "FF27221D",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "z2",
						varName = "item_desc",
						posX = -0.6333919,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.838093,
						sizeY = 0.7596457,
						text = "获得",
						color = "FF966856",
						fontSize = 22,
						fontOutlineColor = "FF27221D",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "b12",
					varName = "closeBtn",
					posX = 0.9384375,
					posY = 0.874897,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1178477,
					sizeY = 0.2376952,
					image = "chu1#gb",
					imageNormal = "chu1#gb",
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
