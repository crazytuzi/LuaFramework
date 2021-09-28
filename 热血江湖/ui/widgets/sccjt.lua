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
			varName = "node",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.4867187,
			sizeY = 0.1882175,
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
				sizeX = 1,
				sizeY = 0.92,
				image = "b#d5",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
				alpha = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "wwcd",
					varName = "bg",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tzjlt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dbj",
					posX = 0.2727667,
					posY = 0.305856,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4441088,
					sizeY = 0.2638889,
					scale9 = true,
					scale9Left = 0.2,
					scale9Right = 0.6,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "zz1",
						varName = "attribute1",
						posX = 0.4538533,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4548171,
						sizeY = 1.129736,
						text = "气血气血",
						color = "FF966856",
						fontOutlineColor = "FF404040",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sx1",
						varName = "value1",
						posX = 0.6975105,
						posY = 0.4999994,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4040627,
						sizeY = 1.129736,
						text = "+1234",
						color = "FFF1E9D7",
						fontOutlineEnable = true,
						fontOutlineColor = "FFA47848",
						fontOutlineSize = 2,
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "qx",
						varName = "property_icon1",
						posX = 0.153859,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.146112,
						sizeY = 1.131579,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xian",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.95,
					sizeY = 0.01475834,
					image = "b#xian",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "mjd",
					posX = 0.3013275,
					posY = 0.7149274,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5414517,
					sizeY = 0.2569444,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "tj1",
						varName = "title",
						posX = 1.069793,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 2.026811,
						sizeY = 1.408946,
						text = "6个宠物突破技能达到1级",
						color = "FF65944D",
						fontSize = 22,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dbj2",
					varName = "item_bg2",
					posX = 0.7327834,
					posY = 0.305856,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4441088,
					sizeY = 0.2638889,
					scale9 = true,
					scale9Left = 0.2,
					scale9Right = 0.6,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "zz2",
						varName = "attribute2",
						posX = 0.4538533,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4548171,
						sizeY = 1.129736,
						text = "气血",
						color = "FF966856",
						fontOutlineColor = "FF404040",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sx2",
						varName = "value2",
						posX = 0.6975105,
						posY = 0.4999994,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4040627,
						sizeY = 1.129736,
						text = "+1234",
						color = "FFF1E9D7",
						fontOutlineEnable = true,
						fontOutlineColor = "FFA47848",
						fontOutlineSize = 2,
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "qx2",
						varName = "property_icon2",
						posX = 0.153859,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.146112,
						sizeY = 1.131579,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "wc1",
					varName = "icon",
					posX = 0.8217537,
					posY = 0.6108696,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2648475,
					sizeY = 0.7231587,
					image = "sui#ydc",
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
