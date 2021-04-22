--
-- zxs
-- 武魂战结算
--
local QBattleDialogBaseFightEnd = import(".QBattleDialogBaseFightEnd")
local QDragonWarDialogWin = class(".QDragonWarDialogWin", QBattleDialogBaseFightEnd)

local QStaticDatabase = import(".....controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("....widgets.QUIWidgetItemsBox")

function QDragonWarDialogWin:ctor(options, owner)
    print("<<<QDragonWarDialogWin>>>")
    --设置该节点启用enter事件
    self:setNodeEventEnabled(true)
    QDragonWarDialogWin.super.ctor(self, options, owner)
    self._audioHandler = app.sound:playSound("battle_complete")

    self._ccbOwner.node_bg_win:setVisible(true)
    self._ccbOwner.node_win_client:setVisible(true)
    self._ccbOwner.node_win_text_title:setVisible(true)
    self:setWinTextTitle({"zhan", "dou", "jie", "shu"})
    self._ccbOwner.node_fight_data:setVisible(true)

    self._ccbOwner.tf_fightData_damage_title:setString("本次伤害：")
    local force, unit = q.convertLargerNumber(options.currentHurt)
    self._ccbOwner.tf_fightData_damage_value:setString(force..unit)
    self._ccbOwner.node_fightData_damage:setVisible(true)
    local posY = self._ccbOwner.node_fightData_damage:getPositionY()
    self._ccbOwner.node_fightData_damage:setPositionY(posY-20)

    -- if remote.playerRecall:isOpen() then
    --     local sp = CCSprite:create("ui/dl_wow_pic/sp_comeback.png")
    --     local node = self._ccbOwner.tf_fightData_damage_value:getParent()
    --     sp:setPositionX(self._ccbOwner.tf_fightData_damage_value:getPositionX() + self._ccbOwner.tf_fightData_damage_value:getContentSize().width)
    --     sp:setPositionY(self._ccbOwner.tf_fightData_damage_value:getPositionY())
    --     node:addChild(sp)
    -- end
    self._ccbOwner.sp_fightData_playerRecall:setVisible(remote.playerRecall:isOpen())
    self._ccbOwner.sp_fightData_playerRecall:setPositionX(self._ccbOwner.tf_fightData_damage_value:getPositionX() + self._ccbOwner.tf_fightData_damage_value:getContentSize().width + 5)
    self._ccbOwner.sp_fightData_playerRecall:setPositionY(self._ccbOwner.tf_fightData_damage_value:getPositionY())

    local response = options.battleResult.gfEndResponse.dragonWarFightEndResponse
    local force, unit = q.convertLargerNumber(response.myInfo.todayMaxPerHurt or 0)
    self._ccbOwner.tf_fightData_meritorious_title:setString("最高伤害：")
    self._ccbOwner.tf_fightData_meritorious_value:setString(force..unit)
    self._ccbOwner.node_fightData_meritorious:setVisible(true)
    local posY = self._ccbOwner.node_fightData_meritorious:getPositionY()
    self._ccbOwner.node_fightData_meritorious:setPositionY(posY-50)

    self._ccbOwner.sp_great:setVisible(options.currentHurt >= (response.myInfo.todayMaxPerHurt or 0))
    self._ccbOwner.sp_great:setPositionY(self._ccbOwner.sp_great:getPositionY()+35)
    self._ccbOwner.tf_award_title:setString("战斗奖励")
    self._ccbOwner.node_award_title:setVisible(true)
    self._ccbOwner.node_award_normal:setVisible(true)
    self._ccbOwner.node_award_normal_client:setVisible(true)

    local normalAwards = response.normalAward or {}
    local addAwards = response.addAward or {}
    normalAwards = string.split(normalAwards, ";")
    addAwards = string.split(addAwards, ";")

    local noramlIndex = 1
    local addIndex = 2
    local awardsNum = 0
    for i = 1, 3 do
        if normalAwards[i] and normalAwards[i] ~= "" then
            local itemsInfo = string.split(normalAwards[i], "^")
            self:createItemBox(self._ccbOwner["node_award_normal_item_"..noramlIndex], itemsInfo[1], itemsInfo[2], "基础奖励")
            awardsNum = awardsNum + 1
        end 

        if addAwards[i] and addAwards[i] ~= "" then
            local itemsInfo = string.split(addAwards[i], "^")
            self:createItemBox(self._ccbOwner["node_award_normal_item_"..addIndex], itemsInfo[1], itemsInfo[2], "伤害奖励")
            awardsNum = awardsNum + 1
        end

        noramlIndex = noramlIndex + 2
        addIndex = addIndex + 2
    end

    -- award normal 中心对齐
    if awardsNum > 0 then
        local posX = self._ccbOwner.node_award_normal_client:getPositionX() + 10
        self._ccbOwner.node_award_normal_client:setPositionX(posX + ((6 - awardsNum) * 79 / 2))
    end
end

function QDragonWarDialogWin:createItemBox(node, itemId, itemCount, title)
    local itemBox = QUIWidgetItemsBox.new()
    local itemType = ITEM_TYPE.ITEM
    if tonumber(itemId) == nil then
        itemType = remote.items:getItemType(itemId)
    end
    itemBox:setPromptIsOpen(true)
    itemBox:setGoodsInfo(tonumber(itemId), itemType, tonumber(itemCount))
    itemBox:setAwardName(title)
    node:addChild(itemBox)
end

function QDragonWarDialogWin:onEnter()
    self.prompt = app:promptTips()
    self.prompt:addItemEventListener(self)
end

function QDragonWarDialogWin:onExit()   
    if self.prompt ~= nil then
        self.prompt:removeItemEventListener()
    end
end

function QDragonWarDialogWin:_onTriggerNext()
    app.sound:playSound("common_item")
    self:_onClose()
end

return QDragonWarDialogWin