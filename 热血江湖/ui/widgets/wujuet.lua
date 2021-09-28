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
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2851563,
			sizeY = 0.04861111,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "btn",
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
				name = "z1",
				varName = "from",
				posX = 0.5806451,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3037915,
				sizeY = 1.842939,
				text = "40000",
				color = "FFF1E9D7",
				fontSize = 18,
				fontOutlineEnable = true,
				fontOutlineColor = "FFA47848",
				fontOutlineSize = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z2",
				varName = "to",
				posX = 0.8849005,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3516417,
				sizeY = 2.234031,
				text = "123123",
				color = "FF76D646",
				fontSize = 18,
				fontOutlineEnable = true,
				fontOutlineColor = "FF5B7838",
				fontOutlineSize = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tb",
				varName = "icon",
				posX = 0.09206852,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.09514562,
				sizeY = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jt",
				varName = "arrow",
				posX = 0.6762393,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.03835616,
				sizeY = 0.365297,
				image = "chu1#jt",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z3",
				varName = "name",
				posX = 0.2916348,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2882399,
				sizeY = 1.667254,
				text = "内甲能量",
				color = "FFF1E9D7",
				fontSize = 18,
				fontOutlineEnable = true,
				fontOutlineColor = "FFA47848",
				fontOutlineSize = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt4",
				varName = "propertyBg2",
				posX = 0.5000001,
				posY = 0.07258561,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9499999,
				sizeY = 0.0376648,
				image = "b#xian",
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
