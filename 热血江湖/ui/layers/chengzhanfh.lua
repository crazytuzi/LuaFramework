--version = 1
local l_fileType = "layer"

local UIUtil = require "ui/common/UIUtil"

--EDITOR elements start tag
local eleRoot = 
{
	prop = {
		etype = "Layer",
		name = "root",
		varName = "RolerevivePanel",
		posX = 0,
		posY = 0,
		anchorX = 0,
		anchorY = 0,
	},
	children = {
	{
		prop = {
			etype = "Image",
			name = "ddd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			scale9 = true,
			scale9Left = 0.2,
			scale9Right = 0.2,
			scale9Top = 0.2,
			scale9Bottom = 0.2,
			alpha = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dd",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "fy1",
			varName = "revive3Panel",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			layoutType = 5,
			layoutTypeW = 5,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "fhd",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.5,
				sizeY = 0.2486111,
				image = "chengzhan#sbd",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "bqz",
				varName = "topImage",
				posX = 0.5,
				posY = 0.9618108,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.4101563,
				sizeY = 0.06527778,
				image = "wybq#tsz",
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "tsz",
				varName = "desc",
				posX = 0.5,
				posY = 0.5132339,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.1735318,
				text = "这句话策划配置",
				color = "FFFFEA44",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "jd2",
				posX = 0.5,
				posY = 0.331486,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2056233,
				sizeY = 0.5007715,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "an2",
					varName = "ComeToLife",
					posX = 0.5,
					posY = 0.5804317,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.7332888,
					sizeY = 0.1719569,
					image = "chengzhan#btn",
					imageNormal = "chengzhan#btn",
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "v2",
						varName = "btn2_text",
						posX = 0.5,
						posY = 0.548387,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8896554,
						sizeY = 1.497759,
						text = "复活点复活",
						color = "FF9F451D",
						fontSize = 24,
						fontOutlineColor = "FF055444",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "slz",
					varName = "leftTime",
					posX = 0.5,
					posY = 0.7364474,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9346582,
					sizeY = 0.2264076,
					text = "00：55",
					color = "FFF81C1C",
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
				name = "gl",
				posX = 0.5,
				posY = 0.6511206,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3835938,
				sizeY = 0.3319444,
				image = "chengzhan#niyijingguale",
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
