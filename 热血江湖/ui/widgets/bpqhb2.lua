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
			name = "ysjm",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.1726563,
			sizeY = 0.3831854,
			hTextAlign = 1,
			vTextAlign = 1,
			layoutType = 5,
			layoutTypeW = 5,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "db",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.9387097,
				sizeY = 0.9999999,
				image = "bphb#hongbaodakai1",
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
					name = "by",
					varName = "name",
					posX = 0.5,
					posY = 0.8192158,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.1625233,
					text = "发红包的大咖",
					color = "FF9A2511",
					fontSize = 18,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sz",
					posX = 0.5,
					posY = 0.529652,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.598471,
					sizeY = 0.1008456,
					text = "元宝",
					color = "FF9A2511",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "qd",
					posX = 0.5,
					posY = 0.9066796,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.1145982,
					text = "抢到",
					color = "FFC93034",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl",
					varName = "diamond",
					posX = 0.6131182,
					posY = 0.6917886,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4090535,
					sizeY = 0.1464261,
					text = "360",
					color = "FFFBEB33",
					fontSize = 24,
					fontOutlineEnable = true,
					fontOutlineColor = "FFB9512A",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "yb",
					posX = 0.3219912,
					posY = 0.6917887,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2410162,
					sizeY = 0.1812294,
					image = "uieffect/01.png",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "suo",
						posX = 0.6724205,
						posY = 0.3588972,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.421875,
						sizeY = 0.421875,
						image = "tb#tb_suo.png",
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "okBtn",
				posX = 0.5030965,
				posY = 0.182814,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.483871,
				sizeY = 0.1470195,
				image = "chu1#an1",
				imageNormal = "chu1#an1",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "w",
					posX = 0.494268,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					text = "确认",
					fontOutlineEnable = true,
					fontOutlineColor = "FFB35F1D",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
					autoWrap = false,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an1",
				posX = 0.5030965,
				posY = 0.3939561,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.483871,
				sizeY = 0.1470195,
				image = "chu1#an2",
				imageNormal = "chu1#an2",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "w1",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					text = "详情",
					fontOutlineEnable = true,
					fontOutlineColor = "FF347468",
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
