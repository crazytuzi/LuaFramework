-- Filename：	XMLSprite.lua
-- Author：		lichenyang
-- Date：		2015-3-24
-- Purpose：		特效动画解析模块
require "script/utils/extern"
require "script/utils/LuaUtil"
require "script/animation/AnimationXML"

XMLSprite = class("XMLSprite",function ()
	return CCSprite:create()
end)

XMLSprite.__index = XMLSprite

function XMLSprite:ctor( ... )
	self.childArray       = {}		--子节点
	self.xmlData          = {} 		--子节点数据
	self.name             = nil 	--动画名称
	self.layerCount       = 0 		--动画层数
	self.batchNode        = nil		--batch父节点
	self.frameIndex       = 0 		--当前动画帧数
	self.fps              = 30 		--默认fps30帧
	self.updateSchedule   = nil 	--定时器
	self.keyFrameCallback = nil		--关键帧回调
	self.endCallback      = nil 	--结束回调
	self.playCount		  = -1		--总播放次数
	self.playTimes 		  = 0 		--当前播放次数
	self.isUseBatch		  = false 	--是否使用batch作为父节点
	self.isAutoClean      = true 	--播放次数完成之后是否清楚自己
end

--[[
	@des:创建特效
	@parm :p_effectPath 特效路径 如果p_effectPath 是个图片路径，则创建一个sprite
	@parm :p_fps 设置默认fps 如果不设置，默认为30
	@parm :p_isBatch  是否使用batchNode 渲染 如果不设置，默认为true
	@ret: sprite
--]]
function XMLSprite:create( p_effectPath, p_fps, p_isBatch )
	local childSprite = XMLSprite:new()
	if 	string.find(p_effectPath, ".png") == nil and
		string.find(p_effectPath, ".jpg") == nil and
		string.find(p_effectPath, ".pvr") == nil and
		string.find(p_effectPath, ".pvr.ccz") == nil then
			childSprite:initWithXml(p_effectPath, p_fps, p_isBatch)
	else
		local texture = CCTextureCache:sharedTextureCache():addImage(p_effectPath)
		local size = texture:getContentSize()
		local spriteFrame = CCSpriteFrame:create(p_effectPath, CCRect(0, 0, size.width, size.height))
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFrame(spriteFrame, p_effectPath)
		childSprite:setDisplayFrame(spriteFrame)
	end
	return childSprite
end

