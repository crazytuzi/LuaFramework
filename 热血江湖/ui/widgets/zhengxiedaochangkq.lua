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
			name = "ysjm",
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
				name = "z2",
				posX = 0.5,
				posY = 0.4638885,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.9188007,
				sizeY = 0.9355062,
				image = "a",
				scale9 = true,
				scale9Left = 0.41,
				scale9Right = 0.37,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "db",
					posX = 0.6220188,
					posY = 0.4905233,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6549055,
					sizeY = 0.8787524,
					image = "zxdckq#zxdckq",
				},
				children = {
				{
					prop = {
						etype = "RichText",
						name = "tj",
						varName = "des",
						posX = 0.8458977,
						posY = 0.5468454,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2918827,
						sizeY = 0.1326983,
						text = "条件",
						color = "FFFFC478",
						fontOutlineEnable = true,
						fontOutlineColor = "FF4C1C3C",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "djk1",
						varName = "root1",
						posX = 0.8389675,
						posY = 0.9149323,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.08622644,
						sizeY = 0.1122031,
						image = "djk#ktong",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "sjt",
							varName = "icon1",
							posX = 0.5053886,
							posY = 0.517023,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8231873,
							sizeY = 0.8319637,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "suo",
							varName = "suo1",
							posX = 0.1919951,
							posY = 0.223852,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.319149,
							sizeY = 0.3191489,
							image = "tb#suo",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "mc1",
							varName = "name1",
							posX = 0.5,
							posY = -0.08835682,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 1.842873,
							sizeY = 0.6620328,
							text = "道具名称",
							color = "FFFFC478",
							fontSize = 18,
							fontOutlineEnable = true,
							fontOutlineColor = "FF4C1C3C",
							fontOutlineSize = 2,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "btn1",
							varName = "bt1",
							posX = 0.5098198,
							posY = 0.4981015,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.160785,
							sizeY = 1.065507,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "djk2",
						varName = "root2",
						posX = 0.7735017,
						posY = 0.7732494,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.08622644,
						sizeY = 0.1122031,
						image = "djk#ktong",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "sjt2",
							varName = "icon2",
							posX = 0.5053886,
							posY = 0.517023,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8231873,
							sizeY = 0.8319637,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "suo2",
							varName = "suo2",
							posX = 0.1919951,
							posY = 0.223852,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.319149,
							sizeY = 0.3191489,
							image = "tb#suo",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "mc2",
							varName = "name2",
							posX = 0.5,
							posY = -0.08835682,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 1.842873,
							sizeY = 0.6620328,
							text = "道具名称",
							color = "FFFFC478",
							fontSize = 18,
							fontOutlineEnable = true,
							fontOutlineColor = "FF4C1C3C",
							fontOutlineSize = 2,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "btn2",
							varName = "bt2",
							posX = 0.5098198,
							posY = 0.4981015,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.160785,
							sizeY = 1.065507,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "djk3",
						varName = "root3",
						posX = 0.9044333,
						posY = 0.7732494,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.08622644,
						sizeY = 0.1122031,
						image = "djk#ktong",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "sjt3",
							varName = "icon3",
							posX = 0.5053886,
							posY = 0.517023,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8231873,
							sizeY = 0.8319637,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "suo3",
							varName = "suo3",
							posX = 0.1919951,
							posY = 0.223852,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.319149,
							sizeY = 0.3191489,
							image = "tb#suo",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "mc3",
							varName = "name3",
							posX = 0.5,
							posY = -0.08835682,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 1.842873,
							sizeY = 0.6620328,
							text = "道具名称",
							color = "FFFFC478",
							fontSize = 18,
							fontOutlineEnable = true,
							fontOutlineColor = "FF4C1C3C",
							fontOutlineSize = 2,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "btn3",
							varName = "bt3",
							posX = 0.5098198,
							posY = 0.4981015,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.160785,
							sizeY = 1.065507,
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wdd",
						posX = 0.7799828,
						posY = 0.1171157,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6,
						sizeY = 0.25,
						text = "您尚未满足开启条件",
						color = "FFFE0000",
						fontSize = 22,
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
