--version = 1
local l_fileType = "node"

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
			etype = "Grid",
			name = "k1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.709375,
			sizeY = 0.6378398,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "db",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9724669,
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
					sizeX = 1.029445,
					sizeY = 1.167134,
					image = "czhd1#banner",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "cjsl",
					varName = "img",
					posX = 0.5130238,
					posY = 0.4172554,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 1,
					sizeY = 0.9755149,
					image = "cscbbanner#cscbbanner",
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sj1",
					varName = "title",
					posX = 0.3237417,
					posY = -0.01927304,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.25,
					text = "活动期限：",
					color = "FFF6C07F",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sj2",
					varName = "ActivitiesTime",
					posX = 0.6178982,
					posY = -0.01927304,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9738973,
					sizeY = 0.1317907,
					text = "10",
					color = "FFF6C07F",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Sprite3D",
					name = "mx",
					varName = "model",
					posX = 0.8141686,
					posY = -0.05326446,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2102985,
					sizeY = 0.7978303,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "pao",
					posX = 0.4758868,
					posY = 0.699024,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4210411,
					sizeY = 0.328485,
					image = "b#pao",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
				children = {
				{
					prop = {
						etype = "RichText",
						name = "smz",
						varName = "content",
						posX = 0.4735292,
						posY = 0.49482,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8667266,
						sizeY = 0.8541009,
						text = "说明",
						color = "FF54F9FF",
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
