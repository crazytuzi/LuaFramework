--
-- zxs
-- 武魂真身突破升星页签
--
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetArtifactInfoGrade = class("QUIWidgetArtifactInfoGrade", QUIWidget)
local QUIWidgetItemsBox = import("...widgets.QUIWidgetItemsBox")
local QUIViewController = import("...QUIViewController")
local QRichText = import("....utils.QRichText") 
local QUIWidgetActorDisplay = import("..actorDisplay.QUIWidgetActorDisplay")
local QUIWidgetEquipmentAvatar = import("...widgets.QUIWidgetEquipmentAvatar")
local QQuickWay = import("....utils.QQuickWay")
local QScrollView = import("....views.QScrollView")

function QUIWidgetArtifactInfoGrade:ctor(options)
	local ccbFile = "ccb/Widget_artifact_shengxing.ccbi"
	local callBacks = {
		{ccbCallbackName = "onPlus", callback = handler(self, self._onPlus)},
		{ccbCallbackName = "onTriggerEvolution1", callback = handler(self, self._onTriggerEvolution)},
		{ccbCallbackName = "onTriggerEvolution2", callback = handler(self, self._onTriggerEvolution)},
		{ccbCallbackName = "onTriggerAutoAdd", callback = handler(self, self._onTriggerAutoAdd)},
		{ccbCallbackName = "onTriggerInfo", callback = handler(self, self._onTriggerInfo)},
	}
	QUIWidgetArtifactInfoGrade.super.ctor(self,ccbFile,callBacks,options)

	q.setButtonEnableShadow(self._ccbOwner.btn_break1)
	q.setButtonEnableShadow(self._ccbOwner.btn_break2)
	q.setButtonEnableShadow(self._ccbOwner.btn_auto_add)
	q.setButtonEnableShadow(self._ccbOwner.node_plus)
	
	self._needMoney = 0
end

function QUIWidgetArtifactInfoGrade:onEnter()
	self._remoteEventProxy = cc.EventProxy.new(remote.user)
	self._remoteEventProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, handler(self, self.refrashMoney))
end

function QUIWidgetArtifactInfoGrade:onExit()
	self._remoteEventProxy:removeAllEventListeners()
	self._remoteEventProxy = nil
end
 
function QUIWidgetArtifactInfoGrade:refrashMoney()
	self._ccbOwner.tf_gold_price:setColor(COLORS.k)
	if remote.user.money < self._needMoney then
		self._ccbOwner.tf_gold_price:setColor(COLORS.m)
	end
	self:checkRedTips()
end

function QUIWidgetArtifactInfoGrade:setInfo(actorId)
	self:resetInfo()
	-- body
	self._actorId = actorId
	self._artifactInfo = remote.herosUtil:getHeroByID(self._actorId).artifact
	self._artifactId = remote.artifact:getArtiactByActorId(actorId)
	self._artifactConfig = db:getItemByID(self._artifactId)
	self._grade = 0
	if self._artifactInfo and self._artifactInfo.artifactBreakthrough then
		self._grade = self._artifactInfo.artifactBreakthrough
	end
	self._autoAddInfo = remote.artifact:getAutoAddGradeInfo(self._artifactId, self._grade)
	self._isOpenAutoAdd = false

	local isUnlock = app.unlock:checkLock("UNLOCK_ARTIFACT_QUICK_UPGRADE")
	if self._autoAddInfo.addGrade >= 2 and isUnlock then
		self._isOpenAutoAdd = true
	end

    local configs = db:getArtifactGradeConfigById(self._artifactId) or {}
	local isMax = self._grade >= #configs
	if isMax then
		self:showArtifactMaxInfo()
	else
		self:showArtifactInfo()
	end
	self._ccbOwner.node_normal:setVisible(not isMax)
	self._ccbOwner.node_max:setVisible(isMax)

	self:checkRedTips()
end

function QUIWidgetArtifactInfoGrade:resetInfo()
	for index = 1, 5 do
		if self._ccbOwner["tf_cur_name"..index] then
			self._ccbOwner["tf_cur_name"..index]:setString("")
			self._ccbOwner["tf_cur_value"..index]:setString("")
		end
		if self._ccbOwner["tf_next_name"..index] then
			self._ccbOwner["tf_next_name"..index]:setString("")
			self._ccbOwner["tf_next_value"..index]:setString("")
		end
		if self._ccbOwner["tf_prop_name"..index] then
			self._ccbOwner["tf_prop_name"..index]:setString("")
			self._ccbOwner["tf_prop_value"..index]:setString("")
		end
	end

	self._ccbOwner.sp_stone:setVisible(false)
	self._ccbOwner.tf_stone_price:setVisible(false)
