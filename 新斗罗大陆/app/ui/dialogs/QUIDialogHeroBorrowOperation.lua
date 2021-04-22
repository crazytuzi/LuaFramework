
local QUIDialog = import(".QUIDialog")
local QUIDialogHeroBorrowOperation = class("QUIDialogHeroBorrowOperation", QUIDialog)
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetHeroBorrowOperation = import("..widgets.QUIWidgetHeroBorrowOperation")
local QListView = import("...views.QListView")


QUIDialogHeroBorrowOperation.TAB_TYPE1 = 1
QUIDialogHeroBorrowOperation.TAB_TYPE2 = 2
QUIDialogHeroBorrowOperation.TAB_TYPE3 = 3


function QUIDialogHeroBorrowOperation:ctor(options)
	local ccbFile = "ccb/Dialog_HeroBorrow_Operation.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerType1", callback = handler(self, self._onTriggerType1)},
		{ccbCallbackName = "onTriggerType2", callback = handler(self, self._onTriggerType2)},
		{ccbCallbackName = "onTriggerType3", callback = handler(self, self._onTriggerType3)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerIgnore", callback = handler(self, self._onTriggerIgnore)},
		{ccbCallbackName = "onTriggerOneKey", callback = handler(self, self._onTriggerOneKey)},
	}
	QUIDialogHeroBorrowOperation.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self._selectTab = QUIDialogHeroBorrowOperation.TAB_TYPE1
	self._type =QUIWidgetHeroBorrowOperation.INFO_TYPE_BORROW_IN
    -- q.setButtonEnableShadow(self._ccbOwner.btn_type1)
    -- q.setButtonEnableShadow(self._ccbOwner.btn_type2)
    -- q.setButtonEnableShadow(self._ccbOwner.btn_type3)
    q.setButtonEnableShadow(self._ccbOwner.btn_onekey)
    q.setButtonEnableShadow(self._ccbOwner.btn_ignore)
	self:selectTabs(true)
	self:initApplyForType(handler(self, self.updateRedTips))

end

function QUIDialogHeroBorrowOperation:viewDidAppear()
	QUIDialogHeroBorrowOperation.super.viewDidAppear(self)
	self:setInfo()
	-- self:selectTabs()
end

function QUIDialogHeroBorrowOperation:viewWillDisappear()
	QUIDialogHeroBorrowOperation.super.viewWillDisappear(self)
end

function QUIDialogHeroBorrowOperation:viewAnimationInHandler()
	--代码
	self:initListView()
end


function QUIDialogHeroBorrowOperation:updateRedTips()
	local count = remote.offerreward:getBorrowInfosCountNum()
	self._ccbOwner.sp_type2_tips:setVisible(count > 0)
end


function QUIDialogHeroBorrowOperation:resetAll()
	self._ccbOwner.btn_type1:setEnabled(true)
	self._ccbOwner.btn_type1:setHighlighted(false)
	self._ccbOwner.btn_type2:setEnabled(true)
	self._ccbOwner.btn_type2:setHighlighted(false)
	self._ccbOwner.btn_type3:setEnabled(true)
	self._ccbOwner.btn_type3:setHighlighted(false)	
end



function QUIDialogHeroBorrowOperation:selectTabs(_request)
	self:resetAll()
	self._data = {}
	local callback = function()
		if not self:safeCheck() then
			return
		end

		if self._selectTab == QUIDialogHeroBorrowOperation.TAB_TYPE1 then
			self._data = remote.offerreward:getBorrowInInfos()
		elseif self._selectTab == QUIDialogHeroBorrowOperation.TAB_TYPE2 then
			self._data = remote.offerreward:getBorrowInfo()
		else
			self._data = remote.offerreward:getBorrowOutInfos()
		end

		if self._listView then
			self._listView:clear()
		end
		self:initListView()
		self:updateRedTips()
	end

	if self._selectTab == QUIDialogHeroBorrowOperation.TAB_TYPE1 then
		self._ccbOwner.btn_type1:setEnabled(false)
		self._ccbOwner.btn_type1:setHighlighted(true)
		if _request then
			self:initBorrowType(callback)
		else
			callback()
		end
		self._ccbOwner.tf_no_content:setString("魂师大人，您未借用宗门玩家的魂师～！")
	elseif self._selectTab == QUIDialogHeroBorrowOperation.TAB_TYPE2 then
		self._ccbOwner.btn_type2:setEnabled(false)
		self._ccbOwner.btn_type2:setHighlighted(true)
		if _request then
			self:initApplyForType(callback)
		else
			callback()
		end		
		self._ccbOwner.tf_no_content:setString("魂师大人，宗门玩家未向您借用魂师～！")
	elseif self._selectTab == QUIDialogHeroBorrowOperation.TAB_TYPE3 then
		self._ccbOwner.btn_type3:setEnabled(false)
		self._ccbOwner.btn_type3:setHighlighted(true)
		if _request then
			self:initLendType(callback)
		else
			callback()
		end				
		self._ccbOwner.tf_no_content:setString("魂师大人，您未借出魂师～！")
	end

	for i=1,3 do
		self._ccbOwner["node_type"..i]:setVisible(i == self._selectTab)
	end
end

function QUIDialogHeroBorrowOperation:setInfo()
end

function QUIDialogHeroBorrowOperation:initBorrowType(callback)
	remote.offerreward:offerRewardGetBorrowInInfo(function(data)
			callback()
		end)
