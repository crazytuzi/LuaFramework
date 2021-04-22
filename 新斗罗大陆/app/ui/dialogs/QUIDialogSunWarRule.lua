--
-- Author: Kumo.Wang
-- Date: Wed Mar  9 00:33:05 2016
--

local QUIDialogBaseHelp = import(".QUIDialogBaseHelp")
local QUIDialogSunWarRule = class("QUIDialogSunWarRule", QUIDialogBaseHelp)

local QUIWidgetSunwarRuleTopHead = import("..widgets.QUIWidgetSunwarRuleTopHead")
local QUIWidgetSunwarRuleSeparator = import("..widgets.QUIWidgetSunwarRuleSeparator")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")


local QListView = import("...views.QListView")
local QNavigationController = import("...controllers.QNavigationController")



function QUIDialogSunWarRule:ctor( option )
    QUIDialogSunWarRule.super.ctor(self, options)
end


function QUIDialogSunWarRule:initData( )
    -- body
    self._data = {}
    table.insert(self._data, {oType = "topHead"})
    table.insert(self._data, {oType = "separator",name = "战斗规则："})
    table.insert(self._data,{oType = "describe", info = {
        helpType = "battlefield_shuoming_2",
        }})
 

end

function QUIDialogSunWarRule:initListView( )
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
    self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
end

return QUIDialogSunWarRule