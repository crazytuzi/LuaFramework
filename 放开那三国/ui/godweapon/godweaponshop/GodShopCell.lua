-- FileName: GodShopCell.lua
-- Author: DJN
-- Date: 14-12-20
-- Purpose: 神兵商店cell


module("GodShopCell", package.seeall)
require "db/DB_Overcomeshop_items"
require "script/libs/LuaCCLabel"
--[[
    @des    :创建tcell
    @param  :
    @return :创建好的cell
--]]
--local _cost = {}     ---兑换商品需要的花费信息
local _remainCount = {}---剩余的兑换次数
local _costType = {}
local _selectedTag = nil --记录兑换的是哪个cell 用于cell刷新，在兑换一个物品后不执行整个tableview的reloaddata()
--local _index = nil
function createCell(p_cellValue,p_index,p_tableView)
    -- print("cell",p_index)
    -- print_t(p_cellValue)
    p_index = tonumber(p_index)
    p_cellValue.id = tonumber(p_cellValue.id)
    _remainCount[p_index] = tonumber(p_cellValue.count)
    local cost = GodShopData.getCostById(p_cellValue.id)
    _costType[p_index] = cost[1]
   -- _cost = GodShopData.getCostById(p_cellValue.id)

    local tCell = CCTableViewCell:create()
    --背景图片
    --local cellBgSprite = CCScale9Sprite:create("images/reward/cell_back.png")
    local cellBgSprite  = nil
    if(p_cellValue.isSpecial)then
        --是特殊商品，背景图片与其他不同
        cellBgSprite = CCScale9Sprite:create("images/common/bg/bg_9s_6.png")
        local noteLable = CCRenderLabel:create(GetLocalizeStringBy("djn_141"),g_sFontName,18,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
        noteLable:setAnchorPoint(ccp(0,0))
        cellBgSprite:addChild(noteLable)
        noteLable:setColor(ccc3(0x00,0xff,0x18))
        noteLable:setPosition(48,24)
    else
        cellBgSprite = CCScale9Sprite:create("images/common/bg/bg_9s_4.png")
    end
    cellBgSprite:setContentSize(CCSizeMake(570, 185))
    cellBgSprite:setAnchorPoint(ccp(0,0))
    cellBgSprite:setPosition(ccp(35/2,5/2))
    tCell:addChild(cellBgSprite)

    --二级背景图片
    local innerBgSprite = CCScale9Sprite:create("images/copy/fort/textbg.png")
    innerBgSprite:setContentSize(CCSizeMake(350,120))
    innerBgSprite:setAnchorPoint(ccp(0,0))
    innerBgSprite:setPosition(ccp(25,45))
    cellBgSprite:addChild(innerBgSprite)
   
    --需要的花费
    if(_costType[p_index] == 1)then
        local richInfo = {
        lineAlignment = 2,
        elements = {} }
            richInfo.elements[1] = {
                    ["type"] = "CCRenderLabel", 
                    newLine = false, 
                    text = GetLocalizeStringBy("djn_110"),   --神兵令
                    font = g_sFontName,
                    size = 25,
                    color = ccc3(0xff,0xe4,0x00)}
            richInfo.elements[2] = {
                    ["type"] = "CCSprite", 
                    newLine = false, 
                    image = "images/god_weapon/shop/token.png"}   --神兵令图片
            richInfo.elements[3] = {
                    ["type"] = "CCRenderLabel", 
                    newLine = false, 
                    text = cost[2],     --显示数量
                    font = g_sFontName,
                    size = 25,
                    color = ccc3(0xff,0xff,0xff)}

        local midSp = LuaCCLabel.createRichLabel(richInfo)
        midSp:setAnchorPoint(ccp(0,0))
        midSp:setPosition(ccp(innerBgSprite:getContentSize().width*0.4,innerBgSprite:getContentSize().height*0.3))
        innerBgSprite:addChild(midSp)

    elseif(_costType[p_index] ==2)then
        local richInfo = {lineAlignment = 2,elements = {}}
            richInfo.elements[1] = {
                    ["type"] = "CCRenderLabel", 
                    text = GetLocalizeStringBy("key_1298"),  --用金币兑换
                    font = g_sFontName,
                    size = 25,
                    color = ccc3(0xff,0xe4,0x00),}
            richInfo.elements[2] = {
                    ["type"] = "CCSprite", 
                    image = "images/common/gold.png"}
            richInfo.elements[3] = {
                    ["type"] = "CCRenderLabel",  
                    text = cost[2],
                    font = g_sFontName,
                    size = 30,
                    color = ccc3(0xff,0xff,0xff)}

        local midSp = LuaCCLabel.createRichLabel(richInfo)
        midSp:setAnchorPoint(ccp(0,0))
        midSp:setPosition(ccp(innerBgSprite:getContentSize().width*0.4,innerBgSprite:getContentSize().height*0.3))
        innerBgSprite:addChild(midSp)

    elseif(_costType[p_index]==3)then
        local richInfo = {lineAlignment = 2,elements = {}}
            richInfo.elements[1] = {
                    ["type"] = "CCRenderLabel", 
                    text = GetLocalizeStringBy("key_1687"),  --用银币兑换
                    font = g_sFontName,
                    size = 25,
                    color = ccc3(0xff,0xe4,0x00),}
            richInfo.elements[2] = {
                    ["type"] = "CCSprite", 
                    image = "images/common/coin_silver.png"}
            richInfo.elements[3] = {
                    ["type"] = "CCRenderLabel",  
                    text = cost[2],
                    font = g_sFontName,
                    size = 30,
                    color = ccc3(0xff,0xff,0xff)}

        local midSp = LuaCCLabel.createRichLabel(richInfo)
        midSp:setAnchorPoint(ccp(0,0))
        midSp:setPosition(ccp(innerBgSprite:getContentSize().width*0.4,innerBgSprite:getContentSize().height*0.3))
        innerBgSprite:addChild(midSp)
    end

    -- ----横线
    -- local lineSprite = CCSprite:create("images/item/equipinfo/line.png")
    -- lineSprite:setScaleX(2.8)
    -- lineSprite:setAnchorPoint(ccp(0, 0))
    -- lineSprite:setPosition(ccp(innerBgSprite:getContentSize().width * 0.2,innerBgSprite:getContentSize().height *0.6))
    -- innerBgSprite:addChild(lineSprite)
    -- ------描述
    -- local items = GodShopData.getRewardInDb(p_cellValue.id)
    -- local descLabel = CCLabelTTF:create(ItemUtil.getItemById(items[1].tid).desc, g_sFontName, 21, CCSizeMake(285,55), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    -- descLabel:setPosition(ccp(innerBgSprite:getContentSize().width * 0.25,innerBgSprite:getContentSize().height *0.1))
    -- descLabel:setColor(ccc3(0x78,0x25,0x00))
    -- innerBgSprite:addChild(descLabel)

    --显示菜单栏回调
    local function showDownMenu()
        MainScene.setMainSceneViewsVisible(false,false,false)
    end
    local rewardInDb = GodShopData.getRewardInDb(p_cellValue.id)[1]
    local icon,itemName,itemColor = ItemUtil.createGoodsIcon(rewardInDb,GodShopLayer.getTouchPriority()-80,
                                                             GodShopLayer.getZOrder()+10,nil,showDownMenu,nil,nil,false)
    --头像
    --local icon = ItemUtil.createGoodsIcon(GodShopData.getRewardInDb(p_cellValue.id)[1],GodShopLayer.getTouchPriority()-80,GodShopLayer.getZOrder()+10,nil,nil,nil,nil,false)
    icon:setPosition(10,20)
    innerBgSprite:addChild(icon)

  
    ------名称
    local nameLabel = CCRenderLabel:create(itemName, g_sFontPangWa,24,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
    innerBgSprite:addChild(nameLabel)
    nameLabel:setAnchorPoint(ccp(0,0))
    nameLabel:setColor(itemColor)  --字体填充颜色
    nameLabel:setPosition(ccp(innerBgSprite:getContentSize().width*0.4,innerBgSprite:getContentSize().height*0.65))
    

    --按钮层
    local cellMenu = BTMenu:create(true)
    cellMenu:setScrollView(p_tableView)
    cellMenu:setAnchorPoint(ccp(0,0))
    cellMenu:setPosition(ccp(0,0))
    cellMenu:setTouchPriority(GodShopLayer.getTouchPriority()-50)
    cellBgSprite:addChild(cellMenu)

    --按钮位置
    local btnPosX = (cellBgSprite:getContentSize().width + innerBgSprite:getContentSize().width)/2

    --兑换按钮
    local exchangeMenuItem = nil
    local buyStr = ""
    if(_costType[p_index] == 1 or _costType[p_index] == 3)then
    
        exchangeMenuItem = LuaCC.create9ScaleMenuItemWithoutLabel("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png","images/common/btn/btn_blue_hui.png",
                             CCSizeMake(120,65))
        buyStr = GetLocalizeStringBy("key_2689")
    elseif(_costType[p_index] == 2 )then
        --用金币买的 按钮是紫色的 防止玩家手抖后又投诉
        exchangeMenuItem = LuaCC.create9ScaleMenuItemWithoutLabel("images/common/btn/btn_violet_n.png","images/common/btn/btn_violet_h.png","images/common/btn/btn_blue_hui.png",
                             CCSizeMake(160,65))
        buyStr = GetLocalizeStringBy("djn_170")
    end
    exchangeMenuItem:setAnchorPoint(ccp(0.5,0.5))
    exchangeMenuItem:setPosition(ccp(btnPosX,50 + innerBgSprite:getContentSize().height/2))
    exchangeMenuItem:registerScriptTapHandler(buyBtnCb)
    cellMenu:addChild(exchangeMenuItem,1,p_index)
   
    --“兑换”字
    local buyLabel = CCRenderLabel:create(buyStr,g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_stroke)  --这里面的颜色设置的是边缘颜色
    buyLabel:setColor(ccc3(0xff,0xe4,0x00)) --字体填充颜色
    buyLabel:setAnchorPoint(ccp(0.5,0.5))
    buyLabel:setPosition(ccp(exchangeMenuItem:getContentSize().width *0.5,exchangeMenuItem:getContentSize().height *0.5))
    exchangeMenuItem:addChild(buyLabel)
    -- if(_remainCount[p_cellValue.id] <= 0)then
    --     exchangeMenuItem:setEnabled(false)
    --     buyLabel:setColor(ccc3(0x7f,0x7f,0x7f))
    -- end
    ------剩余次数
    local numLabel = CCLabelTTF:create(GetLocalizeStringBy("djn_113",_remainCount[p_index]), g_sFontName, 20)
    cellBgSprite:addChild(numLabel)
    numLabel:setAnchorPoint(ccp(0.5,0))
    numLabel:setPosition(ccp(btnPosX,40))
    numLabel:setColor(ccc3(0x00,0x00,0x00))

    ----判断是否是碎片 如果是碎片 需要展示当前已拥有及需要多少个来合成 
    if(ItemUtil.isFragment(rewardInDb.tid))then
        local haveNum = ItemUtil.getCacheItemNumBy(rewardInDb.tid)
        local needNum = GodShopData.getTotalNumInDb(rewardInDb.tid) or 0
        local numColor = haveNum >= needNum and ccc3(0x00,0xff,0x18) or ccc3(0xe8,0x00,0x00)
        -- local fraNumLabel = CCLabelTTF:create("("..haveNum.."/"..needNum..")",g_sFontName,20)
        -- fraNumLabel:setColor(ccc3(0x00,0x00,0x00))
        -- fraNumLabel:setAnchorPoint(ccp(0.5,0))
        -- fraNumLabel:setPosition(ccpsprite(0.5,1.02,exchangeMenuItem))

        local richInfo = {lineAlignment = 1,elements = {}}
            richInfo.elements[1] = {
                    ["type"] = "CCRenderLabel", 
                    text = GetLocalizeStringBy("key_3413"),
                    font = g_sFontName,
                    size = 20,
                    color = ccc3(0x00,0xff,0x18),}
            richInfo.elements[2] = {
                    ["type"] = "CCRenderLabel", 
                    text = "("..haveNum.."/"..needNum..")",g_sFontName,
                    font = g_sFontName,
                    size = 20,
                    color = numColor,}
        local numSp = LuaCCLabel.createRichLabel(richInfo)
        numSp:setAnchorPoint(ccp(0,0))
        numSp:setPosition(ccp(innerBgSprite:getContentSize().width*0.4,innerBgSprite:getContentSize().height*0.1))
        innerBgSprite:addChild(numSp)
    end

    return tCell
end
function buyBtnCb(tag)
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    if(_remainCount[tag] > 0 )then
        require "script/ui/godweapon/godweaponshop/GodShopAlertCost"
        _selectedTag = tag
        local shopInfo,_ = GodShopData.getGoodListForCell()
        GodShopAlertCost.showLayer(shopInfo[tag].id,GodShopLayer.refreshUIByCell,GodShopLayer.getTouchPriority()-80,GodShopLayer.getZOrder()+10)
    else
        --当前剩余兑换次数为0

        require "script/ui/tip/AnimationTip"
        if(_costType[tag] == 1 or _costType[tag] == 3)then
            AnimationTip.showTip(GetLocalizeStringBy("djn_116",GetLocalizeStringBy("key_2689"),GetLocalizeStringBy("key_2689")))
        elseif(_costType[tag] == 2)then
            AnimationTip.showTip(GetLocalizeStringBy("djn_116",GetLocalizeStringBy("key_3420"),GetLocalizeStringBy("key_3420")))
        end
    end
end
function getSelectedTag( ... )
   return _selectedTag
end