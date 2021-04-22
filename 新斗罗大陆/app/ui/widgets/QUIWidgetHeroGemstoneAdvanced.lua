-- @Author: vicentboo
-- @Date:   2019-09-05 16:20:54
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-11-12 10:37:28
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroGemstoneAdvanced = class("QUIWidgetHeroGemstoneAdvanced", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
-- local QUIWidgetQualitySmall = import("..widgets.QUIWidgetQualitySmall")
local QUIWidgetEquipmentAvatar = import("..widgets.QUIWidgetEquipmentAvatar")
-- local QUIWidgetGemstonesBox = import("..widgets.QUIWidgetGemstonesBox")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QQuickWay = import("...utils.QQuickWay")

function QUIWidgetHeroGemstoneAdvanced:ctor(options)
	local ccbFile = "ccb/Widget_HeroGemstone_Advanced.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerAdvanced", callback = handler(self, self._onTriggerAdvanced)},
		{ccbCallbackName = "onTriggerSkillInfo", callback = handler(self, self._onTriggerSkillInfo)},
		{ccbCallbackName = "onTriggerSelectedOnekey", callback = handler(self, self._onTriggerSelectedOnekey)},
    }
    QUIWidgetHeroGemstoneAdvanced.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self._isAnimation = false

	self._nameMaxSize = 110

	self._haveNum1 = 0
	self._haveNum2 = 0
	self._costNum1 = 0
	self._costNum2 = 0
	self._costItemid1 = nil
	self._costItemid2 = nil
	self:hideAllDizuo()

	self._isOnekeyPlaying = false
	self._isUpdateParentView = false
	self._isSelected = false
	self:_showSelectState()
end

function QUIWidgetHeroGemstoneAdvanced:hideAllDizuo( )
	for ii=0,4 do
		self._ccbOwner["level_"..ii]:setVisible(false)
	end
end

function QUIWidgetHeroGemstoneAdvanced:isOnekeyPlaying()
	return self._isOnekeyPlaying
end

function QUIWidgetHeroGemstoneAdvanced:isUpdateParentView()
	return self._isUpdateParentView
end


function QUIWidgetHeroGemstoneAdvanced:setInfo(actorId, gemstoneSid, gemstonePos)
	self._actorId = actorId
	self._gemstoneSid = gemstoneSid
	self._gemstonePos = gemstonePos
	local gemstone = remote.gemstone:getGemstoneById(self._gemstoneSid)
	self._gemstone = gemstone
	local itemConfig = db:getItemByID(gemstone.itemId)
    local level,color = remote.herosUtil:getBreakThrough(gemstone.craftLevel) 

    self._advancedLevel = gemstone.godLevel or remote.gemstone.GEMSTONE_GODLEVLE_TEST
    local mixLevel = gemstone.mix_level or 0
    if mixLevel <= 0 then
    	self._ccbOwner.tf_advanced_des:setString("S魂骨进阶到V阶后变为SS魂骨")
	else
    	self._ccbOwner.tf_advanced_des:setString("SS+魂骨进阶到V阶后开启化神")
	end

    local name = itemConfig.name
	name = remote.gemstone:getGemstoneNameByData(name,self._advancedLevel,mixLevel)
    
    if level > 0 then
    	name = name .. "＋".. level
    end
	local typeStr = ""
    if mixLevel <= 0 then
    	typeStr = " 【"..remote.gemstone:getTypeDesc(itemConfig.gemstone_type).."】"
    end  	

	self._ccbOwner.tf_item_name:setString("LV."..gemstone.level.."  "..name..typeStr)

	local fontColor = BREAKTHROUGH_COLOR_LIGHT[color]
	self._ccbOwner.tf_item_name:setColor(fontColor)
	self._ccbOwner.tf_item_name = setShadowByFontColor(self._ccbOwner.tf_item_name, fontColor)
	
	if self._itemAvatar == nil then
		self._itemAvatar = QUIWidgetEquipmentAvatar.new()
		self._ccbOwner.node_gemstone:addChild(self._itemAvatar)
	end

	self._itemAvatar:setGemstonInfo(itemConfig, gemstone.craftLevel, 1.0,self._advancedLevel, gemstone.mix_level)
	self._itemAvatar:hideAllColor()

	self:_updateGoalInfo()
