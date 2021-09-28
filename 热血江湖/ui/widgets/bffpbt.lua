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
			lockHV = true,
			sizeX = 0.5009849,
			sizeY = 0.1263873,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "bffpt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.98,
				sizeY = 0.95,
				image = "b#lbt",
				scale9 = true,
				scale9Left = 0.2,
				scale9Right = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "wpk",
					varName = "item_bg",
					posX = 0.07300849,
					posY = 0.4713873,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1136536,
					sizeY = 0.8348948,
					image = "djk#klan",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "wp",
						varName = "item_icon",
						posX = 0.4950709,
						posY = 0.5452672,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7995595,
						sizeY = 0.7980609,
						image = "items#items_zhongjilianbaozhen.png",
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z1",
					varName = "name",
					posX = 0.3028415,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.270401,
					sizeY = 0.7419568,
					text = "名字一二三四",
					color = "FF966856",
					fontSize = 22,
					fontOutlineColor = "FF17372F",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xian",
					posX = 0.1520876,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.00477376,
					sizeY = 0.9,
					image = "b#shuxian",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z2",
					varName = "time_label",
					posX = 0.5872064,
					posY = 0.4999999,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.270401,
					sizeY = 0.7419568,
					text = "07-05  20:45",
					color = "FF966856",
					fontOutlineColor = "FF17372F",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z3",
					posX = 0.8573942,
					posY = 0.4999999,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.270401,
					sizeY = 0.7419568,
					text = "系统自动分配",
					color = "FFC93034",
					fontOutlineColor = "FF17372F",
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
