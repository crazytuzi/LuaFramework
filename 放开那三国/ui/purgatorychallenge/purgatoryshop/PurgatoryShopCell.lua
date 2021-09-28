-- Filename: PurgatoryShopCell.lua
-- Author: lichenyang
-- Date: 2015-05-06
-- Purpose: 个人跨服赛商店cell

module("PurgatoryShopCell", package.seeall)

local p_cellInfo = nil
local _index = nil
local _priority = nil
function createCell( p_cellInfo, p_index ,p_touch)
 --    local goodsId = p_index
 --    local groupCopyShopDb = DB_GroupCopy_shop.getDataById(goodsId)
	-- local shopInfo = GuildBossCopyData.getShopInfo()
	-- local goodInfo = shopInfo[tostring(goodsId)]
    _index = p_index
    _priority = p_touch
    local cell = CCTableViewCell:create()
    cell:setContentSize(CCSizeMake(605*g_fScaleX, 190*g_fScaleX))
    --背景图片
    local cellBgSprite = CCScale9Sprite:create("images/common/bg/bg_9s_6.png")
    cellBgSprite:setContentSize(CCSizeMake(570, 185))
    cellBgSprite:setAnchorPoint(ccp(0,0))
    cellBgSprite:setPosition(ccp(35/2,5/2))
    cell:addChild(cellBgSprite)

    --二级背景图片
    local innerBgSprite = CCScale9Sprite:create("images/copy/fort/textbg.png")
    innerBgSprite:setContentSize(CCSizeMake(350,120))
    innerBgSprite:setAnchorPoint(ccp(0,0))
    innerBgSprite:setPosition(ccp(25,45))
    cellBgSprite:addChild(innerBgSprite)

    local itemDesStr = p_cellInfo.type.."|"..p_cellInfo.tid.."|"..p_cellInfo.itemNum

    local rewardInDb = ItemUtil.getItemsDataByStr(itemDesStr)
    local icon,itemName,itemColor = ItemUtil.createGoodsIcon(rewardInDb[1], -500, 800, nil,function ( ... )
        print("ItemUtil.createGoodsIcon")
        print_t(p_cellInfo)
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
            dialog:show(-750, 800)

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
                PurgatoryShopController.buy(p_index, dialog:getNum())
            end)
            dialog:registerChangeCallback(function ( pNum )
                childNodes[3]:setString(tostring(p_cellInfo.costNum * pNum))
            end)
        end
    end


    --按钮位置
    local btnPosX = (cellBgSprite:getContentSize().width + innerBgSprite:getContentSize().width)/2

    --兑换按钮
    local exchangeMenuItem = LuaCC.create9ScaleMenuItemWithoutLabel("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png","images/common/btn/btn_blue_hui.png",
                             CCSizeMake(120,65))
    exchangeMenuItem:setAnchorPoint(ccp(0.5,0.5))
    exchangeMenuItem:setPosition(ccp(btnPosX,50 + innerBgSprite:getContentSize().height/2))
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
    local exchangeDesLabel = CCRenderLabel:create(GetLocalizeStringBy("lcyx_1911",canExchangeNum),g_sFontName,18,1,ccc3(0x00,0x00,0x00),type_stroke)
    exchangeDesLabel:setColor(ccc3(0x00,0xff,0x18))
    exchangeDesLabel:setAnchorPoint(ccp(0.5,0.5))
    exchangeDesLabel:setPosition(ccp(exchangeMenuItem:getPositionX(),exchangeMenuItem:getPositionY()-exchangeMenuItem:getContentSize().height*0.5-exchangeDesLabel:getContentSize().height))
    cellBgSprite:addChild(exchangeDesLabel)
    if tonumber(p_cellInfo.exchangeCount) == 0 then
        --可以无限兑换的不显示
        exchangeDesLabel:setVisible(false)
    end

    if tonumber(p_cellInfo.exchangeCount) > 0 and canExchangeNum == 0 then
        exchangeMenuItem:setEnabled(false)
        exchangeDesLabel:setVisible(false)
        buyLabel:setColor(ccc3(100,100,100))
    end


    -- if goodInfo.remain == 0 or not GuildBossCopyData.isPassedGroupCopy(groupCopyLimit) then
    --     exchangeMenuItem:setEnabled(false)
    --     buyLabel:setColor(ccc3(0x88, 0x88, 0x88))
    -- end
    return cell
end


