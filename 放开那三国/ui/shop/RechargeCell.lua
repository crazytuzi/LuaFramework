-- Filename: RechargeCell.lua.
-- Author: zhz  
-- Date: 2013-09-26
-- Purpose: 该文件用于显示充值界面

module("RechargeCell",  package.seeall)

require "script/model/user/UserModel"
require "script/ui/tip/AnimationTip"
require "script/ui/shop/RecharData"


local function goToSeeCallBack( tag, item)

     require "script/ui/rechargeActive/RechargeActiveMain"
    require "script/ui/month_card/MonthCardLayer"
    require "script/ui/shop/RechargeLayer"
    RechargeLayer.closeCb()
    
   
    local monthCardLayer = RechargeActiveMain.create(RechargeActiveMain._tagMonthCard)
    MainScene.changeLayer(monthCardLayer,"monthCardLayer")
end


-- 月卡充值的回调函数
local function monthCardRechargeCallBack( )
    
    local function payMonthCard( isPay )

        if(isPay == false) then
            return
        end
           
        if(RecharData.getCanBuyMonthCard() ==false) then
            AnimationTip.showTip(GetLocalizeStringBy("key_4023"))
            return
        end

        local monthCardData= RecharData.getMonthCardData()
        local product_id= RecharData.getMonthCardData().productId

        if(Platform.getCurrentPlatform() ~= kPlatform_AppStore ) then
            print("onthCardData.getGoldRigthNow ", monthCardData.getGoldRigthNow)
            Platform.pay( tonumber(monthCardData.getGoldRigthNow) ,Platform.kPay_MonthCard )
        end
        
        
        if(Platform.getCurrentPlatform() == kPlatform_AppStore and product_id) then
            print("product_id  is ", product_id) 
            Platform.payOfAppStore(tonumber(product_id))
       end
    end


    -- if(RecharData.getIsPay()== "false" or RecharData.getIsPay()== false  ) then
    AlertTip.showAlert(GetLocalizeStringBy("key_4032"),payMonthCard, true,nil,nil,nil)
    -- else
    --     payMonthCard(true)
    -- end    

end

-- 购买按钮的回调函数， tag 里面保存充的金币
local function reChargeCallBack( tag, itemBtn )
    print(" the money is : " , tag)
    
    --若不是appStore则直接支付
    if(Platform.getCurrentPlatform() ~= kPlatform_AppStore ) then
        Platform.pay(tonumber(tag))
        print(" the money is : 22 " , tag)
    end

    local product_id= nil 
    --获取充值的数据，内容分为已经首冲和未首冲
    local payData = RecharData.getChargeData()
    -- print(GetLocalizeStringBy("key_2479"))
    -- print_t(payData)
    print(payData[1].consume_grade)
    for i=1, #payData do
        if(tonumber(tag)== tonumber( payData[i].consume_grade) ) then
            product_id = payData[i].product_id
            break
        end
    end
   
    -- 为了 appStore 
    --若是appStore则单独处理，需要当前购买物品的物品id
    if(Platform.getCurrentPlatform() == kPlatform_AppStore and product_id) then
        print("product_id:", product_id)
        Platform.payOfAppStore(tonumber(product_id))
    end
end

