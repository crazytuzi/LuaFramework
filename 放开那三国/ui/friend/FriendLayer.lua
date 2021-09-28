-- FileName: FriendLayer.lua 
-- Author: Li Cong 
-- Date: 13-8-27 
-- Purpose: function description of module 

--[[注: 未完成事项
1.交流界面的查看信息按钮功能
--]]


require "script/utils/BaseUI"
require "script/ui/friend/FriendService"
require "script/ui/friend/FriendData"

module("FriendLayer", package.seeall)

--全局变量
m_layerSize = nil
COMMON_PATH = "images/common/"					    			-- 公用图片主路径
IMG_PATH = "images/friend/"					    				-- 好友图片主路径
m_mainLayer = nil
m_tipSprite = nil												-- 红圈提示数字

local function onNodeEvent( event )
    if (event == "enter") then
    elseif (event == "exit") then
        m_mainLayer = nil
        -- 关闭交流二级界面
        require "script/ui/friend/ExchangeLayer"
        ExchangeLayer.closeButtonCallback()
    end
end

-- 创建更多好友
function createMoreButtonItem()
	local normalSprite = BaseUI.createYellowBg(CCSizeMake(584,110))
    local selectSprite = BaseUI.createYellowSelectBg(CCSizeMake(584,110))
    local item = CCMenuItemSprite:create(normalSprite,selectSprite)
    -- 红条
    local sprite = CCSprite:create("images/common/red_line.png")
	sprite:setAnchorPoint(ccp(0.5,0.5))
	sprite:setPosition(ccp(item:getContentSize().width*0.5,item:getContentSize().height*0.5))
	item:addChild(sprite)
    -- 字体
	local item_font = CCRenderLabel:create( GetLocalizeStringBy("key_1661") , g_sFontPangWa, 35,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	item_font:setAnchorPoint(ccp(0.5,0.5))
    item_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
    item_font:setPosition(ccp(sprite:getContentSize().width*0.5,sprite:getContentSize().height*0.5))
   	sprite:addChild(item_font)
   	return item
end


-- 返回按钮回调
local function closeFortsLayoutAction( ... )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	-- 释放层资源
	if (m_mainLayer) then
		m_mainLayer:removeFromParentAndCleanup(true)
		m_mainLayer = nil
	end
	-- 打开主界面
	require "script/ui/main/MainBaseLayer"
	local main_base_layer = MainBaseLayer.create()
	MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
end 

-- 初始化好友层
function initFriendLayer( ... )
	-- 好友层layer大小
	m_layerSize = m_mainLayer:getContentSize()
	-- 背景
	local friend_bg = BaseUI.createNoBorderViewBg(CCSizeMake((m_layerSize.width-10*MainScene.elementScale),(m_layerSize.height+10*MainScene.elementScale)))
	friend_bg:setAnchorPoint(ccp(0.5,1))
	friend_bg:setPosition(ccp(m_layerSize.width*0.5,m_layerSize.height))
	friend_bg:setScale(1/MainScene.elementScale)
	m_mainLayer:addChild(friend_bg)
	-- 按钮背景
	local menu_bg = BaseUI.createTopMenuBg(CCSizeMake(m_layerSize.width/MainScene.elementScale, 96))
	menu_bg:setAnchorPoint(ccp(0.5,1))
	menu_bg:setPosition(ccp(m_layerSize.width*0.5,m_layerSize.height))
	m_mainLayer:addChild(menu_bg)
	-- 上分界线
	local topSeparator = CCSprite:create( COMMON_PATH .. "separator_top.png" )
	topSeparator:setAnchorPoint(ccp(0.5,1))
	topSeparator:setPosition(ccp(m_layerSize.width*0.5,m_layerSize.height))
	m_mainLayer:addChild(topSeparator)
	topSeparator:setScale(g_fScaleX/MainScene.elementScale)
	-- 创建返回按钮
	local menuCloseBar = CCMenu:create()
	menuCloseBar:setTouchPriority(-135)
	menuCloseBar:setPosition(ccp(0,0))
	menu_bg:addChild(menuCloseBar)
	local closeMenuItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	closeMenuItem:setAnchorPoint(ccp(0, 0))
	closeMenuItem:registerScriptTapHandler(closeFortsLayoutAction)
	closeMenuItem:setAnchorPoint(ccp(1,0.5))
	closeMenuItem:setPosition(ccp(menu_bg:getContentSize().width-5,menu_bg:getContentSize().height*0.5))
	menuCloseBar:addChild(closeMenuItem)

	--  创建竞技和排行按钮
	tabLayer = BaseUI.createSpriteTopTabLayer( { GetLocalizeStringBy("key_1236"), GetLocalizeStringBy("key_1259"), GetLocalizeStringBy("key_3051"), GetLocalizeStringBy("lic_1049") },
	  	28,26,
	  	g_sFontPangWa,
	  	ccc3(0xff, 0xe4, 0x00),ccc3(0x48, 0x85, 0xb5),
	  	CCSizeMake(140,66) 
	)
	tabLayer:setPosition(ccp(0,0))
	tabLayer:setScale(1/MainScene.elementScale)
    m_mainLayer:addChild(tabLayer,2)
    -- 设置竞技和排行按钮位置
    -- 我的好友按钮位置
    tabLayer:buttonOfIndex(0):setAnchorPoint(ccp(0,0))
	tabLayer:buttonOfIndex(0):setPosition(ccp(0, m_layerSize.height-87*MainScene.elementScale))
	tabLayer:buttonOfIndex(0):setScale(MainScene.elementScale)
	-- 推荐好友按钮位置
	local x1 = tabLayer:buttonOfIndex(0):getPositionX()+133*MainScene.elementScale
	tabLayer:buttonOfIndex(1):setAnchorPoint(ccp(0,0))
	tabLayer:buttonOfIndex(1):setPosition(ccp(x1, m_layerSize.height-87*MainScene.elementScale))
	tabLayer:buttonOfIndex(1):setScale(MainScene.elementScale)
	-- 领取耐力按钮位置
	local x1 = tabLayer:buttonOfIndex(1):getPositionX()+133*MainScene.elementScale
	tabLayer:buttonOfIndex(2):setAnchorPoint(ccp(0,0))
	tabLayer:buttonOfIndex(2):setPosition(ccp(x1, m_layerSize.height-87*MainScene.elementScale))
	tabLayer:buttonOfIndex(2):setScale(MainScene.elementScale)
	-- 黑名单按钮位置
	local x1 = tabLayer:buttonOfIndex(2):getPositionX()+133*MainScene.elementScale
	tabLayer:buttonOfIndex(3):setAnchorPoint(ccp(0,0))
	tabLayer:buttonOfIndex(3):setPosition(ccp(x1, m_layerSize.height-87*MainScene.elementScale))
	tabLayer:buttonOfIndex(3):setScale(MainScene.elementScale)
	-- 显示红色数字
	-- require "script/utils/ItemDropUtil"
	-- local num = FriendData.getReceiveListCount()
	-- print("*-*--*-* ", num)
	-- m_tipSprite = ItemDropUtil.getTipSpriteByNum( num )
	-- m_tipSprite:setAnchorPoint(ccp(1,1))
	-- m_tipSprite:setPosition(tabLayer:buttonOfIndex(2):getContentSize().width *0.98, tabLayer:buttonOfIndex(2):getContentSize().height*0.97)
	-- tabLayer:buttonOfIndex(2):addChild(m_tipSprite)
	-- 好友图标红圈
	-- FriendData.setShowTipSprite(true)
	-- if(num <= 0)then
	-- 	m_tipSprite:setVisible(false)
	-- end
	-- local canReceiveNum = FriendData.getTodayReceiveTimes()
	-- print("canReceiveNum",canReceiveNum)
	-- if(canReceiveNum <= 0 or num <= 0 )then
	-- 	-- 好友图标红圈
	-- 	FriendData.setShowTipSprite(false)
	-- end

	-- 设置默认显示 
    require "script/ui/friend/MyFriendLayer"
    tabLayer:layerOfIndex(0):addChild( MyFriendLayer.createMyFriendLayer() )
    -- 按钮切换事件
	tabLayer:registerScriptTapHandler(function ( button,index )
		if (index == 0) then
			-- 音效
			require "script/audio/AudioUtil"
			AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
			FriendData.friendPage = 1
			tabLayer:layerOfIndex(0):addChild( MyFriendLayer.createMyFriendLayer() )
		elseif (index == 1) then
			-- 音效
			require "script/audio/AudioUtil"
			AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
			require "script/ui/friend/RecommendLayer"
			FriendData.showRecomdPage = 1
			tabLayer:layerOfIndex(1):addChild( RecommendLayer.createRecommendLayer() )
		elseif (index == 2) then
			-- 音效
			require "script/audio/AudioUtil"
			AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
			require "script/ui/friend/GetStaminaLayer"
			tabLayer:layerOfIndex(2):addChild( GetStaminaLayer.createGetStaminaLayer() )
		elseif (index == 3) then
			-- 音效
			require "script/audio/AudioUtil"
			AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
			require "script/ui/friend/BlackListLayer"
			tabLayer:layerOfIndex(3):addChild( BlackListLayer.createBlackListLayer() )
        end
	end)

end

-- 创建好友界面
function creatFriendLayer()
	m_mainLayer = MainScene.createBaseLayer("images/main/module_bg.png", true, false,true)
	m_mainLayer:registerScriptHandler(onNodeEvent)

	-- 初始化邮件层
	initFriendLayer()

	return m_mainLayer
end


































