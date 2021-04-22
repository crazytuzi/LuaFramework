--
-- Author: xurui
-- Date: 2016-05-17 15:37:27
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogCombinationAchieve = class("QUIDialogCombinationAchieve", QUIDialog)

local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QNavigationController = import("...controllers.QNavigationController")
local QRichText = import("...utils.QRichText")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetEquipmentSpecialBox = import("..widgets.QUIWidgetEquipmentSpecialBox")
local QUIWidgetHeroEquipment = import("..widgets.QUIWidgetHeroEquipment")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

function QUIDialogCombinationAchieve:ctor(options)
	local ccbFile = "ccb/Dialog_sumingjihuo.ccbi"
	local callBacks = {}
	QUIDialogCombinationAchieve.super.ctor(self, ccbFile, callBacks, options)	

	if options then
		self._combinationInfo = options.combinationInfo
		self._callBack = options.callBack
		self._actorId = options.actorId
		self._combnationHeros = options.combnationHeros
	end
	self._animationIsDone = false
	
	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)

	self:updateRankInfo()
	self:setCombinationInfo()

	scheduler.performWithDelayGlobal(function()
			app.sound:playSound("common_end")
		end, 10/30)	

	scheduler.performWithDelayGlobal(function()
			self._animationIsDone = true
		end, 2+1/3)	
end

function QUIDialogCombinationAchieve:updateRankInfo()
	local combinationRank = remote.user.heroCombinationRank or 0
	local index = app.tip:getCombinationIndex()
	local oldCombinationCount = remote.herosUtil:getCombinationCount()
	self._ccbOwner.tf_old_count:setString(oldCombinationCount + index - 1)
	self._ccbOwner.tf_new_count:setString(oldCombinationCount + index)

	if combinationRank ~= 0 then
		self._ccbOwner.tf_rank:setString(combinationRank)
	else
		self._ccbOwner.tf_rank:setString("未上榜")
	end
end

function QUIDialogCombinationAchieve:viewDidAppear()
	QUIDialogCombinationAchieve.super.viewDidAppear(self)
end

function QUIDialogCombinationAchieve:viewWillDisappear()
	QUIDialogCombinationAchieve.super.viewWillDisappear(self)
end

function QUIDialogCombinationAchieve:setCombinationInfo()
	-- set hero info
	local maxNum = 6
	self:_createHeroHead(maxNum, self._combinationInfo.hero_id)

	maxNum = maxNum - 1
	local haveNum = 1
	if self._combinationInfo.badge_gad_1 then
		self:createEquipmentBox()
		haveNum = 3
	else
		local index = maxNum
		for i = 1, index do
			if self._combinationInfo["combination_hero_"..i] then
				haveNum = haveNum + 1
				self:_createHeroHead(maxNum, self._combinationInfo["combination_hero_"..i])
			else
				self._ccbOwner["node"..maxNum]:setVisible(false)
			end
			maxNum = maxNum - 1
		end
	end
	local offsetX = (6 - haveNum) * 73
	self._ccbOwner.hero_client:setPositionX(self._ccbOwner.hero_client:getPositionX() + offsetX)

	-- set combination prop
	local heroInfo = QStaticDatabase:sharedDatabase():getCharacterByID(self._combinationInfo.hero_id)
	local richText = QRichText.new({
            {oType = "font", content = "获得以上魂师激活", size = 23,color = ccc3(255,255,255)},
            {oType = "font", content = heroInfo.name, size = 23,color = ccc3(254,251,0)},
            {oType = "font", content = "宿命：",size = 23,color = ccc3(255,255,255)},
            {oType = "font", content = self._combinationInfo.combination, size = 23,color = ccc3(254,251,0)},
        },790)
	self._ccbOwner.combination_dec:setString("")
	self._ccbOwner.tf_node_content:addChild(richText)

	local wordLen = q.wordLen("获得以上魂师激活"..(heroInfo.name or "").."宿命："..(self._combinationInfo.combination or ""), 22, 10)
	local positionX = self._ccbOwner.tf_node_content:getPositionX() - (wordLen-396)/2
	local positionY = self._ccbOwner.tf_node_content:getPositionY() - 25
	self._ccbOwner.tf_node_content:setPosition(ccp(positionX, positionY))

    makeNodeCascadeOpacityEnabled(self._ccbOwner.tf_node_content, true)
	-- self._ccbOwner.tf_node_content:setOpacity(0)
	-- scheduler.performWithDelayGlobal(function()
	-- 		self._ccbOwner.tf_node_content:runAction(CCFadeIn:create(1/10))
	-- 	end, 1+9/30)	
	local oldContentSize = 143
	self._ccbOwner.hero_name:setString(heroInfo.name or "")
	local offsetX = (oldContentSize - self._ccbOwner.hero_name:getContentSize().width)/2

	oldContentSize = 269
	self._ccbOwner.combination_name1:setString((self._combinationInfo.combination or "").."：")
	self._ccbOwner.combination_name2:setString((self._combinationInfo.combination or "").."：")
	local offsetX2 = (oldContentSize - self._ccbOwner.combination_name2:getContentSize().width)/2
	self._ccbOwner.node_name:setPositionX(offsetX+offsetX2-10)

	local propInfo = self:getCombinationProp()
	self._ccbOwner.combination_prop:setString((propInfo[1] or "").."   "..(propInfo[2] or ""))
	self._ccbOwner.node_prop:setPositionX(-offsetX+20)

	oldContentSize = 248.2
	local offsetX3 = (oldContentSize - self._ccbOwner.combination_prop:getContentSize().width)/2
	self._ccbOwner.node_combination_desc:setPositionX(-(offsetX+offsetX2)/2+offsetX3)
