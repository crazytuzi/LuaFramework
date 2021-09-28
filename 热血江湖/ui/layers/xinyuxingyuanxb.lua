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
			sizeX = 0.88,
			sizeY = 0.98,
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
				sizeX = 0.4412287,
				sizeY = 0.4407596,
				image = "xyxybj2#xyxybj2",
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.25,
				scale9Bottom = 0.7,
			},
			children = {
			{
				prop = {
					etype = "RichText",
					name = "z1",
					varName = "desc",
					posX = 0.5000002,
					posY = 0.7928753,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8238425,
					sizeY = 0.2060365,
					text = "请选择您的真实性别",
					color = "FF2A6A76",
					fontOutlineColor = "FF27221D",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a1",
					varName = "cancel",
					posX = 0.2505727,
					posY = 0.1923863,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3182734,
					sizeY = 0.192926,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "f1",
						varName = "no_name",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8313926,
						sizeY = 0.9422305,
						text = "取 消",
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
					etype = "Button",
					name = "a2",
					varName = "sure",
					posX = 0.7540076,
					posY = 0.1923863,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3182734,
					sizeY = 0.192926,
					image = "chu1#an1",
					imageNormal = "chu1#an1",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "f2",
						varName = "yes_name",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8313926,
						sizeY = 0.9422306,
						text = "确 定",
						fontSize = 24,
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
					etype = "Image",
					name = "nan",
					posX = 0.25,
					posY = 0.5501533,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.193159,
					sizeY = 0.3601286,
					image = "xyxy#nan",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "nan2",
					posX = 0.75,
					posY = 0.5501533,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.193159,
					sizeY = 0.3601286,
					image = "xyxy#nv",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn1",
					varName = "male_btn",
					posX = 0.25,
					posY = 0.5545133,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3103973,
					sizeY = 0.4524684,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn2",
					varName = "female_btn",
					posX = 0.75,
					posY = 0.5545133,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3103973,
					sizeY = 0.4524684,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xz1",
					varName = "male_frame",
					posX = 0.25,
					posY = 0.5438226,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					lockHV = true,
					sizeX = 0.3232265,
					sizeY = 0.5165387,
					image = "xyxy#xzk",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xz2",
					varName = "female_frame",
					posX = 0.75,
					posY = 0.5438226,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.3232265,
					sizeY = 0.5165387,
					image = "xyxy#xzk",
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
