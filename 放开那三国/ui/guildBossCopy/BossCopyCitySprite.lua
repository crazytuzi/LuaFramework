-- FileName: BossCopyCitySprite.lua
-- Author: bzx
-- Date: 15-04-01
-- Purpose: 军团副本城

require "script/utils/extern"
require "db/DB_GroupCopy"
require "script/ui/guildBossCopy/ProgressBar"

BossCopyCitySprite = class("BossCopyCitySprite", function ( ... )
	return CCSprite:create()
end)

BossCopyCitySprite._id = 0
BossCopyCitySprite._userInfo = {}
BossCopyCitySprite._groupCopyDb = {}
BossCopyCitySprite._touchPriority = -180
BossCopyCitySprite._clickCallback = nil
BossCopyCitySprite._HpProgressSprite = nil

function BossCopyCitySprite:createById(p_id, p_touchPriority, p_clickCallback)
	local bossCopyCitySprite = BossCopyCitySprite:new()
	bossCopyCitySprite:initData(p_id, p_touchPriority, p_clickCallback)
	bossCopyCitySprite:loadBaseUI()
	bossCopyCitySprite:loadFlag()
	bossCopyCitySprite:laodOpenTip()
	bossCopyCitySprite:loadName()
	bossCopyCitySprite:refreshHp()
	return bossCopyCitySprite
end

function BossCopyCitySprite:initData(p_id, p_touchPriority, p_clickCallback)
	self._id = p_id
	self._userInfo = GuildBossCopyData.getUserInfo()
	self._groupCopyDb = DB_GroupCopy.getDataById(p_id)
	self._touchPriority = p_touchPriority or -180
	self._clickCallback = p_clickCallback
end

function BossCopyCitySprite:loadBaseUI( ... )
	local menu = BTSensitiveMenu:create()
	self:addChild(menu)
	menu:setPosition(ccp(0, 0))
	menu:setTouchPriority(self._touchPriority)
	local normal = self:getCitySprite(self._id)
	local menuItem = CCMenuItemSprite:create(normal, normal)
	menu:addChild(menuItem)
	menuItem:setTag(self._id)
	menuItem:registerScriptTapHandler(self._clickCallback)
	self:setContentSize(normal:getContentSize())
end

function BossCopyCitySprite:getCitySprite(p_groupCopyId)
	local citySprite = nil
	local maxPassCopyId = tonumber(GuildBossCopyData.getUserInfo().max_pass_copy)
	local groupCopyDb = DB_GroupCopy.getDataById(p_groupCopyId)
	local fileName = "images/guild_boss_copy/boss_copy/" .. groupCopyDb.city_picture
	if maxPassCopyId + 1 < p_groupCopyId then
		citySprite = BTGraySprite:create(fileName)
	else
		citySprite = CCSprite:create(fileName)
	end
	return citySprite
end

function BossCopyCitySprite:loadName( ... )
	local nameBg = CCScale9Sprite:create("images/common/bg/bg2.png")
	self:addChild(nameBg)
	--nameBg:setContentSize(CCSizeMake(209, 49))
	nameBg:setAnchorPoint(ccp(0.5, 1))
	nameBg:setPosition(ccp(self:getContentSize().width * 0.5, 0))
	local name = CCRenderLabel:create(string.format(GetLocalizeStringBy("key_10060"), self._groupCopyDb.id, self._groupCopyDb.des), g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	nameBg:addChild(name)
	name:setAnchorPoint(ccp(0.5, 0.5))
	name:setPosition(ccpsprite(0.5, 0.5, nameBg))
	name:setColor(ccc3(0xff, 0xf6, 0x00))
end

function BossCopyCitySprite:laodOpenTip( ... )
	if self._id > tonumber(self._userInfo.max_pass_copy) + 1 then
		local lastId = self._id - 1
		local groupCopyDb = DB_GroupCopy.getDataById(lastId)
		local tip = CCRenderLabel:create(string.format(GetLocalizeStringBy("key_10061"), groupCopyDb.des), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		self:addChild(tip)
		tip:setAnchorPoint(ccp(0.5, 1))
		tip:setPosition(ccp(self:getContentSize().width * 0.5, -60))
		tip:setColor(ccc3(0xff, 0x8a, 0x00))
	end
end

function BossCopyCitySprite:loadPassedTip( ... )
	if GuildBossCopyData.isTargetGroupCopy(self._id) then
		if tonumber(self._userInfo.curr_hp) == 0 then
			local tip = CCRenderLabel:create(GetLocalizeStringBy("key_10062"), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			self:addChild(tip)
			tip:setAnchorPoint(ccp(0.5, 1))
			tip:setPosition(ccp(self:getContentSize().width * 0.5, -60))
			tip:setColor(ccc3(0x00, 0xff, 0x18))
		end
	end
end

function BossCopyCitySprite:refreshHp( ... )
	if GuildBossCopyData.isTargetGroupCopy(self._id) then
		local progress = tonumber(self._userInfo.curr_hp) / tonumber(self._userInfo.total_hp)
		if self._HpProgressSprite == nil then
			-- local progressInfo = {
			-- 	{
			-- 		progress = 0.1, 
			-- 		progressSpriteImage = "images/common/red_hp.png"
			-- 	}
			-- }
			self._HpProgressSprite = ProgressBar:create("images/common/exp_bg.png", "images/common/exp_progress.png", 200, progress, nil)
			self:addChild(self._HpProgressSprite)
			self._HpProgressSprite:setAnchorPoint(ccp(0.5, 1))
			self._HpProgressSprite:setPosition(ccp(self:getContentSize().width * 0.5, -60))	
		else
			self._HpProgressSprite.setProgress(progress)
		end
		if progress == 0 then
			self._HpProgressSprite:setVisible(false)
			self:loadPassedTip()
		end
	end
end

function BossCopyCitySprite:loadFlag( ... )
	if GuildBossCopyData.isTargetGroupCopy(self._id) then
		local flag = CCSprite:create("images/guild_boss_copy/target.png")
		self:addChild(flag)
		flag:setAnchorPoint(ccp(0.5, 0))
		flag:setPosition(ccpsprite(1, 0, self))
	end
end