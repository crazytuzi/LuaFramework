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
			etype = "Image",
			name = "zmk",
			posX = 0.1085661,
			posY = 0.7496068,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.1255046,
			sizeY = 0.2180759,
			image = "w#w_jncheng.png",
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "xx1",
				posX = 0.4916154,
				posY = 0.9113577,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3106759,
				sizeY = 0.3295288,
				image = "top#top_xx.png",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xx2",
				posX = 0.1141782,
				posY = 0.3601807,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3106759,
				sizeY = 0.3295288,
				image = "top#top_xx.png",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xx3",
				posX = 0.8773792,
				posY = 0.3601807,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3106759,
				sizeY = 0.3295288,
				image = "top#top_xx.png",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "zdj",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.394221,
				text = "12",
				fontSize = 26,
				fontOutlineEnable = true,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		},
	},
	},
}
--EDITOR elements end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
