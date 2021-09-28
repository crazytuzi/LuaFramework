-- Filename：	FirstPackLayer.lua
-- Author：		zhz
-- Date：		2013-9-29
-- Purpose：		首冲礼包

module ("FirstPackLayer", package.seeall)

require "script/ui/shop/ShopLayer"
require "script/ui/shop/RechargeLayer"
require "script/ui/shop/GiftsPakLayer"
require "script/ui/item/ItemSprite"
require "script/audio/AudioUtil"
require "script/ui/main/MainScene"

local _layer
local _packBackground			-- 首冲礼包的背景
local IMG_PATH = "images/recharge/"
-- 
local function init( )
	_layer = nil
	_packBackground = nil
end 

local function rechargeCallBack( ... )
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	local layer = RechargeLayer.createLayer()
	local scene = CCDirector:sharedDirector():getRunningScene()
	scene:addChild(layer,1111)
end

-- 显示首冲礼包物品的ui
local function createGiftUI(  )
	-- 金色的条
	goldPanel = CCScale9Sprite:create(IMG_PATH .. "gift_panel.png")
	goldPanel:setContentSize(CCSizeMake(565,151))
	goldPanel:setPosition(ccp(_packBackground:getContentSize().width*0.5,_packBackground:getContentSize().height*15/655))
	goldPanel:setAnchorPoint(ccp(0.5,0))
	goldPanel:setScale(MainScene.elementScale)
	_packBackground:addChild(goldPanel)


	-- 物品的背景
	local itemBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	itemBg:setContentSize(CCSizeMake(471,124))
	itemBg:setPosition(ccp(goldPanel:getContentSize().width/2, goldPanel:getContentSize().height/2))
	itemBg:setAnchorPoint(ccp(0.5,0.5))
	goldPanel:addChild(itemBg)

	local items =  GiftsPakLayer.getFirstVipData()
	for i=1, 4 do 
        if(items[i]~= nil) then
            local itemSprite 
            local itemName
            local itemNameLabel
            local itemNumLabel
            if(items[i].type== "item") then
	            itemSprite = getItemIcon(items[i])--ItemSprite.getItemSpriteById(items[i].tid)
	  			itemBg:addChild(itemSprite,0, items[i].tid)
	            itemSprite:setPosition(ccp(18+(i-1)*117,itemBg:getContentSize().height*0.6))
	            itemSprite:setAnchorPoint(ccp(0,0.5))
            -- itemSprite:registerScriptTapHandler(itemCallBack)

            elseif(items[i].type == "gold") then  
                -- 首冲
               itemSprite = ItemSprite.getSpceicalGoldSprite()
               itemSprite:setPosition(ccp(18+(i-1)*117,itemBg:getContentSize().height*0.6))
               itemSprite:setAnchorPoint(ccp(0,0.5))
               itemBg:addChild(itemSprite)
               itemNameLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2385") , g_sFontName,18,1,ccc3(0x00,0x00,0x0),type_stroke)
               itemNameLabel:setPosition(ccp(58+(i-1)*117,3))
               itemNameLabel:setAnchorPoint(ccp(0.5,0))
               itemBg:addChild(itemNameLabel)
          
            elseif(items[i].type == "silver") then  
                -- 首冲
               itemSprite = ItemSprite.getBigSilverSprite()
               itemSprite:setPosition(ccp(18+(i-1)*117,itemBg:getContentSize().height*0.6))
               itemSprite:setAnchorPoint(ccp(0,0.5))
               itemBg:addChild(itemSprite)
               itemNameLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2889").. items[i].num , g_sFontName,18,1,ccc3(0x00,0x00,0x0),type_stroke)
               itemNameLabel:setPosition(ccp(58+(i-1)*117,3))
               itemNameLabel:setAnchorPoint(ccp(0.5,0))
               itemBg:addChild(itemNameLabel)
            end

        end
    end
end

-- 
local function itemDelegateAction(  )
	MainScene.setMainSceneViewsVisible(true, false, false)
end

-- 获得按钮
function getItemIcon(item )

  	local itemSprite = ItemSprite.getItemSpriteById(item.tid,nil, itemDelegateAction)
  	-- itemSprite:setPosition(ccp(18+(i-1)*117,itemBg:getContentSize().height*0.6))
  	-- itemSprite:setAnchorPoint(ccp(0,0.5))
  	-- itemBg:addChild(itemSprite)
  	local itemIcon = CCMenuItemSprite:create(itemSprite, itemSprite)
  	-- itemIcon:registerScriptTapHandler(itemCallBack)
  	-- menu:addChild(itemIcon)

  	local itemTableInfo = ItemUtil.getItemById(tonumber(item.tid))
  	itemName = itemTableInfo.name
  	itemNameLabel = CCRenderLabel:create(itemName , g_sFontName,18,1,ccc3(0x00,0x00,0x0),type_stroke)
  	itemNameLabel:setPosition(ccp(itemIcon:getContentSize().width*0.5 , -5 ))
  	itemNameLabel:setAnchorPoint(ccp(0.5,1))
  	itemIcon:addChild(itemNameLabel)

	   -- 数量
	  if(tonumber(item.num) > 1) then
		  	itemNumLabel = CCRenderLabel:create( "" .. item.num  , g_sFontName,18,1,ccc3(0x00,0x00,0x0),type_stroke)
		   	itemNumLabel:setColor(ccc3(0x00,0xff,0x18))
		    local width =  itemSprite:getContentSize().width - itemNumLabel:getContentSize().width - 6
		    itemNumLabel:setPosition(ccp(width,5))
		    itemNumLabel:setAnchorPoint(ccp(0,0))
		    itemSprite:addChild(itemNumLabel)
	  end
	  return itemIcon
end


