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
		closeAfterOpenAni = true,
	},
	children = {
	{
		prop = {
			etype = "Grid",
			name = "jd",
			posX = 0.5,
			posY = 0.2504043,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 0.5,
			alphaCascade = true,
			layoutType = 2,
			layoutTypeW = 2,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "tsk",
				posX = 0.5,
				posY = 0.7097108,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3291457,
				sizeY = 0.3802212,
				image = "b#zyd",
				scale9 = true,
				scale9Left = 0.55,
				scale9Right = 0.4,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
				alphaCascade = true,
			},
			children = {
			{
				prop = {
					etype = "RichText",
					name = "ts1",
					varName = "desc",
					posX = 0.5082905,
					posY = 0.4873645,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7886244,
					sizeY = 0.4067731,
					text = "复活球最好使",
					color = "FF966856",
					hTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "ts2",
					posX = 0.5082905,
					posY = 0.200987,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8791494,
					sizeY = 0.25,
					text = "点击此提示立即关闭",
					color = "FFC93034",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn",
					varName = "closeBtn",
					posX = 0.5052121,
					posY = 0.4690847,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.008532,
					sizeY = 1.012031,
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
	dakai = {
		jd = {
			alpha = {{0, {1}}, {4000, {1}}, {4300, {0}}, },
		},
	},
	c_dakai = {
		{0,"dakai", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
