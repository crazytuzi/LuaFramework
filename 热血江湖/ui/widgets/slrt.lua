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
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2359375,
			sizeY = 0.1360939,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "slrt",
				varName = "root",
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
					name = "txa",
					varName = "iconBtn",
					posX = 0.3530595,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7061192,
					sizeY = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "txk",
					varName = "txb_img",
					posX = 0.1612828,
					posY = 0.4670386,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.391879,
					sizeY = 0.9695103,
					image = "zdtx#txd",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "tx",
						varName = "icon",
						posX = 0.5054789,
						posY = 0.6925332,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7210885,
						sizeY = 1.110169,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "nam",
					varName = "name",
					posX = 0.608629,
					posY = 0.6957251,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5651863,
					sizeY = 0.493486,
					text = "公认热血最强人",
					color = "FF966856",
					fontSize = 22,
					fontOutlineColor = "FF0C3F3C",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "gx",
					varName = "elationship",
					posX = 0.608629,
					posY = 0.3079315,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5651863,
					sizeY = 0.493486,
					text = "陌生人",
					color = "FFC93034",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "jr",
					varName = "jrBtn",
					posX = 0.8824677,
					posY = 0.4999968,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2161627,
					sizeY = 0.964075,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jt",
					varName = "jiantou",
					posX = 0.89542,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.05960265,
					sizeY = 0.2245182,
					image = "chu1#jt2",
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
