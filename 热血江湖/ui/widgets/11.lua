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
			name = "z2",
			posX = 0.7137104,
			posY = 0.4590964,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.4274222,
			sizeY = 0.8333525,
			scale9 = true,
			scale9Left = 0.41,
			scale9Right = 0.37,
			scale9Top = 0.3,
			scale9Bottom = 0.3,
			alpha = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt1",
				posX = 0.4670997,
				posY = 0.4966401,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9047699,
				sizeY = 0.7537235,
				image = "b#d5",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Scroll",
					name = "bglb",
					varName = "scroll",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.99,
					sizeY = 0.99,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zsz",
					posX = 0.4970342,
					posY = 0.02202809,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9983582,
					sizeY = 0.04260502,
					scale9 = true,
					scale9Left = 0.3,
					scale9Right = 0.3,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wwp",
					varName = "noItemTips",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.6,
					sizeY = 0.25,
					text = "背包里没有此类物品",
					color = "FF966856",
					fontSize = 22,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "yjzb",
				varName = "yjzb_btn",
				posX = 0.1552702,
				posY = 0.05478044,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2891275,
				sizeY = 0.0999977,
				image = "chu1#an1",
				imageNormal = "chu1#an1",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "ys2",
					posX = 0.5,
					posY = 0.5454545,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9120977,
					sizeY = 1.156784,
					text = "一键装备",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FFB35F1D",
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
				name = "plcs",
				varName = "sale_bat",
				posX = 0.7861125,
				posY = 0.05478043,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.2891275,
				sizeY = 0.0999977,
				image = "chu1#an2",
				imageNormal = "chu1#an2",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "ys3",
					posX = 0.5,
					posY = 0.5454545,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9120977,
					sizeY = 1.156784,
					text = "批量出售",
					fontSize = 22,
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
				etype = "Button",
				name = "plcs2",
				varName = "yjhb_btn",
				posX = 0.4706913,
				posY = 0.05478043,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.2891275,
				sizeY = 0.0999977,
				image = "chu1#an2",
				imageNormal = "chu1#an2",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "ys4",
					posX = 0.5,
					posY = 0.5454545,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9120977,
					sizeY = 1.156784,
					text = "一键合并",
					fontSize = 22,
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
