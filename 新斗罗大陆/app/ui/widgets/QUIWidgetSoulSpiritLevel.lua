--
-- Kumo.Wang
-- 魂靈升級界面
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSoulSpiritLevel = class("QUIWidgetSoulSpiritLevel", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QQuickWay = import("...utils.QQuickWay")
local QUIViewController = import("..QUIViewController")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")
local QActorProp = import("...models.QActorProp")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")
local QRichText = import("...utils.QRichText") 

function QUIWidgetSoulSpiritLevel:ctor(options)
	local ccbFile = "ccb/Widget_SoulSpirit_Level.ccbi"
	local callBacks = {
			{ccbCallbackName = "onTriggerClickItem", callback = handler(self, self._onTriggerClickItem)},
			{ccbCallbackName = "onTriggerClickLink", callback = handler(self, self._onTriggerClickLink)},
			{ccbCallbackName = "onTriggerLevelUp", callback = handler(self, self._onTriggerLevelUp)},
			{ccbCallbackName = "onTriggerSelect", callback = handler(self, self._onTriggerSelect)},
			{ccbCallbackName = "onTriggerHelp", callback = handler(self, self._onTriggerHelp)},
		}
	QUIWidgetSoulSpiritLevel.super.ctor(self,ccbFile,callBacks,options)

	self._doubleValue = 0 -- 双倍概率：0～100
	self._levelUpPropList = {}
	self._isPlaying = false
	self._isPutInFood = false
	self._isInit = true
end

function QUIWidgetSoulSpiritLevel:isPlaying()
	return self._isPlaying
end

function QUIWidgetSoulSpiritLevel:setInfo(id, heroId)
	if not id and not heroId then
        return
    elseif id and heroId then
        self._id = id
        self._heroId = heroId
    elseif id then
        self._id = id
        local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(self._id)
        self._heroId = soulSpiritInfo and soulSpiritInfo.heroId or 0
    elseif heroId then
        self._heroId = heroId
        local heroInfo = remote.herosUtil:getHeroByID(self._heroId)
        local soulSpiritInfo = heroInfo.soulSpirit
        self._id = soulSpiritInfo and soulSpiritInfo.id or 0
    end

    self._characterConfig = QStaticDatabase.sharedDatabase():getCharacterByID(self._id)
    local levelConfigList = remote.soulSpirit:getLevelConfigListByAptitude(self._characterConfig.aptitude)
    self._maxLevelByConfig = levelConfigList[#levelConfigList].chongwu_level
	self._maxLevel = math.min(remote.user.level * 2, self._maxLevelByConfig)
	
	self._ccbOwner.node_avatar:removeAllChildren()
local avatar = QUIWidgetActorDisplay.new(self._id)
	self._ccbOwner.node_avatar:addChild(avatar)
	self._ccbOwner.node_avatar:setScaleX(-0.8)
		
	self._ccbOwner.node_normal:setVisible(false)
	self._ccbOwner.node_max:setVisible(false)
	
    self:setSABC()
    print("self:updateInfo(1)")
    self:updateInfo(true)
end

function QUIWidgetSoulSpiritLevel:updateInfo(donotShowFood)
	local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(self._id)
	if soulSpiritInfo.level >= self._maxLevelByConfig then
		self._ccbOwner.node_max:setVisible(true)
		self._ccbOwner.node_normal:setVisible(false)
		self:showMaxInfo()
	else
		self._ccbOwner.node_max:setVisible(false)
		self._ccbOwner.node_normal:setVisible(true)
		self:showInfo()
		self:updateSelectedFoods(true, donotShowFood)	
	end
end

function QUIWidgetSoulSpiritLevel:setSABC()
    local aptitudeInfo = db:getActorSABC(self._id)
    q.setAptitudeShow(self._ccbOwner, aptitudeInfo.lower)

    self._ccbOwner["node_bg_a"]:setVisible(false)
    self._ccbOwner["node_bg_a+"]:setVisible(false)
    self._ccbOwner["node_bg_s"]:setVisible(false)
    self._ccbOwner["node_bg_ss"]:setVisible(false)
    self._ccbOwner["node_bg_"..aptitudeInfo.lower]:setVisible(true)
end

function QUIWidgetSoulSpiritLevel:showMaxInfo()
	self._ccbOwner.tf_name:setString(self._characterConfig.name)
	local fontColor = QIDEA_QUALITY_COLOR[remote.soulSpirit:getColorByCharacherId(self._id)] or COLORS.b
	self._ccbOwner.tf_name:setColor(fontColor)
	self._ccbOwner.tf_name = setShadowByFontColor(self._ccbOwner.tf_name, fontColor)
	
	local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(self._id)
	local levelConfig = remote.soulSpirit:getLevelConfigByAptitudeAndLevel(self._characterConfig.aptitude, soulSpiritInfo.level)
	local uiPropList = remote.soulSpirit:getUiPropListByConfig(levelConfig)
	local index = 1
	while true do
		local tfName = self._ccbOwner["tf_prop_name"..index]
		if tfName then
			tfName:setString("")
		end
		local tfValue = self._ccbOwner["tf_prop_value"..index]
		if tfValue then
			tfValue:setString("")
		end
		if tfName or tfValue then
			index = index + 1
		else
			break
		end
	end
	index = 1
	for _, prop in ipairs(uiPropList) do
		local tfName = self._ccbOwner["tf_prop_name"..index]
		if tfName then
			local name = QActorProp._field[prop.key].uiName or QActorProp._field[prop.key].name
			tfName:setString(name.."：")
		end
		local tfValue = self._ccbOwner["tf_prop_value"..index]
		if tfValue then
			local isPercent = QActorProp._field[prop.key].isPercent
            local str = q.getFilteredNumberToString(tonumber(prop.num), isPercent, 2) 
			tfValue:setString("+"..str)
		end
		if tfName or tfValue then
			index = index + 1
		else
			break
		end
	end
end

function QUIWidgetSoulSpiritLevel:showInfo()
	local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(self._id)
	if soulSpiritInfo.level >= self._maxLevel then
		self._ccbOwner.node_item:setVisible(false)
		self._ccbOwner.node_limit:setVisible(true)
		self._ccbOwner.node_btn_levelUp:setVisible(false)
		self._ccbOwner.node_auto_put_in:setVisible(false)
	else
		self._ccbOwner.node_limit:setVisible(false)
		self._ccbOwner.node_item:setVisible(true)
		self._ccbOwner.node_btn_levelUp:setVisible(true)
		self._ccbOwner.node_auto_put_in:setVisible(true)
		self:_updateAutoPutInState()
	end
	self._ccbOwner.tf_name:setString(self._characterConfig.name)

	local fontColor = QIDEA_QUALITY_COLOR[remote.soulSpirit:getColorByCharacherId(self._id)] or COLORS.b
	self._ccbOwner.tf_name:setColor(fontColor)
	self._ccbOwner.tf_name = setShadowByFontColor(self._ccbOwner.tf_name, fontColor)
	
	self._ccbOwner.tf_level:setString(soulSpiritInfo.level.."/"..self._maxLevel)

	local curLevelConfig = remote.soulSpirit:getLevelConfigByAptitudeAndLevel(self._characterConfig.aptitude, soulSpiritInfo.level)
	local uiPropList = remote.soulSpirit:getUiPropListByConfig(curLevelConfig)
	local index = 1
	while true do
		local tfName = self._ccbOwner["tf_cur_name"..index]
		if tfName then
			tfName:setString("")
		end
		local tfValue = self._ccbOwner["tf_cur_value"..index]
		if tfValue then
			tfValue:setString("")
		end
		if tfName or tfValue then
			index = index + 1
		else
			break
		end
	end
	index = 1
	for _, prop in ipairs(uiPropList) do
		local tfName = self._ccbOwner["tf_cur_name"..index]
		if tfName then
			local name = QActorProp._field[prop.key].uiName or QActorProp._field[prop.key].name
			tfName:setString(name.."：")
		end
		local tfValue = self._ccbOwner["tf_cur_value"..index]
		if tfValue then
			local isPercent = QActorProp._field[prop.key].isPercent
            local str = q.getFilteredNumberToString(tonumber(prop.num), isPercent, 2) 
			tfValue:setString("+"..str)
		end
		if tfName or tfValue then
			index = index + 1
		else
			break
		end
	end
	self._ccbOwner.tf_cur_title:setString(soulSpiritInfo.level.."级属性")

	local nextLevelConfig = remote.soulSpirit:getLevelConfigByAptitudeAndLevel(self._characterConfig.aptitude, soulSpiritInfo.level + 1)
	index = 1
	while true do
		local tfName = self._ccbOwner["tf_next_name"..index]
		if tfName then
			tfName:setString("")
		end
		local tfValue = self._ccbOwner["tf_next_value"..index]
		if tfValue then
			tfValue:setString("")
		end
		if tfName or tfValue then
			index = index + 1
		else
			break
		end
	end
	index = 1
	if nextLevelConfig then
		local uiPropList = remote.soulSpirit:getUiPropListByConfig(nextLevelConfig)
		for _, prop in ipairs(uiPropList) do
			local tfName = self._ccbOwner["tf_next_name"..index]
			if tfName then
				local name = QActorProp._field[prop.key].uiName or QActorProp._field[prop.key].name
				tfName:setString(name.."：")
			end
			local tfValue = self._ccbOwner["tf_next_value"..index]
			if tfValue then
				local isPercent = QActorProp._field[prop.key].isPercent
	            local str = q.getFilteredNumberToString(tonumber(prop.num), isPercent, 2) 
				tfValue:setString("+"..str)
			end
			if tfName or tfValue then
				index = index + 1
			else
				break
			end
		end
		self._ccbOwner.tf_next_title:setString((soulSpiritInfo.level + 1).."级属性")
	else
		self._ccbOwner.tf_next_title:setString("")
	end
end

function QUIWidgetSoulSpiritLevel:cleanSelectedFoods()
	if self._ccbView then
		self._isPutInFood = false

		for i = 1, remote.soulSpirit.maxFoodCount, 1 do
			local node = self._ccbOwner["node_item"..i]
			if node then
				node:removeAllChildren()
				node:stopAllActions()
				local box = QUIWidgetItemsBox.new()
				box:setScale(0.8)
				box:isShowPlus(true)
				node:addChild(box)
			end
		end


		self:cleanPreviewInfoByFoods()
	end
end

function QUIWidgetSoulSpiritLevel:updateSelectedFoods(isAnimation, donotShowFood)
	if self._ccbView then
		local foodIdList = remote.soulSpirit:getSelectedFoodIdList()
		if self._isInit and donotShowFood then
			foodIdList = {}
		end
		for i = 1, remote.soulSpirit.maxFoodCount, 1 do
			local node = self._ccbOwner["node_item"..i]
			if node then
				node:removeAllChildren()
				node:stopAllActions()
				local box = QUIWidgetItemsBox.new()
				box:setScale(0.8)
				if (self._isInit and donotShowFood) or i > #foodIdList then
					box:isShowPlus(true)
				else
					local itemId = foodIdList[i]
					box:setGoodsInfo(itemId, ITEM_TYPE.ITEM, 0)
					box:isShowPlus(false)
					if isAnimation and remote.soulSpirit:getAutoPutInFoodState() == 2 and not self._isPutInFood then
						print("[QUIWidgetSoulSpiritLevel:updateSelectedFoods(1)]", i, #foodIdList)
						local arr = CCArray:create()
						local time = 0.3
						local sx = 1
						local sy = 1
						arr:addObject(CCScaleTo:create(time, sx, sy))
						if i == #foodIdList then
							arr:addObject(CCCallFunc:create(function()
								if self._ccbView then
									print("[QUIWidgetSoulSpiritLevel:updateSelectedFoods(2)]", self._isAutoLevelUping, donotShowFood, self._isGoon)
									self._isPutInFood = true
									if self._isAutoLevelUping then
										if self._isGoon then
											self:_onTriggerLevelUp()
										end
									elseif not donotShowFood then
										print("self._isPlaying = false[1]")
										self._isPlaying = false
									end
								end
							end))
						end
						node:setScale(0)
						node:runAction(CCSequence:create(arr))
					else
						self._isPutInFood = true
					end
				end
				node:addChild(box)
			end
		end

		self._isInit = false

		self:updatePreviewInfoByFoods()

		print("[QUIWidgetSoulSpiritLevel:updateSelectedFoods(3)]", self._isAutoLevelUping, donotShowFood, self._isGoon)
		if #foodIdList == 0 then
			print("self._isPlaying = false[2]")
			self._isPlaying = false
			self:_stopAutolevelUp()
		else
			if self._isAutoLevelUping then
				if self._isGoon and self._isPutInFood then
					self:_onTriggerLevelUp()
				end
			elseif not donotShowFood then
				print("self._isPlaying = false[3]")
				self._isPlaying = false
			end
		end
	end
end

function QUIWidgetSoulSpiritLevel:onExit()
	QUIWidgetSoulSpiritLevel.super.onExit(self)

	if self._stopPlayScheduler ~= nil then
		scheduler.unscheduleGlobal(self._stopPlayScheduler)
		self._stopPlayScheduler = nil
	end

	local index = 1
	while true do
		local node = self._ccbOwner["node_item"..index]
		if node then
			node:stopAllActions()
			index = index + 1
		else
			break
		end
	end
end

function QUIWidgetSoulSpiritLevel:cleanPreviewInfoByFoods()
	local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(self._id)
	local addExp, addCrit = nil, 0
	self:updateExpProgress(soulSpiritInfo.exp, addExp, soulSpiritInfo.level, false, false, 0, addCrit)
	self:updateDoubleProgress(addCrit)
end

function QUIWidgetSoulSpiritLevel:updatePreviewInfoByFoods()
	local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(self._id)
	local addExp, addCrit = remote.soulSpirit:getAddExpAndAddCrit()
	-- print("addExp, addCrit ", addExp, addCrit)
	self:updateExpProgress(soulSpiritInfo.exp, addExp, soulSpiritInfo.level, false, true, 0, addCrit)
	self:updateDoubleProgress(addCrit)
end

--设置进度条
function QUIWidgetSoulSpiritLevel:updateExpProgress(exp, addExp, level, isAnimation, isShowPreview, addLevel, addCrit)		
	exp = exp or 0
	local text = ""
	local nextLevelConfig = remote.soulSpirit:getLevelConfigByAptitudeAndLevel(self._characterConfig.aptitude, level+1)
	if nextLevelConfig then
		if addExp and addExp > 0 then
			if addCrit and addCrit >= 100 then
				text = "##j经验值##q+"..(addExp*2)
				self._ccbOwner.tf_expBar:setString((exp+addExp*2).."/"..nextLevelConfig.strengthen_chongwu)
			else
				text = "##j经验值##q+"..addExp
				self._ccbOwner.tf_expBar:setString((exp+addExp).."/"..nextLevelConfig.strengthen_chongwu)
			end
		else
			text = "##j经验值##q+0"
			self._ccbOwner.tf_expBar:setString(exp.."/"..nextLevelConfig.strengthen_chongwu)
		end
		local scaleValue = exp / nextLevelConfig.strengthen_chongwu
		scaleValue = math.min(scaleValue, 1)
		self._ccbOwner.sp_cur_expBar:setScaleX(scaleValue)
		if addExp == nil then
			self._ccbOwner.node_exp_preview:removeAllChildren()
			self._ccbOwner.sp_preview_expBar:setScaleX(0)
			return 
		end
		exp = exp + addExp
		if isShowPreview then
			local addLevelNum = 0
			if addCrit and addCrit >= 100 then
				addLevelNum = remote.soulSpirit:getAddLevelNumByIdAndAddExp(self._id, addExp*2, self._maxLevel, level)
			else
				addLevelNum = remote.soulSpirit:getAddLevelNumByIdAndAddExp(self._id, addExp, self._maxLevel, level)
			end
			if addLevelNum > 0 then
				-- 升级
				if level + addLevelNum >= self._maxLevel then
					text = text.." ##r满级"
				else
					text = text.." ##j等级##q+"..addLevelNum
				end
				self._ccbOwner.sp_preview_expBar:setScaleX(1)
			else
				local scaleValue = exp / nextLevelConfig.strengthen_chongwu
				scaleValue = math.min(scaleValue, 1)
				self._ccbOwner.sp_preview_expBar:setScaleX(scaleValue)
			end

			local richText = QRichText.new(text, 500, {stringType = 1, defaultSize = 16})
			richText:setAnchorPoint(ccp(0, 0.5))
			self._ccbOwner.node_exp_preview:removeAllChildren()
			self._ccbOwner.node_exp_preview:addChild(richText)
		else
			self._ccbOwner.node_exp_preview:removeAllChildren()
			self._ccbOwner.sp_preview_expBar:setScaleX(0)
		end
		if isAnimation then
			self._ccbOwner.tf_expBar:setString(exp.."/"..nextLevelConfig.strengthen_chongwu)
			local scaleX = exp / nextLevelConfig.strengthen_chongwu
			scaleX = math.min(1, scaleX)
			local ccArr = CCArray:create()
			if exp >= nextLevelConfig.strengthen_chongwu then
				ccArr:addObject(CCScaleTo:create(0.15, 1, 1))
				ccArr:addObject(CCCallFunc:create(function ()
					self:updateExpProgress(exp - nextLevelConfig.strengthen_chongwu, 0, level + 1, isAnimation, isShowPreview, addLevel)
					-- self:updateExpProgress(0, exp - nextLevelConfig.strengthen_chongwu, level + 1, isAnimation, isShowPreview, addLevel)
				end))
			else
				ccArr:addObject(CCScaleTo:create(0.15, exp/nextLevelConfig.strengthen_chongwu, 1))
				ccArr:addObject(CCCallFunc:create(function ()
					self:updateDoubleProgress(0)
					if addLevel and addLevel > 0 then
						self:_levelUpSucceed(addLevel)
					else
						self._isGoon = true
						print("self:updateInfo(2)")
						self:updateInfo()
					end
				end))
			end
			self._ccbOwner.sp_cur_expBar:runAction(CCSequence:create(ccArr))
		elseif not isShowPreview then
			if exp >= nextLevelConfig.strengthen_chongwu then
				self:updateExpProgress(0, exp - nextLevelConfig.strengthen_chongwu, level + 1, isAnimation, isShowPreview, addLevel)
			else
				self._ccbOwner.tf_expBar:setString(exp.."/"..nextLevelConfig.strengthen_chongwu)
				self._ccbOwner.sp_cur_expBar:setScaleX(exp / nextLevelConfig.strengthen_chongwu)
				self:updateDoubleProgress(0)
				if addLevel and addLevel > 0 then
					self:_levelUpSucceed(addLevel)
				else
					self._isGoon = true
					print("self:updateInfo(3)")
					self:updateInfo()
				end
			end
		end
	else
		self._ccbOwner.tf_expBar:setString("--/--")
		self._ccbOwner.sp_cur_expBar:setScaleX(0)
		self._ccbOwner.node_exp_preview:removeAllChildren()
		self._ccbOwner.sp_preview_expBar:setScaleX(0)
		if not self._isMasterLevelUp then 
			print("self._isPlaying = false[4]")
			self._isPlaying = false
			self:_stopAutolevelUp()
		end
		print("self:updateInfo(4)")
		self:updateInfo()
	end
end

--设置进度条
function QUIWidgetSoulSpiritLevel:updateDoubleProgress(addCrit)		
	addCrit = addCrit or 0
	self._ccbOwner.tf_doubleBar:setString(addCrit.."%")
	local scaleValue = addCrit / 100
	scaleValue = math.min(scaleValue, 1)
	self._ccbOwner.sp_cur_doubleBar:setScaleX(scaleValue)
	local text = ""
	if addCrit == 100 then
		text = "##j暴击率:##q必定暴击"
	elseif addCrit > 100 then
		text = "##j暴击率:##r暴击溢出"
	else
		text = "##j暴击率:##q"..addCrit.."%"
	end
	local richText = QRichText.new(text, 500, {stringType = 1, defaultSize = 16})
	richText:setAnchorPoint(ccp(0, 0.5))
	self._ccbOwner.node_double_preview:removeAllChildren()
	self._ccbOwner.node_double_preview:addChild(richText)
end

function QUIWidgetSoulSpiritLevel:_showDoubleEffect()
	if self._numEffect == nil then
		self._numEffect = QUIWidgetAnimationPlayer.new()
		self._ccbOwner.node_exp_effect:addChild(self._numEffect)
	end
	-- self._numEffect:playAnimation("effects/Tips_add.ccbi", function(ccbOwner)
	-- 			ccbOwner.content:setString(" ＋"..exp)
 --            end)
	self._numEffect:playAnimation("effects/Attack_baoji.ccbi", nil, function()
			self._numEffect:removeFromParent()
			self._numEffect = nil
		end)
	
end

function QUIWidgetSoulSpiritLevel:_levelUpSucceed(addLevel)
	local effectShow = QUIWidgetAnimationPlayer.new()
	effectShow:setPositionY(45)
	self._ccbOwner.node_avatar:addChild(effectShow, 999)
	effectShow:playAnimation("ccb/effects/qianghua_effect_g.ccbi",nil,function ()
		effectShow:removeFromParent()
	end)
	app.sound:playSound("equipment_enhance")
	self:showUpdateEffect(addLevel)
end

function QUIWidgetSoulSpiritLevel:showUpdateEffect(addLevel)
	if addLevel > 0 then
		local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(self._id)
		local oldConfig = remote.soulSpirit:getLevelConfigByAptitudeAndLevel(self._characterConfig.aptitude, soulSpiritInfo.level - addLevel)
		local newConfig = remote.soulSpirit:getLevelConfigByAptitudeAndLevel(self._characterConfig.aptitude, soulSpiritInfo.level)
		local oldPropDic = remote.soulSpirit:getPropDicByConfig(oldConfig)
		local newPropDic = remote.soulSpirit:getPropDicByConfig(newConfig)
		for key, value in pairs(newPropDic) do
			local name = QActorProp._field[key].uiName or QActorProp._field[key].name
			local isPercent = QActorProp._field[key].isPercent
			local addValue = value - (oldPropDic[key] and oldPropDic[key] or 0)
            local str = q.getFilteredNumberToString(tonumber(addValue), isPercent, 2)
            local index = QActorProp:getPropIndexByKey(key)
			table.insert(self._levelUpPropList, {name = name, value = str, index = index})
		end
		
		table.sort(self._levelUpPropList, function(a, b)
				return a.index < b.index
			end)

		if not self._isMasterLevelUp then
			local oldMasterConfig = remote.soulSpirit:getMasterConfigByAptitudeAndSoulSpiritLevel(self._characterConfig.aptitude, soulSpiritInfo.level - addLevel)
			local newMasterConfig = remote.soulSpirit:getMasterConfigByAptitudeAndSoulSpiritLevel(self._characterConfig.aptitude, soulSpiritInfo.level)
			self._isMasterLevelUp = newMasterConfig.level > oldMasterConfig.level
		end
		self:_showSucceedEffect(addLevel)
	else
		print("self:updateInfo(5)")
		self:updateInfo()
	end
end

function QUIWidgetSoulSpiritLevel:_showSucceedEffect(addLevel)
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
			strengthenEffectShow._ccbOwner.title_strengthen:setString("等级  ＋"..addLevel)
			if self._levelUpPropList then
				local index = 1
				strengthenEffectShow._ccbOwner.node_1:setVisible(false)
				strengthenEffectShow._ccbOwner.node_2:setVisible(false)
				for _, propInfo in ipairs(self._levelUpPropList) do
					strengthenEffectShow._ccbOwner["tf_name"..index]:setString(propInfo.name .. "  ＋" .. propInfo.value)
					strengthenEffectShow._ccbOwner["node_"..index]:setVisible(true)
					index = index + 1
					if index > 4 then
						break
					end
				end
			end

			self._levelUpPropList = {}
		end, function()
			if self._isMasterLevelUp and remote.soulSpirit:checkDevourUpGradeShowState() then
				self._isMasterLevelUp = false
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulSpiritMasterLevelUpSuccess",
					options = {id = self._id, callback = function()
						if self._ccbView then
							if self._isAutoLevelUping then
								self._isGoon = true
							else
								print("self._isPlaying = false[5]")
								self._isPlaying = false
							end
							print("self:updateInfo(6)")
							self:updateInfo()
						end
					end}}, {isPopCurrentDialog = false})
			else
				if self._isAutoLevelUping then
					self._isGoon = true
				else
					print("self._isPlaying = false[6]")
					self._isPlaying = false
				end
				print("self:updateInfo(7)")
				self:updateInfo()
			end
		end)
