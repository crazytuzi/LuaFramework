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
			sizeX = 0.2234375,
			sizeY = 0.4,
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
				sizeX = 0.98,
				sizeY = 0.98,
				image = "b#d2",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "zhuo",
					posX = 0.5,
					posY = 0.4893707,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7920651,
					sizeY = 0.2373866,
					image = "bagua#zhuo1",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "btn",
				varName = "selectBtn",
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
				name = "djk",
				varName = "bg",
				posX = 0.5,
				posY = 0.7231759,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.3286713,
				sizeY = 0.3263889,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt",
					varName = "icon",
					posX = 0.4997417,
					posY = 0.5188185,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8241311,
					sizeY = 0.8363171,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "slz",
					varName = "count",
					posX = 0.5621452,
					posY = 0.1879524,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7492539,
					sizeY = 0.4245133,
					text = "x5",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo",
					varName = "suo",
					posX = 0.1919341,
					posY = 0.2025296,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3191489,
					sizeY = 0.3191489,
					image = "tb#suo",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz",
				varName = "name",
				posX = 0.5,
				posY = 0.486055,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.044549,
				sizeY = 0.1887826,
				text = "名字写这里",
				color = "FFFFFF00",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "ms",
				varName = "desc",
				posX = 0.4965075,
				posY = 0.1984013,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9145821,
				sizeY = 0.367453,
				text = "道具说明描述写这里",
				color = "FF966856",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xz",
				varName = "selectImg",
				posX = 0.5,
				posY = 0.4982967,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.043023,
				sizeY = 1.015767,
				image = "sp#wk",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
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
