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
			name = "lbjd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.6,
			sizeY = 0.11,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "t1",
				varName = "suicongBg",
				posX = 0.4937639,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.98,
				sizeY = 1.132611,
				image = "dw#d3",
				scale9 = true,
				scale9Left = 0.1,
				scale9Right = 0.1,
				scale9Top = 0.1,
				scale9Bottom = 0.1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz",
				varName = "teamid_lable",
				posX = 0.08368994,
				posY = 0.5126263,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.07084994,
				sizeY = 0.6142268,
				text = "1.",
				color = "FF634624",
				fontSize = 24,
				fontOutlineColor = "FF00152E",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "dw",
				varName = "teamName_lable",
				posX = 0.2681067,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4455623,
				sizeY = 0.5914149,
				text = "谁是额的队伍",
				color = "FF966856",
				fontSize = 22,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz2",
				varName = "teamCount_lable",
				posX = 0.6433169,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.07474904,
				sizeY = 0.6142268,
				text = "2/4",
				color = "FFC93034",
				fontSize = 22,
				fontOutlineColor = "FF00152E",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "join_btn",
				posX = 0.8561845,
				posY = 0.4873737,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1601563,
				sizeY = 0.7323233,
				image = "chu1#an3",
				imageNormal = "chu1#an3",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "zzz",
					posX = 0.5,
					posY = 0.5517241,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6125244,
					sizeY = 1.025976,
					text = "加 入",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FF2A6953",
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