function createLayer(  )
	init()
	_layer = CCLayer:create()

	_packBackground = CCScale9Sprite:create(IMG_PATH .. "fund/fund_bg.png")
	 -- _layer:setScale(1/MainScene.elementScale)

	require "script/ui/main/BulletinLayer"
	require "script/ui/main/MainScene"
	require "script/ui/main/MenuLayer"
	require "script/ui/rechargeActive/RechargeActiveMain"
	
	local bulletinLayerSize = RechargeActiveMain.getTopSize()
	local menuLayerSize = MenuLayer.getLayerContentSize()
	local height = g_winSize.height - (menuLayerSize.height + bulletinLayerSize.height )*g_fScaleX  - RechargeActiveMain.getBgWidth()

	_packBackground:setContentSize(CCSizeMake(g_winSize.width,height))
	_packBackground:setPosition(ccp(0,menuLayerSize.height*g_fScaleX))
	-- _packBackground:setScale(1/MainScene.elementScale)

	_layer:addChild(_packBackground)

	local bgSize = _packBackground:getContentSize()
	require "script/ui/shop/RecharData"
	local configInfo = RecharData.getFirstDataInfo()

	-- 显示 pretty girl
	local configImgPath = "images/recharge/first_charge/config/"
	local imageInfo = string.split(configInfo.img, ",")
	local prettySprite = CCSprite:create(configImgPath .. (imageInfo[1] or "pretty_girl.png") )
	prettySprite:setPosition(ccp(0,161/655*_packBackground:getContentSize().height))
	_packBackground:addChild(prettySprite)
	prettySprite:setScale(MainScene.elementScale)

	--[[
		首充重置 每档双倍 20160530 by lgx
		（最高返利10000金币）文字去掉
		金币3倍显示去掉
		去掉首充3倍金币大礼图片
		将首次充值任意金额图片往上移，前往充值往上移
	--]]
	-- -- 首次充值领取大礼的 文字和 背景
	-- local txtBg = CCSprite:create(IMG_PATH .. "txt_bg.png")
	-- txtBg:setScale(MainScene.elementScale)
	-- txtBg:setPosition(ccp(bgSize.width*265/640 , bgSize.height*510/655))
	-- _packBackground:addChild(txtBg)

	-- local txtSprite = CCSprite:create(IMG_PATH .. "first_charge/charge_title.png")
	-- txtSprite:setScale(MainScene.elementScale)
	-- txtSprite:setPosition(txtBg:getContentSize().width/2,5)
	-- txtSprite:setAnchorPoint(ccp(0.5,0))
	-- txtBg:addChild(txtSprite)

	local descBg =  CCScale9Sprite:create(configImgPath .. (imageInfo[2] or "charge_desc.png"))
	descBg:setScale(MainScene.elementScale)
	-- descBg:setContentSize(CCSizeMake(320,227))
	descBg:setPosition(ccp(bgSize.width*289/640,bgSize.height*425/655))
	-- descBg:setAnchorPoint(ccp(0.5,0))
	_packBackground:addChild(descBg)

	local noteSp = CCSprite:create(IMG_PATH .. "first_charge/charge_note.png")
	noteSp:setScale(MainScene.elementScale)
	noteSp:setPosition(ccp(bgSize.width*0.51,bgSize.height*170/655))
	noteSp:setAnchorPoint(ccp(0.5,0))
	_packBackground:addChild(noteSp)


	-- local txt = GetLocalizeStringBy("key_1876")

	-- local descLabel = CCRenderLabel:createWithAlign( txt , g_sFontName, 21, 1, ccc3(0x00, 0x00, 0x00), type_stroke, CCSizeMake(295,119),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	-- descLabel:setColor(ccc3(0xff,0xf6,0x00))
	-- descLabel:setPosition(ccp(10,descBg:getContentSize().height*0.8))
	-- descLabel:setAnchorPoint(ccp(0,1))
	-- descBg:addChild(descLabel)

	-- local txt2= GetLocalizeStringBy("key_1610")
	-- local descLabel2 = CCRenderLabel:createWithAlign( txt2 , g_sFontName, 21, 1, ccc3(0x00, 0x00, 0x00), type_stroke, CCSizeMake(295,119),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	-- descLabel2:setColor(ccc3(0xff,0x0,0xe1))
	-- descLabel2:setPosition(ccp(33,descBg:getContentSize().height*0.5))
	-- descLabel2:setAnchorPoint(ccp(0,1))
	-- descBg:addChild(descLabel2)

	-- local txt3= GetLocalizeStringBy("key_1179")
	-- local descLabel = CCRenderLabel:createWithAlign( txt3 , g_sFontName, 21, 1, ccc3(0x00, 0x00, 0x00), type_stroke, CCSizeMake(295,119),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	-- descLabel:setColor(ccc3(0xff,0xf6,0x00))
	-- descLabel:setPosition(ccp(10,descBg:getContentSize().height*0.4))
	-- descLabel:setAnchorPoint(ccp(0,1))
	-- descBg:addChild(descLabel)


	-- 前往充值按钮
	local menu = CCMenu:create()
	menu:setPosition(ccp(0,0))
	_packBackground:addChild(menu)

	local rechargeBtn = CCMenuItemImage:create( IMG_PATH .. "recharge_btn/recharge_btn_n.png", IMG_PATH .. "recharge_btn/recharge_btn_h.png")
	rechargeBtn:setPosition(ccp(406/640*bgSize.width,285/655*bgSize.height))
	menu:addChild(rechargeBtn)
	rechargeBtn:setScale(MainScene.elementScale)
	rechargeBtn:registerScriptTapHandler(rechargeCallBack)

	-- -- 创建显示 首冲礼包物品的ui
	createGiftUI()

	return _layer 
end
