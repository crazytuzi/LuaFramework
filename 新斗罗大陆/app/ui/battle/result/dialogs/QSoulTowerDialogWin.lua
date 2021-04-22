--
-- Author: zhangnan
-- Date: 2016-06-04 15:56:00
--
local QBattleDialogBaseFightEnd = import(".QBattleDialogBaseFightEnd")
local QSoulTowerDialogWin = class("QSoulTowerDialogWin", QBattleDialogBaseFightEnd)

local QUIWidgetItemsBox = import("....widgets.QUIWidgetItemsBox")

function QSoulTowerDialogWin:ctor(options, owner)
    print("<<<QSoulTowerDialogWin>>>")
    --设置该节点启用enter事件
    self:setNodeEventEnabled(true)
    QSoulTowerDialogWin.super.ctor(self, options, owner)
    self._audioHandler = app.sound:playSound("battle_complete")

    if options.isWin then
        self._ccbOwner.node_bg_win:setVisible(true)
        self._ccbOwner.node_win_client:setVisible(true)
        self._ccbOwner.node_win_text_title:setVisible(true)
        self:setWinTextTitle({"zhan", "dou", "jie", "shu"})

        self._ccbOwner.node_fight_data:setVisible(false)
        self._ccbOwner.node_soulTower_data:setVisible(true)

        self._ccbOwner.tf_fightData_wave_title:setString("通过关卡：")
        self._ccbOwner.tf_fightData_wave_value:setString((options.battleFloor or 0).."-"..(options.curWave or 0))

        self._ccbOwner.tf_fightData_battleTime_title:setString("击败时间：")
        print("击败时间：=",options.battleTime)
        local passTime = string.format("%0.2f秒", tonumber(options.battleTime or 0))  
        self._ccbOwner.tf_fightData_battleTime_value:setString(passTime)

        self._ccbOwner.tf_award_title:setString("战斗奖励")
        self._ccbOwner.node_award_title:setVisible(true)

        self._ccbOwner.node_no_tips:setFontSize(20)
        self._ccbOwner.node_no_tips:setVisible(true)
        self._ccbOwner.node_no_tips:setString("本层解锁以下奖励")
        
        -- award normal
        self._ccbOwner.node_award_normal:setVisible(true)
        self._ccbOwner.node_award_normal_client:setVisible(true)
        local itemsBox = {}
        local boxWidth = 0
        local i = 1
        local awards = options.awards or {}
        for _, value in ipairs(awards) do
            local node = self._ccbOwner["node_award_normal_item_"..i]
            if node and value then
                local itemBox = self:_createItemBox(node, value)
                if boxWidth == 0 then
                    boxWidth = itemBox:getContentSize().width
                end
                i = i + 1
            end
        end

        -- award normal 中心对齐
        local awardsNum = i - 1
        if awardsNum > 0 then
            local posX = self._ccbOwner.node_award_normal_client:getPositionX() + 10
            self._ccbOwner.node_award_normal_client:setPositionX(posX + ((6 - awardsNum) * 79 / 2))
        end
    else
        makeNodeFromNormalToGray(self._ccbOwner.node_bg_mvp)

        self._ccbOwner.node_bg_lost:setVisible(true)
        self._ccbOwner.node_lost_client:setVisible(true)

        self:hideAllPic()
        self:chooseBestGuide()        
    end
end

function QSoulTowerDialogWin:_createItemBox(node, itemInfo)
    local itemId = itemInfo.id
    local itemType = itemInfo.typeName
    local itemNum = itemInfo.count

    local itemBox = QUIWidgetItemsBox.new()
    itemBox:setGoodsInfo(itemId, itemType, itemNum)
    itemBox:setPromptIsOpen(true)

    node:addChild(itemBox)
    node:setVisible(true)

    return itemBox
end

function QSoulTowerDialogWin:onEnter()
    self.prompt = app:promptTips()
    self.prompt:addItemEventListener(self)
end

function QSoulTowerDialogWin:onExit()
    if self.prompt ~= nil then
        self.prompt:removeItemEventListener()
    end
end

function QSoulTowerDialogWin:_onTriggerNext()
    self:_onClose()
end

return QSoulTowerDialogWin