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
			name = "ysjm",
			varName = "root",
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
				name = "dt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7929688,
				sizeY = 0.8055556,
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "kk2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7743842,
					sizeY = 0.9603449,
					image = "zbbj1#zbbj1",
					scale9Left = 0.45,
					scale9Right = 0.45,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "close",
					posX = 0.8490035,
					posY = 0.780637,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.0640394,
					sizeY = 0.1086207,
					image = "baishi#x",
					imageNormal = "baishi#x",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "jd",
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
						etype = "Label",
						name = "wb1",
						varName = "des",
						posX = 0.5727921,
						posY = 0.776732,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6,
						sizeY = 0.1903545,
						text = "万物有灵，先祖不灭，来占卜一下运势吧",
						color = "FFA0783E",
						fontSize = 22,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wb2",
						posX = 0.5000001,
						posY = 0.8161831,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6,
						sizeY = 0.1903545,
						color = "FF966856",
						fontSize = 22,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "tq",
						varName = "coin",
						posX = 0.7557617,
						posY = 0.08686803,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.04926108,
						sizeY = 0.08620688,
						image = "tb#tongqian",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "tb",
							posX = 0.6381623,
							posY = 0.3445681,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.4375,
							sizeY = 0.4375001,
							image = "tb#suo",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "wb4",
							varName = "coinNum",
							posX = 2.332497,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 2.472461,
							sizeY = 0.9454369,
							text = "500000",
							color = "FF8A5E2E",
							fontSize = 22,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Canvas",
						name = "hb",
						varName = "DrawNote",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4926108,
						sizeY = 0.5267193,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "htqy",
						varName = "textArea",
						posX = 0.5806568,
						posY = 0.4311478,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6,
						sizeY = 0.25,
						text = "画图区域",
						color = "FF966856",
						fontSize = 22,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "sss",
						varName = "image",
						posX = 0.5786879,
						posY = 0.4260258,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5173762,
						sizeY = 0.612785,
					},
					children = {
					{
						prop = {
							etype = "ScrollView",
							name = "scroll",
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
						etype = "Button",
						name = "btn",
						varName = "define",
						posX = 0.8285251,
						posY = 0.1884404,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1615763,
						sizeY = 0.1758621,
						image = "zhanbu#bi",
						imageNormal = "zhanbu#bi",
						disablePressScale = true,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "bz",
					varName = "help",
					posX = 0.226556,
					posY = 0.1677846,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.03349753,
					sizeY = 0.05517241,
					image = "tong#tsf",
					imageNormal = "tong#tsf",
					disablePressScale = true,
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
	dk = {
		ysjm = {
			scale = {{0, {0.3, 0.3, 1}}, {150, {1.05, 1.05, 1}}, {200, {1,1,1}}, },
		},
	},
	c_dakai = {
		{0,"dk", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
