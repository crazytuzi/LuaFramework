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
			name = "liwu",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.13125,
			sizeY = 0.3430555,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "db",
				varName = "bg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "ptbj#tmk",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "mzd",
				varName = "name_icon",
				posX = 0.5,
				posY = 0.5561958,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.922619,
				sizeY = 0.1214575,
				image = "ptbj#top1",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "djk",
				varName = "rank",
				posX = 0.4950073,
				posY = 0.7886871,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.5059524,
				sizeY = 0.3441296,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt",
					varName = "icon",
					posX = 0.4935085,
					posY = 0.5171589,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8365975,
					sizeY = 0.839637,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl",
					varName = "count",
					posX = 0.5559036,
					posY = 0.1988106,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7118073,
					sizeY = 0.7023789,
					text = "x10",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz",
				varName = "item_name",
				posX = 0.5,
				posY = 0.5561958,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9089951,
				sizeY = 0.25,
				text = "道具名称",
				color = "FF966856",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "ms",
				varName = "des",
				posX = 0.4899326,
				posY = 0.3584208,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9115148,
				sizeY = 0.2989111,
				text = "赠送后，该玩家获得100点人气值",
				color = "FF966856",
				fontSize = 18,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "btn",
				varName = "send_btn",
				posX = 0.5,
				posY = 0.1436375,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.625,
				sizeY = 0.1740891,
				image = "qymm#zs",
				imageNormal = "qymm#zs",
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "btnz",
					varName = "send_text",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.036137,
					sizeY = 1.294361,
					text = "赠送",
					color = "FF966856",
					fontSize = 22,
					fontOutlineEnable = true,
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
