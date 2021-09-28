--version = 1
local l_fileType = "layer"

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
			etype = "Button",
			name = "an",
			varName = "close_btn",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			disablePressScale = true,
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "ysjm",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt2",
				posX = 0.5,
				posY = 0.4814888,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3177942,
				sizeY = 0.2929901,
				image = "b#db5",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "top",
					posX = 0.5,
					posY = 0.8032467,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6858802,
					sizeY = 0.2322794,
					image = "chu1#zld",
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "z3",
						varName = "skill_name",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6770836,
						sizeY = 0.8848473,
						text = "技能名字",
						color = "FF966856",
						fontSize = 24,
						fontOutlineColor = "FF27221D",
						hTextAlign = 1,
						vTextAlign = 1,
						wordSpaceAdd = 4,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dk",
					posX = 0.5000001,
					posY = 0.363168,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9008035,
					sizeY = 0.5654143,
					image = "b#d2",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
				children = {
				{
					prop = {
						etype = "RichText",
						name = "z2",
						varName = "skill_desc",
						posX = 0.5,
						posY = 0.490644,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.9267728,
						sizeY = 0.887498,
						text = "技能说明一大堆写在这",
						color = "FF966856",
					},
				},
				{
					prop = {
						etype = "Scroll",
						name = "lb",
						varName = "scroll",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9399815,
						sizeY = 0.8840125,
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
