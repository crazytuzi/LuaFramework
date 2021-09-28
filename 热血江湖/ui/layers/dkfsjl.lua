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
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7929688,
				sizeY = 0.8055556,
				image = "g#dt2.png",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "hb1",
					posX = 0.3200115,
					posY = 0.6979553,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3599968,
					sizeY = 0.5732948,
					image = "w#w_hua.png",
					alpha = 0.3,
					flippedX = true,
					flippedY = true,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hb2",
					posX = 0.6799963,
					posY = 0.6979553,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3599968,
					sizeY = 0.5732948,
					image = "w#w_hua.png",
					alpha = 0.3,
					flippedY = true,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "pg",
					posX = 0.5,
					posY = 0.9561764,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9033602,
					sizeY = 0.065235,
					image = "w#cdd",
					flippedY = true,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "db1",
					posX = 0.5,
					posY = 0.5180728,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9458128,
					sizeY = 0.7935228,
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
						etype = "Scroll",
						name = "lb",
						varName = "itemScroll",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9856524,
						sizeY = 0.9721964,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "y1",
					posX = 0.03167748,
					posY = 0.961136,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1339901,
					sizeY = 0.1706897,
					image = "w#w_yun.png",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "y2",
					posX = 0.9692256,
					posY = 0.02142051,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1339901,
					sizeY = 0.1706897,
					image = "w#w_yun.png",
					flippedX = true,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an",
					varName = "getAward_btn",
					posX = 0.5,
					posY = 0.06896106,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1349754,
					sizeY = 0.08275862,
					image = "w#qq4",
					imageNormal = "w#qq4",
					imagePressed = "w#qq2",
					imageDisable = "w#qq1",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "anz",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8684064,
						sizeY = 0.8651869,
						text = "领取补偿",
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
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "close_btn",
					posX = 0.9817872,
					posY = 0.9699091,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.07684729,
					sizeY = 0.1362069,
					image = "chu1#gb",
					imageNormal = "chu1#gb",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "top",
				posX = 0.5,
				posY = 0.8960159,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3796875,
				sizeY = 0.08472222,
				image = "e#top2",
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.2,
				scale9Bottom = 0.2,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "td2",
					posX = 0.5009738,
					posY = 0.5370265,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1625514,
					sizeY = 0.4754098,
					image = "jjc#jjc_zb.png",
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
			scale = {{0, {0, 0, 1}}, {150, {1.05, 1.05, 1}}, {200, {1,1,1}}, },
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
