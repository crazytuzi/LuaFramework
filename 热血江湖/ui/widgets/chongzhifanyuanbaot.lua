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
			sizeX = 0.1098937,
			sizeY = 0.1111111,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "djk",
				varName = "bg",
				posX = 0.2755533,
				posY = 0.4625,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.5331858,
				sizeY = 0.9375001,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt",
					varName = "icon",
					posX = 0.5006653,
					posY = 0.521825,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8342896,
					sizeY = 0.8386557,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo",
					varName = "lock",
					posX = 0.2170653,
					posY = 0.2504183,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.4166667,
					sizeY = 0.4166667,
					image = "tb#suo",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sz",
					varName = "count",
					posX = 1.98128,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.865922,
					sizeY = 0.6722478,
					text = "x1",
					color = "FF966856",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn",
					varName = "btn",
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
				etype = "Image",
				name = "lz",
				varName = "otherImg",
				posX = 0.2225162,
				posY = 0.7832245,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5331857,
				sizeY = 0.5375,
				image = "sc#lz",
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