end

-- 切换是否显示自动添加子面板
function QUIWidgetArtifactInfoGrade:changeAutoAddInfo()
	self._ccbOwner.node_no_auto_add:setVisible(not self._isOpenAutoAdd)
	self._ccbOwner.node_on_auto_add:setVisible(self._isOpenAutoAdd)
	self._ccbOwner.node_progress:setVisible(false)

	self._ccbOwner.node_gold:setVisible(true)
	self._ccbOwner.node_item_offset_1:setVisible(true)
	self._ccbOwner.node_item_offset_2:setVisible(true)
	self._ccbOwner.node_item_offset_1:setPositionX(0)
	self._ccbOwner.node_item_offset_2:setPositionX(0)
	self._ccbOwner.node_gold:setPositionX(460)
	if self._isOpenAutoAdd then
		self._ccbOwner.node_gold:setPositionX(315)
	end

	local newGradeConfig = remote.artifact:getGradeByArtifactLevel(self._artifactId, self._grade+1)
	if newGradeConfig then
		if newGradeConfig[ITEM_TYPE.SUPER_STONE] then
			if self._isOpenAutoAdd then
				self._ccbOwner.node_item_offset_1:setPositionX(-80)
				self._ccbOwner.node_item_offset_2:setPositionX(-80)
			end
		else
			self._ccbOwner.node_item_offset_1:setVisible(self._isOpenAutoAdd)
			self._ccbOwner.node_item_offset_2:setVisible(false)
			self._ccbOwner.node_progress:setVisible(true)
		end
	else
		self._ccbOwner.node_item_offset_1:setVisible(false)
		self._ccbOwner.node_item_offset_2:setVisible(false)
	end
end

function QUIWidgetArtifactInfoGrade:showArtifactInfo()
	local color = remote.artifact:getColorByActorId(self._actorId)
	if color ~= nil then
		self._ccbOwner.tf_name1:setColor(color)
		self._ccbOwner.tf_name2:setColor(color)
	else
		self._ccbOwner.tf_name1:setColor(QIDEA_QUALITY_COLOR.WHITE)
		self._ccbOwner.tf_name2:setColor(QIDEA_QUALITY_COLOR.WHITE)
	end

	self:changeAutoAddInfo()
	self._ccbOwner.tf_name1:setString(self._artifactConfig.name)
	self._ccbOwner.tf_name2:setString(self._artifactConfig.name)
	self._ccbOwner.node_artifact1:removeAllChildren()
	self._ccbOwner.node_artifact2:removeAllChildren()
	self._ccbOwner.node_item:removeAllChildren()
	self._ccbOwner.node_item_1:removeAllChildren()
	self._ccbOwner.node_item_2:removeAllChildren()

	local itemAvatar1 = QUIWidgetEquipmentAvatar.new()
	self._ccbOwner.node_artifact1:addChild(itemAvatar1)
	itemAvatar1:setArtifactInfo(self._actorId, self._grade)
	local oldGradeConfig = remote.artifact:getGradeByArtifactLevel(self._artifactId, self._grade)
	local props = remote.artifact:getUIPropInfo(oldGradeConfig)
	local index = 1
	for i, prop in ipairs(props) do
		if self._ccbOwner["tf_cur_name"..index] then
			self._ccbOwner["tf_cur_name"..index]:setString(prop.name)
			self._ccbOwner["tf_cur_value"..index]:setString("+"..prop.value)
		end
		index = index + 1
	end

	local itemAvatar2 = QUIWidgetEquipmentAvatar.new()
	self._ccbOwner.node_artifact2:addChild(itemAvatar2)
	itemAvatar2:setArtifactInfo(self._actorId, self._grade+1)
	local newGradeConfig = remote.artifact:getGradeByArtifactLevel(self._artifactId, self._grade+1)
	if newGradeConfig ~= nil then
		local props = remote.artifact:getUIPropInfo(newGradeConfig)
		local index = 1
		for i, prop in ipairs(props) do
			if self._ccbOwner["tf_next_name"..index] then
				self._ccbOwner["tf_next_name"..index]:setString(prop.name)
				self._ccbOwner["tf_next_value"..index]:setString("+"..prop.value)
			end
			index = index + 1
		end
		local soulCount = remote.items:getItemsNumByID(newGradeConfig.soul_gem)
		self._ccbOwner.tf_progress:setString(soulCount.."/"..newGradeConfig.soul_gem_count)
		self._ccbOwner.sp_progress:setScaleX(math.min(soulCount/newGradeConfig.soul_gem_count, 1))
		self._needMoney = newGradeConfig.money

		self._ccbOwner.tf_gold_price:setColor(COLORS.k)
		if remote.user.money < self._needMoney then
			self._ccbOwner.tf_gold_price:setColor(COLORS.m)
		end
		self._ccbOwner.tf_gold_price:setString(self._needMoney)

		local itemBox = QUIWidgetItemsBox.new()
		self._ccbOwner.node_item_1:addChild(itemBox)
		itemBox:setGoodsInfo(newGradeConfig.soul_gem, ITEM_TYPE.ITEM, soulCount)
		itemBox:setItemCount(string.format("%d/%d", soulCount, newGradeConfig.soul_gem_count))
		itemBox:hideSabc()

		local itemConfig = db:getItemByID(newGradeConfig.soul_gem)
		local fontColor = EQUIPMENT_COLOR[itemConfig.colour]
		self._ccbOwner.tf_item_name1:setString(itemConfig.name)
		self._ccbOwner.tf_item_name1:setColor(fontColor)
		setShadowByFontColor(self._ccbOwner.tf_item_name1, fontColor)

		if newGradeConfig[ITEM_TYPE.SUPER_STONE] then
			local superCount = remote.items:getItemsNumByID(tonumber(ITEM_TYPE.SUPER_STONE))
			local itemBox = QUIWidgetItemsBox.new()
			self._ccbOwner.node_item_2:addChild(itemBox)
			itemBox:setGoodsInfo(tonumber(ITEM_TYPE.SUPER_STONE), ITEM_TYPE.ITEM)
			itemBox:setItemCount(string.format("%d/%d", superCount, newGradeConfig[ITEM_TYPE.SUPER_STONE]))
			itemBox:hideSabc()
	
			local itemConfig = db:getItemByID(ITEM_TYPE.SUPER_STONE)
			local fontColor = EQUIPMENT_COLOR[itemConfig.colour]
			self._ccbOwner.tf_item_name2:setString(itemConfig.name)
			self._ccbOwner.tf_item_name2:setColor(fontColor)
			setShadowByFontColor(self._ccbOwner.tf_item_name2, fontColor)
		end

	else
		self._ccbOwner.tf_progress:setString("已到顶级")
		self._ccbOwner.sp_progress:setScaleX(1)
	end

	local itemBox = QUIWidgetItemsBox.new()
	self._ccbOwner.node_item:addChild(itemBox)
	itemBox:setGoodsInfo(oldGradeConfig.soul_gem, ITEM_TYPE.ITEM)
	itemBox:hideSabc()

	local curPoint = self._grade
	local nextPoint = self._grade + 1
	self._ccbOwner.tf_skill_point:setString("可分配天赋点数："..curPoint.."→"..nextPoint)
end

function QUIWidgetArtifactInfoGrade:showArtifactMaxInfo()
	self._ccbOwner.node_gold:setVisible(false)
	self._ccbOwner.node_artifact:removeAllChildren()
	local itemAvatar = QUIWidgetEquipmentAvatar.new()
	self._ccbOwner.node_artifact:addChild(itemAvatar)
	itemAvatar:setArtifactInfo(self._actorId, self._grade)

	local gradeConfig = remote.artifact:getGradeByArtifactLevel(self._artifactId, self._grade)
	local props = remote.artifact:getUIPropInfo(gradeConfig)
	local index = 1
	for i, prop in ipairs(props) do
		if self._ccbOwner["tf_prop_name"..index] then
			self._ccbOwner["tf_prop_name"..index]:setString(prop.name)
			self._ccbOwner["tf_prop_value"..index]:setString("+"..prop.value)
		end
		index = index + 1
	end
end

