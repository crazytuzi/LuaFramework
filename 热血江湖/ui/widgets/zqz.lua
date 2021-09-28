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
			etype = "Button",
			name = "qh10",
			varName = "roleTitle_btn",
			posX = 0.9319386,
			posY = 0.5678637,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.07734375,
			sizeY = 0.2125,
			image = "tong#yq1",
			imageNormal = "tong#yq1",
			imagePressed = "chu1#yq2",
			imageDisable = "tong#yq1",
			disablePressScale = true,
			soundEffectClick = "audio/rxjh/UI/anniu.ogg",
		},
		children = {
		{
			prop = {
				etype = "Label",
				name = "dsa4",
				posX = 0.499558,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3136712,
				sizeY = 0.8094339,
				text = "称号",
				color = "FFEBC6B4",
				fontSize = 26,
				fontOutlineColor = "FF51361C",
				fontOutlineSize = 2,
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
