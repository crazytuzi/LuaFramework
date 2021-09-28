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
			posX = 0.6234418,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.5101563,
			sizeY = 0.6125,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "shouchong",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "h#d5",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
				alpha = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dr",
					posX = 0.5,
					posY = 0.3404591,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9854181,
					sizeY = 0.6181469,
					image = "d#tyd",
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lb",
						varName = "scroll",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9898605,
						sizeY = 0.9741777,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "nrt",
					posX = 0.5061257,
					posY = 0.8391087,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 1.009895,
					sizeY = 0.3118323,
					image = "czt#hddt2",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "tp1",
						posX = 0.7042592,
						posY = 0.4585245,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5756629,
						sizeY = 0.335549,
						text = "封测倒数计时，海量元宝大放送！",
						color = "FFFFFD5E",
						fontSize = 24,
						fontOutlineEnable = true,
						fontOutlineColor = "FFCE151F",
						fontOutlineSize = 2,
						vTextAlign = 1,
						colorTL = "FFFFD060",
						colorTR = "FFFFD060",
						colorBR = "FFF2441C",
						colorBL = "FFF2441C",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "ssd",
						posX = 0.7327954,
						posY = 0.4746979,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.5052847,
						sizeY = 0.4166665,
						scale9 = true,
						scale9Top = 0.3,
						scale9Bottom = 0.3,
						alpha = 0.5,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "qq1",
							posX = 0.2888155,
							posY = 0.7290327,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.4555928,
							sizeY = 0.6001438,
							text = "官方客服群：",
							color = "FF82F13F",
							fontSize = 22,
							fontOutlineEnable = true,
							fontOutlineColor = "FF102E21",
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "qq2",
							posX = 0.2888155,
							posY = 0.2964742,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.4555928,
							sizeY = 0.6001438,
							text = "官方QQ群：",
							color = "FF82F13F",
							fontSize = 22,
							fontOutlineEnable = true,
							fontOutlineColor = "FF102E21",
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "qq3",
							posX = 0.684589,
							posY = 0.7290329,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.4555928,
							sizeY = 0.6001438,
							text = "665548523",
							color = "FFC2F9E8",
							fontSize = 22,
							fontOutlineEnable = true,
							fontOutlineColor = "FF102E21",
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "qq4",
							posX = 0.684589,
							posY = 0.296474,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.4555928,
							sizeY = 0.6001438,
							text = "665548523",
							color = "FFC2F9E8",
							fontSize = 22,
							fontOutlineEnable = true,
							fontOutlineColor = "FF102E21",
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
