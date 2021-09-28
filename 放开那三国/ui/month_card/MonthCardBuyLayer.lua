-- Filename：	MonthCardBuyLayer.lua
-- Author：		chengliang
-- Date：		2014-11-21
-- Purpose：		购买月卡

module("MonthCardBuyLayer", package.seeall)
require "script/ui/month_card/MonthCardData"
require "script/ui/month_card/MonthCardCell"
local _bgLayer 
local _priority
local _zOrder
local _bgSprite
local _vipCardDBData = nil
local _cardId 

function init()
	_bgLayer 	= nil
	_priority 	= nil
	_zOrder 	= nil
	_bgSprite 	= nil
    _vipCardDBData = nil
end

local function onTouchesHandler( eventType, x, y )
	
	if (eventType == "began") then
		-- print("began")

	    return true
    elseif (eventType == "moved") then
    	
    else
        -- print("end")
	end
end

 --]]
local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _priority, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
        _bgLayer = nil
	end
end


-- 关闭按钮的回调函数
function closeCb()
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end

local function buyMonthCardCallback()
    UserModel.addGoldNumber(-tonumber(_vipCardDBData.pay))
    MonthCardCell.refreshAftUpdate()
    AnimationTip.showTip( GetLocalizeStringBy("cl_1010") )
end



