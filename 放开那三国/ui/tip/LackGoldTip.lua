-- Filename：	LackGoldTip.lua
-- Author：		zhz
-- Date：		2013-12-16
-- Purpose：		当金币不足时，弹出警告前往充值

module("LackGoldTip", package.seeall)

require "script/model/DataCache"
require "script/model/user/UserModel"
require "script/audio/AudioUtil"
require "script/ui/shop/GiftsPakLayer"
require "script/ui/shop/RechargeLayer"
require "script/libs/LuaCC"


local _bgLayer 
local _lackGoldBg			          -- 缺少金币提示的背景
local _touchPriority            -- 触摸的优先级
local _zOrder                   -- z轴

local function init(  )
	_bgLayer = nil
	_lackGoldBg =nil
  _touchPriority= -1001
  _zOrder = 1111
end

-- layer 的回调函数
local function layerToucCb(eventType, x, y)
	return true
end

-- 充值按钮的回调函数
function rechargeCb( tag, item )
  AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
  closeCb()
  local layer = RechargeLayer.createLayer(_touchPriority)
  local scene = CCDirector:sharedDirector():getRunningScene()
  scene:addChild(layer,_zOrder)

end
-- 关闭按钮
function closeCb( )
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer=nil
end

function showTip( touchPriority, zOrder)
	init()
	_bgLayer = CCLayer:create()

  _touchPriority= touchPriority or -1001
  _zOrder = zOrder or 1100

	_bgLayer:setTouchEnabled(true)
    _bgLayer:registerScriptTouchHandler(layerToucCb,false,_touchPriority,true)

    local scene = CCDirector:sharedDirector():getRunningScene()
 	scene:addChild(_bgLayer,_zOrder,2013)

 	local myScale = MainScene.elementScale

 	-- 背景的Ui
	local mySize= CCSizeMake(625,502)

	if( UserModel.getVipLevel()==  tonumber(table.count(DB_Vip.Vip) -1) ) then 
		mySize= CCSizeMake(486,359)
	end

	local fullRect = CCRectMake(0, 0, 213, 171)
    local insetRect = CCRectMake(100, 80, 10, 20)
    _lackGoldBg = CCScale9Sprite:create("images/common/viewbg1.png",fullRect,insetRect)
    _lackGoldBg:setContentSize(mySize)
    _lackGoldBg:setScale(myScale)
    _lackGoldBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    _lackGoldBg:setAnchorPoint(ccp(0.5,0.5))
    _bgLayer:addChild(_lackGoldBg)

 	local menu= CCMenu:create()
 	menu:setPosition(ccp(0,0))
    menu:setTouchPriority(_touchPriority-1)
    _lackGoldBg:addChild(menu,99)

     local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(mySize.width*1.02,mySize.height*1.02))
    closeBtn:setAnchorPoint(ccp(1,1))
    closeBtn:registerScriptTapHandler(closeCb)
    menu:addChild(closeBtn)

    local rechargeBtn =  LuaCC.create9ScaleMenuItem("images/common/btn/btn_shop_n.png","images/common/btn/btn_shop_h.png",CCSizeMake(148, 79), GetLocalizeStringBy("key_3177") ,ccc3(0xff, 0xe4, 0x00),36,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    rechargeBtn:setPosition(ccp(_lackGoldBg:getContentSize().width/2, 34))
    rechargeBtn:setAnchorPoint(ccp(0.5,0))
    rechargeBtn:registerScriptTapHandler(rechargeCb)
    menu:addChild(rechargeBtn)

    if(UserModel.getVipLevel()== tonumber(table.count(DB_Vip.Vip) -1) ) then
    	rechargeBtn:setPosition(ccp(_lackGoldBg:getContentSize().width/2, 60))
      createMaxLevelUI() 
      closeBtn:setPosition(mySize.width*1.03,mySize.height*1.03)
    else
        calLevelUpMoney( )
        createTopUI()
        createItemUi()
    end

end

-- 创建顶部的UI
function createTopUI( ... )
	
	-- 文本： 您的金币不足
	local lackGoldLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1255"), g_sFontPangWa,30,1,ccc3(0xff,0xff,0xff),type_stroke)
	lackGoldLabel:setPosition(ccp(_lackGoldBg:getContentSize().width/2, 429))
	lackGoldLabel:setAnchorPoint(ccp(0.5,0))
	lackGoldLabel:setColor(ccc3(0x78,0x25,0x00))
	_lackGoldBg:addChild(lackGoldLabel)

	-- 
	local vipContent = {}
	vipContent[1]= CCRenderLabel:create(GetLocalizeStringBy("key_2116"), g_sFontName,21,1,ccc3(0,0,0),type_stroke)
	vipContent[1]:setColor(ccc3(0xff,0xe4,0x00))
	vipContent[2]= CCSprite:create("images/common/vip.png")
	vipContent[3]= LuaCC.createNumberSprite("images/main/vip", tonumber(UserModel.getVipLevel()))

	local vipNode= BaseUI.createHorizontalNode(vipContent)
	vipNode:setPosition(45, 385)
    _lackGoldBg:addChild(vipNode)

    local chargeContent= {}
    chargeContent[1]= CCRenderLabel:create(GetLocalizeStringBy("key_1056"), g_sFontName,21,1,ccc3(0,0,0),type_stroke)
    chargeContent[1]:setColor(ccc3(0xff,0xe4,0x00))
    chargeContent[2]= CCRenderLabel:create( _levelUpMoney - _curPayMoney .. GetLocalizeStringBy("key_1265") , g_sFontPangWa,21,1,ccc3(0,0,0),type_stroke)
    chargeContent[2]:setColor(ccc3(0xff,0xe4,0x00))
    chargeContent[3]= CCRenderLabel:create(GetLocalizeStringBy("key_1421"), g_sFontName,21,1,ccc3(0,0,0),type_stroke)
    chargeContent[3]:setColor(ccc3(0xff,0xe4,0x00))
    chargeContent[4]= CCSprite:create("images/common/vip.png")
	chargeContent[5]= LuaCC.createNumberSprite("images/main/vip", tonumber(UserModel.getVipLevel())+1)

	local chargeNode= BaseUI.createHorizontalNode(chargeContent)
	chargeNode:setPosition(40, 342)
    _lackGoldBg:addChild(chargeNode)

end

-- 创建物品UI
function createItemUi(  )
    local itemBg =CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
    itemBg:setContentSize(CCSizeMake(566,166))
    itemBg:setPosition(ccp(_lackGoldBg:getContentSize().width/2,132))
    itemBg:setAnchorPoint(ccp(0.5,0))
    _lackGoldBg:addChild(itemBg)

    local vipTitleSp = CCSprite:create("images/reward/cell_title_panel.png")
    vipTitleSp:setPosition(ccp(1,137))
    itemBg:addChild(vipTitleSp)
    local boolCharge= false
    local nextVipLevel = tonumber(UserModel.getVipLevel())+1
    local alertContent = {}
    if(tonumber(_curPayMoney) > 0) then
        alertContent[1] = CCSprite:create("images/common/vip.png")
        alertContent[2] = LuaCC.createNumberSprite("images/main/vip",nextVipLevel )
        alertContent[3] = CCSprite:create("images/shop/vip_desc.png")
        boolCharge = true
    else
        alertContent[1] = CCSprite:create("images/shop/first_charge.png")
    end
    local vipDesc = BaseUI.createHorizontalNode(alertContent)
    vipDesc:setPosition(ccp(vipTitleSp:getContentSize().width*0.5, vipTitleSp:getContentSize().height*0.5))
    vipDesc:setAnchorPoint(ccp(0.5,0.5))
    vipTitleSp:addChild(vipDesc)

    local items = GiftsPakLayer.getVipItemInfo(boolCharge, nextVipLevel)

    for i=1, 4 do 
        if(items[i]~= nil) then
            local itemSprite 
            local itemName
            local itemNameLabel
            if(items[i].type== "item") then
               itemSprite =ItemSprite.getItemSpriteById(items[i].tid,nil, itemDelegateAction,nil, -800, 1200) --ItemSprite.getItemSpriteByItemId(tonumber(items[i].tid))
               local itemTableInfo = ItemUtil.getItemById(tonumber(items[i].tid))
               itemName = itemTableInfo.name

               itemSprite:setPosition(ccp(28+(i-1)*138,itemBg:getContentSize().height/2))
               itemSprite:setAnchorPoint(ccp(0,0.5))
               itemBg:addChild(itemSprite)
               itemNameLabel = CCRenderLabel:create(itemName , g_sFontName,18,1,ccc3(0x00,0x00,0x0),type_stroke)
               itemNameLabel:setPosition(ccp(73+(i-1)*138,8))
               itemNameLabel:setAnchorPoint(ccp(0.5,0))
               itemBg:addChild(itemNameLabel)
            elseif(items[i].type == "gold") then  
                -- 首冲
               itemSprite = ItemSprite.getGoldIconSprite()
               itemSprite:setPosition(ccp(28+(i-1)*138,itemBg:getContentSize().height/2))
               itemSprite:setAnchorPoint(ccp(0,0.5))
               itemBg:addChild(itemSprite)
               itemNameLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2385") , g_sFontName,18,1,ccc3(0x00,0x00,0x0),type_stroke)
               itemNameLabel:setPosition(ccp(73+(i-1)*138,8))
               itemNameLabel:setAnchorPoint(ccp(0.5,0))
               itemBg:addChild(itemNameLabel)
            elseif(items[i].type == "silver") then  
                -- 首冲
               itemSprite = ItemSprite.getBigSilverSprite()
               itemSprite:setPosition(ccp(28+(i-1)*138,itemBg:getContentSize().height/2))
               itemSprite:setAnchorPoint(ccp(0,0.5))
               itemBg:addChild(itemSprite)
               itemNameLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2889") .. items[i].num , g_sFontName,18,1,ccc3(0x00,0x00,0x0),type_stroke)
               itemNameLabel:setPosition(ccp(73+(i-1)*138,8))
               itemNameLabel:setAnchorPoint(ccp(0.5,0))
               itemBg:addChild(itemNameLabel)

            end
        end
    end

        -- nnd ,没有物品，做特殊处理
    if(table.isEmpty(items)  ) then
        local tipNameLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1209") , g_sFontPangWa ,34 ,1,ccc3(0x00,0x00,0x0),type_stroke)
        tipNameLabel:setPosition(itemBg:getContentSize().width/2,itemBg:getContentSize().height/2 )
        tipNameLabel:setAnchorPoint(ccp(0.5,0.5))
        tipNameLabel:setColor(ccc3(0xff,0xe4,0x00))
        itemBg:addChild(tipNameLabel)
    end

end

-- 创建最大VIP等级时的UI
function createMaxLevelUI( )

  local descBg= CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
  descBg:setContentSize(CCSizeMake(427,141))
  descBg:setPosition(_lackGoldBg:getContentSize().width/2, 160)
  descBg:setAnchorPoint(ccp(0.5,0))
  _lackGoldBg:addChild(descBg)

    -- 文本： 您的金币不足
  local lackGoldLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1255"), g_sFontPangWa,30,1,ccc3(0xff,0xff,0xff),type_stroke)
  lackGoldLabel:setPosition(ccp(descBg:getContentSize().width/2, 78))
  lackGoldLabel:setAnchorPoint(ccp(0.5,0))
  lackGoldLabel:setColor(ccc3(0x78,0x25,0x00))
  descBg:addChild(lackGoldLabel)

    local vipContent = {}
  vipContent[1]= CCRenderLabel:create(GetLocalizeStringBy("key_2116"), g_sFontName,21,1,ccc3(0,0,0),type_stroke)
  vipContent[1]:setColor(ccc3(0xff,0xe4,0x00))
  vipContent[2]= CCSprite:create("images/common/vip.png")
  vipContent[3]= LuaCC.createNumberSprite("images/main/vip", tonumber(UserModel.getVipLevel()))

  local vipNode= BaseUI.createHorizontalNode(vipContent)
  vipNode:setPosition(descBg:getContentSize().width/2, 26)
  vipNode:setAnchorPoint(ccp(0.5,0))
  descBg:addChild(vipNode)


end

-------------------------------- utils 方法 -------------------
-- 计算当前的钱数和满级的钱数
function calLevelUpMoney( )
    -- 判断当前用户是否已满级 ，满级时，_levelUpMoney 为当前的级rechargeValue
    local nextVipLevelData
    if(tonumber(UserModel.getVipLevel()) == tonumber(table.count(DB_Vip.Vip) -1)) then
        nextVipLevelData = DB_Vip.getDataById(UserModel.getVipLevel()+1)
    else
        nextVipLevelData = DB_Vip.getDataById(UserModel.getVipLevel()+2)
    end
     _levelUpMoney = nextVipLevelData.rechargeValue or 0
    
    _curPayMoney =  DataCache.getChargeGoldNum()      -- UserModel.getChargeGoldNum() or 0
   if(tonumber(_curPayMoney)>tonumber(_levelUpMoney) ) then
        _levelUpMoney = _curPayMoney
   end
end










