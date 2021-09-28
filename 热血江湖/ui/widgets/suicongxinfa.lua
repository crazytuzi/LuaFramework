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
			name = "tupo",
			varName = "breakRoot",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2882813,
			sizeY = 0.8388889,
			scale9 = true,
			scale9Left = 0.3,
			scale9Right = 0.3,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "bt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.598916,
				sizeY = 0.5298013,
				image = "d#bt",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
				rotation = 90,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wb1",
				posX = 0.4975388,
				posY = 0.06811411,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.1035112,
				text = "当前战绩：",
				color = "FF966856",
				fontSize = 22,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wb2",
				varName = "count",
				posX = 0.6451346,
				posY = 0.06645848,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2296086,
				sizeY = 0.1035112,
				text = "500",
				color = "FF65944D",
				fontSize = 22,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "jia",
				varName = "btn",
				posX = 0.773469,
				posY = 0.07142535,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1544715,
				sizeY = 0.09437086,
				image = "chu1#jia",
				imageNormal = "chu1#jia",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "hx1",
				posX = 0.75,
				posY = 0.5157529,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05420053,
				sizeY = 0.7781457,
				image = "sui#zst",
				scale9 = true,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "hx2",
				posX = 0.25,
				posY = 0.5157529,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05420053,
				sizeY = 0.7781457,
				image = "sui#zst",
				scale9 = true,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
		},
		{
			prop = {
				etype = "Scroll",
				name = "lb",
				varName = "scroll",
				posX = 0.5,
				posY = 0.5115399,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8346882,
				sizeY = 0.8231506,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "top",
				posX = 0.4864725,
				posY = 0.9594818,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7615175,
				sizeY = 0.05298013,
				image = "chu1#top3",
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
					sizeX = 0.8692334,
					sizeY = 1.12294,
					text = "宠物心法",
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
	},
}
--EDITOR elements end tag
--EDITOR animations start tag
local l_animations =
{
	gy = {
	},
	gy2 = {
	},
	gy3 = {
	},
	gy4 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
