local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMountCombination = class("QUIDialogMountCombination", QUIDialog)

local QUIWidgetMountCombinationClient = import("..widgets.mount.QUIWidgetMountCombinationClient")
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")
local QActorProp = import("...models.QActorProp")
local QQuickWay = import("...utils.QQuickWay")
local QRichText = import("...utils.QRichText")

function QUIDialogMountCombination:ctor(options)
	local ccbFile = "ccb/Dialog_Weapon_tujian_11.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClickProp", callback = handler(self, self._onTriggerClickProp)},
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggerClickLeft)},
		{ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggerClickRight)},
        {ccbCallbackName = "onTriggerGenre", callback = handler(self, self._onTriggerGenre)},
	}
	QUIDialogMountCombination.super.ctor(self, ccbFile, callBacks, options)
  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page.topBar:showWithMount()
	CalculateUIBgSize(self._ccbOwner.node_sp,UI_VIEW_MIN_WIDTH)

    q.setButtonEnableShadow(self._ccbOwner.btn_genre)

    --全面屏适配
	self._ccbOwner.sheet:setPositionX(-display.ui_width / 2)
	local size = self._ccbOwner.sheet_layout:getContentSize()
	size.width = display.ui_width
	self._ccbOwner.sheet_layout:setContentSize(size)

    self._ccbOwner.node_arrow:setVisible(false)
  	self._combinationBox = {}
  	self._combinationInfos = {}
	self._propInfo = {}
	self._curIndex = 1
	self._posY = self._ccbOwner.node_prop1:getPositionY()
end

function QUIDialogMountCombination:viewDidAppear()
	QUIDialogMountCombination.super.viewDidAppear(self)
  	self:addBackEvent(true)

  	self:initListView()
	self:setPropInfo()
end

function QUIDialogMountCombination:viewWillDisappear()
	QUIDialogMountCombination.super.viewWillDisappear(self)
	
	self:removeBackEvent()
end

function QUIDialogMountCombination:initListView()
	local combinationInfos = db:getMountCombinationInfo()
	local index = 1
	self._infos = {}
	for _, value in pairs(combinationInfos) do
		if not db:checkHeroShields(value.id,SHIELDS_TYPE.MOUNT_COMBINATION) then
			self._infos[index] = value
			self._infos[index].prop = self:calculateCombinationProp(self._infos[index])
			if remote.mount:checkMountCombination(self._infos[index]) then
				self:calculateAllProp(self._infos[index].prop)
			end
			index = index + 1
		end
	end
	table.sort( self._infos, function(a, b) return a.id < b.id end )

	if not self._listView then
		local cfg = {
			renderItemCallBack = handler(self, self._renderItemFunc),
	        isVertical = false,
	        spaceX = 0,
	        enableShadow = false,
	      	ignoreCanDrag = true,
	        totalNumber = #self._infos,
		}
		self._listView = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else
		self._listView:reload({totalNumber = #self._infos})
	end
end

function QUIDialogMountCombination:_renderItemFunc( list, index, info )
    -- body
    local isCacheNode = true
    local itemData = self._infos[index]
    local item = list:getItemFromCache(itemData.oType)
    if not item then
		item = QUIWidgetMountCombinationClient.new()
		item:addEventListener(QUIWidgetMountCombinationClient.EVENT_CLICK_CARD, handler(self, self._clickCard))
    	isCacheNode = false
    end
    item:setInfo(itemData)
    info.item = item
    info.size = item:getContentSize()
    self._cellSize = info.size

    list:registerBtnHandler(index, "btn_left", "_onTriggerClickLeft")
    list:registerBtnHandler(index, "btn_right", "_onTriggerClickRight")
   
    return isCacheNode
end

function QUIDialogMountCombination:getPropTips(propInfo)
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

function QUIDialogMountCombination:setPropInfo()	
	local propInfo = {}
	local propInfo1 = {}
	local propInfo2 = {}
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
		self._ccbOwner.node_prop1:setPositionY(self._ccbOwner.node_prop1:getPositionY()-30)
	elseif index == 2 then
		self._ccbOwner.node_prop1:setPositionY(self._ccbOwner.node_prop1:getPositionY()-10)
		self._ccbOwner.node_prop2:setPositionY(self._ccbOwner.node_prop2:getPositionY()-15)
	end
end

function QUIDialogMountCombination:calculateCombinationProp(combination)
	local propInfo = {}
	local index = 1
	for name, filed in pairs(QActorProp._field) do
		if combination[name] ~= nil then
			propInfo[index] = {}
			propInfo[index].key = name
			propInfo[index].name = filed.name
			propInfo[index].isPercent = filed.isPercent
			propInfo[index].value = combination[name]
			index = index + 1
		end
	end
	return propInfo
end

function QUIDialogMountCombination:calculateAllProp(prop)
	for i = 1, #prop do
		if self._propInfo[prop[i].key] == nil then
			self._propInfo[prop[i].key] = {}
			self._propInfo[prop[i].key].name = prop[i].name
			self._propInfo[prop[i].key].value = prop[i].value
		else
			self._propInfo[prop[i].key].value = self._propInfo[prop[i].key].value + prop[i].value
		end
	end
end

------------------------------ event listener --------------------------------

function QUIDialogMountCombination:_clickCard(event)
	if event.mountId == nil or self._isMove then return end

	app.tip:itemTip(ITEM_TYPE.ZUOQI, event.mountId, true, {showDress = false ,unShowBox = true})
end

function QUIDialogMountCombination:_onScrollViewMoving()
	self._isMove = true
end

function QUIDialogMountCombination:_onScrollViewBegan()
	self._isMove = false
end

function QUIDialogMountCombination:_onTriggerClickLeft()
	-- app.sound:playSound("common_small")

	-- self:moveSrollView("left")
end

function QUIDialogMountCombination:_onTriggerClickRight()
	-- app.sound:playSound("common_small")

	-- self:moveSrollView("right")
end

function QUIDialogMountCombination:_onTriggerGenre(event)
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPVPCalculateTip", 
        options = {}}, {isPopCurrentDialog = false})
end

function QUIDialogMountCombination:setContentInfo(curIndex)
	self._ccbOwner.btn_left:setVisible(curIndex > 0)
	self._ccbOwner.arrowLeft:setVisible(curIndex > 0)
	self._ccbOwner.btn_right:setVisible(curIndex < #self._infos)
	self._ccbOwner.arrowRight:setVisible(curIndex < #self._infos)
end

--移动动画
function QUIDialogMountCombination:moveSrollView(direction)
	self.moveIsFinished = false

	self._curIndex = self._listView._endIndex
	if direction == "right" then
		self._curIndex = self._curIndex + 2
	else
		self._curIndex = self._curIndex - 2
	end
	if self._curIndex < 0 then
		self._curIndex = 0
	end
	if self._curIndex > #self._infos then
		self._curIndex = #self._infos
	end

	self._listView:startScrollToIndex(self._curIndex, true, 100, function()
		self.moveIsFinished = true
		self:setContentInfo(self._curIndex)
	end, 0)
end

function QUIDialogMountCombination:onTriggerBackHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogMountCombination