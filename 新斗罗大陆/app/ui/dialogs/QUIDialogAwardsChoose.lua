local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogAwardsChoose = class("QUIDialogAwardsChoose", QUIDialog)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetAwardsChoose = import("..widgets.QUIWidgetAwardsChoose")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")

QUIDialogAwardsChoose.EVENT_CHOOSE = "EVENT_CHOOSE"
QUIDialogAwardsChoose.EVENT_NO_CHOOSE = "EVENT_NO_CHOOSE"

function QUIDialogAwardsChoose:ctor(options)
	local ccbFile = "ccb/Dialog_Archaeology_AwardChoose.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerOK", callback = handler(self, QUIDialogAwardsChoose._onTriggerOK)},
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogAwardsChoose._onTriggerClose)},
        {ccbCallbackName = "onTriggerChoose", callback = handler(self, QUIDialogAwardsChoose._onTriggerChoose)},
    }
    QUIDialogAwardsChoose.super.ctor(self, ccbFile, callBacks, options)
    cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self.isAnimation = true --是否动画显示
	q.setButtonEnableShadow(self._ccbOwner.bt_ok)
	self._options = options
    self._callBackFun = options.callBack
    self._awardIndex = options.award_index
    self._archaeologyId = options.archaeologyId or 0
    self._isChoosed = false
    self._itemId = 0
	self._data = {}

	self:_init()
	self:initListView()
end

function QUIDialogAwardsChoose:viewDidAppear()
	QUIDialogAwardsChoose.super.viewDidAppear(self)
end

function QUIDialogAwardsChoose:viewWillDisappear()
  	QUIDialogAwardsChoose.super.viewWillDisappear(self)
end

function QUIDialogAwardsChoose:_init()
	local lastID = remote.archaeology:getLastEnableFragmentID()
	self._isCanGet = self._archaeologyId <= lastID
	
	if self._isCanGet then
		self._ccbOwner.frame_tf_title:setString("选择奖励")
		self._ccbOwner.tf_explain:setString("以下奖励中选取一个")
		self._ccbOwner.btn_ok:setVisible(true)
	else
		self._ccbOwner.frame_tf_title:setString("奖励预览")
		self._ccbOwner.tf_explain:setString("点亮斗罗历史后可选择其中一个奖励")
		self._ccbOwner.btn_ok:setVisible(false)
	end

	local luckyDrawConfig = db:getLuckyDraw( self._awardIndex ) or {}
	local index = 1
	while true do 
		if luckyDrawConfig["id_" .. index] then
			local info = {id = luckyDrawConfig["id_" .. index], num = luckyDrawConfig["num_" .. index], type = luckyDrawConfig["type_" .. index]}
			table.insert(self._data, info)
			index = index + 1
		else
			break
		end
	end
end

function QUIDialogAwardsChoose:initListView()
	printTable(self._data)
	if not self._listView then
		local cfg = {
			renderItemCallBack = handler(self, self._renderItemFunc),
	        curOriginOffset = 10,
	        isVertical = false,
	        contentOffsetY = -7,
	        spaceX = 15,
	        enableShadow = false,
	      	ignoreCanDrag = true,
	        totalNumber = #self._data,
		}
		self._listView = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else
		self._listView:refreshData()
	end
end

function QUIDialogAwardsChoose:_renderItemFunc( list, index, info )
    -- body
    local isCacheNode = true
    local itemData = self._data[index]
    local item = list:getItemFromCache()
    if not item then
    	item = QUIWidgetAwardsChoose.new()
		item:addEventListener(QUIWidgetAwardsChoose.EVENT_CLICK_CHOOSE, handler(self, self.itemClickHandler))
    	isCacheNode = false
    end
    item:setInfo(itemData, self._isCanGet)
    item:setSelectId(self._itemId)
    info.item = item
    info.size = item:getContentSize()

	list:registerBtnHandler(index, "btn_click", "_onTriggerChoose")
    list:registerItemBoxPrompt(index, 1, item._itemBox, -1)

    return isCacheNode
end

function QUIDialogAwardsChoose:_onTriggerOK()
	app.sound:playSound("common_confirm")
	if self._itemId == 0 then
		app.tip:floatTip("请选择")
		return
	end

	if self._archaeologyId ~= 0 then
		self._isChoosed = true
		self:_onTriggerClose()
	else
		print("考古奖励选择结果有误，拒绝向后台发送请求，请检查，数据如下：", self._archaeologyId, self._itemId)
	end
end

function QUIDialogAwardsChoose:itemClickHandler( event )
	app.sound:playSound("common_switch")
	if not event.info or not self._isCanGet then
		return
	end
	self._itemId = event.info.id
	self:initListView()
end

function QUIDialogAwardsChoose:_onTriggerClose()
	self:playEffectOut()
end

function QUIDialogAwardsChoose:viewAnimationOutHandler()
	self:popSelf()
	if self._isChoosed then
		self:dispatchEvent( { name = QUIDialogAwardsChoose.EVENT_CHOOSE, archaeologyId = self._archaeologyId, itemId = self._itemId} ) 
	else
		self:dispatchEvent( { name = QUIDialogAwardsChoose.EVENT_NO_CHOOSE, archaeologyId = self._archaeologyId } ) 
	end

	local callback = self._callBackFun
    if callback ~= nil then
    	callback()
    end

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page.class.__cname == "QUIPageMainMenu" then
		page:checkGuiad()
	end
end

return QUIDialogAwardsChoose