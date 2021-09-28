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
			name = "zz",
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
			varName = "isMax",
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
				etype = "Label",
				name = "hdz3",
				posX = 0.5,
				posY = 0.2883354,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2914189,
				sizeY = 0.1527318,
				text = "点击任意区域关闭",
				color = "FFFFFF80",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tp1",
				posX = 0.5,
				posY = 0.4919285,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7359375,
				sizeY = 0.075,
				image = "zhounianqingwh#xx",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tp2",
				posX = 0.5,
				posY = 0.6569377,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7359375,
				sizeY = 0.07638889,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tp3",
				posX = 0.5015593,
				posY = 0.3796147,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6945312,
				sizeY = 0.05138889,
				image = "zhounianqingwh#tiao",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "hdz2",
					varName = "getExp",
					posX = 0.8767708,
					posY = 0.5000003,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3155662,
					sizeY = 1.778072,
					text = "00",
					color = "FFFAFFA6",
					fontOutlineEnable = true,
					fontOutlineColor = "FFA53116",
					fontOutlineSize = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "hdz",
					posX = 0.3876987,
					posY = 0.5000006,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6311328,
					sizeY = 1.778072,
					text = "本次获得经验（每天仅可获得一轮经验奖励）",
					color = "FFFAFFA6",
					fontOutlineEnable = true,
					fontOutlineColor = "FFA53116",
					fontOutlineSize = 2,
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
	dk = {
		tp1 = {
			alpha = {{0, {1}}, {500, {0}}, {1800, {1}}, },
		},
		tp2 = {
			alpha = {{0, {1}}, {500, {0}}, {1800, {1}}, },
		},
	},
	c_dakai = {
		{0,"dk", -1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
