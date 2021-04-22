--
-- Author: qinyuanji
-- Date: 2015-04-02 17:14:49
--

--[[    
    文件名称：QUIDialogHeroRebornRule.lua
    创建时间：2016-07-30 19:21:53
    作者：nieming
    描述：QUIDialogHeroRebornRule
]]

local QUIDialogBaseHelp = import(".QUIDialogBaseHelp")
local QUIDialogHeroRebornRule = class("QUIDialogHeroRebornRule", QUIDialogBaseHelp)
local QListView = import("...views.QListView")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
--初始化
function QUIDialogHeroRebornRule:ctor(options)
    QUIDialogHeroRebornRule.super.ctor(self,options)
end

function QUIDialogHeroRebornRule:initData( options )
    -- body
    local options = self:getOptions() or {}
    self._type = options.type or 1 
    local helpDescribleStr = "rebirth_angel_"..self._type
    local data = {}
    self._data = data
    
    table.insert(data,{oType = "describe", info = {
        helpType = helpDescribleStr,
        }})

end

function QUIDialogHeroRebornRule:initListView( ... )
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
              
                item:setInfo(itemData.info or {}, itemData.customStr)
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

return QUIDialogHeroRebornRule

