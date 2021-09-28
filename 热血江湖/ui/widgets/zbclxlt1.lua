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
			name = "qm2",
			varName = "attrRoot2",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.3416267,
			sizeY = 0.07638889,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dwt2",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9,
				sizeY = 0.95,
				image = "d#bt",
				alpha = 0.5,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "js2",
				varName = "attr",
				posX = 0.612363,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3600475,
				sizeY = 0.9999994,
				text = "666（+12）",
				color = "FF966856",
				fontOutlineColor = "FFA47848",
				fontOutlineSize = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an2",
				varName = "lockBtn",
				posX = 0.06663514,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1120558,
				sizeY = 0.9272727,
				image = "zq#ws",
				imageNormal = "zq#ws",
				imagePressed = "zq#ys",
				imageDisable = "zq#ws",
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mc2",
				varName = "name",
				posX = 0.3991745,
				posY = 0.5000006,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.342347,
				sizeY = 1.052631,
				text = "气血：",
				color = "FF966856",
				fontOutlineColor = "FF27221D",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "s",
				varName = "prop_icon",
				posX = 0.1752675,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1143426,
				sizeY = 0.9090909,
				image = "zt#qixue",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xx",
				posX = 0.8110108,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.05945817,
				sizeY = 0.4727273,
				image = "bs#xx",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "mc3",
					varName = "starCount",
					posX = 2.81496,
					posY = 0.423077,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 3.392074,
					sizeY = 1.923077,
					text = "x10",
					color = "FFDFD3FF",
					fontOutlineEnable = true,
					fontOutlineColor = "FF6247AA",
					fontOutlineSize = 2,
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
