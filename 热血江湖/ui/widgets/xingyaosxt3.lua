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
			posY = 0.506188,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2271474,
			sizeY = 0.06805556,
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
				sizeX = 0.9595917,
				sizeY = 1.020408,
				image = "xingpan#zld",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "top",
					posX = 0.3351267,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.125448,
					sizeY = 0.64,
					image = "tong#zl",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wz",
						varName = "power",
						posX = 3.454798,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 4.072445,
						sizeY = 1.262031,
						text = "12345",
						color = "FFFFE7AF",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FFB2722C",
						fontOutlineSize = 2,
						vTextAlign = 1,
					},
				},
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
	gy3 = {
	},
	gy2 = {
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
	gy15 = {
	},
	gy16 = {
	},
	gy17 = {
	},
	gy18 = {
	},
	gy19 = {
	},
	gy20 = {
	},
	gy21 = {
	},
	gy22 = {
	},
	gy23 = {
	},
	gy24 = {
	},
	gy25 = {
	},
	gy26 = {
	},
	gy27 = {
	},
	gy28 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
