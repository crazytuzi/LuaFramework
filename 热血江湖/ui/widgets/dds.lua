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
			name = "btk",
			posX = 0.5000001,
			posY = 0.9384527,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 0.1028774,
			image = "phb#top4",
			scale9 = true,
			scale9Left = 0.4,
			scale9Right = 0.4,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "btk1",
				posX = 0.07932863,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.16,
				sizeY = 1.016394,
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "z1",
					posX = 0.7469503,
					posY = 0.5064974,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.740453,
					sizeY = 0.8444229,
					text = "排 名",
					color = "FF966856",
					fontSize = 22,
					fontOutlineColor = "FF143230",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "btk2",
				posX = 0.3179442,
				posY = 0.5000004,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.28,
				sizeY = 1.016394,
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "z2",
					posX = 0.5,
					posY = 0.5064985,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8735054,
					sizeY = 0.8444229,
					text = "名 称",
					color = "FF966856",
					fontSize = 22,
					fontOutlineColor = "FF143230",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "btk3",
				posX = 0.5034775,
				posY = 0.5000001,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.16,
				sizeY = 1.016394,
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "z3",
					posX = 0.5,
					posY = 0.5064974,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.740453,
					sizeY = 0.8444229,
					text = "职 业",
					color = "FF966856",
					fontSize = 22,
					fontOutlineColor = "FF143230",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "btk4",
				posX = 0.641583,
				posY = 0.5000001,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.16,
				sizeY = 1.016394,
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "z4",
					varName = "sort_name",
					posX = 0.5323032,
					posY = 0.5064985,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.171738,
					sizeY = 0.8444229,
					text = "家园人气",
					color = "FF966856",
					fontSize = 22,
					fontOutlineColor = "FF143230",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "btk5",
				posX = 0.8641685,
				posY = 0.5000002,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.273084,
				sizeY = 1.016394,
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "z5",
					posX = 0.4193929,
					posY = 0.5064974,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.740453,
					sizeY = 0.8444229,
					text = "称 号",
					color = "FF966856",
					fontSize = 22,
					fontOutlineColor = "FF143230",
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
