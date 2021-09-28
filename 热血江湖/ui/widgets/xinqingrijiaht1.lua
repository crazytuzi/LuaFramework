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
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2,
			sizeY = 0.1041667,
		},
		children = {
		{
			prop = {
				etype = "Grid",
				name = "mr",
				varName = "hobby_item",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dw",
					varName = "background",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					image = "ptbj#tmk",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "gxd",
					posX = 0.1217107,
					posY = 0.4866858,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1757813,
					sizeY = 0.5999998,
					image = "xqrj#gxd",
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "gxan",
						varName = "choose_btn",
						posX = 2.629731,
						posY = 0.558913,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 5.54668,
						sizeY = 1.493323,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "dj",
						varName = "tick",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.9999998,
						sizeY = 1,
						image = "xqrj#dg",
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mz",
					varName = "desc",
					posX = 0.5390623,
					posY = 0.4999996,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.7373299,
					text = "狮子座",
					fontSize = 24,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "sc",
					varName = "delete_btn",
					posX = 0.9094946,
					posY = 0.7130511,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1559992,
					sizeY = 0.5324771,
					disablePressScale = true,
					propagateToChildren = true,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "zan",
						posX = 0.6752814,
						posY = 0.6752814,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5008039,
						sizeY = 0.5008038,
						image = "xqrj#sc",
						imageNormal = "xqrj#sc",
						disablePressScale = true,
						disableClick = true,
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "xz",
				varName = "add_hobby",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dw2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					image = "xqrj#jia",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mz2",
					posX = 0.6051622,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.7373299,
					text = "自定义",
					color = "FF966856",
					fontSize = 24,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gxan2",
					varName = "add_btn",
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
