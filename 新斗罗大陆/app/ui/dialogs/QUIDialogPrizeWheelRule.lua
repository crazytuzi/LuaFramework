-- @Author: zhouxiaoshu
-- @Date:   2019-08-16 12:03:13
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-08-16 12:03:58
local QUIDialogBaseHelp = import(".QUIDialogBaseHelp")
local QUIDialogPrizeWheelRule = class("QUIDialogPrizeWheelRule", QUIDialogBaseHelp)
local QListView = import("...views.QListView")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")

--初始化
function QUIDialogPrizeWheelRule:ctor(options)
    QUIDialogPrizeWheelRule.super.ctor(self,options)
end

function QUIDialogPrizeWheelRule:initData( options )
    -- body
    options = options or {}
    local prizeWheelRound = remote.activityRounds:getPrizaWheel()
    local helpType = prizeWheelRound:getCurDialogHelpType()
    self._data = {}
    table.insert(self._data, {oType = "describe", info = {helpType = helpType}})    

    -- body
    if not self._listViewLayout then
        local cfg = {
            renderItemCallBack = function( list, index, info )
                -- body
                local isCacheNode = true
                local itemData = self._data[index]
                local item = list:getItemFromCache(itemData.oType)
                if not item then
                    if itemData.oType == "describe" then
                        item = QUIWidgetHelpDescribe.new()
                    end
                    isCacheNode = false
                end
                if itemData.oType == "describe" then
                    item:setInfo(itemData.info)
                end
               
                info.item = item
                info.size = item:getContentSize()
                return isCacheNode
            end,
            curOriginOffset = 15,
            enableShadow = false,
            ignoreCanDrag = true,
            totalNumber = #self._data,
        }
        self._listViewLayout = QListView.new(self._ccbOwner.sheet_layout,cfg)
    else

        self._listViewLayout:reload({#self._data})
    end
end

return QUIDialogPrizeWheelRule

