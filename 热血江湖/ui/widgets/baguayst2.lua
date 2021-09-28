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
			sizeX = 0.3100001,
			sizeY = 0.08333334,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dw",
				posX = 0.5563039,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9680633,
				sizeY = 0.6166666,
				image = "d#bt",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "diw1",
				varName = "typeIcon",
				posX = 0.1100167,
				posY = 0.4333333,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1638104,
				sizeY = 1.1,
				image = "yishu#tian",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sxt",
				varName = "propImage",
				posX = 0.2357743,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.126008,
				sizeY = 0.8333333,
				image = "zt#qixue",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "shuxz",
				varName = "name",
				posX = 0.656894,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6824346,
				sizeY = 1.235573,
				text = "攻击：",
				color = "FF966856",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "shuxz2",
				varName = "value",
				posX = 0.8624061,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4679846,
				sizeY = 1.235573,
				text = "500",
				color = "FF966856",
				fontOutlineColor = "FFA47848",
				fontOutlineSize = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "shuxz3",
				varName = "otherValue",
				posX = 1.003256,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4025662,
				sizeY = 1.235573,
				text = "500",
				color = "FF65944D",
				fontOutlineColor = "FF5B7838",
				fontOutlineSize = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jt",
				posX = 0.5831659,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.03528225,
				sizeY = 0.25,
				image = "chu1#jt",
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
	gy = {
	},
	gy2 = {
	},
	gy3 = {
	},
	gy4 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