end

function QUIDialogCombinationAchieve:_createHeroHead(index, actorId)
	local heros = remote.herosUtil:getHeroByID(actorId) or {}
    local heroInfo = q.cloneShrinkedObject(QStaticDatabase:sharedDatabase():getCharacterByID(actorId))
	local heroHead = QUIWidgetHeroHead.new()
	heroHead:setHeroSkinId(heros.skinId)
    heroHead:setHero(actorId)
	for _,value in ipairs(HERO_SABC) do
        if value.aptitude == tonumber(heroInfo.aptitude) then
        	heroHead:setBreakthrough(value.breakLevel)
			break
        end
    end
    heroHead:showSabc()
    heroHead:setGodSkillShowLevel(heros.godSkillGrade)

 --    local profession = heroInfo.func or "dps"
	-- heroHead:setProfession(profession)
	if self._combnationHeros == actorId then
		heroHead:setHighlightedSelectState(true)
	end

    self._ccbOwner["node_hero_"..index]:addChild(heroHead)
    self._ccbOwner["hero_name_"..index]:setString(heroInfo.name or "")

    makeNodeCascadeOpacityEnabled(self._ccbOwner["node"..index], true)
    self._ccbOwner["node"..index]:setOpacity(0)

	scheduler.performWithDelayGlobal(function()
			self._ccbOwner["node"..index]:runAction(CCFadeIn:create(1/6))
		end, 17/30)	
end

function QUIDialogCombinationAchieve:createEquipmentBox()
	local equipBox = {}
	local index = 5
	for i = 1, 2 do
		equipBox[i] = QUIWidgetEquipmentSpecialBox.new()
		self._ccbOwner["node_hero_"..index]:addChild(equipBox[i])
		index = index - 1
	end
	--纹章 徽章
	equipBox[1]:setType(EQUIPMENT_TYPE.JEWELRY1)
	equipBox[2]:setType(EQUIPMENT_TYPE.JEWELRY2)

	--装备控制器
	local equipmentUtils = QUIWidgetHeroEquipment.new()
	self:getView():addChild(equipmentUtils) --此处添加至节点没有显示需求
	equipmentUtils:setUI(equipBox)
	equipmentUtils:setHero(self._actorId) -- 装备显示

	index = 5
	for i = 1, 2 do
   		self._ccbOwner["hero_name_"..index]:setString(equipBox[i]._itemInfo.name or "")
		equipBox[i]:showStrengthenLevelIcon(false)
		equipBox[i]:showCanEnchant(false)
		equipBox[i]:showCanEvolution(false)
		index = index - 1
	end

	for i = 5, 4, -1 do
	    makeNodeCascadeOpacityEnabled(self._ccbOwner["node"..i], true)
	    self._ccbOwner["node"..i]:setOpacity(0)

		scheduler.performWithDelayGlobal(function()
				self._ccbOwner["node"..i]:runAction(CCFadeIn:create(1/6))
			end, 1+2/15)
	end

	for i = 3, 1, -1 do
		self._ccbOwner["node"..i]:setVisible(false)
	end
end 

function QUIDialogCombinationAchieve:getCombinationProp()
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

function QUIDialogCombinationAchieve:_backClickHandler()
	if not self._animationIsDone then return end

    local callback = self._callBack
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)

    if app.tip._combnationInfos and next(app.tip._combnationInfos) then
    	app.tip:creatCombinationTip(callback)
    else
	    if callback ~= nil then
	        callback()
	    end
	end
end

return QUIDialogCombinationAchieve 