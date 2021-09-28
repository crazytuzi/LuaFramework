-- FileName: TallyShopCell.lua
-- Author: FQQ
-- Date: 2016-01-07
-- Purpose: 兵符商店Cell
module("TallyShopCell",package.seeall)

-- 触摸优先级
local _touchPriority = nil
-- 兑换次数文本的内容
local _timeTxt = nil
-- 当前显示的物品信息
local _itemInfo = nil
--点击兑换按钮后出现的提示框
local _buyAlertTip = nil

--[[
    @des    : 移除掉提示框
    @param  : 
    @return : 
--]]
function removeBuyAlertTip( ... )
    if(_buyAlertTip ~= nil)then
        _buyAlertTip:removeFromParentAndCleanup(true)
        _buyAlertTip = nil
    end
end

function createUI( pCell,pItemInfo )
	-- body
	_touchPriority = -839
	-- 背景
    local cellBg = CCScale9Sprite:create("images/reward/cell_back.png")
    cellBg:setContentSize(CCSizeMake(442,164))
    pCell:addChild(cellBg)
    cellBg:setScale(g_fScaleX)
    -- 白底
    local itemBg= CCScale9Sprite:create("images/reward/item_back.png")
    itemBg:setAnchorPoint(ccp(0,0.5))
    itemBg:setContentSize(CCSizeMake(274,115))
    itemBg:setPosition(ccpsprite(0.05,0.5,cellBg))
    cellBg:addChild(itemBg)
    -- 商品图标
    local itemData = ItemUtil.getItemsDataByStr(pItemInfo.items)[1]
    local icon = ItemUtil.createGoodsIcon(itemData,_touchPriority - 10,nil,_touchPriority - 25,nil,false,false,false,true)
    icon:setPosition(ccp(33,36))
    cellBg:addChild(icon)
    -- 商品信息
    local itemInfo = ItemUtil.getItemById(tonumber(itemData.tid))
    -- 支付类型信息
    local itemCostData = ItemUtil.getItemsDataByStr(pItemInfo.cost)[1]
    local priceLabelColor = nil
    local priceIconPath = nil
    local btnNormalImage = nil
    local btnSelectImage = nil
    local btnText = nil
    if itemCostData.type == "tally_point" then
        priceLabelColor = ccc3( 0xff, 0xf6, 0x00)
        priceIconPath = "images/tally/bingfu.png"
        btnNormalImage = "images/common/btn/btn_blue_n.png"
        btnSelectImage = "images/common/btn/btn_blue_h.png"
        btnText = GetLocalizeStringBy("key_2689")
    elseif itemCostData.type == "silver" then
        priceLabelColor = ccc3( 0xff, 0xff, 0xff)
        priceIconPath = "images/common/coin_silver.png"
        btnNormalImage = "images/common/btn/btn_violet_n.png"
        btnSelectImage = "images/common/btn/btn_violet_h.png"
        btnText = GetLocalizeStringBy("key_1523")
    elseif itemCostData.type == "gold" then
        priceLabelColor = ccc3( 0xff, 0xf6, 0x00)
        priceIconPath = "images/common/gold.png"
        btnNormalImage = "images/common/btn/btn_violet_n.png"
        btnSelectImage = "images/common/btn/btn_violet_h.png"
        btnText = GetLocalizeStringBy("key_1523")
    end
    local nameColor = HeroPublicLua.getCCColorByStarLevel(itemInfo.quality)
    local richInfo = {
        linespace = 8, -- 行间距
        alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
        lineAlignment = 2, -- 当前行在竖直方向上的对齐方式 1，下对齐， 2，居中， 3，上对齐
        labelDefaultFont = g_sFontPangWa,
        labelDefaultColor = ccc3( 0xff, 0xff, 0xff),
        labelDefaultSize = 18,
        defaultType = "CCRenderLabel",
        elements =
        {
            {
                type = "CCRenderLabel", 
                newLine = false,
                text = itemInfo.name,
                size = 23,
                color = nameColor,
                renderType = 2,-- 1 描边， 2 投影
            },
            {
                type = "CCRenderLabel", 
                newLine = true,
                text = string.format("%s: ",itemCostData.name),
                color = priceLabelColor,
                renderType = 2,-- 1 描边， 2 投影
            },
            {
                ["type"] = "CCSprite",
                image = priceIconPath,  --"银币图片"
            },
            {
                type = "CCRenderLabel", 
                newLine = false,
                text = itemCostData.num,
                renderType = 2,-- 1 描边， 2 投影
            },
        }
    }
    -- 如果是碎片类型
    -- 已拥有的碎片的数量
    local itemCount = 0 
    if ItemUtil.isFragment(tonumber(itemData.tid)) then
        itemCount = pItemInfo.itemCount
        local needCount = itemInfo.need_part_num
        local textColor = nil
        if needCount > itemCount then
            textColor = ccc3( 0xff, 0, 0)
        else
            textColor = ccc3( 0x00, 0xff, 0x18)
        end
        local element = {
            {
                newLine = true,
                color = ccc3( 0x00, 0xff, 0x18),
                text = GetLocalizeStringBy("lcyx_1939"),
                renderType = 2,-- 1 描边， 2 投影
            },
            {
                newLine = false,
                color = textColor,
                text = string.format("%d/%d", itemCount, needCount),
                renderType = 2,-- 1 描边， 2 投影
            }
        }
        richInfo.elements = table.connect({richInfo.elements,element})
    end
    _priceLabel = LuaCCLabel.createRichLabel(richInfo)
    _priceLabel:setAnchorPoint(ccp(0, 1))
    _priceLabel:setPosition(ccp(128,130))
    cellBg:addChild(_priceLabel)
    -- 兑换按钮
    local menu= CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(_touchPriority - 20)
    cellBg:addChild(menu)
    local exchangeHandler = function ( ... )
        -- 音效
        require "script/audio/AudioUtil"
        AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
        local richInfo = {
            linespace = 10,
            elements = {
                {
                    ["type"] = "CCSprite",
                    image = priceIconPath
                },
                {
                    text = itemCostData.num,
                },
                {
                    font = g_sFontPangWa,
                    text = string.format(GetLocalizeStringBy("key_10230"), itemData.num)
                },
                {
                    type = "CCRenderLabel",
                    font = g_sFontPangWa,
                    text = itemInfo.name,
                    color = nameColor,
                }
            }
        }
        local newRichInfo = nil
        if itemCostData.name ~= GetLocalizeStringBy("fqq_050") then
            --商品为消耗兵符令的商品时
            newRichInfo = GetNewRichInfo(GetLocalizeStringBy("key_10231"), richInfo)
        else
            --商品为消耗金币的商品时
            newRichInfo = GetNewRichInfo(GetLocalizeStringBy("key_10232"), richInfo)
        end
        local alertCallback = function ( isConfirm, _argsCB )
            if not isConfirm then
                return
            end
            TallyShopController.buyTally(pItemInfo,itemData.num)
        end
        _buyAlertTip = RichAlertTip.showAlert(newRichInfo, alertCallback, true, nil, GetLocalizeStringBy("key_8129"), nil, nil, nil, nil, nil, nil, true)
    end
    local exchangeItem = CCMenuItemImage:create(btnNormalImage,btnSelectImage)
    exchangeItem:setAnchorPoint(ccp(0.5,0.5))
    exchangeItem:setPosition(360,100)
    exchangeItem:registerScriptTapHandler(exchangeHandler)
    menu:addChild(exchangeItem,1)
    -- 按钮文字
    local item_font = CCRenderLabel:create(btnText, g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    item_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
    item_font:setAnchorPoint(ccp(0.5,0.5))
    item_font:setPosition(ccp(exchangeItem:getContentSize().width*0.5,exchangeItem:getContentSize().height*0.5))
    exchangeItem:addChild(item_font)
    -- "兑换次数"
    local timeLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2696"),g_sFontName,21)
    timeLabel:setAnchorPoint(ccp(0,1))
    timeLabel:setColor(ccc3( 0x00, 0x00, 0x00))
    timeLabel:setPosition(ccpsprite(0,0,exchangeItem))
    exchangeItem:addChild(timeLabel)
    local time = pItemInfo.canExchangeNum
    local timeValueLabel = CCLabelTTF:create(time,g_sFontName,21)
    timeValueLabel:setAnchorPoint(ccp(0,0.5))
    timeValueLabel:setColor(ccc3( 0x00, 0x00, 0x00))
    timeValueLabel:setPosition(ccpsprite(1,0.5,timeLabel))
    timeLabel:addChild(timeValueLabel)
    local canExchangeNum = pItemInfo.canExchangeNum
    if canExchangeNum < 1 then
         exchangeItem:setVisible(false)
            if itemCostData.type == "tally_point" then
                    local hasReceiveItem = CCSprite:create("images/common/yiduihuan.png")
                    hasReceiveItem:setAnchorPoint(ccp(0.5,0.5))
                    hasReceiveItem:setPosition(ccp(360,90))
                    cellBg:addChild(hasReceiveItem) 
            else
                    local hasReceiveItem = CCSprite:create("images/common/yigoumai.png")
                    hasReceiveItem:setAnchorPoint(ccp(0.5,0.5))
                    hasReceiveItem:setPosition(ccp(360,90))
                    cellBg:addChild(hasReceiveItem) 
            end
   
    end
end

function createCell( pItemInfo )
    local cell = CCTableViewCell:create()
    createUI(cell,pItemInfo)
    return cell
end