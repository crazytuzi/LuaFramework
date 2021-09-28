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
			name = "k",
			varName = "rootGird",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.06640625,
			sizeY = 0.1180556,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "db",
				varName = "bg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "xingpan#tcd1",
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xingyao",
				varName = "x1",
				posX = 0.2482504,
				posY = 0.7393442,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.2215864,
				sizeY = 0.2357301,
				image = "xingpan#huix",
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xingyao2",
				varName = "x2",
				posX = 0.4996814,
				posY = 0.7393442,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2215864,
				sizeY = 0.2357301,
				image = "xingpan#huix",
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xingyao3",
				varName = "x3",
				posX = 0.7511125,
				posY = 0.7393442,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2215864,
				sizeY = 0.2357301,
				image = "xingpan#huix",
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xingyao4",
				varName = "x4",
				posX = 0.2482504,
				posY = 0.4937737,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2215864,
				sizeY = 0.2357301,
				image = "xingpan#huix",
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xingyao5",
				varName = "x5",
				posX = 0.4996811,
				posY = 0.4937735,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2215864,
				sizeY = 0.2357301,
				image = "xingpan#huix",
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xingyao6",
				varName = "x6",
				posX = 0.7511125,
				posY = 0.4937735,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2215864,
				sizeY = 0.2357301,
				image = "xingpan#huix",
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xingyao7",
				varName = "x7",
				posX = 0.2482504,
				posY = 0.2482336,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2215864,
				sizeY = 0.2357301,
				image = "xingpan#huix",
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xingyao8",
				varName = "x8",
				posX = 0.4996811,
				posY = 0.2482333,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2215864,
				sizeY = 0.2357301,
				image = "xingpan#huix",
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xingyao9",
				varName = "x9",
				posX = 0.7511125,
				posY = 0.2482333,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2215864,
				sizeY = 0.2357301,
				image = "xingpan#huix",
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
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
