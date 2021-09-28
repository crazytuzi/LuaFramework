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
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.7101563,
			sizeY = 0.6378398,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				varName = "CZSL",
				posX = 0.8814176,
				posY = 0.4978225,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2400881,
				sizeY = 1.171489,
				image = "czhd1#dt",
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "hdd",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.9999999,
				sizeY = 1.167134,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "lbdd",
					posX = 0.3945615,
					posY = 0.472055,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7292741,
					sizeY = 0.7711114,
					image = "czhd#dc",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
			},
			},
		},
		{
			prop = {
				etype = "Scroll",
				name = "lb2",
				varName = "ExchangeGiftList",
				posX = 0.394431,
				posY = 0.4706551,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7257193,
				sizeY = 0.8891245,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "lht",
				posX = 0.9146512,
				posY = 0.553309,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3623348,
				sizeY = 1.315203,
				image = "czhdlh#lh1",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "ysz2",
				posX = 0.8817759,
				posY = 0.189498,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2486248,
				sizeY = 0.5313072,
				image = "czhd1#db",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "z2",
					varName = "ActivitiesTime",
					posX = 0.747754,
					posY = 0.5118182,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4977021,
					sizeY = 0.2895346,
					text = "800分钟",
					color = "FFF6C07F",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "aa",
					posX = 0.5,
					posY = 0.864135,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8741778,
					sizeY = 0.1229508,
					image = "caishendao#db",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "z4",
						posX = 0.5,
						posY = 0.5090004,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7316574,
						sizeY = 1.093873,
						text = "在线时长",
						color = "FFF6C07F",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z3",
					posX = 0.3345965,
					posY = 0.5118228,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7316571,
					sizeY = 0.2895345,
					text = "当前已在线",
					color = "FFF6C07F",
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
