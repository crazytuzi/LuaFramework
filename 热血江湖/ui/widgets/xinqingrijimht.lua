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
			name = "jd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.078125,
			sizeY = 0.1791667,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "djk",
				varName = "bgIcon",
				posX = 0.5,
				posY = 0.6684434,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.85,
				sizeY = 0.6589146,
				image = "djk#ktong",
				effect = "bgIcon",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt",
					varName = "icon",
					posX = 0.4997493,
					posY = 0.5187224,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8490807,
					sizeY = 0.8365093,
					effect = "icon",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "syz",
					varName = "usingIcon",
					posX = 0.1945959,
					posY = 0.5822377,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.3764706,
					sizeY = 0.8470588,
					image = "biaoche#syz",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wz",
				varName = "name",
				posX = 0.5,
				posY = 0.2683087,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.168564,
				sizeY = 0.6696492,
				text = "名称名称",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wz2",
				varName = "isOwned",
				posX = 0.5,
				posY = 0.09776667,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.168564,
				sizeY = 0.6696492,
				text = "已拥有",
				fontSize = 18,
				hTextAlign = 1,
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
