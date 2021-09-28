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
			sizeX = 0.1729215,
			sizeY = 0.6128823,
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
				sizeX = 1.048164,
				sizeY = 0.9699161,
				image = "qiling#db",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dib",
					posX = 0.5,
					posY = 0.1311691,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.912037,
					sizeY = 0.2068966,
					image = "qiling#sxd",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tx",
				varName = "headImg",
				posX = 0.5000001,
				posY = 0.651913,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6234766,
				sizeY = 0.31273,
				image = "qiling#suo",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "mz",
				varName = "nameImg",
				posX = 0.5,
				posY = 0.8663155,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4879382,
				sizeY = 0.1065095,
				image = "qiling#qilin",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zbz",
				varName = "weaponIcon",
				posX = 0.5043799,
				posY = 0.3583149,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2167621,
				sizeY = 0.1065095,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "btn",
				varName = "infoBtn",
				posX = 0.5,
				posY = 0.6404572,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8638104,
				sizeY = 0.2944501,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "wb1",
				varName = "rankLabel",
				posX = 0.5,
				posY = 0.147127,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.716054,
				sizeY = 0.1246388,
				text = "多少阶",
				color = "FF966856",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "wb2",
				varName = "levelLabel",
				posX = 1.331063,
				posY = 0.2028664,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.4849339,
				sizeY = 0.0871157,
				text = "多少段",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "wb3",
				varName = "mifaLabel",
				posX = 0.4999999,
				posY = 0.09409992,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.716054,
				sizeY = 0.1246388,
				text = "秘法多少级",
				color = "FF966856",
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
	gy = {
	},
	gy3 = {
	},
	gy2 = {
	},
	gy4 = {
	},
	gy5 = {
	},
	gy6 = {
	},
	gy7 = {
	},
	gy8 = {
	},
	gy9 = {
	},
	gy10 = {
	},
	gy11 = {
	},
	gy12 = {
	},
	gy13 = {
	},
	gy14 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
