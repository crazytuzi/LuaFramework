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
			sizeX = 0.5101563,
			sizeY = 0.6125,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "shouchong",
				varName = "ShouChong",
				posX = 0.4976502,
				posY = 0.4977324,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.0107,
				sizeY = 1.027438,
				image = "duihuanma#duihuanma",
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dr",
					posX = 0.5,
					posY = 0.3236704,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.985418,
					sizeY = 0.4902861,
					image = "d#bt",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
					alpha = 0.7,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "hb",
						posX = 0.5,
						posY = -0.08068979,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9302724,
						sizeY = 0.1581632,
						image = "d#cdd",
						alpha = 0.5,
						flippedY = true,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "hb3",
						posX = 0.4999999,
						posY = 1.080662,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9302725,
						sizeY = 0.1581632,
						image = "d#cdd",
						alpha = 0.5,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "smd",
						posX = 0.5027484,
						posY = 1.006459,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3407864,
						sizeY = 0.1766275,
						image = "cl2#top",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "mz",
							posX = 0.5,
							posY = 0.6,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7500203,
							sizeY = 1.079304,
							text = "输入兑换码",
							color = "FFFFFF80",
							fontSize = 24,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "srd",
						posX = 0.5,
						posY = 0.5971453,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6260735,
						sizeY = 0.2207844,
						image = "b#srk",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
					},
					children = {
					{
						prop = {
							etype = "EditBox",
							name = "sr",
							sizeXAB = 372.9026,
							sizeYAB = 40.20634,
							posXAB = 206.6645,
							posYAB = 16.21044,
							varName = "editBox",
							posX = 0.5075568,
							posY = 0.3305084,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9158284,
							sizeY = 0.8197518,
							color = "FFFFF4E4",
							fontSize = 24,
							phText = "在此处输入兑换码",
							phColor = "FFFFF4E4",
							phFontSize = 24,
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an8",
					varName = "GetBtn",
					posX = 0.5,
					posY = 0.1828163,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2496172,
					sizeY = 0.1451247,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "z2",
						varName = "GetBtnText",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.016411,
						sizeY = 0.8880838,
						text = "兑 换",
						fontSize = 24,
						fontOutlineEnable = true,
						fontOutlineColor = "FF2A6953",
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
