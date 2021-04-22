-- @Author: xurui
-- @Date:   2017-09-22 16:14:13
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-02-21 17:16:21

local QUIWidget = import(".QUIWidget")
local QUIWidgetHeroDetailFrame = class("QUIWidgetHeroDetailFrame", QUIWidget)

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
local QUIWidgetArtifactBox = import("..widgets.artifact.QUIWidgetArtifactBox")
local QUIWidgetHeroProfessionalIcon = import("..widgets.QUIWidgetHeroProfessionalIcon")

QUIWidgetHeroDetailFrame.EVENT_HERO_FRAMES_CLICK = "EVENT_HERO_FRAMES_CLICK"

function QUIWidgetHeroDetailFrame:ctor(options)
	local ccbFile = "ccb/Widget_HeroOverview1.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerHeroOverview", callback = handler(self, QUIWidgetHeroDetailFrame._onTriggerHeroOverview)}
	}
	QUIWidgetHeroDetailFrame.super.ctor(self,ccbFile,callBacks,options)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._database = QStaticDatabase:sharedDatabase()
	self._stoneIcon = {}

	self:initNode()

	self:initHeroEquipment()

end

function QUIWidgetHeroDetailFrame:onEnter()
end

function QUIWidgetHeroDetailFrame:onExit()
end

function QUIWidgetHeroDetailFrame:initNode()
	if self._heroCardSprite == nil then
        self._heroCardSprite = CCSprite:create()

		self._heroCardSprite:setPositionY(-4)
		self._ccbOwner.node_card:addChild(self._heroCardSprite)
	end
end

function QUIWidgetHeroDetailFrame:initGLLayer()
	self._glLayerIndex = 1 
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_card_bg, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_card, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._heroCardSprite, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_hero_mask, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_no_hero_mask, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_level_bg, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_level, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_god_bg, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_god_skill, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.layerG_star_bg, self._glLayerIndex)
	
    if q.isEmpty(self._equipBox) == false then
    	for i = 1, #self._equipBox do
    		self._glLayerIndex = self._equipBox[i]:initGLLayer(self._glLayerIndex)
    	end
    end
    if q.isEmpty(self._gemstoneBoxs) == false then
    	for i = 1, #self._gemstoneBoxs do
    		self._glLayerIndex = self._gemstoneBoxs[i]:initGLLayer(self._glLayerIndex)
    	end
    end
    if q.isEmpty(self._sparBoxs) == false then
    	for i = 1, #self._sparBoxs do
    		self._glLayerIndex = self._sparBoxs[i]:initGLLayer(self._glLayerIndex)
    	end
    end

    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_mount_bg, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_mount_frame, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_mount, self._glLayerIndex)
    if self._mountIcon then
    	self._glLayerIndex = q.nodeAddGLLayer(self._mountIcon, self._glLayerIndex)
    end

    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_mount_plus, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_mount_lock, self._glLayerIndex)


    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_soulSpirit_bg, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_soulSpirit_frame, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_soulSpirit, self._glLayerIndex)
    if self._soulSpiritIcon then
    	self._glLayerIndex = q.nodeAddGLLayer(self._soulSpiritIcon, self._glLayerIndex)
    end
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_soulSpirit_plus, self._glLayerIndex)

    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_artifact_bg, self._glLayerIndex) 
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_artifact_frame, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_artifact, self._glLayerIndex)
    if self._artifactIcon then
    	self._glLayerIndex = q.nodeAddGLLayer(self._artifactIcon, self._glLayerIndex)
    end

    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_artifact_plus, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_artifact_lock, self._glLayerIndex)

    if q.isEmpty(self._stoneIcon) == false then
    	for i = 1, #self._stoneIcon do
    		self._glLayerIndex = q.nodeAddGLLayer(self._stoneIcon[i], self._glLayerIndex)
    	end
    end

    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_battle_force, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_battle, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_call, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_progress_bg, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_progress_bar, self._glLayerIndex)
    if self._soulItem then
		self._glLayerIndex = self._soulItem:initGLLayer(self._glLayerIndex)
    end
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_progress, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_hero_name, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_hero_profession, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_is_collected, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_hero_star, self._glLayerIndex)
    if q.isEmpty(self._heroStar) == false then
    	for _, value in pairs(self._heroStar) do
    		value:setGLLayer(self._glLayerIndex)
    	end
    end
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_aptitude, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_a, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.star_a, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.pingzhi_b, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.pingzhi_c, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner["pingzhi_a+"], self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_s, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.star_s, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_ss, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.star_ss, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_tips_hero, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.button_heroOverView, self._glLayerIndex)
end

