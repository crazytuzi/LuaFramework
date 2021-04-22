--
-- Author: qinyuanji
-- Date: 2015-03-5 17:08:35
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroEquipmentEnchant = class("QUIWidgetHeroEquipmentEnchant", QUIWidget)

local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetHeroEquipmentEvolutionItem = import("..widgets.QUIWidgetHeroEquipmentEvolutionItem")
local QQuickWay = import("...utils.QQuickWay")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIDialogHeroEquipmentDetail = import("..dialogs.QUIDialogHeroEquipmentDetail")
local QUIWidgetEquipmentAvatar = import("..widgets.QUIWidgetEquipmentAvatar")
local QUIWidgetEnchantStar = import("..widgets.QUIWidgetEnchantStar")
local QRichText = import("...utils.QRichText")
local QColorLabel = import("...utils.QColorLabel")
local QQuickWay = import("...utils.QQuickWay")
local QScrollView = import("...views.QScrollView") 

QUIWidgetHeroEquipmentEnchant.MOVEMENT_MINIMUM_PIXEL = 10
QUIWidgetHeroEquipmentEnchant.GAP = 20
QUIWidgetHeroEquipmentEnchant.ITEM_WIDTH = 70
QUIWidgetHeroEquipmentEnchant.COLUMN_NUMBER = 5
QUIWidgetHeroEquipmentEnchant.ENCHANT = "EquipmentEnchant"   -- Author: xurui   -- 当激活觉醒大师时，用来通知 QUIDialogHeroEquipmentDetail 创建一个遮罩
QUIWidgetHeroEquipmentEnchant.ENCHANT_SUCCESS_EVENT = "ENCHANT_SUCCESS_EVENT"
QUIWidgetHeroEquipmentEnchant.ENCHANT_RESET_EVENT = "ENCHANT_RESET_EVENT"

function QUIWidgetHeroEquipmentEnchant:ctor(options)
	local ccbFile = "ccb/Widget_HeroEquipment_Enchant_e.ccbi"
	local callBacks = {
			{ccbCallbackName = "onTriggerEnchant", callback = handler(self, QUIWidgetHeroEquipmentEnchant._onTriggerEnchant)},
			{ccbCallbackName = "onTriggerInfo", callback = handler(self, QUIWidgetHeroEquipmentEnchant._onTriggerInfo)},
			{ccbCallbackName = "onTriggerReset", callback = handler(self, QUIWidgetHeroEquipmentEnchant._onTriggerReset)},
		}
	QUIWidgetHeroEquipmentEnchant.super.ctor(self,ccbFile,callBacks,options)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._ccbOwner.tf_special_info:setString("")
	self._ccbOwner.tf_normal_info:setString("")

	self._updateAttribute = {}
end

function QUIWidgetHeroEquipmentEnchant:onEnter()
	QUIWidgetHeroEquipmentEnchant.super.onEnter(self)
    
	self._userEventProxy = cc.EventProxy.new(remote.user)
    self._userEventProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, handler(self, self.updateInfo))

	self:_initScrollView()
end

function QUIWidgetHeroEquipmentEnchant:onExit()
	QUIWidgetHeroEquipmentEnchant.super.onExit(self)
    self._userEventProxy:removeAllEventListeners()
end

function QUIWidgetHeroEquipmentEnchant:_initScrollView()
	-- By Kumo：把scrollView的初始化放在構造函數完成，因為戰鬥界面的跳轉會先執行setinfo，放在構造之外的地方初始化，可能導致bug
	if not self._scrollView then
		local itemContentSize = self._ccbOwner.sheet_layout:getContentSize()
	    self._scrollView = QScrollView.new(self._ccbOwner.sheet, itemContentSize, {bufferMode = 1})
	    self._scrollView:setVerticalBounce(true)
	end
end

function QUIWidgetHeroEquipmentEnchant:setInfo(actorId, itemId)
	if self._isPlaying and self._itemId == itemId and self._actorId == actorId then return end
	self:_initScrollView()
	
	local enchant = remote.herosUtil:getWearByItem(actorId, itemId)
	self._actorId = actorId
	self._itemId = itemId
	self._enchant = enchant
	if enchant ~= nil then
		local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(itemId)
		self:_updateEnchantNode(1, itemConfig, actorId, enchant.enchants or 0)

		if (enchant.enchants or 0) < QStaticDatabase:sharedDatabase():getMaxEnchantLevel(itemId,actorId) then
			self:_displayNonMaxLevel(itemConfig, actorId, (enchant.enchants or 0) + 1)
		else
			self:_displayMaxLevel(itemConfig, actorId, enchant.enchants)
		end
	end
