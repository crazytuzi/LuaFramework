local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroGemstoneStrength = class("QUIWidgetHeroGemstoneStrength", QUIWidget)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetEquipmentAvatar = import("..widgets.QUIWidgetEquipmentAvatar")
local QUIViewController = import("..QUIViewController")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QQuickWay = import("...utils.QQuickWay")
local QUIHeroModel = import("...models.QUIHeroModel")
local QUIWidgetGemstoneEvolutionMaxLevel = import("..widgets.QUIWidgetGemstoneEvolutionMaxLevel")


function QUIWidgetHeroGemstoneStrength:ctor(options)
	local ccbFile = "ccb/Widget_Baoshi_Qianghua_2.ccbi"
	local callBacks = {
			{ccbCallbackName = "onTriggerClickTeamLevel", callback = handler(self, QUIWidgetHeroGemstoneStrength._onTriggerClickTeamLevel)},
			{ccbCallbackName = "onTriggerOneWearMax", callback = handler(self, QUIWidgetHeroGemstoneStrength._onTriggerOneWearMax)},
			{ccbCallbackName = "onTriggerStrengthenOne", callback = handler(self, QUIWidgetHeroGemstoneStrength._onTriggerStrengthenOne)},

		}
	QUIWidgetHeroGemstoneStrength.super.ctor(self,ccbFile,callBacks,options)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetHeroGemstoneStrength:onExit()
	QUIWidgetHeroGemstoneStrength.super.onExit(self)
	if self._strengthenScheduler ~= nil then
		scheduler.unscheduleGlobal(self._strengthenScheduler)
		self._strengthenScheduler = nil
	end
	if self._gemstoneSchedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._gemstoneSchedulerHandler)
		self._gemstoneSchedulerHandler = nil
	end	

	if self._masterDialog ~= nil then
		self._masterDialog:removeAllEventListeners()
		self._masterDialog = nil
	end
end

function QUIWidgetHeroGemstoneStrength:setTopAnimationNode(topNode)
	self._topNode = topNode
end

function QUIWidgetHeroGemstoneStrength:setParentDailog(baba)
	self._baba = baba
end

