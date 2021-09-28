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
			sizeX = 0.1335938,
			sizeY = 0.1875,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dw",
				varName = "background",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "ptbj#tmk",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dw2",
				varName = "textBg",
				posX = 0.4824883,
				posY = 0.2115467,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9064324,
				sizeY = 0.2222222,
				image = "ptbj#top1",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz",
				varName = "desc",
				posX = 0.5,
				posY = 0.2147392,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7999936,
				sizeY = 0.4795922,
				text = "狮子座",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tb",
				varName = "bg",
				posX = 0.5,
				posY = 0.6481482,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4444443,
				sizeY = 0.5629629,
				image = "kfhy#shizizuo",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "gxd",
				posX = 0.1294249,
				posY = 0.8328145,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2631578,
				sizeY = 0.3333333,
				image = "xqrj#gxd",
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "gxan",
					varName = "choose_btn",
					posX = 1.8977,
					posY = -0.5204537,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 3.69379,
					sizeY = 3.002192,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dj",
					varName = "tick",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9999999,
					sizeY = 1,
					image = "xqrj#dg",
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
