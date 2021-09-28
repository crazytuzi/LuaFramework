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
			name = "lbdt3",
			posX = 0.5,
			posY = 0.4973999,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.7542292,
			sizeY = 0.1263889,
			image = "b#lbt",
			scale9 = true,
			scale9Left = 0.2,
			scale9Right = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dw",
				posX = 0.7065467,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.003107477,
				sizeY = 0.888,
				image = "b#shuxian",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "lbtz7",
				varName = "name_label",
				posX = 0.204328,
				posY = 0.4890108,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1839504,
				sizeY = 0.5647206,
				text = "我的名字很长啊",
				color = "FF966856",
				fontSize = 22,
				fontOutlineColor = "FF102E21",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "lbtz10",
				varName = "power_label",
				posX = 0.3876897,
				posY = 0.489011,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1447881,
				sizeY = 0.5520709,
				text = "9999999",
				color = "FF966856",
				fontSize = 22,
				fontOutlineColor = "FF102E21",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "lbtz11",
				varName = "job_label",
				posX = 0.5736592,
				posY = 0.489011,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1755211,
				sizeY = 0.5520703,
				text = "药师",
				color = "FF966856",
				fontSize = 22,
				fontOutlineColor = "FF102E21",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "lba3",
				varName = "agree_btn",
				posX = 0.7834777,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1274066,
				sizeY = 0.6373625,
				image = "chu1#an3",
				imageNormal = "chu1#an3",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "anz7",
					posX = 0.5,
					posY = 0.5517241,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8401152,
					sizeY = 1.00501,
					text = "同 意",
					fontSize = 24,
					fontOutlineEnable = true,
					fontOutlineColor = "FF1C7760",
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
				name = "lba4",
				varName = "refuse_btn",
				posX = 0.9160064,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1274066,
				sizeY = 0.6373625,
				image = "chu1#an4",
				imageNormal = "chu1#an4",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "anz8",
					posX = 0.5,
					posY = 0.5517241,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8401152,
					sizeY = 1.00501,
					text = "拒绝",
					fontSize = 24,
					fontOutlineEnable = true,
					fontOutlineColor = "FF917029",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "txk",
				varName = "roleHeadBg",
				posX = 0.05432768,
				posY = 0.449702,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1032315,
				sizeY = 0.8791207,
				image = "zdtx#txd",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tx",
					varName = "headIcon",
					posX = 0.5054789,
					posY = 0.6925332,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7210885,
					sizeY = 1.110169,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "djd",
					posX = 0.8077809,
					posY = 0.2425532,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3511903,
					sizeY = 0.4375,
					image = "zdte#djd2",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "lbtz8",
				varName = "level_label",
				posX = 0.08596163,
				posY = 0.2247703,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05188559,
				sizeY = 0.4359249,
				text = "85",
				fontSize = 18,
				fontOutlineEnable = true,
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
