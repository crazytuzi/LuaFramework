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
			name = "zbsct1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1151386,
			sizeY = 0.07777778,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "yq",
				varName = "type_btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "chu1#fy1",
				imageNormal = "chu1#fy1",
				imagePressed = "chu1#fy2",
				imageDisable = "chu1#fy1",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "wz",
					varName = "type_text",
					posX = 0.5,
					posY = 0.5193399,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9916163,
					sizeY = 0.8928571,
					text = "装 备",
					color = "FF966856",
					fontSize = 26,
					fontOutlineColor = "FF51361C",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hd",
					varName = "red_icon",
					posX = 0.9267914,
					posY = 0.7851633,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.1832031,
					sizeY = 0.5,
					image = "zdte#hd",
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
