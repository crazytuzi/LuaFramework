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
			name = "jie",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.08671875,
			sizeY = 0.2680556,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "btn",
				varName = "unWearBtn",
				posX = 0.5089958,
				posY = 0.2465053,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6936937,
				sizeY = 0.3989637,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jndk",
				varName = "kong",
				posX = 0.509009,
				posY = 0.2517016,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.963964,
				sizeY = 0.5544041,
				image = "yishu#yuand",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "djk",
				posX = 0.5,
				posY = 0.7073734,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.8468469,
				sizeY = 0.4870466,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt",
					varName = "icon",
					posX = 0.5306007,
					posY = 0.5200127,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.893617,
					sizeY = 0.9042553,
					image = "yishu#qian",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "djd",
					varName = "zhuanjing",
					posX = 0.8079768,
					posY = 0.2345048,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4574468,
					sizeY = 0.4574468,
					image = "yishu#djyuan",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "djz",
						varName = "count",
						posX = 0.5232558,
						posY = 0.4534884,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.730095,
						sizeY = 1.380074,
						text = "22",
						fontSize = 18,
						fontOutlineEnable = true,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jnt",
				varName = "skill_icon",
				posX = 0.5,
				posY = 0.2738986,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.963964,
				sizeY = 0.5544041,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jnd",
				varName = "skill_bg",
				posX = 0.5159672,
				posY = 0.2609383,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.963964,
				sizeY = 0.5544041,
				image = "yishu#yuan",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "suo",
				varName = "lock",
				posX = 0.509009,
				posY = 0.2453329,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6936937,
				sizeY = 0.3730569,
				image = "yishu#suo",
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
