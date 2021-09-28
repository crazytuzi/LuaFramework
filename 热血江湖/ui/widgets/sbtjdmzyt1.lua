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
			name = "tj1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.3210937,
			sizeY = 0.09923995,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "ditu",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "b#scd1",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "tbn",
					varName = "sendAway",
					posX = 0.8012241,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3163017,
					sizeY = 0.609319,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "ntba",
						posX = 0.3773417,
						posY = 0.5196078,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8375808,
						sizeY = 0.8086997,
						text = "传送",
						color = "FF65944D",
						fontSize = 22,
						fontOutlineColor = "FF2A6953",
						fontOutlineSize = 2,
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "jt",
						posX = 0.9076954,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1076923,
						sizeY = 0.3445304,
						image = "chu1#jt",
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "wblx",
				varName = "desc",
				posX = 0.4435635,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7762327,
				sizeY = 0.6962112,
				text = "描述描述描述",
				color = "FF966856",
				fontSize = 24,
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
