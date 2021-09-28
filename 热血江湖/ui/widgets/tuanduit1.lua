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
			name = "k",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1018599,
			sizeY = 0.2212117,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "btn",
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
				name = "kong",
				varName = "kong",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.9740707,
				sizeY = 0.9543397,
				image = "qds#db2",
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "db2",
					posX = 0.5,
					posY = 0.1381578,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.992126,
					sizeY = 0.3092106,
					image = "qds#db",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wb3",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8631512,
						sizeY = 0.6728441,
						text = "空",
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
					posX = 0.5,
					posY = 0.6118414,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9055118,
					sizeY = 0.6447368,
					image = "zdtx#txd",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "jia",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2782609,
						sizeY = 0.3163265,
						image = "qds#jia",
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dw",
				varName = "profileRoot",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9740707,
				sizeY = 0.9543397,
				image = "qds#db2",
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "db3",
					posX = 0.5,
					posY = 0.1381578,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.992126,
					sizeY = 0.3092106,
					image = "qds#db",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wb1",
						varName = "nameLabel",
						posX = 0.5,
						posY = 0.712766,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.280798,
						sizeY = 0.8281798,
						text = "名字六七个字",
						color = "FFFFE5C4",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wb2",
						varName = "levelLabel",
						posX = 0.5,
						posY = 0.2981722,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8107309,
						sizeY = 0.9512109,
						text = "lv80",
						color = "FFFFE5C4",
						fontSize = 18,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tx",
					varName = "iconType",
					posX = 0.5,
					posY = 0.5592102,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.8828237,
					sizeY = 0.5921053,
					image = "zdtx#txd",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "txx",
						varName = "icon",
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
					etype = "Image",
					name = "zy",
					varName = "typeImg",
					posX = 0.8528934,
					posY = 0.8777175,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2755905,
					sizeY = 0.2302632,
					image = "zy#daoke",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dz",
					varName = "isLeader",
					posX = 0.1282612,
					posY = 0.9004316,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2204724,
					sizeY = 0.1907895,
					image = "qds#fz",
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
