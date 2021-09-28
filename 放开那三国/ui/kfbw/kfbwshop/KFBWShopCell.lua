-- FileName: KFBWShopCell.lua
-- Author: shengyixian
-- Date: 2015-09-30
-- Purpose: 跨服比武商店表单元
module("KFBWShopCell",package.seeall)

-- 触摸优先级
local _touchPriority = nil
-- 兑换次数文本的内容
local _timeTxt = nil
-- 当前显示的物品信息
local _itemInfo = nil

function initView(tcell,id)
    -- body
    local pItemInfo = KFBWShopData.getItemInfo()[id]
    _touchPriority = -655
    _timeTxt = GetLocalizeStringBy("syx_1005",pItemInfo.exchangeTimes)
    if pItemInfo.limitType == 2 then
        _timeTxt = GetLocalizeStringBy("syx_1006",pItemInfo.exchangeTimes)
    elseif pItemInfo.limitType == 3 then
        _timeTxt = GetLocalizeStringBy("syx_1015",pItemInfo.exchangeTimes)
    end
    -- 背景
    local cellBg = CCScale9Sprite:create("images/reward/cell_back.png")
    cellBg:setContentSize(CCSizeMake(442,164))
    tcell:addChild(cellBg)
    cellBg:setScale(g_fScaleX)
    -- 白底
    local itemBg= CCScale9Sprite:create("images/reward/item_back.png")
    itemBg:setAnchorPoint(ccp(0.5,0.5))
    itemBg:setContentSize(CCSizeMake(274,115))
    itemBg:setPosition(153,96)
    cellBg:addChild(itemBg)
    -- 当前是第几个价格配置
    local priceIndex = 1
    -- 价格说明文本的Y坐标
    local tLabelPosY = {80,55}
    for i,v in ipairs(pItemInfo.priceAry) do
        if (v.type == "silver") then
            --“银币”文本
            local needSilverLabel = CCRenderLabel:create(GetLocalizeStringBy("key_3341"),g_sFontBold, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            needSilverLabel:setAnchorPoint(ccp(0,0))
            needSilverLabel:setColor(ccc3(0xff,0xf6,0x00))
            needSilverLabel:setPosition(ccp(138,tLabelPosY[priceIndex]))
            cellBg:addChild(needSilverLabel)
            -- 银币值
            local needSilverValueLabel = CCRenderLabel:create(v.num,g_sFontBold, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            needSilverValueLabel:setAnchorPoint(ccp(0,0))
            needSilverValueLabel:setColor(ccc3( 0xff, 0xff, 0xff))
            needSilverValueLabel:setPosition(ccp(138 + needSilverLabel:getContentSize().width,tLabelPosY[priceIndex]))
            cellBg:addChild(needSilverValueLabel)
        elseif(v.type == "gold") then
            --“金币”文本
            local needGoldLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1298"),g_sFontBold, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            needGoldLabel:setAnchorPoint(ccp(0,0))
            needGoldLabel:setColor(ccc3(0xff,0xf6,0x00))
            needGoldLabel:setPosition(ccp(138,tLabelPosY[priceIndex]))
            cellBg:addChild(needGoldLabel)
            -- 金币值
            local needGoldValueLabel = CCRenderLabel:create(v.num,g_sFontBold, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            needGoldValueLabel:setAnchorPoint(ccp(0,0))
            needGoldValueLabel:setColor(ccc3( 0xff, 0xff, 0xff))
            needGoldValueLabel:setPosition(ccp(138 + needGoldLabel:getContentSize().width,tLabelPosY[priceIndex]))
            cellBg:addChild(needGoldValueLabel)
        elseif(v.type == "prestige") then
            --“声望”文本
            local needPrestigeLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2902"),g_sFontBold, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            needPrestigeLabel:setAnchorPoint(ccp(0,0))
            needPrestigeLabel:setColor(ccc3(0xff,0xf6,0x00))
            needPrestigeLabel:setPosition(ccp(138,tLabelPosY[priceIndex]))
            cellBg:addChild(needPrestigeLabel)
            -- 声望值
            local needPrestigeValueLabel = CCRenderLabel:create(v.num,g_sFontBold, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            needPrestigeValueLabel:setAnchorPoint(ccp(0,0))
            needPrestigeValueLabel:setColor(ccc3( 0xff, 0xff, 0xff))
            needPrestigeValueLabel:setPosition(ccp(138 + needPrestigeLabel:getContentSize().width,tLabelPosY[priceIndex]))
            cellBg:addChild(needPrestigeValueLabel)
        elseif(v.type == "cross_honor") then
            --“跨服荣誉”文本
            local needHonorLabel = CCRenderLabel:create(GetLocalizeStringBy("syx_1018"),g_sFontBold, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            needHonorLabel:setAnchorPoint(ccp(0,0))
            needHonorLabel:setColor(ccc3(0xff,0xf6,0x00))
            needHonorLabel:setPosition(ccp(132,tLabelPosY[priceIndex]))
            cellBg:addChild(needHonorLabel)
            --跨服图标
            local honorIcon = CCSprite:create("images/kfbw/kfbwshop/rongyushengji.png")
            needHonorLabel:addChild(honorIcon)
            honorIcon:setAnchorPoint(ccp(0,0))
            honorIcon:setPosition(ccp(needHonorLabel:getContentSize().width,0))
            -- 荣誉值
            local needHonorValueLabel = CCRenderLabel:create(v.num,g_sFontBold, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            needHonorValueLabel:setAnchorPoint(ccp(0,0))
            needHonorValueLabel:setColor(ccc3( 0xff, 0xff, 0xff))
            needHonorValueLabel:setPosition(ccp(132 + needHonorLabel:getContentSize().width+honorIcon:getContentSize().width,tLabelPosY[priceIndex]))
            cellBg:addChild(needHonorValueLabel)
        elseif(v.type == "jh") then
            --“武将精华”文本
            local heroJhLabel = CCRenderLabel:create(GetLocalizeStringBy("syx_1052"),g_sFontBold, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            heroJhLabel:setAnchorPoint(ccp(0,0))
            heroJhLabel:setColor(ccc3(0xff,0xf6,0x00))
            heroJhLabel:setPosition(ccp(132,tLabelPosY[priceIndex]))
            cellBg:addChild(heroJhLabel)
            --将星图标
            local heroIcon = CCSprite:create("images/kfbw/kfbwshop/jiangxing.png")
            heroJhLabel:addChild(heroIcon)
            heroIcon:setAnchorPoint(ccp(0,0))
            heroIcon:setPosition(ccp(heroJhLabel:getContentSize().width,0))
            -- 武将精华的值
            local heroJhValueLabel = CCRenderLabel:create(v.num,g_sFontBold, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            heroJhValueLabel:setAnchorPoint(ccp(0,0))
            heroJhValueLabel:setColor(ccc3( 0xff, 0xff, 0xff))
            heroJhValueLabel:setPosition(ccp(132 + heroJhLabel:getContentSize().width+heroIcon:getContentSize().width,tLabelPosY[priceIndex]))
            cellBg:addChild(heroJhValueLabel)
        end
        priceIndex = priceIndex + 1
    end
    -- 兑换按钮
    local menu= CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(_touchPriority)
    cellBg:addChild(menu)
    local exchangeItem = CCMenuItemImage:create("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png")
    exchangeItem:setAnchorPoint(ccp(0.5,0.5))
    exchangeItem:setPosition(360,80)
    exchangeItem:registerScriptTapHandler(exchangeHandler)
    menu:addChild(exchangeItem,1,id)
    -- “兑换”字体
    local item_font = CCRenderLabel:create(GetLocalizeStringBy("key_2689") , g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    item_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
    item_font:setAnchorPoint(ccp(0.5,0.5))
    item_font:setPosition(ccp(exchangeItem:getContentSize().width*0.5,exchangeItem:getContentSize().height*0.5))
    exchangeItem:addChild(item_font)
    -- 可兑换次数
    local timeLabel = CCRenderLabel:create(_timeTxt,g_sFontBold, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    timeLabel:setAnchorPoint(ccp(0,0))
    timeLabel:setColor(ccc3(0x00,0xff,0x18))
    timeLabel:setPosition(ccp(17,18))
    cellBg:addChild(timeLabel)
    if(pItemInfo.exchangeTimes < 1)then
     exchangeItem:setVisible(false)
        local hasReceiveItem = CCSprite:create("images/common/yiduihuan.png")
        hasReceiveItem:setAnchorPoint(ccp(0.5,0.5))
        hasReceiveItem:setPosition(ccp(360,80))
        cellBg:addChild(hasReceiveItem) 
    end
    -- 商品图标
    local itemInfo = ItemUtil.getItemsDataByStr(pItemInfo.items)[1]
    local icon,nameStr,nameColor = ItemUtil.createGoodsIcon(itemInfo,_touchPriority,1234,nil,nil,nil,false,false)
    icon:setAnchorPoint(ccp(0.5,0.5))
    icon:setPosition(ccp(72,96))
    cellBg:addChild(icon)
    local goodNameLabel = CCRenderLabel:create(nameStr,g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    goodNameLabel:setColor(nameColor)
    goodNameLabel:setAnchorPoint(ccp(0.5,0.5))
    goodNameLabel:setPosition(ccp(186,129))
    cellBg:addChild(goodNameLabel)
    -- -- 数量文本
    -- local iconSize = icon:getContentSize()
    -- local numLabel = CCRenderLabel:create(pItemInfo.itemNum,g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    -- numLabel:setColor(ccc3( 0xff, 0xff, 0xff ))
    -- numLabel:setAnchorPoint(ccp(1,0))
    -- numLabel:setPosition(ccp(iconSize.width,0))
    -- icon:addChild(numLabel)

    --可兑换等级限制 add by FQQ
    local levelLimit = tonumber(pItemInfo.needLevel)
    --判断玩家等级
    if(UserModel.getHeroLevel() < levelLimit)then
        local width = itemBg:getPositionX() + itemBg:getContentSize().width -180
        local labelText = CCLabelTTF:create(GetLocalizeStringBy("key_3131"),g_sFontPangWa,18)
        labelText:setColor(ccc3(0x78, 0x25, 0x00))
        labelText:setPosition(ccp(width,20))
        cellBg:addChild(labelText)
        local labelLv = CCLabelTTF:create(levelLimit,g_sFontPangWa,18)
        labelLv:setColor(ccc3(0x00, 0x8d, 0x3d))
        labelLv:setPosition(ccp(labelText:getPositionX() + labelText:getContentSize().width + 3,20))
        cellBg:addChild(labelLv)
    end
end

function createCell( itemInfo )
    -- body
    local tcell = CCTableViewCell:create()
    initView(tcell,itemInfo)
    return tcell
end

--[[
    @des    : 兑换按钮回调函数
    @param  : 
    @return : 
--]]
function exchangeHandler(tag,item)
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    local itemInfo = KFBWShopData.getItemInfo()[tag]
    KFBWShopController.beforeExchange(itemInfo,function ( ... )
        -- body
        require "script/ui/kfbw/kfbwshop/KFBWSelectNumDialog"
        local numDialog = KFBWSelectNumDialog.new()
        numDialog:setItemInfo(itemInfo)
        numDialog:show(_touchPriority - 10,555)
    end)
end



