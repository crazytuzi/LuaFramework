G_RED_DOT_DATA = {}
local trade_sc_check_new_ret = function(buffer)
    local proto = g_msgHandlerInst:convertBufferToTable("MallCheckNewRet", buffer)
    if G_NFTRIGGER_NODE and not G_NFTRIGGER_NODE:isFuncOn(NF_FURNACE) then   --如果熔炼功能没有开启不应该显示红点,todo:如果收到消息时G_NFTRIGGER_NODE还没有被创建怎么办?
        return
    end
    if not (proto.mallType == 3 and proto.isNew == true) then --3.熔炼商城
        return
    end
    G_RED_DOT_DATA.bool_shallShowSmelterRedDot = true
    if not G_MAINSCENE then
        return
    end
    --装备button
    G_MAINSCENE:processEquipButtonRedDot()
    --熔炼button
    if
        G_MAINSCENE.base_node:getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BUTTON + require("src/config/CommDef").TAG_INDEX_SUB_NODE_EQUIP)
        and G_MAINSCENE.base_node:getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BUTTON + require("src/config/CommDef").TAG_INDEX_SUB_NODE_EQUIP):getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BG):getChildByTag(require("src/config/CommDef").TAG_BUTTON_RONGLIAN)
        and not G_MAINSCENE.base_node:getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BUTTON + require("src/config/CommDef").TAG_INDEX_SUB_NODE_EQUIP):getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BG):getChildByTag(require("src/config/CommDef").TAG_BUTTON_RONGLIAN):getChildByTag(require("src/config/CommDef").TAG_RED_DOT)
    then
        local node_rongLian = G_MAINSCENE.base_node:getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BUTTON + require("src/config/CommDef").TAG_INDEX_SUB_NODE_EQUIP):getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BG):getChildByTag(require("src/config/CommDef").TAG_BUTTON_RONGLIAN)
        local spr_redDot = createSprite(
            node_rongLian
            , "res/component/flag/red.png"
            , cc.p(node_rongLian:getContentSize().width - 5, node_rongLian:getContentSize().height - 15)
        )
        spr_redDot:setTag(require("src/config/CommDef").TAG_RED_DOT)
    end
    --熔炼商城tab
    if
        G_MAINSCENE.base_node:getChildByTag(100 + require("src/config/CommDef").PARTIAL_TAG_SMELTER_DIALOG_TEMP)
        and not G_MAINSCENE.base_node:getChildByTag(100 + require("src/config/CommDef").PARTIAL_TAG_SMELTER_DIALOG_TEMP):getChildByTag(require("src/config/CommDef").TAG_SMELTER_NODE):getChildByTag(require("src/config/CommDef").TAG_SMELTER_RONGLIAN_SHOP_MENU):getChildByTag(require("src/config/CommDef").TAG_SMELTER_RONGLIAN_SHOP_BTN):getChildByTag(require("src/config/CommDef").TAG_RED_DOT)
    then
        local node_rongLianTab = G_MAINSCENE.base_node:getChildByTag(100 + require("src/config/CommDef").PARTIAL_TAG_SMELTER_DIALOG_TEMP):getChildByTag(require("src/config/CommDef").TAG_SMELTER_NODE):getChildByTag(require("src/config/CommDef").TAG_SMELTER_RONGLIAN_SHOP_MENU):getChildByTag(require("src/config/CommDef").TAG_SMELTER_RONGLIAN_SHOP_BTN)
        local spr_redDot = createSprite(
            node_rongLianTab
            , "res/component/flag/red.png"
            , cc.p(node_rongLianTab:getContentSize().width - 5, node_rongLianTab:getContentSize().height - 15)
        )
        spr_redDot:setTag(require("src/config/CommDef").TAG_RED_DOT)
    end
end

g_msgHandlerInst:registerMsgHandler(TRADE_SC_CHECK_NEW_RET, trade_sc_check_new_ret)