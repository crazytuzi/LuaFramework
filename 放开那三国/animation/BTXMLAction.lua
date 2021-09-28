-- Filename：	BTXMLAction.lua
-- Author：		lichenyang
-- Date：		2015-3-24
-- Purpose：		特效动画解析模块
require "script/utils/extern"
require "script/utils/LuaUtil"
require "script/animation/AnimationXML"

BTXMLAction = class("BTXMLAction")

function BTXMLAction:ctor( ... )
	self._xmlData        = {}
	self._targetSprite   = nil
	self._endCallback    = nil
	self._keyCallback    = nil
	self._changeCallback = nil
	self._isLoop		 = nil
end

function BTXMLAction:create( pActionXMLPath )
	local animaXML = AnimationXML:new()
	animaXML:loadXml(pXmlPath)
	self._xmlData = animaXML:getXmlData()
end

--[[
	@des:得到动画数据
	@parm: pCallback function 
--]]
function BTXMLAction:getXmlData()
	return self._xmlData
end

--[[
	@des:设置目标节点
--]]
function BTXMLAction:setTargetSprite( pSprite )
	self._targetSprite = pSprite
end

--[[
	@des:是否循环播放
	@parm: pCallback function 
--]]
function BTXMLAction:setIsLoop( pIsLoop )
	self._isLoop = pIsLoop
end
--[[
	@des:是否循环播放
	@parm: pCallback function 
--]]
function BTXMLAction:getIsLoop( pIsLoop )
	return self._isLoop
end

--[[
	@des:动作完成回调
	@parm: pCallback function 
--]]
function BTXMLAction:registerActionEndCallback( pCallback )
	self._endCallback = pCallback
end

--[[
	@des:关键帧回调注册
	@parm: pCallback function 
--]]
function BTXMLAction:registerActionKeyCallback( pCallback )
	self._keyCallback = pCallback
end

--[[
	@des:每次帧改变回调注册
	@parm: pCallback function 
--]]
function BTXMLAction:registerActionChangeCallback( pCallback )
	self._changeCallback = pCallback
end