function QUIWidgetHeroGemstoneStrength:setInfo(actorId, gemstoneSid, gemstonePos)
	self._actorId = actorId
	self._gemstoneSid = gemstoneSid
	self._gemstonePos = gemstonePos

	local gemstone = remote.gemstone:getGemstoneById(self._gemstoneSid)
	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(gemstone.itemId)

	local maxLevel = QStaticDatabase:sharedDatabase():getConfiguration().EQUIPMENT_MAX_LEVEL.value
	if maxLevel <= gemstone.level then --已经突破到顶级了
		self._ccbOwner.client1_ItemBox:setVisible(false)
		self._ccbOwner.client2_info:setVisible(false)
		self._ccbOwner.client3_stengthen:setVisible(false)
		if self._maxWidget == nil then
			self._maxWidget = QUIWidgetGemstoneEvolutionMaxLevel.new()
			self:getView():addChild(self._maxWidget)
		end
		self._maxWidget:setInfo(actorId, gemstoneSid, gemstonePos, "TAB_STRONG")
		return
	end
	self._ccbOwner.client1_ItemBox:setVisible(true)
	self._ccbOwner.client2_info:setVisible(true)
	self._ccbOwner.client3_stengthen:setVisible(true)
	if self._maxWidget ~= nil then
		self._maxWidget:removeFromParent()
		self._maxWidget = nil
	end

    local level,color = remote.herosUtil:getBreakThrough(gemstone.craftLevel) 
    local name = itemConfig.name

    local advancedLevel = gemstone.godLevel or remote.gemstone.GEMSTONE_GODLEVLE_TEST
	local mixLevel = gemstone.mix_level or 0
	name = remote.gemstone:getGemstoneNameByData(name,advancedLevel,mixLevel)

    if level > 0 then
    	name = name .. "＋".. level
    end
	self._ccbOwner.tf_item_name:setString(name)

	local fontColor = BREAKTHROUGH_COLOR_LIGHT[color]
	self._ccbOwner.tf_item_name:setColor(fontColor)
	self._ccbOwner.tf_item_name = setShadowByFontColor(self._ccbOwner.tf_item_name, fontColor)
			
	self.maxStrengthenLevel = remote.herosUtil:getEquipmentStrengthenMaxLevel()
	self:strengthenInfoHandler()


	if self.maxStrengthenLevel > gemstone.level then
		self._count = self.maxStrengthenLevel - gemstone.level
		if self._count > 5 then
			self._count = 5 
		end
		self._needResouce = self:countNeedMoney(itemConfig.gemstone_quality, gemstone.level, gemstone.level + self._count)

		self._ccbOwner.strengthen_btn:setVisible(true)
		self._ccbOwner.tf_money:setString(self._needResouce.money)
		if self._needResouce.money > remote.user.money then
			self._ccbOwner.tf_money:setColor(UNITY_COLOR_LIGHT.red)
		else
			self._ccbOwner.tf_money:setColor(ccc3(61, 13, 0))
		end
		self._ccbOwner.tf_gem_engery:setString(self._needResouce.gemstoneEnergy)
		if self._needResouce.gemstoneEnergy > remote.user.gemstoneEnergy then
			self._ccbOwner.tf_gem_engery:setColor(UNITY_COLOR_LIGHT.red)
		else
			self._ccbOwner.tf_gem_engery:setColor(ccc3(61, 13, 0))
		end
		self._ccbOwner.strengthen_label:setString("强化"..self._count.."次")

		self._needResouceOne = self:countNeedMoney(itemConfig.gemstone_quality, gemstone.level, gemstone.level + 1)
		self._ccbOwner.strengthen_one_btn:setVisible(true)
		self._ccbOwner.tf_money_one:setString(self._needResouceOne.money)
		if self._needResouceOne.money > remote.user.money then
			self._ccbOwner.tf_money_one:setColor(UNITY_COLOR_LIGHT.red)
		else
			self._ccbOwner.tf_money_one:setColor(ccc3(61, 13, 0))
		end
		self._ccbOwner.tf_gem_engery_one:setString(self._needResouceOne.gemstoneEnergy)
		if self._needResouceOne.gemstoneEnergy > remote.user.gemstoneEnergy then
			self._ccbOwner.tf_gem_engery_one:setColor(UNITY_COLOR_LIGHT.red)
		else
			self._ccbOwner.tf_gem_engery_one:setColor(ccc3(61, 13, 0))
		end
		self._ccbOwner.strengthen_label_one:setString("强化1次")
	else
		self._ccbOwner.node_max:setVisible(true)
	end
end

