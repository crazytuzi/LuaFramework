--魂力试炼帮助，规则

local QUIDialogBaseHelp = import(".QUIDialogBaseHelp")
local QUIDialogSoulTrialHelp = class("QUIDialogSoulTrialHelp", QUIDialogBaseHelp)
local QListView = import("...views.QListView")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
local QUIWidgetBaseHelpTitle = import("..widgets.QUIWidgetBaseHelpTitle")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidget = import("..widgets.QUIWidget")


--初始化
function QUIDialogSoulTrialHelp:ctor(options)
    QUIDialogSoulTrialHelp.super.ctor(self,options)
end

function QUIDialogSoulTrialHelp:initData( options )
    -- body
    options = options or {}

    local data = {}
    self._data = data
    table.insert(data,{oType = "myRank"}) 
    table.insert(data,{oType = "describe", info = {helpType = "hunlishilian_1"}})
    table.insert(data,{oType = "empty", height = 10})
    table.insert(data,{oType = "describe", info = {helpType = "hunlishilian_2"}})
    table.insert(data,{oType = "empty", height = 10})
    table.insert(data,{oType = "describe", info = {helpType = "hunlishilian_3"}}) 
    table.insert(data,{oType = "empty", height = 30})
    -- table.insert(data,{oType = "title", info = {name = "战队称号等级:"}})
    -- table.insert(data,{oType = "rank"})

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
                    elseif itemData.oType == "myRank" then
                        item = self:getTitleNode()
                    elseif itemData.oType == "rank" then
                        item = self:getRankNode()
                    elseif itemData.oType == "empty" then
                        item = QUIWidgetQlistviewItem.new()
                    end
                    isCacheNode = false
                end
                if itemData.oType == "describe" then
                    item:setInfo(itemData.info, itemData.title)
                elseif itemData.oType == "empty" then
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
        self._listViewLayout:reload({#self._data})
    end
end

function QUIDialogSoulTrialHelp:getTitleNode()
    local node = CCNode:create()
    local curChapter = remote.soulTrial:getCurChapter( remote.user.soulTrial )
    local curBossConfig = remote.soulTrial:getBossConfigByChapter( curChapter-1 )

    local titleTTF = CCLabelTTF:create("", global.font_default, 20)
    titleTTF:setString("当前称号等级：")
    titleTTF:setAnchorPoint(ccp(0, 0.5))
    titleTTF:setPosition(ccp(30, -30))
    titleTTF:setColor(GAME_COLOR_LIGHT.normal)
    node:addChild(titleTTF)

    if curBossConfig and curBossConfig.title_icon1 and curBossConfig.title_icon2 then
        local kuang = CCSprite:create(curBossConfig.title_icon2)
        if kuang then
            kuang:setPosition(ccp(270, -30))
            kuang:setScale(0.7)
            node:addChild(kuang)
        end
        local sprite = CCSprite:create(curBossConfig.title_icon1)
        if sprite then
            sprite:setPosition(ccp(270, -30))
            sprite:setScale(0.7)
            node:addChild(sprite)
        end
    else
        local titleTTF = CCLabelTTF:create("", global.font_default, 20)
        titleTTF:setString("无")
        titleTTF:setAnchorPoint(ccp(0, 0.5))
        titleTTF:setPosition(ccp(150, -30))
        titleTTF:setColor(GAME_COLOR_LIGHT.normal)
        node:addChild(titleTTF)
    end

    node:setContentSize(CCSize(100, 70))

    return node
end

function QUIDialogSoulTrialHelp:getRankNode()
    local node = CCNode:create()
    local heads = QStaticDatabase:sharedDatabase():getHeroTitle(13)
    local configs = {}
    for _, v in pairs(heads) do
        local reward = {}
        reward.id = tonumber(v.id)
        reward.desc = v.desc
        reward.icon = v.icon
        table.insert(configs, reward)
    end

    table.sort(configs, function (a,b)
        return a.id > b.id
    end)

    -- QPrintTable(configs)
    local height = 30
    for i = 1, #configs do
        local widget = CCNode:create()

        local titleTTF = CCLabelTTF:create("", global.font_default, 20)
        titleTTF:setString(i..". "..configs[i].desc)
        titleTTF:setAnchorPoint(ccp(0, 0.5))
        titleTTF:setPositionX(30)
        titleTTF:setColor(GAME_COLOR_LIGHT.normal)
        widget:addChild(titleTTF)
 
        local icon = configs[i].icon
        local head = CCSprite:createWithSpriteFrame(QSpriteFrameByPath(icon))
        head:setPosition(ccp(280, 10))
        widget:addChild(head)

        widget:setPosition(ccp(0, -height))
        node:addChild(widget)
        height = height + 70
    end
    node:setContentSize(CCSize(100,height))

    return node
end

function QUIDialogSoulTrialHelp:_onTriggerClose()
    self:playEffectOut()
end

return QUIDialogSoulTrialHelp
