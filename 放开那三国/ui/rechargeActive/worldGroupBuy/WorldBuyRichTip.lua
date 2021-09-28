-- Filename：    WorldBuyRichTip.lua
-- Author：      DJN
-- Date：        2015-8-3
-- Purpose：     跨服团购弹窗


module ("WorldBuyRichTip", package.seeall)
require "script/ui/tip/RichAlertTip"
--确认花费***购买***的提示
function tipConfirmBuy(p_tag,p_num)
    local goldNum,curponNum = WorldGroupData.getTotalPreviewCostByNum(p_tag,p_num)
    local activeData = WorldGroupData.getActiveDataByID(p_tag)
    local itemName = activeData["good_name"]
    local quality = tonumber(activeData.quality) or 2
    local richInfo = {lineAlignment = 2,elements = {},labelDefaultSize = 28}
        richInfo.elements = {}
        local tmpElement = nil
        tmpElement = { 
                text = GetLocalizeStringBy("key_1088"),
                color = ccc3(0x78, 0x25, 0x00)}
        table.insert(richInfo.elements,tmpElement)
        if(goldNum > 0)then
            tmpElement = {
                    ["type"] = "CCSprite",
                    image = "images/common/gold.png"}
            table.insert(richInfo.elements,tmpElement)
            tmpElement = {
                    ["type"] = "CCRenderLabel", 
                    text = goldNum ,
                    color = ccc3(0xff,0xf6,0x00)}
            table.insert(richInfo.elements,tmpElement)
        end
        if(goldNum > 0 and curponNum > 0)then
            tmpElement = {
                    ["type"] = "CCRenderLabel", 
                    text = "、",
                    color = ccc3(0xff,0xf6,0x00)}
            table.insert(richInfo.elements,tmpElement)
        end
        --消耗的物品的icon
      
        local imagePath = "images/recharge/worldGroupBuy/coupon.png" 
     
        if(curponNum > 0)then          
            tmpElement = {
                    ["type"] = "CCSprite",
                    image = imagePath}
            table.insert(richInfo.elements,tmpElement)
            tmpElement = {
                    ["type"] = "CCRenderLabel", 
                    text = curponNum ,
                    color = ccc3(0xff,0xf6,0x00)}
            table.insert(richInfo.elements,tmpElement)
        
        end
        tmpElement = {
                text = GetLocalizeStringBy("key_1523")..p_num..GetLocalizeStringBy("key_2557"),
                color =  ccc3(0x78, 0x25, 0x00)}
        table.insert(richInfo.elements,tmpElement)

        tmpElement = {
                ["type"] = "CCRenderLabel",
                text =  itemName,
                color = HeroPublicLua.getCCColorByStarLevel(quality)}
        table.insert(richInfo.elements,tmpElement)
        tmpElement = {
                text = "?",
                color =   ccc3(0x78, 0x25, 0x00)}
        table.insert(richInfo.elements,tmpElement)
        -- tmpElement = {
        --         newLine = true,
        --         text = "\n"..GetLocalizeStringBy("key_1854")..":",
        --         color =  ccc3(0x00, 0x6d, 0x2f)}
        -- table.insert(richInfo.elements,tmpElement)
        -- tmpElement = {
        --         ["type"] = "CCSprite",
        --         image = imagePath}
        -- table.insert(richInfo.elements,tmpElement)

        -- tmpElement = {
        --         text = WorldGroupData.getUserInfo().coupon or 0,
        --         color =  ccc3(0x00, 0x6d, 0x2f)}
        -- table.insert(richInfo.elements,tmpElement)
    
    local confirmCostCb = function (p_status)

        if(p_status)then
            WorldGroupControler.confirmCb(p_tag,goldNum,p_num)
        end
    end
    RichAlertTip.showAlert(richInfo, confirmCostCb, true)
end
--点击礼包icon展示礼包内容
function showBagTip(p_tag )
    local activeData = WorldGroupData.getActiveDataByID(p_tag)
    local dataStr = activeData["item"]
     local itemsData = ItemUtil.getItemsDataByStr(dataStr )
    -- 展示奖励
    require "script/ui/item/ReceiveReward"
    ReceiveReward.showRewardWindow( itemsData, nil , WorldGroupLayer.getZorder()+10,WorldGroupLayer.getTouchPriority() -300, GetLocalizeStringBy("lic_1021") )
end
--购买成功够提示花费的提示
function tipBuySuccess(costGold,costCoupon,addPoint,addCoupon)
    -- local goldNum,curponNum = WorldGroupData.getTotalPreviewCostByNum(p_tag,p_num)
    -- local activeData = WorldGroupData.getActiveDataByID(p_tag)
    -- local itemName = activeData["good_name"]
    -- local quality = tonumber(activeData.quality) or 2
    if costGold then
        costGold = tonumber(costGold) 
    else
        costGold = 0
    end
    if costCoupon then
        costCoupon = tonumber(costCoupon) 
    else
        costCoupon = 0
    end
    local richInfo = {lineAlignment = 2,elements = {},labelDefaultSize = 28}
        richInfo.elements = {}
        local tmpElement = nil
        tmpElement = { 
                text = GetLocalizeStringBy("djn_209",addPoint,addCoupon),
                color = ccc3(0x78, 0x25, 0x00)}
        table.insert(richInfo.elements,tmpElement)
         tmpElement = { 
                text = GetLocalizeStringBy("djn_237"),
                newLine = true,
                color = ccc3(0x78, 0x25, 0x00)}
        table.insert(richInfo.elements,tmpElement)
        if(costGold > 0)then
            tmpElement = {
                    ["type"] = "CCSprite",
                    image = "images/common/gold.png"}
            table.insert(richInfo.elements,tmpElement)
            tmpElement = {
                    ["type"] = "CCRenderLabel", 
                    text = costGold ,
                    color = ccc3(0xff,0xf6,0x00)}
            table.insert(richInfo.elements,tmpElement)
        end
        if(costGold > 0 and costCoupon > 0)then
            tmpElement = {
                    ["type"] = "CCRenderLabel", 
                    text = "、",
                    color = ccc3(0xff,0xf6,0x00)}
            table.insert(richInfo.elements,tmpElement)
        end
        --消耗的物品的icon
      
        local imagePath = "images/recharge/worldGroupBuy/coupon.png" 
     
        if(costCoupon > 0)then          
            tmpElement = {
                    ["type"] = "CCSprite",
                    image = imagePath}
            table.insert(richInfo.elements,tmpElement)
            tmpElement = {
                    ["type"] = "CCRenderLabel", 
                    text = costCoupon ,
                    color = ccc3(0xff,0xf6,0x00)}
            table.insert(richInfo.elements,tmpElement)
        
        end

    RichAlertTip.showAlert(richInfo)
end