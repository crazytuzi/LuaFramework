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
			name = "zmcyt",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.3007813,
			sizeY = 0.1708333,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "cyd",
				varName = "bg_image",
				posX = 0.4376624,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8961037,
				sizeY = 1.00813,
				image = "wj#tz1",
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "gq1",
				varName = "floorImg",
				posX = 0.277776,
				posY = 0.508,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3428571,
				sizeY = 0.8866668,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "gqt",
					varName = "level_bg",
					posX = 0.378989,
					posY = 0.5366135,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7381474,
					sizeY = 0.9169266,
					image = "wj#qz1",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an1",
					varName = "floor_btn",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8425944,
					sizeY = 0.7446379,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo1",
					varName = "suo",
					posX = 0.4620091,
					posY = 0.3736836,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4217985,
					sizeY = 0.4859711,
					image = "wj#suo",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "smd",
					posX = 0.4164198,
					posY = 0.1459759,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.244247,
					sizeY = 0.4197738,
					image = "d#tyd",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "tj1",
						varName = "floor_power",
						posX = 0.5,
						posY = 0.2573959,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.160719,
						sizeY = 1.400143,
						text = "战力：685487",
						color = "FFC00000",
						fontOutlineEnable = true,
						fontOutlineColor = "FFFFFFFF",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "gmz1",
						varName = "floor_text",
						posX = 0.5,
						posY = 0.7300742,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.028993,
						sizeY = 1.260402,
						text = "第一关",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FF27221D",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jt",
					varName = "showselect",
					posX = 0.3635974,
					posY = 1.256643,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4745233,
					sizeY = 0.6876949,
					image = "wj#jt",
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
