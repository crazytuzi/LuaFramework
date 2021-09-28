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
			etype = "Image",
			name = "lbdt1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.5429688,
			sizeY = 0.08360039,
			image = "b#lbt",
			scale9 = true,
			scale9Left = 0.2,
			scale9Right = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "detail_btn",
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
				etype = "Label",
				name = "lbtz1",
				varName = "name_label",
				posX = 0.1787652,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2385052,
				sizeY = 0.7950516,
				text = "名字六个字啊",
				color = "FF966856",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "lbtz5",
				varName = "old_contri",
				posX = 0.6042143,
				posY = 0.4999999,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1781897,
				sizeY = 0.7950516,
				text = "666654",
				color = "FF966856",
				fontOutlineColor = "FF0E3B2F",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "lbtz6",
				varName = "state",
				posX = 0.8620495,
				posY = 0.4999997,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1497242,
				sizeY = 0.7950516,
				text = "24小时前",
				color = "FF966856",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zy",
				varName = "job_icon",
				posX = 0.4089383,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0647482,
				sizeY = 0.7476042,
				image = "zy#daoke",
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
