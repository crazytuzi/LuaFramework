--
-- zxs
-- 武魂真身强化升级页签
--

local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetArtifactInfoLevel = class("QUIWidgetArtifactInfoLevel", QUIWidget)
local QStaticDatabase = import("....controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("...widgets.QUIWidgetItemsBox")
local QUIWidgetAnimationPlayer = import("...widgets.QUIWidgetAnimationPlayer")
local QQuickWay = import("....utils.QQuickWay")
local QUIViewController = import("...QUIViewController")
local QUIWidgetArtifactBox = import("...widgets.artifact.QUIWidgetArtifactBox")
local QUIWidgetActorDisplay = import("..actorDisplay.QUIWidgetActorDisplay")
local QActorProp = import("....models.QActorProp")
local QUIWidgetFcaAnimation = import("..actorDisplay.QUIWidgetFcaAnimation")

function QUIWidgetArtifactInfoLevel:ctor(options)
	local ccbFile = "ccb/Widget_artifact_qianghua.ccbi"
	local callBacks = {
			{ccbCallbackName = "onTriggerClickItem1", callback = handler(self, self._onTriggerClickItem1)},
			{ccbCallbackName = "onTriggerClickItem2", callback = handler(self, self._onTriggerClickItem2)},
			{ccbCallbackName = "onTriggerClickItem3", callback = handler(self, self._onTriggerClickItem3)},
			{ccbCallbackName = "onTriggerClickLink", callback = handler(self, self._onTriggerClickLink)},
			{ccbCallbackName = "onTriggerUpgrade1", callback = handler(self, self._onTriggerUpgrade1)},
			{ccbCallbackName = "onTriggerUpgrade5", callback = handler(self, self._onTriggerUpgrade5)},
		}
	QUIWidgetArtifactInfoLevel.super.ctor(self,ccbFile,callBacks,options)

	q.setButtonEnableShadow(self._ccbOwner.btn_upgrade_1)
	q.setButtonEnableShadow(self._ccbOwner.btn_upgrade_5)
	
	self._expItems = {}
	self._eatNum = 0
	self._changeLevel = 0
	self._attributeInfo = {}
	self._parent = options.parent
end

function QUIWidgetArtifactInfoLevel:setInfo(actorId)
	self._actorId = actorId
	local character = db:getCharacterByID(actorId)
	self._artifactInfo = remote.herosUtil:getHeroByID(actorId).artifact
	self._aptitude = character.aptitude
	self._artifactId = character.artifact_id
	self._artifactConfig = db:getItemByID(self._artifactId)
	local levelConfigs = db:getArtifactLevelConfigBylevel(self._aptitude)
	local maxLevel = #levelConfigs
	self._maxLevel = math.min(remote.user.level * 2 , maxLevel)

	self._ccbOwner.node_artifact:removeAllChildren()
    if character.backSoulFile then
        local fcaFile = character.backSoulFile
        local artifact = QUIWidgetFcaAnimation.new(fcaFile, "actor")
        if artifact:getSkeletonView().isFca then
        	artifact:setScale(0.27)
        else
            artifact:getSkeletonView():flipActor()
            artifact:attachEffectToDummy(character.backSoulShowEffect)
	        if character.backSoulFile_xy then
	            local tbl = string.split(character.backSoulFile_xy,",")
	            artifact:setPosition(ccp(tonumber(tbl[1]), tonumber(tbl[2])))
	        end
        end
        self._ccbOwner.node_artifact:addChild(artifact)
    end

	self._ccbOwner.node_normal:setVisible(false)
	self._ccbOwner.node_max:setVisible(false)
	if self._artifactInfo.artifactLevel >= maxLevel then
		self._ccbOwner.node_max:setVisible(true)
		self:showArtifactMaxInfo()
	else
		self._ccbOwner.node_normal:setVisible(true)
		self:showArtifactInfo()
		self:setExpItems()	
	end
	
    self:setSABC()
end

function QUIWidgetArtifactInfoLevel:setSABC()
    local aptitudeInfo = db:getActorSABC(self._actorId)
    q.setAptitudeShow(self._ccbOwner, aptitudeInfo.lower)
end

function QUIWidgetArtifactInfoLevel:showArtifactMaxInfo()
	local props = db:getArtifactLevelConfigBylevel(self._aptitude, self._artifactInfo.artifactLevel)
	local index = 1
	index = self:setTotalPropTF(index, "生    命:", props.hp_value)
	index = self:setTotalPropTF(index, "攻    击:", props.attack_value)
	index = self:setTotalPropTF(index, "物理防御:", props.armor_physical)
	index = self:setTotalPropTF(index, "法术防御:", props.armor_magic)
end

function QUIWidgetArtifactInfoLevel:setTotalPropTF(index, name, value)
	if index > 4 then return index end
	if value ~= nil then
		self._ccbOwner["tf_prop_name"..index]:setString(name)
		self._ccbOwner["tf_prop_value"..index]:setString(value)
	end
	return index + 1
end

function QUIWidgetArtifactInfoLevel:showArtifactInfo()
	if self._artifactInfo.artifactLevel >= self._maxLevel then
		self._ccbOwner.node_item:setVisible(false)
		self._ccbOwner.node_limit:setVisible(true)
		self._ccbOwner.node_btn_upgrade_1:setVisible(false)
		self._ccbOwner.node_btn_upgrade_5:setVisible(false)
	else
		self._ccbOwner.node_limit:setVisible(false)
		self._ccbOwner.node_item:setVisible(true)
		self._ccbOwner.node_btn_upgrade_1:setVisible(true)
		self._ccbOwner.node_btn_upgrade_5:setVisible(true)
	end
	self._ccbOwner.tf_name:setString(self._artifactConfig.name)

	local fontColor = remote.artifact:getColorByActorId(self._actorId)
	self._ccbOwner.tf_name:setColor(fontColor)
	setShadowByFontColor(self._ccbOwner.tf_name, fontColor)
	
	self._ccbOwner.tf_level:setString(self._artifactInfo.artifactLevel.."/"..self._maxLevel)
	self:updateProgress(self._artifactInfo.artifactExp, self._artifactInfo.artifactLevel)

	local oldConfig = db:getArtifactLevelConfigBylevel(self._aptitude, self._artifactInfo.artifactLevel)
	self._ccbOwner.tf_cur_title:setString(self._artifactInfo.artifactLevel.."级属性")
	local index = 1
	index = self:setPropTF(index, true, "生    命:", oldConfig.hp_value)
	index = self:setPropTF(index, true, "攻    击:", oldConfig.attack_value)
	index = self:setPropTF(index, true, "物理防御:", oldConfig.armor_physical)
	index = self:setPropTF(index, true, "法术防御:", oldConfig.armor_magic)

	local newConfig = db:getArtifactLevelConfigBylevel(self._aptitude, self._artifactInfo.artifactLevel + 1)
	if newConfig ~= nil then
		self._ccbOwner.tf_next_title:setString((self._artifactInfo.artifactLevel+1).."级属性")
		index = 1
		index = self:setPropTF(index, false, "生    命:", newConfig.hp_value)
		index = self:setPropTF(index, false, "攻    击:", newConfig.attack_value)
		index = self:setPropTF(index, false, "物理防御:", newConfig.armor_physical)
		index = self:setPropTF(index, false, "法术防御:", newConfig.armor_magic)
	end
end

function QUIWidgetArtifactInfoLevel:setPropTF(index, isOld, name, value)
	if index > 4 then return index end
	if value ~= nil then
		if isOld == true then
			self._ccbOwner["tf_cur_name"..index]:setString(name)
			self._ccbOwner["tf_cur_value"..index]:setString("+"..value)
		else
			self._ccbOwner["tf_next_name"..index]:setString(name)
			self._ccbOwner["tf_next_value"..index]:setString("+"..value)
			self._ccbOwner["tf_next_value"..index]:setColor(GAME_COLOR_LIGHT.property)
		end
	end
	return index + 1
end

function QUIWidgetArtifactInfoLevel:setExpItems()
	self._materials = {}
	local materials = remote.artifact:getArtifactLevelMaterials()
	self._masterProp, self._masterLevel = db:getArtifactMasterInfo(self._aptitude, self._artifactInfo.artifactLevel)
	for i = 1, 3, 1 do
		local itemId = materials[i]
		if itemId ~= nil then
			self._ccbOwner["node_item"..i]:setVisible(true)
			if self._materials[i] == nil then
				self._materials[i] = itemId
			end
			if self._expItems[i] == nil then
				self._expItems[i] = QUIWidgetItemsBox.new()
				self._ccbOwner["item"..i]:addChild(self._expItems[i])
			end
			local count = remote.items:getItemsNumByID(itemId) or 0
			self._expItems[i]:setGoodsInfo(itemId, ITEM_TYPE.ITEM, count)

			self._ccbOwner["item_layer"..i]:setVisible(count<=0)
			local itemConfig = db:getItemByID(itemId)
			if itemConfig ~= nil then
				self._ccbOwner["tf_exp"..i]:setString("经验＋"..(itemConfig.exp_num or 0))
			end
		else
			self._ccbOwner["node_item"..i]:setVisible(false)
		end
	end
end

--设置进度条
function QUIWidgetArtifactInfoLevel:updateProgress(exp, level, addExp, isAnimation)		
	exp = exp or 0
	local nextExp = db:getArtifactLevelConfigBylevel(self._aptitude, level)
	if nextExp ~= nil then
		self._ccbOwner.tf_progress:setString(exp.."/"..nextExp.artifact_exp)
		self._ccbOwner.sp_progress:setScaleX(exp/nextExp.artifact_exp)
		if addExp == nil then
			return 
		end
		exp = exp + addExp
		if isAnimation then
			self._ccbOwner.tf_progress:setString(exp.."/"..nextExp.artifact_exp)
			local scaleX = exp/nextExp.artifact_exp
			scaleX = math.min(1, scaleX)
			local ccArr = CCArray:create()
			if exp >= nextExp.artifact_exp then
				ccArr:addObject(CCScaleTo:create(0.15, 2, 2))
				ccArr:addObject(CCCallFunc:create(function ()
					self:updateProgress(0, level + 1, exp - nextExp.artifact_exp, true)
				end))
			else
				ccArr:addObject(CCScaleTo:create(0.15, (exp/nextExp.artifact_exp)*2, 2))
			end
			self._ccbOwner.sp_progress:runAction(CCSequence:create(ccArr))
		else
			if exp >= nextExp.artifact_exp then
				self:updateProgress(0, level + 1, exp - nextExp.artifact_exp, false)
			else
				self._ccbOwner.tf_progress:setString(exp.."/"..nextExp.artifact_exp)
				self._ccbOwner.sp_progress:setScaleX(exp/nextExp.artifact_exp)
			end
		end
	end
end

function QUIWidgetArtifactInfoLevel:_onDownHandler(index)
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
	self._oldLevel = self._artifactInfo.artifactLevel
	self._oldMasterLevel = self._masterLevel
	self._selectIndex = index
	self._itemIndex = index
	self._itemId = self._materials[index]
	self._isUp = false
	self._isEating = false
	self._addNum = 1
	self._changeLevel = 0
	self._eatNum = 0

	self._delayTime = 0.2
	-- 延时一秒 如果一秒内未up或者移动则连续吃经验
	self._timeHandler = scheduler.performWithDelayGlobal(handler(self, self._eatExpItemsForEach), self._delayTime)
end

function QUIWidgetArtifactInfoLevel:_onUpHandler()
	if self._isUp == true then return end
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
	self._isUp = true
	if self._isEating == false then
		self:_eatExpItem()
	else
		self._isEating = false
	end
	self:upGrade()
end

function QUIWidgetArtifactInfoLevel:_eatExpItemsForEach(index)
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
	self._isEating = true
	self._timeHandler = scheduler.performWithDelayGlobal(handler(self, self._eatExpItem), self._delayTime)
end

function QUIWidgetArtifactInfoLevel:_eatExpItem()
	local itemNum = remote.items:getItemsNumByID(self._itemId) or 0
	if itemNum > 0 then
		if itemNum < self._addNum then
			self._addNum = itemNum or 0
		end
		local itemConfig = db:getItemByID(self._itemId)
		local exp = itemConfig.exp_num or 0 
		exp = exp * self._addNum

		local isSucc, addLevel, currExp = self:mountEatExp(exp) --检查是否能吃，吃完了能升级吗
		if isSucc then
			self:addEatNum() --累加吃经验道具
			self:_showEatNum(exp) --在经验条上显示经验飘动数据
			self:setExpItems() --设置经验道具的数量
			self:_showEffect() --显示吃经验飞动的效果

			--更新经验条
			self._artifactInfo.artifactExp = currExp
			self._artifactInfo.artifactLevel = self._artifactInfo.artifactLevel + addLevel
			self._ccbOwner.tf_level:setString(self._artifactInfo.artifactLevel.."/"..self._maxLevel)
			self:updateProgress(self._artifactInfo.artifactExp, self._artifactInfo.artifactLevel)

			if addLevel > 0 then
				self:showUpGradeEffect(addLevel)
			end

			if self._isEating == true then --如果在吃经验中则加快吃的速度 
				self._delayTime = self._delayTime - 0.02
				self._delayTime = self._delayTime > 0.05 and self._delayTime or 0.05
				self._addNum = self._addNum + 2 
				self._addNum = self._addNum >= 10 and 10 or self._addNum
				self._timeHandler = scheduler.performWithDelayGlobal(handler(self, self._eatExpItem), self._delayTime)
			end
		else
			self:_onUpHandler()
			return
		end
	else
		self:_onUpHandler()
		local dropType = QQuickWay.ITEM_DROP_WAY
    	QQuickWay:addQuickWay(dropType, self._itemId, nil, nil, nil, "武魂真身升级材料不足，请查看获取途径~")
	end
end

function QUIWidgetArtifactInfoLevel:addEatNum()
	if remote.items:removeItemsByID(self._itemId, self._addNum, false) == false then
		return
	end
	self._eatNum = self._eatNum + self._addNum
end


function QUIWidgetArtifactInfoLevel:_showEatNum(exp)
	if self._numEffect == nil then
		self._numEffect = QUIWidgetAnimationPlayer.new()
		self._ccbOwner.node_exp:addChild(self._numEffect)
	end
	self._numEffect:playAnimation("effects/Tips_add.ccbi", function(ccbOwner)
				ccbOwner.content:setString(" ＋"..exp)
            end)
end

function QUIWidgetArtifactInfoLevel:_showEffect()
	local effectFun1 = function ()
		local actionHandler = nil
		local item = QUIWidgetItemsBox.new()
		item:setGoodsInfo(self._itemId, "item", 0)
		self._ccbOwner["item"..self._itemIndex]:addChild(item)

		local position1 = self._ccbOwner.node_exp:convertToWorldSpaceAR(ccp(0, 0))
		local position2 = self._ccbOwner["item"..self._itemIndex]:convertToWorldSpaceAR(ccp(0, 0))

		local targetPosition = ccp(position1.x - position2.x , position1.y - position2.y + 80)

		local moveTo = CCMoveTo:create(0.1, targetPosition)
		local scale = CCScaleTo:create(0.1, 0)
		local func = CCCallFunc:create(function()
				item:removeFromParent()
				item = nil
				actionHandler = nil
			end)
		local array1 = CCArray:create()
		array1:addObject(moveTo)
		array1:addObject(scale)
		local ccspawn = CCSpawn:create(array1)

		local array2 = CCArray:create()
		array2:addObject(ccspawn)
		array2:addObject(func)
		local ccsequence = CCSequence:create(array2)
		actionHandler = item:runAction(ccsequence)
	end
	local effectFun2 = function ()
    	local effect = QUIWidgetAnimationPlayer.new()
    	self._ccbOwner["item"..self._itemIndex]:addChild(effect)
    	effect:playAnimation("ccb/effects/UseItem2.ccbi", nil, function()
                effect:disappear()
                effect = nil
            end)
	end
	effectFun1()
	scheduler.performWithDelayGlobal(effectFun2, 0.1)
end

function QUIWidgetArtifactInfoLevel:mountEatExp(exp)
	local nextExp = db:getArtifactLevelConfigBylevel(self._aptitude, self._artifactInfo.artifactLevel)
	if nextExp == nil then
		return false
	end
	if nextExp.artifact_level >= self._maxLevel then
		return false, 0, 0
	end
	local addLevel = 0
	local currentExp = self._artifactInfo.artifactExp + exp
	while true do
		if currentExp >= nextExp.artifact_exp then
			addLevel = addLevel + 1
			currentExp = currentExp - nextExp.artifact_exp
			nextExp = db:getArtifactLevelConfigBylevel(self._aptitude, self._artifactInfo.artifactLevel + addLevel)
			if nextExp == nil then
				return true, addLevel, 0
			end
		else
			break
		end
	end
	return true, addLevel, currentExp
end

function QUIWidgetArtifactInfoLevel:showUpGradeEffect(addLevel)
	local masterProp, masterLevel = db:getArtifactMasterInfo(self._aptitude, self._artifactInfo.artifactLevel)
	if masterLevel > self._masterLevel then
		self:_onUpHandler()
	end
	self:strengthenSucceed(addLevel, masterLevel - self._masterLevel)
end

function QUIWidgetArtifactInfoLevel:strengthenSucceed(addLevel, masterLevel)
	local effectShow = QUIWidgetAnimationPlayer.new()
	effectShow:setPositionY(45)
	self._ccbOwner.node_artifact:addChild(effectShow,999)
	effectShow:playAnimation("ccb/effects/qianghua_effect_g.ccbi",nil,function ()
		effectShow:removeFromParent()
	end)
	app.sound:playSound("equipment_enhance")
	self._changeLevel = self._changeLevel + addLevel
	self:showUpdateEffect(addLevel, masterLevel)
end

function QUIWidgetArtifactInfoLevel:showUpdateEffect(addLevel, masterLevel)
	if addLevel > 0 then
		local oldConfig = db:getArtifactLevelConfigBylevel(self._aptitude, self._artifactInfo.artifactLevel - addLevel)
		local newConfig = db:getArtifactLevelConfigBylevel(self._aptitude, self._artifactInfo.artifactLevel)

        self.attributeNum = 1
		self:_setAttributeInfo("攻   击：", oldConfig.attack_value, newConfig.attack_value)
		self:_setAttributeInfo("生   命：", oldConfig.hp_value, newConfig.hp_value)
		self:_setAttributeInfo("命   中：", oldConfig.hit_rating, newConfig.hit_rating)
		self:_setAttributeInfo("闪   避：", oldConfig.dodge_rating, newConfig.dodge_rating)
		self:_setAttributeInfo("暴   击：", oldConfig.critical_rating, newConfig.critical_rating)
		self:_setAttributeInfo("格   挡：", oldConfig.block_rating, newConfig.block_rating)
		self:_setAttributeInfo("攻   速：", oldConfig.haste_rating, newConfig.haste_rating)
		self:_setAttributeInfo("物理防御：", oldConfig.armor_physical, newConfig.armor_physical)
		self:_setAttributeInfo("法术防御：", oldConfig.armor_magic, newConfig.armor_magic)
		self:_setAttributeInfo("生命百分比：", string.format("%0.3f",(oldConfig.hp_percent or 0) * 100), string.format("%0.3f",(newConfig.hp_percent or 0) * 100))
		self:_setAttributeInfo("攻击百分比：", string.format("%0.3f",(oldConfig.attack_percent or 0) * 100), string.format("%0.3f",(newConfig.attack_percent or 0) * 100))
	end
	if masterLevel > 0 then
		self._parent:enableTouchSwallowTop()
	end
	self:_showSucceedEffect(masterLevel)
end

function QUIWidgetArtifactInfoLevel:_setAttributeInfo(str, oldValue, newValue)
	local value = tonumber(string.format("%0.3f",(newValue or 0) - (oldValue or 0)))
	if self.attributeNum <= 4 and value ~= 0 then
		table.insert(self._attributeInfo, {name = str, value = value})
        self.attributeNum = self.attributeNum + 1
	end
end

function QUIWidgetArtifactInfoLevel:_showSucceedEffect(masterLevel)
	self._ccbOwner.node_animation:removeAllChildren()
	local ccbFile = "ccb/effects/mountstrenghtSccess.ccbi"
	local strengthenEffectShow = QUIWidgetAnimationPlayer.new()
	self._ccbOwner.node_animation:addChild(strengthenEffectShow)
	strengthenEffectShow:setPosition(ccp(0, 200))
	strengthenEffectShow:playAnimation(ccbFile, function()
			for i=1,4 do
				strengthenEffectShow._ccbOwner["node_"..i]:setVisible(false)
			end
			strengthenEffectShow._ccbOwner.title_enchant:setVisible(false)
			strengthenEffectShow._ccbOwner.title_skill:setVisible(false)
			strengthenEffectShow._ccbOwner.title_strengthen:setString("等级  ＋"..self._changeLevel)
			if self._attributeInfo ~= nil then
				local index = 1
				strengthenEffectShow._ccbOwner.node_1:setVisible(false)
				strengthenEffectShow._ccbOwner.node_2:setVisible(false)
				for _,propInfo in ipairs(self._attributeInfo) do
					strengthenEffectShow._ccbOwner["tf_name"..index]:setString(propInfo.name .. "＋" .. propInfo.value)
					strengthenEffectShow._ccbOwner["node_"..index]:setVisible(true)
					index = index + 1
					if index > 4 then
						break
					end
				end
			end

			self._changeLevel = 0
			self._attributeInfo = {}
		end, function()
			if masterLevel > 0 then
				if self._parent ~= nil then 
					self._parent:disableTouchSwallowTop()
				end
				local successTip = app.master.ARTIFACT_MASTER_TIP
				if app.master:getMasterShowState(successTip) then
					app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogArtifactTalentSuccess",
						options = { actorId = self._actorId, isTalent = true, successTip = successTip, callback = function ()
						end}},{isPopCurrentDialog = false})
				end
			end
		end)
