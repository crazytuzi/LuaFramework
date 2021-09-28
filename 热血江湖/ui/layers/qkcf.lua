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
			scale9Left = 0.1,
			scale9Right = 0.1,
			scale9Top = 0.1,
			scale9Bottom = 0.1,
			alpha = 0.8,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dd",
				varName = "close_btn",
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
				etype = "Grid",
				name = "k1",
				posX = 0.2872434,
				posY = 0.4813707,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2539063,
				sizeY = 0.5986111,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dw1",
					posX = 0.5429842,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 1.331854,
					sizeY = 1.209257,
					image = "kp#kp",
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "ybd",
						posX = 0.5043234,
						posY = 0.3334675,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4516391,
						sizeY = 0.0690727,
						image = "h#jdd2",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "yb1",
						varName = "cMoneyIcon",
						posX = 0.3161846,
						posY = 0.3408131,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1265094,
						sizeY = 0.1063711,
						image = "tb#tb_yuanbao.png",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "suo1",
							varName = "cSuoIcon",
							posX = 0.6710758,
							posY = 0.2557017,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.5256118,
							sizeY = 0.5256116,
							image = "tb#tb_suo.png",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "xz",
							varName = "cMoneyCount",
							posX = 3.08196,
							posY = 0.4591132,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 2.3405,
							sizeY = 1.027893,
							text = "12345",
							color = "FF43261D",
							fontSize = 24,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Scroll",
						name = "lb1",
						varName = "desc_scroll1",
						posX = 0.5,
						posY = 0.4866506,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5447889,
						sizeY = 0.2244736,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "pt",
						varName = "cIcon",
						posX = 0.4976898,
						posY = 0.7195403,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.5617748,
						sizeY = 0.2338639,
						image = "bp#bp_ptyxt.png",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "tsa1",
						posX = 0.5,
						posY = 0.8721675,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2425768,
						sizeY = 0.04988586,
						image = "bp#ptyx2",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "ba1",
					posX = 0.545387,
					posY = 0.5033236,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.21646,
					sizeY = 1.153557,
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "k2",
				posX = 0.7150437,
				posY = 0.4813707,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2539063,
				sizeY = 0.5986111,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dw2",
					posX = 0.5429842,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.331854,
					sizeY = 1.209257,
					image = "kp#kp",
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "ybd2",
						posX = 0.5043234,
						posY = 0.3334675,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4516391,
						sizeY = 0.0690727,
						image = "h#jdd2",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "yb2",
						varName = "gMoneyIcon",
						posX = 0.3161846,
						posY = 0.3408131,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1265094,
						sizeY = 0.1063711,
						image = "tb#tb_yuanbao.png",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "suo2",
							varName = "gSuoIcon",
							posX = 0.6710758,
							posY = 0.2557017,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.5256118,
							sizeY = 0.5256116,
							image = "tb#tb_suo.png",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "xz2",
							varName = "gMoneyCount",
							posX = 3.08196,
							posY = 0.4591132,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 2.3405,
							sizeY = 1.027893,
							text = "12345",
							color = "FF43261D",
							fontSize = 24,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Scroll",
						name = "lb2",
						varName = "desc_scroll2",
						posX = 0.5,
						posY = 0.4866506,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5447889,
						sizeY = 0.2244736,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "pt2",
						varName = "gIcon",
						posX = 0.4976898,
						posY = 0.7195403,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5617748,
						sizeY = 0.2338639,
						image = "bp#bp_hhyxt.png",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "tsa2",
						posX = 0.5,
						posY = 0.8721675,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2402665,
						sizeY = 0.04988586,
						image = "bp#hhyx2",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "ba2",
					posX = 0.545387,
					posY = 0.5033236,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.21646,
					sizeY = 1.153557,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "qx2",
				varName = "start_btn1",
				posX = 0.2981573,
				posY = 0.2815557,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2254936,
				sizeY = 0.2092734,
				propagateToChildren = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "das",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3014221,
					sizeY = 0.5773946,
					image = "bp#an",
					imageNormal = "bp#an",
					disableClick = true,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "az2",
					posX = 0.5,
					posY = 0.5229886,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.010267,
					sizeY = 0.7171067,
					text = "开启",
					color = "FF911D02",
					fontSize = 24,
					fontOutlineColor = "FF69360B",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "qx3",
				varName = "start_btn2",
				posX = 0.7275259,
				posY = 0.2815557,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.2254936,
				sizeY = 0.2092734,
				propagateToChildren = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "das2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3014221,
					sizeY = 0.5773946,
					image = "bp#an",
					imageNormal = "bp#an",
					disableClick = true,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "az3",
					posX = 0.5,
					posY = 0.5229886,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.010267,
					sizeY = 0.7171067,
					text = "开启",
					color = "FF911D02",
					fontSize = 24,
					fontOutlineColor = "FF69360B",
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
