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
			name = "shengji",
			varName = "upgradeRoot",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.29375,
			sizeY = 0.7763889,
			scale9 = true,
			scale9Top = 0.3,
			scale9Bottom = 0.3,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "kkk",
				posX = 0.5,
				posY = 0.5956832,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9062512,
				sizeY = 0.3023792,
				image = "b#d2",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
				alpha = 0.5,
			},
			children = {
			{
				prop = {
					etype = "Scroll",
					name = "lb",
					varName = "scroll",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z1",
				varName = "level",
				posX = 0.4775266,
				posY = 0.93965,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2892201,
				sizeY = 0.08989987,
				text = "等级:",
				color = "FF966856",
				fontSize = 22,
				fontOutlineColor = "FF00152E",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z2",
				varName = "value",
				posX = 0.6582122,
				posY = 0.9396499,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2892201,
				sizeY = 0.08989987,
				text = "60",
				color = "FF966856",
				fontSize = 22,
				fontOutlineColor = "FF00152E",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jd1",
				posX = 0.5,
				posY = 0.8693672,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6303192,
				sizeY = 0.05724508,
				image = "chu1#jdd",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "LoadingBar",
					name = "dt1",
					varName = "exp_slider",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9451476,
					sizeY = 0.625,
					image = "tong#jdt2",
					scale9Left = 0.3,
					scale9Right = 0.3,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "tsz",
					varName = "exp_value",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9976744,
					sizeY = 1.810698,
					text = "12/666",
					fontOutlineEnable = true,
					fontOutlineColor = "FF567D23",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "ijsy",
				varName = "oneKeyUseBtn",
				posX = 0.5,
				posY = 0.03199816,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.462766,
				sizeY = 0.118068,
				image = "chu1#an2",
				imageNormal = "chu1#an2",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "ijsyz",
					posX = 0.5,
					posY = 0.5454545,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9047835,
					sizeY = 0.876363,
					text = "一键使用",
					fontSize = 24,
					fontOutlineEnable = true,
					fontOutlineColor = "FF2A6953",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "z5",
				varName = "needLevel",
				posX = 0.5,
				posY = 0.7895137,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8633695,
				sizeY = 0.09682327,
				text = "角色5级后可以升阶",
				color = "FF966856",
				fontSize = 22,
				fontOutlineColor = "FF00152E",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Scroll",
				name = "lie",
				varName = "item_scroll",
				posX = 0.5,
				posY = 0.3026115,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9186624,
				sizeY = 0.2196575,
				horizontal = true,
				showScrollBar = false,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "z6",
				varName = "tips",
				posX = 0.5,
				posY = 0.1457629,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8510638,
				sizeY = 0.1431127,
				text = "提示文本",
				color = "FFC93034",
				fontOutlineColor = "FF00152E",
				hTextAlign = 1,
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