end

function QUIWidgetHeroEquipmentEnchant:_updateEnchantNode(index, itemConfig, actorId, level)	
	self._ccbOwner["item"..index]:removeAllChildren()
	local item = QUIWidgetEquipmentAvatar.new()
	item:setEquipmentInfo(itemConfig, actorId)
	self._ccbOwner["item"..index]:addChild(item)

	self:_updateEnchantStar(index, level)

	-- Update attribute
	local enchantConfig = QStaticDatabase:sharedDatabase():getEnchant(itemConfig.id, level, actorId)
	local config = self:_getEnchantValue(enchantConfig)
	self._ccbOwner["tf_name"..index.."_1"]:setVisible(level > 0)
	self._ccbOwner["tf_value"..index.."_1"]:setVisible(level > 0)
	self._ccbOwner["tf_name"..index.."_1"]:setString(config[1] and (config[1].description or "") or "")
	self._ccbOwner["tf_value"..index.."_1"]:setString("+" .. (config[1] and (config[1].value or 0) or 0))
	self._ccbOwner["tf_name"..index.."_2"]:setVisible(#config > 1)
	self._ccbOwner["tf_value"..index.."_2"]:setVisible(#config > 1)
	if #config > 1 then
		self._ccbOwner["tf_name"..index.."_2"]:setString(config[2].description)
		self._ccbOwner["tf_value"..index.."_2"]:setString("+" .. config[2].value)
	end

	self._ccbOwner.tf_money:setString(tostring(enchantConfig.money))
	if (enchantConfig.money or 0) > remote.user.money then
		self._ccbOwner.tf_money:setColor(UNITY_COLOR_LIGHT.red)
	else
		self._ccbOwner.tf_money:setColor(ccc3(58,22,0))
	end

	self._updateAttribute[index] = {}
	for i = 1, 2, 1 do
		self._updateAttribute[index][i] = {}
		config[i] = config[i] ~= nil and config[i] or {}
		self._updateAttribute[index][i].name = config[i].description
		if config[i].description ~= nil and (config[i].description == "攻击百分比" or config[i].description == "生命百分比") then
			self._updateAttribute[index][i].value = tonumber(config[i].realValue) or 0
		else
			self._updateAttribute[index][i].value = tonumber(config[i].value) or 0
		end
	end

	-- Update equipment name
    local breaklevel = remote.herosUtil:getHeroEquipmentEvolutionByID(actorId, itemConfig.id)
    local _level, color = remote.herosUtil:getBreakThrough(breaklevel) 
    local name = itemConfig.name
    if _level > 0 then
    	name = name .. "＋".. _level
    end
	self._ccbOwner["name"..index]:setString(name)
	local fontColor = BREAKTHROUGH_COLOR_LIGHT[color]
	self._ccbOwner["name"..index]:setColor(fontColor)
	self._ccbOwner["name"..index] = setShadowByFontColor(self._ccbOwner["name"..index], fontColor)

	-- set enchant description
	local description = "##n觉醒能大幅度提升装备属性##d和##e魂师战斗力##n。"
	if enchantConfig.describe then
		description = enchantConfig.describe
	end
	if self._desText ~= nil then
		self._desText:removeFromParent()
		self._desText = nil
	end
	self._desText = QColorLabel:create(description, 450, 50, nil, 22, ccc3(76, 33, 0), global.font_zhcn)
	self._ccbOwner.node_normal_info:addChild(self._desText)
end

function QUIWidgetHeroEquipmentEnchant:_updateEnchantStar(index, level)
	self._ccbOwner["enchant_star" .. index]:removeAllChildren()

	local enchantStar = QUIWidgetEnchantStar.new({number = level})
	self._ccbOwner["enchant_star" .. index]:addChild(enchantStar)

	if index == 1 then
		if level > 0 then
	    	self._ccbOwner.btn_reset:setVisible(true)
	    else
	    	self._ccbOwner.btn_reset:setVisible(false)
	    end
    end
end

function QUIWidgetHeroEquipmentEnchant:_getEnchantValue(enchantConfig)
	local config = {}
	if enchantConfig.attack_percent then
		table.insert(config, {description = "攻击百分比", value = string.format("%0.1f%%", enchantConfig.attack_percent * 100), realValue = enchantConfig.attack_percent, enchantConfig.passive_skill, enchantConfig.passive_skill_level})
	end
	if enchantConfig.hp_percent then
		table.insert(config, {description = "生命百分比", value = string.format("%0.1f%%", enchantConfig.hp_percent * 100) , realValue = enchantConfig.hp_percent, enchantConfig.passive_skill, enchantConfig.passive_skill_level})
	end
	if enchantConfig.attack_grow then
		table.insert(config, {description = "攻击成长", value = enchantConfig.attack_grow})
	end
	if enchantConfig.hp_grow then
		table.insert(config, {description = "生命成长", value = enchantConfig.hp_grow})
	end
	if enchantConfig.armor_physical_grow then
		table.insert(config, {description = "物防成长", value = enchantConfig.armor_physical_grow})
	end
	if enchantConfig.armor_magic_grow then
		table.insert(config, {description = "法防成长", value = enchantConfig.armor_magic_grow})
	end
	if enchantConfig.attack_value then
		table.insert(config, {description = "攻击", value = enchantConfig.attack_value})
	end
	if enchantConfig.hp_value then
		table.insert(config, {description = "生命", value = enchantConfig.hp_value})
	end
	if enchantConfig.armor_physical then
		table.insert(config, {description = "物理防御", value = enchantConfig.armor_physical})
	end
	if enchantConfig.armor_magic then
		table.insert(config, {description = "法术防御", value = enchantConfig.armor_magic})
	end
	if enchantConfig.hit_rating then
		table.insert(config, {description = "命中等级", value = enchantConfig.hit_rating})
	end
	if enchantConfig.dodge_rating then
		table.insert(config, {description = "闪避等级", value = enchantConfig.dodge_rating})
	end
	if enchantConfig.critical_rating then
		table.insert(config, {description = "暴击等级", value = enchantConfig.critical_rating})
	end
	if enchantConfig.cri_reduce_rating then
		table.insert(config, {description = "抗暴等级", value = enchantConfig.cri_reduce_rating})
	end
	if enchantConfig.hit_grow then
		table.insert(config, {description = "命中率成长", value = enchantConfig.hit_grow})
	end
	if enchantConfig.dodge_grow then
		table.insert(config, {description = "闪避成长", value = enchantConfig.dodge_grow})
	end

	return config
end

function QUIWidgetHeroEquipmentEnchant:_displayNonMaxLevel(itemConfig, actorId, level)
	self._ccbOwner.incomplete:setVisible(true)
	self._ccbOwner.complete:setVisible(false)
	self._ccbOwner.btn_reset:setPositionY(-88)

	self:_updateEnchantNode(2, itemConfig, actorId, level)

	self._heroInfo = remote.herosUtil:getHeroByID(self._actorId)
	local materials, enchantConfig = QStaticDatabase:sharedDatabase():getEnchantMaterials(itemConfig.id, level, actorId)
	-- for i = 1, 3 do
	-- 	self._ccbOwner["material" .. i]:removeAllChildren()
	-- end
	self._ccbOwner.node_material1:removeAllChildren()
	self._ccbOwner.node_material2:removeAllChildren()
	self._ccbOwner.node_normal:setVisible(false)
	self._ccbOwner.node_special:setVisible(false)
	local itemContent = nil
	if enchantConfig.skill_show ~= nil then
		itemContent = self._ccbOwner.node_material2
		self._ccbOwner.node_special:setVisible(true)
		local skillConfig = QStaticDatabase:sharedDatabase():getSkillByID(enchantConfig.skill_show)
		local name = ""
		if skillConfig ~= nil then
			name = skillConfig.name or ""
			name = name.."："
		end

		self._ccbOwner.tf_special_name:setString(name)
		self._scrollView:clear()

		local desc = QColorLabel.replaceColorSign(enchantConfig.describe, false)
	    local strArr  = string.split(desc,"\n") or {}
	    local textNode = CCNode:create()
	    local height = 0
	    for i, v in pairs(strArr) do
	        local richText = QRichText.new(v, 380, {stringType = 1, defaultColor = GAME_COLOR_LIGHT.normal, defaultSize = 20})
	        richText:setAnchorPoint(ccp(0, 1))
	        richText:setPositionY(-height)
	        textNode:addChild(richText)
	        height = height + richText:getContentSize().height
	    end
	    textNode:setContentSize(CCSize(380, height))
	    textNode:setPositionY(-5)
		self._scrollView:addItemBox(textNode)
		self._scrollView:setRect(0, -height-5, 0, 0)
	else
		itemContent = self._ccbOwner.node_material1
		self._ccbOwner.node_normal:setVisible(true)
	end
	for k, v in ipairs(materials) do
		local material = QUIWidgetHeroEquipmentEvolutionItem.new()
		material:setInfo(v.id, v.count)
		material:addEventListener(QUIWidgetHeroEquipmentEvolutionItem.EVENT_CLICK, handler(self, self._equipmentSelected))
		material:setPositionX((k-1) * 100)
		itemContent:addChild(material)
	end

	self._onTriggerEnchantImp = function ( ... )
		if self._isPlaying then return end

		for k, v in ipairs(materials) do
			if v.count > remote.items:getItemsNumByID(v.id) then
				QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, v.id, v.count)
				return
			end
		end

		if tonumber(self._ccbOwner.tf_money:getString()) > remote.user.money then
    		QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.MONEY)
			return
		end

		self._masterType = "zhuangbeifumo_master_"
		if self._equipmentPos == EQUIPMENT_TYPE.JEWELRY1 or self._equipmentPos == EQUIPMENT_TYPE.JEWELRY2 then
			self._masterType = "shipingfumo_master_"
		end
		local oldUIModel = clone(remote.herosUtil:getUIHeroByID(self._actorId))
		local oldMasterLevel = oldUIModel:getMasterLevelByType(self._masterType)
		self._isPlaying = true
		app:getClient():enchant(self._actorId, self._itemId, function ()
			local masterUpGrade = nil
			local newUIModel = remote.herosUtil:getUIHeroByID(self._actorId)
			local newMasterLevel = newUIModel:getMasterLevelByType(self._masterType)
			masterUpGrade = newMasterLevel > oldMasterLevel and newMasterLevel or nil

			self:_playAnimation(handler(self, self.updateInfo), masterUpGrade, (self._enchant.enchants or 0))
			remote.user:addPropNumForKey("todayEquipEnchantCount", 1)
		end)
	end
end

function QUIWidgetHeroEquipmentEnchant:_playAnimation(callback, masterUpGrade, enchantLevel)
	local effectFunc = function ( ... )

		local combination = nil
		local combinationInfo = QStaticDatabase:sharedDatabase():getCombinationInfoByHeroId(self._actorId)
		for i = 1, #combinationInfo do
			if remote.herosUtil:checkEnchantCombination(self._actorId, combinationInfo[i]) then
				combination = combinationInfo[i]
				break
			end
		end
		if combination then
	        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogCombinationAchieve", 
	            options = {actorId = self._actorId, combinationInfo = combination, combnationHeros = self._actorId, callBack = callBack}}, {isPopCurrentDialog = false})
		end

		self._isPlaying = false
		if callback then
			callback()
		end
		if masterUpGrade ~= nil then
			self:dispatchEvent({name = QUIWidgetHeroEquipmentEnchant.ENCHANT, masterUpGrade = masterUpGrade, masterType = self._masterType, isShowMaster = true, actorId =  self._actorId})
		end
		self:dispatchEvent({name = QUIWidgetHeroEquipmentEnchant.ENCHANT_SUCCESS_EVENT, enchantLevel = enchantLevel})
		self:dispatchEvent({name = QUIDialogHeroEquipmentDetail.REFESH_BATTLE_FORCE})
	end

	local successTip = app.master.JEWELRY_ENCHANT_TIP
	if self._equipmentPos ~= EQUIPMENT_TYPE.JEWELRY1 and self._equipmentPos ~= EQUIPMENT_TYPE.JEWELRY2 then
		successTip = app.master.EQUIPMENT_ENCHANT_TIP
	end
	if app.master:getMasterShowState(successTip) then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogEquipmentEnchantSuccess", 
	    	options = {props = self._updateAttribute, itemId = self._itemId, actorId = self._actorId, equipmentPos = self._equipmentPos, successTip = successTip, callBack = function()
	    		effectFunc()
	    	end}}, {isPopCurrentDialog = false})
	else
		effectFunc()
	end

	app.sound:playSound("gem_drop")
