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
			layoutType = 3,
			layoutTypeW = 3,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				varName = "findRoot",
				posX = 0.4150329,
				posY = 0.4124366,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2710938,
				sizeY = 0.3888889,
				image = "fsbj3#fsbj3",
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "an1",
					varName = "enter_btn",
					posX = 0.5,
					posY = 0.2476652,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.4558553,
					sizeY = 0.3061225,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "as1",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.069936,
						sizeY = 1.023591,
						text = "进 入",
						fontSize = 24,
						fontOutlineEnable = true,
						fontOutlineColor = "FF347468",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "bc",
					varName = "name",
					posX = 0.5,
					posY = 0.8208299,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8396317,
					sizeY = 0.4242095,
					text = "xxxx",
					color = "FFFDE498",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FF603E39",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "bfb",
					varName = "desc",
					posX = 0.5,
					posY = 0.5345438,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9337665,
					sizeY = 0.4646717,
					text = "发现灵虚，进去吸附灵气吧",
					fontOutlineEnable = true,
					fontOutlineColor = "FF533040",
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
