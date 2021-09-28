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
			etype = "Grid",
			name = "jd1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			layoutType = 3,
			layoutTypeW = 3,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "da",
				posX = 0.444621,
				posY = 0.1877711,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4382812,
				sizeY = 0.07777778,
				image = "ts#dw",
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "wb",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.082799,
					sizeY = 1.088929,
					text = "任务变身中，请尽快完成任务！",
					color = "FFFFFC10",
					fontSize = 24,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hua",
					posX = 0.1085579,
					posY = 0.4377054,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.0623886,
					sizeY = 0.6607143,
					image = "ts#tsd",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "th",
						posX = 0.5,
						posY = 0.635135,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4285714,
						sizeY = 1.135135,
						image = "ts#th",
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
	tanhao = {
		th = {
			scale = {{0, {0.9, 0.9, 1}}, {350, {1.1, 1.1, 1}}, {700, {0.9, 0.9, 1}}, },
		},
	},
	c_dakai = {
		{0,"tanhao", -1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
