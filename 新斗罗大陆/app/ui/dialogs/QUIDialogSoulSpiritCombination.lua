-- @Author: zhouxiaoshu
-- @Date:   2019-06-18 10:37:14
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-07-06 12:12:16

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSoulSpiritCombination = class("QUIDialogSoulSpiritCombination", QUIDialog)

local QUIWidgetSoulSpiritCombinationClient = import("..widgets.QUIWidgetSoulSpiritCombinationClient")
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")
local QActorProp = import("...models.QActorProp")
local QQuickWay = import("...utils.QQuickWay")
local QRichText = import("...utils.QRichText")

function QUIDialogSoulSpiritCombination:ctor(options)
	local ccbFile = "ccb/Dialog_SoulSpirit_tujian_11.ccbi"
	local callBacks = {
	}
	QUIDialogSoulSpiritCombination.super.ctor(self, ccbFile, callBacks, options)
  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page.topBar:showWithSoulSpirit()
	CalculateUIBgSize(self._ccbOwner.node_sp,UI_VIEW_MIN_WIDTH)
    --全面屏适配
	self._ccbOwner.sheet:setPositionX(-display.ui_width / 2)
	local size = self._ccbOwner.sheet_layout:getContentSize()
	size.width = display.ui_width
	self._ccbOwner.sheet_layout:setContentSize(size)
	self._ccbOwner.sp_left:setPositionX(0)
	self._ccbOwner.sp_right:setPositionX(size.width)

  	self._combinationInfos = {}
	self._propInfo = {}
	self._curIndex = 1
	self._posY1 = self._ccbOwner.node_prop1:getPositionY()
	self._posY2 = self._ccbOwner.node_prop2:getPositionY()
end

function QUIDialogSoulSpiritCombination:viewDidAppear()
	QUIDialogSoulSpiritCombination.super.viewDidAppear(self)
  	self:addBackEvent(true)

  	self:initListView()
	self:setPropInfo()
end

function QUIDialogSoulSpiritCombination:viewWillDisappear()
	QUIDialogSoulSpiritCombination.super.viewWillDisappear(self)
	
	self:removeBackEvent()
end

function QUIDialogSoulSpiritCombination:getSoulSpiritIds(combinationInfo)
	local conditionTbl = string.split(combinationInfo[1].condition, ";")
	local soulSpiritIds = {}
	for _, spiritInfo in pairs(conditionTbl) do
        local spiritInfoTbl = string.split(spiritInfo, "^")
        table.insert(soulSpiritIds, tonumber(spiritInfoTbl[1]))
    end
    return soulSpiritIds
end

function QUIDialogSoulSpiritCombination:initListView()
	local combinationInfos = db:getStaticByName("soul_tujian")
	local index = 1
	self._infos = {}
	self._propInfo = {}
	for id, combinationInfo in pairs(combinationInfos) do
		local soulSpiritIds = self:getSoulSpiritIds(combinationInfo)
		if soulSpiritIds[1] and not db:checkHeroShields(soulSpiritIds[1],SHIELDS_TYPE.SOUL_SPIRIT) then
			local grade = remote.soulSpirit:getCombinationGradeById(id)
			self._infos[index] = {}
			self._infos[index].id = id
			self._infos[index].grade = grade
			self._infos[index].soulSpiritIds = soulSpiritIds
			self._infos[index].combinationInfo = combinationInfo
			self._infos[index].prop = self:calculateCombinationProp(combinationInfo, grade)
			if grade > 0 then
				self:calculateAllProp(self._infos[index].prop)
			end
			index = index + 1
		end
	end
	table.sort( self._infos, function(a, b) return a.id < b.id end )

	if not self._listView then
		local cfg = {
			renderItemCallBack = handler(self, self._renderItemFunc),
	        curOriginOffset = 0,
	        isVertical = false,
	        spaceX = 0,
	        enableShadow = false,
	      	ignoreCanDrag = true,
	        totalNumber = #self._infos,
		}
		self._listView = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else
		self._listView:refreshData()
	end
end

function QUIDialogSoulSpiritCombination:_renderItemFunc( list, index, info )
    local isCacheNode = true
    local itemData = self._infos[index]
    local item = list:getItemFromCache(itemData.oType)
    if not item then
		item = QUIWidgetSoulSpiritCombinationClient.new()
		item:addEventListener(QUIWidgetSoulSpiritCombinationClient.EVENT_CLICK_CARD, handler(self, self._clickCard))
		item:addEventListener(QUIWidgetSoulSpiritCombinationClient.EVENT_CLICK_VISIT, handler(self, self._visitCard))
		item:addEventListener(QUIWidgetSoulSpiritCombinationClient.EVENT_CLICK_UPGRADE, handler(self, self._upgradeCard))
    	isCacheNode = false
    end
    item:setInfo(itemData)
    info.item = item
    info.size = item:getContentSize()
    self._cellSize = info.size

    list:registerBtnHandler(index, "btn_active", "_onTriggerClickActive", nil, true)
    list:registerBtnHandler(index, "btn_upgrade", "_onTriggerClickUpgrade", nil, true)
    list:registerBtnHandler(index, "btn_top", "_onTriggerClickTop", nil, true)
    list:registerBtnHandler(index, "btn_visit", "_onTriggerClickVisit", nil, true)
    list:registerBtnHandler(index, "btn_left", "_onTriggerClickLeft")
    list:registerBtnHandler(index, "btn_right", "_onTriggerClickRight")
   
    return isCacheNode
end

function QUIDialogSoulSpiritCombination:getPropTips(propInfo)
	local prop = {}
	local index = 1
	for _, value in pairs(propInfo) do
		prop[index] = value
		index = index + 1
	end

	local tips = {}
	for i = 1, #prop do
		local buffName = string.gsub(prop[i].name, "玩家对战", "PVP")
		table.insert(tips, {oType = "font", content = buffName, size = 20,color = UNITY_COLOR_LIGHT.white})
		table.insert(tips, {oType = "font", content = "+"..prop[i].value.."    ", size = 20,color = UNITY_COLOR_LIGHT.green})
	end

	local richText = QRichText.new(tips)
	richText:setAnchorPoint(ccp(0.5, 1))
	return richText
end

function QUIDialogSoulSpiritCombination:setPropInfo()	
	local propInfo = {}
	local propInfo1 = {}
	local propInfo2 = {}
	self._ccbOwner["node_prop1"]:removeAllChildren()
	self._ccbOwner["node_prop2"]:removeAllChildren()
	self._ccbOwner["node_prop3"]:removeAllChildren()
	
	for name, filed in pairs(QActorProp._field) do
		if self._propInfo[name] then
			if filed.isPercent then
				self._propInfo[name].value = (self._propInfo[name].value * 100).."%"
				local isFind = string.find(name, "pvp")
				if isFind then
					propInfo2[name] = self._propInfo[name]
				else
					propInfo1[name] = self._propInfo[name]
				end
			else
				propInfo[name] = self._propInfo[name]
			end
		end
	end

	local index = 0
	if next(propInfo) then
		index = index + 1
		local richText = self:getPropTips(propInfo)
		self._ccbOwner["node_prop"..index]:addChild(richText)
	end
	if next(propInfo1) then
		index = index + 1
		local richText = self:getPropTips(propInfo1)
		self._ccbOwner["node_prop"..index]:addChild(richText)
	end
	if next(propInfo2) then
		index = index + 1
		local richText = self:getPropTips(propInfo2)
		self._ccbOwner["node_prop"..index]:addChild(richText)
	end

	self._ccbOwner.tf_no_prop:setVisible(false)
	if index == 0 then
		self._ccbOwner.tf_no_prop:setVisible(true)
	elseif index == 1 then
		self._ccbOwner.node_prop1:setPositionY(self._posY1-30)
	elseif index == 2 then
		self._ccbOwner.node_prop1:setPositionY(self._posY1-10)
		self._ccbOwner.node_prop2:setPositionY(self._posY2-15)
	end
end

function QUIDialogSoulSpiritCombination:calculateCombinationProp(combinationInfo, grade)
	if grade == 0 then
		grade = 1
	end
	local combination = combinationInfo[grade]
	local propInfo = {}
	local index = 1
	for key, filed in pairs(QActorProp._field) do
		if combination[key] ~= nil then
			propInfo[index] = {}
			propInfo[index].key = key
			propInfo[index].name = filed.uiName or filed.name
			propInfo[index].isPercent = filed.isPercent
			propInfo[index].value = combination[key]
			index = index + 1
		end
	end
	return propInfo
end

function QUIDialogSoulSpiritCombination:calculateAllProp(prop)
	for i = 1, #prop do
		local name = prop[i].name
		if prop[i].key == "physical_damage_percent_attack" then
			name = "伤害提升"
		elseif prop[i].key == "physical_damage_percent_beattack_reduce" then 
			name = "伤害减免"
		end
		if prop[i].key == "magic_damage_percent_attack" or prop[i].key == "magic_damage_percent_beattack_reduce" then
		elseif self._propInfo[prop[i].key] == nil then
			self._propInfo[prop[i].key] = {}
			self._propInfo[prop[i].key].name = name
			self._propInfo[prop[i].key].value = prop[i].value
		else
			self._propInfo[prop[i].key].value = self._propInfo[prop[i].key].value + prop[i].value
		end
	end
end

function QUIDialogSoulSpiritCombination:_clickCard(event)
	if event.soulSpiritId == nil or self._isMove then return end
	app.tip:itemTip(ITEM_TYPE.SOUL_SPIRIT, event.soulSpiritId, true)
end

function QUIDialogSoulSpiritCombination:_visitCard(event)
	if event.combinationId == nil or self._isMove then return end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulSpiritCombinationProp", 
    	options={combinationId = event.combinationId, grade = event.grade}}, {isPopCurrentDialog = false})
end

function QUIDialogSoulSpiritCombination:_upgradeCard(event)
	if event.combinationId == nil or self._isMove then return end
	local callback = function()
		self:initListView()
		self:setPropInfo()
        remote.soulSpirit:dispatchEvent({name = remote.soulSpirit.EVENT_REFRESH_SOUL_SPIRIT})
    end
	remote.soulSpirit:soulSpiritCollectActiveRequest(event.combinationId, function()
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulSpiritCombinationSuccess", 
    		options={combinationId = event.combinationId, grade = event.grade + 1, callback = callback}}, {isPopCurrentDialog = false})
 	end)
end

function QUIDialogSoulSpiritCombination:onTriggerBackHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogSoulSpiritCombination