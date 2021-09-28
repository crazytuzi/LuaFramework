
-- Filename：	RobLayer.lua
-- Author：		Cheng Liang
-- Date：		2013-8-3
-- Purpose：		比武

module ("RobLayer", package.seeall)

require "script/network/RequestCenter"
require "script/model/DataCache"
require "script/ui/main/MainScene"


local _bgLayer = nil

local function init( )
	_bgLayer = nil
end 


function createLayer()
	_bgLayer = MainScene.createBaseLayer("images/main/module_bg.png")

	return _bgLayer
end 

