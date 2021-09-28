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
			sizeX = 0.4945312,
			sizeY = 0.09722222,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "btn",
				varName = "select_btn",
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
				name = "dq",
				varName = "showselect",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "hx#hx1",
				scale9 = true,
				scale9Left = 0.48,
				scale9Right = 0.48,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "jt",
					posX = 0.04230712,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.03461539,
					sizeY = 0.3142858,
					image = "chu1#jt2",
				},
			},
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "fwb",
				varName = "lineOrder",
				posX = 0.3189793,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4586365,
				sizeY = 0.9736063,
				text = "一线",
				color = "FF966856",
				fontOutlineColor = "FF102E21",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "fwb2",
				varName = "totalNum",
				posX = 0.5083469,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5759028,
				sizeY = 0.9736063,
				text = "人数：100/100",
				color = "FF966856",
				fontOutlineColor = "FF102E21",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "fwb3",
				varName = "sectNum",
				posX = 0.7206848,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3724637,
				sizeY = 0.9736063,
				text = "本帮人数：50",
				color = "FF966856",
				fontOutlineColor = "FF102E21",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "jr",
				varName = "enter_btn",
				posX = 0.8873625,
				posY = 0.4856733,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1958926,
				sizeY = 0.8285715,
				image = "chu1#sn1",
				imageNormal = "chu1#sn1",
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "jrz",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9150806,
					sizeY = 0.8478857,
					text = "进 入",
					color = "FF966856",
					fontSize = 22,
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
