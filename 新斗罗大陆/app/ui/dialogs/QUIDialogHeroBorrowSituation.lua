--qinisyang
--单个魂师的借用情况

local QUIDialog = import(".QUIDialog")
local QUIDialogHeroBorrowSituation = class("QUIDialogHeroBorrowSituation", QUIDialog)
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetHeroBorrowOperation = import("..widgets.QUIWidgetHeroBorrowOperation")
local QListView = import("...views.QListView")

local max_borrow_num = 5
local max_can_borrow_num = 3

function QUIDialogHeroBorrowSituation:ctor(options)
	local ccbFile = "ccb/Dialog_HeroBorrow_Situation.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerHelp", callback = handler(self, self._onTriggerHelp)},
		{ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogHeroBorrowSituation.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
    self._ccbOwner.frame_tf_title:setVisible(false)

    q.setButtonEnableShadow(self._ccbOwner.btn_help)
    q.setButtonEnableShadow(self._ccbOwner.btn_ok)
    self._actorId = options.actorId or 0
    self._listView = nil
end

function QUIDialogHeroBorrowSituation:viewDidAppear()
	QUIDialogHeroBorrowSituation.super.viewDidAppear(self)
	self:handleData()
	self:setInfo()
	self:initListView()
end

function QUIDialogHeroBorrowSituation:viewWillDisappear()
	QUIDialogHeroBorrowSituation.super.viewWillDisappear(self)
end

function QUIDialogHeroBorrowSituation:viewAnimationInHandler()
	--代码
	self:initListView()
end

function QUIDialogHeroBorrowSituation:setInfo()
    self._ccbOwner.tf_title:setString("宗门魂师")
    -- local num = 5
    local sametime_num = max_borrow_num
    -- self._ccbOwner.tf_num:setString(num.."人")

    self._ccbOwner.tf_sametime_num:setString(max_can_borrow_num.."名")

    self:borrowCountHandler()
end

function QUIDialogHeroBorrowSituation:handleData()
	self._data = remote.offerreward:getRankingHeroInfos()
	self._alreadyBorrowedCount = remote.offerreward:getMyAlreadyBorrowedHeroNum()
end


function QUIDialogHeroBorrowSituation:initListView()
	self._ccbOwner.node_no:setVisible(not next(self._data))

	if self._listView then
		self._listView:setContentSize(self._ccbOwner.sheet_content:getContentSize())
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
		self._listView = QListView.new(self._ccbOwner.sheet_content,cfg)
	else
		self._listView:reload({totalNumber = #self._data})
	end
end

function QUIDialogHeroBorrowSituation:_renderItemFunc( list, index, info )
    -- body
    local isCacheNode = true
    local itemData = self._data[index]
    local item = list:getItemFromCache(self._selectTab)
    if not item then
 		item = QUIWidgetHeroBorrowOperation.new()
    	isCacheNode = false
    end
    item:setInfo(itemData, QUIWidgetHeroBorrowOperation.INFO_TYPE_APPLY_FOR ,self._actorId)
    -- item:initGLLayer()
    info.tag = self._selectTab
    info.item = item
    info.size = item:getContentSize()
    list:registerBtnHandler(index, "btn_select", handler(self, self._onTriggerSelect))
    list:registerBtnHandler(index, "btn_clickhead", handler(self, self._onTriggerClickHead))

    return isCacheNode
end

function QUIDialogHeroBorrowSituation:_onTriggerSelect(x, y, touchNode, listView )
	app.sound:playSound("common_switch")
    local touchIndex = listView:getCurTouchIndex()
    -- if self._data[touchIndex].selected == false and self._inviteCount >= 5 then
    -- 	app.tip:floatTip("最多一次邀请5人~")
    -- 	return 
    -- end

    local item = listView:getItemByIndex(touchIndex)
    local selected = item:getSelectState()
    if not selected then --从未选择到已经选择 需要判断
	    if max_borrow_num <= self._borrowCount then
		 	app.tip:floatTip("同一魂师最多向5名宗门成员发送申请~")
			return   	
	    end

	    if max_can_borrow_num <= self._alreadyBorrowedCount then
		 	app.tip:floatTip("最多借用3个宗门魂师~")
			return   	
	    end
	end
    
    item:_onTriggerSelect()
    self:borrowCountHandler()
end

function QUIDialogHeroBorrowSituation:_onTriggerClickHead(x, y, touchNode, listView )
	app.sound:playSound("common_switch")
    local touchIndex = listView:getCurTouchIndex()
    local item = listView:getItemByIndex(touchIndex)
    item:_onTriggerClickHead()
end



function QUIDialogHeroBorrowSituation:borrowCountHandler()
	self._borrowCount = remote.offerreward:getMyBorrowInHeroNum()
	for _,info in ipairs(self._data) do
		if info.selected == true then
			self._borrowCount = self._borrowCount + 1
		end
	end
	self._ccbOwner.tf_num:setString((max_borrow_num - self._borrowCount).."人")
end

function QUIDialogHeroBorrowSituation:_onTriggerOK()
	app.sound:playSound("common_small")

    if max_can_borrow_num <= self._alreadyBorrowedCount then
	 	app.tip:floatTip("最多借用3个宗门魂师~")
		return   	
    end
	
	local borrowInfo = {}
	for _,info in ipairs(self._data) do
		if info.selected == true then
			local bInfo = {}
			bInfo.actorId = self._actorId
			bInfo.userId = info.userId
			table.insert(borrowInfo,bInfo)
		end
	end
	if q.isEmpty(borrowInfo) then
	 	app.tip:floatTip("请选择您需要借用的魂师~")
		return   	
	end
 	remote.offerreward:offerRewardBorrowHeroRequest(borrowInfo,handler(self, self._onTriggerClose))
end

function QUIDialogHeroBorrowSituation:_backClickHandler()
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogHeroBorrowSituation:_onTriggerClose()
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogHeroBorrowSituation:_onTriggerHelp()
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogOfferRewardHelp", 
        options = {}}, {isPopCurrentDialog = true})
end

return QUIDialogHeroBorrowSituation