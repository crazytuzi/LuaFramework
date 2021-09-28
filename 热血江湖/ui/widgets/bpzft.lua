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
			sizeX = 0.6762072,
			sizeY = 0.1388889,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "info_btn",
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
				etype = "Image",
				name = "lbt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 1,
				sizeY = 1,
				image = "b#ftd1",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.6,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mc",
				varName = "times",
				posX = 0.8304083,
				posY = 0.1931218,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3795866,
				sizeY = 0.7439823,
				text = "剩余祝福次数：10",
				color = "FF439565",
				fontSize = 18,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "fwb",
				varName = "des",
				posX = 0.3725431,
				posY = 0.4876242,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4625307,
				sizeY = 0.7539679,
				text = "xx祝福:x小时内击杀怪物所获得的经验提示x%",
				color = "FF439565",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tb",
				varName = "title",
				posX = 0.0732252,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.0924273,
				sizeY = 0.8,
				image = "bpzf#1",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "btn",
				varName = "blessing",
				posX = 0.8304082,
				posY = 0.5998325,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.142107,
				sizeY = 0.58,
				image = "chu1#an3",
				imageNormal = "chu1#an3",
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "btnz",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.03494,
					sizeY = 1.123364,
					text = "使 用",
					fontSize = 22,
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
