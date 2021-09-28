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
			name = "zdt",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.56,
			sizeY = 0.14,
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
				sizeX = 0.9905134,
				sizeY = 1.027958,
				image = "dw#dw_d3.png",
				scale9 = true,
				scale9Left = 0.1,
				scale9Right = 0.1,
				scale9Top = 0.1,
				scale9Bottom = 0.1,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "rs",
					varName = "index",
					posX = 0.08841501,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.09646802,
					sizeY = 0.6656414,
					text = "1.",
					color = "FF966856",
					fontSize = 24,
					fontOutlineColor = "FF0E3B2F",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a1",
					varName = "joinBtn",
					posX = 0.8178515,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1732394,
					sizeY = 0.5597474,
					image = "chu1#an3",
					imageNormal = "chu1#an3",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "zz",
						posX = 0.5,
						posY = 0.5517241,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.210572,
						sizeY = 1.43535,
						text = "加 入",
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
					etype = "RichText",
					name = "rs3",
					varName = "teamName",
					posX = 0.3479044,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4109946,
					sizeY = 0.6656414,
					text = "1/3",
					color = "FF966856",
					fontSize = 24,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xian",
					posX = 0.103469,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.004225352,
					sizeY = 0.85,
					image = "b#shuxian",
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "rs2",
					varName = "teamCount",
					posX = 0.6047506,
					posY = 0.4999999,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1954643,
					sizeY = 0.488616,
					text = "人数 3/4",
					color = "FFC93034",
					fontSize = 22,
					fontOutlineColor = "FF0E3B2F",
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