-- 创建cell
function createCell( cellValues, touchPriority )
    local tCell = CCTableViewCell:create()

        -- cell 的背景
    local cellBackground = CCScale9Sprite:create("images/common/bg/y_9s_bg.png")
    cellBackground:setContentSize(CCSizeMake(552,105))
    tCell:addChild(cellBackground)

    local moneyBg = CCScale9Sprite:create("images/friend/friend_name_bg.png")
    moneyBg:setContentSize(CCSizeMake(171,34))
    moneyBg:setPosition(ccp(8,56))
    cellBackground:addChild(moneyBg)

    local moneyDesc = GetLocalizeStringBy("key_1782")
    local platformName = Platform.getPlatformUrlName()
    local consume_money = cellValues.consume_money 
    if Platform.getPlatformFlag() == "IOS_91" then
        moneyDesc = GetLocalizeStringBy("zzh_1013")
    elseif(type(Platform.getConfig().getPayMoneyDesc) == "function" 
        and Platform.getConfig().getPayMoneyDesc() ~= nil 
        and Platform.getConfig().getPayMoneyDesc() ~= "")then
        moneyDesc = Platform.getConfig().getPayMoneyDesc()
        consume_money = tonumber(consume_money)/100
    else
    end

    local moneyLabel =  CCRenderLabel:create(consume_money .. moneyDesc, g_sFontName ,30,1,ccc3(0x00,0x00,0x0),type_stroke)
    moneyLabel:setColor(ccc3(0xff,0xf6,0x01))
    moneyLabel:setPosition(ccp(moneyBg:getContentSize().width/2,moneyBg:getContentSize().height/2 -4))
    moneyLabel:setAnchorPoint(ccp(0.5,0.5))
    moneyBg:addChild(moneyLabel)

    -- 充值按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(touchPriority)
    cellBackground:addChild(menu)

    local image_n = "images/common/btn/btn_shop_n.png"
    local image_h = "images/common/btn/btn_shop_h.png"
    local rect_full   = CCRectMake(0,0,70,79)
    local rect_inset  = CCRectMake(19,20,3,3)
    local btn_size_n    = CCSizeMake(144, 85)
    local btn_size_h    = CCSizeMake(144 ,85)   
    local text_color_n  = ccc3(0xfe, 0xdb, 0x1c) 
    local text_color_h  = ccc3(0xfe, 0xdb, 0x1c) 
    local font          = g_sFontPangWa
    local font_size     = 30
    local strokeCor_n   = ccc3(0x00, 0x00, 0x00) 
    local strokeCor_h   = ccc3(0x00, 0x00, 0x00)  
    local stroke_size   = 1

    local reChargeItem = LuaCCMenuItem.createMenuItemOfRender( image_n, image_h, rect_full, rect_inset, rect_full, rect_inset, btn_size_n, btn_size_h, GetLocalizeStringBy("key_1170"), text_color_n, text_color_h, font, font_size, strokeCor_n, strokeCor_h, stroke_size )
    reChargeItem:setPosition(ccp(393,cellBackground:getContentSize().height/2))
    reChargeItem:setAnchorPoint(ccp(0,0.5))
    reChargeItem:registerScriptTapHandler(reChargeCallBack)
    menu:addChild(reChargeItem,1,cellValues.consume_grade)


    local alertContent = {}

    alertContent[1] = CCSprite:create("images/common/gold.png")
    alertContent[2] = CCRenderLabel:create("".. cellValues.consume_grade, g_sFontName ,30,1,ccc3(0x00,0x00,0x0),type_stroke)
    alertContent[2]:setColor(ccc3(0xff,0xf6,0x01))
    -- alertContent[2]:setAnchorPoint(ccp(0,0))
    if (Platform.isAdShow == false) then
        alertContent[3] = CCSprite:create("images/shop/give.png")
        alertContent[4] = CCSprite:create("images/common/gold.png")
        alertContent[5] = CCRenderLabel:create("" .. cellValues.gold_num, g_sFontName ,30,1,ccc3(0x00,0x00,0x0),type_stroke)
        alertContent[5]:setColor(ccc3(0xff,0xf6,0x01))
    end
    -- alertContent[5]:setAnchorPoint(ccp(0,0))

    local giveMoney = BaseUI.createHorizontalNode(alertContent)
    giveMoney:setPosition(ccp(87,13))
    cellBackground:addChild(giveMoney)

     return tCell
end



