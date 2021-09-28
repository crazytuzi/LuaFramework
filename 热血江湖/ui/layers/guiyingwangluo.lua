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
				name = "asdfsadf",
				posX = 0.5001433,
				posY = 0.5001019,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9980707,
				sizeY = 0.9985647,
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
				name = "bei",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "guiyingbj1#guiyingbj1",
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "aaaa",
				posX = 0.4953201,
				posY = 0.5748774,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "kp5",
					varName = "modelBg5",
					posX = 0.440723,
					posY = 0.6122967,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1263393,
					sizeY = 0.2777778,
					image = "guiying#db1",
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lbs5",
						varName = "modelScroll5",
						posX = 0.5,
						posY = 0.51682,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8043488,
						sizeY = 0.8772929,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "djan5",
						varName = "modelBtn5",
						posX = 0.4999925,
						posY = 0.5281693,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8608849,
						sizeY = 0.8999915,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "kp6",
					varName = "modelBg6",
					posX = 0.5662808,
					posY = 0.5720847,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1263393,
					sizeY = 0.2777778,
					image = "guiying#db1",
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lbs6",
						varName = "modelScroll6",
						posX = 0.5,
						posY = 0.51682,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8043488,
						sizeY = 0.8772929,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "djan6",
						varName = "modelBtn6",
						posX = 0.4999925,
						posY = 0.5281693,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8608849,
						sizeY = 0.8999915,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "kp4",
					varName = "modelBg4",
					posX = 0.3182678,
					posY = 0.5720848,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1263393,
					sizeY = 0.2777778,
					image = "guiying#db1",
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lbs4",
						varName = "modelScroll4",
						posX = 0.5,
						posY = 0.51682,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8043488,
						sizeY = 0.8772929,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "djan4",
						varName = "modelBtn4",
						posX = 0.4999925,
						posY = 0.5281693,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8608849,
						sizeY = 0.8999915,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "kp",
					varName = "modelBg1",
					posX = 0.440723,
					posY = 0.3627065,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1793897,
					sizeY = 0.3944177,
					image = "guiying#db1",
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lbs",
						varName = "modelScroll1",
						posX = 0.5,
						posY = 0.51682,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8043488,
						sizeY = 0.8772929,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "djan1",
						varName = "modelBtn1",
						posX = 0.4999925,
						posY = 0.5281693,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8608849,
						sizeY = 0.8999915,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "kp3",
					varName = "modelBg3",
					posX = 0.1965937,
					posY = 0.4514497,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1263393,
					sizeY = 0.2777778,
					image = "guiying#db1",
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lbs3",
						varName = "modelScroll3",
						posX = 0.5,
						posY = 0.51682,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8043488,
						sizeY = 0.8772929,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "djan3",
						varName = "modelBtn3",
						posX = 0.4999925,
						posY = 0.5281693,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8608849,
						sizeY = 0.8999915,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "kp2",
					varName = "modelBg2",
					posX = 0.285509,
					posY = 0.3738,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1263393,
					sizeY = 0.2777778,
					image = "guiying#db1",
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lbs2",
						varName = "modelScroll2",
						posX = 0.5,
						posY = 0.51682,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8043488,
						sizeY = 0.8772929,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "djan2",
						varName = "modelBtn2",
						posX = 0.4999925,
						posY = 0.5281693,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8608849,
						sizeY = 0.8999915,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "kp7",
					varName = "modelBg7",
					posX = 0.6887417,
					posY = 0.4514497,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1263393,
					sizeY = 0.2777778,
					image = "guiying#db1",
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lbs7",
						varName = "modelScroll7",
						posX = 0.5,
						posY = 0.51682,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8043488,
						sizeY = 0.8772929,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "djan7",
						varName = "modelBtn7",
						posX = 0.4999925,
						posY = 0.5281693,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8608849,
						sizeY = 0.8999915,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "kp8",
					varName = "modelBg8",
					posX = 0.5959381,
					posY = 0.3738,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1263393,
					sizeY = 0.2777778,
					image = "guiying#db1",
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lbs8",
						varName = "modelScroll8",
						posX = 0.5,
						posY = 0.51682,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8043488,
						sizeY = 0.8772929,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "djan8",
						varName = "modelBtn8",
						posX = 0.4999925,
						posY = 0.5281693,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8608849,
						sizeY = 0.8999915,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "kp9",
					varName = "leaderBg",
					posX = 0.4430633,
					posY = 0.3987592,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					lockHV = true,
					sizeX = 0.2210937,
					sizeY = 0.4861111,
					image = "guiying#db3",
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lbs9",
						varName = "leaderScroll",
						posX = 0.5,
						posY = 0.51682,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8043488,
						sizeY = 0.8772929,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "djan9",
						posX = 0.4999925,
						posY = 0.5281693,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8608849,
						sizeY = 0.8999915,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "tm",
						posX = 0.1472216,
						posY = 0.8708174,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1201414,
						sizeY = 0.1714286,
						image = "guiying#toumu",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "jiantou",
					varName = "rightBtn",
					posX = 0.7644089,
					posY = 0.463949,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.03359375,
					sizeY = 0.075,
					image = "chu1#jiantou",
					imageNormal = "chu1#jiantou",
					disablePressScale = true,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "jiantou2",
					varName = "leftBtn",
					posX = 0.123275,
					posY = 0.463949,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.03359375,
					sizeY = 0.075,
					image = "chu1#jiantou",
					imageNormal = "chu1#jiantou",
					disablePressScale = true,
					flippedX = true,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "bj",
				varName = "bg",
				posX = 0.5035089,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9024231,
				sizeY = 0.8763889,
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
					name = "wb1",
					varName = "bossText",
					posX = 0.5,
					posY = 0.9385267,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5333049,
					sizeY = 0.1239687,
					text = "已发现“头目”菜刀",
					color = "FFF1E9D7",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FFCB5539",
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
				name = "xbj",
				posX = 0.4134231,
				posY = 0.1547336,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5428573,
				sizeY = 0.1469812,
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
					name = "xlb",
					varName = "clueScroll",
					posX = 0.6279591,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.647615,
					sizeY = 0.8032017,
					horizontal = true,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "fx6",
					varName = "leaderBtn",
					posX = 1.133752,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1986019,
					sizeY = 0.5480671,
					image = "jiebai#an1",
					imageNormal = "jiebai#an1",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "fxwb6",
						varName = "leaderText",
						posX = 0.5160611,
						posY = 0.5117077,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 1,
						text = "揭露头目",
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
					etype = "Label",
					name = "dwb",
					posX = 0.114408,
					posY = 0.7373202,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2199357,
					sizeY = 0.4322321,
					text = "可进行调查：",
					color = "FFF7E9D6",
					fontSize = 18,
					fontOutlineEnable = true,
					fontOutlineColor = "FF62423B",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "dwb2",
					posX = 0.114408,
					posY = 0.3518136,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2199357,
					sizeY = 0.4322321,
					text = "可进行追击：",
					color = "FFF7E9D6",
					fontSize = 18,
					fontOutlineEnable = true,
					fontOutlineColor = "FF62423B",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "dwb3",
					varName = "surveyText",
					posX = 0.2654765,
					posY = 0.7373202,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1128312,
					sizeY = 0.4322321,
					text = "2",
					color = "FFF7E9D6",
					fontSize = 18,
					fontOutlineEnable = true,
					fontOutlineColor = "FF62423B",
					fontOutlineSize = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "dwb4",
					varName = "receiveText",
					posX = 0.2654765,
					posY = 0.3518138,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1128312,
					sizeY = 0.4322321,
					text = "1",
					color = "FFF7E9D6",
					fontSize = 18,
					fontOutlineEnable = true,
					fontOutlineColor = "FF62423B",
					fontOutlineSize = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "wb6",
					varName = "noneClueText",
					posX = 0.6279591,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.647615,
					sizeY = 0.8032017,
					text = "尚未拥有任何线索",
					color = "FFC00000",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "jd2",
				posX = 0.870566,
				posY = 0.5915142,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1870771,
				sizeY = 0.5213656,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "wb7",
					varName = "stateText",
					posX = 0.5,
					posY = 0.8719101,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.931129,
					sizeY = 0.2017354,
					text = "尚未揭露",
					color = "FF008000",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "tips2",
					varName = "surveyBtn",
					posX = -1.505019,
					posY = 0.5038783,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1419869,
					sizeY = 0.08524622,
					image = "guiying#th",
					imageNormal = "guiying#th",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "fx2",
					varName = "chooseBtn",
					posX = 0.5,
					posY = 0.1639459,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5762998,
					sizeY = 0.1545088,
					image = "jiebai#an1",
					imageNormal = "jiebai#an1",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "fxwb2",
						varName = "chooseText",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 1,
						text = "选择",
						color = "FF964F19",
						fontSize = 24,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "fx3",
					varName = "storyBtn",
					posX = -3.485789,
					posY = 0.7952169,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.392552,
					sizeY = 0.2264353,
					image = "gzcj#qq",
					imageNormal = "gzcj#qq",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "ds",
					posX = 0.5000003,
					posY = 0.5079831,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7748554,
					sizeY = 0.4999983,
					image = "b#d2",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
				children = {
				{
					prop = {
						etype = "RichText",
						name = "wb9",
						varName = "clueDesc",
						posX = 0.4999993,
						posY = 0.4487472,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9416177,
						sizeY = 0.8471842,
						text = "可获得的线索",
						color = "FF966856",
						hTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "tops",
						posX = 0.5,
						posY = 1,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8773071,
						sizeY = 0.1918046,
						image = "chu1#top2",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wb8",
						varName = "ralation",
						posX = 0.5,
						posY = 1,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6888515,
						sizeY = 0.2754005,
						text = "相关资讯",
						color = "FF966856",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "tips3",
					varName = "leaderSurvey",
					posX = -1.404957,
					posY = 0.6474964,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1419869,
					sizeY = 0.08524622,
					image = "guiying#th",
					imageNormal = "guiying#th",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "bz",
				varName = "helpBtn",
				posX = 0.91572,
				posY = 0.1353267,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.053125,
				sizeY = 0.09444445,
				image = "chu1#bz",
				imageNormal = "chu1#bz",
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "close",
				posX = 0.9578413,
				posY = 0.9430158,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.046875,
				sizeY = 0.08055556,
				image = "guiying#gb",
				imageNormal = "guiying#gb",
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
