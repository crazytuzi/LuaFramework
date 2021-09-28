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
			sizeX = 0.7296875,
			sizeY = 0.08333334,
			image = "w#w_smd3.png",
			scale9 = true,
			scale9Left = 0.4,
			scale9Right = 0.4,
			alpha = 0.5,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an1",
				varName = "select_btn",
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
				name = "mz",
				varName = "owner_name",
				posX = 0.5426221,
				posY = 0.4999997,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2697593,
				sizeY = 0.825847,
				text = "我的名字很长暗暗",
				color = "FF5AF6D3",
				fontSize = 24,
				fontOutlineEnable = true,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "zmm",
				varName = "clan_name",
				posX = 0.1440529,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.267227,
				sizeY = 0.825847,
				text = "全世界最屌宗门",
				color = "FF5AF6D3",
				fontSize = 24,
				fontOutlineEnable = true,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "dj",
				varName = "clan_id",
				posX = 0.3427044,
				posY = 0.4999997,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1705238,
				sizeY = 0.825847,
				text = "12",
				color = "FF5AF6D3",
				fontSize = 24,
				fontOutlineEnable = true,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "zl",
				varName = "owner_power",
				posX = 0.7449286,
				posY = 0.5000002,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1753013,
				sizeY = 0.825847,
				text = "1200000",
				color = "FF5AF6D3",
				fontSize = 24,
				fontOutlineEnable = true,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mw",
				varName = "distance_label",
				posX = 0.9004225,
				posY = 0.4999997,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1761341,
				sizeY = 0.825847,
				text = "1200000",
				color = "FF5AF6D3",
				fontSize = 24,
				fontOutlineEnable = true,
				hTextAlign = 1,
				vTextAlign = 1,
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
