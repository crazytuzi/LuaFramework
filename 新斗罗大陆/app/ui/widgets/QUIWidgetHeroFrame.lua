--
-- Author: wkwang
-- Date: 2014-07-15 18:47:01
--
local QUIWidget = import(".QUIWidget")
local QUIWidgetHeroFrame = class("QUIWidgetHeroFrame", QUIWidget)

local QUIWidgetHeroHead = import(".QUIWidgetHeroHead")
local QHeroModel = import("...models.QHeroModel")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetHeroEquipmentSmallBox = import(".QUIWidgetHeroEquipmentSmallBox")
local QUIWidgetHeroEquipment = import(".QUIWidgetHeroEquipment")
local QUIWidgetItemsBox = import(".QUIWidgetItemsBox")
local QUIViewController = import("..QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetGemstonesSmallBox = import("..widgets.QUIWidgetGemstonesSmallBox")
local QGemstoneController = import("..controllers.QGemstoneController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetHeroProfessionalIcon = import("..widgets.QUIWidgetHeroProfessionalIcon")
local QUIWidgetArtifactBox = import("..widgets.artifact.QUIWidgetArtifactBox")

QUIWidgetHeroFrame.EVENT_HERO_FRAMES_CLICK = "EVENT_HERO_FRAMES_CLICK"

function QUIWidgetHeroFrame:ctor(options)
	local ccbFile = "ccb/Widget_HeroOverview_sheet.ccbi"
	local callBacks = {{ccbCallbackName = "onTriggerHeroOverview", callback = handler(self, QUIWidgetHeroFrame._onTriggerHeroOverview)}}
	QUIWidgetHeroFrame.super.ctor(self,ccbFile,callBacks,options)
	
	self._forceBarScaleX = self._ccbOwner.sprite_bar:getScaleX()
	-- self._ccbOwner.node_hero_name = setShadow(self._ccbOwner.node_hero_name)
	setShadow5(self._ccbOwner.node_hero_name)

	self._equipBox = {}
    for i = 1, 6 do
        self._equipBox[i] = QUIWidgetHeroEquipmentSmallBox.new()
        self._ccbOwner["node_equip"..i]:addChild(self._equipBox[i]:getView())
    end
    --武器 护手 衣服 脚  饰品1 饰品2
    self._equipBox[1]:setType(EQUIPMENT_TYPE.WEAPON)
    self._equipBox[2]:setType(EQUIPMENT_TYPE.BRACELET)
    self._equipBox[3]:setType(EQUIPMENT_TYPE.CLOTHES)
    self._equipBox[4]:setType(EQUIPMENT_TYPE.SHOES)
    self._equipBox[5]:setType(EQUIPMENT_TYPE.JEWELRY1)
    self._equipBox[6]:setType(EQUIPMENT_TYPE.JEWELRY2)

    --装备控制器
    self._equipmentUtils = QUIWidgetHeroEquipment.new()
    self:getView():addChild(self._equipmentUtils) --此处添加至节点没有显示需求
    self._equipmentUtils:setUI(self._equipBox)

    --宝石控制器
    self._ccbOwner.node_hero_gemstone:setVisible(true)
    self._gemstoneBoxs = {}
    for i = 1, 4 do
        self._gemstoneBoxs[i] = QUIWidgetGemstonesSmallBox.new()
        self._ccbOwner["node_baoshi"..i]:addChild(self._gemstoneBoxs[i])
    end
    --晶石
    self._sparBoxs = {}
    for i = 1, 2 do
        self._sparBoxs[i] = QUIWidgetGemstonesSmallBox.new()
        self._ccbOwner["node_spar"..i]:addChild(self._sparBoxs[i])
    end
    self._gemstoneController = QGemstoneController.new()
    self._gemstoneController:setBoxs(self._gemstoneBoxs, self._sparBoxs)

	self._heroHead = QUIWidgetHeroHead.new({})
	self._heroHead:setTouchEnabled(false)
	self._ccbOwner.node_hero_head:addChild(self._heroHead:getView())

	self._isGrayDisplay = false

	if options.isInRenderTexture then
		-- nzhang: 犹豫是在render texture绘制的，因此convertToWorldSpaceAR是无法正常工作的，会影响到引导圈的位置判断，这里hard code一下
		local _convertToWorldSpaceAR = self._ccbOwner.bg.convertToWorldSpaceAR
		function self._ccbOwner.bg:convertToWorldSpaceAR(pos)
			local wpos = _convertToWorldSpaceAR(self, pos)
			wpos.x = wpos.x - 425
			wpos.y = wpos.y - 445
			return wpos
		end

		self._ccbOwner.button_heroOverView:setEnabled(false)
		self._ccbOwner.button_heroOverView:setTouchEnabled(false)
	end
end

-- Add profession @qinyuanji
function QUIWidgetHeroFrame:setProfession(iconScale)
	self._ccbOwner.node_hero_professional:removeAllChildren()

    if self._professionalIcon == nil then 
	    self._professionalIcon = QUIWidgetHeroProfessionalIcon.new()
	    self._ccbOwner.node_hero_professional:addChild(self._professionalIcon)
	end
    self._professionalIcon:setHero(self._actorId, false, iconScale)
end

function QUIWidgetHeroFrame:getName()
	return "QUIWidgetHeroFrame"
end

function QUIWidgetHeroFrame:getHero()
	return self._actorId
end

function QUIWidgetHeroFrame:setHero(actorId)
	self._actorId = actorId
	self._hero = remote.herosUtil:getHeroByID(self._actorId)
	local database = QStaticDatabase:sharedDatabase()
	local heroInfo = database:getCharacterByID(self._actorId)
	self._ccbOwner.is_selected:setVisible(false)

	-- 设置魂师名称
	local name = heroInfo.name
	local nameColor = BREAKTHROUGH_COLOR_LIGHT["white"]

	-- for i = 1,3 do
	-- 	self._ccbOwner["sp_link"..i]:setVisible(false)
	-- end
	-- 设置头像显示
	self._heroHead:setHeroSkinId(self._hero.skinId)
	self._heroHead:setHero(actorId, level)
	self._heroHead:setStarVisible(false)
	local level = 0
	local characher = QStaticDatabase:sharedDatabase():getCharacterByID(self._actorId)
	if self._hero ~= nil then
		local breakthroughLevel,color = remote.herosUtil:getBreakThrough(self._hero.breakthrough)
	    local isTips = remote.herosUtil:checkHerosIsTipByID(self._actorId)

		level = self._hero.level
		--设置进阶
		if color ~= nil then
			nameColor = BREAKTHROUGH_COLOR_LIGHT[color]
		end
		if breakthroughLevel > 0 then
			name = name.." +"..breakthroughLevel
		end
		-- 是否显示小红点
		if isTips then 
			isTips = remote.herosUtil:checkHerosIsNeedTipByID(self._actorId)
		end
	    self._ccbOwner.node_tips_hero:setVisible(isTips)
    
		local UIHeroModel = remote.herosUtil:getUIHeroByID(self._actorId)
		-- for i = 1, 4 do
		-- 	local gemstoneInfo = UIHeroModel:getGemstoneInfoByPos(i)
		-- 	if gemstoneInfo.state == remote.gemstone.GEMSTONE_LOCK then
		-- 	else
		-- 		if i > 1 then
		-- 			self._ccbOwner["sp_link"..(i-1)]:setVisible(true)
		-- 		end
		-- 	end
		-- end
		-- 装备显示
		self._equipmentUtils:setHero(self._hero.actorId) 
        self._gemstoneController:setHero(self._hero.actorId)
	    local count = self._gemstoneController:getUnlockGemstoneCount()
	    for i=1,4 do
	    	self._ccbOwner["node_gemstone_bg"..i]:setVisible(false)
	    end
	    if self._ccbOwner["node_gemstone_bg"..count] ~= nil then
    		self._ccbOwner["node_gemstone_bg"..count]:setVisible(true)
    	end

    	-- 晶石显示
		self._ccbOwner.node_hero_spar:setVisible(false)
	    local sparCount = self._gemstoneController:getUnlockSparCount()
		if sparCount == 1 then
			self._ccbOwner.node_hero_spar:setVisible(true)
			self._ccbOwner["node_spar_bg1"]:setVisible(true)
    		self._ccbOwner["node_spar_bg2"]:setVisible(false)
    	elseif sparCount == 2 then
			self._ccbOwner.node_hero_spar:setVisible(true)
			self._ccbOwner["node_spar_bg1"]:setVisible(false)
    		self._ccbOwner["node_spar_bg2"]:setVisible(true)
	    end

		self:showEquipment()
		-- diaplay stars
		self._heroHead:setStar(self._hero.grade)
		self._heroHead:showSabcWithoutStar()
		self._heroHead:setLevel(self._hero.level)

		if self._isGrayDisplay == true then
			makeNodeOpacity(self._heroHead, 255)
			self._heroHead:setStarVisible(true)
			makeNodeFromGrayToNormal(self._heroHead)
			self._isGrayDisplay = false
		end
		self._ccbOwner.node_recruitAnimation:setVisible(false)
		
		-- set mount info
		self._ccbOwner.node_mount_box:setVisible(false)
		self._ccbOwner.node_mount:removeAllChildren()
		self._ccbOwner.sp_plus:setVisible(true)
		if app.unlock:checkLock("UNLOCK_ZUOQI", false) then
			local mountState =  UIHeroModel:getMountState() 
			if mountState ~= remote.mount.STATE_LOCK then
				self._ccbOwner.node_mount_box:setVisible(true)
				if self._hero.zuoqi then
					self._ccbOwner.sp_plus:setVisible(false)
					local heroDisplay = QStaticDatabase:sharedDatabase():getCharacterByID(self._hero.zuoqi.zuoqiId)
					local icon = CCSprite:create()
					self._ccbOwner.node_mount:addChild(icon)
					icon:setTexture(CCTextureCache:sharedTextureCache():addImage(heroDisplay.icon))
				end
			end
		end

		--set artifact info
		self._ccbOwner.node_artifact_box:setVisible(false)
		self._ccbOwner.node_artifact:removeAllChildren()
		if app.unlock:checkLock("UNLOCK_ARTIFACT", false) then
			local state =  UIHeroModel:getArtifactState() 
			if state ~= remote.artifact.STATE_LOCK and state ~= remote.artifact.STATE_NO then
				self._ccbOwner.node_artifact_box:setVisible(true)
				if self._hero.artifact and self._hero.artifact.artifactBreakthrough > 0 then
					self._ccbOwner.sp_artifact_plus:setVisible(false)
					local artifactId = remote.artifact:getArtiactByActorId(self._actorId)
					if artifactId ~= nil then
						local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(artifactId)
						local icon = CCSprite:create()
						self._ccbOwner.node_artifact:addChild(icon)
						icon:setTexture(CCTextureCache:sharedTextureCache():addImage(itemInfo.icon))
					end
				else
					self._ccbOwner.sp_artifact_plus:setVisible(true)
				end
			end
		end
	else
		-- invisible tip icon
		self._ccbOwner.node_tips_hero:setVisible(false)
		self._ccbOwner.node_mount_box:setVisible(false)
		self._ccbOwner.node_artifact_box:setVisible(false)
		self._ccbOwner.node_hero_spar:setVisible(false)
		
		-- display fragment
		self:showBattleForce()
		local grade_info = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(self._actorId, characher.grade or 0)
		local soulGemId = grade_info.soul_gem
		local currentGemCount = remote.items:getItemsNumByID(soulGemId)
		local needGemCount = QStaticDatabase:sharedDatabase():getNeedSoulByHeroActorLevel(self._actorId, characher.grade or 0)
		-- can summon the hero
		if currentGemCount >= needGemCount then
			self._ccbOwner.sprite_bar:setScaleX(self._forceBarScaleX)
			self._ccbOwner.node_hero_force_full:setVisible(true)
			self._ccbOwner.node_hero_force:setVisible(false)
			self._ccbOwner.node_recruitAnimation:setVisible(true)
		else
			self._ccbOwner.sprite_bar:setScaleX(self._forceBarScaleX * (currentGemCount / needGemCount))
			self._ccbOwner.node_hero_force_full:setVisible(false)
			self._ccbOwner.node_hero_force:setVisible(true)
			self._ccbOwner.node_hero_force:setString(tostring(currentGemCount) .. "/" .. tostring(needGemCount))
			self._ccbOwner.node_recruitAnimation:setVisible(false)
		end

	    local itemBox = QUIWidgetItemsBox.new()
	    itemBox:setGoodsInfo(soulGemId, ITEM_TYPE.ITEM, 0)
	    itemBox:hideSabc()
	    itemBox:hideTalentIcon()
	    itemBox:setScale(0.5)
	    itemBox:setPosition(ccp(self._ccbOwner.soul_icon:getPosition()))
	    self._ccbOwner.soul_icon:getParent():addChild(itemBox)
	    self._ccbOwner.soul_icon:setVisible(false)

		-- self._heroHead:setStar(characher.grade, false)
		self._heroHead:showSabcWithoutStar()
		-- self._heroHead:setStarVisible(true)
		self._heroHead:setLevelVisible(false)

	    self._ccbOwner.is_selected:setVisible(remote.herosUtil:checkHeroHavePast(self._actorId))

		if self._isGrayDisplay == false then
			makeNodeOpacity(self._heroHead, math.floor(255 * 0.85))
			self._heroHead:setStarVisible(false)
			makeNodeFromNormalToGray(self._heroHead:getNode())

			self._isGrayDisplay = true
		end
	end

	-- Show profession
	self:setProfession()

	self._ccbOwner.node_hero_name:setString(name)
	self._ccbOwner.node_hero_name:setColor(nameColor)
	self:removeFight()
end

--刷新当前信息显示
function QUIWidgetHeroFrame:refreshInfo()
	self:setHero(self._actorId)
end

function QUIWidgetHeroFrame:selected()
	self._ccbOwner.node_hero_select:setVisible(true)
end

function QUIWidgetHeroFrame:unselected()
	self._ccbOwner.node_hero_select:setVisible(false)
end

function QUIWidgetHeroFrame:setFramePos(pos)
	self._pos = pos
end

function QUIWidgetHeroFrame:getContentSize()
	return self._ccbOwner.bg:getContentSize()
end

function QUIWidgetHeroFrame:showEquipment()
	self._ccbOwner.node_hero_equipment:setVisible(true)
	self._ccbOwner.node_hero_gemstone:setVisible(true)
	self._ccbOwner.node_hero_battleForce:setVisible(false)
end

function QUIWidgetHeroFrame:showBattleForce()
	self._ccbOwner.node_hero_equipment:setVisible(false)
	self._ccbOwner.node_hero_gemstone:setVisible(false)
	self._ccbOwner.node_hero_battleForce:setVisible(true)
end

function QUIWidgetHeroFrame:showFight()
	self._isFight = true
	self._ccbOwner.node_hero_fight:setVisible(true)
end

function QUIWidgetHeroFrame:removeFight()
	self._isFight = false
	self._ccbOwner.node_hero_fight:setVisible(false)
end

function QUIWidgetHeroFrame:onExit()
	self._eventProxy = nil
end

--event callback area--
function QUIWidgetHeroFrame:_onTriggerHeroOverview(tag, menuItem)
	local position = self:convertToWorldSpaceAR(ccp(0,0))
	if tonumber(tag) == CCControlEventTouchDown then return end
	QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetHeroFrame.EVENT_HERO_FRAMES_CLICK, hero = self._hero, actorId = self._actorId, position = position})
end

function QUIWidgetHeroFrame:_removeDelay()
	if self._delay ~= nil then 
		scheduler.unscheduleGlobal(self._delay)
		self._delay = nil
	end
end

return QUIWidgetHeroFrame
