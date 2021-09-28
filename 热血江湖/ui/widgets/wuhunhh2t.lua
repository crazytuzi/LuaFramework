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
			name = "k1",
			varName = "itemRoot",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.09671412,
			sizeY = 0.2192937,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "selectBtn",
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
				etype = "Image",
				name = "bpsdt",
				varName = "root",
				posX = 0.5007961,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.945118,
				sizeY = 0.9120189,
				image = "bg2#szd",
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dj",
					varName = "iconBg",
					posX = 0.5,
					posY = 0.6309454,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.6837607,
					sizeY = 0.5555556,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "djt",
						varName = "icon",
						posX = 0.5,
						posY = 0.5416668,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8,
						sizeY = 0.8,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "yzb",
					varName = "equipingIcon",
					posX = 0.3549272,
					posY = 0.8050129,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.6752136,
					sizeY = 0.4027778,
					image = "bg2#yzb",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz",
				varName = "name",
				posX = 0.4758002,
				posY = 0.3009668,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.412174,
				sizeY = 0.2468876,
				text = "名字最长七个字",
				color = "FF404040",
				fontSize = 18,
				fontOutlineColor = "FF614A31",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "hd",
				varName = "redPoint",
				posX = 0.8790873,
				posY = 0.8857114,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2181042,
				sizeY = 0.177337,
				image = "zdte#hd",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz3",
				varName = "desc",
				posX = 0.4758002,
				posY = 0.1664071,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.412174,
				sizeY = 0.25,
				text = "八阶解锁",
				color = "FFC93034",
				fontSize = 18,
				fontOutlineColor = "FF614A31",
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
