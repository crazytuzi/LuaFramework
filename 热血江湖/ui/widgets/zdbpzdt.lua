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
			name = "lbt",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2096,
			sizeY = 0.07638889,
		},
		children = {
		{
			prop = {
				etype = "Label",
				name = "w",
				varName = "name",
				posX = 0.5176501,
				posY = 0.6552483,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7465801,
				sizeY = 0.7795094,
				text = "龙运之柱金",
				color = "FFFFECBD",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jd",
				posX = 0.5039018,
				posY = 0.1950422,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5950278,
				sizeY = 0.3636364,
			},
			children = {
			{
				prop = {
					etype = "LoadingBar",
					name = "jdt",
					varName = "bar",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.613095,
					sizeY = 0.8999999,
					image = "zd#xt3",
					percent = 10,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "wk",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.613095,
					sizeY = 0.8999999,
					image = "zd#xk3",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "w1",
					varName = "percentLabel",
					posX = 0.5,
					posY = 0.5002053,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9261635,
					sizeY = 1.831331,
					text = "10/100",
					fontSize = 18,
					fontOutlineEnable = true,
					fontOutlineColor = "FF112E39",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jin",
				varName = "icon",
				posX = 0.07579284,
				posY = 0.6552479,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1192748,
				sizeY = 0.5818182,
				image = "bpzd#jin",
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
