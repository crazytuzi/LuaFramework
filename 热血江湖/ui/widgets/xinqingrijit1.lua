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
			name = "jie1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.4945312,
			sizeY = 0.15,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "btn",
				varName = "showdelete_btn",
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
				name = "lbt",
				varName = "background",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1.009259,
				image = "ptbj#qp",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.3,
				scale9Bottom = 0.5,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "xqz",
				varName = "diaryContent",
				posX = 0.5149822,
				posY = 0.5204529,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8721856,
				sizeY = 0.6986126,
				text = "日记文字写在这里",
				color = "FF966856",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "sc",
				varName = "delete_btn",
				posX = 0.8809658,
				posY = 0.5278045,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1374408,
				sizeY = 0.3425926,
				image = "xqrj#shanchu",
				imageNormal = "xqrj#shanchu",
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "scz",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9884249,
					sizeY = 1.906072,
					text = "删 除",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "xqz3",
				varName = "date",
				posX = 0.5100678,
				posY = 0.2085111,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8820143,
				sizeY = 0.7034508,
				text = "2018-04-06 16:33",
				color = "FF966856",
				fontSize = 18,
				hTextAlign = 2,
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
