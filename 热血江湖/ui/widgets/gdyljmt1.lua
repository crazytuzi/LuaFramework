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
			varName = "root",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.05771694,
			sizeY = 0.1026078,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "jl2",
				varName = "btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9999996,
				sizeY = 0.9999999,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jl1",
				varName = "bg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.8662968,
				sizeY = 0.8662975,
				image = "guidaoyuling1#spdb",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "jiangli",
					varName = "icon",
					posX = 0.4946854,
					posY = 0.5108859,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.859375,
					sizeY = 0.8484989,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl",
					varName = "num",
					posX = 0.4747949,
					posY = 0.1568339,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9239773,
					sizeY = 0.5615811,
					text = "x1",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xz",
					varName = "select",
					posX = 0.4995785,
					posY = 0.4926109,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 1.125,
					sizeY = 1.125,
					image = "guidaoyuling1#xz",
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "xz2",
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
					name = "xz3",
					varName = "select2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.974584,
					sizeY = 0.9745846,
					image = "djk#xz",
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
