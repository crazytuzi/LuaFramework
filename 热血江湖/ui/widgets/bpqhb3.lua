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
			name = "ysjm",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.1613536,
			sizeY = 0.3833333,
			hTextAlign = 1,
			vTextAlign = 1,
			layoutType = 5,
			layoutTypeW = 5,
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
				lockHV = true,
				sizeX = 0.9387097,
				sizeY = 0.9341763,
				image = "bphb#hongbaodakai2",
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "db2",
					posX = 0.5077477,
					posY = 0.6727936,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7531832,
					sizeY = 0.46156,
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wqd",
						posX = 0.5,
						posY = 0.147301,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.9286304,
						sizeY = 0.3869294,
						text = "您手慢了，红包已经被抢完了哦！",
						color = "FF9A2511",
						fontSize = 18,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "okBtn",
				posX = 0.5,
				posY = 0.2095172,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6662611,
				sizeY = 0.1891118,
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
