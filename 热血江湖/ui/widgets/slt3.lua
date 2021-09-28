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
			posY = 0.4884012,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.4,
			sizeY = 0.1431976,
		},
		children = {
		{
			prop = {
				etype = "Grid",
				name = "slt1",
				posX = 0.5,
				posY = 1,
				anchorX = 0.5,
				anchorY = 1,
				sizeX = 1,
				sizeY = 0.8341233,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "txk",
					varName = "txb_img",
					posX = 0.8856062,
					posY = 0.4559245,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2189817,
					sizeY = 1.041667,
					image = "zdtx#txd",
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "txa",
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
						name = "tx",
						varName = "icon",
						posX = 0.5054789,
						posY = 0.6925332,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7210885,
						sizeY = 1.110169,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "ltd",
					varName = "bg_img",
					posX = 0.4138609,
					posY = 0.8927908,
					anchorX = 0.5,
					anchorY = 1,
					sizeX = 0.78125,
					sizeY = 1.041667,
					image = "ltk#ltd",
					scale9 = true,
					scale9Top = 0.7,
					scale9Bottom = 0.2,
					flippedX = true,
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "wz",
					varName = "text",
					posX = 0.4239385,
					posY = 0.7767129,
					anchorX = 0.5,
					anchorY = 1,
					sizeX = 0.6551465,
					sizeY = 0.8246915,
					text = "dddddddddddddddddddddddddddddddddddddddddddd",
					color = "FF966856",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zsxia",
					varName = "downImg",
					posX = 0.121812,
					posY = -0.1502184,
					anchorX = 0.5,
					anchorY = 0,
					visible = false,
					sizeX = 0.2441406,
					sizeY = 1.186046,
					image = "ltk#xiongmaof",
					flippedX = true,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zsshang",
					varName = "upImg",
					posX = 0.121812,
					posY = 0.9079208,
					anchorX = 0.5,
					anchorY = 1,
					visible = false,
					sizeX = 0.2441406,
					sizeY = 1.186046,
					image = "ltk#gugujif",
					flippedX = true,
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
