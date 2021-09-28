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
			etype = "Image",
			name = "lbdt1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.6921875,
			sizeY = 0.1666667,
			image = "b#lbt",
			scale9 = true,
			scale9Left = 0.2,
			scale9Right = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "detail_btn",
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
				etype = "Label",
				name = "lbtz1",
				varName = "name_label",
				posX = 0.2033566,
				posY = 0.8131302,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3160873,
				sizeY = 0.5047162,
				text = "玩家名字七个字评论：",
				color = "FF966856",
				fontSize = 22,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "lbtz5",
				varName = "nodeTxt",
				posX = 0.3889923,
				posY = 0.3205239,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6873586,
				sizeY = 0.7092952,
				text = "这里写的是八十个字啊这里写的是八十个字啊这里写的是八十个字啊这里写的是八十个字啊这里写的是八十个字啊这里写的是八十个字啊这里写的是八十个字啊这里写的是八十个字啊",
				color = "FF966856",
				fontOutlineColor = "FF0E3B2F",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "lba2",
				varName = "flowerBtn",
				posX = 0.8111242,
				posY = 0.5249639,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.03837472,
				sizeY = 0.3499999,
				image = "bgb#zan",
				imageNormal = "bgb#zan",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "lba3",
				varName = "brickBtn",
				posX = 0.928313,
				posY = 0.5249639,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.03837472,
				sizeY = 0.2416666,
				image = "bgb#cai",
				imageNormal = "bgb#cai",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "lbtz6",
				varName = "flowerNum",
				posX = 0.8111243,
				posY = 0.1924036,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1932645,
				sizeY = 0.3166076,
				text = "333333",
				color = "FF966856",
				fontOutlineColor = "FF0E3B2F",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "lbtz7",
				varName = "brickNum",
				posX = 0.928313,
				posY = 0.1924036,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1932645,
				sizeY = 0.3166076,
				text = "333333",
				color = "FF966856",
				fontOutlineColor = "FF0E3B2F",
				hTextAlign = 1,
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
