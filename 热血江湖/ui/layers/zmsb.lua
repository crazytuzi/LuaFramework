--version = 1
local l_fileType = "layer"

local UIUtil = require "ui/common/UIUtil"

--EDITOR elements start tag
local eleRoot = 
{
	prop = {
		etype = "Layer",
		name = "root",
		varName = "Bonuspanel",
		posX = 0,
		posY = 0,
		anchorX = 0,
		anchorY = 0,
		soundEffectOpen = "audio/rxjh/UI/ui_lose.ogg",
	},
	children = {
	{
		prop = {
			etype = "Image",
			name = "ddd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			image = "b#dd",
			scale9 = true,
			scale9Left = 0.2,
			scale9Right = 0.2,
			scale9Top = 0.2,
			scale9Bottom = 0.2,
			alpha = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dd",
				varName = "close_btn",
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
	{
		prop = {
			etype = "Grid",
			name = "ysjm",
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
				etype = "Grid",
				name = "kk2",
				posX = 0.5,
				posY = 0.466735,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.5160202,
				alphaCascade = true,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "ddw",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 0.6,
					image = "b#dd",
					scale9 = true,
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
					alpha = 0.49,
					alphaCascade = true,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "ld",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5607088,
						sizeY = 0.2756674,
						image = "d#sld4",
						alpha = 0.5,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "tsz",
						varName = "desc_label",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8588975,
						sizeY = 0.7539785,
						text = "很遗憾，你未能抢到任何资源",
						color = "FF2C9EFF",
						fontSize = 24,
						fontOutlineEnable = true,
						fontOutlineColor = "FF102E21",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "bp",
					posX = 0.2340531,
					posY = 0.5698667,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1664063,
					sizeY = 0.6055965,
					image = "bq#guixia",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.4829454,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.9742247,
				alpha = 0.5,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "top",
					posX = 0.5,
					posY = 0.6501536,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4476562,
					sizeY = 0.1967376,
					image = "js#js_zdsb.png",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tit11",
				varName = "coolTimeLabel",
				posX = 0.4291623,
				posY = 0.2381047,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.04016649,
				sizeY = 0.08113909,
				text = "120",
				color = "FFC872FF",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tit12",
				posX = 0.5,
				posY = 0.2853272,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2112233,
				sizeY = 0.08113909,
				text = "点击空白区域退出",
				color = "FF459F86",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tit13",
				posX = 0.5531721,
				posY = 0.2394936,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2112233,
				sizeY = 0.08113909,
				text = "秒后强制传出副本",
				color = "FF91FFD2",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zs2",
				posX = 0.6263472,
				posY = 0.2853883,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0890625,
				sizeY = 0.0125,
				image = "w#w_zhuangshixian.png",
				flippedX = true,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zs1",
				posX = 0.3791042,
				posY = 0.2853883,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0890625,
				sizeY = 0.0125,
				image = "w#w_zhuangshixian.png",
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
	sl = {
		kk2 = {
			alpha = {{0, {0}}, {300, {1}}, },
		},
		top = {
			alpha = {{0, {0}}, {300, {1}}, },
		},
	},
	zi = {
		tit11 = {
			alpha = {{0, {0}}, {300, {1}}, },
		},
		tit12 = {
			alpha = {{0, {0}}, {300, {1}}, },
		},
		tit13 = {
			alpha = {{0, {0}}, {300, {1}}, },
		},
		zs1 = {
			alpha = {{0, {0}}, {300, {0.7}}, },
		},
		zs2 = {
			alpha = {{0, {0}}, {300, {0.7}}, },
		},
	},
	c_dakai = {
		{0,"sl", 1, 100},
		{0,"zi", 1, 100},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