function QUIWidgetHeroGemstoneStrength:strengthenInfoHandler()
	local gemstone = remote.gemstone:getGemstoneById(self._gemstoneSid)
	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(gemstone.itemId)
	self._ccbOwner.tf_strength_level:setString(gemstone.level.."/"..self.maxStrengthenLevel)

	local advancedLevel = gemstone.godLevel or remote.gemstone.GEMSTONE_GODLEVLE_TEST

	local itemAvatar = QUIWidgetEquipmentAvatar.new()
	self._ccbOwner.equ_node:addChild(itemAvatar)
	itemAvatar:setGemstonInfo(itemConfig, gemstone.craftLevel,1.0,advancedLevel, gemstone.mix_level)

	local oldConfig = QStaticDatabase:sharedDatabase():getTotalEnhancePropByLevel(itemConfig.enhance_data, gemstone.level)
	local equConfig = QStaticDatabase:sharedDatabase():getEnhanceDataByEquLevel(itemConfig.enhance_data, gemstone.level + 1)

	self._index = 1
	self:setTFValue("生    命：", "生命", math.floor(oldConfig.hp_value or 0), math.floor(equConfig.hp_value or 0), "hp_value")
	self:setTFValue("攻    击：", "攻击", math.floor(oldConfig.attack_value or 0), math.floor(equConfig.attack_value or 0), "attack_value")
	self:setTFValue("命    中：", "命中", math.floor(oldConfig.hit_rating or 0), math.floor(equConfig.hit_rating or 0), "hit_rating")
	self:setTFValue("闪    避：", "闪避", math.floor(oldConfig.dodge_rating or 0), math.floor(equConfig.dodge_rating or 0), "dodge_rating")
	self:setTFValue("暴    击：", "暴击", math.floor(oldConfig.critical_rating or 0), math.floor(equConfig.critical_rating or 0), "critical_rating")
	self:setTFValue("格    挡：", "格挡", math.floor(oldConfig.block_rating or 0), math.floor(equConfig.block_rating or 0), "block_rating")
	self:setTFValue("急    速：", "急速", math.floor(oldConfig.haste_rating or 0), math.floor(equConfig.haste_rating or 0), "haste_rating")
	self:setTFValue("物理防御：", "物理防御", math.floor(oldConfig.armor_physical or 0), math.floor(equConfig.armor_physical or 0), "armor_physical")
	self:setTFValue("法术防御：", "法术防御", math.floor(oldConfig.armor_magic or 0), math.floor(equConfig.armor_magic or 0), "armor_magic")
	self:setTFValue("生命增加：", "生命增加", oldConfig.hp_percent or 0, equConfig.hp_percent or 0, "hp_percent")
	self:setTFValue("攻击增加：", "攻击增加", oldConfig.attack_percent or 0, equConfig.attack_percent or 0, "attack_percent")
	self:setTFValue("物防增加", "物防增加", oldConfig.armor_physical_percent or 0, equConfig.armor_physical_percent or 0, "armor_physical_percent")
	self:setTFValue("法防增加", "法防增加", oldConfig.armor_magic_percent or 0, equConfig.armor_magic_percent or 0, "armor_magic_percent")

	self._ccbOwner.old_prop_title:setString(gemstone.level.."级属性")
	self._ccbOwner.new_prop_title:setString((gemstone.level+1).."级属性")
end

function QUIWidgetHeroGemstoneStrength:setTFValue(name, cname, oldValue, newValue, state)
	if self._index > 1 then return end
	if oldValue ~= nil then
		if type(oldValue) == "number" or oldValue > 0 then
			if newValue ~= 0 then
				self._cname = cname
				self._ccbOwner["name1"]:setString(name)
				self._ccbOwner["name2"]:setString(name)
				local value1 = oldValue
				local value2 = oldValue + newValue
				if oldValue ~= 0 and oldValue < 1 and newValue < 1 then
					value1 = (oldValue * 100).."%"
					value2 = ((oldValue + newValue) * 100).."%"
				end
				self._ccbOwner["old_prop"]:setString(" +"..value1)
				self._ccbOwner["new_prop"]:setString(" +"..value2)
				self._oldPropValue = value1
				self._oldValue = value1
				self._propState = state 
				self._index = self._index + 1
			end
		end
	end
end

function QUIWidgetHeroGemstoneStrength:countNeedMoney(gemstoneQuality, startLevel, maxLevel)
	local configs = QStaticDatabase:sharedDatabase():getGemstoneStrengthByQuality(gemstoneQuality)
	local needResouce = {money = 0, gemstoneEnergy = 0}
	for _,config in ipairs(configs) do
		if config.enhance_level > startLevel and config.enhance_level <= maxLevel then
			needResouce.money = needResouce.money + config.money
			needResouce.gemstoneEnergy = needResouce.gemstoneEnergy + config.strengthen_stone
		end
	end
	return needResouce
end

