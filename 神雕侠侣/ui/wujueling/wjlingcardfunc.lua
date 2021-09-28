--[[author: lvxiaolong
date: 2013/11/29
function: wjling card general function
]]

require "ui.dialog"
require "utils.mhsdutils"
require "manager.beanconfigmanager"


s_INDEX_GROUP_BTN_LIMIT_SELL = 7
s_INDEX_GROUP_BTN_VIP_LIMIT_SELL = 8
s_TYPE_OTHER_SELL_ITEM = 1
s_TYPE_LIMIT_SELL_ITEM = 2
s_TYPE_VIP_LIMIT_SELL_ITEM = 3

lua_CardUnit = {}
function lua_CardUnit.New()
    local cardunit = {}

    cardunit.pBack = nil
    cardunit.pItemCell = nil
    cardunit.pItemName = nil
    cardunit.pItemLight = nil
    cardunit.baseID = 0
    cardunit.num = 0

    return cardunit
end

function lua_CardUnit.InitTurnBack(cardunit)
    cardunit.pItemCell:setVisible(false)
    cardunit.pItemName:setVisible(false)
end

function lua_CardUnit.TurnBack(cardunit)
    cardunit.pBack:setProperty("NormalImage", "set:MainControl1 image:Pokerface")
    cardunit.pItemCell:setVisible(true)
    cardunit.pItemName:setVisible(true)
end
