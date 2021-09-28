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
			name = "k1",
			varName = "baseSetPanel",
			posX = 0.5,
			posY = 0.4922003,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.464861,
			sizeY = 0.06205098,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "g11",
				posX = 0.09541062,
				posY = 0.4897822,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.05714073,
				sizeY = 0.716257,
				image = "jh1#szdt",
			},
			children = {
			{
				prop = {
					etype = "RichText",
					name = "text",
					varName = "textLabel",
					posX = 8.457137,
					posY = 0.5469919,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 14.33815,
					sizeY = 1.030823,
					text = "结婚异性2人组队且在月老附近sssss",
					color = "FFC33636",
					fontSize = 22,
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "sz",
					varName = "number",
					posX = 0.5079678,
					posY = 0.5905763,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.174538,
					sizeY = 1.216778,
					text = "1.",
					color = "FFFFEFCC",
					fontSize = 22,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
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
