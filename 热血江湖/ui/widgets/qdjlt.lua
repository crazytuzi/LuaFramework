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
			name = "xjst",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.3617187,
			sizeY = 0.1666667,
			alphaCascade = true,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt1",
				varName = "item_bg",
				posX = 0.3531336,
				posY = 0.3250007,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1731237,
				sizeY = 0.6749999,
				image = "djk#ktong",
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
				alphaCascade = true,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tx1",
					varName = "item_icon",
					posX = 0.5,
					posY = 0.5169031,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8,
					sizeY = 0.8,
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wz1",
				varName = "title_desc",
				posX = 0.3748934,
				posY = 0.8329704,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6000001,
				sizeY = 0.4661092,
				text = "签到奖励：",
				fontSize = 24,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wz2",
				varName = "item_desc",
				posX = 0.7154675,
				posY = 0.3587631,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4962638,
				sizeY = 0.4661092,
				text = "大个经验丹x10",
				fontSize = 22,
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
