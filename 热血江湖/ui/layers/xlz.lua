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
			name = "xunlu",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			layoutType = 5,
			layoutTypeW = 5,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "xun",
				posX = 0.4048276,
				posY = 0.4514702,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05,
				sizeY = 0.08888889,
				image = "uieffect/xun.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "lu",
				posX = 0.441545,
				posY = 0.4500813,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05,
				sizeY = 0.08888889,
				image = "uieffect/lu.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zhong",
				posX = 0.4766999,
				posY = 0.4514702,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05,
				sizeY = 0.08888889,
				image = "uieffect/zhong.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dd",
				posX = 0.4968911,
				posY = 0.4320436,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.025,
				sizeY = 0.04444445,
				image = "uieffect/dd.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dd2",
				posX = 0.5140789,
				posY = 0.4320436,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.025,
				sizeY = 0.04444445,
				image = "uieffect/dd.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dd3",
				posX = 0.5312669,
				posY = 0.4320436,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.025,
				sizeY = 0.04444445,
				image = "uieffect/dd.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "d9",
				varName = "DigingPanel",
				posX = 0.5,
				posY = 0.3513877,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5066907,
				sizeY = 0.1194444,
				layoutType = 2,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "tsz",
					varName = "Digtipstext",
					posX = 0.4653638,
					posY = 0.5137026,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.3001705,
					sizeY = 0.764343,
					text = "寻路中......",
					color = "FFFFFF00",
					fontSize = 24,
					fontOutlineEnable = true,
					fontOutlineColor = "FF51361C",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gbn",
					varName = "flybtn",
					posX = 0.6999472,
					posY = 1.340639,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1911916,
					sizeY = 0.6744189,
					image = "chu1#sn1",
					imageNormal = "chu1#sn1",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "qx",
						posX = 0.5,
						posY = 0.5172414,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9077845,
						sizeY = 1.115898,
						text = "传 送",
						color = "FFFFF2E1",
						fontSize = 24,
						fontOutlineEnable = true,
						fontOutlineColor = "FF8F4E1B",
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
	},
	},
}
--EDITOR elements end tag
--EDITOR animations start tag
local l_animations =
{
	gy = {
	},
	xun = {
		xun = {
			scale = {{0, {0, 1, 1}}, {200, {1.1, 1, 1}}, {250, {1,1,1}}, },
			alpha = {{0, {1}}, {2000, {1}}, {2500, {0}}, {2600, {0}}, },
		},
	},
	lu = {
		lu = {
			scale = {{0, {0, 1, 1}}, {200, {1.1, 1, 1}}, {250, {1,1,1}}, },
			alpha = {{0, {1}}, {1900, {1}}, {2400, {0}}, {2600, {0}}, },
		},
	},
	zhong = {
		zhong = {
			scale = {{0, {0, 1, 1}}, {200, {1.1, 1, 1}}, {250, {1,1,1}}, },
			alpha = {{0, {1}}, {1800, {1}}, {2300, {0}}, {2600, {0}}, },
		},
	},
	dd1 = {
		dd = {
			alpha = {{0, {1}}, {1700, {1}}, {2200, {0}}, {2600, {0}}, },
		},
	},
	dd2 = {
		dd2 = {
			alpha = {{0, {1}}, {1600, {1}}, {2100, {0}}, {2600, {0}}, },
		},
	},
	dd3 = {
		dd3 = {
			alpha = {{0, {1}}, {1500, {1}}, {2000, {0}}, {2600, {0}}, },
		},
	},
	c_xunluzhong = {
		{0,"xun", -1, 0},
		{0,"lu", -1, 100},
		{0,"zhong", -1, 200},
		{0,"dd1", -1, 300},
		{0,"dd2", -1, 400},
		{0,"dd3", -1, 500},
	},
	c_dakai = {
		{0,"xun", -1, 0},
		{0,"lu", -1, 100},
		{0,"zhong", -1, 200},
		{0,"dd1", -1, 300},
		{0,"dd2", -1, 400},
		{0,"dd3", -1, 500},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
