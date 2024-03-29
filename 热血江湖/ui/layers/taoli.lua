--version = 1
local l_fileType = "layer"

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
			name = "ddd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			image = "b#dd",
			scale9 = true,
			scale9Left = 0.45,
			scale9Right = 0.45,
			scale9Top = 0.45,
			scale9Bottom = 0.45,
			alpha = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dd",
				posX = 0.5031186,
				posY = 0.5012822,
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
				name = "bjt",
				posX = 0.5183286,
				posY = 0.5610106,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6122745,
				sizeY = 0.3605184,
				image = "taolizh#q2",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "db",
				posX = 0.6107551,
				posY = 0.5526904,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3242188,
				sizeY = 0.4472222,
			},
			children = {
			{
				prop = {
					etype = "Sprite3D",
					name = "mx4",
					varName = "modle4",
					posX = 0.9008052,
					posY = -0.02213978,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4202839,
					sizeY = 0.810207,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "bjt2",
					posX = -0.03285949,
					posY = 0.5186041,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.392892,
					sizeY = 0.8061281,
					image = "taolizh#q2",
				},
			},
			{
				prop = {
					etype = "Sprite3D",
					name = "mx3",
					varName = "modle3",
					posX = 0.4355068,
					posY = -0.02213983,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4202839,
					sizeY = 0.810207,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "bjt3",
					posX = -0.2662118,
					posY = 0.5186041,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9261876,
					sizeY = 0.8061281,
					image = "taolizh#q2",
				},
			},
			{
				prop = {
					etype = "Sprite3D",
					name = "mx2",
					varName = "modle2",
					posX = -0.02979499,
					posY = -0.02213981,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4202839,
					sizeY = 0.810207,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "bjt4",
					posX = -0.4959546,
					posY = 0.5186041,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4667019,
					sizeY = 0.8061281,
					image = "taolizh#q2",
				},
			},
			{
				prop = {
					etype = "Sprite3D",
					name = "mx1",
					varName = "modle1",
					posX = -0.4981512,
					posY = -0.02213982,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4202839,
					sizeY = 0.810207,
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb",
					varName = "scroll1",
					posX = -0.4971644,
					posY = 0.4426413,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4210024,
					sizeY = 0.9456496,
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb2",
					varName = "scroll2",
					posX = -0.03287668,
					posY = 0.4426413,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4210024,
					sizeY = 0.9456496,
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb3",
					varName = "scroll3",
					posX = 0.4362483,
					posY = 0.4426412,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4210024,
					sizeY = 0.9456496,
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb4",
					varName = "scroll4",
					posX = 0.9029462,
					posY = 0.4426413,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4210024,
					sizeY = 0.9456496,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "bj",
				varName = "bg",
				posX = 0.5007801,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9328125,
				sizeY = 0.6541666,
				image = "taolizh#kuang",
				scale9Left = 0.45,
				scale9Right = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "wb2",
					varName = "txt",
					posX = 0.8951008,
					posY = 0.5943224,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.09281023,
					sizeY = 0.3413328,
					text = "不求同生，但求同死。",
					color = "FFAF8567",
					hTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dk",
					posX = 0.2932461,
					posY = -0.03097591,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1041842,
					sizeY = 0.09538411,
					image = "taolizh#q1",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wb6",
					varName = "likeNum",
					posX = 0.2955406,
					posY = -0.03204205,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1322486,
					sizeY = 0.1695723,
					text = "0",
					color = "FFFFEFD6",
					fontSize = 22,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "dz",
					varName = "likeBtn",
					posX = 0.2335547,
					posY = -0.0289268,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.05628489,
					sizeY = 0.142684,
					image = "jinlp#bbd",
					imageNormal = "jinlp#bbd",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "fx",
					varName = "shareBtn",
					posX = 0.6948192,
					posY = -0.01915595,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1155779,
					sizeY = 0.1231423,
					image = "jiebai#an1",
					imageNormal = "jiebai#an1",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "fenx",
						posX = 0.5030365,
						posY = 0.5099658,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9477151,
						sizeY = 0.9639468,
						text = "分享",
						color = "FF964F19",
						fontSize = 22,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "xg",
					varName = "editBtn",
					posX = 0.9412267,
					posY = 0.5950281,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.03852596,
					sizeY = 0.07855628,
					image = "jinlp#gai",
					imageNormal = "jinlp#gai",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dzt",
					posX = 0.2335547,
					posY = -0.0289268,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.05628489,
					sizeY = 0.142684,
					image = "jinlp#bbd",
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "xwb1",
					varName = "node1",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.25,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wb3",
						varName = "pos1",
						posX = 0.1217604,
						posY = -0.4326528,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2271065,
						sizeY = 0.3730564,
						text = "师傅",
						color = "72BF0",
						fontSize = 22,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wb8",
						varName = "name1",
						posX = 0.1217604,
						posY = -0.8565692,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2271065,
						sizeY = 0.3730564,
						text = "角色名",
						color = "72BF0",
						fontSize = 22,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "xwb2",
					varName = "node2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.25,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wb4",
						varName = "pos2",
						posX = 0.3891534,
						posY = -0.4326528,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2271065,
						sizeY = 0.3730564,
						text = "师兄",
						color = "72BF0",
						fontSize = 22,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wb9",
						varName = "name2",
						posX = 0.3891534,
						posY = -0.8565693,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2271065,
						sizeY = 0.3730564,
						text = "角色名",
						color = "72BF0",
						fontSize = 22,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "xwb3",
					varName = "node3",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.25,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wb5",
						varName = "pos3",
						posX = 0.6586934,
						posY = -0.432653,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2271065,
						sizeY = 0.3730564,
						text = "我",
						color = "72BF0",
						fontSize = 22,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wb10",
						varName = "name3",
						posX = 0.6586934,
						posY = -0.848111,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2271065,
						sizeY = 0.3730564,
						text = "角色名",
						color = "72BF0",
						fontSize = 22,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "xwb4",
					varName = "node4",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.25,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wb7",
						varName = "pos4",
						posX = 0.9299686,
						posY = -0.4199326,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2271065,
						sizeY = 0.3730564,
						text = "师弟",
						color = "72BF0",
						fontSize = 22,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wb11",
						varName = "name4",
						posX = 0.9299687,
						posY = -0.8481112,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2271065,
						sizeY = 0.3730564,
						text = "角色名",
						color = "72BF0",
						fontSize = 22,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wb1",
					varName = "desc",
					posX = 0.9022735,
					posY = 0.8200408,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1453122,
					sizeY = 0.08896887,
					text = "师傅寄语：",
					color = "FFAF8567",
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "closeBtn",
				posX = 0.9114897,
				posY = 0.7336419,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05234375,
				sizeY = 0.1055556,
				image = "chu1#gb",
				imageNormal = "chu1#gb",
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
