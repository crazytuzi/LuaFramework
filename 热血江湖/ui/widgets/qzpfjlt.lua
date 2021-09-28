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
			sizeX = 0.7136802,
			sizeY = 0.1527778,
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
				sizeY = 0.88,
				scale9 = true,
				scale9Left = 0.1,
				scale9Right = 0.1,
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
					sizeY = 1.126033,
					image = "b#lbt",
					scale9 = true,
					scale9Left = 0.3,
					scale9Right = 0.6,
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
					posX = 0.2098632,
					posY = 0.3194442,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3461982,
					sizeY = 0.2903454,
					scale9 = true,
					scale9Left = 0.2,
					scale9Right = 0.7,
					alpha = 0.7,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "zz1",
						varName = "attribute1",
						posX = 0.5707353,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4548171,
						sizeY = 1.129736,
						text = "气血",
						color = "FF966856",
						fontOutlineColor = "FF27221D",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sx1",
						varName = "value1",
						posX = 0.8746299,
						posY = 0.4999994,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4548171,
						sizeY = 1.129736,
						text = "+1234",
						color = "FF76D646",
						fontOutlineEnable = true,
						fontOutlineColor = "FF5B7838",
						fontOutlineSize = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "qx",
						varName = "property_icon1",
						posX = 0.2476081,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1580999,
						sizeY = 1.565533,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "mjd",
					posX = 0.1896553,
					posY = 0.7087712,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2222196,
					sizeY = 0.3125,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "tj1",
						varName = "title",
						posX = 1.470736,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 2.828698,
						sizeY = 1.408946,
						text = "全身强化 +10",
						color = "FF966856",
						fontSize = 22,
						fontOutlineColor = "FFA47848",
						fontOutlineSize = 2,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dbj2",
					posX = 0.6172919,
					posY = 0.3194441,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3461982,
					sizeY = 0.2903454,
					scale9 = true,
					scale9Left = 0.2,
					scale9Right = 0.7,
					alpha = 0.7,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "zz2",
						varName = "attribute2",
						posX = 0.5707353,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4548171,
						sizeY = 1.129736,
						text = "气血",
						color = "FF966856",
						fontOutlineColor = "FF27221D",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sx2",
						varName = "value2",
						posX = 0.8746295,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4548171,
						sizeY = 1.129736,
						text = "+1234",
						color = "FF76D646",
						fontOutlineEnable = true,
						fontOutlineColor = "FF5B7838",
						fontOutlineSize = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "qx2",
						varName = "property_icon2",
						posX = 0.2444462,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1580999,
						sizeY = 1.565533,
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "ydc",
				varName = "isReach",
				posX = 0.8857873,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1806219,
				sizeY = 0.8909089,
				image = "sui#ydc",
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
