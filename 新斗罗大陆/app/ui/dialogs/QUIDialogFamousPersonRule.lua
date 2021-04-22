--
-- Author: Kumo.Wang
-- Date: Wed Mar  9 00:33:05 2016
-- 名人堂帮助
--

local QUIDialogBaseHelp = import(".QUIDialogBaseHelp")
local QUIDialogFamousPersonRule = class("QUIDialogFamousPersonRule", QUIDialogBaseHelp)
local QListView = import("...views.QListView")
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
local QNavigationController = import("...controllers.QNavigationController")

function QUIDialogFamousPersonRule:ctor(options)
    QUIDialogFamousPersonRule.super.ctor(self,options)
end

function QUIDialogFamousPersonRule:initData( options )
    options = options or {}

    local data = {}
    self._data = data
    table.insert(self._data,{oType = "describe", info = {helpType = "mingrentang_help"}})
    table.insert(self._data,{oType = "rankInfo"})

    if not self._listViewLayout then
        local cfg = {
            renderItemCallBack = function( list, index, info )
                local isCacheNode = true
                local itemData = self._data[index]
                local item = list:getItemFromCache(itemData.oType)
                if not item then
                    if itemData.oType == "describe" then
                        item = QUIWidgetHelpDescribe.new()
                    elseif itemData.oType == "rankInfo" then
                        item = self:getRankInfo()
                    end
                    isCacheNode = false
                end
                if itemData.oType == "describe" then
                    item:setInfo(itemData.info, itemData.title)
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

function QUIDialogFamousPersonRule:getRankInfo()
    local node = CCNode:create()
    local titleNode = QUIWidget.new("ccb/Widget_Base_Help_mingrentang.ccbi")
    titleNode:setPositionY(-10)
    node:addChild(titleNode)

    local rankConfig = db:getFamousPersonConfig()
    local rankInfos = {}
    for _, rankInfo in pairs(rankConfig) do
        table.insert(rankInfos, rankInfo)
    end
    table.sort(rankInfos, function(a, b)return a.rank < b.rank end)

    local height = 60
    for i, rankInfo in pairs(rankInfos) do
        local rankNode = QUIWidget.new("ccb/Widget_Base_Help_mingrentangrank.ccbi")
        rankNode._ccbOwner.tf_rank:setString("第"..rankInfo.rank.."名")
        rankNode._ccbOwner.tf_num1:setString(rankInfo.mrt_zl or "0")
        rankNode._ccbOwner.tf_num2:setString(rankInfo.mrt_dj or "0")
        rankNode._ccbOwner.tf_num3:setString(rankInfo.mrt_ptfb or "0")
        rankNode._ccbOwner.node_bg:setVisible( (i%2==0) ) 
        rankNode:setPositionY(-height)
        node:addChild(rankNode)

        height = height + 40
    end
    node:setContentSize(CCSize(100, height))

    return node
end

function QUIDialogFamousPersonRule:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.topLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogFamousPersonRule
