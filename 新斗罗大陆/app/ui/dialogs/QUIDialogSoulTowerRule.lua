-- @Author: DELL
-- @Date:   2020-04-16 12:44:10
-- @Last Modified by:   DELL
-- @Last Modified time: 2020-04-29 10:02:06
local QUIDialogBaseHelp = import("..dialogs.QUIDialogBaseHelp")
local QUIDialogSoulTowerRule = class("QUIDialogSoulTowerRule", QUIDialogBaseHelp)

local QListView = import("...views.QListView")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
--初始化
function QUIDialogSoulTowerRule:ctor(options)
    QUIDialogSoulTowerRule.super.ctor(self,options)
end

function QUIDialogSoulTowerRule:initData( options )
    -- body
    local options = self:getOptions() or {}

    local helpDescribleStr = "help_soul_tower"
    local data = {}
    self._data = data
    
    table.insert(data,{oType = "describe", info = {helpType = helpDescribleStr}})
    table.insert(data,{oType = "describe", info = { helpType = "help_soul_tower2"}})
    table.insert(data,{oType = "rank"})

end

function QUIDialogSoulTowerRule:initListView( ... )
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
                    elseif itemData.oType == "rank" then
                        item = self:getRankNode()                        
                    end
                    isCacheNode = false
                end
                if itemData.oType == "describe" then
                    item:setInfo(itemData.info or {}, itemData.customStr)
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

function QUIDialogSoulTowerRule:getRankNode()
    local node = CCNode:create()
    local rewards = remote.soultower:getSoultowerRankAwards()
    table.sort( rewards, function(a, b) 
    	return a.rank < b.rank 
    end )    
    local height = 30
    for _,reward in ipairs(rewards) do
        local awards = db:getluckyDrawById(reward.local_rank_reward) 
        local widget = QUIWidget.new("ccb/Widget_RewardRules_client3.ccbi")
        local rank = reward.rank
        if reward.rank ~= reward.rank_max then
            rank = reward.rank_max.."~"..rank
        end
        widget._ccbOwner.tf_1:setString(string.format("第%s名", rank))
        widget._ccbOwner.rank:setString("")
        widget._ccbOwner.tf_2:setString("")
        local posX = 70--widget._ccbOwner.tf_1:getContentSize().width - 70
        if posX < 0 then posX = 0 end
        for i=1,5 do
            if awards[i] ~= nil then
                local itemBox = QUIWidgetItemsBox.new()
                itemBox:setGoodsInfo(awards[i].id, awards[i].typeName, 0)
                itemBox:setScale(0.5)
                widget._ccbOwner["item"..i]:addChild(itemBox)
                widget._ccbOwner["reward_nums"..i]:setString("x "..awards[i].count)
                widget._ccbOwner["item"..i]:setPositionX(widget._ccbOwner["item"..i]:getPositionX() + posX)
                widget._ccbOwner["reward_nums"..i]:setPositionX(widget._ccbOwner["reward_nums"..i]:getPositionX() + posX)
            else
                widget._ccbOwner["reward_nums"..i]:setString("")
            end
        end
        widget:setPosition(ccp(430, -height))
        node:addChild(widget)
        height = height + 40
    end
    node:setContentSize(CCSize(100,height))
    return node
end

return QUIDialogSoulTowerRule
