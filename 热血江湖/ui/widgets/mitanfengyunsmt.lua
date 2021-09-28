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
			name = "k",
			posX = 0.5,
			posY = 0.466434,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.4140625,
			sizeY = 0.2129654,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.5358136,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.9283727,
				image = "guidaoyuling1#db",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tb",
					posX = 0.1306684,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1830189,
					sizeY = 0.6198517,
					image = "jn#jnbai",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "tb1",
						varName = "icon",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.742268,
						sizeY = 0.8275861,
						image = "skillqiang#qiang_16fengmo",
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mc",
					varName = "name",
					posX = 0.4172455,
					posY = 0.8597769,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3475384,
					sizeY = 0.25,
					text = "技能名称",
					color = "FF0000FF",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "ms",
					varName = "desc",
					posX = 0.6081416,
					posY = 0.3870627,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7293304,
					sizeY = 0.6069973,
					text = "技能说明技能技能技能技能说明技能技能说明说明技能说明明技能技能说明技能技能技能说明技能技能技能技能说明技能技能说明说技能技能说明技能技能技能说明技能技能技能技能说明技能技能说明说明技能说明明技能说明",
					color = "FF966856",
					fontSize = 18,
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
