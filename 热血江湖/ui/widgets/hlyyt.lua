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
			name = "jd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.6458114,
			sizeY = 0.1141472,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dib",
				varName = "tHide",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "jh5#db1",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				effect = "tShow",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dib2",
				varName = "tShow",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "jh5#db2",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				effect = "tHide",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zyd",
				varName = "btnIcon",
				posX = 0.0470605,
				posY = 0.4634372,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.05178942,
				sizeY = 0.5322295,
				image = "ty#zyd",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dj",
				varName = "isShow",
				posX = 0.05959924,
				posY = 0.5075073,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.08211535,
				sizeY = 0.6144099,
				image = "ty#xzjt",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "sjd",
				varName = "time",
				posX = 0.226512,
				posY = 0.5000004,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2353776,
				sizeY = 0.8679304,
				text = "时间段",
				color = "FF966856",
				fontSize = 22,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "kyy",
				varName = "label2",
				posX = 0.411198,
				posY = 0.4583977,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1106226,
				sizeY = 0.9657052,
				text = "可预约",
				color = "FF966856",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "yyy2",
				varName = "label3",
				posX = 0.411198,
				posY = 0.4583429,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1064552,
				sizeY = 0.5962088,
				image = "jh5#yyy",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "yyy3",
				varName = "label1",
				posX = 0.411198,
				posY = 0.4583429,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1064552,
				sizeY = 0.5962088,
				image = "jh5#ygq",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "yb",
				varName = "moneyIcon",
				posX = 0.5145169,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.06924871,
				sizeY = 0.6965135,
				image = "tb#yuanbao",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "skz",
					varName = "moneyCount",
					posX = 2.588972,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 3.184142,
					sizeY = 1.034625,
					text = "x222",
					color = "FF634624",
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz1",
				varName = "mName",
				posX = 0.6693853,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2353658,
				sizeY = 1.06265,
				text = "名字已七个字",
				color = "FF966856",
				hTextAlign = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz2",
				varName = "gName",
				posX = 0.9551893,
				posY = 0.5000002,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2353658,
				sizeY = 1.06265,
				text = "名字已七个字",
				color = "FF966856",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "txa",
				posX = 0.8118185,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0326624,
				sizeY = 0.2920206,
				image = "rw#tx",
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
