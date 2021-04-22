--
-- Author: xurui
-- Date: 2015-08-26 17:32:52
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetEquipmentAvatar = class("QUIWidgetEquipmentAvatar", QUIWidget)

local QUIWidgetHeroHeadStar = import("..widgets.QUIWidgetHeroHeadStar")
local QUIWidgetEquipmentBox = import("..widgets.QUIWidgetEquipmentBox")
local QUIWidgetEquipmentSpecialBox = import("..widgets.QUIWidgetEquipmentSpecialBox")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetGemstonesBox = import("..widgets.QUIWidgetGemstonesBox")
local QUIWidgetSparBox = import("..widgets.spar.QUIWidgetSparBox")
local QUIWidgetMountBox = import("..widgets.mount.QUIWidgetMountBox")
local QUIWidgetArtifactBox = import("..widgets.artifact.QUIWidgetArtifactBox")
local QUIWidgetHeroSkillBox = import("..widgets.QUIWidgetHeroSkillBox")
local QUIWidgetQualitySmall = import("..widgets.QUIWidgetQualitySmall")

local MOUNT_COLOR = {blue = 3, purple = 4, orange = 5, red = 6}

function QUIWidgetEquipmentAvatar:ctor(options)
	local ccbFile = "ccb/Widget_HeroEquipment_Stengthen_client.ccbi"
	local callBacks = {}
	QUIWidgetEquipmentAvatar.super.ctor(self, ccbFile, callBacks, options)

	self:resetAll()
end

function QUIWidgetEquipmentAvatar:resetAll()
	self:hideAllColor()
	self._ccbOwner.node_godlevel:setVisible(false)
end

function QUIWidgetEquipmentAvatar:setEquipmentInfo(itemInfo, actorId)
	if self._itemBox ~= nil then
		self._itemBox:removeFromParent()
		self._itemBox = nil
	end
	if itemInfo ~= nil then
		self._itemInfo = itemInfo
		local imageTexture =CCTextureCache:sharedTextureCache():addImage(self._itemInfo.icon_1)
		if ENABLE_EQUIPMENT_FRAME then
			self._ccbOwner.equ_icon:setTexture(imageTexture)
			self._ccbOwner.equ_icon:setScale(1.0)
			self._ccbOwner.equ_icon:setVisible(true)
		else
			self._ccbOwner.equ_icon:setVisible(false)
			self._itemBox = nil
			local uiHero = remote.herosUtil:getUIHeroByID(actorId)
			local pos,breakInfo = uiHero:getEquipmentPosition(itemInfo.id)
			if pos ~= EQUIPMENT_TYPE.JEWELRY1 and pos ~= EQUIPMENT_TYPE.JEWELRY2 then
				self._itemBox = QUIWidgetEquipmentBox.new({noEvent = true})
			else
				self._itemBox = QUIWidgetEquipmentSpecialBox.new({noEvent = true})
			end
    		self._ccbOwner.node_icon:removeAllChildren()
			self._ccbOwner.node_icon:addChild(self._itemBox)
			self._itemBox:setEquipmentInfo(itemInfo,actorId)
			self._itemBox:setEvolution(breakInfo.breakthrough_level)
			self._itemBox:setStrengthenNode(false)
		end
		local breaklevel = remote.herosUtil:getHeroEquipmentEvolutionByID(actorId, itemInfo.id)
		local level,index = remote.herosUtil:getBreakThroughLevel(breaklevel)
		self:setColor(index)
	end
end

