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
			name = "lb1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.6640624,
			sizeY = 0.09166667,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "tl",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.969697,
				image = "b#lbt",
				scale9 = true,
				scale9Left = 0.2,
				scale9Right = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "text2",
					varName = "name",
					posX = 0.2575636,
					posY = 0.5000007,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2,
					sizeY = 1,
					text = "名字最长七个字",
					color = "FF966856",
					fontSize = 22,
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "text3",
					varName = "factionOwnerName",
					posX = 0.4857316,
					posY = 0.4999999,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2,
					sizeY = 1,
					text = "名字最长七个字",
					color = "FF966856",
					fontSize = 22,
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "text4",
					varName = "value",
					posX = 0.7138996,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2,
					sizeY = 1,
					text = "999",
					color = "FFC93034",
					fontSize = 24,
					fontOutlineColor = "FFC00000",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an",
					posX = 0.8820089,
					posY = 0.5000405,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1411765,
					sizeY = 0.7002656,
					image = "chu1#an2",
					layoutType = 5,
					layoutTypeW = 5,
					imageNormal = "chu1#an2",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "jr",
						varName = "enterBtn",
						posX = 0.5,
						posY = 0.5446258,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 1,
						text = "进 入",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FF145A4F",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "text5",
					varName = "rankID",
					posX = 0.09138976,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2,
					sizeY = 1,
					text = "1",
					color = "FF966856",
					fontSize = 24,
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
