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
			name = "jd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.3061952,
			sizeY = 0.1249996,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "lbt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "b#lbt",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.6,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "mc1",
					varName = "npcFunction",
					posX = 0.5815365,
					posY = 0.6888899,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6165189,
					sizeY = 0.8127602,
					text = "<名字我写起哥字>",
					color = "FF966856",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mc2",
					varName = "npcName",
					posX = 0.5412893,
					posY = 0.3111098,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5360245,
					sizeY = 0.8127602,
					text = "NPC功能",
					color = "FF65944D",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn",
					varName = "open_btn",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					disablePressScale = true,
					propagateToChildren = true,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "hd",
						varName = "redPoint",
						posX = 0.9598034,
						posY = 0.823266,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.06888988,
						sizeY = 0.3111121,
						image = "zdte#hd",
					},
				},
				{
					prop = {
						etype = "Button",
						name = "btns",
						posX = 0.8769977,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1148165,
						sizeY = 0.3444456,
						image = "wh#jt",
						imageNormal = "wh#jt",
						disablePressScale = true,
						disableClick = true,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "txk",
					varName = "tx_icon",
					posX = 0.1255107,
					posX = 0.1561287,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.165846,
					sizeY = 0.7222245,
					image = "zdte#bossd",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "txt",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9538462,
						sizeY = 0.9538463,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "txw",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.030769,
						sizeY = 1.030769,
						image = "zdte#bossk",
					},
				},
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
