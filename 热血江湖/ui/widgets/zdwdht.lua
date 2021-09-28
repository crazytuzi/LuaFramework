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
			varName = "root",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.0390625,
			sizeY = 0.07222223,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "db",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 1,
				sizeY = 0.9615383,
				image = "wdh#xued",
			},
		},
		{
			prop = {
				etype = "ProgressTimer",
				name = "xt",
				varName = "blood",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.9615383,
				image = "wdh#xue",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "wj1",
				varName = "typeImg",
				posX = 0.5,
				posY = 0.48,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9,
				sizeY = 0.8653845,
				image = "zy#daoke",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "sl1",
					varName = "livesTxt",
					posX = 0.797406,
					posY = 0.1664938,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.016917,
					sizeY = 0.7835625,
					text = "1",
					color = "FFFFE244",
					fontOutlineEnable = true,
					hTextAlign = 1,
					vTextAlign = 1,
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
	gy = {
	},
	gy2 = {
	},
	gy3 = {
	},
	gy4 = {
	},
	gy5 = {
	},
	gy6 = {
	},
	gy7 = {
	},
	gy8 = {
	},
	gy9 = {
	},
	gy10 = {
	},
	gy11 = {
	},
	gy12 = {
	},
	gy13 = {
	},
	gy14 = {
	},
	c_dakai = {
	},
	c_dakai2 = {
	},
	c_dakai3 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
