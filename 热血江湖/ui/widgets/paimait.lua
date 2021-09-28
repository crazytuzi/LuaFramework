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
			sizeX = 0.6571686,
			sizeY = 0.1672382,
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
				posX = 0.2584413,
				posY = 0.4870588,
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
				etype = "Image",
				name = "dj",
				varName = "itemBg",
				posX = 0.08459771,
				posY = 0.5,
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
				varName = "yb1",
				posX = 0.4037072,
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
					varName = "curPrice",
					posX = 2.412314,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 2.76453,
					sizeY = 0.9459509,
					text = "160000",
					color = "FFF54516",
					fontSize = 22,
					fontOutlineColor = "FF302A14",
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "yb2",
				varName = "yb2",
				posX = 0.6731997,
				posY = 0.7154973,
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
					name = "lbtz4",
					varName = "bidPrice",
					posX = 2.412314,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 2.76453,
					sizeY = 0.9459509,
					text = "160000",
					color = "FF466F22",
					fontSize = 22,
					fontOutlineColor = "FF302A14",
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "yb3",
				varName = "yb3",
				posX = 0.854797,
				posY = 0.7154976,
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
					name = "lbtz6",
					varName = "finalPrice",
					posX = 2.412314,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 2.76453,
					sizeY = 0.9459509,
					text = "160000",
					color = "FF466F22",
					fontSize = 22,
					fontOutlineColor = "FF302A14",
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "lba3",
				varName = "bidBtn",
				posX = 0.7158113,
				posY = 0.3176307,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1661095,
				sizeY = 0.4401573,
				image = "chu1#an1",
				imageNormal = "chu1#an1",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "anz7",
					varName = "bidLabel",
					posX = 0.5,
					posY = 0.5377356,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8401152,
					sizeY = 1.00501,
					text = "竞 价",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FFB35F1D",
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
				name = "lba2",
				varName = "finalBtn",
				posX = 0.8976977,
				posY = 0.3176307,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1661095,
				sizeY = 0.4401573,
				image = "chu1#an2",
				imageNormal = "chu1#an2",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "anz6",
					posX = 0.5,
					posY = 0.5377358,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8401152,
					sizeY = 1.00501,
					text = "一口价",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FF1C7760",
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
				name = "ysc",
				varName = "soldOut",
				posX = 0.8109582,
				posY = 0.4917071,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.1783218,
				sizeY = 0.7308272,
				image = "chu1#shouchu",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "buhuo",
				varName = "buhuo",
				posX = 0.4572858,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.1783218,
				sizeY = 0.7308272,
				image = "chu1#buhuo",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "bhz",
					varName = "bhTime",
					posX = 2.017425,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 2.728848,
					sizeY = 1.3843,
					text = "补货倒计时：xxxxxxxx",
					color = "FFC93034",
					fontSize = 22,
					hTextAlign = 2,
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
