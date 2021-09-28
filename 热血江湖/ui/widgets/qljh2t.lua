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
			sizeX = 0.2698804,
			sizeY = 0.06666667,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dc3",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9999997,
				sizeY = 0.9166666,
				image = "d#bt",
				alpha = 0.5,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "pd3",
					varName = "image",
					posX = 0.07880582,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1100025,
					sizeY = 0.7727273,
					image = "chu1#dj",
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "wb3",
					varName = "label",
					posX = 0.6383836,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9578215,
					sizeY = 1.183666,
					text = "条件1",
					color = "FF966856",
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
