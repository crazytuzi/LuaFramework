--
-- Author: Kumo.Wang
-- 大富翁仙品管理主界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMonopolyPickFlower = class("QUIDialogMonopolyPickFlower", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QQuickWay = import("...utils.QQuickWay")
local QListView = import("...views.QListView")

local QUIWidgetMonopolyPickFlower = import("..widgets.QUIWidgetMonopolyPickFlower")

function QUIDialogMonopolyPickFlower:ctor(options)
	local ccbFile = "ccb/Dialog_monopoly_collection.ccbi"
	local callBack = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogMonopolyPickFlower.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true --是否动画显示

	self._ccbOwner.frame_tf_title:setString("仙品管理")

    self:_init()
end

function QUIDialogMonopolyPickFlower:viewDidAppear()
	QUIDialogMonopolyPickFlower.super.viewDidAppear(self)
end

function QUIDialogMonopolyPickFlower:viewWillDisappear()
	QUIDialogMonopolyPickFlower.super.viewWillDisappear(self)
end

function QUIDialogMonopolyPickFlower:_init()
	self._configs = clone(remote.monopoly:getFlowerConfigs())

	table.sort(self._configs, function(a, b)
			local aConfig = remote.monopoly:getFlowerCurAndNextConfigById(a[1].id)
			local bConfig = remote.monopoly:getFlowerCurAndNextConfigById(b[1].id)
			if aConfig and bConfig then
				return tonumber(aConfig.level) > tonumber(bConfig.level)
			else
				return true
			end
		end)
	-- QPrintTable(self._configs)
	self:_initListView()
end

function QUIDialogMonopolyPickFlower:_initListView()
    if not self._listView then
	    local cfg = {
	        renderItemCallBack = handler(self, self.reandFunHandler),
	        -- ignoreCanDrag = true,
	        isVertical = false,
	        totalNumber = #self._configs,
	        spaceX = 15,
	        curOffset = 30,
	        enableShadow = false,
	    }  
	    self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._listView:reload({totalNumber = #self._configs})
	end
end

function QUIDialogMonopolyPickFlower:reandFunHandler( list, index, info )
    local isCacheNode = true
    local config = self._configs[index]
    local item = list:getItemFromCache()

    if not item then
        item = QUIWidgetMonopolyPickFlower.new()
        isCacheNode = false
    end

    item:setInfo(config)
    info.item = item
    info.size = item:getContentSize()

    list:registerBtnHandler(index, "btn_OK", "_onTriggerOK")
    
    return isCacheNode
end

function QUIDialogMonopolyPickFlower:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogMonopolyPickFlower:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_small")
	self:playEffectOut()
end

function QUIDialogMonopolyPickFlower:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_SPECIFIC_CONTROLLER, nil, self)
end

return QUIDialogMonopolyPickFlower