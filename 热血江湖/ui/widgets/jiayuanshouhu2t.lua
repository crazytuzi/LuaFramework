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
			name = "tc",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.5664063,
			sizeY = 0.1527778,
		},
		children = {
		{
			prop = {
				etype = "Grid",
				name = "cw",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "lbt",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 0.9909089,
					image = "b#ff1",
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
					name = "txk",
					varName = "petHeadBg",
					posX = 0.08539235,
					posY = 0.4997892,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1296552,
					sizeY = 0.8545453,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "tx",
						varName = "petHead",
						posX = 0.4986923,
						posY = 0.5200127,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7673025,
						sizeY = 0.7622454,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mz",
					varName = "name",
					posX = 0.3597594,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2693176,
					sizeY = 0.4789634,
					text = "名字",
					color = "FFFFFACD",
					fontOutlineEnable = true,
					fontOutlineColor = "FFB99877",
					fontOutlineSize = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn3",
					varName = "findwayBtn",
					posX = 0.7918387,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1710345,
					sizeY = 0.5272726,
					image = "chu1#sn1",
					imageNormal = "chu1#sn1",
					disablePressScale = true,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "btnz3",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9185178,
						sizeY = 1.0564,
						text = "寻 路",
						color = "FF874200",
						fontSize = 22,
						fontOutlineColor = "FF347468",
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
