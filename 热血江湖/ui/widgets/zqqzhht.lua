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
			sizeX = 0.265625,
			sizeY = 0.5277778,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "bjt",
				posX = 0.5,
				posY = 0.5763163,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 1.274367,
				sizeY = 1.033328,
				image = "zqbj#zqbj",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "top",
				posX = 0.5,
				posY = 0.2503791,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7647059,
				sizeY = 0.1421053,
				image = "zqqz#mzd",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "mz",
					varName = "name",
					posX = 0.5,
					posY = 0.4215689,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9319838,
					sizeY = 1.142969,
					text = "发起名字",
					color = "FFAFF8F1",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FF084A64",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gm",
				varName = "unlockBtn",
				posX = 0.5,
				posY = 0.1158801,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.4264706,
				sizeY = 0.1447368,
				image = "chu1#an2",
				imageNormal = "chu1#an2",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "gmz",
					varName = "lockBtnText",
					posX = 0.5,
					posY = 0.5153604,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9493306,
					sizeY = 0.8995697,
					text = "解 锁",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FF347468",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xhd",
					varName = "lockRed",
					posX = 0.8977249,
					posY = 0.8270545,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.1862069,
					sizeY = 0.5090911,
					image = "zdte#hd",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "sy",
				varName = "useBtn",
				posX = 0.5,
				posY = 0.1158801,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.4264706,
				sizeY = 0.1447368,
				image = "chu1#an1",
				imageNormal = "chu1#an1",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "syz",
					varName = "useText",
					posX = 0.5,
					posY = 0.5153604,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9493306,
					sizeY = 0.8995697,
					text = "使 用",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FFB35F1D",
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
				name = "jswz",
				varName = "lockTxt",
				posX = 0.5,
				posY = 0.1233606,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9108652,
				sizeY = 0.25,
				text = "什么什么解锁",
				color = "FFC93034",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "shi",
				varName = "inUse",
				posX = 0.4823528,
				posY = 0.1184593,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.6117647,
				sizeY = 0.1894737,
				image = "zqqz#syz",
			},
		},
		{
			prop = {
				etype = "Sprite3D",
				name = "mx",
				varName = "modle",
				posX = 0.5,
				posY = 0.4828499,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6692937,
				sizeY = 0.6548375,
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