end

function QUIDialogHeroBorrowOperation:initApplyForType(callback)
	remote.offerreward:offerRewardGetApplyInfo(function(data)
			callback()
		end)
end

function QUIDialogHeroBorrowOperation:initLendType(callback)
	remote.offerreward:offerRewardGetBorrowOutInfo(function(data)
			callback()
		end)
end

function QUIDialogHeroBorrowOperation:initListView()
	self._ccbOwner.node_no:setVisible(not next(self._data))

	if self._selectTab == QUIDialogHeroBorrowOperation.TAB_TYPE2 then
		self._ccbOwner.sheet_layout:setPositionY(-378)
		self._ccbOwner.sheet_layout:setContentSize(CCSize(690,380))
		self._ccbOwner.sheet_bg_short:setVisible(true)
		self._ccbOwner.sheet_bg_long:setVisible(false)
	else
		self._ccbOwner.sheet_layout:setPositionY(-437)
		self._ccbOwner.sheet_layout:setContentSize(CCSize(690,440))
		self._ccbOwner.sheet_bg_short:setVisible(false)
		self._ccbOwner.sheet_bg_long:setVisible(true)
	end
	if self._listView then
		self._listView:setContentSize(self._ccbOwner.sheet_layout:getContentSize())
		self._listView:resetTouchRect()
	end

	if not self._listView then
		local cfg = {
			renderItemCallBack = handler(self, self._renderItemFunc),
	        curOriginOffset = 0,
	        isVertical = true,
	        enableShadow = true,
	      	ignoreCanDrag = true,
	      	spaceY = -8,
	        totalNumber = #self._data,
		}
		self._listView = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else
		self._listView:reload({totalNumber = #self._data})
	end
end

function QUIDialogHeroBorrowOperation:_renderItemFunc( list, index, info )
    local isCacheNode = true
    local itemData = self._data[index]
    local item = list:getItemFromCache(self._selectTab)
    if not item then
 		item = QUIWidgetHeroBorrowOperation.new()
    	isCacheNode = false
    end
    item:setInfo(itemData, self._type)
    -- item:initGLLayer()
    info.tag = self._selectTab
    info.item = item
    info.size = item:getContentSize()

    list:registerBtnHandler(index, "btn_return", handler(self, self._onTriggerReturn))
    list:registerBtnHandler(index, "btn_borrow", handler(self, self._onTriggerBorrow))

    return isCacheNode
end

function QUIDialogHeroBorrowOperation:_onTriggerReturn(x, y, touchNode, listView )
	app.sound:playSound("common_switch")


    local touchIndex = listView:getCurTouchIndex()
   
    local item = listView:getItemByIndex(touchIndex)
    item:_onTriggerReturn(handler(self, self.selectTabs))
end


function QUIDialogHeroBorrowOperation:_onTriggerBorrow(x, y, touchNode, listView )
	app.sound:playSound("common_switch")
    local touchIndex = listView:getCurTouchIndex()
    local item = listView:getItemByIndex(touchIndex)
    item:_onTriggerBorrow(handler(self, self.selectTabs))
end



function QUIDialogHeroBorrowOperation:_onTriggerIgnore(event)
    app.sound:playSound("common_switch")
	if not next(self._data) then
		return 
	end    
	local  success = function ( )
		print("_onTriggerIgnore  clearAll")
		-- remote.offerreward:clearBorrowInfo()
		app.tip:floatTip("魂师申请已全部忽略~")
		self:selectTabs()
	end
	remote.offerreward:offerRewardRefuseRequest({},success)

end

function QUIDialogHeroBorrowOperation:_onTriggerOneKey(event)
    app.sound:playSound("common_switch")
	if not next(self._data) then
		return 
	end   	
	local  success = function ( )
		print("_onTriggerOneKey  clearAll")
		-- remote.offerreward:clearBorrowInfo()
		app.tip:floatTip("一键借出成功~")
		self:selectTabs()
	end 
	remote.offerreward:offerRewardPromissRequest({},success)

end


function QUIDialogHeroBorrowOperation:_onTriggerType1(event)
	if self._selectTab == QUIDialogHeroBorrowOperation.TAB_TYPE1 then return end
    app.sound:playSound("common_switch")
	self._selectTab = QUIDialogHeroBorrowOperation.TAB_TYPE1
	self._type =QUIWidgetHeroBorrowOperation.INFO_TYPE_BORROW_IN

	self:selectTabs(true)
end

function QUIDialogHeroBorrowOperation:_onTriggerType2(event)
	if self._selectTab == QUIDialogHeroBorrowOperation.TAB_TYPE2 then return end
    app.sound:playSound("common_switch")
	self._selectTab = QUIDialogHeroBorrowOperation.TAB_TYPE2
	self._type =QUIWidgetHeroBorrowOperation.INFO_TYPE_APPLY
	self:selectTabs(true)
end

function QUIDialogHeroBorrowOperation:_onTriggerType3(event)
	if self._selectTab == QUIDialogHeroBorrowOperation.TAB_TYPE3 then return end
    app.sound:playSound("common_switch")
	self._selectTab = QUIDialogHeroBorrowOperation.TAB_TYPE3
	self._type =QUIWidgetHeroBorrowOperation.INFO_TYPE_BORROW_OUT
	self:selectTabs(true)
end

function QUIDialogHeroBorrowOperation:_onTriggerClose()
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

return QUIDialogHeroBorrowOperation