function QUIWidgetHeroGemstoneStrength:strengthenSucceed(critNum)
	if self._effectShow ~= nil then
		self._effectShow:removeFromParent()
		self._effectShow = nil
	end
	self._effectShow = QUIWidgetAnimationPlayer.new()
	
	self._ccbOwner.equ_node:addChild(self._effectShow)
	self._effectShow:playAnimation("ccb/effects/qianghua_effect_g.ccbi")
	app.sound:playSound("equipment_enhance")

	critNum = critNum or 0

	self:setLabelScale(self._ccbOwner.tf_strength_level, 1.2)
	self:setLabelScale(self._ccbOwner.old_prop, 1.2)
	self:setLabelScale(self._ccbOwner.new_prop, 1.2)

	local attributeInfo = {}
	local value = 0
	attributeInfo = {{name = self._propState, value =  value}}
	attributeInfo[1].name = self._cname or ""

	local gemstone = remote.gemstone:getGemstoneById(self._gemstoneSid)
	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(gemstone.itemId)
	local changeLevel = gemstone.level - self._oldLevel
	for i = self._oldLevel+1, gemstone.level do
		local equConfig1 = QStaticDatabase:sharedDatabase():getEnhanceDataByEquLevel(itemConfig.enhance_data, i)
		attributeInfo[1].value =  attributeInfo[1].value + (equConfig1[self._propState] or 0)
	end

	if self._strengthenEffectShow ~= nil then
		self._strengthenEffectShow:disappear()
		self._strengthenEffectShow = nil
	end
	self._topNode:removeAllChildren()
	if critNum > 0 then
		self._strengthenEffectShow = QUIWidgetAnimationPlayer.new()
		self._topNode:addChild(self._strengthenEffectShow)
		self._strengthenEffectShow:setPosition(ccp(0, 100))
		self._strengthenEffectShow:playAnimation("ccb/effects/Baoji.ccbi", function(ccbOwner)
			ccbOwner.level:setVisible(false)
			ccbOwner.tf_name1:setString("连续强化"..(changeLevel).."次 （暴击 "..critNum.." 次）")
			if attributeInfo[1] ~= nil then
				local value = attributeInfo[1].value
				if value < 1 then
					value = value.."%"
				end
				self._strengthValue = value
				self._strengthenEffectShow._ccbOwner["tf_name"..2]:setString(attributeInfo[1].name .. "＋" .. value)
			else
				self._strengthenEffectShow._ccbOwner["node_"..2]:setVisible(false)
			end
		end, function()
			if self._strengthenEffectShow ~= nil then
				self._strengthenEffectShow:disappear()
				self._strengthenEffectShow = nil
			end
		end)
	else
		local ccbFile = "ccb/effects/StrenghtSccess.ccbi"
		if changeLevel > 1 then
			ccbFile = "ccb/effects/StrenghtSccessBaoji.ccbi"
		end
		self._strengthenEffectShow = QUIWidgetAnimationPlayer.new()
		self._topNode:addChild(self._strengthenEffectShow)
		self._strengthenEffectShow:setPosition(ccp(0, 100))
		self._strengthenEffectShow:playAnimation(ccbFile, function()
				if changeLevel > 1 then
					self._strengthenEffectShow._ccbOwner["level"]:setString(changeLevel)
					self._strengthenEffectShow._ccbOwner["crit_num"]:setString(critNum or 0)
					if critNum == 0 then
						self._strengthenEffectShow._ccbOwner.node_baoji:setVisible(false)
						self._strengthenEffectShow._ccbOwner["node_"..1]:setPositionY(-49)
						self._strengthenEffectShow._ccbOwner["node_"..2]:setPositionY(-117)
					end
				else
					if critNum == 0 then
						self._strengthenEffectShow._ccbOwner.title_enchant:setVisible(false)
						self._strengthenEffectShow._ccbOwner.title_skill:setVisible(false)
					end
				end
				for i = 1, 2, 1 do
					if attributeInfo[i] ~= nil then
						local value = attributeInfo[i].value
						if value < 1 then
							value = value.."%"
						end
						self._strengthValue = value
						self._strengthenEffectShow._ccbOwner["tf_name"..i]:setString(attributeInfo[i].name .. "  ＋" .. value)
					else
						self._strengthenEffectShow._ccbOwner["node_"..i]:setVisible(false)
					end
				end
			end, function()
				if self._strengthenEffectShow ~= nil then
					self._strengthenEffectShow:disappear()
					self._strengthenEffectShow = nil
				end
			end)	
	end
	local newStrengthMaster = remote.herosUtil:getUIHeroByID(self._actorId):getMasterLevelByType(QUIHeroModel.GEMSTONE_MASTER)
	if newStrengthMaster > self._oldStrengthMaster then
		self._baba:enableTouchSwallowTop()
		self._gemstoneSchedulerHandler = scheduler.performWithDelayGlobal(function()
			self._baba:disableTouchSwallowTop()
			self._masterDialog = app.master:upGradeGemstoneMaster(self._oldStrengthMaster, newStrengthMaster, QUIHeroModel.GEMSTONE_MASTER, self._actorId)
			if self._masterDialog then
				self._masterDialog:addEventListener(self._masterDialog.EVENT_CLOSE, function (e)
						self._masterDialog:removeAllEventListeners()
						self._masterDialog = nil
						remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
					end)
			else
				remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
			end
		end,0.3)
  	else
		remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
	end
