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
			sizeX = 0.6,
			sizeY = 0.6,
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
				sizeX = 0.75,
				sizeY = 0.8,
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
					varName = "background",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.131944,
					sizeY = 1.241319,
					image = "ptbj3#ptbj3",
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.2,
					scale9Bottom = 0.7,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dk",
						varName = "scrollIcon",
						posX = 0.5045923,
						posY = 0.5744691,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7043651,
						sizeY = 0.5399029,
						image = "ptbj#dk",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
						scale9Top = 0.4,
						scale9Bottom = 0.4,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "kk",
					posX = 0.5,
					posY = 0.5621288,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8644516,
					sizeY = 0.6211269,
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
				children = {
				{
					prop = {
						etype = "EditBox",
						name = "srk",
						sizeXAB = 400.3497,
						sizeYAB = 172.7134,
						posXAB = 250.962,
						posYAB = 117.3307,
						varName = "input_label",
						posX = 0.5040166,
						posY = 0.546585,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8040375,
						sizeY = 0.8045851,
						color = "FF966856",
						fontSize = 26,
						phColor = "FF966856",
						phFontSize = 26,
					},
				},
				{
					prop = {
						etype = "RichText",
						name = "wbz",
						varName = "label",
						posX = 0.5040166,
						posY = 0.5465851,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8040376,
						sizeY = 0.8045851,
						text = "在此输入您想设置的爱好，最多可输入4个字",
						color = "FF966856",
						fontSize = 22,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a2",
					varName = "sure_btn",
					posX = 0.7,
					posY = 0.1925693,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.233747,
					sizeY = 0.162037,
					image = "ptbj#zs",
					imageNormal = "ptbj#zs",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "f2",
						varName = "sureText",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.048375,
						sizeY = 1.203417,
						text = "确 定",
						color = "FF914A15",
						fontSize = 24,
						fontOutlineEnable = true,
						fontOutlineColor = "FFFEE07C",
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
					name = "a3",
					varName = "close_btn",
					posX = 0.3,
					posY = 0.1925693,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.233747,
					sizeY = 0.162037,
					image = "ptbj#zs",
					imageNormal = "ptbj#zs",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wz2",
						varName = "cancelText",
						posX = 0.5,
						posY = 0.5000002,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.048375,
						sizeY = 1.203417,
						text = "取 消",
						color = "FF914A15",
						fontSize = 24,
						fontOutlineEnable = true,
						fontOutlineColor = "FFFEE07C",
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
