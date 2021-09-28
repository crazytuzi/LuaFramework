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
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.6319455,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.2971277,
				sizeY = 0.2860788,
				image = "b#bp",
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
					name = "z1",
					posX = 0.2817781,
					posY = 0.8324593,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.420692,
					sizeY = 0.1971751,
					text = "当前时间：",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z2",
					posX = 0.2817781,
					posY = 0.6657428,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.420692,
					sizeY = 0.1971751,
					text = "已买体力次数：",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z3",
					posX = 0.2817781,
					posY = 0.4990262,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.420692,
					sizeY = 0.1971751,
					text = "下点体力恢复：",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z4",
					posX = 0.2817781,
					posY = 0.3323097,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.420692,
					sizeY = 0.1971751,
					text = "恢复全部体力：",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z5",
					posX = 0.2817781,
					posY = 0.1655932,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.420692,
					sizeY = 0.1971751,
					text = "恢复时间间隔：",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z6",
					varName = "nowTime",
					posX = 0.6898311,
					posY = 0.8324594,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4602432,
					sizeY = 0.1971751,
					text = "加成1",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z7",
					varName = "boughtTimes",
					posX = 0.6898311,
					posY = 0.6657429,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4602432,
					sizeY = 0.1971751,
					text = "加成1",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z8",
					varName = "nextVitTime",
					posX = 0.6898311,
					posY = 0.4990264,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4602432,
					sizeY = 0.1971751,
					text = "加成1",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z9",
					varName = "maxVitTime",
					posX = 0.6898311,
					posY = 0.3323098,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4602432,
					sizeY = 0.1971751,
					text = "加成1",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z10",
					varName = "intervalTime",
					posX = 0.6898311,
					posY = 0.1655933,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4602432,
					sizeY = 0.1971751,
					text = "加成1",
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
