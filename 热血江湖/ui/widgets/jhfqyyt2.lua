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
			name = "jnljd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2636288,
			sizeY = 0.1705534,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "jnbjan",
				varName = "btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9127416,
				sizeY = 0.9364939,
				image = "h#c4",
				imageNormal = "h#c4",
				imagePressed = "h#c2",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "jnk",
					posX = 0.212263,
					posY = 0.5003412,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2987013,
					sizeY = 0.808696,
					image = "jn#scjnk",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "jntb",
						varName = "icon",
						posX = 0.4973859,
						posY = 0.5052307,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8695651,
						sizeY = 0.8602152,
						image = "xinfa#poxin",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "jnmc",
						varName = "name",
						posX = 1.767028,
						posY = 0.6752289,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.214361,
						sizeY = 0.4794052,
						text = "形影不离",
						color = "FF634624",
						fontSize = 24,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sjsj",
						varName = "level",
						posX = 1.751189,
						posY = 0.2834496,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8887613,
						sizeY = 0.4039857,
						text = "0级",
						color = "FF634624",
						fontSize = 24,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
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
