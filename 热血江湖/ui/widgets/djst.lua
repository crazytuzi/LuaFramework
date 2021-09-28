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
			name = "zbqht",
			varName = "node",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.4046875,
			sizeY = 0.06111111,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "smd",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.95,
				alpha = 0.5,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "zbqhtz",
				varName = "label",
				posX = 0.1415872,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1537455,
				sizeY = 0.7706608,
				text = "使用",
				color = "FF966856",
				fontSize = 22,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "zbqhtz2",
				varName = "value",
				posX = 0.8832675,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1917506,
				sizeY = 1.020652,
				text = "暴击x3",
				fontSize = 22,
				fontOutlineEnable = true,
				fontOutlineColor = "FF804040",
				vTextAlign = 1,
				colorTL = "FFFF8080",
				colorTR = "FFFF8080",
				colorBR = "FFFF0000",
				colorBL = "FFFF0000",
				useQuadColor = true,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tb1",
				posX = 0.2930897,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.0958396,
				sizeY = 1.156163,
				image = "tb#tb_yuanbao.png",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "suo",
					varName = "suo",
					posX = 0.7010925,
					posY = 0.3429326,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.5035763,
					sizeY = 0.4914375,
					image = "tb#suo",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "zbqhtz3",
				varName = "diamond",
				posX = 0.1890499,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.09381395,
				sizeY = 0.7706608,
				text = "100",
				color = "FF65944D",
				fontSize = 22,
				hTextAlign = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "zbqhtz4",
				posX = 0.4271168,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1537455,
				sizeY = 0.7706608,
				text = "获得",
				color = "FF966856",
				fontSize = 22,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "zbqhtz5",
				varName = "coin",
				posX = 0.5149532,
				posY = 0.5000001,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1537455,
				sizeY = 0.7706608,
				text = "100000",
				color = "FF65944D",
				fontSize = 22,
				hTextAlign = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tb2",
				posX = 0.6543715,
				posY = 0.5240924,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.0958396,
				sizeY = 1.156163,
				image = "tb#tb_tongqian.png",
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
