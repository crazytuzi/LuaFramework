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
			sizeX = 0.4146698,
			sizeY = 0.1374808,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "jdd",
				varName = "loading_root",
				posX = 0.5931317,
				posY = 0.1654551,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8007124,
				sizeY = 0.3232774,
				image = "chu1#jdd",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
			},
			children = {
			{
				prop = {
					etype = "LoadingBar",
					name = "djt",
					varName = "loadingbar",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9647058,
					sizeY = 0.6250001,
					image = "tong#jdt",
					percent = 80,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sld",
					varName = "name",
					posX = 0.3539512,
					posY = 2.199252,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5806663,
					sizeY = 2.283212,
					text = "一阶：元力",
					color = "FF966856",
					fontSize = 24,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sld2",
					varName = "text",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4729597,
					sizeY = 2.283212,
					text = "100、2000",
					fontOutlineEnable = true,
					fontOutlineColor = "FF5B7838",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "djk",
					varName = "itemBg",
					posX = -0.1186242,
					posY = 1.457712,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2211764,
					sizeY = 2.9375,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "jt1",
						varName = "itemIcon",
						posX = 0.5,
						posY = 0.5255376,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8,
						sizeY = 0.8,
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
