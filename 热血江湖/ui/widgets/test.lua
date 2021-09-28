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
			name = "dt",
			posX = 0.7103457,
			posY = 0.5846851,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.3280784,
			sizeY = 0.08894772,
			image = "q#bossmingzidi.png",
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an",
				posX = 0.1673148,
				posY = 0.4839688,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2674641,
				sizeY = 0.7185338,
				image = "q#zidong.png",
				imageNormal = "q#zidong.png",
				imagePressed = "q#zidong.png",
				imageDisable = "q#zidong.png",
			},
		},
		{
			prop = {
				etype = "LoadingBar",
				name = "jdt",
				posX = 0.6640394,
				posY = 0.5311846,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.25,
				image = "q#bossxuetiao1.png",
				percent = 66,
			},
		},
		},
	},
	},
}
--EDITOR elements end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot)
end
return create
