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
			etype = "Grid",
			name = "renwu",
			varName = "taskRoot",
			posX = 0.09440771,
			posY = 0.5965136,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.180874,
			sizeY = 0.259625,
			layoutType = 7,
			layoutTypeW = 7,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "smd",
				posX = 0.5,
				posY = 0.5394599,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.8864978,
				image = "b#rwd",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "mb",
					posX = 0.3620238,
					posY = 0.8570526,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6622287,
					sizeY = 0.3431182,
					text = "当前目标",
					color = "FFFFF554",
					fontSize = 22,
					fontOutlineColor = "FF27221D",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "z2",
					varName = "taskName",
					posX = 0.5054504,
					posY = 0.6605499,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.949082,
					sizeY = 0.1830747,
					text = "述一小描述一大推大推",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "bt1",
					varName = "show_btn",
					posX = 0.5012361,
					posY = 0.1242104,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.02014,
					sizeY = 0.2215703,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "bt2",
					varName = "doTaskBtn",
					posX = 0.4947612,
					posY = 0.6275806,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9985736,
					sizeY = 0.7448933,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "tsz",
					varName = "titleName",
					posX = 0.701469,
					posY = 1.097701,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.347915,
					sizeY = 0.3430228,
					text = "探索宠物身世副本中...",
					color = "FFFFF554",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FF27221D",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "z3",
					varName = "taskDesc",
					posX = 0.5054504,
					posY = 0.3725109,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.949082,
					sizeY = 0.3594382,
					text = "小描述一大推小描述一小描述一大推大推",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "qmd3",
				posX = 0.495692,
				posY = 0.186592,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.015037,
				sizeY = 0.1711871,
				image = "chu1#jdd",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "LoadingBar",
					name = "qmdt3",
					varName = "percent",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9531912,
					sizeY = 0.6249999,
					image = "tong#jdt2",
					scale9Left = 0.3,
					scale9Right = 0.3,
					imageHead = "ty#guang",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "qmdz3",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.6811866,
					sizeY = 1.803565,
					text = "12/666",
					fontOutlineEnable = true,
					fontOutlineColor = "FF5B7838",
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
			etype = "Grid",
			name = "ysj",
			posX = 0.7491965,
			posY = 0.7502891,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.4968341,
			sizeY = 0.4950193,
			layoutType = 9,
			layoutTypeW = 9,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "wg",
				posX = 0.485872,
				posY = 0.8697749,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1257965,
				sizeY = 0.2244581,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "wg1",
					varName = "skillBtn",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					image = "tb#wg",
					imageNormal = "tb#wg",
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
	gy = {
	},
	gy2 = {
	},
	gy3 = {
	},
	gy4 = {
	},
	gy5 = {
	},
	gy6 = {
	},
	gy7 = {
	},
	c_dakai = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
