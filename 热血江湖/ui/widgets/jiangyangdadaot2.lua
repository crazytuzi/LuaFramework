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
			name = "jd2",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.29375,
			sizeY = 0.2777778,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "xin2",
				varName = "iconBg",
				posX = 0.5,
				posY = 0.49,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.912234,
				sizeY = 0.9999999,
				image = "jydd#jyddtx",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "btn2",
				varName = "check",
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
				name = "mz2",
				varName = "name",
				posX = 0.5701528,
				posY = 0.7482949,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7943274,
				sizeY = 0.1970828,
				text = "大盗名字",
				color = "FF9D5749",
				fontSize = 22,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "deng6",
				varName = "level",
				posX = 0.4188062,
				posY = 0.5800098,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4916344,
				sizeY = 0.1970828,
				text = "大盗等级",
				color = "FF9D5749",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "yueka2",
				varName = "monthCard",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6943223,
				sizeY = 0.288977,
				text = "月卡用户专属",
				color = "FFFFF48A",
				fontSize = 22,
				fontOutlineEnable = true,
				fontOutlineColor = "FF7D3E3A",
				fontOutlineSize = 2,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "deng8",
				varName = "stateDesc",
				posX = 0.4314187,
				posY = 0.2978485,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5168594,
				sizeY = 0.2845232,
				text = "两个字吧",
				color = "FF6B4498",
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