--刷新当前信息显示
function QUIWidgetHeroDetailFrame:refreshInfo()
	self:setInfo({actorId = self._actorId})
end

function QUIWidgetHeroDetailFrame:setInfo(param)
	self._actorId = param.actorId or 0
	self._hero = remote.herosUtil:getHeroByID(self._actorId)

	self._heroIsExit = false
	if self._hero then
		self._heroIsExit = true
	end
	
	self._ccbOwner.node_show_god_skill:setVisible(false)

	self:setHeroInfo()

	self:setEquipmentInfo()

	self:checkRedTip()

	self:initGLLayer()
end

function QUIWidgetHeroDetailFrame:setHeroInfo()
	local heroInfo = self._database:getCharacterByID(self._actorId)
	local name = heroInfo.name
	local nameColor = UNITY_COLOR_LIGHT["ash"]
	local level = 1

	self._ccbOwner.node_hero_exist:setVisible(self._heroIsExit)
	self._ccbOwner.node_hero_no_exist:setVisible(not self._heroIsExit)
	self._ccbOwner.sp_call:setVisible(not self._heroIsExit)
	if self._heroIsExit then
		local breakthroughLevel,color = remote.herosUtil:getBreakThrough(self._hero.breakthrough)
		self._ccbOwner.sp_hero_mask:setColor(HEOR_FRAME_MASK_COLORS[color])

		if color ~= nil then
			nameColor = BREAKTHROUGH_COLOR_LIGHT[color]
		end
		if breakthroughLevel > 0 then
			name = name.."+"..breakthroughLevel
		end

		level = self._hero.level or 1

	    local num,unit = q.convertLargerNumber(self._hero.force or 0)
		self._ccbOwner.tf_battle:setString(num..unit)
	    local fontInfo = QStaticDatabase:sharedDatabase():getForceColorByForce(self._hero.force or 0)
	    if fontInfo ~= nil then
			local color = string.split(fontInfo.force_color, ";")
			self._ccbOwner.tf_battle:setColor(ccc3(color[1], color[2], color[3]))
	    end

		self._ccbOwner.sp_is_collected:setVisible(false)

		self:setGodSkillShowLevel(self._hero.godSkillGrade)
	else
		self._ccbOwner.sp_is_collected:setVisible(true)

		self:setHeroSoulInfo()
	end

	self._ccbOwner.tf_hero_name:setString(name)

	self._ccbOwner.tf_hero_name:setColor(nameColor)
	self._ccbOwner.tf_hero_name = setShadowByFontColor(self._ccbOwner.tf_hero_name, nameColor)
			
    self._ccbOwner.tf_level:setString(level)

	self:setProfessionByActorId(self._actorId)
	self:setSABC()

	local _heroInfo = remote.herosUtil:getHeroByID(self._actorId)
	local _cardPath = ""
	if _heroInfo and _heroInfo.skinId and _heroInfo.skinId > 0 then
		local skinConfig = remote.heroSkin:getHeroSkinBySkinId(self._actorId, _heroInfo.skinId)
        if skinConfig.skins_visitingCard then
        	-- print("use skin visitingCard", self._actorId, skinConfig.skins_name)
        	_cardPath = skinConfig.skins_visitingCard
        end
	end
	if _cardPath == "" and heroInfo.visitingCard then
		_cardPath = heroInfo.visitingCard
	end
	self:setHeroCard(_cardPath)

	self:setHeroStar()

	if self._heroIsExit then
		makeNodeFromGrayToNormal(self._ccbOwner.node_equipment)
		makeNodeFromGrayToNormal(self._ccbOwner.node_card)
		self._ccbOwner.sp_hero_mask:setVisible(true)
		self._ccbOwner.sp_no_hero_mask:setVisible(false)
	else
		makeNodeFromNormalToGray(self._ccbOwner.node_equipment)
		makeNodeFromNormalToGray(self._ccbOwner.node_card)
		self._ccbOwner.sp_hero_mask:setVisible(false)
		self._ccbOwner.sp_no_hero_mask:setVisible(true)
	end
end