end

function QUIWidgetHeroGemstoneStrength:setLabelScale(node, scale)
	local ccArray = CCArray:create()
	ccArray:addObject(CCScaleTo:create(0.1, 1.2))
	ccArray:addObject(CCScaleTo:create(0.1, 1))
	node:runAction(CCSequence:create(ccArray))
end

function QUIWidgetHeroGemstoneStrength:resetAll()
	self._ccbOwner.tf_item_name:setString("")
	self._ccbOwner.tf_strength_level:setString("")
	self._ccbOwner.equ_node:removeAllChildren()
	self._effectShow = nil
	self._ccbOwner.strengthen_btn:setVisible(false)
	self._ccbOwner.strengthen_one_btn:setVisible(false)
	self._ccbOwner.node_max:setVisible(false)
end

function QUIWidgetHeroGemstoneStrength:_onTriggerClickBreakthough()
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogInstance", options = {isQuickWay = true}})
end

function QUIWidgetHeroGemstoneStrength:requestStrengthen(resouce, count)
	if resouce.money > remote.user.money then
    	QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.MONEY)
		return
	end
	if resouce.gemstoneEnergy > remote.user.gemstoneEnergy then
    	QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.GEMSTONE_ENERGY)
		return
	end
	local gemstone = remote.gemstone:getGemstoneById(self._gemstoneSid)
	self._oldLevel = gemstone.level
	self._oldStrengthMaster = remote.herosUtil:getUIHeroByID(self._actorId):getMasterLevelByType(QUIHeroModel.GEMSTONE_MASTER)
	remote.gemstone:gemstoneEnhanceRequest(gemstone.sid, gemstone.level+count, function (data)
		if self:safeCheck() then
			local critNum = data.enhanceEquipmentCritCount or 0
			self:strengthenSucceed(critNum)
		end
	end)
end

function QUIWidgetHeroGemstoneStrength:_onTriggerOneWearMax(e)
	if q.buttonEventShadow(e, self._ccbOwner.stengthen_equ) == false then return end
	self:requestStrengthen(self._needResouce, self._count)
end

function QUIWidgetHeroGemstoneStrength:_onTriggerStrengthenOne(e)
	if q.buttonEventShadow(e, self._ccbOwner.stengthen_equ_one) == false then return end
	self:requestStrengthen(self._needResouceOne, 1)
end

function QUIWidgetHeroGemstoneStrength:_onTriggerClickTeamLevel()
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogInstance", options = {isQuickWay = true}})
end

return QUIWidgetHeroGemstoneStrength