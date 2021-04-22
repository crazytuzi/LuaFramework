--
-- Author: Kumo.Wang
-- Date: Wed Mar  9 00:33:05 2016
--

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSocietyDungeonRuleNew = class("QUIDialogSocietyDungeonRuleNew", QUIDialog)

local QUIWidgetSunwarRuleTopHead = import("..widgets.QUIWidgetSunwarRuleTopHead")
local QUIWidgetSunwarRuleSeparator = import("..widgets.QUIWidgetSunwarRuleSeparator")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
local QListView = import("...views.QListView")
local QNavigationController = import("...controllers.QNavigationController")

function QUIDialogSocietyDungeonRuleNew:ctor( option )
    local ccbFile = "ccb/Dialog_SunWar_Rule.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogSocietyDungeonRuleNew.super.ctor(self,ccbFile,callBacks,options)
    self._ccbOwner.frame_tf_title:setString("帮 助")
    self:initData()
    self:initListView()
end

function QUIDialogSocietyDungeonRuleNew:initData( )
    -- body
    self._data = {}
    -- table.insert(self._data, {oType = "topHead"})
    -- table.insert(self._data, {oType = "separator",name = "军团副本规则"})
    table.insert(self._data,{oType = "describe", info = {
        helpType = "sociaty_chapter_help",
        }})
end

function QUIDialogSocietyDungeonRuleNew:initListView( )
    -- body
    local cfg = {
        renderItemCallBack = function( list, index, info )
          -- body
            local isCacheNode = true
            local data = self._data[index]
            local item = list:getItemFromCache(data.oType)
            if not item then
                if data.oType == "topHead" then
                    item = QUIWidgetSunwarRuleTopHead.new()
                elseif data.oType == "describe" then
                    item = QUIWidgetHelpDescribe.new()
                elseif data.oType == "separator" then
                    item = QUIWidgetSunwarRuleSeparator.new()
                end
                isCacheNode = false
            end
            if data.oType == "describe" then
                item:setInfo(data.info or {}, data.customStr)
            else
                item:setInfo(data)
            end
            info.item = item
            info.size = item:getContentSize()
            info.tag = data.oType
            return isCacheNode
        end,
        totalNumber = #self._data,
        enableShadow = false,
    }
    self._listView = QListView.new(self._ccbOwner.listView,cfg)
end

function QUIDialogSocietyDungeonRuleNew:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogSocietyDungeonRuleNew:_onTriggerClose(e)
    if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
    app.sound:playSound("common_cancel")
    self:playEffectOut()
end

function QUIDialogSocietyDungeonRuleNew:onTriggerBackHandler(tag)
    self:_onTriggerBack()
end

function QUIDialogSocietyDungeonRuleNew:_backClickHandler()
    self:_onTriggerClose()
end

return QUIDialogSocietyDungeonRuleNew