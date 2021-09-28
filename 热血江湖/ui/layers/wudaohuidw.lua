--version = 1
local l_fileType = "layer"

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
			name = "ddd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			image = "b#dd",
			scale9 = true,
			scale9Left = 0.1,
			scale9Right = 0.1,
			scale9Top = 0.1,
			scale9Bottom = 0.1,
			alpha = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dd",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "ysjm",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.7,
			sizeY = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.195816,
				sizeY = 0.6267928,
				scale9 = true,
				scale9Left = 0.41,
				scale9Right = 0.37,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "wk",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7186515,
					sizeY = 0.7280703,
					image = "wdh#db",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.2,
					scale9Bottom = 0.7,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lb",
						varName = "teamScroll",
						posX = 0.5,
						posY = 0.42586,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9875608,
						sizeY = 0.8153581,
						showScrollBar = false,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "mz",
						varName = "name",
						posX = 0.2359435,
						posY = 0.9124104,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3363025,
						sizeY = 0.25,
						text = "战队名字",
						color = "FFFFE013",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "mz2",
						varName = "state",
						posX = 0.4563891,
						posY = 0.9124104,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3363025,
						sizeY = 0.25,
						text = "状态",
						color = "FF36E7B3",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "mz3",
						varName = "score",
						posX = 0.6768346,
						posY = 0.9124104,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3363025,
						sizeY = 0.25,
						text = "积分1",
						color = "FFFFE013",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "zj",
						varName = "recordBtn",
						posX = 0.03193557,
						posY = 0.9384496,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.06363637,
						sizeY = 0.2173913,
						image = "wdh#dw",
						imageNormal = "wdh#dw",
						disablePressScale = true,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "mz4",
						varName = "honor",
						posX = 0.8972801,
						posY = 0.9124104,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3363025,
						sizeY = 0.25,
						text = "积分1",
						color = "FFFFE013",
						vTextAlign = 1,
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "bgBtn",
				posX = 0.9100397,
				posY = 0.7020457,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.04241071,
				sizeY = 0.07539683,
				image = "wdh#gb",
				imageNormal = "wdh#gb",
				disablePressScale = true,
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
