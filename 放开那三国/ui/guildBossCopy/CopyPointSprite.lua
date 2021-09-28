-- FileName: CopyPointSprite.lua 
-- Author: bzx
-- Date: 15-04-02 
-- Purpose: 副本据点

CopyPointSprite = class("CopyPointSprite", function ( ... )
	return CCSprite:create()
end)
	
CopyPointSprite._copyPointIndex = nil
CopyPointSprite._clickCallback = nil
CopyPointSprite._hpBar = nil
CopyPointSprite._addtionSprite = nil
CopyPointSprite._menuItem = nil
CopyPointSprite._menu = nil
CopyPointSprite._groupCopyId = nil
CopyPointSprite._groupCopyDb = nil
CopyPointSprite._heightestDamageLabel = nil
CopyPointSprite._deadTagSprite = nil

function CopyPointSprite:createById(p_groupCopyId, p_copyIndex, p_touchPriority, p_clickCallback)
	local copyPointSprite = CopyPointSprite:new()
	copyPointSprite:initData(p_groupCopyId, p_copyIndex, p_touchPriority, p_clickCallback)
	copyPointSprite:loadBaseUI()
	return copyPointSprite
end

function CopyPointSprite:initData(p_groupCopyId, p_copyIndex, p_touchPriority, p_clickCallback )
	self._groupCopyId = p_groupCopyId
	self._groupCopyDb = DB_GroupCopy.getDataById(p_groupCopyId)
	self._copyPointIndex = p_copyIndex
	self._touchPriority = p_touchPriority or -180
	self._clickCallback = p_clickCallback
end