function QUIWidgetHeroDetailFrame:setHeroSoulInfo()
	if self._soulItem == nil then
		self._soulItem = QUIWidgetItemsBox.new()
		self._soulItem:setScale(0.35)
		self._ccbOwner.node_item:addChild(self._soulItem)
	end
	local gradeInfo = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(self._actorId, 0)
	self._soulItem:setGoodsInfo(gradeInfo.soul_gem, ITEM_TYPE.ITEM, 0)
	self._soulItem:hideSabc()
	self._soulItem:hideTalentIcon() 

	local needNum = gradeInfo.soul_gem_count or 0
	local haveNum = remote.items:getItemsNumByID(gradeInfo.soul_gem)
	self._ccbOwner.tf_progress:setString(haveNum.."/"..needNum)
	local scaleX = haveNum/needNum
	scaleX = scaleX > 1 and 1 or scaleX
	self._ccbOwner.sp_progress_bar:setScaleX(scaleX)
	self._ccbOwner.sp_call:setVisible(scaleX == 1)
	-- self._ccbOwner.ccb_call_effect:setVisible(scaleX == 1)
	local isCollected = remote.herosUtil:checkHeroHavePast(self._actorId)
	self._ccbOwner.sp_is_collected:setVisible(isCollected)
end

function QUIWidgetHeroDetailFrame:setGodSkillShowLevel(grade)	
	self._ccbOwner.node_show_god_skill:setVisible(false)
	local godSkillLevel = remote.herosUtil:getGodSkillLevelByActorId(self._actorId)
	if godSkillLevel >= 0 then
		local path = nil
		if godSkillLevel == 0 then
			path = QResPath("god_skill_0")
		else
			path = QResPath("god_skill")[godSkillLevel]
		end
		QSetDisplayFrameByPath(self._ccbOwner.sp_god_skill, path)
		self._ccbOwner.node_show_god_skill:setVisible(true)
	else
		self._ccbOwner.node_show_god_skill:setVisible(false)
	end
end

function QUIWidgetHeroDetailFrame:setHeroStar(grade)
	self._ccbOwner.node_hero_star:removeAllChildren()
	self._heroStar = {}
	self._ccbOwner.node_hero_star:setVisible(true)
	self._ccbOwner.layerG_star_bg:setVisible(true)
	if self._heroIsExit then
	    local starNum, iconPath = remote.herosUtil:getStarIconByStarNum(self._hero.grade+1, false)
	    if starNum ~= nil then
	    	local _scale = 0.85
	    	local _stepOffset = -5
	    	local _layerWidth = 0
			local _layerHeight = 0
   			local _nodeX = 0
		    local _nodeXOffset = 2
		    local _widthOffset = 4
			for i = 1, starNum do
				self._heroStar[i] = CCSprite:create(iconPath)
				if self._heroStar[i] then
					self._heroStar[i]:setAnchorPoint(ccp(0.5, 1))
					local w = self._heroStar[i]:getContentSize().width * _scale
		            if w > _layerWidth then
		                _layerWidth = w + _widthOffset
                		_nodeX = _layerWidth/2
		            end
					local starStep = self._heroStar[i]:getContentSize().height + _stepOffset
					_layerHeight = (i-1) * starStep * _scale + self._heroStar[i]:getContentSize().height * _scale
					self._heroStar[i]:setScale(_scale)
					self._heroStar[i]:setPositionY(-(i-1) * starStep * _scale)
					self._ccbOwner.node_hero_star:addChild(self._heroStar[i])
				end
			end
			self._ccbOwner.node_hero_star:setPositionX(-98 + _nodeX)
			self._ccbOwner.layerG_star_bg:setPositionX(-98 + _nodeX)
		    self._ccbOwner.layerG_star_bg:setPositionY(self._ccbOwner.node_hero_star:getPositionY() + 50)
		    self._ccbOwner.layerG_star_bg:setContentSize(CCSize(_layerWidth, _layerHeight + 50))
		else
			self._ccbOwner.node_hero_star:setVisible(false)
			self._ccbOwner.layerG_star_bg:setVisible(false)
		end
	else
		self._ccbOwner.node_hero_star:setVisible(false)
		self._ccbOwner.layerG_star_bg:setVisible(false)
	end
end

function QUIWidgetHeroDetailFrame:checkRedTip()
	-- 是否显示小红点
	if self._heroIsExit then
	    local isTips = remote.herosUtil:checkHerosIsTipByID(self._actorId)
		if isTips then
		 	isTips = remote.herosUtil:checkHerosIsNeedTipByID(self._actorId)
		end
	    self._ccbOwner.node_tips_hero:setVisible(isTips)
	else
	    self._ccbOwner.node_tips_hero:setVisible(false)
	end