end

function QUIWidgetHeroGemstoneAdvanced:showCurrentStep()
	local advancedLevel = self._advancedLevel
	local gemstone = remote.gemstone:getGemstoneById(self._gemstoneSid)
	local oldLevelInfo = db:getGemstoneEvolutionBygodLevel(gemstone.itemId,advancedLevel)
    local nextLevelInfo = db:getGemstoneEvolutionBygodLevel(gemstone.itemId,advancedLevel + self._addLevel)

    local oldPropVlue = remote.gemstone:getAllAdvancedProp(gemstone.itemId, 1, advancedLevel)
	if nextLevelInfo and next(nextLevelInfo) ~= nil then
		local newadvanced , nextLevel = remote.gemstone:getGemsonesAdvanced(advancedLevel + self._addLevel)
		self._ccbOwner.new_prop_title:setVisible(true)
		self._ccbOwner.new_prop_title:setString("【"..q.getRomanNumberalsByInt(newadvanced).."阶"..nextLevel.."级属性".."】")

		local prePropVlue = remote.gemstone:getAllAdvancedProp(gemstone.itemId, 1, advancedLevel + self._addLevel - 1)
		self:setNewProp(prePropVlue.attack_value ,nextLevelInfo.attack_value , "攻    击：","＋%d")
		self:setNewProp(prePropVlue.hp_value , nextLevelInfo.hp_value , "生    命：","＋%d")
		self:setNewProp(prePropVlue.armor_physical , nextLevelInfo.armor_physical , "物    防：","＋%d")
		self:setNewProp(prePropVlue.armor_magic , nextLevelInfo.armor_magic , "法    防：","＋%d")

		if self._itemEffectTexture ~= nil then
			self._itemEffectTexture:release()
			self._itemEffectTexture = nil
		end

		if self._addLevel > 1 then
			local nextConfigList = remote.gemstone:getNextConfigListByGoalLevel(gemstone.itemId, advancedLevel, advancedLevel + self._addLevel)
			if not q.isEmpty(nextConfigList) then
				self._costNum1 = 0
				self._costItemid1 = 0
				self._haveNum1 = 0

				self._costNum2 = 0
				self._costItemid2 = 0
				self._haveNum2 = 0
				for _, config in ipairs(nextConfigList) do
					if config.evolution_consume_type_1 then
						self._costNum1 =  self._costNum1 + tonumber(config.evolution_consume_1)
						if self._costItemid1 == 0 then
							self._costItemid1 = config.evolution_consume_type_1
						end
					end

					if config.evolution_consume_type_2 then
						self._costNum2 = self._costNum2 + tonumber(config.evolution_consume_2)
						if self._costItemid2 == 0 then
							self._costItemid2 = config.evolution_consume_type_2
						end
					end

				end

				if self._costItemid1 ~= 0 then
					self._haveNum1 = remote.items:getItemsNumByID(self._costItemid1)
					self._ccbOwner.tf_money_1:setString(self._haveNum1.."/"..(self._costNum1 or 0))
					local costItemInfo1 = db:getItemByID(self._costItemid1)
					if costItemInfo1 and costItemInfo1.icon_1 then
						QSetDisplaySpriteByPath(self._ccbOwner.icon_money_1,costItemInfo1.icon_1)
						self._itemEffectTexture = CCTextureCache:sharedTextureCache():addImage(costItemInfo1.icon_1)
						self._itemEffectTexture:retain()			
					end

					if self._haveNum1 < (self._costNum1 or 0) then
						self._ccbOwner.tf_money_1:setColor(COLORS.m)
					else
						self._ccbOwner.tf_money_1:setColor(COLORS.k)
					end
				end

				if self._costItemid2 ~= 0 then
					self._ccbOwner.node_type_money2:setVisible(true)
					self._haveNum2 = remote.items:getItemsNumByID(self._costItemid2)
					self._ccbOwner.tf_money_2:setString(self._haveNum2.."/"..(self._costNum2 or 0))
					local costItemInfo2 = db:getItemByID(self._costItemid2)
					if costItemInfo2 and costItemInfo2.icon_1 then
						QSetDisplaySpriteByPath(self._ccbOwner.icon_money_2,costItemInfo2.icon_1)		
					end	
					if self._haveNum2 < (self._costNum2 or 0) then
						self._ccbOwner.tf_money_2:setColor(COLORS.m)
					else
						self._ccbOwner.tf_money_2:setColor(COLORS.k)
					end
				else
					self._ccbOwner.node_type_money2:setVisible(false)
				end
			end
		else
			if nextLevelInfo.evolution_consume_type_1 then
				self._costNum1 = tonumber(nextLevelInfo.evolution_consume_1)
				self._costItemid1 = nextLevelInfo.evolution_consume_type_1
				self._haveNum1 = remote.items:getItemsNumByID(self._costItemid1)
				self._ccbOwner.tf_money_1:setString(self._haveNum1.."/"..(self._costNum1 or 0))

				local costItemInfo1 = db:getItemByID(self._costItemid1)
			
				if costItemInfo1 and costItemInfo1.icon_1 then
					QSetDisplaySpriteByPath(self._ccbOwner.icon_money_1,costItemInfo1.icon_1)
					self._itemEffectTexture = CCTextureCache:sharedTextureCache():addImage(costItemInfo1.icon_1)
					self._itemEffectTexture:retain()			
				end
			end

			if nextLevelInfo.evolution_consume_type_2 then
				self._ccbOwner.node_type_money2:setVisible(true)

				self._costNum2 = tonumber(nextLevelInfo.evolution_consume_2)
				self._costItemid2 = nextLevelInfo.evolution_consume_type_2
				self._haveNum2 = remote.items:getItemsNumByID(self._costItemid2)
				self._ccbOwner.tf_money_2:setString(self._haveNum2.."/"..(self._costNum2 or 0))

				local costItemInfo2 = db:getItemByID(self._costItemid2)
			
				if costItemInfo2 and costItemInfo2.icon_1 then
					QSetDisplaySpriteByPath(self._ccbOwner.icon_money_2,costItemInfo2.icon_1)		
				end	
			else
				self._costNum2 = 0
				self._ccbOwner.node_type_money2:setVisible(false)		
			end
		end
	else
		self._ccbOwner.new_prop_title:setString("已进阶到顶级")
	end

	if advancedLevel > 0 and oldLevelInfo and next(oldLevelInfo) ~= nil then
		local advanced,level = remote.gemstone:getGemsonesAdvanced(advancedLevel)
		self._ccbOwner.old_prop_title:setVisible(true)

		self._ccbOwner.old_prop_title:setString("【"..q.getRomanNumberalsByInt(advanced).."阶"..level.."级属性".."】")
		self:showAdvanced(advanced,level)
		self._ccbOwner.tf_value1:setString(q.getRomanNumberalsByInt(advanced).."阶"..level.."级")

		self:setOldProp(oldPropVlue.attack_value , "攻    击：","＋%d")
		self:setOldProp(oldPropVlue.hp_value , "生    命：","＋%d")
		self:setOldProp(oldPropVlue.armor_physical , "物    防：","＋%d")
		self:setOldProp(oldPropVlue.armor_magic, "法    防：","＋%d")

		local advancedSkillId, godSkillId = db:getGemstoneEvolutionSkillIdBygodLevel(gemstone.itemId,advancedLevel)

		if advancedSkillId then
			local skillInfo = db:getSkillByID(advancedSkillId)
			self._ccbOwner.tf_skillname:setString(skillInfo.name)
		else
			self._ccbOwner.tf_skillname:setString("无")
		end
	else

		self._ccbOwner.tf_value1:setString("0阶1级")
		self._ccbOwner.old_prop_title:setString("【0阶1级】")
		self._ccbOwner["old_name1"]:setString("无")
		self._ccbOwner["old_prop1"]:setString("")
		self._ccbOwner.tf_skillname:setString("无")
		self:showAdvanced(0,1)
	end
