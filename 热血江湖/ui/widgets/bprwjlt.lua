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
			name = "k1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.4992188,
			sizeY = 0.1332721,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "rcht1",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9937401,
				sizeY = 0.95,
				image = "b#lbt",
				scale9 = true,
				scale9Left = 0.2,
				scale9Right = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "an1",
					varName = "globel_btn",
					posX = 0.5006351,
					posY = 0.4999979,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.97074,
					sizeY = 0.8314365,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "icok",
					posX = 0.07804795,
					posY = 0.461658,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1338583,
					sizeY = 0.9422608,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "ico",
						varName = "taskIcon",
						posX = 0.4976835,
						posY = 0.5379093,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8,
						sizeY = 0.8,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "rwmc",
					varName = "taskName",
					posX = 0.2922207,
					posY = 0.7351722,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2789056,
					sizeY = 0.4653175,
					text = "任务名称",
					color = "FF966856",
					fontSize = 24,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "wpk2",
					varName = "image2",
					posX = 0.5455393,
					posY = 0.5397032,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.07037297,
					sizeY = 0.5484976,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "wp2",
						varName = "icon2",
						posX = 0.522378,
						posY = 0.42,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.118898,
						sizeY = 0.9999998,
						image = "ty#exp",
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "rwtj2",
					posX = 0.4853187,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1429939,
					sizeY = 0.6326435,
					text = "奖励",
					color = "FF65944D",
					fontSize = 24,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "rwtj4",
					varName = "contri_count",
					posX = 0.6800211,
					posY = 0.4999999,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1682209,
					sizeY = 0.6326435,
					text = "×30000",
					color = "FF65944D",
					fontSize = 24,
					fontOutlineColor = "FF00152E",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xx",
					varName = "star1",
					posX = 0.1683198,
					posY = 0.2624033,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.0472441,
					sizeY = 0.3290985,
					image = "ty#xx",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xx6",
					posX = 0.2071452,
					posY = 0.2624033,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.0472441,
					sizeY = 0.3290985,
					image = "ty#xx",
					alpha = 0.3,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xx7",
					posX = 0.2459705,
					posY = 0.2624033,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.0472441,
					sizeY = 0.3290985,
					image = "ty#xx",
					alpha = 0.3,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xx8",
					posX = 0.2847959,
					posY = 0.2624033,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.0472441,
					sizeY = 0.3290985,
					image = "ty#xx",
					alpha = 0.3,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xx9",
					posX = 0.3236213,
					posY = 0.2624033,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.0472441,
					sizeY = 0.3290985,
					image = "ty#xx",
					alpha = 0.3,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xx2",
					varName = "star2",
					posX = 0.2071452,
					posY = 0.2624033,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.0472441,
					sizeY = 0.3290985,
					image = "ty#xx",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xx3",
					varName = "star3",
					posX = 0.2459705,
					posY = 0.2624033,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.0472441,
					sizeY = 0.3290985,
					image = "ty#xx",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xx4",
					varName = "star4",
					posX = 0.2847959,
					posY = 0.2624033,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.0472441,
					sizeY = 0.3290985,
					image = "ty#xx",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xx5",
					varName = "star5",
					posX = 0.3236213,
					posY = 0.2624033,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.0472441,
					sizeY = 0.3290985,
					image = "ty#xx",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "rwmc2",
					varName = "task_count",
					posX = 0.9194536,
					posY = 0.4999999,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1429939,
					sizeY = 0.6326435,
					text = "x5",
					color = "FF966856",
					fontSize = 26,
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
