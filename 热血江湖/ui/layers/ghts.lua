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
			etype = "Image",
			name = "ddd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			image = "b#dd",
			scale9 = true,
			scale9Left = 0.2,
			scale9Right = 0.2,
			scale9Top = 0.2,
			scale9Bottom = 0.2,
			alpha = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dd",
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
			etype = "Grid",
			name = "k",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.8,
			sizeY = 0.8,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.6,
				sizeY = 0.7,
				image = "dt.png",
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
					name = "wz1",
					posX = 0.4629313,
					posY = 0.8943688,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7793541,
					sizeY = 0.1547141,
					text = "您将更换哀木涕为当前使用角色",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wz2",
					posX = 0.4613036,
					posY = 0.5186474,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7793542,
					sizeY = 0.185384,
					text = "更换角色后，当前坐骑不可使用，请选择更换一个坐骑。",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "qh",
					posX = 0.4992847,
					posY = 0.1159644,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2776656,
					sizeY = 0.1530364,
					image = "sz#as4.png",
					imageNormal = "sz#as4.png",
					imagePressed = "sz#as2.png",
					imageDisable = "sz#as4.png",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wz4",
						posX = 0.5055541,
						posY = 0.5577834,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6807113,
						sizeY = 0.545788,
						text = "确定",
						fontSize = 26,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "txk",
					posX = 0.2026359,
					posY = 0.7303358,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1592423,
					sizeY = 0.2426551,
					image = "q#touxiangdi.png",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "tx",
						posX = 0.5,
						posY = 0.5102209,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.7755116,
						sizeY = 0.7677556,
						image = "tx#aimuti.png",
					},
				},
				},
			},
			{
				prop = {
					etype = "List",
					name = "lb",
					posX = 0.4975616,
					posY = 0.321721,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7588435,
					sizeY = 0.2129432,
					horizontal = true,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				posX = 0.7934642,
				posY = 0.8171883,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05566406,
				sizeY = 0.1006944,
				image = "sz#gb.png",
				imageNormal = "sz#gb.png",
				imagePressed = "sz#gb2.png",
				imageDisable = "sz#gb.png",
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