end

function QUIWidgetHeroGemstoneAdvanced:addAndvandStoneWidget(node,path,isActivity)
	if node == nil or path == nil then return end
	node:removeAllChildren()
	local proxy = CCBProxy:create()
	local ccbOwner = {}
    local ccbView = CCBuilderReaderLoad(path, proxy, ccbOwner)
    node:addChild(ccbView)

	local animationManager = tolua.cast(ccbView:getUserObject(), "CCBAnimationManager")

	if isActivity then
		animationManager:runAnimationsForSequenceNamed("open")
	else
		animationManager:runAnimationsForSequenceNamed("stand")
	end
end

function QUIWidgetHeroGemstoneAdvanced:showAdvanced( advancedlevel, level )
    local showInfo  = db:getGemstoneEvolutionBygodLevel(self._gemstone.itemId,1)
    local ccbfile = "ccb/effects/hg_gemstone_orange.ccbi"
    if showInfo and showInfo.show_animation then
    	ccbfile = "ccb/effects/"..showInfo.show_animation
    end
	for ii = 1, 5 do
		local isActivity = false
		if ii == level then
			isActivity = true
		end
		self:addAndvandStoneWidget(self._ccbOwner["node_step"..ii], ccbfile, isActivity)
		self._ccbOwner["tf_advanced"..ii]:setString(ii)
		makeNodeFromNormalToGray(self._ccbOwner["node_step"..ii])
	end
	self.showLevelAnimation = level
	if level > 0 then
		for ii=1,5 do
			self._ccbOwner["tf_advanced"..ii]:setString(ii)
			if ii > level then
				makeNodeFromNormalToGray(self._ccbOwner["node_step"..ii])
			else
				makeNodeFromGrayToNormal(self._ccbOwner["node_step"..ii])
			end
		end
	else
		for ii = 1, 5 do
			self._ccbOwner["tf_advanced"..ii]:setString(ii)
			makeNodeFromNormalToGray(self._ccbOwner["node_step"..ii])
		end
	end

	if level == 5 then
		self._ccbOwner.tf_button_name:setString("升 阶")
		if self._haveNum1 >= self._costNum1 and self._haveNum2 >= self._costNum2 then
			self._ccbOwner.node_btn_effect:setVisible(true)
		else
			self._ccbOwner.node_btn_effect:setVisible(false)
		end
	else
		self._ccbOwner.node_btn_effect:setVisible(false)
		self._ccbOwner.tf_button_name:setString("进 阶")
	end

	for ii=0,4 do
		self._ccbOwner["level_"..ii]:setVisible(false)
	end
	self._ccbOwner["level_"..advancedlevel]:setVisible(true)

	for jj = 1, 5 do
		local node = self._ccbOwner["level_"..advancedlevel.."_"..jj]
		if node then
			if jj <= level then
				node:setVisible(true)
			else
				node:setVisible(false)
			end
		end
	end

