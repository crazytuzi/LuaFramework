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
			name = "xjd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.709375,
			sizeY = 0.6378398,
			scale9 = true,
			scale9Left = 0.45,
			scale9Right = 0.45,
			scale9Top = 0.45,
			scale9Bottom = 0.45,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "d",
				posX = 0.5000001,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9988998,
				sizeY = 0.8625783,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "xt1",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.001101,
					sizeY = 1.342978,
					image = "opppbanner#oppobanner",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "xwb1",
						varName = "title",
						posX = 0.3669565,
						posY = 0.7037849,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7048125,
						sizeY = 0.5871726,
						text = "每月累计充值元宝达到指定数量即可领取超级福利",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FF404000",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
						colorTL = "FFFFFFDD",
						colorTR = "FFFFFFDD",
						colorBR = "FFFFEA00",
						colorBL = "FFFFEA00",
						useQuadColor = true,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "xwb2",
						posX = 0.221472,
						posY = 0.6370474,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3945876,
						sizeY = 0.4044117,
						text = "累计充值金额：",
						fontOutlineEnable = true,
						fontOutlineColor = "FF808000",
						fontOutlineSize = 2,
						vTextAlign = 1,
						colorTL = "FFFFAF93",
						colorTR = "FFFFAF93",
						colorBR = "FFFF0000",
						colorBL = "FFFF0000",
						useQuadColor = true,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "xwb3",
						varName = "coinNum",
						posX = 0.4868559,
						posY = 0.6407989,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6,
						sizeY = 0.4044117,
						text = "xxx元宝",
						fontOutlineEnable = true,
						fontOutlineColor = "FF808000",
						fontOutlineSize = 2,
						vTextAlign = 1,
						colorTL = "FFFFAF93",
						colorTR = "FFFFAF93",
						colorBR = "FFFF0000",
						colorBL = "FFFF0000",
						useQuadColor = true,
					},
				},
				{
					prop = {
						etype = "Scroll",
						name = "xlb",
						varName = "scroll",
						posX = 0.4967009,
						posY = 0.2932932,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9434446,
						sizeY = 0.5699353,
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
