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
				posY = 0.4791665,
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
					posY = 0.5568241,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8424596,
					sizeY = 1.067253,
					image = "b#cs",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.2,
					scale9Bottom = 0.7,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "close_btn",
					posX = 0.8873598,
					posY = 1.019894,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.06600985,
					sizeY = 0.1310345,
					image = "chu1#gb",
					imageNormal = "chu1#gb",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "jie",
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
						name = "dw",
						posX = 0.5,
						posY = 0.8839954,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8570836,
						sizeY = 0.2065857,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "mswz",
							varName = "des",
							posX = 0.5048024,
							posY = 0.5714518,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8825186,
							sizeY = 0.8929939,
							text = "已解锁的属性条目需要设置选目标属性以及属性品质(支援属性多选)，才可以进行自动洗练，自动洗练过程中，任意1条洗炼属性满足设置属性，即停止当前自动洗炼(锁定的属性不参与洗练)。洗练期间可以随时手动停止洗练。",
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
						name = "d5",
						posX = 0.5,
						posY = 0.5740057,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7475414,
						sizeY = 0.478524,
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
						scale9Top = 0.4,
						scale9Bottom = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "dt3",
							posX = 0.5006946,
							posY = 0.5109407,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9854481,
							sizeY = 0.9709235,
							image = "zqxl#jgg1",
							scale9 = true,
							scale9Left = 0.4,
							scale9Right = 0.4,
							scale9Top = 0.4,
							scale9Bottom = 0.4,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "dt2",
							posX = 0.6065759,
							posY = 0.8771738,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7684178,
							sizeY = 0.2378002,
							image = "zqxl#jgg2",
							scale9 = true,
							scale9Left = 0.4,
							scale9Right = 0.4,
							scale9Top = 0.4,
							scale9Bottom = 0.4,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "dt1",
							posX = 0.1256956,
							posY = 0.510941,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.2346141,
							sizeY = 0.9709235,
							image = "b#d5",
							scale9 = true,
							scale9Left = 0.4,
							scale9Right = 0.4,
							scale9Top = 0.4,
							scale9Bottom = 0.4,
						},
					},
					{
						prop = {
							etype = "Scroll",
							name = "lb2",
							varName = "scollList",
							posX = 0.6249985,
							posY = 0.4099288,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6763144,
							sizeY = 0.7479262,
						},
					},
					{
						prop = {
							etype = "Scroll",
							name = "lb",
							varName = "scroll",
							posX = 0.1252775,
							posY = 0.5144122,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.2346141,
							sizeY = 0.9028795,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "gxd1",
						posX = 0.7842752,
						posY = 0.2899855,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.02955665,
						sizeY = 0.05172414,
						image = "chu1#gxd",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "dj",
							varName = "py",
							posX = 0.5333333,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.266667,
							sizeY = 1.133333,
							image = "chu1#dj",
						},
					},
					{
						prop = {
							etype = "Button",
							name = "gxan",
							varName = "powerYbt",
							posX = 0.5004669,
							posY = 0.5000005,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.333059,
							sizeY = 1.555168,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "gxz1",
							posX = -0.8517865,
							posY = 0.534145,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.299775,
							sizeY = 1.198001,
							text = "是",
							color = "FFBB7C4E",
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
						name = "gxd2",
						posX = 0.860997,
						posY = 0.2899855,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.02955665,
						sizeY = 0.05172414,
						image = "chu1#gxd",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "dj2",
							varName = "pn",
							posX = 0.5333333,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.266667,
							sizeY = 1.133333,
							image = "chu1#dj",
						},
					},
					{
						prop = {
							etype = "Button",
							name = "gxan2",
							varName = "powerNbt",
							posX = 0.5004669,
							posY = 0.5000005,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.333059,
							sizeY = 1.555168,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "gxz2",
							posX = -0.8517865,
							posY = 0.534145,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.299775,
							sizeY = 1.198001,
							text = "否",
							color = "FFBB7C4E",
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
						name = "gxd3",
						posX = 0.7842752,
						posY = 0.2108888,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.02955665,
						sizeY = 0.05172414,
						image = "chu1#gxd",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "dj3",
							varName = "ly",
							posX = 0.5333333,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.266667,
							sizeY = 1.133333,
							image = "chu1#dj",
						},
					},
					{
						prop = {
							etype = "Button",
							name = "gxan3",
							varName = "lockYbt",
							posX = 0.5004669,
							posY = 0.5000005,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.333059,
							sizeY = 1.555168,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "gxz3",
							posX = -0.8517865,
							posY = 0.534145,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.299775,
							sizeY = 1.198001,
							text = "是",
							color = "FFBB7C4E",
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
						name = "gxd4",
						posX = 0.860997,
						posY = 0.2108888,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.02955665,
						sizeY = 0.05172414,
						image = "chu1#gxd",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "dj4",
							varName = "ln",
							posX = 0.5333333,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.266667,
							sizeY = 1.133333,
							image = "chu1#dj",
						},
					},
					{
						prop = {
							etype = "Button",
							name = "gxan4",
							varName = "lockNbt",
							posX = 0.5004669,
							posY = 0.5000005,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.333059,
							sizeY = 1.555168,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "gxz4",
							posX = -0.8517865,
							posY = 0.534145,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.299775,
							sizeY = 1.198001,
							text = "否",
							color = "FFBB7C4E",
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
						name = "d2",
						posX = 0.4309246,
						posY = 0.2908505,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5975374,
						sizeY = 0.06896552,
						image = "b#d2",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "wb2",
							varName = "powerDes",
							posX = 0.5004124,
							posY = 0.5311646,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9942487,
							sizeY = 0.9682487,
							text = "洗练过程中，战力升高是否自动保存？",
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
						name = "d3",
						posX = 0.4309246,
						posY = 0.2134905,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5975374,
						sizeY = 0.06896552,
						image = "b#d2",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "wb3",
							varName = "lockDes",
							posX = 0.5004124,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9942487,
							sizeY = 0.9682487,
							text = "洗练过程中，锁定属性数值提升，是否自动保存？",
							color = "FF966856",
							fontSize = 18,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Button",
						name = "btna2",
						varName = "preview",
						posX = 0.25,
						posY = 0.1023684,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1451074,
						sizeY = 0.09632123,
						image = "chu1#an2",
						imageNormal = "chu1#an2",
						disablePressScale = true,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "top2z4",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7589157,
							sizeY = 1.483045,
							text = "设置预览",
							fontSize = 22,
							fontOutlineEnable = true,
							fontOutlineColor = "FF347468",
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
						name = "btna",
						varName = "sureBtn",
						posX = 0.75,
						posY = 0.1023684,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1451074,
						sizeY = 0.09632123,
						image = "chu1#an1",
						imageNormal = "chu1#an1",
						disablePressScale = true,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "top2z3",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7589157,
							sizeY = 1.483045,
							text = "保存设置",
							fontSize = 22,
							fontOutlineEnable = true,
							fontOutlineColor = "FFB35F1D",
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
		{
			prop = {
				etype = "Image",
				name = "top",
				posX = 0.5,
				posY = 0.9015715,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2059108,
				sizeY = 0.06011602,
				image = "chu1#top2",
				scale9Left = 0.45,
				scale9Right = 0.4,
				alpha = 0.8,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "wb",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9454169,
					sizeY = 1.343948,
					text = "自动洗练设置",
					color = "FFF1E9D7",
					fontSize = 22,
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
				name = "yblb2",
				posX = 0.5698065,
				posY = 0.691358,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4453616,
				sizeY = 0.07210371,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "y2",
					posX = 0.2342926,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5256069,
					sizeY = 1.063695,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "kk3",
						posX = 0.2498593,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1232973,
						sizeY = 0.6690063,
						image = "fj#xz",
					},
					children = {
					{
						prop = {
							etype = "Button",
							name = "gxan6",
							varName = "allselect",
							posX = 0.5025076,
							posY = 0.500017,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 1.062153,
							sizeY = 0.9503471,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "k",
							varName = "allselectImg",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 1.028599,
							sizeY = 0.9203257,
							image = "chu1#dj",
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "kkk2",
						posX = 0.7801509,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5640309,
						sizeY = 0.6700305,
						image = "zqxl#di1",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "wb7",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.07343,
							sizeY = 1.393533,
							text = "全部属性",
							color = "FF966856",
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
					name = "dk2",
					posX = 0.7863857,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3223589,
					sizeY = 0.712708,
					image = "zqxl#di1",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wb8",
						varName = "allTxt",
						posX = 0.4231418,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.088347,
						sizeY = 1.145833,
						text = "蓝色品质以上",
						color = "FF0DC3FF",
						fontOutlineColor = "FFAA654A",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "dan",
						varName = "allquality",
						posX = 0.5,
						posY = 0.4993007,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9887741,
						sizeY = 1.081555,
						propagateToChildren = true,
					},
					children = {
					{
						prop = {
							etype = "Button",
							name = "xzan2",
							posX = 0.9020106,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1320845,
							sizeY = 0.4747919,
							image = "zqxl#jiantou",
							imageNormal = "zqxl#jiantou",
							disableClick = true,
						},
					},
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "fl2",
				varName = "scroll2_root",
				posX = 0.7018644,
				posY = 0.6604017,
				anchorX = 0.5,
				anchorY = 1,
				visible = false,
				sizeX = 0.1532775,
				sizeY = 0.3115501,
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "mask",
					varName = "mask",
					posX = -0.9745561,
					posY = 0.4804367,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 7.28723,
					sizeY = 3.197059,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "fl3",
					varName = "scroll2_bg",
					posX = 0.4999949,
					posY = 0.4930967,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1.012623,
					image = "b#bp",
					scale9 = true,
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb3",
					varName = "scroll2",
					posX = 0.499995,
					posY = 0.4994081,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
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
	c_dakai = {
		{0,"dk", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