end

function QUIWidgetHeroGemstoneAdvanced:setOldProp(prop1,value,value1,ispercent)
	local prop = (prop1 or 0) 
	if prop ~= nil and prop > 0 then
		if ispercent == true then
			prop = prop * 100
		end
		self._ccbOwner["old_name1"]:setString(value)
		self._ccbOwner["old_name1"]:setVisible(true)
		self._ccbOwner["old_prop1"]:setString(string.format(value1, prop))
		self._ccbOwner["old_prop1"]:setVisible(true)
	end

	local nameWidth = self._ccbOwner.old_prop1:getContentSize().width
	self._ccbOwner.old_prop1:setScale(1)
	if nameWidth > self._nameMaxSize then
		self._ccbOwner.old_prop1:setScale(1-(nameWidth - self._nameMaxSize)/self._nameMaxSize)
	end
end

function QUIWidgetHeroGemstoneAdvanced:setNewProp(oldprop, prop1,value,value1,ispercent)

	local prop = (oldprop or 0) + (prop1 or 0)

	if prop ~= nil and prop > 0 then
		if ispercent == true then
			prop = prop * 100
		end
		self._ccbOwner["new_name1"]:setString(value)
		self._ccbOwner["new_name1"]:setVisible(true)
		self._ccbOwner["new_prop1"]:setString(string.format(value1, prop))
		self._ccbOwner["new_prop1"]:setVisible(true)
	end

	local nameWidth = self._ccbOwner.new_prop1:getContentSize().width
	self._ccbOwner.new_prop1:setScale(1)
	if nameWidth > self._nameMaxSize then
		self._ccbOwner.new_prop1:setScale(1-(nameWidth - self._nameMaxSize)/self._nameMaxSize)
	end
