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
			posX = 0.5028733,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.7179689,
			sizeY = 0.2054466,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an3",
				varName = "btn",
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
				name = "bplbt",
				posX = 0.5,
				posY = 0.3613606,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.722721,
				image = "b#lbt",
				scale9 = true,
				scale9Left = 0.2,
				scale9Right = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "id",
					posX = 0.04738127,
					posY = 0.8807352,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.08509631,
					sizeY = 0.152716,
					text = "99",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "id2",
					posX = 0.1809542,
					posY = 0.7177013,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2650706,
					sizeY = 0.4456149,
					text = "参与总次数：",
					color = "FF43261D",
					fontSize = 22,
					fontOutlineColor = "FF0E2620",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "id3",
					posX = 0.4280974,
					posY = 0.8726215,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.1361806,
					sizeY = 0.2501273,
					text = "我的名字很长啊",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "id4",
					varName = "enterLabel",
					posX = 0.2771108,
					posY = 0.6989934,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1249306,
					sizeY = 0.5342133,
					text = "1500",
					color = "FF008000",
					fontSize = 24,
					fontOutlineColor = "FF27221D",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "id5",
					varName = "probaLabel",
					posX = 0.629572,
					posY = 0.6989934,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1476649,
					sizeY = 0.5342133,
					text = "200%",
					color = "FFFF1901",
					fontSize = 24,
					fontOutlineColor = "FF27221D",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "id6",
					posX = 0.5107924,
					posY = 0.6989935,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.106663,
					sizeY = 0.5342133,
					text = "胜率：",
					color = "FF43261D",
					fontSize = 24,
					fontOutlineColor = "FF0E2620",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "ms",
					posX = 0.1809542,
					posY = 0.2910349,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2650706,
					sizeY = 0.4456149,
					text = "单日获得积分：",
					color = "FF43261D",
					fontSize = 22,
					fontOutlineColor = "FF0E2620",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "id7",
					varName = "rankLabel",
					posX = 0.2771108,
					posY = 0.2816808,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1249306,
					sizeY = 0.5342133,
					text = "1500",
					color = "FF008000",
					fontSize = 24,
					fontOutlineColor = "FF27221D",
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "smd",
				posX = 0.1579087,
				posY = 0.8442199,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3025027,
				sizeY = 0.2163309,
				image = "cl2#dw2",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tot",
				varName = "nameLabel",
				posX = 0.232305,
				posY = 0.8527963,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4187496,
				sizeY = 0.3275083,
				text = "本服4v4jingjic",
				color = "FF43261D",
				fontSize = 24,
				fontOutlineColor = "FF102E21",
				vTextAlign = 1,
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
