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
			name = "zdt",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.5358379,
			sizeY = 0.13,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt2",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.9722222,
				scale9Left = 0.2,
				scale9Right = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "diban",
					varName = "background",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					image = "ptbj#tmk",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mz",
					varName = "name_label",
					posX = 0.4375072,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2800736,
					sizeY = 0.6043956,
					text = "我是一个大棒槌",
					color = "FF966856",
					fontSize = 22,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "dj2",
					varName = "power_label",
					posX = 0.8720466,
					posY = 0.5000001,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2987297,
					sizeY = 0.6043956,
					text = "1000",
					color = "FFC93034",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "txd",
					varName = "txb_img",
					posX = 0.2301559,
					posY = 0.4340803,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.154387,
					sizeY = 0.9340659,
					image = "zdtx#txd",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "tx",
						varName = "icon",
						posX = 0.5054789,
						posY = 0.6925332,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.7210885,
						sizeY = 1.110169,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "dj",
					varName = "level_label",
					posX = 0.6679029,
					posY = 0.4999999,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1814135,
					sizeY = 0.6043956,
					text = "Lv.55",
					color = "FF966856",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "d1",
					varName = "best_three",
					posX = 0.07810365,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.05686188,
					sizeY = 0.2967033,
					image = "dati#1st",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "dj3",
					varName = "fourth",
					posX = 0.07810367,
					posY = 0.4993541,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1814135,
					sizeY = 0.4839197,
					text = "4.",
					color = "FF966856",
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