end

function QUIWidgetHeroDetailFrame:setProfessionByActorId(actorId)
	if actorId == nil then return end

    if self._professionalIcon == nil then 
	    self._professionalIcon = QUIWidgetHeroProfessionalIcon.new()
	    self._ccbOwner.node_hero_profession:addChild(self._professionalIcon)
	end
    self._professionalIcon:setHero(actorId)
end

function QUIWidgetHeroDetailFrame:setSABC()
	local aptitudeInfo = db:getActorSABC(self._actorId)
    q.setAptitudeShow(self._ccbOwner, aptitudeInfo.lower)
end

function QUIWidgetHeroDetailFrame:initHeroEquipment()
	self._equipBox = {}
	self._gemstoneBoxs = {}
	self._sparBoxs = {}

    for i = 1, 6 do
        self._equipBox[i] = QUIWidgetHeroEquipmentSmallBox.new()
        self._equipBox[i]:setScale(0.85)
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

	self._ccbOwner.node_root_tf:setPositionY(0)
    self._ccbOwner.node_hero_gemstone:setVisible(true)
    for i = 1, 4 do
        self._gemstoneBoxs[i] = QUIWidgetGemstonesSmallBox.new()
        self._ccbOwner["node_baoshi"..i]:addChild(self._gemstoneBoxs[i])
    end
    --晶石
	local sparLock = app.unlock:checkLock("UNLOCK_ZHUBAO", false)
    if sparLock then
	    for i = 1, 2 do
	        self._sparBoxs[i] = QUIWidgetGemstonesSmallBox.new()
	        self._ccbOwner["node_spar"..i]:addChild(self._sparBoxs[i])
	    end
	end
	self._gemstoneController = QGemstoneController.new()
	self._gemstoneController:setBoxs(self._gemstoneBoxs, self._sparBoxs)
end

function QUIWidgetHeroDetailFrame:resetQuipment()
	if app.unlock:checkLock("UNLOCK_GEMSTONE") and self._heroIsExit then 
		self._ccbOwner.node_root_tf:setPositionY(0)
	    self._ccbOwner.node_hero_gemstone:setVisible(true)
	else
		self._ccbOwner.node_root_tf:setPositionY(-35)
	    self._ccbOwner.node_hero_gemstone:setVisible(false)
	end
end