end

function QUIWidgetHeroGemstoneAdvanced:_showEffect(callBack)
	local effectFun1 = function ()
		if self._isEnter == nil or self._isEnter == false then return end
    	local effect = QUIWidgetAnimationPlayer.new()
    	effect:setPosition(ccp(-135,85))
    	self._ccbOwner.node_gemstoneinfo:addChild(effect)
    	effect:playAnimation("ccb/effects/UseItem2.ccbi", nil, function()
                effect:removeFromParentAndCleanup(true)
				if self._isEnter == nil or self._isEnter == false then return end
                if callBack ~= nil then 
					makeNodeFromGrayToNormal(self._ccbOwner.button_stengthen)
					self._ccbOwner.tf_button_name:enableOutline()
					self._ccbOwner.btn_advanced:setEnabled(true)                	
                	callBack() 
                	self._isAnimation = false
                end
            end)
	end
	local effectFun2 = function ()
		self._effectScheduler2 = nil
		if self._isEnter == nil or self._isEnter == false then return end
		local icon = CCSprite:create()
		icon:setTexture(self._itemEffectTexture)
		-- local p = ccp(self._ccbOwner.icon_money:getPosition())
		icon:setPosition(ccp(118,-246))
		self._ccbOwner.node_gemstoneinfo:addChild(icon)
		local arr = CCArray:create()
		arr:addObject(CCMoveTo:create(0.1, ccp(-135,85)))
		arr:addObject(CCCallFunc:create(function()
				icon:removeFromParentAndCleanup(true)
				effectFun1()
			end))
		local seq = CCSequence:create(arr)
		icon:runAction(seq)
	end
	local effectFun3 = function ()
		if self._isEnter == nil or self._isEnter == false then return end
		local effect = QUIWidgetAnimationPlayer.new()
		-- local p = ccp(self._ccbOwner.icon_money:getPosition())
    	effect:setPosition(ccp(118,-246))
    	self._ccbOwner.node_gemstoneinfo:addChild(effect)
    	effect:playAnimation("ccb/effects/UseItem.ccbi", function(ccbOwner)
    			ccbOwner.node_icon:setTexture(self._itemEffectTexture)
    		end, function()
                effect:removeFromParentAndCleanup(true)
                effectFun2()
            end)
	end
	makeNodeFromNormalToGray(self._ccbOwner.button_stengthen)
	self._ccbOwner.tf_button_name:disableOutline()
	self._ccbOwner.btn_advanced:setEnabled(false)
	effectFun3()
	-- self._effectScheduler2 = scheduler.performWithDelayGlobal(effectFun2, 0.2)
end

function QUIWidgetHeroGemstoneAdvanced:isAnimation()
	return self._isAnimation
end

function QUIWidgetHeroGemstoneAdvanced:onEnter()
	self._isEnter = true
end

function QUIWidgetHeroGemstoneAdvanced:onExit()
	self._isEnter = false

	if self._effectScheduler2 ~= nil then
		scheduler.unscheduleGlobal(self._effectScheduler2)
		self._effectScheduler2 = nil
	end
	if self._itemEffectTexture ~= nil then
		self._itemEffectTexture:release()
		self._itemEffectTexture = nil
	end	

	if self._oneKeyScheduler then
		scheduler.unscheduleGlobal(self._oneKeyScheduler)
		self._oneKeyScheduler = nil
	end
end

function QUIWidgetHeroGemstoneAdvanced:_showSelectState()
    self._ccbOwner.btn_select_onekey:setHighlighted(not self._isSelected)
