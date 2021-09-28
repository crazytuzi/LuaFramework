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
			name = "lbjd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2797076,
			sizeY = 0.4402778,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "a",
				posX = 0.4859464,
				posY = 0.6390712,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9614763,
				sizeY = 0.7218578,
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tb2",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.9397968,
				sizeY = 0.9805555,
				scale9Left = 0.3,
				scale9Right = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "da",
					posX = 0.1230235,
					posY = 0.6570084,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1337409,
					sizeY = 0.5436949,
					image = "slz#djd",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "rm3",
						varName = "need_lvl",
						posX = 0.4956787,
						posY = 0.2340659,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.073335,
						sizeY = 0.4266595,
						text = "55",
						fontSize = 22,
						fontOutlineColor = "FF14332E",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "smd",
					varName = "nameImg",
					posX = 0.5503465,
					posY = 0.6260344,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6716766,
					sizeY = 0.7270712,
					image = "slz#zx",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "rm6",
				varName = "join_time",
				posX = 0.5473154,
				posY = 0.05720621,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8506228,
				sizeY = 0.1542647,
				text = "时间段1",
				color = "FF1F9400",
				fontSize = 24,
				fontOutlineColor = "FF102E21",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "bm",
				varName = "join",
				posX = 0.5473155,
				posY = 0.1921407,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.4189643,
				sizeY = 0.1794844,
				image = "chu1#an2",
				imageNormal = "chu1#an2",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "bmz",
					varName = "join_text",
					posX = 0.5,
					posY = 0.5454545,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8680274,
					sizeY = 0.8176304,
					text = "报 名",
					fontSize = 24,
					fontOutlineEnable = true,
					fontOutlineColor = "FF347468",
					fontOutlineSize = 2,
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
