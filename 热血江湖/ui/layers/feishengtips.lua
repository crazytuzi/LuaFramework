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
			sizeX = 0.88,
			sizeY = 0.98,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.5079902,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5193537,
				sizeY = 0.5031179,
				image = "fsbj2#fsbj2",
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.25,
				scale9Bottom = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tipsd",
					posX = 0.5,
					posY = 0.3115753,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5230769,
					sizeY = 0.1098591,
					image = "feisheng#tips",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "kk",
					posX = 0.4846153,
					posY = 0.5939239,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.890251,
					sizeY = 0.4367502,
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
				children = {
				{
					prop = {
						etype = "RichText",
						name = "z1",
						varName = "desc",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.861172,
						sizeY = 0.8178486,
						text = "描述文字",
						color = "FFFFEED7",
						fontOutlineColor = "FF27221D",
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
					varName = "findwayBtn",
					posX = 0.4846154,
					posY = 0.1362365,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2703961,
					sizeY = 0.1690141,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "f2",
						varName = "findText",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8313926,
						sizeY = 0.9422306,
						text = "解 锁",
						fontSize = 22,
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
					name = "chu",
					varName = "name",
					posX = 0.4846154,
					posY = 0.8590668,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2410256,
					sizeY = 0.1661972,
					image = "feisheng#zhoudengshanz",
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "closeBtn",
					posX = 0.9396244,
					posY = 0.8611623,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.07692308,
					sizeY = 0.1267606,
					image = "feisheng#gb",
					imageNormal = "feisheng#gb",
					disablePressScale = true,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "ts",
					varName = "stateText",
					posX = 0.4846153,
					posY = 0.3079065,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8144488,
					sizeY = 0.25,
					text = "状态文字",
					color = "FFFF8392",
					fontOutlineEnable = true,
					fontOutlineColor = "FFBB342D",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "ts2",
					varName = "finishText",
					posX = 0.4846153,
					posY = 0.1414324,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8144488,
					sizeY = 0.25,
					text = "状态文字",
					color = "FFFFEED7",
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
