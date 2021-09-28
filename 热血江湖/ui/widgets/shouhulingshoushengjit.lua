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
			name = "shengji",
			varName = "upgradeRoot",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.0859375,
			sizeY = 0.1694444,
			scale9 = true,
			scale9Top = 0.3,
			scale9Bottom = 0.3,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "wpk5",
				varName = "bg",
				posX = 0.5,
				posY = 0.5983604,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.7727273,
				sizeY = 0.6967215,
				image = "djk#kbai",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "wp5",
					varName = "icon",
					posX = 0.5,
					posY = 0.5427376,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7960408,
					sizeY = 0.7786804,
					image = "items#xueping1.png",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dw5",
					posX = 0.4861749,
					posY = 0.1873567,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8597251,
					sizeY = 0.2933058,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "lj5",
						varName = "value",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.278572,
						sizeY = 1.91113,
						text = "1000",
						fontOutlineEnable = true,
						hTextAlign = 1,
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
				name = "an6",
				varName = "btn",
				posX = 0.5,
				posY = 0.53684,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8652516,
				sizeY = 0.842837,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "mojid5",
				varName = "count5Root",
				posX = 0.5,
				posY = 0.1529041,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9849878,
				sizeY = 0.3367422,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "sl5",
					varName = "count",
					posX = 0.5,
					posY = 0.4999993,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.157398,
					sizeY = 1.096285,
					text = "15",
					color = "FF4C3612",
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