end

function QUIWidgetArtifactInfoLevel:upGrade()
	-- body
	if self._eatNum > 0 then
		local eatNum = self._eatNum
		self._eatNum = 0
		local itemId = self._materials[self._itemIndex]
		remote.artifact:artifactEnchantRequest(self._actorId, {{type = itemId, count = eatNum}}, function ()
			remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
		end)
	end
end

function QUIWidgetArtifactInfoLevel:upGradeByLevel(addLevel)
	local info = remote.artifact:strengthToLevel(self._actorId, addLevel)
	if info.statusCode ~= nil then
		if info.statusCode == 1 then
			app.tip:floatTip("等级不可超过等级上限")
		elseif info.statusCode == 2 and info.dropItemId ~= nil then
    		QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, self._materials[#self._materials])
		end
		return
	end
	local eatItems = {}
	for _,v in ipairs(info.eatItems) do
		table.insert(eatItems, {type = v.id, count = v.count})
	end

	local oldLevel = self._artifactInfo.artifactLevel
	remote.artifact:artifactEnchantRequest(self._actorId, eatItems, function ()
		remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})

		if self.class then
			local _, masterLevel1 = QStaticDatabase:sharedDatabase():getArtifactMasterInfo(self._aptitude, oldLevel)
			local _, masterLevel2 = QStaticDatabase:sharedDatabase():getArtifactMasterInfo(self._aptitude, oldLevel + info.addLevel)
			self:strengthenSucceed(info.addLevel, masterLevel2 - masterLevel1)
		end
	end)
end

function QUIWidgetArtifactInfoLevel:_onTriggerClickItem1(event)
	if tonumber(event) == CCControlEventTouchDown then
		self:_onDownHandler(1)
	else
		self:_onUpHandler(1)
	end
end

function QUIWidgetArtifactInfoLevel:_onTriggerClickItem2(event)
	if tonumber(event) == CCControlEventTouchDown then
		self:_onDownHandler(2)
	else
		self:_onUpHandler(2)
	end
end

function QUIWidgetArtifactInfoLevel:_onTriggerClickItem3(event)
	if tonumber(event) == CCControlEventTouchDown then
		self:_onDownHandler(3)
	else
		self:_onUpHandler(3)
	end
end

function QUIWidgetArtifactInfoLevel:_onTriggerClickLink(event)
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogInstance", options = {isQuickWay = true}})
end

function QUIWidgetArtifactInfoLevel:_onTriggerUpgrade1(event)
	app.sound:playSound("common_small")

	self:upGradeByLevel(1)
end

function QUIWidgetArtifactInfoLevel:_onTriggerUpgrade5(event)
	app.sound:playSound("common_small")

	self:upGradeByLevel(5)
end

return QUIWidgetArtifactInfoLevel