function showAlertTip()

    require "script/ui/tip/BaseAlertTip"

    local tipLayer = BaseAlertTip.createLayer()
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    runningScene:addChild(tipLayer, 999)
    -- 默认文本的信息
    local local_infos = {}
    local_infos.localColor = ccc3(0,0,0)
    local_infos.localFontSize = 25
    local_infos.localLabelType = "label"
    local_infos.font = g_sFontName

    -- 各个变量的节点信息 也就是 %s 中要替代的内容
    local param_table = {
                            { 
                                ntype     = "image",
                                image     = "images/common/gold.png",
                            },
                            { 
                                ntype     = "label",
                                fontSize  = 25,
                                text      = _vipCardDBData.pay,
                                color     = ccc3( 155, 0, 0),
                            },
                        }

    -- tip
    local b_bgSprite = BaseAlertTip.getBgSprite()
    local infos_sprite = GetLocalizeLabelSpriteBy("cl_1013", local_infos, param_table)
    infos_sprite:setPosition(ccp(b_bgSprite:getContentSize().width*0.5, 190))
    infos_sprite:setAnchorPoint(ccp(0.5,0.5))
    
    b_bgSprite:addChild(infos_sprite)

    local function confirmAction( )
        print("confirmAction")
        MonthCardService.buyMonthCard(_cardId,buyMonthCardCallback)
        tipLayer:removeFromParentAndCleanup(true)
        tipLayer=nil
    end

    -- 
    local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(-460)
    b_bgSprite:addChild(menuBar)
    require "script/libs/LuaCC"
    local confirmBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 70), GetLocalizeStringBy("key_10052"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    confirmBtn:setAnchorPoint(ccp(0.5, 0.5))
    confirmBtn:registerScriptTapHandler(confirmAction)
    confirmBtn:setPosition(ccp(b_bgSprite:getContentSize().width*0.5, b_bgSprite:getContentSize().height*0.25))
    menuBar:addChild(confirmBtn)
    
end


-- menu callback
function monthCardRechargeCallBack( tag, btn )
    closeCb()
	if( MonthCardData.getMonthChargeGold(_cardId) < tonumber(_vipCardDBData.payneedgold) )then 
        -- 未达到条件
		require "script/ui/month_card/MonthCardChargeTip"
		MonthCardChargeTip.showLayer(-460,nil,_cardId)
	else
        if( UserModel.getGoldNumber() < tonumber(_vipCardDBData.pay) )then
            require "script/ui/tip/LackGoldTip"
            LackGoldTip.showTip()
        else
            showAlertTip()
        end
	end
end

-- 
function createContent( ... )

    -- 默认文本的信息
    local local_infos = {}
    local_infos.localColor = ccc3(0,0,0)
    local_infos.localFontSize = 25
    local_infos.localLabelType = "label"
    local_infos.font = g_sFontName

    -- 各个变量的节点信息 也就是 %s 中要替代的内容
    local param_table = {
                            { 
                                ntype     = "image",
                                image     = "images/common/gold.png",
                 
                            },
                            { 
                                ntype     = "label",
                                fontSize  = 25,
                                text      = _vipCardDBData.payneedgold,
                                color     = ccc3( 155, 0, 0),
                            },
                            { 
                                ntype     = "image",
                                image     = "images/common/gold.png",
                            },
                            { 
                                ntype     = "label",
                                fontSize  = 25,
                                text      = MonthCardData.getMonthChargeGold(_cardId),
                                color     = ccc3( 155, 0, 0),
                            },
                        }

    -- tip
    local infos_sprite = GetLocalizeLabelSpriteBy("cl_1011", local_infos, param_table)
    infos_sprite:setPosition(ccp(60, 310))
    infos_sprite:setAnchorPoint(ccp(0,0.5))
    _bgSprite:addChild(infos_sprite)


	local cellBackground = CCScale9Sprite:create("images/common/bg/y_9s_bg.png")
    cellBackground:setContentSize(CCSizeMake(500,224))
    cellBackground:setAnchorPoint(ccp(0.5, 0.5))
    cellBackground:setPosition(ccp(_bgSprite:getContentSize().width*0.5, _bgSprite:getContentSize().height*0.4))
    _bgSprite:addChild(cellBackground)

    local moneyBg = CCScale9Sprite:create("images/friend/friend_name_bg.png")
    moneyBg:setContentSize(CCSizeMake(171,34))
    moneyBg:setPosition(ccp(8,174))
    cellBackground:addChild(moneyBg)

    local moneyLabel =  CCRenderLabel:create( _vipCardDBData.buyExplain, g_sFontPangWa ,30,1,ccc3(0x00,0x00,0x0),type_stroke)
    moneyLabel:setColor(ccc3(0xff,0xf6,0x01))
    moneyLabel:setPosition(ccp(moneyBg:getContentSize().width/2,moneyBg:getContentSize().height/2))
    moneyLabel:setAnchorPoint(ccp(0.5,0.5))
    moneyBg:addChild(moneyLabel)


    local alertContent = {}
    alertContent[1] = CCSprite:create("images/common/gold.png")
    alertContent[2] = CCRenderLabel:create(_vipCardDBData.pay, g_sFontName ,30,1,ccc3(0x00,0x00,0x0),type_stroke)
    alertContent[2]:setColor(ccc3(0xff,0xf6,0x01))

    local goldNode = BaseUI.createHorizontalNode(alertContent)
    goldNode:setPosition(ccp(215,179))
    cellBackground:addChild(goldNode)



    -- 文本：30天连续每日都可以领取
    local descLabel= CCRenderLabel:create(_vipCardDBData.continueTime ..GetLocalizeStringBy("key_4022"), g_sFontPangWa ,21,1,ccc3(0x00,0x00,0x0),type_stroke)
    descLabel:setAnchorPoint(ccp(0,0))
    descLabel:setColor(ccc3(0x00,0xff,0x18))
    descLabel:setPosition(24,135)
    cellBackground:addChild(descLabel)

    local itemBg=CCScale9Sprite:create("images/friend/friend_name_bg.png" )
    itemBg:setContentSize(CCSizeMake(370,112))
    itemBg:setPosition(ccp(30,14))
    cellBackground:addChild(itemBg)

    require "script/ui/item/ItemUtil"
    local cardReward= RecharData.getMonthCardData(_cardId).items
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
    menuBar:setTouchPriority(_priority-2)
    cellBackground:addChild(menuBar)

    local reChargeItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_shop_n.png","images/common/btn/btn_shop_h.png",CCSizeMake(164, 80),GetLocalizeStringBy("key_1523"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    reChargeItem:setPosition( 302,135 )
    reChargeItem:registerScriptTapHandler(monthCardRechargeCallBack)
    menuBar:addChild(reChargeItem)
end

-- 
local function createBgSprite()
	local myScale = MainScene.elementScale
	local mySize = CCSizeMake(610, 400)
	-- 背景
	local fullRect = CCRectMake(0, 0, 213, 171)
	local insetRect = CCRectMake(84, 84, 2, 3)
    _bgSprite = CCScale9Sprite:create("images/common/viewbg1.png",fullRect,insetRect)
    _bgSprite:setContentSize(mySize)
    _bgSprite:setScale(myScale)
    _bgSprite:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    _bgSprite:setAnchorPoint(ccp(0.5,0.5))
    _bgLayer:addChild(_bgSprite)

    local titleBg= CCSprite:create("images/common/viewtitle1.png")
	titleBg:setPosition(ccp(_bgSprite:getContentSize().width*0.5, _bgSprite:getContentSize().height-6))
	titleBg:setAnchorPoint(ccp(0.5, 0.5))
	_bgSprite:addChild(titleBg)

	 --标题文本
	local labelTitle = CCRenderLabel:create(GetLocalizeStringBy("cl_1009"), g_sFontPangWa,33,2,ccc3(0x00,0x00,0x0),type_shadow)
	labelTitle:setPosition(ccp(titleBg:getContentSize().width/2, (titleBg:getContentSize().height-1)/2))
	labelTitle:setColor(ccc3(0xff,0xe4,0x00))
	labelTitle:setPosition(ccp(titleBg:getContentSize().width*0.5,titleBg:getContentSize().height*0.5))
    labelTitle:setAnchorPoint(ccp(0.5,0.5))
	titleBg:addChild(labelTitle)

	-- 关闭按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(_priority-1)
    _bgSprite:addChild(menu,99)
    closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(mySize.width*1.02,mySize.height*1.02))
    closeBtn:setAnchorPoint(ccp(1,1))
    closeBtn:registerScriptTapHandler(closeCb)
    menu:addChild(closeBtn)
end

-- 创建
function createLayer()
	
	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)

	createBgSprite()
	createContent()

	return _bgLayer
end

-- 展示
function showLayer( priority, zOrder ,pCardId)
	init()
	_priority = priority or -450
	_zOrder = zOrder or  999
	_cardId = pCardId
    _vipCardDBData = MonthCardData.getVipCardDatafromXml(pCardId)

	createLayer()
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(_bgLayer, _zOrder)

end