function XMLSprite:initWithXml( p_effectPath, p_fps, p_isBatch )
	--load image
	local plistName 	= p_effectPath..".plist"
	local fullPlistPath = CCFileUtils:sharedFileUtils():fullPathForFilename(plistName)
    local dict 			= CCDictionary:createWithContentsOfFile(fullPlistPath)
    local metadataDict 	= tolua.cast(dict:objectForKey("metadata"), "CCDictionary")
 	local textureName 	= metadataDict:valueForKey("textureFileName"):getCString()
 	local texturePath 	= CCFileUtils:sharedFileUtils():fullPathFromRelativeFile(textureName, plistName)
 	
	self.fps = p_fps or self.fps
	if p_isBatch ~= nil then
		self.isUseBatch = p_isBatch
	end
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(plistName)

	--load xml
	self.xmlData = AnimationXML:new()
	self.xmlData:load(p_effectPath)

	--create BatchNode
	if self.isUseBatch then
		self.batchNode = CCSpriteBatchNode:create(texturePath)
	else
		self.batchNode = CCSprite:create()
	end
	self:addChild(self.batchNode)

	local animationData = self.xmlData:getXmlData()
	
	-- init child array
	for k,v in pairs(animationData) do
		self.childArray[k] = {}
	end
	-- add child sprite
	for layerName,layerData in pairs(animationData) do
		local bitmapNames = self.xmlData:getBitmapNames(layerName)
		for k,v in pairs(bitmapNames) do
			local pFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(v..".png")
			if pFrame then
				local sprite = CCSprite:createWithSpriteFrame(pFrame)
				sprite:setPosition(5000, 5000)
				sprite:setAnchorPoint(ccp(0.5, 0.5))
				local zOrder = self.xmlData:getLayerIndex(layerName)
				-- print(v..".png")
				self.batchNode:addChild(sprite, zOrder)
				self.childArray[layerName][v] = sprite
			else
				print("XMLSprite Alert: not find frame:", v..".png")
			end
		end
	end
	
	--tick
	local updateTimer = function ( ... )
		local keyName = nil
		for layerName,layerData in pairs(animationData) do		
			local frameInfo = layerData[self.frameIndex]
			for k,v in pairs(self.childArray[layerName]) do
				v:setVisible(false)
			end
			if frameInfo then
				local spriteName = frameInfo.bitmapName

				if spriteName ~= nil then
					local sprite = self.childArray[layerName][spriteName]
					if sprite then
						sprite:setVisible(true)
						sprite:setPosition(tonumber(frameInfo.posX), -tonumber(frameInfo.posY)) --在flash中y的正方形是朝向屏幕下边的，而cocos中是朝向屏幕上边的
						sprite:setScaleX(tonumber(frameInfo.scaleX))
						sprite:setScaleY(tonumber(frameInfo.scaleY))
						sprite:setOpacity(tonumber(frameInfo.alpha))
						sprite:setRotation(tonumber(frameInfo.rotation))
						--斜切兼容
						if tonumber(frameInfo.rotationX) ~= 0 or tonumber(frameInfo.rotationY) ~= 0 then
							if sprite.setRotationX ~= nil and sprite.setRotationY ~= nil then
								sprite:setRotationX(tonumber(frameInfo.rotationX))
								sprite:setRotationY(tonumber(frameInfo.rotationY))
							end
						end
					end
				end
				if frameInfo.isKeyFrame and self.keyFrameCallback then
					keyName = frameInfo.isKeyFrame
				end
			end
		end
		if keyName then
			self.keyFrameCallback(keyName)
		end
		self.frameIndex = self.frameIndex + 1
		if self.frameIndex > self.xmlData:getMaxFrameCount()-1 then
			self.frameIndex = 0
			--增加播放次数
			self.playTimes = self.playTimes + 1
			--播放结束回调
			if self.endCallback then
				self.endCallback()
			end
			--播放次数到达上限
			if not tolua.isnull(self) and self.playCount >0 and self.playTimes >= self.playCount then
				self:stop()
				--是否需要清楚自己
				if self.isAutoClean then
					self:removeFromParentAndCleanup(true)
				end
				return
			end
		end
	end
	self:registerScriptHandler(function ( nodeType )
		if (nodeType == "enter") then
			self.updateSchedule = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateTimer, 1/self.fps, false)
		elseif(nodeType == "exit") then
			self:stop()
		end
	end)
end

--[[
	@des: 特好动画中的spriteFrame,要使用此法方法，创建动画时isUseBatch必须为false
	@parm: p_keyName frame名称
	@parm: p_fileName 要替换的图片路径
--]]
function XMLSprite:replaceImage( p_keyName, p_fileName )
	self.childArray = self.childArray  or {}
	for k,v in pairs(self.childArray) do
		if v[p_keyName] then
			local texture = CCTextureCache:sharedTextureCache():addImage(p_fileName)
			local size = texture:getContentSize()
			local spriteFrame = CCSpriteFrame:createWithTexture(texture, CCRectMake(0, 0, size.width, size.height))
			v[p_keyName]:setDisplayFrame(spriteFrame)
		end
	end
end

--[[
	@des:得到特效中图元
	@parm：pFrameName 图元名称
--]]
function XMLSprite:getFrameByName( pFrameName )
	local retSprite = nil
	self.childArray = self.childArray  or {}
	for k,v in pairs(self.childArray) do
		if v[pFrameName] then
			retSprite = v[pFrameName]
			break 
		end
	end
	return retSprite
end

--[[
	@des:停止动画播放，停止后无法重新开始
--]]
function XMLSprite:stop()
	if self.updateSchedule then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.updateSchedule)
	end
	self.endCallback = nil
	self.keyFrameCallback = nil
end

--[[
	@des:得到关键帧总数
	@parm:void
	@ret:number
--]]
function XMLSprite:getKeyFrameCount()
	return self.xmlData:getKeyFrameCount()
end

--[[
	@des:设置动画播放的循环次数
	@armm: p_times 次数
--]]
function XMLSprite:setReplayTimes( p_times, p_autoClean )
	self.playCount = p_times
	self.isAutoClean = p_autoClean or false
end

--[[
	@des:动画每一个循环播放结束回调
	@parm: p_callback 回调方法
--]]
function XMLSprite:registerEndCallback( p_callback )
	self.endCallback = p_callback
end

--[[
	@des:动画每一个关键帧播放结束回调
	@parm: p_callback 回调方法
--]]
function XMLSprite:registerKeyFrameCallback( p_callback )
	self.keyFrameCallback = p_callback
end
