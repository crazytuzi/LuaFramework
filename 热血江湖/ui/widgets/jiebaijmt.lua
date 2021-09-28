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
			sizeX = 0.4421875,
			sizeY = 0.1305556,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "lbt",
				varName = "bg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "jiebai#t2",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.6,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "bq",
				posX = 0.05973757,
				posY = 0.4790534,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.06360424,
				sizeY = 0.8085104,
				image = "jiebai#hb",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "cwz",
					varName = "rankText",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.009875,
					sizeY = 1.097458,
					text = "老大",
					color = "FFFFF335",
					fontSize = 22,
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
				posX = 0.1727896,
				posY = 0.3755218,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1746426,
				sizeY = 0.8441185,
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
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz",
				varName = "roleName",
				posX = 0.445861,
				posY = 0.641416,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3607466,
				sizeY = 1.023526,
				text = "名字最长七个字",
				color = "FFFFF335",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz2",
				varName = "activity",
				posX = 0.5183298,
				posY = 0.2714088,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3607466,
				sizeY = 1.023526,
				text = "活跃度：88",
				color = "FFFFF335",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zy",
				varName = "profession",
				posX = 0.2864737,
				posY = 0.2714086,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.06183746,
				sizeY = 0.3723403,
				image = "zy#daoke",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "cw1",
				varName = "swornName",
				posX = 0.7025842,
				posY = 0.4999996,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3621489,
				sizeY = 0.8381116,
				text = "葫芦娃三娃",
				color = "FFFFF335",
				fontSize = 22,
				fontOutlineEnable = true,
				fontOutlineColor = "FF66628C",
				fontOutlineSize = 2,
				hTextAlign = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "xg2",
				varName = "changeBtn",
				posX = 0.9436126,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.09010601,
				sizeY = 0.542553,
				image = "bgb#xg",
				imageNormal = "bgb#xg",
				disablePressScale = true,
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
