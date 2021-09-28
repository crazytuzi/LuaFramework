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
				varName = "closeBtn",
				posX = 0.5000001,
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
			posX = 0.4992199,
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
				name = "fx",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7050925,
				sizeY = 0.9526008,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "zg",
					posX = 0.5011054,
					posY = 0.4985449,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.017699,
					sizeY = 0.8573508,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hp",
					varName = "icon1",
					posX = 0.2091085,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4321242,
					sizeY = 0.8208522,
					image = "hjha#2",
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.2,
					scale9Bottom = 0.7,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "hp1",
					varName = "desc1",
					posX = 0.2843292,
					posY = 0.2158469,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.3697039,
					sizeY = 0.0917215,
					text = "和平分线说明",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "hp2",
					varName = "enterBtn1",
					posX = 0.2085188,
					posY = 0.5589529,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4236708,
					sizeY = 0.77147,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "ld",
					varName = "icon2",
					posX = 0.7926446,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4321242,
					sizeY = 0.8208522,
					image = "hjha#1",
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.2,
					scale9Bottom = 0.7,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "ld1",
					varName = "desc2",
					posX = 0.7129995,
					posY = 0.2158469,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.3697039,
					sizeY = 0.0917215,
					text = "乱斗分线说明",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "ld2",
					varName = "enterBtn2",
					posX = 0.7893268,
					posY = 0.5748076,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4236708,
					sizeY = 0.77147,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "aaa",
					varName = "desc",
					posX = 0.5,
					posY = 0.126516,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6836269,
					sizeY = 0.07332666,
					text = "hh ",
					color = "FFFFFFC0",
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
