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
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.5101563,
			sizeY = 0.6125,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "jijin",
				varName = "JiJin",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
				alpha = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "hdd",
					posX = 0.5030628,
					posY = 0.8218417,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 1.024502,
					sizeY = 0.3856062,
					image = "lianxujijin#lianxujijin",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "topz3",
						varName = "ActivitiesTitle",
						posX = 0.8516334,
						posY = 0.2412578,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.2877358,
						sizeY = 0.4071879,
						fontSize = 26,
						fontOutlineEnable = true,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "lbk3",
					posX = 0.4999731,
					posY = 0.3197812,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.010666,
					sizeY = 0.6321007,
					image = "b#d5",
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
						name = "lb3",
						varName = "fundGiftList",
						posX = 0.5,
						posY = 0.5022127,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 0.9661876,
						showScrollBar = false,
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "lq",
				varName = "BuyBtn",
				posX = 0.9027207,
				posY = 0.6958989,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1883614,
				sizeY = 0.1315193,
				image = "chu1#an3",
				imageNormal = "chu1#an3",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "lqz",
					varName = "BuyBtnText",
					posX = 0.5,
					posY = 0.5588235,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8247252,
					sizeY = 1.143941,
					text = "投 资",
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
				etype = "RichText",
				name = "bt",
				varName = "BuyContent",
				posX = 0.5714651,
				posY = 0.7587405,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5940036,
				sizeY = 0.1506932,
				text = "投资1000元宝返还5倍绑定元宝",
				color = "FFAC2D1E",
				fontOutlineColor = "FFFFFFFF",
				fontOutlineSize = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "bt2",
				varName = "ActivitiesTime",
				posX = 0.6111133,
				posY = 0.6936311,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6732999,
				sizeY = 0.1088435,
				text = "活动期限：不限时",
				color = "FFAC2D1E",
				fontOutlineColor = "FFFFFFFF",
				fontOutlineSize = 2,
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
