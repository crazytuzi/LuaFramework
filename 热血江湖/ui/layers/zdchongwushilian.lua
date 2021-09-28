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
			name = "renwu",
			varName = "taskRoot",
			posX = 0.5,
			posY = 0.75,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 0.5,
			layoutType = 7,
			layoutTypeW = 7,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "smd",
				posX = 0.1104053,
				posY = 0.1983934,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2101562,
				sizeY = 0.6055555,
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Scroll",
					name = "lb",
					varName = "taskscoll",
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
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "yx",
			posX = 0.5,
			posY = 0.25,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 0.5,
			layoutType = 3,
			layoutTypeW = 3,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "gh",
				varName = "changeEquip",
				posX = 0.6763442,
				posY = 0.1533488,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0625,
				sizeY = 0.2222222,
				image = "zdte2#zhuangbeigenghuan",
				imageNormal = "zdte2#zhuangbeigenghuan",
				disablePressScale = true,
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "ys",
			posX = 0.5,
			posY = 0.75,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 0.5,
			layoutType = 9,
			layoutTypeW = 9,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "gh2",
				varName = "reward",
				posX = 0.9618475,
				posY = 0.608151,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0625,
				sizeY = 0.2222222,
				image = "zdte2#shouyi",
				imageNormal = "zdte2#shouyi",
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gh3",
				varName = "event",
				posX = 0.8991854,
				posY = 0.6081511,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0625,
				sizeY = 0.2222222,
				image = "zdte2#xingyunshijian",
				imageNormal = "zdte2#xingyunshijian",
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gh4",
				varName = "gatherBt",
				posX = 0.8365232,
				posY = 0.6081511,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0625,
				sizeY = 0.2222222,
				image = "zdte2#caiji",
				imageNormal = "zdte2#caiji",
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "slz2",
					varName = "gatherNum",
					posX = 0.5,
					posY = -0.1412269,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.271687,
					sizeY = 1.300557,
					text = "0/5",
					fontOutlineEnable = true,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gh5",
				varName = "taskBt",
				posX = 0.7738611,
				posY = 0.6081511,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0625,
				sizeY = 0.2222222,
				image = "zdte2#renwu",
				imageNormal = "zdte2#renwu",
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "slz1",
					varName = "tasknum",
					posX = 0.5,
					posY = -0.1412269,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.271687,
					sizeY = 1.300557,
					text = "0/5",
					fontOutlineEnable = true,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		},
	},
	{
		prop = {
			etype = "Button",
			name = "btn",
			varName = "tip",
			posX = 0.7738611,
			posY = 0.9285651,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.0625,
			sizeY = 0.1111111,
			image = "guidaoyuling1#shuoming",
			imageNormal = "guidaoyuling1#shuoming",
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
	gy6 = {
	},
	gy7 = {
	},
	c_dakai = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
