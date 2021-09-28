-- FileName: ProgressBar.lua
-- Author: bzx
-- Date: 15-04-01
-- Purpose: 九宫格进度条

ProgressBar = class("ProgressBar", function ( ... )
	return CCSprite:create()
end)

ProgressBar._bg = nil
ProgressBar._progress = nil
ProgressBar._progressValue = 100
ProgressBar._width = 200
ProgressBar._leftSpace = 0
ProgressBar._rightSpace = 0
ProgressBar._bgHeight = 0
ProgressBar._progressHeight = 0
ProgressBar._progressLabel = nil
ProgressBar._isScale9 = false
ProgressBar._progressFilename = nil
ProgressBar._progressSprite = nil
ProgressBar._progressInfo = nil
ProgressBar._progressEffect = nil
ProgressBar._isShowProgressEffect = nil

function ProgressBar:create( p_bgFilename, p_progressFilename, p_width, p_progressValue, p_isScale9, p_progressInfo,p_isShowEffect)
	local progressBar = ProgressBar:new()
	progressBar._width = p_width
	progressBar._isScale9 = p_isScale9
	if progressBar._isScale9 == nil then
		progressBar._isScale9 = true
	end
	progressBar._progressInfo = p_progressInfo
	progressBar._isShowProgressEffect = p_isShowEffect
	if progressBar._isShowProgressEffect == nil then
		progressBar._isShowProgressEffect = true
	end
	progressBar:loadBg(p_bgFilename)
	progressBar:loadProgressSprite(p_progressFilename)
	progressBar:setProgress(p_progressValue)
	return progressBar
end

function ProgressBar:loadBg(p_bgFilename)
	if self._isScale9 then
		self._bg = CCScale9Sprite:create(p_bgFilename)
		self._bgHeight = self._bg:getContentSize().height
		self._width = self._width or self._bg:getContentSize().width
		self._bg:setContentSize(CCSizeMake(self._width, self._bgHeight))
	else
		self._bg = CCSprite:create(p_bgFilename)
		self._width = self._width or self._bg:getContentSize().width
		self._bgHeight = self._bg:getContentSize().height
	end
	self:addChild(self._bg)
	self:setContentSize(CCSizeMake(self._width, self._bgHeight))
end

function ProgressBar:setProgressSprite( p_progressSprite )
	if self._progressSprite ~= nil then
		self._progressSprite:removeFromParentAndCleanup(true)
	end
	self._progressSprite = p_progressSprite
	self:addChild(self._progressSprite)
	self._progressHeight = self._progressSprite:getContentSize().height
	self._progressSprite:setAnchorPoint(ccp(0, 0.5))
	self._leftSpace = (self._bg:getContentSize().width - self._progressSprite:getContentSize().width) * 0.5
	self._progressSprite:setPosition(ccp(self._leftSpace, self._bg:getContentSize().height * 0.5))
	self:setProgress(self._progressValue)
end

function ProgressBar:loadProgressSprite(p_progressFilename)
	self._progressFilename = p_progressFilename
	local progressSprite = nil
	if self._isScale9 then
		progressSprite = CCScale9Sprite:create(p_progressFilename)
		progressSprite:setContentSize(CCSizeMake(self._width, progressSprite:getContentSize().height))
	else
		progressSprite = CCSprite:create(p_progressFilename)
	end
	self:setProgressSprite(progressSprite)
end

function ProgressBar:refreshProgressTip( ... )
	local progressTip = string.format("%d%%", math.ceil(self._progressValue * 100), 100)
	if self._progressLabel == nil then
		self._progressLabel = CCRenderLabel:create(progressTip, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		self:addChild(self._progressLabel, 10)
		self._progressLabel:setAnchorPoint(ccp(0.5, 0.5))
		self._progressLabel:setPosition(ccpsprite(0.5, 0.5, self._bg))
	else
		self._progressLabel:setString(progressTip)
	end
end

function ProgressBar:setProgress( p_progressValue )
	local lastProgress = self._progressValue
	self._progressValue = p_progressValue
	if self._isScale9 then
		if self._progressInfo ~= nil then
			for i = 1, #self._progressInfo do
				if lastProgress > self._progressInfo[i].progress and self._progressValue <= self._progressInfo[i].progress then
					local progressSprite = CCScale9Sprite:create(self._progressInfo[i].progressSpriteImage)
					self:setProgressSprite(progressSprite)
					break
				end
			end
		end
		self._progressSprite:setContentSize(CCSizeMake((self._width - self._leftSpace - self._rightSpace) * p_progressValue, self._progressHeight))
	else
		self._progressSprite:removeFromParentAndCleanup(true)
		self._progressSprite = CCSprite:create(self._progressFilename, CCRectMake(0, 0, self._width * p_progressValue, self._progressHeight))
		self:addChild(self._progressSprite, 3)
		self._progressSprite:setAnchorPoint(ccp(0, 0.5))
		self._progressSprite:setPosition(ccp(self._leftSpace, self:getContentSize().height * 0.5))
	end
	if p_progressValue == 0 then
		self._progressSprite:setVisible(false)
	elseif(p_progressValue > 0)then
		self._progressSprite:setVisible(true)
	else
	end
	if p_progressValue <= 0.1 and self._progressEffect == nil and self._isScale9 then
		self._progressEffect = XMLSprite:create("images/guild_boss_copy/effect/daojishi/daojishi")
		self._bg:addChild(self._progressEffect, 20)
		self._progressEffect:setAnchorPoint(ccp(0.5, 0.5))
		self._progressEffect:setPosition(ccpsprite(0.5, 0.5, self._bg))
		self._progressEffect:setVisible(self._isShowProgressEffect)
	end
	self:refreshProgressTip()
end

function ProgressBar:getProgressLabel( ... )
	return self._progressLabel 
end

--[[
	@des 	:设置是否显示百分百提示 by licong
	@param 	:true or false 
	@return :
--]]
function ProgressBar:setProgressLabelVisible( p_isShow )
	if( self._progressLabel )then
		self._progressLabel:setVisible(p_isShow)
	end
end
