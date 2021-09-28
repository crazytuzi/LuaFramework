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
			name = "jjpht",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.078125,
			sizeY = 0.1736111,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "xb",
				posX = 0.5,
				posY = 0.172,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7675207,
				sizeY = 0.248,
				image = "b#pmd",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tpm2",
				varName = "price",
				posX = 0.4850193,
				posY = 0.1840454,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7487688,
				sizeY = 0.2640615,
				text = "4.",
				color = "FF966856",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dj1",
				varName = "grade_icon",
				posX = 0.4892868,
				posY = 0.622147,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.85,
				sizeY = 0.6800001,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt1",
					varName = "item_icon",
					posX = 0.499981,
					posY = 0.5276311,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8108343,
					sizeY = 0.8282878,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an1",
					varName = "bt",
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
					name = "suo1",
					varName = "suo",
					posX = 0.2026743,
					posY = 0.2376662,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.3384071,
					sizeY = 0.3456846,
					image = "tb#suo",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "bz",
					varName = "isShareIcon",
					posX = 0.2071314,
					posY = 0.6864435,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.3733333,
					sizeY = 0.6133333,
					image = "wdh#bz",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl",
					varName = "count",
					posX = 0.4149073,
					posY = 0.1907928,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.017323,
					sizeY = 0.6100187,
					text = "x10",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "mian",
					varName = "mian",
					posX = 0.805374,
					posY = 0.640946,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					lockHV = true,
					sizeX = 0.2941177,
					sizeY = 0.6925996,
					image = "qz#mf",
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
