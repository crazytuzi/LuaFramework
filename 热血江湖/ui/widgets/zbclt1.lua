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
			sizeX = 0.09,
			sizeY = 0.1638889,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "cc1",
				varName = "bt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dk1",
					varName = "icon_bg",
					posX = 0.5118598,
					posY = 0.594976,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.6944444,
					sizeY = 0.6779661,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "t1",
						varName = "item_icon",
						posX = 0.5,
						posY = 0.5127688,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8,
						sizeY = 0.8,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "suo",
						varName = "suo",
						posX = 0.1920202,
						posY = 0.226778,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.3375,
						sizeY = 0.3375,
						image = "tb#tb_suo.png",
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "ss1",
					varName = "item_count",
					posX = 0.5,
					posY = 0.09895537,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.257374,
					sizeY = 0.296635,
					text = "222/333",
					fontOutlineColor = "FF27221D",
					hTextAlign = 1,
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
