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
			layoutType = 5,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.4970857,
				posY = 0.4699568,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4140625,
				sizeY = 0.4722222,
				scale9 = true,
				scale9Left = 0.41,
				scale9Right = 0.37,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "wk",
					posX = 0.5,
					posY = 0.5033069,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.02,
					sizeY = 1.02,
					image = "g#dt2",
					scale9 = true,
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hb2",
					posX = 0.7083296,
					posY = 0.685129,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4172986,
					sizeY = 0.6018519,
					image = "w#w_hua.png",
					alpha = 0.3,
					flippedY = true,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hb",
					posX = 0.2923054,
					posY = 0.685129,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4172986,
					sizeY = 0.6018519,
					image = "w#w_hua.png",
					alpha = 0.3,
					flippedX = true,
					flippedY = true,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dk",
					posX = 0.5,
					posY = 0.6470558,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8679245,
					sizeY = 0.4705882,
					image = "g#g_d9.png",
					scale9 = true,
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "ms1",
						posX = 0.5070219,
						posY = 0.5379701,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9223957,
						sizeY = 0.7799656,
						text = "由于您的宗门大于5级，解散您的宗门需要花费大量时间，请您耐心等待，在等待期间，您无法进入任何宗门。",
						color = "FF89FFDF",
						fontSize = 24,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "top",
					posX = 0.5,
					posY = 1.002576,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7283019,
					sizeY = 0.1794118,
					image = "e#top3",
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "g2",
						posX = 0.5,
						posY = 0.534903,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.4274611,
						sizeY = 0.5081967,
						image = "zm#zm_jsz.png",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a1",
					varName = "cancel_btn",
					posX = 0.776466,
					posY = 0.1457739,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2584906,
					sizeY = 0.1411765,
					image = "w#w_ee4.png",
					imageNormal = "w#w_ee4.png",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "az1",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.005408,
						sizeY = 0.9193038,
						text = "取消解散",
						color = "FFF1FFB0",
						fontSize = 24,
						fontOutlineEnable = true,
						fontOutlineColor = "FF69360B",
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
					name = "tm1",
					varName = "time_label",
					posX = 0.370025,
					posY = 0.325589,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5937495,
					sizeY = 0.1249983,
					text = "剩余时间：68小时",
					fontSize = 26,
					fontOutlineEnable = true,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a2",
					varName = "ok_btn",
					posX = 0.2397381,
					posY = 0.1457739,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2584906,
					sizeY = 0.1411765,
					image = "w#w_qq4.png",
					imageNormal = "w#w_qq4.png",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "az2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9830623,
						sizeY = 1.106485,
						text = "我知道了",
						color = "FFB0FFD9",
						fontSize = 24,
						fontOutlineEnable = true,
						fontOutlineColor = "FF145A4F",
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
	dk = {
		ysjm = {
			scale = {{0, {0.3, 0.3, 1}}, {150, {1.1, 1.1, 1}}, {200, {1,1,1}}, },
		},
	},
	c_dakai = {
		{0,"dk", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
