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
			etype = "Grid",
			name = "xsysjm",
			varName = "roleInfoUI",
			posX = 0.5,
			posY = 0.75,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 0.5,
			layoutType = 7,
			layoutTypeW = 7,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dk",
				posX = 0.1455064,
				posY = 0.159916,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2800065,
				sizeY = 0.486228,
				image = "b#rwd",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "smd",
				posX = 0.1186117,
				posY = 0.3041038,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.2961404,
				sizeY = 0.1590105,
				scale9 = true,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
				alpha = 0.5,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "vs",
					varName = "nameImage",
					posX = 0.6454584,
					posY = 0.05629743,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 1.084262,
					sizeY = 2.65531,
					image = "zxd#zxd",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sz1",
					varName = "decent",
					posX = 0.7403116,
					posY = 0.639607,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2888854,
					sizeY = 0.8122289,
					text = "66666",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FF946D26",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sz2",
					varName = "villain",
					posX = 0.4523805,
					posY = 0.6570514,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2764279,
					sizeY = 0.8122289,
					text = "66666",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FF6846A2",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "d",
				posX = 0.1220525,
				posY = 0.1150303,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.289259,
				sizeY = 0.2246307,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "an",
					varName = "task_btn",
					posX = 0.5615658,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.858885,
					sizeY = 1,
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "z1",
					varName = "taskName",
					posX = 0.5392357,
					posY = 0.3966174,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8628632,
					sizeY = 0.5,
					text = "击杀目标xxx0/10",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "z3",
					varName = "taskDesc",
					posX = 0.5392357,
					posY = -0.06115448,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8628632,
					sizeY = 0.5,
					text = "击杀目标xxx0/10",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jdtd",
					varName = "other_sideImg",
					posX = 0.7993237,
					posY = 0.3966173,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.3781214,
					sizeY = 0.2225876,
				},
				children = {
				{
					prop = {
						etype = "LoadingBar",
						name = "jdt1",
						varName = "self_side",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 1.185714,
						sizeY = 0.8888888,
						image = "zd#xt2",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xk",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 1.2,
						sizeY = 0.9999999,
						image = "zd#xk",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jdtd2",
					varName = "self_sideImg",
					posX = 0.7993237,
					posY = -0.06115448,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.3781214,
					sizeY = 0.2225876,
					image = "zd#ybxd",
				},
				children = {
				{
					prop = {
						etype = "LoadingBar",
						name = "jdt2",
						varName = "other_side",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.185714,
						sizeY = 0.8888888,
						image = "zd#xt",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xk2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 1.2,
						sizeY = 0.9999999,
						image = "zd#xk",
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
	c_dakai = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