end

function QUIWidgetSoulSpiritLevel:_onTriggerClickItem(e)
	if self._isPlaying then return end
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulSpiritChooseFood",
		options = {id = self._id, maxLevel = self._maxLevel, callback = handler(self, self.updateSelectedFoods)}}, {isPopCurrentDialog = false})
end

function QUIWidgetSoulSpiritLevel:_onTriggerClickLink(e)
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogInstance", options = {isQuickWay = true}})
end

function QUIWidgetSoulSpiritLevel:_stopAutolevelUp()
	self._isAutoLevelUping = false
	remote.soulSpirit.isWarningForCritNotEnough = false
	self._ccbOwner.tf_btn_levelUp:setString("吞 噬")
end

function QUIWidgetSoulSpiritLevel:_startAutolevelUp()
	self._isAutoLevelUping = true
	self._ccbOwner.tf_btn_levelUp:setString("停 止")
	if self._stopPlayScheduler ~= nil then
		scheduler.unscheduleGlobal(self._stopPlayScheduler)
		self._stopPlayScheduler = nil
	end
end

function QUIWidgetSoulSpiritLevel:_onTriggerLevelUp(e)
	print("[QUIWidgetSoulSpiritLevel:_onTriggerLevelUp()] ", e, self._isAutoLevelUping, remote.soulSpirit:checkAutoLevelUpUnlock(), remote.soulSpirit:getAutoLevelUpState(), self._isPutInFood, remote.soulSpirit.isWarningForCritNotEnough)
	if q.buttonEventShadow(e, self._ccbOwner.btn_levelUp) == false then return end
	if e then
		app.sound:playSound("common_small")
		if self._stopPlayScheduler ~= nil then
			scheduler.unscheduleGlobal(self._stopPlayScheduler)
			self._stopPlayScheduler = nil
		end
	end
	self._isPlaying = true
	self._isGoon = false

	if self._isAutoLevelUping then
		if e then
			-- 手动停止自动吞噬
			self:_stopAutolevelUp()
			if self._isPlaying then
				self._stopPlayScheduler = scheduler.performWithDelayGlobal(function ()
					if self._ccbView then
						self._isPlaying = false
					end
				end, 1)
			end
			return
		else
			-- 自动吞噬ing
			self:_startAutolevelUp()
		end
	else
		-- 开始吞噬（普通、自动）
		if remote.soulSpirit:checkAutoLevelUpUnlock() and remote.soulSpirit:getAutoLevelUpState()  then
			self:_startAutolevelUp()
		else
			self:_stopAutolevelUp()
		end
	end

	local foodList = remote.soulSpirit:getSelectedFoodList()
	if #foodList == 0 then 
		app.tip:floatTip("未选择吞噬道具～")
		print("self._isPlaying = false[7]")
		self._isPlaying = false
		self:_stopAutolevelUp()
		return
	end

	if not self._isPutInFood then
		-- 多余的调用，材料还没有放入，不作为
		return
	end

	local addExp, addCrit = remote.soulSpirit:getAddExpAndAddCrit()

	if remote.soulSpirit.isWarningForCritNotEnough and self._isAutoLevelUping and addCrit < 100 then
		app:alert({content = "材料不足，相同配置暴击率不足100%，是否继续吞噬？（本次自动吞噬不再提示）", title = "系统提示", 
            callback = function(state)

            	remote.soulSpirit.isWarningForCritNotEnough = false

            	if self._ccbView then
	                if state == ALERT_TYPE.CONFIRM then
	                    self:_onTriggerLevelUp()
	                else
	                	print("self._isPlaying = false[8]")
						self._isPlaying = false
	                	self:_stopAutolevelUp()
	                end
               	end	
        end, isAnimation = false}, true, true)     
        return 
	end

	local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(self._id)
	local oldExp = soulSpiritInfo.exp
	local oldLevel = soulSpiritInfo.level
	local guessAddLevel, guessExp = remote.soulSpirit:getAddLevelNumByIdAndAddExp(self._id, addExp, self._maxLevel, oldLevel)

	remote.soulSpirit:soulSpiritLevelUpdateRequest(self._id, foodList, function(data)
			if self._ccbView then
				local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(self._id)
				local addLevel = soulSpiritInfo.level - oldLevel

				local oldMasterConfig = remote.soulSpirit:getMasterConfigByAptitudeAndSoulSpiritLevel(self._characterConfig.aptitude, oldLevel)
				local newMasterConfig = remote.soulSpirit:getMasterConfigByAptitudeAndSoulSpiritLevel(self._characterConfig.aptitude, soulSpiritInfo.level)
				self._isMasterLevelUp = newMasterConfig.level > oldMasterConfig.level
				
				self:cleanSelectedFoods()

				local fcaAnimation = QUIWidgetFcaAnimation.new("fca/hunling_tsbao1", "res")
				if fcaAnimation then
					fcaAnimation:playAnimation("animation", false)
					self._ccbOwner.node_fca:removeAllChildren()
					self._ccbOwner.node_fca:addChild(fcaAnimation)
				end
				self:updateExpProgress(oldExp, addExp, oldLevel, false, false, addLevel)

				if addLevel > guessAddLevel or (addLevel == guessAddLevel and soulSpiritInfo.exp > guessExp) then
					self:_showDoubleEffect()
				end
			end
		end, function()
			if self._ccbView then
				print("self._isPlaying = false[9]")
				self._isPlaying = false
				self:_stopAutolevelUp()
			end
		end)