function QUIWidgetEquipmentAvatar:setGemstonInfo(itemInfo, breaklevel, iconScale,godLevel , mixLevel, refineLevel)
	if itemInfo ~= nil then
		local level,index = remote.herosUtil:getBreakThroughLevel(breaklevel)
		local quality = APTITUDE.C
		if ENABLE_EQUIPMENT_FRAME then
			self._itemInfo = itemInfo
			local imageTexture = CCTextureCache:sharedTextureCache():addImage(self._itemInfo.icon_1 or self._itemInfo.icon)
			self._ccbOwner.equ_icon:setTexture(imageTexture)
			self._ccbOwner.equ_icon:setScale(iconScale or 1.2)
		else
			self._ccbOwner.equ_icon:setVisible(false)
			if self._gemstoneBox == nil then
				self._gemstoneBox = QUIWidgetGemstonesBox.new()
    			self._ccbOwner.node_icon:removeAllChildren()
	       		self._ccbOwner.node_icon:addChild(self._gemstoneBox)
			end
			local gemstoneInfo = {itemId = itemInfo.id , godLevel = godLevel , mix_level = mixLevel, refine_level = refineLevel, craftLevel = breaklevel , level = 0 }
			self._gemstoneBox:setGemstoneInfo(gemstoneInfo)
			self._gemstoneBox:setStateQualityVisible(false)
			quality = self._gemstoneBox:getQuality()
	        -- self._gemstoneBox:setItemIdByData(itemInfo.id , godLevel , mixLevel )
	        -- self._gemstoneBox:setBreakLevel(0)
	        -- self._gemstoneBox:setStrengthen(0)
		end
		self:setColor(index)
		-- if self._gemstoneBox then
		-- 	quality = self._gemstoneBox:getQuality()
		-- 	self._gemstoneBox:setBreakLevel(breaklevel)
		-- 	self._gemstoneBox:setStateQualityVisible(false)
		-- end

		local qualityWidget = QUIWidgetQualitySmall.new()
		qualityWidget:setScale(0.8)
		qualityWidget:setPosition(ccp(-41,26))
		self._ccbOwner.node_quailty:removeAllChildren()
		self._ccbOwner.node_quailty:addChild(qualityWidget)
		qualityWidget:setQuality(remote.gemstone:getSABC(quality).lower)
		-- self._ccbOwner.node_godlevel:setVisible(false)
		-- if godLevel and godLevel > 0 then
		-- 	self._ccbOwner.node_godlevel:setVisible(true)
		-- 	if godLevel > GEMSTONE_MAXADVANCED_LEVEL then
		-- 		local grade = godLevel - GEMSTONE_MAXADVANCED_LEVEL
		-- 		local iconPath = QResPath("god_skill")[grade]
		-- 		QSetDisplaySpriteByPath(self._ccbOwner.sp_godlevel,iconPath)
		-- 		self._ccbOwner.sp_godlevel:setVisible(true)
		-- 		self._ccbOwner.tf_godLevel:setString("")
		-- 	elseif godLevel < GEMSTONE_MAXADVANCED_LEVEL then
		-- 		local advanced = math.floor((godLevel)/5)
		-- 		self._ccbOwner.tf_godLevel:setString(q.getRomanNumberalsByInt(advanced).."阶")
		-- 		local color = EQUIPMENT_QUALITY[advanced + 1 ]
		-- 		self._ccbOwner.tf_godLevel:setColor(BREAKTHROUGH_COLOR_LIGHT[color])	
		-- 		self._ccbOwner.sp_godlevel:setVisible(false)	
		-- 	else
		-- 		self._ccbOwner.node_godlevel:setVisible(false)
		-- 	end
		-- end
	end
end

function QUIWidgetEquipmentAvatar:setSparInfo(itemInfo, sparPos, iconScale)
	if itemInfo ~= nil then
		if ENABLE_EQUIPMENT_FRAME then
			self._itemInfo = itemInfo
			local imageTexture = CCTextureCache:sharedTextureCache():addImage(self._itemInfo.icon_1 or self._itemInfo.icon)
			self._ccbOwner.equ_icon:setTexture(imageTexture)
			self._ccbOwner.equ_icon:setScale(iconScale or 1.2)
		else
			self._ccbOwner.equ_icon:setVisible(false)
			if self._sparBox == nil then
				self._sparBox = QUIWidgetSparBox.new()
    			self._ccbOwner.node_icon:removeAllChildren()
	       		self._ccbOwner.node_icon:addChild(self._sparBox)
			end
	        self._sparBox:setInfo({sparInfo = {itemId = itemInfo.id, grade = 0}, sparPos = sparPos})
	        self._sparBox:setNameVisible(false)
			self._sparBox:setStar(0)
		end
		local itemConfig = db:getItemByID(itemInfo.id)
		self:setColor(itemConfig.colour)
	end
end

