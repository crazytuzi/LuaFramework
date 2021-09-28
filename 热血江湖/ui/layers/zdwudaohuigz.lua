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
			name = "jd",
			posX = 0.5,
			posY = 0.35,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 0.7,
			layoutType = 2,
			layoutTypeW = 2,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				varName = "findRoot",
				posX = 0.34,
				posY = 0.1310665,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2721583,
				sizeY = 0.2076917,
				image = "zd#ltd",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "bc",
					varName = "teamName1",
					posX = 0.4817243,
					posY = 0.7871834,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8244824,
					sizeY = 0.4242095,
					image = "teamName1",
					text = "队伍名称1",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb",
					varName = "scroll1",
					posX = 0.5,
					posY = 0.4051003,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9210641,
					sizeY = 0.5984849,
					showScrollBar = false,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt2",
				posX = 0.66,
				posY = 0.1310665,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2721583,
				sizeY = 0.2076917,
				image = "zd#ltd",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "bc2",
					varName = "teamName2",
					posX = 0.4817243,
					posY = 0.7871834,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8244824,
					sizeY = 0.4242095,
					image = "teamName2",
					text = "队伍名称2",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb2",
					varName = "scroll2",
					posX = 0.5,
					posY = 0.3955665,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9210641,
					sizeY = 0.5794172,
					showScrollBar = false,
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
	c_box = {
		{2,"gy", 1, 0},
		{2,"gy2", 1, 0},
		{2,"liz", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
