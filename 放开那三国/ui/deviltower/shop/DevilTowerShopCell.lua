-- FileName: DevilTowerShopCell.lua 
-- Author: fuqiongqiong
-- Date: 2016-7-29
-- Purpose:试练塔商店Cell

module("DevilTowerShopCell",package.seeall)
require "script/ui/deviltower/shop/DevilTowerShopBuyLayer"
require "script/ui/deviltower/shop/DevilTowerShopData"
function createCell( p_cellInfo, p_index,p_touch)
	local cell = CCTableViewCell:create()
    --背景图片
    local cellBgSprite = CCScale9Sprite:create("images/reward/cell_back.png")
    cellBgSprite:setContentSize(CCSizeMake(454,182))
    cellBgSprite:setScale(g_fScaleX)
    cell:addChild(cellBgSprite)

    --二级背景图片
    local innerBgSprite = CCScale9Sprite:create("images/reward/item_back.png")
    innerBgSprite:setContentSize(CCSizeMake(290,116))
    innerBgSprite:setPosition(ccp(30,50))
    cellBgSprite:addChild(innerBgSprite)
    local item = nil
    local nameColor = nil
    local item_type, item_id, item_num = DevilTowerShopData.getItemData(p_cellInfo.items)
    -- if(tonumber(item_type) == 1)then
    --     -- DB_Contest_shop表中每条数据中的 物品数据
    --     require "script/ui/item/ItemUtil"
    --     item_data = ItemUtil.getItemById(item_id)
    --     iconSprite = ItemSprite.getItemSpriteById(item_id,nil, showDownMenu)
    --     iconSprite:setAnchorPoint(ccp(0,0))
    --     iconSprite:setPosition(ccp(12,12))
    --     innerBgSprite:addChild(iconSprite)
    --     local quality = ItemUtil.getTreasureQualityByTid(item_id)
    --     nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    --     -- 显示物品的数量
    --     local num_data = item_num or 1
    --     local num_font = CCRenderLabel:create(num_data, g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    --     num_font:setColor(ccc3(0x70, 0xff, 0x18))
    --     num_font:setAnchorPoint(ccp(1,0))
    --     num_font:setPosition(ccp(iconSprite:getContentSize().width-5,2))
    --     iconSprite:addChild(num_font)
    -- elseif(tonumber(item_type) == 2)then
    --     -- -- DB_Contest_shop表中每条数据中的 英雄数据
    --     require "script/model/utils/HeroUtil"
    --     item_data = HeroUtil.getHeroLocalInfoByHtid(item_id)
    --     iconSprite = HeroUtil.getHeroIconByHTID(item_id)
    --     local menu = CCMenu:create()
    --     menu:setPosition(ccp(0,0))
    --     innerBgSprite:addChild(menu)
    --     local iconItem = CCMenuItemSprite:create(iconSprite,iconSprite)
    --     iconItem:setAnchorPoint(ccp(0,0))
    --     iconItem:setPosition(ccp(12,12))
    --     menu:addChild(iconItem,1,tonumber(item_id))
    --     iconItem:registerScriptTapHandler(heroSpriteCb)
    --     nameColor = HeroPublicLua.getCCColorByStarLevel(item_data.star_lv)
    --     -- 显示物品的数量
    --     local num_data = item_num or 1
    --     local num_font = CCRenderLabel:create(num_data, g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    --     num_font:setColor(ccc3(0x70, 0xff, 0x18))
    --     num_font:setAnchorPoint(ccp(1,0))
    --     num_font:setPosition(ccp(iconItem:getContentSize().width-8,3))
    --     iconItem:addChild(num_font)
    -- end
    -- local itemDesStr = p_cellInfo.type.."|"..p_cellInfo.tid.."|"..p_cellInfo.num
    local rewardInDb = ItemUtil.getItemsDataByStr(p_cellInfo.items)
    local icon,itemName,itemColor = ItemUtil.createGoodsIcon(rewardInDb[1],-730,1100,-900,function ( ... )
        end,nil,nil,false)
    icon:setPosition(ccp(10,20))
    innerBgSprite:addChild(icon)
    local nameLabel = CCRenderLabel:create(itemName, g_sFontPangWa,24,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
    nameLabel:setPosition(ccp(innerBgSprite:getContentSize().width*0.4,innerBgSprite:getContentSize().height*0.8))
    nameLabel:setColor(itemColor)
    innerBgSprite:addChild(nameLabel)

    -- 物品名称
    -- local nameLabel = CCRenderLabel:create(item_data.name, g_sFontPangWa, 24, 1, ccc3(0x00, 0x00, 0x00), type_shadow)
    -- nameLabel:setColor(nameColor)
    -- nameLabel:setPosition(110, 100)
    -- innerBgSprite:addChild(nameLabel)
    -- local rewardInDb = ItemUtil.getItemsDataByStr(p_cellInfo.items)
    -- local icon,itemName,itemColor = ItemUtil.createGoodsIcon(rewardInDb[1],-800,800,-900,function ( ... )
    --     end,nil,nil,false)
    -- icon:setPosition(ccp(10,20))
    -- innerBgSprite:addChild(icon)
    -- local nameLabel = CCRenderLabel:create(itemName, g_sFontPangWa,24,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
    -- nameLabel:setPosition(ccp(innerBgSprite:getContentSize().width*0.4,innerBgSprite:getContentSize().height*0.8))
    -- nameLabel:setColor(itemColor)
    -- innerBgSprite:addChild(nameLabel)
    local richInfo = {
        lineAlignment = 2,
        labelDefaultColor = ccc3(0xff,0xf6,0x00),
        labelDefaultSize  = 18,
        defaultType = "CCRenderLabel",
        elements = {
           {
                ["type"] = "CCSprite",
                image = "images/tower/jifenbi.png",
            },
            {
                text = tostring(p_cellInfo.cost_nightmare),
                color = ccc3(0xff,0xff,0xff),
            }
        }
    }
    local priceLabel = GetLocalizeLabelSpriteBy_2(GetLocalizeStringBy("fqq_129"),richInfo)
    innerBgSprite:addChild(priceLabel)
    priceLabel:setAnchorPoint(ccp(0, 0.5))
    priceLabel:setPosition(ccp(innerBgSprite:getContentSize().width*0.4,innerBgSprite:getContentSize().height*0.35))

    local cellMenu = CCMenu:create()
    cellMenu:setPosition(ccp(0,0))
    cellMenu:setTouchPriority(p_touch)
    cellBgSprite:addChild(cellMenu)
    --可兑换次数
    local canExchangeNum = tonumber(p_cellInfo.baseNum) - DevilTowerShopData.getInfoOfGoods(p_cellInfo.id)
    print("~~~~~~~~~~",canExchangeNum)
    local exchangeNum = nil
    local exchangeTypeStr = nil
    if( tonumber(p_cellInfo.limitType) == 1)then
        exchangeTypeStr = "key_10103" --今日可兑换 次
    elseif tonumber(p_cellInfo.limitType) == 2 then
        exchangeTypeStr = "key_10104"--总共可兑换 次
    elseif tonumber(p_cellInfo.limitType) == 3 then
        exchangeTypeStr = "key_10105"  --本周可兑换 次
    end

    local typeLabel = CCRenderLabel:create(GetLocalizeStringBy(exchangeTypeStr,canExchangeNum),g_sFontName,18,1,ccc3(0x00,0x00,0x00),type_stroke)
    typeLabel:setColor(ccc3(0x00,0xff,0x18))
    typeLabel:setAnchorPoint(ccp(0,0))
    typeLabel:setPosition(ccp(35,24))
    cellBgSprite:addChild(typeLabel)

    --兑换按钮
    local exchangeMenuItem = LuaCC.create9ScaleMenuItemWithoutLabel("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png","images/common/btn/btn_blue_hui.png",
        CCSizeMake(120,65))
    exchangeMenuItem:setAnchorPoint(ccp(0,0.5))
    exchangeMenuItem:setPosition(ccp(innerBgSprite:getPositionX()+innerBgSprite:getContentSize().width,innerBgSprite:getPositionY()+innerBgSprite:getContentSize().height/2))
    cellMenu:addChild(exchangeMenuItem,1, tonumber(p_index))

    --“兑换”字
    local buyLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2689"),g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_stroke)
    buyLabel:setColor(ccc3(0xff,0xe4,0x00))
    buyLabel:setAnchorPoint(ccp(0.5,0.5))
    buyLabel:setPosition(ccp(exchangeMenuItem:getContentSize().width *0.5,exchangeMenuItem:getContentSize().height *0.5))
    exchangeMenuItem:addChild(buyLabel)
    if  canExchangeNum == 0 then
        exchangeMenuItem:setVisible(false)
        local hasReceiveItem = CCSprite:create("images/common/yiduihuan.png")
        hasReceiveItem:setAnchorPoint(ccp(0,0.5))
        hasReceiveItem:setPosition(ccp(innerBgSprite:getPositionX()+innerBgSprite:getContentSize().width,innerBgSprite:getPositionY()+innerBgSprite:getContentSize().height/2))
        cellBgSprite:addChild(hasReceiveItem) 
    end 
    exchangeMenuItem:registerScriptTapHandler(exchangeNumCallBack)

    
	return cell 
end
function exchangeNumCallBack( tag )
    --判断背包
    require "script/ui/item/ItemUtil"
    if(ItemUtil.isBagFull() == true )then
        return
    end
     -- 判断武将满了
    require "script/ui/hero/HeroPublicUI"
    if HeroPublicUI.showHeroIsLimitedUI() then
        return
    end
    DevilTowerShopBuyLayer.showPurchaseLayer(tag)
end
-- 获得英雄的信息
 function getHeroData( htid)
    value = {}

    value.htid = htid
    require "db/DB_Heroes"
    local db_hero = DB_Heroes.getDataById(htid)
    value.country_icon = HeroModel.getCiconByCidAndlevel(db_hero.country, db_hero.star_lv)
    value.name = db_hero.name
    value.level = db_hero.lv
    value.star_lv = db_hero.star_lv
    value.hero_cb = menu_item_tap_handler
    value.head_icon = "images/base/hero/head_icon/" .. db_hero.head_icon_id
    value.quality_bg = "images/hero/quality/"..value.star_lv .. ".png"
    value.quality_h = "images/hero/quality/highlighted.png"
    value.type = "HeroFragment"
    value.isRecruited = false
    value.evolve_level = 0

    return value
end
-- 点击英雄头像的回调函数
function heroSpriteCb( tag,menuItem )
    local data = getHeroData(tag)
    local tArgs = {}
    tArgs.sign = "PrestigeShop"
    tArgs.fnCreate = PrestigeShop.createPrestigeShopLayer
    tArgs.reserved =  {index= 10001}
    HeroInfoLayer.createLayer(data, {isPanel=true})
end
