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
			sizeX = 0.6813368,
			sizeY = 0.145854,
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
					name = "wc1",
					varName = "icon",
					posX = 0.4100464,
					posY = 0.5000001,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1255422,
					sizeY = 0.3848845,
				},
				children = {
				{
					prop = {
						etype = "RichText",
						name = "fwb",
						varName = "desc",
						posX = 0.6374617,
						posY = 0.5000283,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 2.671739,
						sizeY = 2.272442,
						text = "参与任意武会7次（4/7）",
						color = "FF7F4920",
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "mjd",
					posX = 0.1229716,
					posY = 0.4909221,
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
						posX = 0.7333786,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.285017,
						sizeY = 1.612365,
						text = "所向披靡",
						color = "FF8F61AC",
						fontSize = 24,
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
					posX = 0.8617619,
					posY = 0.5327669,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2688871,
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
						varName = "itemCount",
						posX = 0.6929753,
						posY = 0.4374685,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4909433,
						sizeY = 1.129736,
						text = "558",
						color = "FF966856",
						fontOutlineColor = "FF27221D",
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "qx2",
						varName = "itemIcon",
						posX = 0.5085166,
						posY = 0.387136,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.2212497,
						sizeY = 1.701605,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jxz",
					posX = 0.7494851,
					posY = 0.5453789,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1816209,
					sizeY = 0.3848845,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "xwb2",
						varName = "state",
						posX = 0.5772704,
						posY = 0.3820975,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.434204,
						sizeY = 1.299091,
						text = "进行中",
						color = "FFC00000",
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "ylq",
					posX = 0.8375744,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					lockHV = true,
					sizeX = 0.1737515,
					sizeY = 0.8570215,
					image = "gq#ylq",
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
