local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroCombinationCilent = class("QUIWidgetHeroCombinationCilent", QUIWidget)

local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetHeroHead = import(".QUIWidgetHeroHead")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QActorProp = import("...models.QActorProp")
local QUIWidgetEquipmentSpecialBox = import("..widgets.QUIWidgetEquipmentSpecialBox")
local QUIWidgetHeroEquipment = import("..widgets.QUIWidgetHeroEquipment")

QUIWidgetHeroCombinationCilent.CLICK_HERO_HEAD = "CLICK_HERO_HEAD"

function QUIWidgetHeroCombinationCilent:ctor(options)
	local ccbFile = "ccb/Widget_HeroSuming_Client1.ccbi"
	local callBacks = {
		-- {ccbCallbackName = "onTriggerClickBar", callback = handler(self, QUIWidgetHeroCombinationCilent._onTriggerClickBar)}
	}
	QUIWidgetHeroCombinationCilent.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	-- setShadow5(self._ccbOwner.combination_name1, ccc3(83, 39, 11))
	-- setShadow5(self._ccbOwner.combination_name2)

	for i = 1, 6 do
		self._ccbOwner["node"..i]:setVisible(false)
	end
end

function QUIWidgetHeroCombinationCilent:onEnter()
end

function QUIWidgetHeroCombinationCilent:onExit()

end

function QUIWidgetHeroCombinationCilent:setCombinationInfo(actorId, combination)
	if combination == nil then return end

	self._actorId = actorId
	self._combinationInfo = combination
	local heroNums = 0

	-- check enchant combination 
	self._isEnhant = false
	if self._combinationInfo.badge_gad_1 then
		self._isEnhant = true
	end 

	--set combination description
	local heroInfos = QStaticDatabase:sharedDatabase():getCharacterByID(self._actorId)
	self._ccbOwner.combination_name1:setString(self._combinationInfo.combination or "")
	local prop = self:getCombinationProp()
	self._ccbOwner.hero_name:setString((prop[1] or "").."  "..(prop[2] or ""))
	self._ccbOwner.combination_prop:setString("")

	-- set hero head
	local index = 1
	self._heroHead = {}
	if self._isEnhant then
		self:setEquimentInfo()
	else
		for i = 1, 6 do
			if self._combinationInfo["combination_hero_"..i] or self._combinationInfo["show_hero"..i] then
				index = index + 1
				self:setHeroInfo(self._combinationInfo["combination_hero_"..i], i)
				self._ccbOwner["node"..i]:setVisible(true)
			end
		end
	end

	-- set bg size 
	if index <= 4 then
		self._ccbOwner.bg_1:setPreferredSize(CCSize(338, 210))
	else
		self._ccbOwner.bg_1:setPreferredSize(CCSize(338, 335))
	end

	-- check is active
	local active = remote.herosUtil:checkHeroCombination(self._actorId, self._combinationInfo)
	if self._isEnhant then 
		active = remote.herosUtil:checkEnchantCombination(self._actorId, self._combinationInfo)
	end
	if active then
		self._ccbOwner.ly_bg_1:setStartColor(ccc3(255, 229, 194))
		self._ccbOwner.ly_bg_2:setStartColor(ccc3(255, 229, 194))
		self._ccbOwner.ly_bg_1:setStartOpacity(255)
		self._ccbOwner.ly_bg_2:setStartOpacity(255)
    	q.setNodeShadow(self, false)
	else
		self._ccbOwner.ly_bg_1:setStartColor(ccc3(10, 10, 10))
		self._ccbOwner.ly_bg_2:setStartColor(ccc3(10, 10, 10))
		self._ccbOwner.ly_bg_1:setStartOpacity(30)
		self._ccbOwner.ly_bg_2:setStartOpacity(30)
    	q.setNodeShadow(self, true)
		if self._isEnhant then 
			makeNodeFromNormalToGray(self._ccbOwner["node_equipment"..1])
			makeNodeFromNormalToGray(self._ccbOwner["node_equipment"..2])
		end
	end
end

