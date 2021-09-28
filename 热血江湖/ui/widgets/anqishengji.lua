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
			name = "shengji",
			varName = "upgradeRoot",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.29375,
			sizeY = 0.7763889,
			scale9 = true,
			scale9Top = 0.3,
			scale9Bottom = 0.3,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "kkk",
				posX = 0.5,
				posY = 0.6386955,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9062512,
				sizeY = 0.3880891,
				image = "b#d2",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
				alpha = 0.5,
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
					sizeX = 1,
					sizeY = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z1",
				varName = "level",
				posX = 0.1765257,
				posY = 0.9431875,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2076386,
				sizeY = 0.06139318,
				text = "等阶:",
				color = "FF966856",
				fontSize = 22,
				fontOutlineColor = "FF00152E",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z2",
				varName = "value",
				posX = 0.336935,
				posY = 0.9431875,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2076386,
				sizeY = 0.06139318,
				text = "60",
				color = "FF966856",
				fontSize = 22,
				fontOutlineColor = "FF00152E",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jd1",
				posX = 0.5,
				posY = 0.8747339,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6303192,
				sizeY = 0.05724508,
				image = "chu1#jdd",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "LoadingBar",
					name = "dt1",
					varName = "exp_slider",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9451476,
					sizeY = 0.625,
					image = "tong#jdt2",
					scale9Left = 0.3,
					scale9Right = 0.3,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "tsz",
					varName = "exp_value",
					posX = 0.5,
					posY = 0.54,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9976744,
					sizeY = 1.810698,
					text = "12/666",
					fontOutlineEnable = true,
					fontOutlineColor = "FF567D23",
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
				name = "z3",
				varName = "desc",
				posX = 0.5,
				posY = 0.04143184,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9313284,
				sizeY = 0.07199287,
				text = "无需装备即可给角色附加属性",
				color = "FFC93034",
				fontOutlineColor = "FF404040",
				hTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "wpk4",
				varName = "itemBg1",
				posX = 0.1861333,
				posY = 0.3426753,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.2568096,
				sizeY = 0.1686977,
				image = "djk#kbai",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "wp4",
					varName = "itemIcon1",
					posX = 0.5,
					posY = 0.5427376,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7960408,
					sizeY = 0.7786804,
					image = "items#xueping1.png",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dw4",
					posX = 0.4861749,
					posY = 0.2226508,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8597251,
					sizeY = 0.2933058,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "lj4",
						varName = "itemCount1",
						posX = 0.5,
						posY = 0.4956484,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.022223,
						sizeY = 1.395685,
						text = "1000",
						fontOutlineEnable = true,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "wpk5",
				varName = "itemBg2",
				posX = 0.4994404,
				posY = 0.3426753,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.2568096,
				sizeY = 0.1686977,
				image = "djk#kbai",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "wp5",
					varName = "itemIcon2",
					posX = 0.5,
					posY = 0.5427376,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7960408,
					sizeY = 0.7786804,
					image = "items#xueping1.png",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dw5",
					posX = 0.4861749,
					posY = 0.2226508,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8597251,
					sizeY = 0.2933058,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "lj5",
						varName = "itemCount2",
						posX = 0.5,
						posY = 0.4956484,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.022223,
						sizeY = 1.395685,
						text = "1000",
						fontOutlineEnable = true,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "wpk6",
				varName = "itemBg3",
				posX = 0.8127478,
				posY = 0.3426753,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.2568096,
				sizeY = 0.1686977,
				image = "djk#kbai",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "wp6",
					varName = "itemIcon3",
					posX = 0.5,
					posY = 0.5427376,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7960408,
					sizeY = 0.7786804,
					image = "items#xueping1.png",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dw6",
					posX = 0.4861749,
					posY = 0.2226508,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8597251,
					sizeY = 0.2933058,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "lj6",
						varName = "itemCount3",
						posX = 0.5,
						posY = 0.4956484,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.022223,
						sizeY = 1.395685,
						text = "1000",
						fontOutlineEnable = true,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an5",
				varName = "itemBtn1",
				posX = 0.1888365,
				posY = 0.349754,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2590887,
				sizeY = 0.1530526,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an6",
				varName = "itemBtn2",
				posX = 0.4994401,
				posY = 0.349754,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2590887,
				sizeY = 0.1530526,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an7",
				varName = "itemBtn3",
				posX = 0.8127475,
				posY = 0.349754,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2590887,
				sizeY = 0.1530526,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "mojid4",
				varName = "count4Root",
				posX = 0.1953683,
				posY = 0.2462789,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2571463,
				sizeY = 0.05163313,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "sl4",
					varName = "count1",
					posX = 0.4474375,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.606396,
					sizeY = 1.096285,
					text = "15",
					color = "FF4C3612",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "mojid5",
				varName = "count5Root",
				posX = 0.5058023,
				posY = 0.2462788,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2571463,
				sizeY = 0.05163313,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "sl5",
					varName = "count2",
					posX = 0.4474375,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.606396,
					sizeY = 1.096285,
					text = "15",
					color = "FF4C3612",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "mojid6",
				varName = "count6Root",
				posX = 0.8191096,
				posY = 0.2462789,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2571463,
				sizeY = 0.05163313,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "sl6",
					varName = "count3",
					posX = 0.4474375,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.606396,
					sizeY = 1.096285,
					text = "15",
					color = "FF4C3612",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "ijsy",
				varName = "akey_btn",
				posX = 0.5,
				posY = 0.142763,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.462766,
				sizeY = 0.118068,
				image = "chu1#an2",
				imageNormal = "chu1#an2",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "ijsyz",
					posX = 0.5,
					posY = 0.5454545,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9047835,
					sizeY = 0.876363,
					text = "一键使用",
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
		{
			prop = {
				etype = "RichText",
				name = "z5",
				varName = "needLevel",
				posX = 0.6692116,
				posY = 0.9431875,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6207321,
				sizeY = 0.06139318,
				text = "角色5级后可以升阶",
				color = "FF966856",
				fontSize = 22,
				fontOutlineColor = "FF00152E",
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
	gy = {
	},
	gy2 = {
	},
	gy3 = {
	},
	gy4 = {
	},
	gy5 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