function CopyPointSprite:loadBaseUI( ... )
	self._menu = BTSensitiveMenu:create()
	self:addChild(self._menu)
	self._menu:setPosition(ccp(0, 0))
	self._menu:setTouchPriority(self._touchPriority)
	self:refreshMenuItem()
	local name = parseField(self._groupCopyDb.name, 1)[self._copyPointIndex]
	local nameLabel = CCRenderLabel:create(name, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
	self._menuItem:addChild(nameLabel)
	nameLabel:setAnchorPoint(ccp(0.5, 0.5))
	nameLabel:setPosition(ccpsprite(0.5, 0.9, self._menuItem))
	local nameColors = {ccc3(0x00, 0xff, 0x18), ccc3(0x00, 0xe4, 0xff), ccc3(0xe4, 0x00, 0xff)}
	local colorIndex = 0
	if self._copyPointIndex <= 3 then
		colorIndex = 1
	elseif self._copyPointIndex <= 5 then
		colorIndex = 2
	else
		colorIndex = 3
	end
	nameLabel:setColor(nameColors[colorIndex])
	
	self:refreshAddtion()
	self:refreshHpBar()
	self:refreshHeightestDamage()
	self:refreshDeadTagSprite()
end

function CopyPointSprite:getPointSprite()
	local pointSprite = nil
	local fileName = "images/guild_boss_copy/point_copy/" .. parseField(self._groupCopyDb.picture, 1)[self._copyPointIndex]
	local total, curr = GuildBossCopyData.getPointCopyHpInfo(self._copyPointIndex)
	if curr == 0 then
		pointSprite = BTGraySprite:create(fileName)
	else
		pointSprite = CCSprite:create(fileName)
	end
	return pointSprite
end

function CopyPointSprite:refreshMenuItem( ... )
	local total, curr = GuildBossCopyData.getPointCopyHpInfo(self._copyPointIndex)
	if self._menuItem == nil then
		local normal = self:getPointSprite()
		self._menuItem = CCMenuItemSprite:create(normal, normal)
		self._menu:addChild(self._menuItem)
		self._menuItem:setTag(self._copyPointIndex)
		self._menuItem:registerScriptTapHandler(self._clickCallback)
		self:setContentSize(normal:getContentSize())
		self._menu:setContentSize(normal:getContentSize())
	end
	if curr == 0 then
		local normal = tolua.cast(self._menuItem:getNormalImage(), "CCSprite")
		local grayNormal = BTGraySprite:createWithSprite(normal)
		self._menuItem:setDisabledImage(grayNormal)
		self._menuItem:setEnabled(false)
	end
end

function CopyPointSprite:refreshAddtion( ... )
	local total, curr = GuildBossCopyData.getPointCopyHpInfo(self._copyPointIndex)
	if self._addtionSprite == nil then
		self._addtionSprite = CCSprite:create()
		self._menuItem:addChild(self._addtionSprite)
		self._addtionSprite:setPosition(ccpsprite(0.6, 0.6, self._menuItem))

		local copyPointInfo = GuildBossCopyData.getCopyInfo()[tostring(self._copyPointIndex)]
		local additionImages = {"wei.png", "shu.png", "wu.png", "qun.png"}
		for i = 1, 2 do
			local addtionType = tonumber(copyPointInfo.type[i])
			local addtionSprite = CCSprite:create("images/guild_boss_copy/" .. additionImages[addtionType])
			self._addtionSprite:addChild(addtionSprite)
			addtionSprite:setAnchorPoint(ccp(0, 0.5))
			addtionSprite:setPosition(ccp(20 + (i - 1) * 50, 60))
			addtionSprite:setScale(0.55)
		end
	end
	if curr == 0 then
		self._addtionSprite:removeFromParentAndCleanup(true)
		self._addtionSprite = nil
	end
end

function CopyPointSprite:refreshHpBar( ... )
	local total, curr = GuildBossCopyData.getPointCopyHpInfo(self._copyPointIndex)
	local hpProgress = curr / total
	if self._hpBar == nil then
		self._hpBar = ProgressBar:create("images/guild_boss_copy/red_bar.png", "images/guild_boss_copy/green_bar.png", nil, hpProgress, false)
		self._menuItem:addChild(self._hpBar)
		self._hpBar:setAnchorPoint(ccp(0.5, 0.5))
		self._hpBar:setPosition(ccpsprite(0.5, 0.8, self._menuItem))
		self._hpBar:getProgressLabel():setVisible(false)
	else
		self._hpBar:setProgress(hpProgress)
	end
	if curr == 0 then
		self._hpBar:removeFromParentAndCleanup(true)
		self._hpBar = nil
	end
end

function CopyPointSprite:refreshDeadTagSprite( ... )
	local total, curr = GuildBossCopyData.getPointCopyHpInfo(self._copyPointIndex)
	if self._deadTagSprite == nil and curr == 0 then
		self._deadTagSprite = CCSprite:create("images/guild_boss_copy/yijipo.png")
		self._menuItem:addChild(self._deadTagSprite, 100)
		self._deadTagSprite:setAnchorPoint(ccp(0.5, 0.5))
		self._deadTagSprite:setPosition(ccpsprite(0.7, 0.5, self._menuItem))
	end
	if curr ~= 0 and self._deadTagSprite ~= nil then
		self._deadTagSprite:removeFromParentAndCleanup(true)
		self._deadTagSprite = nil
	end
end

function CopyPointSprite:refreshHeightestDamage( ... )
	local copyInfo = GuildBossCopyData.getCopyInfo()
	if copyInfo[tostring(self._copyPointIndex)] == nil then
		return
	end
	local maxDamager = copyInfo[tostring(self._copyPointIndex)].max_damager
	if self._heightestDamageLabel == nil and maxDamager ~= nil then
		local sex = HeroModel.getSex(tonumber(maxDamager.htid))
		local nameColor = nil
		if sex == 1 then
			nameColor = ccc3(0x00, 0xe4, 0xff)
		else
			nameColor = ccc3(0xf9, 0x59, 0xff)
		end
		local richInfo = {
			defaultType = "CCRenderLabel",
			labelDefaultSize = 18, 
			defaultRenderType = type_shadow,
			elements = {
				{
					text = maxDamager.uname,
					color = nameColor,
				}
			}
		}
		self._heightestDamageLabel = GetLocalizeLabelSpriteBy_2(GetLocalizeStringBy("key_10091"), richInfo)
		self._menuItem:addChild(self._heightestDamageLabel)
		self._heightestDamageLabel:setAnchorPoint(ccp(0.5, 1))
		self._heightestDamageLabel:setPosition(ccpsprite(0.5, 0, self._menuItem))
	end
end

function CopyPointSprite:refresh( ... )
	self:refreshAddtion()
	self:refreshHeightestDamage()
	self:refreshHpBar()
	self:refreshMenuItem()
	self:refreshDeadTagSprite()
end