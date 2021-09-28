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
				varName = "rootBg",
				posX = 0.5842898,
				posY = 0.3063759,
				anchorX = 1,
				anchorY = 0.5,
				sizeX = 0.3370339,
				sizeY = 0.2198748,
				image = "d#tst",
				scale9 = true,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an4",
				varName = "descBtn",
				posX = 0.5226998,
				posY = 0.3035196,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.053125,
				sizeY = 0.1349206,
				image = "chu1#sx2",
				imageNormal = "chu1#sx2",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jn1",
				posX = 0.4438246,
				posY = 0.3038906,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.0625,
				sizeY = 0.1587302,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "jnt1",
					varName = "itemIcon2",
					posX = 0.5061287,
					posY = 0.5137039,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7370484,
					sizeY = 0.7467495,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl1",
					varName = "count2",
					posX = 0.493665,
					posY = 0.2516251,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7620125,
					sizeY = 0.4222755,
					text = "x18",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an1",
					varName = "btn2",
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
					etype = "LoadingBar",
					name = "lq1",
					varName = "cd2",
					posX = 0.5065144,
					posY = 0.5209323,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9359602,
					sizeY = 0.9359612,
					image = "b#bp",
					barDirection = 3,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jn2",
				posX = 0.3461725,
				posY = 0.3038906,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.0625,
				sizeY = 0.1587302,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "jnt2",
					varName = "itemIcon1",
					posX = 0.5061287,
					posY = 0.5137039,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7370484,
					sizeY = 0.7467495,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl2",
					varName = "count1",
					posX = 0.493665,
					posY = 0.2516251,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7620125,
					sizeY = 0.4222755,
					text = "x18",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an2",
					varName = "btn1",
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
					etype = "LoadingBar",
					name = "lq2",
					varName = "cd1",
					posX = 0.5065144,
					posY = 0.5209501,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9359602,
					sizeY = 0.9359612,
					image = "b#bp",
					barDirection = 3,
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