function QUIWidgetEquipmentAvatar:setMountInfo(mountInfo, grade)
	if mountInfo ~= nil then
		local itemConfig = db:getItemByID(mountInfo.zuoqiId)
		local itemBox = nil
		if ENABLE_EQUIPMENT_FRAME then
			self._itemInfo = itemInfo
			local imageTexture =CCTextureCache:sharedTextureCache():addImage(itemConfig.icon_1 or itemConfig.icon)
			self._ccbOwner.equ_icon:setTexture(imageTexture)
			self._ccbOwner.equ_icon:setScale(iconScale or 1.2)
		else
			itemBox = QUIWidgetMountBox.new()
	        itemBox:setMountInfo(mountInfo)
	        itemBox:isShowLevel(false)
	        itemBox:setStarVisible(grade ~= nil)
        	itemBox:setGrade(grade or mountInfo.grade)
    		self._ccbOwner.node_icon:removeAllChildren()
	        self._ccbOwner.node_icon:addChild(itemBox)
			self._ccbOwner.equ_icon:setVisible(false)
		end
		local color = remote.mount:getColorByMountId(mountInfo.zuoqiId)
    	color = string.lower(color)
    	local index = MOUNT_COLOR[color]
		self:setColor(index)
	end
end

function QUIWidgetEquipmentAvatar:setArtifactInfo(actorId, grade, isPreview)
	local artifactId = remote.artifact:getArtiactByActorId(actorId)
	if artifactId ~= nil then
		local itemConfig = db:getItemByID(artifactId)
		if ENABLE_EQUIPMENT_FRAME then
			self._itemInfo = itemInfo
			local imageTexture = CCTextureCache:sharedTextureCache():addImage(itemConfig.icon_1 or itemConfig.icon)
			self._ccbOwner.equ_icon:setTexture(imageTexture)
			self._ccbOwner.equ_icon:setScale(iconScale or 1.2)
		else
			self._ccbOwner.equ_icon:setVisible(false)
			local itemBox = QUIWidgetArtifactBox.new()
	        itemBox:setHero(actorId, isPreview)
	        itemBox:setGrade(grade)
	        itemBox:showRedTips(false)
	        itemBox:isShowLevel(false)
    		self._ccbOwner.node_icon:removeAllChildren()
	        self._ccbOwner.node_icon:addChild(itemBox)
		end
		local index = itemConfig.colour
		self:setColor(index)
	end
end

function QUIWidgetEquipmentAvatar:setGodSkillInfo(actorId, grade)
	grade = grade or 1
	local godSkillConfig = db:getGodSkillByIdAndGrade(actorId, 1)
    local skillIds = string.split(godSkillConfig.skill_id, ";")
    local skillId = skillIds[1]
	if skillId ~= nil then
		local itemBox = QUIWidgetHeroSkillBox.new()
		itemBox:setLock(false)
	    itemBox:setSkillID(skillId)
	    itemBox:setGodSkillShowLevel(grade, actorId)
		self._ccbOwner.equ_icon:setVisible(false)
    	self._ccbOwner.node_icon:removeAllChildren()
	    self._ccbOwner.node_icon:addChild(itemBox)
		self:setColor(6)
	end
end

function QUIWidgetEquipmentAvatar:setStar(grade)
	if grade ~= nil then
		grade = grade+1
		if self._star == nil then
	    	self._star = QUIWidgetHeroHeadStar.new({})
	    	self._ccbOwner.node_star:addChild(self._star:getView())
	    end
	    self._star:setScale(0.9)
	    self._star:setStar(grade, false)
		self._ccbOwner.node_star:setVisible(grade>0)
	end
end 

function QUIWidgetEquipmentAvatar:setColor(index)
	if index ~= nil then
		self:hideAllColor()
		self._ccbOwner["break"..index]:setVisible(true)
	end
end 

function QUIWidgetEquipmentAvatar:hideAllColor()
	for i = 1, 7, 1 do
		self._ccbOwner["break"..i]:setVisible(false)
	end

	for i = 0, 5 do
		self._ccbOwner["level_"..i]:setVisible(false)
	end
end

function QUIWidgetEquipmentAvatar:showAdvancedColor( advanced)
	local showAdvanced = advanced or 0
	if showAdvanced > 5 then
		showAdvanced = 5
	end
	local node = self._ccbOwner["level_"..showAdvanced]
	if node then
		node:setVisible(true)
	end
end

function QUIWidgetEquipmentAvatar:stopAction()
    local animationManager = tolua.cast(self:getCCBView():getUserObject(), "CCBAnimationManager")
    animationManager:runAnimationsForSequenceNamed("1")
end


return QUIWidgetEquipmentAvatar