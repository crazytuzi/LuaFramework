--version = 1
local l_fileType = "node"

local UIUtil = require "ui/common/UIUtil"

--EDITOR elements start tag
local eleRoot = 
{
	prop = {
		etype = "Layer",
		name = "root",
		varName = "bsjnsmt",
		posX = 0,
		posY = 0,
		anchorX = 0,
		anchorY = 0,
	},
	children = {
	{
		prop = {
			etype = "Grid",
			name = "k",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.3710938,
			sizeY = 0.1859289,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "b#scd1",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "jnd",
					varName = "cover",
					posX = 0.1324143,
					posY = 0.4999999,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1978947,
					sizeY = 0.70218,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "t",
						varName = "icon",
						posX = 0.4893897,
						posY = 0.5105955,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.7410772,
						sizeY = 0.7501155,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z1",
					varName = "name",
					posX = 0.4459517,
					posY = 0.8206747,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3733312,
					sizeY = 0.4986942,
					text = "技能名字",
					color = "FF911D02",
					fontSize = 24,
					fontOutlineColor = "FF1A4841",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "z6",
					varName = "desc",
					posX = 0.6245032,
					posY = 0.3739864,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7304341,
					sizeY = 0.6249157,
					text = "技能简单描述",
					color = "FF966856",
					fontOutlineColor = "FF1A4841",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xian",
				posX = 0.5,
				posY = 0.03,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9,
				sizeY = 0.01851852,
				image = "b#xian",
				scale9 = true,
				scale9Left = 0.35,
				scale9Right = 0.35,
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
