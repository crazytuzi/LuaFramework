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
			sizeX = 0.6732632,
			sizeY = 0.1111111,
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
				image = "b#lbt",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.55,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z11",
				varName = "name",
				posX = 0.1060525,
				posY = 0.4999999,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2877926,
				sizeY = 0.9663996,
				text = "名字",
				color = "FF966856",
				fontOutlineColor = "FF143230",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z3",
				varName = "level",
				posX = 0.2386994,
				posY = 0.5000003,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1634794,
				sizeY = 0.9663996,
				text = "10",
				color = "FF966856",
				fontOutlineColor = "FF143230",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z8",
				varName = "power",
				posX = 0.3456892,
				posY = 0.5000002,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2424216,
				sizeY = 0.9663996,
				text = "66666666",
				color = "FF966856",
				fontOutlineColor = "FF143230",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z9",
				varName = "activity",
				posX = 0.505711,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1634794,
				sizeY = 0.9663996,
				text = "654321",
				color = "FF966856",
				fontOutlineColor = "FF143230",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z10",
				varName = "dividend",
				posX = 0.6396666,
				posY = 0.5000001,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1634794,
				sizeY = 0.9663996,
				text = "1000000",
				color = "FF966856",
				fontOutlineColor = "FF143230",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z12",
				varName = "state",
				posX = 0.7887074,
				posY = 0.5000001,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1634794,
				sizeY = 0.9663996,
				text = "久未上线",
				color = "FF966856",
				fontOutlineColor = "FF143230",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "unbind",
				posX = 0.9193739,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1251129,
				sizeY = 0.6303954,
				image = "chu1#sn1",
				imageNormal = "chu1#sn1",
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "anz",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.059265,
					sizeY = 1.174213,
					text = "解 绑",
					color = "FF966856",
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
