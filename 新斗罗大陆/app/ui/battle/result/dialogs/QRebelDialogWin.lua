--
-- Author: Your Name
-- Date: 2014-05-19 10:58:04
--
local QBattleDialogBaseFightEnd = import(".QBattleDialogBaseFightEnd")
local QRebelDialogWin = class(".QRebelDialogWin", QBattleDialogBaseFightEnd)

local QStaticDatabase = import(".....controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("....widgets.QUIWidgetItemsBox")

function QRebelDialogWin:ctor(options, owner)
    print("<<<QRebelDialogWin>>>")
    --设置该节点启用enter事件
    self:setNodeEventEnabled(true)
    QRebelDialogWin.super.ctor(self, options, owner)
    self._audioHandler = app.sound:playSound("battle_complete")
    --设置掉落的物品
    remote.invasion:setBattleItems(clone(options.intrusionFightEndAward))

    self._ccbOwner.node_bg_win:setVisible(true)
    self._ccbOwner.node_win_client:setVisible(true)
    self._ccbOwner.node_win_text_title:setVisible(true)
    self:setWinTextTitle({"zhan", "dou", "jie", "shu"})
    self._ccbOwner.node_fight_data:setVisible(true)
    self._ccbOwner.tf_fightData_damage_title:setString("造成伤害：")
    local hour = q.date("%H", q.serverTime())
    -- if tonumber(hour) == 18 or tonumber(hour) == 19 then
    --     self._ccbOwner.tf_fightData_damage_value:setString(options.damage * 2)
    -- else
    --     self._ccbOwner.tf_fightData_damage_value:setString(options.damage)
    -- end
    local force, unit = q.convertLargerNumber(options.damage)
    self._ccbOwner.tf_fightData_damage_value:setString(force..unit)
    self._ccbOwner.node_fightData_damage:setVisible(true)

    local force, unit = q.convertLargerNumber(options.meritorious)
    self._ccbOwner.tf_fightData_meritorious_title:setString("获得积分：")
    self._ccbOwner.tf_fightData_meritorious_value:setString(force..unit)
    self._ccbOwner.node_fightData_meritorious:setVisible(true)
    self._ccbOwner.tf_fightData_damageRank_title:setString("伤害名次：")
    self._ccbOwner.tf_fightData_damageRank_old:setString(options.damageOldRank or 0)
    self._ccbOwner.tf_fightData_damageRank_new:setString(options.damageNewRank or 0)
    self._ccbOwner.node_fightData_damage_rank:setVisible(options.damageOldRank ~= options.damageNewRank)
    self._ccbOwner.tf_fightData_meritoriousRank_title:setString("积分名次：")
    self._ccbOwner.tf_fightData_meritoriousRank_old:setString(options.meritOldRank or 0)
    self._ccbOwner.tf_fightData_meritoriousRank_new:setString(options.meritNewRank or 0)
    self._ccbOwner.node_fightData_meritorious_rank:setVisible(options.meritOldRank ~= options.meritNewRank)

    self._ccbOwner.tf_award_title:setString("战斗奖励")
    self._ccbOwner.node_award_title:setVisible(true)

    -- self._ccbOwner.ly_award_equation_size:setVisible(false)
    self._ccbOwner.tf_award_equation_item_3:setString("基础奖励")
    self._ccbOwner.tf_award_equation_item_4:setString("伤害加成")
    self._ccbOwner.tf_award_equation_item_5:setString("总共获得")
    self._ccbOwner.node_plus_3:setVisible(true)
    self._ccbOwner.node_equal:setVisible(true)
    local itemsBox = QUIWidgetItemsBox.new()
    itemsBox:setVisible(false)
    itemsBox:setPromptIsOpen(true)
    itemsBox:resetAll()

    self:setBoxInfo(itemsBox, nil, ITEM_TYPE.INTRUSION_MONEY, options.baseRebelToken)
    self._ccbOwner.node_award_equation_item_3:addChild(itemsBox)
    itemsBox = QUIWidgetItemsBox.new()
    itemsBox:setVisible(false)
    itemsBox:setPromptIsOpen(true)
    itemsBox:resetAll()
    self:setBoxInfo(itemsBox, nil, ITEM_TYPE.INTRUSION_MONEY, options.addRebelToken - options.baseRebelToken)
    self._ccbOwner.node_award_equation_item_4:addChild(itemsBox)
    itemsBox = QUIWidgetItemsBox.new()
    itemsBox:setVisible(false)
    itemsBox:setPromptIsOpen(true)
    itemsBox:resetAll()
    self:setBoxInfo(itemsBox, nil, ITEM_TYPE.INTRUSION_MONEY, options.addRebelToken)
    self._ccbOwner.node_award_equation_item_5:addChild(itemsBox)
    self._ccbOwner.node_award_equation:setVisible(true)

    local activityYield = options.activityYield
    if activityYield and activityYield > 1 then
        itemsBox:setRateActivityState(true, activityYield)
    end

    -- awards 中心对齐
    self._ccbOwner.node_award_equation:setPositionX(-(self._ccbOwner.ly_award_equation_size:getContentSize().width - self.awardEquationWidth * 3) / 2)
end

function QRebelDialogWin:onEnter()
    self.prompt = app:promptTips()
    self.prompt:addItemEventListener(self)
end

function QRebelDialogWin:onExit()   
    if self.prompt ~= nil then
        self.prompt:removeItemEventListener()
    end
end

function QRebelDialogWin:_onTriggerNext()
    app.sound:playSound("common_item")
    self:_onClose()
end

return QRebelDialogWin