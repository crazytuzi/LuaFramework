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
			sizeX = 0.4382812,
			sizeY = 0.1138889,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dj1",
				varName = "item_bg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9982176,
				sizeY = 0.8902438,
				image = "jingmai#lbt",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "sl",
					varName = "des",
					posX = 0.1882915,
					posY = 0.3010619,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3346028,
					sizeY = 0.5072681,
					text = "成功率：100%",
					color = "FFF1E9D7",
					fontSize = 18,
					fontOutlineEnable = true,
					fontOutlineColor = "FFA47848",
					fontOutlineSize = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl2",
					varName = "name",
					posX = 0.1882915,
					posY = 0.6435276,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3346028,
					sizeY = 0.5072681,
					text = "标题",
					color = "FFF1E9D7",
					fontSize = 18,
					fontOutlineEnable = true,
					fontOutlineColor = "FFA47848",
					fontOutlineSize = 2,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "buf1",
				posX = 0.3655983,
				posY = 0.495962,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2493013,
				sizeY = 0.950325,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tu1",
					varName = "bg1",
					posX = 0.2492992,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					lockHV = true,
					sizeX = 0.5640765,
					sizeY = 1.01018,
					image = "zdjn#bai",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "buft",
					varName = "icon1",
					posX = 0.2778993,
					posY = 0.4999998,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3861059,
					sizeY = 0.7186244,
					image = "jingmai#buff1",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "jl1",
					varName = "des1",
					posX = 0.72846,
					posY = 0.6348175,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4714926,
					sizeY = 0.5269492,
					text = "buff1",
					color = "FF966856",
					fontSize = 18,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn1",
					varName = "btn1",
					posX = 0.2910417,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6357509,
					sizeY = 0.9331763,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "jl4",
					varName = "value1",
					posX = 0.7730203,
					posY = 0.3270066,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5606132,
					sizeY = 0.5269492,
					text = "buff1",
					color = "FFF1E9D7",
					fontSize = 16,
					fontOutlineEnable = true,
					fontOutlineColor = "FFA47848",
					fontOutlineSize = 2,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "buf2",
				posX = 0.6190879,
				posY = 0.4959616,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2493013,
				sizeY = 0.950325,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tu2",
					varName = "bg2",
					posX = 0.2492992,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					lockHV = true,
					sizeX = 0.5640765,
					sizeY = 1.01018,
					image = "zdjn#bai",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "buft2",
					varName = "icon2",
					posX = 0.2778993,
					posY = 0.4999998,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3861059,
					sizeY = 0.7186244,
					image = "jingmai#buff2",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "jl2",
					varName = "des2",
					posX = 0.72846,
					posY = 0.6348178,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4714926,
					sizeY = 0.5269492,
					text = "buff1",
					color = "FF966856",
					fontSize = 18,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn2",
					varName = "btn2",
					posX = 0.2910417,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6357509,
					sizeY = 0.9331763,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "jl5",
					varName = "value2",
					posX = 0.7964286,
					posY = 0.327007,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6074297,
					sizeY = 0.5269492,
					text = "buff1",
					color = "FFF1E9D7",
					fontSize = 16,
					fontOutlineEnable = true,
					fontOutlineColor = "FFA47848",
					fontOutlineSize = 2,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "buf3",
				posX = 0.8725774,
				posY = 0.4959616,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2493013,
				sizeY = 0.950325,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tu3",
					varName = "bg3",
					posX = 0.2492992,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					lockHV = true,
					sizeX = 0.5640765,
					sizeY = 1.01018,
					image = "zdjn#bai",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "buft3",
					varName = "icon3",
					posX = 0.2778993,
					posY = 0.4999998,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3861059,
					sizeY = 0.7186244,
					image = "jingmai#buff3",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "jl3",
					varName = "des3",
					posX = 0.72846,
					posY = 0.6348178,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4714926,
					sizeY = 0.5269492,
					text = "buff1",
					color = "FF966856",
					fontSize = 18,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn3",
					varName = "btn3",
					posX = 0.2910417,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6357509,
					sizeY = 0.9331763,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "jl6",
					varName = "value3",
					posX = 0.8519617,
					posY = 0.327007,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.718496,
					sizeY = 0.5269492,
					text = "buff1",
					color = "FFF1E9D7",
					fontSize = 16,
					fontOutlineEnable = true,
					fontOutlineColor = "FFA47848",
					fontOutlineSize = 2,
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
