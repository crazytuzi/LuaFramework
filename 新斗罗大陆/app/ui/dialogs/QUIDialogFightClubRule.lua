--搏击俱乐部帮助，规则

local QUIDialogBaseHelp = import(".QUIDialogBaseHelp")
local QUIDialogFightClubRule = class("QUIDialogFightClubRule", QUIDialogBaseHelp)
local QListView = import("...views.QListView")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
local QUIWidgetBaseHelpTitle = import("..widgets.QUIWidgetBaseHelpTitle")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidget = import("..widgets.QUIWidget")
local QUIViewController = import("..QUIViewController")


--初始化
function QUIDialogFightClubRule:ctor(options)
    QUIDialogFightClubRule.super.ctor(self,options)

    self:setShowRule(true)
end

function QUIDialogFightClubRule:initData( options )
    -- body
    options = options or {}

    local data = {}
    self._data = data
    table.insert(data, {oType = "describe", info = {helpType = "help_fight_club"}})    
    table.insert(data, {oType = "empty", height = 10})
    table.insert(data, {oType = "title", info = {name = "本服每赛季排名奖励:"}})
    table.insert(data, {oType = "rank"})
    table.insert(data, {oType = "title", info = {name = "全服每赛季排名奖励:"}})
    table.insert(data, {oType = "rank2"})

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
                    elseif itemData.oType == "title" then
                        item = QUIWidgetBaseHelpTitle.new()
                    elseif itemData.oType == "rank" then
                        item = self:getCurRankNode()
                    elseif itemData.oType == "rank2" then
                        item = self:getAllRankNode()
                    elseif itemData.oType == "empty" then
                        item = QUIWidgetQlistviewItem.new()
                    end
                    isCacheNode = false
                end
                if itemData.oType == "describe" or itemData.oType == "title" then
                    item:setInfo(itemData.info)
                end
                if itemData.oType == "empty" then
                    item:setContentSize(CCSizeMake(0, itemData.height))
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

        self._listViewLayout:reload({totalNumber = #self._data})
    end
end

function QUIDialogFightClubRule:getCurRankNode()
    local node = CCNode:create()
    local _configs = db:getDivinationRankAwards("fight_club_benfu") 
    local configs = {}
    for _,v in ipairs(_configs) do
        if v.level_min <= remote.user.level and remote.user.level <= v.level_max then
            table.insert(configs, v)
        end
    end

    table.sort(configs, function (a,b)
        return a.rank < b.rank
    end)
    local height = 30
    for i = 1, #configs do
        local awards = {}
        local awardConfig = db:getLuckyDraw(configs[i].lucky_draw)
        if awardConfig ~= nil then
            local index = 1
            while true do
                local typeName = awardConfig["type_"..index]
                local id = awardConfig["id_"..index]
                local count = awardConfig["num_"..index]
                if typeName ~= nil then
                    table.insert(awards, {id = id, typeName = typeName, count = count})
                else
                    break
                end
                index = index + 1
            end
        end
        local widget = QUIWidget.new("ccb/Widget_RewardRules_client3.ccbi")

        if configs[i].rank > 3 and (configs[i-1].rank+1) ~= configs[i].rank then
            widget._ccbOwner.tf_1:setString(string.format("第%s~%s名: ", configs[i-1].rank+1,configs[i].rank))
        else
            widget._ccbOwner.tf_1:setString(string.format("第%s名: ", configs[i].rank))
        end
        widget._ccbOwner.rank:setVisible(false)
        widget._ccbOwner.tf_2:setVisible(false)
        
        local posX = 70
        if posX < 0 then posX = 0 end
        for i=1,5 do
            if awards[i] ~= nil then
                local itemBox = QUIWidgetItemsBox.new()
                itemBox:setGoodsInfo(awards[i].id, awards[i].typeName, 0)
                itemBox:setScale(0.5)
                widget._ccbOwner["item"..i]:addChild(itemBox)
                widget._ccbOwner["reward_nums"..i]:setVisible(true)
                widget._ccbOwner["reward_nums"..i]:setString("x"..awards[i].count)
                widget._ccbOwner["item"..i]:setPositionX(widget._ccbOwner["item"..i]:getPositionX() + posX)
                widget._ccbOwner["reward_nums"..i]:setPositionX(widget._ccbOwner["reward_nums"..i]:getPositionX() + posX)
            else
                widget._ccbOwner["reward_nums"..i]:setVisible(false)
            end
        end
        widget:setPosition(ccp(425, -height))
        node:addChild(widget)
        height = height + 40
    end
    node:setContentSize(CCSize(100,height))
    return node
end

function QUIDialogFightClubRule:getAllRankNode()
    local node = CCNode:create()
    local _configs = db:getDivinationRankAwards("fight_club_quanfu") 
    local heads = db:getHeroTitle(3)
    local configs = {}
    for _, reward in ipairs(_configs) do
        local head = nil
        for _,v in pairs(heads) do
            local conditions = string.split(v.condition, ",")
            if conditions and tonumber(conditions[2]) == reward.rank then 
                head = v
                break
            end
        end
        reward.head = head
        if reward.level_min <= remote.user.level and remote.user.level <= reward.level_max then
            table.insert(configs, reward)
        end
    end
    table.sort(configs, function (a,b)
        return a.rank < b.rank
    end)

    local height = 30
    for i = 1, #configs do
        local awards = {}
        local awardConfig = db:getLuckyDraw(configs[i].lucky_draw)
        if awardConfig ~= nil then
            local index = 1
            while true do
                local typeName = awardConfig["type_"..index]
                local id = awardConfig["id_"..index]
                local count = awardConfig["num_"..index]
                if typeName ~= nil then
                    table.insert(awards, {id = id, typeName = typeName, count = count})
                else
                    break
                end
                index = index + 1
            end
        end

        local widget = QUIWidget.new("ccb/Widget_RewardRules_client3.ccbi")

        if configs[i].rank > 3 and (configs[i-1].rank+1) ~= configs[i].rank then
            widget._ccbOwner.tf_1:setString(string.format("第%s~%s名: ", configs[i-1].rank+1,configs[i].rank))
        else
            widget._ccbOwner.tf_1:setString(string.format("第%s名: ", configs[i].rank))
        end
        widget._ccbOwner.rank:setVisible(false)
        widget._ccbOwner.tf_2:setVisible(false)
        
        local posX = 70
        local index = 1
        for i = 1, 5 do
            if awards[i] then
                local itemBox = QUIWidgetItemsBox.new()
                itemBox:setGoodsInfo(awards[i].id, awards[i].typeName, 0)
                itemBox:setScale(0.5)
                widget._ccbOwner["item"..i]:addChild(itemBox)
                widget._ccbOwner["reward_nums"..i]:setVisible(true)
                widget._ccbOwner["reward_nums"..i]:setString("x"..awards[i].count)
                widget._ccbOwner["item"..i]:setPositionX(widget._ccbOwner["item"..i]:getPositionX() + posX)
                widget._ccbOwner["reward_nums"..i]:setPositionX(widget._ccbOwner["reward_nums"..i]:getPositionX() + posX)
                index = i
            else
                widget._ccbOwner["reward_nums"..i]:setVisible(false)
            end
        end
        index = index + 1

        if configs[i].head then
            local icon = configs[i].head.icon
            local sp_head = CCSprite:createWithSpriteFrame(QSpriteFrameByPath(icon))
            sp_head:setAnchorPoint(ccp(0, 0.5))
            sp_head:setPositionX(-30)
            widget._ccbOwner["item"..index]:setPositionX(widget._ccbOwner["item"..index]:getPositionX() + posX)
            widget._ccbOwner["item"..index]:addChild(sp_head)
        end

        widget:setPosition(ccp(425, -height))
        node:addChild(widget)
        height = height + 40
    end
    node:setContentSize(CCSize(100,height))

    return node
end

function QUIDialogFightClubRule:showRule()
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFightClubTutorialDialog", options = {}}, {isPopCurrentDialog = false})
end

return QUIDialogFightClubRule

