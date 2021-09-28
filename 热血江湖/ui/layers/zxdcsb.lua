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
				varName = "closeBtn",
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
							alpha = 0.25,
							alphaCascade = true,
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
				{
					prop = {
						etype = "Image",
						name = "exp",
						posX = 0.3853452,
						posY = 0.4800671,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.0390625,
						sizeY = 0.07128175,
						image = "ty#exp",
						alphaCascade = true,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "sl1",
							varName = "expLabel",
							posX = 2.426203,
							posY = 0.4999997,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 2.456431,
							sizeY = 0.8178803,
							text = "+665",
							fontSize = 24,
							fontOutlineEnable = true,
							fontOutlineColor = "FF102E21",
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sl2",
						varName = "interalLabel",
						posX = 0.632496,
						posY = 0.480067,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2041563,
						sizeY = 0.05829994,
						text = "积分+0",
						fontSize = 24,
						fontOutlineEnable = true,
						fontOutlineColor = "FF102E21",
						vTextAlign = 1,
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
					image = "tong#zsx2",
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
					image = "tong#zsx2",
					flippedX = true,
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
	sl = {
		kk2 = {
			alpha = {{0, {0}}, {300, {1}}, },
		},
		top = {
			alpha = {{0, {0}}, {300, {1}}, },
		},
		exp = {
			alpha = {{0, {0}}, {300, {1}}, },
		},
		sl2 = {
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
		{0,"sl", 1, 0},
		{2,"lizi", 1, 0},
		{0,"zi", 1, 100},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
