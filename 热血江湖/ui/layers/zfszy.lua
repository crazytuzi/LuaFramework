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
			posX = 0.4992208,
			posY = 0.5041591,
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
				sizeX = 0.5880963,
				sizeY = 0.6111111,
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
					name = "wk",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9641914,
					sizeY = 1.100401,
					image = "b#db5",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "d1",
					posX = 0.5013263,
					posY = 0.5000002,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9244019,
					sizeY = 1.030124,
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "aa",
					posX = 0.2771776,
					posY = 0.5204278,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4748005,
					sizeY = 0.8168277,
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
						name = "h1",
						posX = 0.3141563,
						posY = 0.9768052,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5260031,
						sizeY = 0.09760729,
						image = "zfsbj#dt2",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "dj",
							varName = "level",
							posX = 0.5968617,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.128976,
							sizeY = 0.9683447,
							text = "真言等级",
							color = "FFFF7E2D",
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "h2",
						varName = "equipCountText",
						posX = 0.3566118,
						posY = 0.8737455,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6,
						sizeY = 0.081822,
						text = "嗯嗯嗯嗯",
						color = "FF966856",
						fontSize = 18,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "h3",
						varName = "propAddText",
						posX = 0.3566118,
						posY = 0.7990191,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6,
						sizeY = 0.081822,
						text = "嗯嗯嗯嗯呃",
						color = "FF966856",
						fontSize = 18,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "RichText",
						name = "h4",
						varName = "holeCount",
						posX = 0.5129533,
						posY = 0.7242927,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9126832,
						sizeY = 0.081822,
						text = "嗯呢讷讷",
						color = "FF966856",
						fontSize = 18,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "h5",
						varName = "energyText",
						posX = 0.5129535,
						posY = 0.6495663,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9126831,
						sizeY = 0.081822,
						text = "嗯呢讷讷",
						color = "FF966856",
						fontSize = 18,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "h6",
						varName = "equipCount",
						posX = 0.8123404,
						posY = 0.8737456,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3083283,
						sizeY = 0.081822,
						text = "100",
						color = "FF966856",
						fontSize = 18,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "h7",
						varName = "propAdd",
						posX = 0.8123405,
						posY = 0.7990191,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3083283,
						sizeY = 0.081822,
						text = "100",
						color = "FF966856",
						fontSize = 18,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "h8",
						posX = 0.3141563,
						posY = 0.5484401,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5260031,
						sizeY = 0.09760729,
						image = "zfsbj#dt2",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "dj2",
							varName = "rateTitle",
							posX = 0.6127932,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.160838,
							sizeY = 1.068442,
							text = "真言等级",
							color = "FFFF7E2D",
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "k1",
						posX = 0.5027938,
						posY = 0.4191131,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.964799,
						sizeY = 0.09738339,
						image = "zfsbj#dt1",
						scale9 = true,
						scale9Left = 0.45,
						scale9Right = 0.45,
						scale9Top = 0.45,
						scale9Bottom = 0.45,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "h9",
							varName = "stone1",
							posX = 0.1462838,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.138218,
							sizeY = 1,
							text = "嗯",
							color = "FF966856",
							fontSize = 18,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "h10",
							varName = "rate1",
							posX = 0.3182125,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1842594,
							sizeY = 1,
							text = "嗯嗯嗯",
							color = "FF966856",
							fontSize = 18,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "h11",
							varName = "stone5",
							posX = 0.6361771,
							posY = 0.4319789,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.138218,
							sizeY = 1,
							text = "嗯",
							color = "FF966856",
							fontSize = 18,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "h12",
							varName = "rate5",
							posX = 0.8013747,
							posY = 0.4319789,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1842594,
							sizeY = 1,
							text = "嗯嗯嗯",
							color = "FF966856",
							fontSize = 18,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "k2",
						posX = 0.5027939,
						posY = 0.3251178,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.964799,
						sizeY = 0.09738339,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "h13",
							varName = "stone2",
							posX = 0.1462835,
							posY = 0.4319789,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.138218,
							sizeY = 1,
							text = "嗯",
							color = "FF966856",
							fontSize = 18,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "h14",
							varName = "rate2",
							posX = 0.3182123,
							posY = 0.431979,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1842594,
							sizeY = 1,
							text = "嗯嗯嗯",
							color = "FF966856",
							fontSize = 18,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "h15",
							varName = "stone6",
							posX = 0.6361771,
							posY = 0.4319789,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.138218,
							sizeY = 1,
							text = "嗯",
							color = "FF966856",
							fontSize = 18,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "h16",
							varName = "rate6",
							posX = 0.8013747,
							posY = 0.4319789,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1842594,
							sizeY = 1,
							text = "嗯嗯嗯",
							color = "FF966856",
							fontSize = 18,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "k3",
						posX = 0.502794,
						posY = 0.2311224,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.964799,
						sizeY = 0.09738339,
						image = "zfsbj#dt1",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "h17",
							varName = "stone3",
							posX = 0.1462835,
							posY = 0.4319789,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.138218,
							sizeY = 1,
							text = "嗯",
							color = "FF966856",
							fontSize = 18,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "h18",
							varName = "rate3",
							posX = 0.3182122,
							posY = 0.431979,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1842594,
							sizeY = 1,
							text = "嗯嗯嗯",
							color = "FF966856",
							fontSize = 18,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "h19",
							varName = "stone7",
							posX = 0.6361771,
							posY = 0.4319789,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.138218,
							sizeY = 1,
							text = "嗯",
							color = "FF966856",
							fontSize = 18,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "h20",
							varName = "rate7",
							posX = 0.8013747,
							posY = 0.4319789,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1842594,
							sizeY = 1,
							text = "嗯嗯嗯",
							color = "FF966856",
							fontSize = 18,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "k4",
						posX = 0.5027939,
						posY = 0.1371271,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.964799,
						sizeY = 0.09738339,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "h21",
							varName = "stone4",
							posX = 0.1462835,
							posY = 0.4319789,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.138218,
							sizeY = 1,
							text = "嗯",
							color = "FF966856",
							fontSize = 18,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "h22",
							varName = "rate4",
							posX = 0.3182123,
							posY = 0.431979,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1842594,
							sizeY = 1,
							text = "嗯嗯嗯",
							color = "FF966856",
							fontSize = 18,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "h23",
							varName = "stone8",
							posX = 0.6361771,
							posY = 0.4319789,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.138218,
							sizeY = 1,
							text = "嗯",
							color = "FF966856",
							fontSize = 18,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "h24",
							varName = "rate8",
							posX = 0.8013747,
							posY = 0.4319789,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1842594,
							sizeY = 1,
							text = "嗯嗯嗯",
							color = "FF966856",
							fontSize = 18,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "k5",
						posX = 0.5027939,
						posY = 0.04313174,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.964799,
						sizeY = 0.09738339,
						image = "zfsbj#dt1",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "h25",
							varName = "stone10",
							posX = 0.1462835,
							posY = 0.4319789,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.138218,
							sizeY = 1,
							text = "嗯",
							color = "FF966856",
							fontSize = 18,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "h26",
							varName = "rate10",
							posX = 0.3182123,
							posY = 0.431979,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1842594,
							sizeY = 1,
							text = "嗯嗯嗯",
							color = "FF966856",
							fontSize = 18,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "h27",
							varName = "stone9",
							posX = 0.6361771,
							posY = 0.4319789,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.138218,
							sizeY = 1,
							text = "嗯",
							color = "FF966856",
							fontSize = 18,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "h28",
							varName = "rate9",
							posX = 0.8013747,
							posY = 0.4319789,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1842594,
							sizeY = 1,
							text = "嗯嗯嗯",
							color = "FF966856",
							fontSize = 18,
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
					name = "dt1",
					posX = 0.7413779,
					posY = 0.8290148,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4297095,
					sizeY = 0.1860995,
					image = "b#d2",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
				children = {
				{
					prop = {
						etype = "RichText",
						name = "cc",
						varName = "prayLevel",
						posX = 0.1588615,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2661624,
						sizeY = 0.951014,
						text = "真言等级3级",
						color = "FF966856",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "jdtd",
						posX = 0.6172819,
						posY = 0.3377917,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6666655,
						sizeY = 0.3907974,
						image = "chu1#jdd",
						scale9 = true,
						scale9Left = 0.45,
						scale9Right = 0.45,
					},
					children = {
					{
						prop = {
							etype = "LoadingBar",
							name = "jdt",
							varName = "prayLoading",
							posX = 0.4979973,
							posY = 0.5085559,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9456,
							sizeY = 0.6239913,
							image = "tong#jdtf2",
							imageHead = "r",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "jyz",
							varName = "prayPercent",
							posX = 0.5,
							posY = 1.272441,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.184092,
							sizeY = 2.834588,
							text = "9999999/99999999",
							color = "FF966856",
							fontSize = 18,
							fontOutlineColor = "FF567D23",
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "max",
							varName = "maxIcon",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 0.1854892,
							sizeY = 0.5312505,
							image = "chu1#max2",
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dt2",
					posX = 0.7413779,
					posY = 0.5976994,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4297095,
					sizeY = 0.1860994,
					image = "b#d2",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "z4",
						varName = "desc",
						posX = 0.5,
						posY = 0.5000004,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6790099,
						sizeY = 0.7970929,
						text = "1111111",
						fontSize = 18,
						fontOutlineEnable = true,
						fontOutlineColor = "FFA47848",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dt3",
					posX = 0.7413779,
					posY = 0.2243156,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4297095,
					sizeY = 0.4606165,
					image = "b#d2",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lb1",
						varName = "scroll",
						posX = 0.5,
						posY = 0.6166278,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9739402,
						sizeY = 0.5674213,
						horizontal = true,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "a1",
						varName = "batchUse",
						posX = 0.5,
						posY = 0.1732404,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.3802522,
						sizeY = 0.2861777,
						image = "chu1#an3",
						imageNormal = "chu1#an3",
						soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "wz1",
							varName = "cancel_word",
							posX = 0.4927007,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8313926,
							sizeY = 0.963034,
							text = "一键使用",
							fontOutlineEnable = true,
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
			{
				prop = {
					etype = "Image",
					name = "top",
					posX = 0.5,
					posY = 1.028279,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3507079,
					sizeY = 0.1181818,
					image = "chu1#top",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "top1",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5151514,
						sizeY = 0.4807693,
						image = "biaoti#zhenyandengji",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a2",
					varName = "rightBtn",
					posX = 0.4080245,
					posY = 0.03712429,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.05091219,
					sizeY = 0.1093838,
					image = "chu1#jiantou",
					imageNormal = "chu1#jiantou",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a3",
					varName = "leftBtn",
					posX = 0.1283945,
					posY = 0.03712429,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.05091219,
					sizeY = 0.1093838,
					image = "chu1#jiantou",
					imageNormal = "chu1#jiantou",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					flippedX = true,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "closeBtn",
					posX = 0.9628772,
					posY = 1.00928,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.07040726,
					sizeY = 0.1204545,
					image = "feisheng#gb",
					imageNormal = "feisheng#gb",
					disablePressScale = true,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dddd",
					posX = 0.2678787,
					posY = 0.0348561,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1659908,
					sizeY = 0.09529576,
					image = "zfsbj#dt3",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "ss",
						varName = "page",
						posX = 0.4921504,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.942809,
						sizeY = 0.9318308,
						text = "第一页de",
						color = "FF966856",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xian",
					posX = 0.5119335,
					posY = 0.458025,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.002651688,
					sizeY = 0.8962552,
					image = "daxia#x",
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
			scale = {{0, {0.3, 0.3, 1}}, {150, {1.1, 1.1, 1}}, {200, {1,1,1}}, },
		},
	},
	gy = {
	},
	gy3 = {
	},
	gy2 = {
	},
	gy4 = {
	},
	gy5 = {
	},
	gy6 = {
	},
	gy7 = {
	},
	gy8 = {
	},
	gy9 = {
	},
	gy10 = {
	},
	gy11 = {
	},
	gy12 = {
	},
	gy13 = {
	},
	gy14 = {
	},
	gy15 = {
	},
	gy16 = {
	},
	gy17 = {
	},
	gy18 = {
	},
	gy19 = {
	},
	gy20 = {
	},
	gy21 = {
	},
	gy22 = {
	},
	gy23 = {
	},
	gy24 = {
	},
	gy25 = {
	},
	gy26 = {
	},
	gy27 = {
	},
	gy28 = {
	},
	gy29 = {
	},
	gy30 = {
	},
	gy31 = {
	},
	gy32 = {
	},
	gy33 = {
	},
	gy34 = {
	},
	gy35 = {
	},
	gy36 = {
	},
	gy37 = {
	},
	gy38 = {
	},
	gy39 = {
	},
	gy40 = {
	},
	gy41 = {
	},
	gy42 = {
	},
	gy43 = {
	},
	gy44 = {
	},
	gy45 = {
	},
	gy46 = {
	},
	gy47 = {
	},
	gy48 = {
	},
	gy49 = {
	},
	gy50 = {
	},
	gy51 = {
	},
	gy52 = {
	},
	gy53 = {
	},
	gy54 = {
	},
	gy55 = {
	},
	gy56 = {
	},
	gy57 = {
	},
	gy58 = {
	},
	gy59 = {
	},
	gy60 = {
	},
	gy61 = {
	},
	gy62 = {
	},
	gy63 = {
	},
	gy64 = {
	},
	gy65 = {
	},
	gy66 = {
	},
	gy67 = {
	},
	gy68 = {
	},
	gy69 = {
	},
	gy70 = {
	},
	gy71 = {
	},
	gy72 = {
	},
	gy73 = {
	},
	gy74 = {
	},
	gy75 = {
	},
	gy76 = {
	},
	gy77 = {
	},
	gy78 = {
	},
	gy79 = {
	},
	gy80 = {
	},
	gy81 = {
	},
	gy82 = {
	},
	gy83 = {
	},
	gy84 = {
	},
	gy85 = {
	},
	gy86 = {
	},
	gy87 = {
	},
	gy88 = {
	},
	gy89 = {
	},
	gy90 = {
	},
	gy91 = {
	},
	gy92 = {
	},
	gy93 = {
	},
	gy94 = {
	},
	gy95 = {
	},
	gy96 = {
	},
	gy97 = {
	},
	gy98 = {
	},
	gy99 = {
	},
	gy100 = {
	},
	gy101 = {
	},
	gy102 = {
	},
	gy103 = {
	},
	gy104 = {
	},
	gy105 = {
	},
	gy106 = {
	},
	gy107 = {
	},
	gy108 = {
	},
	gy109 = {
	},
	gy110 = {
	},
	gy111 = {
	},
	gy112 = {
	},
	gy113 = {
	},
	gy114 = {
	},
	gy115 = {
	},
	gy116 = {
	},
	gy117 = {
	},
	gy118 = {
	},
	gy119 = {
	},
	gy120 = {
	},
	gy121 = {
	},
	gy122 = {
	},
	gy123 = {
	},
	gy124 = {
	},
	gy125 = {
	},
	gy126 = {
	},
	gy127 = {
	},
	gy128 = {
	},
	gy129 = {
	},
	gy130 = {
	},
	gy131 = {
	},
	gy132 = {
	},
	gy133 = {
	},
	gy134 = {
	},
	gy135 = {
	},
	gy136 = {
	},
	gy137 = {
	},
	gy138 = {
	},
	gy139 = {
	},
	gy140 = {
	},
	gy141 = {
	},
	gy142 = {
	},
	gy143 = {
	},
	gy144 = {
	},
	gy145 = {
	},
	gy146 = {
	},
	gy147 = {
	},
	gy148 = {
	},
	gy149 = {
	},
	gy150 = {
	},
	gy151 = {
	},
	gy152 = {
	},
	gy153 = {
	},
	gy154 = {
	},
	gy155 = {
	},
	gy156 = {
	},
	gy157 = {
	},
	gy158 = {
	},
	gy159 = {
	},
	gy160 = {
	},
	gy161 = {
	},
	gy162 = {
	},
	gy163 = {
	},
	gy164 = {
	},
	gy165 = {
	},
	gy166 = {
	},
	gy167 = {
	},
	gy168 = {
	},
	gy169 = {
	},
	gy170 = {
	},
	gy171 = {
	},
	gy172 = {
	},
	gy173 = {
	},
	gy174 = {
	},
	gy175 = {
	},
	gy176 = {
	},
	gy177 = {
	},
	gy178 = {
	},
	gy179 = {
	},
	gy180 = {
	},
	gy181 = {
	},
	gy182 = {
	},
	gy183 = {
	},
	gy184 = {
	},
	gy185 = {
	},
	gy186 = {
	},
	gy187 = {
	},
	gy188 = {
	},
	gy189 = {
	},
	gy190 = {
	},
	gy191 = {
	},
	gy192 = {
	},
	gy193 = {
	},
	gy194 = {
	},
	gy195 = {
	},
	gy196 = {
	},
	gy197 = {
	},
	gy198 = {
	},
	gy199 = {
	},
	gy200 = {
	},
	gy201 = {
	},
	gy202 = {
	},
	gy203 = {
	},
	gy204 = {
	},
	gy205 = {
	},
	gy206 = {
	},
	gy207 = {
	},
	gy208 = {
	},
	gy209 = {
	},
	gy210 = {
	},
	gy211 = {
	},
	gy212 = {
	},
	gy213 = {
	},
	gy214 = {
	},
	gy215 = {
	},
	gy216 = {
	},
	gy217 = {
	},
	gy218 = {
	},
	gy219 = {
	},
	gy220 = {
	},
	gy221 = {
	},
	gy222 = {
	},
	gy223 = {
	},
	gy224 = {
	},
	gy225 = {
	},
	gy226 = {
	},
	gy227 = {
	},
	gy228 = {
	},
	gy229 = {
	},
	gy230 = {
	},
	gy231 = {
	},
	gy232 = {
	},
	gy233 = {
	},
	gy234 = {
	},
	gy235 = {
	},
	gy236 = {
	},
	gy237 = {
	},
	gy238 = {
	},
	gy239 = {
	},
	gy240 = {
	},
	gy241 = {
	},
	gy242 = {
	},
	gy243 = {
	},
	gy244 = {
	},
	gy245 = {
	},
	gy246 = {
	},
	gy247 = {
	},
	gy248 = {
	},
	gy249 = {
	},
	gy250 = {
	},
	gy251 = {
	},
	gy252 = {
	},
	gy253 = {
	},
	gy254 = {
	},
	gy255 = {
	},
	gy256 = {
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
