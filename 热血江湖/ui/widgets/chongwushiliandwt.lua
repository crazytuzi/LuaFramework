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
			name = "jd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.5097226,
			sizeY = 0.1041667,
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
				sizeX = 1,
				sizeY = 1,
				image = "xunyang#tiao1",
				scale9Left = 0.3,
				scale9Right = 0.6,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "mc1",
					varName = "name",
					posX = 0.4220027,
					posY = 0.4999996,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7559947,
					sizeY = 1.003567,
					text = "风雨森林",
					color = "FF966856",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mc2",
					varName = "level",
					posX = 0.5191991,
					posY = 0.4999996,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5983863,
					sizeY = 1.003567,
					text = "90级",
					color = "FF65944D",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mc3",
					varName = "des",
					posX = 0.6354194,
					posY = 0.4999996,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.595241,
					sizeY = 1.003567,
					text = "建议所有试炼技能3级以上",
					color = "FF966856",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "jran",
					varName = "join",
					posX = 0.8886659,
					posY = 0.4466668,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1885217,
					sizeY = 0.7733331,
					image = "chu1#an3",
					imageNormal = "chu1#an3",
					disablePressScale = true,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "jrz",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.11167,
						sizeY = 1.157679,
						text = "进入",
						fontOutlineEnable = true,
						fontOutlineColor = "FF347468",
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
