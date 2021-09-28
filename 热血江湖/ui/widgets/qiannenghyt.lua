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
			sizeX = 0.3726563,
			sizeY = 0.1527778,
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
				sizeY = 0.9909089,
				image = "b#lbt",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.6,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "xian",
					posX = 0.4308185,
					posY = 0.4633028,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4339622,
					sizeY = 0.01834862,
					image = "jingmai#fgx",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jnd",
				varName = "bg",
				posX = 0.108941,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1719077,
				sizeY = 0.7454544,
				image = "jingmai#jnd",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "jnt",
					varName = "icon",
					posX = 0.4999898,
					posY = 0.5138195,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7266476,
					sizeY = 0.7295921,
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mc2",
				varName = "power",
				posX = 0.601206,
				posY = 0.7304643,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3460692,
				sizeY = 0.5152749,
				text = "55555",
				color = "FFFFE7AF",
				fontOutlineEnable = true,
				fontOutlineColor = "FFB2722C",
				fontOutlineSize = 2,
				vTextAlign = 1,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "zhan",
					posX = -0.1559832,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2120248,
					sizeY = 0.5645705,
					image = "tong#zl",
				},
			},
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "mc3",
				varName = "desc",
				posX = 0.4828135,
				posY = 0.2765665,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.547205,
				sizeY = 0.5152749,
				text = "技能描述",
				color = "FF966856",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "mzd",
				posX = 0.1089393,
				posY = 0.1914177,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.163522,
				sizeY = 0.1454545,
				image = "jingmai#qhd",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "mc1",
					varName = "name",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.500298,
					sizeY = 2.01172,
					text = "技能名称",
					color = "FFF1E9D7",
					fontSize = 18,
					fontOutlineEnable = true,
					fontOutlineColor = "FF831F07",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "djd",
				posX = 0.2553328,
				posY = 0.7304642,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.09224317,
				sizeY = 0.3818181,
				image = "jingmai#djd",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "dj",
					varName = "lvl",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.227541,
					sizeY = 1.037462,
					text = "22",
					color = "FFF1E9D7",
					fontOutlineEnable = true,
					fontOutlineColor = "FFA47848",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "ts",
				varName = "specialIcon",
				posX = 0.4602235,
				posY = 0.7450589,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.245283,
				sizeY = 0.2454545,
				image = "jingmai#tsxg",
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