-- 创建cell
-- 创建 CCScrollView的一个cell
--[[
    @desc: 创建 CCScrollView的一个cell:
    @param: cellValues:所有用到的数据， chargeType==1:正常的充钱， chargeType==2:月卡。touchPriority:
--]]
function createRechargeCell( cellValues,touchPriority )
    -- local tCell = CCTableViewCell:create()

    local size= CCSizeMake(552,105)
    -- cell 的背景
    local cellBackground = CCScale9Sprite:create("images/common/bg/y_9s_bg.png")
    cellBackground:setContentSize(CCSizeMake(552,105))

    local moneyBg = CCScale9Sprite:create("images/friend/friend_name_bg.png")
    moneyBg:setContentSize(CCSizeMake(171,34))
    moneyBg:setPosition(ccp(8,56))
    cellBackground:addChild(moneyBg)

    --钱币的单位，默认为“元”
    local moneyDesc = GetLocalizeStringBy("key_1782")

    local platformName = Platform.getPlatformUrlName()
    local consume_money = cellValues.consume_money 
    --该平台下钱币单位为“91豆”
    if Platform.getPlatformFlag() == "IOS_91" then
        moneyDesc = GetLocalizeStringBy("zzh_1013")
    elseif(type(Platform.getConfig().getPayMoneyDesc) == "function" 
        and Platform.getConfig().getPayMoneyDesc() ~= nil 
        and Platform.getConfig().getPayMoneyDesc() ~= "")then
        moneyDesc = Platform.getConfig().getPayMoneyDesc()
        consume_money = tonumber(consume_money)/100
    else
    end

    local moneyLabel =  CCRenderLabel:create(consume_money .. moneyDesc, g_sFontName ,30,1,ccc3(0x00,0x00,0x0),type_stroke)
    moneyLabel:setColor(ccc3(0xff,0xf6,0x01))
    moneyLabel:setPosition(ccp(moneyBg:getContentSize().width/2,moneyBg:getContentSize().height/2 -4))
    moneyLabel:setAnchorPoint(ccp(0.5,0.5))
    moneyBg:addChild(moneyLabel)

    -- 充值按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(touchPriority)
    cellBackground:addChild(menu)

    local image_n = "images/common/btn/btn_shop_n.png"
    local image_h = "images/common/btn/btn_shop_h.png"
    local rect_full   = CCRectMake(0,0,70,79)
    local rect_inset  = CCRectMake(19,20,3,3)
    local btn_size_n    = CCSizeMake(144, 85)
    local btn_size_h    = CCSizeMake(144 ,85)   
    local text_color_n  = ccc3(0xfe, 0xdb, 0x1c) 
    local text_color_h  = ccc3(0xfe, 0xdb, 0x1c) 
    local font          = g_sFontPangWa
    local font_size     = 30
    local strokeCor_n   = ccc3(0x00, 0x00, 0x00) 
    local strokeCor_h   = ccc3(0x00, 0x00, 0x00)  
    local stroke_size   = 1

    local reChargeItem = LuaCCMenuItem.createMenuItemOfRender( image_n, image_h, rect_full, rect_inset, rect_full, rect_inset, btn_size_n, btn_size_h, GetLocalizeStringBy("key_1170"), text_color_n, text_color_h, font, font_size, strokeCor_n, strokeCor_h, stroke_size )
    reChargeItem:setPosition(ccp(393,cellBackground:getContentSize().height/2))
    reChargeItem:setAnchorPoint(ccp(0,0.5))
    reChargeItem:registerScriptTapHandler(reChargeCallBack)
    menu:addChild(reChargeItem,1,cellValues.consume_grade)

    local alertContent = {}

    alertContent[1] = CCSprite:create("images/common/gold.png")
    alertContent[2] = CCRenderLabel:create("".. cellValues.consume_grade, g_sFontName ,30,1,ccc3(0x00,0x00,0x0),type_stroke)
    alertContent[2]:setColor(ccc3(0xff,0xf6,0x01))
    -- alertContent[2]:setAnchorPoint(ccp(0,0))
    if (Platform.isAdShow == false) then
        alertContent[3] = CCSprite:create("images/shop/give.png")
        alertContent[4] = CCSprite:create("images/common/gold.png")
        alertContent[5] = CCRenderLabel:create("" .. cellValues.gold_num, g_sFontName ,30,1,ccc3(0x00,0x00,0x0),type_stroke)
        alertContent[5]:setColor(ccc3(0xff,0xf6,0x01))
    end
    -- alertContent[5]:setAnchorPoint(ccp(0,0))

    local giveMoney = BaseUI.createHorizontalNode(alertContent)
    giveMoney:setPosition(ccp(87,13))
    cellBackground:addChild(giveMoney)

    -- 首充重置每档双倍 双倍提示 20160607 add by lgx
    local isNeedShowDoubleTip = RecharData.isNeedShowDoubleTip()
    if (isNeedShowDoubleTip == true) then
        if (cellValues.hadBuy == false) then
            local firstSprite = CCSprite:create("images/common/double_tag.png")
            firstSprite:setPosition(ccp(2,72))
            firstSprite:setAnchorPoint(ccp(0,0.5))
            cellBackground:addChild(firstSprite)
        end
    end

    return cellBackground
end