function QUIWidgetArtifactInfoGrade:checkRedTips()
	local UIHeroModel = remote.herosUtil:getUIHeroByID(self._actorId)
	UIHeroModel:initArtifact()
	self._ccbOwner.node_grade_tips:setVisible(UIHeroModel:getArtifactState() == remote.artifact.STATE_CAN_BREAK)
end

function QUIWidgetArtifactInfoGrade:_onPlus(event)
	local newGradeConfig = remote.artifact:getGradeByArtifactLevel(self._artifactId, self._grade+1)
	if newGradeConfig ~= nil then
		local dropType = QQuickWay.ITEM_DROP_WAY
		QQuickWay:addQuickWay(dropType, newGradeConfig.soul_gem, nil, nil, false)
	end
end

function QUIWidgetArtifactInfoGrade:_onTriggerEvolution(event)
	app.sound:playSound("common_small")
	local newGradeConfig = remote.artifact:getGradeByArtifactLevel(self._artifactId, self._grade+1)
	if newGradeConfig == nil then
		app.tip:floatTip("已经到顶级")
		return
	end

	if self._needMoney and remote.user.money < self._needMoney then
		QQuickWay:moneyQuickWay()
		return
	end

	if newGradeConfig[ITEM_TYPE.SUPER_STONE] then
		local superCount = remote.items:getItemsNumByID(tonumber(ITEM_TYPE.SUPER_STONE))
		if superCount < newGradeConfig[ITEM_TYPE.SUPER_STONE] then
			QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, ITEM_TYPE.SUPER_STONE)
			return
		end
	end
	local soulCount = remote.items:getItemsNumByID(newGradeConfig.soul_gem)
	if soulCount < newGradeConfig.soul_gem_count then
		QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, newGradeConfig.soul_gem)
		return
	end

	local callback = function()
		remote.artifact:artifactGradeRequest(self._actorId, false, function ()
			self:setInfo(self._actorId)
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogArtifactGradeUpSuccess",
				options = { actorId = self._actorId, callback = function ()
					remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
				end}},{isPopCurrentDialog = false})
		end)
	end
	-- local content = ""
	-- local itemConfig = db:getItemByID(newGradeConfig.soul_gem)
	-- local heroInfo = db:getCharacterByID(self._actorId)
	-- if newGradeConfig[ITEM_TYPE.SUPER_STONE] then
	-- 	local superConfig = db:getItemByID(tonumber(ITEM_TYPE.SUPER_STONE))
	-- 	content = string.format("##n是否消耗##l【%s】*%d，##l【%s】*%d，金币*%d，##n让##l%s##n的武魂真身从##l%d##n星升级至##l%d##n星？",itemConfig.name, newGradeConfig.soul_gem_count, superConfig.name, newGradeConfig[ITEM_TYPE.SUPER_STONE], newGradeConfig.money, heroInfo.name, self._grade, self._grade+1 ) 
	-- else
	-- 	content = string.format("##n是否消耗##l【%s】*%d，金币*%d，##n让##l%s##n的武魂真身从##l%d##n星升级至##l%d##n星？",itemConfig.name, newGradeConfig.soul_gem_count, newGradeConfig.money, heroInfo.name, self._grade, self._grade+1 ) 
	-- end
 --    app:alert({content = content, title = "系统提示", callback = function(callType)
 --            if callType == ALERT_TYPE.CONFIRM then
 --                callback()
 --            end
 --        end, isAnimation = true, colorful = true}, true, true)
 	callback()
end

-- 一键添加
function QUIWidgetArtifactInfoGrade:_onTriggerAutoAdd()
	app.sound:playSound("common_small")

	local callback = function()
		self:setInfo(self._actorId)
	end

	app:getNavigationManager():pushViewController(app.middleLayer, {
		uiType = QUIViewController.TYPE_DIALOG, 
		uiClass = "QUIDialogArtifactAutoGrade", 
		options = {
			actorId = self._actorId, 
			artifactId = self._artifactId, 
			curGrade = self._grade, 
			callback = callback,
			autoAddInfo = self._autoAddInfo}
		},{
			isPopCurrentDialog = false
		}
	)
end

function QUIWidgetArtifactInfoGrade:_onTriggerInfo()
	app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogArtifactSkill", 
        options = {actorId = self._actorId}},{isPopCurrentDialog = false})
end

return QUIWidgetArtifactInfoGrade