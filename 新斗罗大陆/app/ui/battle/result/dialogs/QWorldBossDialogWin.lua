--
-- Author: zhangnan
-- Date: 2016-06-04 15:56:00
--
local QBattleDialogBaseFightEnd = import(".QBattleDialogBaseFightEnd")
local QWorldBossDialogWin = class("QWorldBossDialogWin", QBattleDialogBaseFightEnd)

local QUIWidgetItemsBox = import("....widgets.QUIWidgetItemsBox")

function QWorldBossDialogWin:ctor(options, owner)
    print("<<<QWorldBossDialogWin>>>")
    --设置该节点启用enter事件
    self:setNodeEventEnabled(true)
    QWorldBossDialogWin.super.ctor(self, options, owner)
    self._audioHandler = app.sound:playSound("battle_complete")

    self._ccbOwner.node_bg_win:setVisible(true)
    self._ccbOwner.node_win_client:setVisible(true)
    self._ccbOwner.node_win_text_title:setVisible(true)
    self:setWinTextTitle({"zhan", "dou", "jie", "shu"})

    self._ccbOwner.node_fight_data:setVisible(true)

    self._ccbOwner.tf_fightData_damage_title:setString("造成伤害：")
    local num, unit = q.convertLargerNumber(options.damage)
    self._ccbOwner.tf_fightData_damage_value:setString(num..(unit or ""))
    self._ccbOwner.node_fightData_damage:setVisible(true)
    self._ccbOwner.tf_fightData_meritorious_title:setString("获得荣誉：")
    self._ccbOwner.tf_fightData_meritorious_value:setString(options.meritorious)
    self._ccbOwner.node_fightData_meritorious:setVisible(true)
    self._ccbOwner.tf_fightData_damageRank_title:setString("荣誉排名：")
    self._ccbOwner.tf_fightData_damageRank_old:setString(options.oldHurtRank)
    self._ccbOwner.tf_fightData_damageRank_new:setString(options.hurtRank)
    self._ccbOwner.node_fightData_damage_rank:setVisible(true)

    self._ccbOwner.tf_award_title:setString("战斗奖励")
    self._ccbOwner.node_award_title:setVisible(true)

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
end

function QWorldBossDialogWin:_createItemBox(node, itemInfo)
    local itemId = itemInfo[1]
    local itemType = ITEM_TYPE.ITEM
    local itemNum = tonumber(itemInfo[2])
    if tonumber(itemInfo[1]) == nil then
        itemType = remote.items:getItemType(itemInfo[1])
    end

    local itemBox = QUIWidgetItemsBox.new()
    itemBox:setGoodsInfo(itemId, itemType, itemNum)
    itemBox:setPromptIsOpen(true)
    itemBox:setName(itemInfo.title)
    -- itemBox:resetAll()
    node:addChild(itemBox)
    node:setVisible(true)

    return itemBox
end

function QWorldBossDialogWin:onEnter()
    self.prompt = app:promptTips()
    self.prompt:addItemEventListener(self)
end

function QWorldBossDialogWin:onExit()
    if self.prompt ~= nil then
        self.prompt:removeItemEventListener()
    end
end

function QWorldBossDialogWin:_onTriggerNext()
    self:_onClose()
end

return QWorldBossDialogWin