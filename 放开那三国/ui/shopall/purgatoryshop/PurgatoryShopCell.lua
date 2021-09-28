-- Filename: PurgatoryShopCell.lua
-- Author: lichenyang
-- Date: 2015-05-06
-- Purpose: 炼狱商店cell

module("PurgatoryShopCell", package.seeall)

local p_cellInfo = nil
local _index = nil
local _priority = nil
function createCell( p_cellInfo, p_index,p_touch)

    _index = p_index
    _priority = p_touch
    local cell = CCTableViewCell:create()
    --背景图片
    local cellBgSprite = CCScale9Sprite:create("images/common/bg/bg_9s_6.png")
    cellBgSprite:setContentSize(CCSizeMake(454, 182))
    -- cellBgSprite:setAnchorPoint(ccp(0,0))
    -- cellBgSprite:setPosition(ccp(35/2,5/2))
    cellBgSprite:setScale(g_fScaleX)
    cell:addChild(cellBgSprite)

    --二级背景图片
    local innerBgSprite = CCScale9Sprite:create("images/copy/fort/textbg.png")
    innerBgSprite:setContentSize(CCSizeMake(290, 116))
    innerBgSprite:setAnchorPoint(ccp(0,0))
    -- innerBgSprite:setScale(g_fElementScaleRatio)
    innerBgSprite:setPosition(ccp(30,50))
    cellBgSprite:addChild(innerBgSprite)

    local itemDesStr = p_cellInfo.type.."|"..p_cellInfo.tid.."|"..p_cellInfo.itemNum

    local rewardInDb = ItemUtil.getItemsDataByStr(itemDesStr)
    local icon,itemName,itemColor = ItemUtil.createGoodsIcon(rewardInDb[1], -800, 800, -900,function ( ... )
        print("ItemUtil.createGoodsIcon")
    end,nil,nil,false)
    icon:setPosition(10,20)
    innerBgSprite:addChild(icon)


    local nameLabel = CCRenderLabel:create(itemName, g_sFontPangWa,24,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
    innerBgSprite:addChild(nameLabel)
    nameLabel:setAnchorPoint(ccp(0,0))
    nameLabel:setColor(itemColor)
    nameLabel:setPosition(ccp(innerBgSprite:getContentSize().width*0.4,innerBgSprite:getContentSize().height*0.65))

    local richInfo = {
        lineAlignment = 2,
        labelDefaultColor = ccc3(0xff, 0xe4, 0x00),
        labelDefaultSize = 23,
        defaultType = "CCRenderLabel",
        elements = {
            {
                ["type"] = "CCSprite",
                image = "images/purgatory/lianyulingsmall.png",
            },
            {
                text = tostring(p_cellInfo.costNum),
                color = ccc3(0xff, 0xff, 0xff),
            }
        }
    }
    local priceLabel = GetLocalizeLabelSpriteBy_2(GetLocalizeStringBy("llp_209"), richInfo)
    innerBgSprite:addChild(priceLabel)
    priceLabel:setAnchorPoint(ccp(0, 0.5))
    priceLabel:setPosition(ccp(innerBgSprite:getContentSize().width*0.4,innerBgSprite:getContentSize().height*0.45))


    --按钮层
    local cellMenu = CCMenu:create()
    cellMenu:setAnchorPoint(ccp(0,0))
    cellMenu:setPosition(ccp(0,0))
    cellMenu:setTouchPriority(_priority)
    cellBgSprite:addChild(cellMenu)

    local buyBtnCb = function( ... )
        if(tonumber(UserModel.getHeroLevel())<(p_cellInfo.needLevel))then
            AnimationTip.showTip(GetLocalizeStringBy("llp_196"))
        else
            require "script/utils/SelectNumDialog"
            local dialog = SelectNumDialog:create()
            dialog:setTitle(GetLocalizeStringBy("lcyx_1910"))
            dialog:show(-810, 800)

            local contentMsgInfo = {}
            contentMsgInfo.labelDefaultColor = ccc3(0xff, 0xf6, 0x00)
            contentMsgInfo.labelDefaultSize = 25
            contentMsgInfo.defaultType = "CCRenderLabel"
            contentMsgInfo.lineAlignment = 1
            contentMsgInfo.labelDefaultFont = g_sFontName
            contentMsgInfo.elements = {
                {
                    text = itemName,
                    color = itemColor,
                    font = g_sFontPangWa,
                    size = 30,
                }
            }
            contentMsgNode = GetLocalizeLabelSpriteBy_2(GetLocalizeStringBy("lcyx_1914"), contentMsgInfo)
            contentMsgNode:setAnchorPoint(ccp(0.5,0.5))
            contentMsgNode:setPosition(ccpsprite(0.5, 0.74, dialog))
            dialog:addChild(contentMsgNode)
            dialog:setLimitNum(p_cellInfo.exchangeCount-p_cellInfo.exchangeNum)
            --争霸令
            local childNodes = {}
            childNodes[1] = CCRenderLabel:create(GetLocalizeStringBy("llp_210"),g_sFontName, 25,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
            childNodes[1]:setColor(ccc3(0xff, 0xf6, 0x00))

            childNodes[2] = CCSprite:create("images/purgatory/lianyulingsmall.png")

            childNodes[3] = CCRenderLabel:create(tostring(p_cellInfo.costNum),g_sFontName, 30, 1,ccc3( 0x00, 0x00, 0x00),type_stroke)
            childNodes[3]:setColor(ccc3(0xff, 0xf6, 0x00))

            contentCostNode = BaseUI.createHorizontalNode(childNodes)
            contentCostNode:setAnchorPoint(ccp(0.5,0.5))
            contentCostNode:setPosition(ccpsprite(0.5, 0.3, dialog))
            dialog:addChild(contentCostNode)


            dialog:registerOkCallback(function ()
                -- 背包满了
                if(ItemUtil.isBagFull() == true )then
                    return
                end
                require "script/ui/purgatorychallenge/purgatoryshop/PurgatoryShopController"
                PurgatoryShopController.buy(p_cellInfo.id, dialog:getNum())
            end)
            dialog:registerChangeCallback(function ( pNum )
                local pointNum = tonumber(PurgatoryData.getCopyInfo().hell_point)
                if(tonumber(p_cellInfo.costNum * pNum) > pointNum)then
                    local num = pointNum%tonumber(p_cellInfo.costNum)
                    local pointNum1 = pointNum - num
                    pNum = tonumber(pointNum1/tonumber(p_cellInfo.costNum))
                    if(pNum == 0)then
                        pNum = 1
                    end
                end
                dialog:setNum(pNum)
                childNodes[3]:setString(tostring(p_cellInfo.costNum * pNum))
            end)
        end
    end


    --按钮位置
    local btnPosX = (cellBgSprite:getContentSize().width + innerBgSprite:getContentSize().width)/2

    --兑换按钮
    local exchangeMenuItem = LuaCC.create9ScaleMenuItemWithoutLabel("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png","images/common/btn/btn_blue_hui.png",
        CCSizeMake(120,65))
    -- exchangeMenuItem:setScale(g_fElementScaleRatio)
    exchangeMenuItem:setAnchorPoint(ccp(0,0.5))
    exchangeMenuItem:setPosition(ccp(innerBgSprite:getPositionX()+innerBgSprite:getContentSize().width,innerBgSprite:getPositionY()+innerBgSprite:getContentSize().height/2))
    exchangeMenuItem:registerScriptTapHandler(buyBtnCb)
    cellMenu:addChild(exchangeMenuItem,1, p_index)

    --“兑换”字
    local buyLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2689"),g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_stroke)
    buyLabel:setColor(ccc3(0xff,0xe4,0x00))
    buyLabel:setAnchorPoint(ccp(0.5,0.5))
    buyLabel:setPosition(ccp(exchangeMenuItem:getContentSize().width *0.5,exchangeMenuItem:getContentSize().height *0.5))
    exchangeMenuItem:addChild(buyLabel)

    --可兑换次数
     local canExchangeNum = tonumber(p_cellInfo.exchangeCount) - tonumber(p_cellInfo.exchangeNum)
    local str = nil
    if( tonumber(p_cellInfo.limitType) == 1)then
        str = string.format(GetLocalizeStringBy("key_10103"), canExchangeNum)  --今日可兑换 次
    elseif tonumber(p_cellInfo.limitType) == 2 then
        str = string.format(GetLocalizeStringBy("key_10104"), canExchangeNum)--总共可兑换 次
    elseif tonumber(p_cellInfo.limitType) == 3 then
        str = string.format(GetLocalizeStringBy("key_10105"), canExchangeNum)  --本周可兑换 次
    end
    local exchangeDesLabel = CCRenderLabel:create( str, g_sFontName, 18, 1, ccc3(0x00, 0x00, 0x00), type_shadow)
    exchangeDesLabel:setColor(ccc3(0x00, 0xff, 0x18))
    exchangeDesLabel:setAnchorPoint(ccp(0,0))
    exchangeDesLabel:setPosition(35, 24)
    cellBgSprite:addChild(exchangeDesLabel)

    if(canExchangeNum <= 0)then
        exchangeMenuItem:setVisible(false)
        local hasReceiveItem = CCSprite:create("images/common/yiduihuan.png")
        hasReceiveItem:setAnchorPoint(ccp(0,0.5))
        hasReceiveItem:setPosition(ccp(innerBgSprite:getPositionX()+innerBgSprite:getContentSize().width,innerBgSprite:getPositionY()+innerBgSprite:getContentSize().height/2))
        cellBgSprite:addChild(hasReceiveItem)
    end
   
    -- local exchangeDesLabel = CCRenderLabel:create(GetLocalizeStringBy("lcyx_1911",canExchangeNum),g_sFontName,18,1,ccc3(0x00,0x00,0x00),type_stroke)
    -- exchangeDesLabel:setColor(ccc3(0x00,0xff,0x18))
    -- exchangeDesLabel:setAnchorPoint(ccp(0,0))
    -- -- exchangeDesLabel:setScale(g_fElementScaleRatio)
    -- exchangeDesLabel:setPosition(ccp(35,24))
    -- cellBgSprite:addChild(exchangeDesLabel)
    if tonumber(p_cellInfo.exchangeCount) == 0 then
        --可以无限兑换的不显示
        exchangeDesLabel:setVisible(false)
    end

    if tonumber(p_cellInfo.exchangeCount) > 0 and canExchangeNum == 0 then
        exchangeMenuItem:setEnabled(false)
        exchangeDesLabel:setVisible(false)
        buyLabel:setColor(ccc3(100,100,100))
    end

    --添加兑换等级限制
    local levelLimit = tonumber(p_cellInfo.needLevel)
    -- print("看看限制等级：",levelLimit)
    -- print("看看玩家的等级：",UserModel.getHeroLevel())
    --判断玩家等级
    if(UserModel.getHeroLevel() < levelLimit)then
        local width = innerBgSprite:getPositionX() + innerBgSprite:getContentSize().width -50
        local labelText = CCLabelTTF:create(GetLocalizeStringBy("key_3131"),g_sFontPangWa,18)
        labelText:setColor(ccc3(0x78, 0x25, 0x00))
        labelText:setPosition(ccp(width,22))
        cellBgSprite:addChild(labelText)
        local labelLv = CCLabelTTF:create(levelLimit,g_sFontPangWa,18)
        labelLv:setColor(ccc3(0x00, 0x8d, 0x3d))
        labelLv:setPosition(ccp(labelText:getPositionX() + labelText:getContentSize().width + 3,22))
        cellBgSprite:addChild(labelLv)
    end

    -- if goodInfo.remain == 0 or not GuildBossCopyData.isPassedGroupCopy(groupCopyLimit) then
    --     exchangeMenuItem:setEnabled(false)
    --     buyLabel:setColor(ccc3(0x88, 0x88, 0x88))
    -- end
    return cell
end





