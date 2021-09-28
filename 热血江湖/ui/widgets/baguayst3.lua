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
			sizeY = 0.1111111,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dw",
				posX = 0.5563039,
				posY = 0.675,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9680633,
				sizeY = 0.4625,
				image = "d#bt",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "diw1",
				varName = "typeIcon",
				posX = 0.1100167,
				posY = 0.6,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1512096,
				sizeY = 0.7615387,
				image = "yishu#tian",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sxt",
				varName = "propImage",
				posX = 0.2357743,
				posY = 0.675,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.126008,
				sizeY = 0.6250001,
				image = "zt#qixue",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "shuxz",
				varName = "name",
				posX = 0.656894,
				posY = 0.675,
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
				etype = "RichText",
				name = "tswb1",
				varName = "text1",
				posX = 0.5970137,
				posY = 0.2817118,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7425243,
				sizeY = 0.6865772,
				text = "xxx加点最高时启动",
				color = "FFC93034",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "shuxz2",
				varName = "value",
				posX = 0.8624061,
				posY = 0.675,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4679846,
				sizeY = 1.235573,
				text = "+231",
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
				posY = 0.675,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4025662,
				sizeY = 1.235573,
				text = "+231",
				color = "FF65944D",
				fontOutlineColor = "FF5B7838",
				fontOutlineSize = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "yjh",
				varName = "jihuo",
				posX = 0.9151431,
				posY = 0.6747194,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1234879,
				sizeY = 0.6125001,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jt",
				posX = 0.5831659,
				posY = 0.675,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.03528225,
				sizeY = 0.1875,
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
