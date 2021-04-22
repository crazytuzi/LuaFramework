--
-- Author: Kumo.Wang
-- Date: Thu Mar 10 20:03:54 2016
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSunWarPromote = class("QUIDialogSunWarPromote", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

function QUIDialogSunWarPromote:ctor(options)
	local ccbFile = "ccb/Dialog_SunWar_Promote.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogSunWarPromote._onTriggerConfirm)},
    }
    QUIDialogSunWarPromote.super.ctor(self, ccbFile, callBacks, options)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page.topBar:setAllSound(false)

    local titleWidget = QUIWidgetTitelEffect.new()
    self._ccbOwner.node_title_effect:addChild(titleWidget)
    
    self._callBackFun = options.callBack

    local mapID = remote.sunWar:getCurrentMapID()
    local mapInfo = remote.sunWar:getMapInfoByMapID( mapID )
    -- printTable(mapInfo, mapID..">>>")
    self._ccbOwner.tf_level:setString("LV."..mapInfo.chapter)
    self._ccbOwner.tf_name:setString(mapInfo.name)
    local i = 1
    while(true) do
        if mapInfo["reward_type_"..i] then
            local node = self:_getIcon(mapInfo["reward_type_"..i], mapInfo["item_id_"..i], mapInfo["reward_num_"..i])
            self._ccbOwner["node_item_"..i]:addChild(node)
            -- self._ccbOwner["tf_text_"..i]:setString(mapInfo["reward_num_"..i])
            i = i + 1
        else
            break
        end
    end
end

--[[
    设置icon
]]
function QUIDialogSunWarPromote:_getIcon( type, id, count )
    local node = nil
    node = QUIWidgetItemsBox.new()
    node:setGoodsInfo(id, type, count)
    -- node:setScale(0.7)

    return node
end

function QUIDialogSunWarPromote:viewDidAppear()
	QUIDialogSunWarPromote.super.viewDidAppear(self)
end

function QUIDialogSunWarPromote:viewWillDisappear()
  	QUIDialogSunWarPromote.super.viewWillDisappear(self)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page.topBar:setAllSound(true)
end

function QUIDialogSunWarPromote:_backClickHandler()
	if self._isLock then return end
    self:_onTriggerConfirm()
end

function QUIDialogSunWarPromote:_onTriggerConfirm()
	if self._isShowing then return end
	
	local callback = self._callBackFun
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
    if callback ~= nil then
    	callback()
    end
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page.class.__cname == "QUIPageMainMenu" then
		printInfo("call QUIPageMainMenu function checkGuiad()")
		page:checkGuiad()
	end
end

return QUIDialogSunWarPromote