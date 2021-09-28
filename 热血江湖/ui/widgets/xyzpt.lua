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
			name = "jd1",
			posX = 0.4999999,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.35625,
			sizeY = 0.06944445,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dw",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.98,
				image = "d#bt",
				alpha = 0.5,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "bew",
				varName = "dwa",
				posX = 0.4485351,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8034774,
				sizeY = 1,
				text = "文字描述文字文字描述文字描述",
				color = "FF634624",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dk",
				varName = "iconbg",
				posX = 0.8070181,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.09868421,
				sizeY = 0.8810531,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dt",
					varName = "icon",
					posX = 0.5060216,
					posY = 0.5299393,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8014206,
					sizeY = 0.8186566,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl",
					varName = "cnt",
					posX = 2.019463,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.840451,
					sizeY = 0.8038867,
					text = "x20",
					color = "FF634624",
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