function createMonthCardCell(cellValues , touchPriority)
      -- cell 的背景
    local cellBackground = CCScale9Sprite:create("images/common/bg/y_9s_bg.png")
    cellBackground:setContentSize(CCSizeMake(552,224))

    local moneyBg = CCScale9Sprite:create("images/friend/friend_name_bg.png")
    moneyBg:setContentSize(CCSizeMake(171,34))
    moneyBg:setPosition(ccp(8,174))
    cellBackground:addChild(moneyBg)

    local moneyLabel =  CCRenderLabel:create( cellValues.buyExplain , g_sFontPangWa ,30,1,ccc3(0x00,0x00,0x0),type_stroke)
    moneyLabel:setColor(ccc3(0xff,0xf6,0x01))
    moneyLabel:setPosition(ccp(moneyBg:getContentSize().width/2,moneyBg:getContentSize().height/2))
    moneyLabel:setAnchorPoint(ccp(0.5,0.5))
    moneyBg:addChild(moneyLabel)


    local alertContent = {}
    alertContent[1] = CCSprite:create("images/common/gold.png")
    alertContent[2] = CCRenderLabel:create("".. cellValues.getGoldRigthNow, g_sFontName ,30,1,ccc3(0x00,0x00,0x0),type_stroke)
    alertContent[2]:setColor(ccc3(0xff,0xf6,0x01))

    local goldNode = BaseUI.createHorizontalNode(alertContent)
    goldNode:setPosition(ccp(215,179))
    cellBackground:addChild(goldNode)



    -- 文本：30天连续每日都可以领取
    local descLabel= CCRenderLabel:create(cellValues.continueTime ..GetLocalizeStringBy("key_4022"), g_sFontPangWa ,21,1,ccc3(0x00,0x00,0x0),type_stroke)
    descLabel:setAnchorPoint(ccp(0,0))
    descLabel:setColor(ccc3(0x00,0xff,0x18))
    descLabel:setPosition(24,135)
    cellBackground:addChild(descLabel)

    local itemBg=CCScale9Sprite:create("images/friend/friend_name_bg.png" )
    itemBg:setContentSize(CCSizeMake(370,112))
    itemBg:setPosition(ccp(8,14))
    cellBackground:addChild(itemBg)

    require "script/ui/item/ItemUtil"
    local cardReward= RecharData.getMonthCardData().items
    local x= 2
    local y= 79

    print_t(cardReward)

    for i=1, #cardReward do

        if(i==3) then
            y=43
        elseif(i==5) then
            y= 2
        end

        if(i%2==0) then
            x= 192
        else
            x=2    
        end
        local item= cardReward[i]
        local itemSp= ItemUtil.getSmallSprite(item)
        itemSp:setPosition(x,y)
        itemBg:addChild(itemSp)

      
        local itemName=nil
        local labelColor= ccc3(0xff,0xf6,0x00)
        if(item.type=="item" ) then
            local itemData = ItemUtil.getItemById(item.tid)
            itemName= itemData.name .. "X" .. item.num
            labelColor=  HeroPublicLua.getCCColorByStarLevel(itemData.quality)
        else
            itemName= item.name .. item.num
            labelColor= ccc3(0xff,0xf6,0x00)
        end

        local itemLabel= CCRenderLabel:create( itemName, g_sFontName ,21,1,ccc3(0x00,0x00,0x0),type_stroke)
        itemLabel:setPosition(x+40, y+2)
        itemLabel:setAnchorPoint(ccp(0,0))
        itemLabel:setColor(labelColor)
        itemBg:addChild(itemLabel)

    end

    local menuBar=CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(touchPriority)
    cellBackground:addChild(menuBar)

    local reChargeItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_shop_n.png","images/common/btn/btn_shop_h.png",CCSizeMake(144, 85),GetLocalizeStringBy("key_1170"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    reChargeItem:setPosition( 392,125 )
    reChargeItem:registerScriptTapHandler(monthCardRechargeCallBack)
    menuBar:addChild(reChargeItem)

    -- 前往查看按钮
    local goToSeeItem=LuaCC.create9ScaleMenuItem( "images/common/btn/btn_violet_n.png", "images/common/btn/btn_violet_h.png",CCSizeMake(153, 64),GetLocalizeStringBy("key_1354"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    goToSeeItem:setPosition(392,38)
    goToSeeItem:registerScriptTapHandler(goToSeeCallBack)
    menuBar:addChild(goToSeeItem)

    return cellBackground

end



