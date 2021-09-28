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
				varName = "imgBK",
				posX = 0.5015603,
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
				sizeX = 0.5058419,
				sizeY = 0.4366162,
				image = "b#cs",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.25,
				scale9Bottom = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "kk",
					posX = 0.5,
					posY = 0.6053451,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9216833,
					sizeY = 0.6781677,
					image = "b#d2",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "tst",
						posX = 0.2981849,
						posY = 0.5044988,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5781128,
						sizeY = 0.9240527,
						image = "dw#tst",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hua",
					posX = 0.6595274,
					posY = 0.4579085,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7691385,
					sizeY = 0.8811451,
					image = "hua1#hua1",
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "z1",
					varName = "desc",
					posX = 0.778704,
					posY = 0.6555505,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3661565,
					sizeY = 0.5208212,
					text = "等待其他玩家加入您的临时队伍，此时可以做主线任务，刷怪升级，活动下筋骨，在图中位置可以随时查看进度。",
					color = "FF966856",
					fontOutlineColor = "FF27221D",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a2",
					varName = "ok",
					posX = 0.5,
					posY = 0.1306369,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2687351,
					sizeY = 0.2099479,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "f2",
						varName = "btnName",
						posX = 0.5,
						posY = 0.5454545,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8313926,
						sizeY = 0.9422306,
						text = "我知道了",
						fontSize = 24,
						fontOutlineEnable = true,
						fontOutlineColor = "FF2A6953",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "andt",
					posX = 0.6801717,
					posY = 0.3592573,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.06522343,
					sizeY = 0.1343371,
					image = "sz#xzd",
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "xzan",
						varName = "bzts_btn",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.567579,
						sizeY = 1.376678,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xztp",
						varName = "bzts_img",
						posX = 0.5,
						posY = 0.5263543,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						lockHV = true,
						sizeX = 0.7906272,
						sizeY = 0.7906272,
						image = "sz#xzt",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "bzts",
						posX = 3.441571,
						posY = 0.5236794,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 4.194022,
						sizeY = 1.30036,
						text = "不再提示",
						color = "FFC93034",
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
