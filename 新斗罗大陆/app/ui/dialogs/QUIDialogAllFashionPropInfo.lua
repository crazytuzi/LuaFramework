--
-- Kumo.Wang
-- 時裝衣櫃属性总览界面
--
local QUIDialog = import(".QUIDialog")
local QUIDialogAllFashionPropInfo = class("QUIDialogAllFashionPropInfo", QUIDialog)

local QListView = import("...views.QListView")

local QUIWidgetAllFashionPropInfo = import("..widgets.QUIWidgetAllFashionPropInfo")

function QUIDialogAllFashionPropInfo:ctor(options)
    local ccbFile = "ccb/Dialog_Fashion_All_Prop_Info.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
	QUIDialogAllFashionPropInfo.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true

    self._ccbOwner.frame_tf_title:setString("属性总览")

    self:_init()
end

function QUIDialogAllFashionPropInfo:viewDidAppear()
    QUIDialogAllFashionPropInfo.super.viewDidAppear(self)
end

function QUIDialogAllFashionPropInfo:viewWillDisAppear()
    QUIDialogAllFashionPropInfo.super.viewWillDisAppear(self)
end

function QUIDialogAllFashionPropInfo:_init()
    self._data = {
        {index = 1, typeName = "皮肤属性", isSecondTitle = true, isShowAllProp = false},
        {index = 2, typeName = "宝录属性", isSecondTitle = false, isShowAllProp = false},
        {index = 3, typeName = "绘卷属性", isSecondTitle = false, isShowAllProp = false},
    }

    self:_initListView()
end

function QUIDialogAllFashionPropInfo:_initListView()
    if not self._data then return end

    if not self._listView then
        local cfg = {
            renderItemCallBack = handler(self, self._renderFunHandler),
            ignoreCanDrag = true,
            enableShadow = false,
            totalNumber = #self._data,
        }  
        self._listView = QListView.new(self._ccbOwner.node_list_view, cfg)
    else
        self._listView:refreshData()
    end
end

function QUIDialogAllFashionPropInfo:_renderFunHandler(list, index, info)
    local isCacheNode = true
    local itemData = self._data[index]
    local item = list:getItemFromCache()

    if not item then
        item = QUIWidgetAllFashionPropInfo.new()
        isCacheNode = false
    end
    info.item = item
    item:setInfo(itemData)
    info.size = item:getContentSize()

    return isCacheNode
end

function QUIDialogAllFashionPropInfo:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogAllFashionPropInfo:_onTriggerClose(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_close) == false then return end
  	app.sound:playSound("common_close")
    self:playEffectOut()
end

function QUIDialogAllFashionPropInfo:viewAnimationOutHandler()
    self:popSelf()

    if self._callback then
        self._callback()
    end
end

return QUIDialogAllFashionPropInfo