function QUIWidgetHeroDetailFrame:setEquipmentInfo()
	self:resetQuipment()

	if self._heroIsExit then
		if self._equipmentUtils then
			self._equipmentUtils:setHero(self._hero.actorId) 
		end
		if self._gemstoneController then
        	self._gemstoneController:setHero(self._hero.actorId)
    	end
		
		local UIHeroModel = remote.herosUtil:getUIHeroByID(self._actorId)
		-- set mount info
		self._ccbOwner.node_mount_box:setVisible(false)
		self._ccbOwner.node_mount:setVisible(false)
		self._ccbOwner.sp_mount_plus:setVisible(true)

		if app.unlock:checkLock("UNLOCK_ZUOQI", false) then
			local mountState = UIHeroModel:getMountState() 
			self._ccbOwner.node_mount_box:setVisible(true)
			if mountState == remote.mount.STATE_LOCK then
				self._ccbOwner.sp_mount_lock:setVisible(true)
				self._ccbOwner.sp_mount_plus:setVisible(false)
			else
				self._ccbOwner.sp_mount_lock:setVisible(false)
				if self._hero.zuoqi then
					self._ccbOwner.sp_mount_plus:setVisible(false)
					self._ccbOwner.node_mount:setVisible(true)
					local heroDisplay = db:getCharacterByID(self._hero.zuoqi.zuoqiId)
					if self._mountIcon == nil then
						self._mountIcon = CCSprite:create()
						self._ccbOwner.node_mount:addChild(self._mountIcon)
					end
					self._mountIcon:setTexture(CCTextureCache:sharedTextureCache():addImage(heroDisplay.icon))
				end
			end
		end

		--set artifact info
		self._ccbOwner.node_artifact_box:setVisible(false)
		self._ccbOwner.node_artifact:setVisible(false)
		self._ccbOwner.sp_artifact_plus:setVisible(true)
		local artifactId = remote.artifact:getArtiactByActorId(self._actorId)
		if app.unlock:checkLock("UNLOCK_ARTIFACT", false) and artifactId then
			local artifactState = UIHeroModel:getArtifactState() 
			self._ccbOwner.node_artifact_box:setVisible(true)
			if artifactState == remote.artifact.STATE_LOCK then
				self._ccbOwner.sp_artifact_lock:setVisible(true)
				self._ccbOwner.sp_artifact_plus:setVisible(false)
			else
				self._ccbOwner.sp_artifact_lock:setVisible(false)
				if self._hero.artifact then
					self._ccbOwner.sp_artifact_plus:setVisible(false)
					self._ccbOwner.node_artifact:setVisible(true)
					local itemInfo = db:getItemByID(artifactId)
					if self._artifactIcon == nil then
						self._artifactIcon = CCSprite:create()
						self._ccbOwner.node_artifact:addChild(self._artifactIcon)
					end
					self._artifactIcon:setTexture(CCTextureCache:sharedTextureCache():addImage(itemInfo.icon))
				end
			end
		end

		-- set soulspirit info
		self._ccbOwner.node_soulSpirit_box:setVisible(false)
		self._ccbOwner.node_soulSpirit:setVisible(false)
		self._ccbOwner.sp_soulSpirit_plus:setVisible(true)
		if remote.soulSpirit:checkSoulSpiritUnlock() then
	        local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
			self._ccbOwner.node_soulSpirit_box:setVisible(true)
			if heroInfo.soulSpirit then
				self._ccbOwner.sp_soulSpirit_plus:setVisible(false)
				local characterConfig = QStaticDatabase:sharedDatabase():getCharacterByID(heroInfo.soulSpirit.id)
				self._ccbOwner.node_soulSpirit:removeAllChildren()
				self._soulSpiritIcon = nil
				if self._soulSpiritIcon == nil then
					self._soulSpiritIcon = CCSprite:create()
					self._ccbOwner.node_soulSpirit:addChild(self._soulSpiritIcon)
					self._ccbOwner.node_soulSpirit:setVisible(true)
				end

				local soulSpiritIcon = characterConfig and characterConfig.icon
				if soulSpiritIcon then
					local iconTexture = CCTextureCache:sharedTextureCache():addImage(soulSpiritIcon)
					self._soulSpiritIcon:setTexture(iconTexture)
				end
			end
		end
	else
		self._ccbOwner.node_mount_box:setVisible(false)
		self._ccbOwner.node_artifact_box:setVisible(false)
		self._ccbOwner.node_soulSpirit_box:setVisible(false)

		if self._equipmentUtils then
			self._equipmentUtils:_removeAll() 
			self._equipmentUtils:showGreenState() 
		end
	end
end

function QUIWidgetHeroDetailFrame:setHeroCard(path)
    if path then
    	local frame = QSpriteFrameByPath(path)
    	if frame then
    		self._heroCardSprite:setDisplayFrame(frame)
    	end
    end
end

function QUIWidgetHeroDetailFrame:getName()
	return "QUIWidgetHeroDetailFrame"
end

function QUIWidgetHeroDetailFrame:getHero()
	return self._actorId
end

function QUIWidgetHeroDetailFrame:selected()
	self._ccbOwner.node_hero_select:setVisible(true)
end

function QUIWidgetHeroDetailFrame:unselected()
	self._ccbOwner.node_hero_select:setVisible(false)
end

function QUIWidgetHeroDetailFrame:setFramePos(pos)
	self._pos = pos
end

function QUIWidgetHeroDetailFrame:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetHeroDetailFrame:showFight()
	self._isFight = true
	self._ccbOwner.node_hero_fight:setVisible(true)
end

function QUIWidgetHeroDetailFrame:removeFight()
	self._isFight = false
	self._ccbOwner.node_hero_fight:setVisible(false)
end

--event callback area--
function QUIWidgetHeroDetailFrame:_onTriggerHeroOverview(tag, menuItem)
	local position = self:convertToWorldSpaceAR(ccp(0,0))

	self:dispatchEvent({name = QUIWidgetHeroDetailFrame.EVENT_HERO_FRAMES_CLICK, hero = self._hero, actorId = self._actorId, position = position})
end

function QUIWidgetHeroDetailFrame:_removeDelay()
	if self._delay ~= nil then 
		scheduler.unscheduleGlobal(self._delay)
		self._delay = nil
	end
end

return QUIWidgetHeroDetailFrame
