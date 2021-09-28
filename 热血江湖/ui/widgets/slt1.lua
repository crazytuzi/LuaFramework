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
			posY = 0.4858365,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.4,
			sizeY = 0.1491602,
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
				sizeY = 0.8007796,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "txk",
					varName = "txb_img",
					posX = 0.08873767,
					posY = 0.4559245,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2189818,
					sizeY = 1.034483,
					image = "zdtx#txd",
				},
				children = {
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
				{
					prop = {
						etype = "Button",
						name = "txa",
						posX = 0.5,
						posY = 0.4729716,
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
					etype = "Image",
					name = "ltd",
					varName = "bg_img",
					posX = 0.5642614,
					posY = 0.846655,
					anchorX = 0.5,
					anchorY = 1,
					sizeX = 0.78125,
					sizeY = 1.034483,
					image = "ltk#ltd",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.7,
					scale9Bottom = 0.2,
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "wz",
					varName = "text",
					posX = 0.5494647,
					posY = 0.7385105,
					anchorX = 0.5,
					anchorY = 1,
					sizeX = 0.653738,
					sizeY = 0.8479866,
					text = "2131231",
					color = "FF966856",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zsxia",
					varName = "downImg",
					posX = 0.8567279,
					posY = -0.1974136,
					anchorX = 0.5,
					anchorY = 0,
					visible = false,
					sizeX = 0.2441406,
					sizeY = 1.186046,
					image = "ltk#xiongmaof",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zsxia2",
					varName = "upImg",
					posX = 0.8567279,
					posY = 0.8490975,
					anchorX = 0.5,
					anchorY = 1,
					visible = false,
					sizeX = 0.2441406,
					sizeY = 1.186046,
					image = "ltk#gugujif",
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
