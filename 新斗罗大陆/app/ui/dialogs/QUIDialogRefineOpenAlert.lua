--
-- Author: Kumo.Wang
-- Date: 
-- 神炼石开启格子提示框
--
local QUIDialog = import(".QUIDialog")
local QUIDialogRefineOpenAlert = class("QUIDialogRefineOpenAlert", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QQuickWay = import("...utils.QQuickWay")

function QUIDialogRefineOpenAlert:ctor(options)
	local ccbFile = "ccb/Dialog_refine_alertSystem.ccbi"
    local callBacks = {
    	{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},	
        {ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
    }
    QUIDialogRefineOpenAlert.super.ctor(self, ccbFile, callBacks, options)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setManyUIVisible()
    page.topBar:showWithRefine()
    self.isAnimation = true
    self._itemId = 5000003 -- 神炼石物品id
    self._actorId = options.actorId

    self._comfirmBack = options.comfirmBack
    self._callBack = options.callBack
    self._isComfirm = false

    local heroInfo = remote.herosUtil:getHeroByID( self._actorId ) 
	local openGrid = 0
	if heroInfo.refineHeroInfo and heroInfo.refineHeroInfo.openGrid then
		openGrid = heroInfo.refineHeroInfo.openGrid
	else
		local refineHeroInfo = remote.herosUtil:getHeroRefineInfoByID( self._actorId ) 
		if refineHeroInfo then
			openGrid = refineHeroInfo.openGrid
		end
	end

    self._price = QStaticDatabase.sharedDatabase():getConfigurationValue( "gezi_kaiqi"..(openGrid + 1) ) 
    self._ccbOwner.tf_price:setString(self._price.."个神炼石")
end

function QUIDialogRefineOpenAlert:viewDidAppear()
    QUIDialogRefineOpenAlert.super.viewDidAppear(self)

    self._remoteProxy = cc.EventProxy.new(remote.items)
    self._remoteProxy:addEventListener(remote.items.EVENT_ITEMS_UPDATE, handler(self, self.onEvent))

    self:_updateInfo()
end

function QUIDialogRefineOpenAlert:viewWillDisappear()
    QUIDialogRefineOpenAlert.super.viewWillDisappear(self)

    self._remoteProxy:removeAllEventListeners()
end

function QUIDialogRefineOpenAlert:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.topLayer, QNavigationController.POP_TOP_CONTROLLER)
	if self._isComfirm then
		if self._comfirmBack ~= nil then
			self._comfirmBack()
		end
	else
		if self._callBack ~= nil then
			self._callBack()
		end
	end
end

function QUIDialogRefineOpenAlert:onEvent( event )
	if not event or not event.name then return end

	if event.name == remote.items.EVENT_ITEMS_UPDATE then
		self:_updateInfo()
	end
end

function QUIDialogRefineOpenAlert:_onTriggerOK()
	app.sound:playSound("common_small")
	if self._canOpen then
		self._isComfirm = true
		app:getClient():refineHeroOpenGridRequest( self._actorId, function (response)
		        self:_onTriggerClose()
		    end)
	else
		QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, self._itemId, nil, nil, nil, "道具合成数量不足，请查看获取途径~")
	end
end

function QUIDialogRefineOpenAlert:_updateInfo()
	local count = remote.items:getItemsNumByID( self._itemId )
	self._ccbOwner.tf_shenlianshi:setString( count )
	if count >= self._price then
		self._canOpen = true
	else
		self._canOpen = false
	end
end

function QUIDialogRefineOpenAlert:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogRefineOpenAlert:_onTriggerClose()
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

return QUIDialogRefineOpenAlert