end

function QUIWidgetHeroGemstoneAdvanced:_onTriggerSelectedOnekey(event)
	if self._isAnimation then return end
	if self._isOnekeyPlaying then return end

	self._isSelected = not self._isSelected
    self:_showSelectState()
    self:_updateGoalInfo()
end

function QUIWidgetHeroGemstoneAdvanced:_updateGoalInfo()
	if not self._isSelected then
		self._addLevel = 1
	else
		local advancedLevel = self._advancedLevel or 0
		local goalLevel = (math.floor(advancedLevel / 5) + 1) * 5
		if goalLevel > GEMSTONE_MAXADVANCED_LEVEL then
			goalLevel = GEMSTONE_MAXADVANCED_LEVEL
		end
		self._addLevel = goalLevel - advancedLevel
	end

	self:showCurrentStep()
end

function QUIWidgetHeroGemstoneAdvanced:_onTriggerAdvanced(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_advanced) == false then return end
	app.sound:playSound("common_menu")
	if self._isAnimation then return end
	if self._isOnekeyPlaying then return end
	local gemstone = remote.gemstone:getGemstoneById(self._gemstoneSid)
   	if self._advancedLevel < (gemstone.godLevel or remote.gemstone.GEMSTONE_GODLEVLE_TEST) then
   		-- app.tip:floatTip("【内部提示】你点的太快了")
   		-- print("【内部提示】你点的太快了")
   		return
   	end

	if self._haveNum1 < self._costNum1 then
		QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, self._costItemid1, nil, nil, false)
		return
	end

	if self._haveNum2 < self._costNum2 then
		QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, self._costItemid2, nil, nil, false)
		return		
	end

	local goalLevel = 1
	if self._isSelected then
		goalLevel = (self._advancedLevel or 0) + (self._addLevel or 1)
	else
		goalLevel = nil
	end
	self._oldLevel = self._advancedLevel
	self._addOldLevel = 1
	if self._addLevel and self._addLevel > 1 then
		self._isOnekeyPlaying = true
	end
	self._isUpdateParentView = false
	remote.gemstone:gemstoneToGodAndAdvanced(self._gemstoneSid, goalLevel, function(data)
		self._isAnimation = true
		if not self._isOnekeyPlaying then
			local effectName = "effects/hg_upgrade_1.ccbi"
	      	local effectccb = QUIWidgetAnimationPlayer.new()
	      	if self.showLevelAnimation == 0 then
	      		self.showLevelAnimation = 1
	      	end
	      	self._ccbOwner["node_step"..self.showLevelAnimation]:addChild(effectccb)
	      	effectccb:playAnimation(effectName,nil,function()
	      		effectccb:disappear()
	      	end)
      	end

      	if self._addOldLevel and self._addLevel and self._addOldLevel >= self._addLevel then
	      	local gemstone = remote.gemstone:getGemstoneById(self._gemstoneSid)
	      	local advanced, level = remote.gemstone:getGemsonesAdvanced(gemstone.godLevel)
	      	if level == 1 then
	      		self._ccbOwner.node_bigAnimation:removeAllChildren()
				local effectName = "effects/hg_upgrade_2.ccbi"
		      	local bigeffectccb = QUIWidgetAnimationPlayer.new()
		      	bigeffectccb:setPosition(ccp(0,12))
		      	self._ccbOwner.node_bigAnimation:addChild(bigeffectccb)
		      	bigeffectccb:playAnimation(effectName,nil,function()
		      		bigeffectccb:disappear()
		      	end)
	      	end
	    end

      	self:_showEffect(function()
      		if self._ccbView then
  				self:_showOneKeyEffect(function()
  					if self._ccbView then
      					if self._addLevel and self._addLevel > 1 then
							remote.gemstone:dispatchEvent({name = remote.gemstone.EVENT_ADVANCED, sid = self._gemstoneSid, actorId = self._actorId, oldLevel = self._oldLevel})
						else
							remote.gemstone:dispatchEvent({name = remote.gemstone.EVENT_ADVANCED, sid = self._gemstoneSid, actorId = self._actorId})
						end
					end
  				end)
			end
      	end)
	end,nil)