end

function QUIWidgetSoulSpiritLevel:_onTriggerSelect(e)
	if self._isPlaying then return end
	app.sound:playSound("common_small")
	
	if remote.soulSpirit:checkAutoLevelUpUnlock() then
		--需要加tips提示 一个账号触发一次
		remote.soulSpirit:checkAutoLevelUpUnlockTips()
		
		if remote.soulSpirit:getAutoLevelUpState() then
			remote.soulSpirit:setAutoLevelUpState(false)
		else
			remote.soulSpirit:setAutoLevelUpState(true)
		end
	else
		if remote.soulSpirit:getAutoPutInFoodState() == 0 then
			remote.soulSpirit:setAutoPutInFoodState(1)
		else
			remote.soulSpirit:setAutoPutInFoodState(0)
		end
	end

	self:_updateAutoPutInState()
end

function QUIWidgetSoulSpiritLevel:_updateAutoPutInState()
	if remote.soulSpirit:checkAutoLevelUpUnlock() then
		self._ccbOwner.tf_auto_put_in:setString("连续吞噬")
		self._ccbOwner.sp_select:setVisible(remote.soulSpirit:getAutoLevelUpState())
	else
		self._ccbOwner.tf_auto_put_in:setString("自动放入")
		self._ccbOwner.sp_select:setVisible(remote.soulSpirit:getAutoPutInFoodState() ~= 0)
	end
end

function QUIWidgetSoulSpiritLevel:_onTriggerHelp(e)
	if self._isPlaying then return end
	if q.buttonEventShadow(e, self._ccbOwner.btn_help) == false then return end
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSoulSpiritLevelUpHelp"})
end

return QUIWidgetSoulSpiritLevel