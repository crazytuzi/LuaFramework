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
			etype = "Button",
			name = "bb",
			varName = "close_btn",
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
			name = "xys",
			posX = 0.5,
			posY = 0.35,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 0.7,
			layoutType = 2,
			layoutTypeW = 2,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "db",
				posX = 0.6973488,
				posY = 0.4963688,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.34375,
				sizeY = 0.4761905,
				image = "b#qhd",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "fy1",
					varName = "top_btn1",
					posX = 0.1730054,
					posY = 1.096598,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3226139,
					sizeY = 0.2125,
					image = "zd#qh1",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					imageNormal = "zd#qh1",
					imagePressed = "zd#qh2",
					imageDisable = "zd#qh1",
					disablePressScale = true,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wz1",
						varName = "btn1_txt",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.098671,
						sizeY = 0.8689175,
						text = "技能切换",
						color = "FF91673B",
						fontSize = 24,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "fy2",
					varName = "top_btn2",
					posX = 0.4974709,
					posY = 1.096598,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3226139,
					sizeY = 0.2125,
					image = "zd#qh1",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					imageNormal = "zd#qh1",
					imagePressed = "zd#qh2",
					imageDisable = "zd#qh1",
					disablePressScale = true,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wz2",
						varName = "btn2_txt",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.098671,
						sizeY = 0.8689175,
						text = "技能切换",
						color = "FF91673B",
						fontSize = 24,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "fy3",
					varName = "top_btn3",
					posX = 0.8219365,
					posY = 1.096598,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3226139,
					sizeY = 0.2125,
					image = "zd#qh1",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					imageNormal = "zd#qh1",
					imagePressed = "zd#qh2",
					imageDisable = "zd#qh1",
					disablePressScale = true,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wz3",
						varName = "btn3_txt",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.098671,
						sizeY = 0.8689175,
						text = "技能切换",
						color = "FF91673B",
						fontSize = 24,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb",
					varName = "scr_list",
					posX = 0.5,
					posY = 0.5633093,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9782732,
					sizeY = 0.8253793,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "tsz",
					varName = "desc_txt",
					posX = 0.5,
					posY = 0.0848138,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.25,
					text = "点击更换技能",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zs1",
					posX = -0.02045455,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.04545455,
					sizeY = 0.225,
					image = "zd#zs3",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zs2",
					posX = 1.020457,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.04545455,
					sizeY = 0.225,
					image = "zd#zs3",
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
