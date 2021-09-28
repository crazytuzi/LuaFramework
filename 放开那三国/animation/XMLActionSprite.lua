-- Filename：	XMLAction.lua
-- Author：		lichenyang
-- Date：		2015-3-24
-- Purpose：		特效动画解析模块
require "script/utils/extern"
require "script/utils/LuaUtil"
require "script/animation/AnimationXML"

XMLActionSprite = class("XMLActionSprite", function ( ... )
	return CCSprite:create()
end)

function XMLActionSprite:ctor( ... )
	self._xmlData          	= {} 		--子节点数据
	self._frameIndex		= 0
	self._basePointX		= nil
	self._basePointY		= nil
	self._baseScaleX		= nil
	self._baseScaleY		= nil
	self._baseRotation		= nil
	self._baseOpactiy 		= nil
	self._isRunning			= false
	self._endCallback		= nil
	self._scheduleArray     = {}
end


function XMLActionSprite:create( pImagePath )
	local instance = XMLActionSprite:new()
	instance:setAnchorPoint(ccp(0.5, 0))
	--init texture
	instance:initWithFile(pImagePath)
	return instance
end

function XMLActionSprite:initWithFile( pImagePath )
	local texture = CCTextureCache:sharedTextureCache():addImage(pImagePath)
	local size = texture:getContentSize()
	local spriteFrame = CCSpriteFrame:create(pImagePath, CCRect(0, 0, size.width, size.height))
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFrame(spriteFrame, pImagePath)
	self:setDisplayFrame(spriteFrame)
end



--[[
	@des:播放一个xml动作
	@parm: pXmlPath,xml动作路径
	@parm: pIsLoop 是否循环播放
--]]
function XMLActionSprite:runXMLAction( pXmlPath, pIsLoop )
	
	if self._isRunning then
		if self._endCallback then
			self._endCallback()
			self._endCallback = nil
		end
		self:stop()
	else
		self._isRunning = true
	end
	--init data
	local animaXML = AnimationXML:new()
	animaXML:loadXml(pXmlPath)
	self._xmlData = animaXML:getXmlData()
	if tolua.isnull(self) then
		return
	end
	self._basePointX, self._basePointY = self:getPosition()
	self._baseScaleX = self:getScaleX()
	self._baseScaleY = self:getScaleY()
	self._baseRotation = self:getRotation()
	self._baseOpacity = self:getOpacity()
	self._frameIndex = 0
	--tick = 1
	local updateTimer = function ( ... )
		if tolua.isnull(self) == true then
			return
		end
		for layerName,layerData in pairs(self._xmlData) do		
			local frameInfo = layerData[self._frameIndex]
			if frameInfo then
				local spriteName = frameInfo.bitmapName
				if spriteName ~= nil then
					self:setPosition(self._basePointX + frameInfo.posX, self._basePointY-frameInfo.posY) --在flash中y的正方形是朝向屏幕下边的，而cocos中是朝向屏幕上边的
					self:setScaleX(self._baseScaleX * frameInfo.scaleX)
					self:setScaleY(self._baseScaleY * frameInfo.scaleY)
					self:setOpacity(frameInfo.alpha)
					self:setRotation(frameInfo.rotation)
				end
				if frameInfo.isKeyFrame and self._keyCallback then
					self._keyCallback()
				end
			end
		end
		if self._changeCallback then
			self._changeCallback()
		end	
		self._frameIndex = self._frameIndex + 1
		if self._frameIndex > animaXML:getMaxFrameCount() then
			self._frameIndex = 0
			--播放次数到达上限
			if pIsLoop == false or pIsLoop == nil then
				self:stop()
			end
			if self._endCallback then
				self._endCallback()
			end
			if pIsLoop == false or pIsLoop == nil then
				-- print("remove schedule:", tostring(self._endCallback))
				self._keyCallback = nil
				self._isRunning = false
				self._endCallback = nil
			end
		end
	end
	self:registerScriptHandler(function ( nodeType )
		if(nodeType == "exit") then
			for k,v in pairs(self._scheduleArray) do
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(v)
			end
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.updateSchedule)
			self._scheduleArray = {}
		end
	end)
	self.updateSchedule = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateTimer, 1/30, false)
	table.insert(self._scheduleArray, self.updateSchedule)
end

--[[
	@des:停止动画播放，停止后无法重新开始
--]]
function XMLActionSprite:stop()
	if not tolua.isnull(self) then
		self:setPosition(self._basePointX or 0, self._basePointY or 0)
		self:setScaleX(self._baseScaleX or 1)
		self:setScaleY(self._baseScaleY or 1)
		self:setOpacity(self._baseOpacity or 255)
		self:setRotation(self._baseRotation or 0)
		print("self._baseScaleX",self._baseScaleX)
		print("self._baseScaleY",self._baseScaleY)
		print("self._baseRotation",self._baseRotation)
		print("self._baseOpacity",self._baseOpacity)
		print("self._basePointX",self._basePointX)
		print("self._basePointY",self._basePointY)
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.updateSchedule)
		for k,v in pairs(self._scheduleArray) do
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(v)
		end
		self._scheduleArray = {}
	end
end

--[[
	@des:停止定时器
--]]
function XMLActionSprite:stopSchedule()
	if self.updateSchedule then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.updateSchedule)
	end
end

--[[
	@des:注册播放结束回调
--]]
function XMLActionSprite:registerActionEndCallback( pCallback )
	self._endCallback = pCallback
end

--[[
	@des:注册关键帧回调
--]]
function XMLActionSprite:registerActionKeyFramCallback( pCallback )
	self._keyCallback = pCallback
end
