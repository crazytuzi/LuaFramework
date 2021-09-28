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
				sizeX = 0.5551895,
				sizeY = 0.5195621,
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
					posY = 0.6169837,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8985136,
					sizeY = 0.604332,
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
						etype = "Scroll",
						name = "lb",
						varName = "itemScoll",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9779505,
						sizeY = 0.9553229,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hua",
					posX = 0.6165395,
					posY = 0.3936545,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7963343,
					sizeY = 0.7555856,
					image = "hua1#hua1",
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "z1",
					varName = "desc",
					posX = 0.5000002,
					posY = 0.2507842,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8238425,
					sizeY = 0.2968358,
					text = "挂载家俱操作说明加壹句写在这里",
					color = "FF966856",
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
					posY = 0.1079181,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2529431,
					sizeY = 0.1636648,
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
						posY = 0.5468748,
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
					varName = "ok",
					posX = 0.7540076,
					posY = 0.1079181,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2529431,
					sizeY = 0.1636648,
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
						posY = 0.546875,
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
					name = "top",
					posX = 0.5,
					posY = 0.9983841,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4221531,
					sizeY = 0.1418428,
					image = "chu1#top",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "topz",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5151516,
						sizeY = 0.4807692,
						image = "biaoti#jiayuanbaijian",
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
