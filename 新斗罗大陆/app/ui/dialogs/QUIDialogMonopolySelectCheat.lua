--
-- Author: Kumo.Wang
-- 大富翁遥控骰子选择界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMonopolySelectCheat = class("QUIDialogMonopolySelectCheat", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QQuickWay = import("...utils.QQuickWay")
local QListView = import("...views.QListView")

local QUIWidgetMonopolySelectCheatCell = import("..widgets.QUIWidgetMonopolySelectCheatCell")

function QUIDialogMonopolySelectCheat:ctor(options)
	local ccbFile = "ccb/Dialog_monopoly_cheat_select.ccbi"
	local callBack = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
	}
	QUIDialogMonopolySelectCheat.super.ctor(self, ccbFile, callBack, options)

	self._ccbOwner.frame_tf_title:setString("遥控骰子")

    q.setButtonEnableShadow(self._ccbOwner.btn_OK)

	self.isAnimation = true --是否动画显示

    self:_init()
end

function QUIDialogMonopolySelectCheat:viewDidAppear()
	QUIDialogMonopolySelectCheat.super.viewDidAppear(self)
end

function QUIDialogMonopolySelectCheat:viewWillDisappear()
	QUIDialogMonopolySelectCheat.super.viewWillDisappear(self)
end

function QUIDialogMonopolySelectCheat:_init()
	self._configs = remote.monopoly.cheatItemInfo

	self:_initListView()
end

function QUIDialogMonopolySelectCheat:_initListView()
    if not self._listView then
	    local cfg = {
	        renderItemCallBack = handler(self, self.reandFunHandler),
	        isVertical = false,
	        totalNumber = #self._configs,
	        enableShadow = false,
	    }  
	    self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._listView:reload({totalNumber = #self._configs})
	end
	self._listView:setCanNotTouchMove(#self._configs > 3)
end

function QUIDialogMonopolySelectCheat:reandFunHandler( list, index, info )
    local isCacheNode = true
    local config = self._configs[index]
    local item = list:getItemFromCache()

    if not item then
        item = QUIWidgetMonopolySelectCheatCell.new()
        isCacheNode = false
    end

    item:setInfo(config)
    info.item = item
    info.size = item:getContentSize()
    item:addEventListener(QUIWidgetMonopolySelectCheatCell.Selected, handler(self, self._onSelectedCheat))
    list:registerBtnHandler(index, "btn_select", "_onTriggerSelect")
    
    return isCacheNode
end

function QUIDialogMonopolySelectCheat:_onSelectedCheat(...)
	local arg = {...}
	-- QPrintTable(arg)
	local index = 1
	while true do
		local item = self._listView:getItemByIndex(index)
		if item then
			item:setSelectState(false)
			index = index + 1
		else
			break
		end
	end
	arg[1].target:setSelectState(true)
	self._selectedItemId = arg[1].itemId
	-- print("QUIDialogMonopolySelectCheat:_onSelectedCheat(...)", self._selectedItemId)
end

function QUIDialogMonopolySelectCheat:_onTriggerOK()
	app.sound:playSound("common_small")
	if self._selectedItemId then
		local itemCount = remote.items:getItemsNumByID(self._selectedItemId)
		if itemCount > 0 then
			app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_SPECIFIC_CONTROLLER, nil, self)
            app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMonopolyCheat", options = {itemId = self._selectedItemId}}, {isPopCurrentDialog = true})
		else
			app.tip:floatTip("道具不足")
		end
	else
		app.tip:floatTip("尚未选择")
	end
end

function QUIDialogMonopolySelectCheat:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogMonopolySelectCheat:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
	if e then
		app.sound:playSound("common_small")
	end
	self:playEffectOut()
end

function QUIDialogMonopolySelectCheat:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_SPECIFIC_CONTROLLER, nil, self)
end

return QUIDialogMonopolySelectCheat