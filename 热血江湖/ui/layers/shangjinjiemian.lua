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
			name = "jd1",
			posX = 0.1755276,
			posY = 0.6261908,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.35,
			sizeY = 0.75,
			layoutType = 7,
			layoutTypeW = 7,
		},
		children = {
		{
			prop = {
				etype = "Grid",
				name = "ss",
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
					etype = "Button",
					name = "zuo",
					varName = "openBtn",
					posX = 0.05579681,
					posY = 0.59021,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.1026786,
					sizeY = 0.08518519,
					image = "zdte#suojin",
					imageNormal = "zdte#suojin",
					flippedX = true,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "you",
					varName = "closeBtn",
					posX = 0.6639724,
					posY = 0.59021,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1026786,
					sizeY = 0.08518519,
					image = "zdte#suojin",
					imageNormal = "zdte#suojin",
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "dyjd",
				varName = "teamRoot",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				layoutType = 7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "gg",
					varName = "leftRoots",
					posX = 0.3089054,
					posY = 0.4622321,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.609676,
					sizeY = 0.3386226,
					image = "b#rwd",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "top",
						posX = 0.4993315,
						posY = 0.9126698,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 1.001084,
						sizeY = 0.1616577,
						image = "bpzd#db",
					},
				},
				{
					prop = {
						etype = "RichText",
						name = "mz",
						varName = "titleName",
						posX = 0.5009423,
						posY = 0.9120522,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9759361,
						sizeY = 0.2500002,
						text = "先灵任务",
						color = "FFD7B886",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "an",
						varName = "taskBtn",
						posX = 0.4993735,
						posY = 0.4149427,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.010483,
						sizeY = 0.8189768,
					},
				},
				{
					prop = {
						etype = "Scroll",
						name = "lb",
						varName = "scroll",
						posX = 0.5070564,
						posY = 0.4309208,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9674386,
						sizeY = 0.7417278,
						showScrollBar = false,
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt",
				varName = "timeTipsBg",
				posX = 1.435963,
				posY = 0.8336978,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8379085,
				sizeY = 0.07210524,
				image = "ts#dw",
			},
			children = {
			{
				prop = {
					etype = "RichText",
					name = "wb",
					varName = "timeTips",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.252232,
					sizeY = -0.7756147,
					text = "本地图将于1111关闭",
					color = "FFD7B886",
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
	chu = {
		dyjd = {
			moveP = {{0, {-0.3, 0.5, 0}}, {300, {0.5, 0.5, 0}}, },
		},
	},
	ru = {
		dyjd = {
			moveP = {{0, {0.5, 0.5, 0}}, {200, {-0.3, 0.5, 0}}, },
		},
	},
	c_chu = {
		{0,"chu", 1, 0},
	},
	c_ru = {
		{0,"ru", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
