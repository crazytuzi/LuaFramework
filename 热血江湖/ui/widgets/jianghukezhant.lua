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
			name = "np1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.0734375,
			sizeY = 0.1388889,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "npn1",
				varName = "btn",
				posX = 0.5,
				posY = 0.48,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "djd1",
				posX = 0.5,
				posY = 0.48,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.010638,
				sizeY = 0.9599999,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "npt1",
					varName = "icon",
					posX = 0.4996338,
					posY = 0.536433,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8413734,
					sizeY = 0.8631689,
					image = "tx#tx_chenshangbif.png",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zz",
				varName = "darkImg",
				posX = 0.5,
				posY = 0.5199685,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8709112,
				sizeY = 0.8186566,
				image = "b#bp",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "zl1",
				varName = "powerLabel",
				posX = 0.4882299,
				posY = 0.3533204,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.015982,
				sizeY = 0.4089863,
				text = "23546",
				color = "FFFF4412",
				fontOutlineEnable = true,
				fontOutlineColor = "FF0C1E1D",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "zl2",
				varName = "needLabel",
				posX = 0.5,
				posY = 0.6349872,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.093281,
				sizeY = 0.4089863,
				text = "战力需求",
				color = "FFFF4412",
				fontOutlineEnable = true,
				fontOutlineColor = "FF0C1E1D",
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
				posY = 0.52,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 1.106383,
				sizeY = 1.04,
				image = "djk#zbxz",
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
