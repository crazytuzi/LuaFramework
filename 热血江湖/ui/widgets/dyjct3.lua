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
			sizeX = 0.4146698,
			sizeY = 0.06874076,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "tiao",
				posX = 0.3831899,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7592638,
				sizeY = 0.7071657,
				image = "jy#tiao",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "wza",
					varName = "groupName",
					posX = 0.4143236,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6867129,
					sizeY = 1.979112,
					text = "丹药",
					color = "FFED6114",
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "btn",
				varName = "btn",
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
				name = "jt1",
				varName = "right",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.03391252,
				sizeY = 0.4445041,
				image = "chu1#jt2",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jt2",
				varName = "down",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.03391252,
				sizeY = 0.4445041,
				image = "chu1#jt2",
				rotation = 90,
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