function QUIWidgetHeroCombinationCilent:getCombinationProp()
	local prop = {}
	local index = 1
    if self._combinationInfo["attack_percent"] ~= nil then
    	prop[index] = "攻击 +"..(self._combinationInfo["attack_percent"]*100).."%"
    	index = index + 1
    end
    if self._combinationInfo["hp_percent"] ~= nil then
    	prop[index] = "生命 +"..(self._combinationInfo["hp_percent"]*100).."%"
    	index = index + 1
    end
    if self._combinationInfo["armor_magic_percent"] ~= nil then
    	prop[index] = "法防 +"..(self._combinationInfo["armor_magic_percent"]*100).."%"
    	index = index + 1
    end
    if self._combinationInfo["armor_physical_percent"] ~= nil then
    	prop[index] = "物防 +"..(self._combinationInfo["armor_physical_percent"]*100).."%"
    	index = index + 1
    end
    return prop 
end

function QUIWidgetHeroCombinationCilent:setHeroInfo(actorId, index)
	if self._heroHead[index] == nil then
		self._heroHead[index] = QUIWidgetHeroHead.new()
		self._ccbOwner["hero_node"..index]:addChild(self._heroHead[index])
	end

	self._ccbOwner["no_hero"..index]:setVisible(false)

	local heros = remote.herosUtil:getHeroByID(actorId) or {}
	local isHide = db:checkHeroShields(actorId)
	if self._combinationInfo["show_hero"..index] == 1 or isHide then
		self._heroHead[index]:setHero(nil, nil, index, true)
		self._ccbOwner["hero_name"..index]:setString("即将开放")
	else
		self._heroHead[index]:setHeroSkinId(heros.skinId)
		self._heroHead[index]:setHero(actorId)
		local heroInfos = q.cloneShrinkedObject(QStaticDatabase:sharedDatabase():getCharacterByID(actorId))
		self._ccbOwner["hero_name"..index]:setString(heroInfos.name)
		
		if remote.herosUtil:checkHeroHavePast(actorId) == false then
			self._ccbOwner["no_hero"..index]:setVisible(true)
			self._ccbOwner["hero_name"..index]:setColor(ccc3(109, 106, 108))
			makeNodeFromNormalToGray(self._ccbOwner["hero_node"..index])
		else
			self._ccbOwner["hero_name"..index]:setColor(ccc3(134, 84, 54))
			makeNodeFromGrayToNormal(self._ccbOwner["hero_node"..index])
		end
		self._heroHead[index]:setBreakthrough(0)
		self._heroHead[index]:setGodSkillShowLevel(heros.godSkillGrade)
	end

	self._heroHead[index]:addEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self.clickHeroHead))
end

function QUIWidgetHeroCombinationCilent:setEquimentInfo()
	local equipBox = {}
	for i = 1, 2 do
		equipBox[i] = QUIWidgetEquipmentSpecialBox.new()
		self._ccbOwner["node_equipment"..i]:addChild(equipBox[i])
		equipBox[i]:addEventListener(QUIWidgetEquipmentSpecialBox.EVENT_EQUIPMENT_BOX_CLICK, handler(self, self.clickEquipment))
	end
	--纹章 徽章
	equipBox[1]:setType(EQUIPMENT_TYPE.JEWELRY1)
	equipBox[2]:setType(EQUIPMENT_TYPE.JEWELRY2)

	--装备控制器
	local equipmentUtils = QUIWidgetHeroEquipment.new()
	self:getView():addChild(equipmentUtils) --此处添加至节点没有显示需求
	equipmentUtils:setUI(equipBox)
	equipmentUtils:setHero(self._actorId) -- 装备显示

	for i = 1, 2 do
		equipBox[i]:showStrengthenLevelIcon(false)
		equipBox[i]:showCanEnchant(false)
		equipBox[i]:showCanEvolution(false)
	end
end

function QUIWidgetHeroCombinationCilent:getContentSize()
	local preferredSize = self._ccbOwner.bg_1:getPreferredSize()
	return preferredSize 
end

function QUIWidgetHeroCombinationCilent:clickHeroHead(event)
	if event == nil then return end

    app.sound:playSound("common_common")
	self:dispatchEvent({name = QUIWidgetHeroCombinationCilent.CLICK_HERO_HEAD, actorId = event.target._actorId})
end

function QUIWidgetHeroCombinationCilent:clickEquipment(event)
	if event == nil then return end
	app.tip:floatTip("魂师大人，将戒指和项链觉醒到"..(self._combinationInfo.badge_gad_1 or 2).."星即可激活宿命哦~~")
end

return QUIWidgetHeroCombinationCilent
