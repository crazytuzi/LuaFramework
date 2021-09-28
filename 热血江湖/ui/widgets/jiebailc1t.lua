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
			name = "rw2",
			posX = 0.5,
			posY = 0.4985628,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.175,
			sizeY = 0.3236111,
			image = "jiebai#dk2",
			scale9Left = 0.3,
			scale9Right = 0.3,
			scale9Top = 0.3,
			scale9Bottom = 0.3,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dw",
				posX = 0.5,
				posY = 0.189772,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6877522,
				sizeY = 0.193133,
				image = "jiebai#mzd",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "dj2",
				varName = "role_btn",
				posX = 0.4904645,
				posY = 0.507686,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9510792,
				sizeY = 0.954426,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "txk2",
				varName = "headBg2",
				posX = 0.5,
				posY = 0.501967,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.65625,
				sizeY = 0.5064378,
				image = "zdtx#txd",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tx2",
					varName = "role_icon2",
					posX = 0.5054789,
					posY = 0.6925332,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.7210885,
					sizeY = 1.110169,
					image = "tx#tx_yisheng.png",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz2",
				varName = "name2",
				posX = 0.4999997,
				posY = 0.1858657,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 1.006999,
				sizeY = 0.2515427,
				text = "角色名称",
				color = "FFFFDEBE",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dzb2",
				varName = "leader_mark2",
				posX = 0.2700026,
				posY = 0.8729575,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				lockHV = true,
				sizeX = 0.5314286,
				sizeY = 0.2890995,
				image = "dw#lsdz",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz3",
				varName = "title_txt",
				posX = 0.5,
				posY = 0.9271536,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 1.006999,
				sizeY = 0.2515427,
				text = "位次",
				color = "FFE7C19D",
				fontSize = 22,
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