end

function QUIWidgetHeroEquipmentEnchant:_displayMaxLevel(itemConfig, actorId, level)
	self._ccbOwner.incomplete:setVisible(false)
	self._ccbOwner.complete:setVisible(true)
	self._ccbOwner.btn_reset:setPositionY(20)
	self._ccbOwner.btn_reset:setVisible(true)

	self._ccbOwner.citem:removeAllChildren()
	local item = QUIWidgetEquipmentAvatar.new()
	item:setEquipmentInfo(itemConfig, actorId)
	self._ccbOwner.citem:addChild(item)

	self._ccbOwner.star_light_cnode:removeAllChildren()
	self._ccbOwner.bigStarC:removeAllChildren()
	local enchantStar = QUIWidgetEnchantStar.new({number = level})
	self._ccbOwner.star_light_cnode:addChild(enchantStar)

	-- Update attribute
	local enchantConfig = QStaticDatabase:sharedDatabase():getEnchant(itemConfig.id, level, actorId)
	local config = self:_getEnchantValue(enchantConfig)

	self._ccbOwner["tf_cname1"]:setVisible(level > 0)
	self._ccbOwner["tf_cvalue1"]:setVisible(level > 0)
	self._ccbOwner["tf_cname1"]:setString(config[1] and (config[1].description or "") or "")
	self._ccbOwner["tf_cvalue1"]:setString("+ " .. (config[1] and (config[1].value or 0) or 0))
	self._ccbOwner["tf_cname2"]:setVisible(#config > 1)
	self._ccbOwner["tf_cvalue2"]:setVisible(#config > 1)
	if #config > 1 then
		self._ccbOwner["tf_cname2"]:setString(config[2].description)
		self._ccbOwner["tf_cvalue2"]:setString("+ " .. config[2].value)
	end

	-- Update equipment name
    local breaklevel = remote.herosUtil:getHeroEquipmentEvolutionByID(actorId, itemConfig.id)
    local level, color = remote.herosUtil:getBreakThrough(breaklevel) 

    local name = itemConfig.name
    if level > 0 then
    	name = name .. "＋".. level
    end

	self._ccbOwner.cname:setString(name)
	local fontColor = BREAKTHROUGH_COLOR_LIGHT[color]
	self._ccbOwner.cname:setColor(fontColor)
	self._ccbOwner.cname = setShadowByFontColor(self._ccbOwner.cname, fontColor)

	self._onTriggerEnchantImp = function ()

	end
end

function QUIWidgetHeroEquipmentEnchant:setEquipmentPos(equipmentPos)
	self._equipmentPos = equipmentPos
end

function QUIWidgetHeroEquipmentEnchant:updateInfo()
	self:setInfo(self._actorId, self._itemId)
end

function QUIWidgetHeroEquipmentEnchant:_equipmentSelected(event)
	QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, event.itemID, event.needNum)
end

function QUIWidgetHeroEquipmentEnchant:_onTriggerEnchant(event)
	if q.buttonEventShadow(event, self._ccbOwner.enchant_btn) == false then return end
	self._onTriggerEnchantImp()
end

--todo
function QUIWidgetHeroEquipmentEnchant:_onTriggerInfo(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_info) == false then return end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogEnchantInfo", 
		options = {actorId = self._actorId, itemId = self._itemId, level = (self._enchant.enchants or 0)}}, {isPopCurrentDialog = false})
end

function QUIWidgetHeroEquipmentEnchant:_onTriggerReset(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_reset) == false then return end
	if remote.user.token < 30 then
		QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
	else
		app:alert({content = "##n花费##e30钻石##n，摘除这件装备上的##e所有觉醒材料##n？摘除后，返还##e全部觉醒材料##n。", title = "系统提示", 
	        callback = function(callType)
	        	if callType == ALERT_TYPE.CONFIRM then
	            	self:dispatchEvent({name = QUIWidgetHeroEquipmentEnchant.ENCHANT_RESET_EVENT, actorId = self._actorId, itemId = self._itemId})
	            end
	        end, isAnimation = true, colorful = true}, true, true)
	end
end

return QUIWidgetHeroEquipmentEnchant