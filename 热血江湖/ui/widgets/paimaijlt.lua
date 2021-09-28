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
			name = "lbdt1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.6504923,
			sizeY = 0.1655392,
			image = "b#lbt",
			scale9 = true,
			scale9Left = 0.2,
			scale9Right = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Label",
				name = "lbtz1",
				varName = "name_label",
				posX = 0.2520729,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2338247,
				sizeY = 0.5047162,
				text = "名字六个字啊",
				color = "FF966856",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "lbtz5",
				varName = "gsid",
				posX = 0.415042,
				posY = 0.5119403,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1781897,
				sizeY = 0.4762154,
				text = "666654",
				color = "FF2983DF",
				fontSize = 22,
				fontOutlineColor = "FF0E3B2F",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dj",
				varName = "itemBg",
				posX = 0.07701225,
				posY = 0.4991337,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.101049,
				sizeY = 0.7059126,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt",
					varName = "itemIcon",
					posX = 0.5026811,
					posY = 0.5231765,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7698042,
					sizeY = 0.7674302,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btnn",
					varName = "itemBtn",
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
					etype = "Label",
					name = "sl",
					varName = "itemCount",
					posX = 0.4967806,
					posY = 0.2118887,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8285293,
					sizeY = 0.3798225,
					text = "x111",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "yb",
				varName = "diamond",
				posX = 0.5879334,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.05944059,
				sizeY = 0.4152427,
				image = "tb#yuanbao",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "lbtz3",
					varName = "count",
					posX = 2.412314,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 2.76453,
					sizeY = 0.9459509,
					text = "160000",
					color = "FF65944D",
					fontSize = 22,
					fontOutlineColor = "FF302A14",
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "lbtz2",
				varName = "buyerName",
				posX = 0.871495,
				posY = 0.5119401,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2762331,
				sizeY = 0.5047162,
				text = "名字六个字啊",
				color = "FFF54516",
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
