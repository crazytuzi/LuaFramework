--
-- Author: zhangnan
-- Date: 2016-06-04 15:56:00
--
local QBattleDialogBaseFightEnd = import(".QBattleDialogBaseFightEnd")
local QBattleDialogSocietyDungeon = class("QBattleDialogSocietyDungeon", QBattleDialogBaseFightEnd)

local QUIWidgetItemsBox = import("....widgets.QUIWidgetItemsBox")

function QBattleDialogSocietyDungeon:ctor(options, owner)
    print("<<<QBattleDialogSocietyDungeon>>>")
    --设置该节点启用enter事件
    self:setNodeEventEnabled(true)
    local tmpWin = options.isWin
    options.isWin = true
    QBattleDialogSocietyDungeon.super.ctor(self, options, owner)
    options.isWin = tmpWin
    
    self._audioHandler = app.sound:playSound("battle_complete")

    self._ccbOwner.node_bg_win:setVisible(true)

    self._ccbOwner.node_win_client:setVisible(true)

    self._ccbOwner.node_win_text_title:setVisible(true)
    self:setWinTextTitle({"zhan", "dou", "jie", "shu"})

    self._ccbOwner.node_fight_data:setVisible(true)
    self._ccbOwner.tf_fightData_damage_title:setString("造成伤害：")
    self._ccbOwner.tf_fightData_damage_value:setString(options.damage)

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

    if self._ccbOwner.tf_warning and remote.user.userConsortia then
        self._ccbOwner.tf_warning:setVisible(not remote.user.userConsortia.isValid)
    end

    self._ccbOwner.node_fightData_damage:setVisible(true)


    self._ccbOwner.tf_award_title:setString("战斗奖励")
    self._ccbOwner.node_award_title:setVisible(true)

    -- self._ccbOwner.ly_award_equation_size:setVisible(false)
    local isWin = options.isWin
    local activityYield = options.activityYield
    self._ccbOwner.tf_award_equation_item_3:setString("基础奖励")
    self._ccbOwner.tf_award_equation_item_4:setString("伤害加成")
    self._ccbOwner.tf_award_equation_item_5:setString("总共获得")
    self._ccbOwner.node_plus_3:setVisible(true)
    self._ccbOwner.node_equal:setVisible(true)
    local itemsBox = QUIWidgetItemsBox.new()
    itemsBox:setVisible(false)
    itemsBox:setPromptIsOpen(true)
    itemsBox:resetAll()
    if activityYield > 1 then
        itemsBox:setRateActivityState(true)
    end
    self:setBoxInfo(itemsBox, nil, ITEM_TYPE.CONSORTIA_MONEY, options.baseAward)
    self._ccbOwner.node_award_equation_item_3:addChild(itemsBox)
    if isWin then
        self._ccbOwner.tf_award_equation_item_2:setString("击杀奖励")
        self._ccbOwner.node_plus_2:setVisible(true)
        itemsBox = QUIWidgetItemsBox.new()
        itemsBox:setVisible(false)
        itemsBox:setPromptIsOpen(true)
        itemsBox:resetAll()
        self:setBoxInfo(itemsBox, nil, ITEM_TYPE.CONSORTIA_MONEY, options.killedAward)
        self._ccbOwner.node_award_equation_item_2:addChild(itemsBox)
    end
    itemsBox = QUIWidgetItemsBox.new()
    itemsBox:setVisible(false)
    itemsBox:setPromptIsOpen(true)
    itemsBox:resetAll()
    if activityYield > 1 then
        itemsBox:setRateActivityState(true)
    end
    self:setBoxInfo(itemsBox, nil, ITEM_TYPE.CONSORTIA_MONEY, options.damageAward)
    self._ccbOwner.node_award_equation_item_4:addChild(itemsBox)
    itemsBox = QUIWidgetItemsBox.new()
    itemsBox:setVisible(false)
    itemsBox:setPromptIsOpen(true)
    itemsBox:resetAll()
    self:setBoxInfo(itemsBox, nil, ITEM_TYPE.CONSORTIA_MONEY, options.totalAward)
    self._ccbOwner.node_award_equation_item_5:addChild(itemsBox)
    self._ccbOwner.node_award_equation:setVisible(true)

    -- awards 中心对齐
    if isWin then
        self._ccbOwner.node_award_equation:setPositionX(-(self._ccbOwner.ly_award_equation_size:getContentSize().width - self.awardEquationWidth * 4) / 2)
    else
        self._ccbOwner.node_award_equation:setPositionX(-(self._ccbOwner.ly_award_equation_size:getContentSize().width - self.awardEquationWidth * 3) / 2)
    end
end

function QBattleDialogSocietyDungeon:onEnter()
    self.prompt = app:promptTips()
    self.prompt:addItemEventListener(self)
end

function QBattleDialogSocietyDungeon:onExit()
    if self.prompt ~= nil then
        self.prompt:removeItemEventListener()
    end
end

function QBattleDialogSocietyDungeon:_onTriggerNext()
    self:_onClose()
end

return QBattleDialogSocietyDungeon