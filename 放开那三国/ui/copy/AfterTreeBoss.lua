-- FileName: AfterTreeBoss.lua 
-- Author: Li Cong 
-- Date: 13-11-2 
-- Purpose: function description of module 

module("AfterTreeBoss", package.seeall)
require "script/model/DataCache"
local _mainLayer = nil
local afterOKCallFun = nil

-- touch事件处理
local function cardLayerTouch(eventType, x, y)
    return true
end


function creteAfterTreeBossLayer( harmData, silverData, afterOKCallFun, addTreeExp )
	-- 点击确定按钮传入回调
    afterOKCallFun = afterOKCallFun
    
    local winSize = CCDirector:sharedDirector():getWinSize()
    _mainLayer = CCLayerColor:create(ccc4(11,11,11,200))
    _mainLayer:setTouchEnabled(true)
    _mainLayer:registerScriptTouchHandler(cardLayerTouch,false,-600,true)

    -- 创建背景框
    local bg_sprite = CCScale9Sprite:create("images/upgrade/upgrade_bg.png")
    bg_sprite:setContentSize(CCSizeMake(560,500))
    bg_sprite:setAnchorPoint(ccp(0.5,0.5))
    bg_sprite:setPosition(ccp(winSize.width*0.5,winSize.height*0.50))
    _mainLayer:addChild(bg_sprite)
    -- 适配
    setAdaptNode(bg_sprite)

    -- 标题
    local titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(ccp(bg_sprite:getContentSize().width/2, bg_sprite:getContentSize().height-6.6 ))
	bg_sprite:addChild(titlePanel)
	local titleLabel = LuaCCLabel.createShadowLabel(GetLocalizeStringBy("key_2956"), g_sFontPangWa, 34)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setPosition(ccp(90, 10))
	titlePanel:addChild(titleLabel)

	-- 按钮
	local menu = CCMenu:create()
    menu:setTouchPriority(-600)
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	bg_sprite:addChild(menu,2)
	-- local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	-- closeButton:setAnchorPoint(ccp(0.5, 0.5))
	-- closeButton:setPosition(ccp(bg_sprite:getContentSize().width * 0.955, bg_sprite:getContentSize().height*0.965 ))
	-- closeButton:registerScriptTapHandler(closeButtonCallback)
	-- menu:addChild(closeButton)

	-- 确定
    local okItem = createButtonItem(GetLocalizeStringBy("key_1985"))
    okItem:setAnchorPoint(ccp(0.5,0.5))
    okItem:registerScriptTapHandler(closeButtonCallback)
    menu:addChild(okItem,2)
    okItem:setPosition(ccp(bg_sprite:getContentSize().width*0.5,68))

    -- 战绩如下
    local line = CCScale9Sprite:create("images/common/line2.png")
    line:setAnchorPoint(ccp(0.5,0.5))
    line:setPosition(ccp(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height-85))
    bg_sprite:addChild(line)
    local font_str = GetLocalizeStringBy("key_1221")
    local font = CCRenderLabel:create(font_str, g_sFontPangWa, 30, 1, ccc3( 0xff, 0xff, 0xff), type_stroke)
    font:setAnchorPoint(ccp(0.5,0.5))
    font:setColor(ccc3(0x78,0x25,0x00))
    font:setPosition(ccp(line:getContentSize().width*0.5,line:getContentSize().height*0.5))
    line:addChild(font)

    -- 挑战伤害总值
	local bg1 = CCScale9Sprite:create("images/common/labelbg_white.png")
	bg1:setContentSize(CCSizeMake(450,45))
	bg1:setAnchorPoint(ccp(0.5,1))
	bg1:setPosition(ccp(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height-125))
	bg_sprite:addChild(bg1)
	local font1 = CCRenderLabel:create(GetLocalizeStringBy("key_3105"), g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	font1:setAnchorPoint(ccp(0,0.5))
	font1:setColor(ccc3(0xfe,0xdb,0x1c))
	font1:setPosition(ccp(10,bg1:getContentSize().height*0.5))
	bg1:addChild(font1)
	-- 伤害数值
	local harm = harmData or 0
	local font2 = CCRenderLabel:create(harm, g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	font2:setAnchorPoint(ccp(0,0.5))
	font2:setColor(ccc3(0xff,0x42,0x00))
	font2:setPosition(ccp(222,bg1:getContentSize().height*0.5))
	bg1:addChild(font2)
	
    -- 获得银币奖励
    local bg2 = CCScale9Sprite:create("images/common/labelbg_white.png")
	bg2:setContentSize(CCSizeMake(450,45))
	bg2:setAnchorPoint(ccp(0.5,1))
	bg2:setPosition(ccp(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height-200))
	bg_sprite:addChild(bg2)
    local coin = CCRenderLabel:create(GetLocalizeStringBy("key_2423"), g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	coin:setAnchorPoint(ccp(0,0.5))
	coin:setColor(ccc3(0xfe,0xdb,0x1c))
	coin:setPosition(ccp(10,bg2:getContentSize().height*0.5))
	bg2:addChild(coin)
    local icon = CCSprite:create("images/common/coin.png")
	icon:setAnchorPoint(ccp(0,0.5))
	icon:setPosition(ccp(222,bg2:getContentSize().height*0.5))
	bg2:addChild(icon)
	-- 获得银币数量
	local coinData = silverData or 0
	local coin_data = CCRenderLabel:create(coinData, g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	coin_data:setAnchorPoint(ccp(0,0.5))
	coin_data:setColor(ccc3(0xd7,0xd7,0xd7))
	coin_data:setPosition(ccp(252,bg2:getContentSize().height*0.5))
	bg2:addChild(coin_data)
	
    -- 摇钱树获得经验
    local nodeTab = {}
    local curFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1294"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    curFont:setColor(ccc3(0xff, 0xff, 0xff))
    table.insert(nodeTab,curFont)
    -- 等级
    local expSp = CCSprite:create("images/common/exp.png")
    table.insert(nodeTab,expSp)
    local expData = addTreeExp
    local expFont = CCRenderLabel:create( " " .. expData, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    expFont:setColor(ccc3(0xff, 0xf6, 0x00))
    table.insert(nodeTab,expFont)
    -- 提示
    local tipNode = BaseUI.createHorizontalNode(nodeTab)
    tipNode:setAnchorPoint(ccp(0,0.5))
    tipNode:setPosition( 66 , bg_sprite:getContentSize().height*0.45)
    bg_sprite:addChild(tipNode)

	-- 摇钱树等级
    local nodeArr = {}
    local curFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1271"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    curFont:setColor(ccc3(0xff, 0xff, 0xff))
    table.insert(nodeArr,curFont)
    -- 等级
    local lvSp = CCSprite:create("images/common/lv.png")
    table.insert(nodeArr,lvSp)
    local level = DataCache.getBakBossTreeLevel()
    local lvFont = CCRenderLabel:create(" " .. level, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    lvFont:setColor(ccc3(0xff, 0xf6, 0x00))
    table.insert(nodeArr,lvFont)
    local actionArray = CCArray:create()
    actionArray:addObject(CCDelayTime:create(0.5))
    actionArray:addObject(CCCallFunc:create(function ( ... )
    	level = DataCache.getTreeBossLevel()
    	lvFont:setString(level)
    end))
    local seqAction = CCSequence:create(actionArray)
    lvFont:runAction(seqAction)

    -- 最大等级
    local curLv = DataCache.getTreeBossLevel()
    local maxLv = DataCache.getConfigTreeMaxLv()
    local realExpNum = 0
    local needExpNum = 0
    local rate = 0
    if(curLv < maxLv)then
    	-- 经验条
        realExpNum = DataCache.getTreeBossExp()
    	needExpNum = DataCache.getTreeBossMaxExp(DataCache.getTreeBossLevel() + 1)
    	rate = realExpNum/needExpNum
    	if(rate > 1)then
    		rate = 1
    	end
    else
        rate = 1
    end
    --留一点空隙
    local spaceNode = CCNode:create()
    spaceNode:setContentSize(CCSizeMake(15,20))
    table.insert(nodeArr,spaceNode)
    -- expbg
    local bgProress = CCScale9Sprite:create("images/common/exp_bg.png")
	bgProress:setContentSize(CCSizeMake(181, 23))
	table.insert(nodeArr,bgProress)
	-- 蓝条
	local progressSp = CCScale9Sprite:create("images/common/exp_progress.png")
	progressSp:setContentSize(CCSizeMake(181*rate, 23))
	progressSp:setAnchorPoint(ccp(0, 0.5))
	progressSp:setPosition(ccp(0, bgProress:getContentSize().height * 0.5))
	bgProress:addChild(progressSp)
	-- 经验值
    if(curLv < maxLv)then
    	local expLabel = CCRenderLabel:create(realExpNum .. "/" .. needExpNum, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    	expLabel:setColor(ccc3(0xff, 0xff, 0xff))
    	expLabel:setAnchorPoint(ccp(0.5, 0.5))
    	expLabel:setPosition(ccp(bgProress:getContentSize().width*0.5, bgProress:getContentSize().height*0.5))
    	bgProress:addChild(expLabel,10)
    else
        local maxSprrite = CCSprite:create("images/common/max.png")
        maxSprrite:setAnchorPoint(ccp(0.5, 0.5))
        maxSprrite:setPosition(ccp(bgProress:getContentSize().width*0.5, bgProress:getContentSize().height * 0.5))
        bgProress:addChild(maxSprrite,10)
    end
	-- 提示
    local expNode = BaseUI.createHorizontalNode(nodeArr)
    expNode:setAnchorPoint(ccp(0,0.5))
    expNode:setPosition( 66, bg_sprite:getContentSize().height*0.35)
    bg_sprite:addChild(expNode)


    local font1 = CCLabelTTF:create(GetLocalizeStringBy("lic_1295"), g_sFontName, 18)
    font1:setAnchorPoint(ccp(0.5,0.5))
    font1:setColor(ccc3(0x78,0x25,0x00))
    font1:setPosition(ccp(bg_sprite:getContentSize().width*0.5 , bg_sprite:getContentSize().height*0.25))
    bg_sprite:addChild(font1)

    return _mainLayer
end

-- 按钮item
function createButtonItem( str )
    local normalSprite  =CCScale9Sprite:create("images/common/btn/btn_green_n.png")
    local selectSprite  =CCScale9Sprite:create("images/common/btn/btn_green_h.png")
    local item = CCMenuItemSprite:create(normalSprite,selectSprite)
    -- 字体
    local item_font = CCRenderLabel:create( str , g_sFontPangWa, 35, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    item_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
    item_font:setAnchorPoint(ccp(0.5,0.5))
    item_font:setPosition(ccp(item:getContentSize().width*0.5,item:getContentSize().height*0.5))
    item:addChild(item_font)
    return item
end

-- 关闭按钮回调
function closeButtonCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	require "script/battle/BattleLayer"
    BattleLayer.closeLayer()
	-- 自定义回调
	if(afterOKCallFun ~= nil)then
		afterOKCallFun()
	end
end




