end

function QUIWidgetHeroGemstoneAdvanced:_showOneKeyEffect(callback)
	if not self._isOnekeyPlaying then 
		if self._oneKeyScheduler then
			scheduler.unscheduleGlobal(self._oneKeyScheduler)
			self._oneKeyScheduler = nil
		end
		return 
	end
	
	if self._oldLevel and self._addLevel and self._addLevel > 1 then
		if self._oneKeyScheduler then
			scheduler.unscheduleGlobal(self._oneKeyScheduler)
			self._oneKeyScheduler = nil
		end

		local curLevel = self._oldLevel + self._addOldLevel
		if curLevel >= remote.gemstone.GEMSTONE_TOGOD_LEVEL then
			self._isOnekeyPlaying = false
			self._isUpdateParentView = true
			if callback then
				callback()
			end
			return
		end
		local advanced, level = remote.gemstone:getGemsonesAdvanced(curLevel)
		if level == 1 then
      		self._ccbOwner.node_bigAnimation:removeAllChildren()
			local effectName = "effects/hg_upgrade_2.ccbi"
	      	local bigeffectccb = QUIWidgetAnimationPlayer.new()
	      	bigeffectccb:setPosition(ccp(0,12))
	      	self._ccbOwner.node_bigAnimation:addChild(bigeffectccb)
	      	bigeffectccb:playAnimation(effectName,nil,function()
	      		bigeffectccb:disappear()
	      		if self._ccbView then
		      		self:showAdvanced(advanced, 1)
					self._addOldLevel = self._addOldLevel + 1
				end
	      	end)
      	else
	      	self:showAdvanced(advanced, level)
			self._addOldLevel = self._addOldLevel + 1
      	end
	
		self._oneKeyScheduler = scheduler.scheduleGlobal(function()
				local curLevel = self._oldLevel + self._addOldLevel
				if self._addOldLevel > self._addLevel or curLevel >= remote.gemstone.GEMSTONE_TOGOD_LEVEL then
					if self._oneKeyScheduler then
						scheduler.unscheduleGlobal(self._oneKeyScheduler)
						self._oneKeyScheduler = nil
					end
					self._isOnekeyPlaying = false
					self._isUpdateParentView = true
					if callback then
						callback()
					end
					return
				end
				
				local advanced, level = remote.gemstone:getGemsonesAdvanced(curLevel)
				if level == 1 then
		      		self._ccbOwner.node_bigAnimation:removeAllChildren()
					local effectName = "effects/hg_upgrade_2.ccbi"
			      	local bigeffectccb = QUIWidgetAnimationPlayer.new()
			      	bigeffectccb:setPosition(ccp(0,12))
			      	self._ccbOwner.node_bigAnimation:addChild(bigeffectccb)
			      	if self._oneKeyScheduler then
						scheduler.unscheduleGlobal(self._oneKeyScheduler)
						self._oneKeyScheduler = nil
					end
			      	bigeffectccb:playAnimation(effectName,nil,function()
			      		bigeffectccb:disappear()
			      		if self._ccbView then
				      		self:showAdvanced(advanced, 1)
							self._isOnekeyPlaying = false
							self._isUpdateParentView = true
							if callback then
								callback()
							end
						end
			      	end)
			    else
			      	self:showAdvanced(advanced, level)
					self._addOldLevel = self._addOldLevel + 1
		      	end
			end, 0.2)
	else
		self._isOnekeyPlaying = false
		self._isUpdateParentView = true
		if callback then 
			callback()
		end
	end
end

function QUIWidgetHeroGemstoneAdvanced:_onTriggerSkillInfo(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_check) == false then return end
    app.sound:playSound("common_menu")
    if self._isOnekeyPlaying then return end

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGemstoneSkillInfo", 
        options={gemstone = self._gemstone}}, {isPopCurrentDialog = false})
end

function QUIWidgetHeroGemstoneAdvanced:getContentSize()
end

return QUIWidgetHeroGemstoneAdvanced
