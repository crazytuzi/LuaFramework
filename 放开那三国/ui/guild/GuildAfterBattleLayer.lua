-- FileName: GuildAfterBattleLayer.lua 
-- Author: Li Cong 
-- Date: 14-2-28 
-- Purpose: function description of module 公会


module("GuildAfterBattleLayer", package.seeall)
require "script/model/user/UserModel"
require "script/ui/item/ItemSprite"
require "script/ui/item/ItemUtil"
require "script/ui/hero/HeroPublicLua"
require "script/ui/hero/HeroPublicCC"

local mainLayer 				= nil
local menu 						= nil
local backAnimSprite 			= nil
local animSprite 				= nil
local winSize 					= nil
local bg_sprite					= nil
-- 回调函数
local afterOKCallFun 			= nil
-- 掉落物品数据
local _flopData 				= nil
-- 三个按钮
local userFormationItem 		= nil
local replayItem 				= nil
local okItem 					= nil
local userFormationItem_font 	= nil
local replayItem_font 			= nil
local okItem_font 				= nil
local _allData 					= nil
local flop_bg 					= nil
local _isReplay                  = nil

-- 初始化
function init( ... )
    mainLayer 					= nil
    menu 						= nil
    backAnimSprite 				= nil
    animSprite 					= nil
    winSize 					= nil
    bg_sprite 					= nil
    -- 回调函数
    afterOKCallFun 				= nil
    -- 掉落物品数据
    _flopData 					= nil
    -- 三个按钮
    userFormationItem 			= nil
    replayItem 					= nil
    okItem 						= nil
    userFormationItem_font 		= nil
    replayItem_font 			= nil
    okItem_font 				= nil
    _allData 					= nil
    flop_bg 					= nil
    _isReplay                   = nil
end
-- touch事件处理
local function cardLayerTouch(eventType, x, y)
   
    return true
    
end

-- 创建挑战结算面板
-- flopData:掉落数据
-- CallFun: 自定义确定按钮后回调
function createAfterBattleLayer( tAllData, isReplay, CallFun )
    -- 初始化
    init()
    -- 所有数据
    _allData = tAllData
    print("=======>>>>")
    print_t(_allData)
    -- 点击确定按钮传入回调
    afterOKCallFun = CallFun
    -- 是否重播
    _isReplay = isReplay
    -- 掉落物品
    _flopData = tAllData.reward.item or {}
    winSize = CCDirector:sharedDirector():getWinSize()
    mainLayer = CCLayerColor:create(ccc4(11,11,11,200))
    mainLayer:setTouchEnabled(true)
    mainLayer:registerScriptTouchHandler(cardLayerTouch,false,-560,true)

    -- 战斗胜负判断
    local isWin = nil
    local appraisal = tAllData.server.result
    --  appraisal true是玩家这方赢了
    if( appraisal == "true" or appraisal == true )then
        isWin = true
        -- 创建胜利背景框
        bg_sprite = BaseUI.createViewBg(CCSizeMake(520,745))
        bg_sprite:setAnchorPoint(ccp(0.5,0.5))
        bg_sprite:setPosition(ccp(winSize.width/2,winSize.height*0.40))
        mainLayer:addChild(bg_sprite)
    else
        isWin = false
        -- 创建失败背景框
        bg_sprite = BaseUI.createViewBg(CCSizeMake(520,728))
        bg_sprite:setAnchorPoint(ccp(0.5,0.5))
        bg_sprite:setPosition(ccp(winSize.width/2,winSize.height*0.40))
        mainLayer:addChild(bg_sprite)
    end

    -- 创建V/S
    local vs_sprite = CCSprite:create("images/arena/vs.png")
    vs_sprite:setAnchorPoint(ccp(0.5,0.5))
    vs_sprite:setPosition(ccp(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height-70))
    bg_sprite:addChild(vs_sprite)
    -- 我方名字
    local fullRect = CCRectMake(0,0,31,41)
	local insetRect = CCRectMake(8,17,2,2)
    local myName_bg = CCScale9Sprite:create("images/common/b_name_bg.png", fullRect, insetRect)
    myName_bg:setContentSize(CCSizeMake(195,44))
    myName_bg:setAnchorPoint(ccp(0,0.5))
    myName_bg:setPosition(ccp(23,bg_sprite:getContentSize().height-70))
    bg_sprite:addChild(myName_bg)
    -- 我方姓名的颜色
    local myNameStr = tAllData.server.team1.name or " "
    local name_color,stroke_color = getHeroNameColor( 2 )
    local myName_font = CCRenderLabel:create( myNameStr, g_sFontPangWa, 25, 1, stroke_color, type_stroke)
    myName_font:setColor(name_color)
    myName_font:setAnchorPoint(ccp(0.5,0.5))
    myName_font:setPosition(ccp(myName_bg:getContentSize().width*0.5,myName_bg:getContentSize().height*0.5))
    myName_bg:addChild(myName_font)

    -- 敌方名字 
    local fullRect = CCRectMake(0,0,31,41)
	local insetRect = CCRectMake(8,17,2,2)
    local enemyName_bg = CCScale9Sprite:create("images/common/b_name_bg.png", fullRect, insetRect)
    enemyName_bg:setContentSize(CCSizeMake(195,44))
    enemyName_bg:setAnchorPoint(ccp(0,0.5))
    enemyName_bg:setPosition(ccp(bg_sprite:getContentSize().width-23,bg_sprite:getContentSize().height-70))
    bg_sprite:addChild(enemyName_bg)
    enemyName_bg:setScale(enemyName_bg:getScaleX()*-1)
    -- 敌方姓名的颜色
    local enemyNameStr = getEnemyNameByCopyId(tAllData.server.team2.name)
    local name_color,stroke_color = getHeroNameColor( 1 )
    local enemyName_font = CCRenderLabel:create( enemyNameStr, g_sFontPangWa, 25, 1, stroke_color, type_stroke)
    enemyName_font:setColor(name_color)
    enemyName_font:setAnchorPoint(ccp(0.5,0.5))
    enemyName_font:setPosition(ccp(enemyName_bg:getContentSize().width*0.5,enemyName_bg:getContentSize().height*0.5))
    enemyName_bg:addChild(enemyName_font)
    enemyName_font:setScale(enemyName_font:getScaleX()*-1)

    -- 三个按钮
    menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-570)
    bg_sprite:addChild(menu)

    -- 查看战报
    userFormationItem = createButtonItem()
    userFormationItem:setAnchorPoint(ccp(0.5,0.5))
    userFormationItem:registerScriptTapHandler(userFormationItemFun)
    menu:addChild(userFormationItem)
    -- 字体
    userFormationItem_font = CCRenderLabel:create( GetLocalizeStringBy("key_2849") , g_sFontPangWa, 35, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    userFormationItem_font:setAnchorPoint(ccp(0.5,0.5))
    userFormationItem_font:setPosition(ccp(userFormationItem:getContentSize().width*0.5,userFormationItem:getContentSize().height*0.5))
    userFormationItem:addChild(userFormationItem_font)
    userFormationItem_font:setColor(ccc3(0xfe, 0xdb, 0x1c))

    -- 发送战报 -- added by zhz
    _sendMsgItem =  createButtonItem()
    _sendMsgItem:setAnchorPoint(ccp(0.5,0.5))
    _sendMsgItem:registerScriptTapHandler(sendMegFun )
    menu:addChild(_sendMsgItem)
    -- 文字
    _sendMsgItem_font = CCRenderLabel:create( GetLocalizeStringBy("key_4000") , g_sFontPangWa, 35, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _sendMsgItem_font:setAnchorPoint(ccp(0.5,0.5))
    _sendMsgItem_font:setPosition(ccp(_sendMsgItem:getContentSize().width*0.5,_sendMsgItem:getContentSize().height*0.5))
    _sendMsgItem:addChild(_sendMsgItem_font)
    _sendMsgItem_font:setColor(ccc3(0xfe, 0xdb, 0x1c))

    -- 重播
    replayItem = createButtonItem()
    replayItem:setAnchorPoint(ccp(0.5,0.5))
    replayItem:registerScriptTapHandler(replayItemFun)
    menu:addChild(replayItem)
    -- 字体
    replayItem_font = CCRenderLabel:create( GetLocalizeStringBy("key_2184") , g_sFontPangWa, 35, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    replayItem_font:setAnchorPoint(ccp(0.5,0.5))
    replayItem_font:setPosition(ccp(replayItem:getContentSize().width*0.5,replayItem:getContentSize().height*0.5))
    replayItem:addChild(replayItem_font)
	-- replayItem_font:setColor(ccc3(0xfe, 0xdb, 0x1c))

	-- 重播功能暂未开放
	replayItem:setEnabled(false)
    replayItem_font:setColor(ccc3(0xf1,0xf1,0xf1))


    -- 确定
    okItem = createButtonItem()
    okItem:setAnchorPoint(ccp(0.5,0.5))
    okItem:registerScriptTapHandler(okItemFun)
    menu:addChild(okItem)
    -- 字体
    okItem_font = CCRenderLabel:create( GetLocalizeStringBy("key_1985") , g_sFontPangWa, 35, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    okItem_font:setAnchorPoint(ccp(0.5,0.5))
    okItem_font:setPosition(ccp(okItem:getContentSize().width*0.5,okItem:getContentSize().height*0.5))
    okItem:addChild(okItem_font)
	okItem_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
    

    if(isWin) then
        -- 创建中间ui
        -- -- 获得银币
		local bg1 = CCScale9Sprite:create("images/common/labelbg_white.png")
		bg1:setContentSize(CCSizeMake(384,40))
		bg1:setAnchorPoint(ccp(0.5,0.5))
		bg1:setPosition(ccp(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height-140))
		bg_sprite:addChild(bg1)
		local font1 = CCLabelTTF:create(GetLocalizeStringBy("key_2415"), g_sFontName, 24)
		font1:setAnchorPoint(ccp(0,0.5))
		font1:setColor(ccc3(0x78,0x25,0x00))
		font1:setPosition(ccp(75,bg1:getContentSize().height*0.5))
		bg1:addChild(font1)
		local icon1 = CCSprite:create("images/common/coin.png")
		icon1:setAnchorPoint(ccp(0,0.5))
		icon1:setPosition(ccp(222,bg1:getContentSize().height*0.5))
		bg1:addChild(icon1)
		-- 获得银币数量
		local coinData = tAllData.reward.silver or 0
		local coin_data = CCLabelTTF:create( coinData, g_sFontName, 24)
		coin_data:setAnchorPoint(ccp(0,0.5))
		coin_data:setColor(ccc3(0x00,0x00,0x00))
		coin_data:setPosition(ccp(258,bg1:getContentSize().height*0.5))
		bg1:addChild(coin_data)
		-- 获得将魂
		local bg2 = CCScale9Sprite:create("images/common/labelbg_white.png")
		bg2:setContentSize(CCSizeMake(384,40))
		bg2:setAnchorPoint(ccp(0.5,0.5))
		bg2:setPosition(ccp(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height-190))
		bg_sprite:addChild(bg2)
		local font2 = CCLabelTTF:create(GetLocalizeStringBy("key_1228"), g_sFontName, 24)
		font2:setAnchorPoint(ccp(0,0.5))
		font2:setColor(ccc3(0x78,0x25,0x00))
		font2:setPosition(ccp(75,bg2:getContentSize().height*0.5))
		bg2:addChild(font2)
		local icon2 = CCSprite:create("images/common/icon_soul.png")
		icon2:setAnchorPoint(ccp(0,0.5))
		icon2:setPosition(ccp(222,bg2:getContentSize().height*0.5))
		bg2:addChild(icon2)
		-- 获得将魂数量
		local soulData = tAllData.reward.soul or 0
		local soul_data = CCLabelTTF:create( soulData, g_sFontName, 24)
		soul_data:setAnchorPoint(ccp(0,0.5))
		soul_data:setColor(ccc3(0x00,0x00,0x00))
		soul_data:setPosition(ccp(258,bg2:getContentSize().height*0.5))
		bg2:addChild(soul_data)
		-- 获得经验
		local bg3 = CCScale9Sprite:create("images/common/labelbg_white.png")
		bg3:setContentSize(CCSizeMake(384,40))
		bg3:setAnchorPoint(ccp(0.5,0.5))
		bg3:setPosition(ccp(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height-240))
		bg_sprite:addChild(bg3)
		local font3 = CCLabelTTF:create(GetLocalizeStringBy("key_3142"), g_sFontName, 24)
		font3:setAnchorPoint(ccp(0,0.5))
		font3:setColor(ccc3(0x78,0x25,0x00))
		font3:setPosition(ccp(75,bg3:getContentSize().height*0.5))
		bg3:addChild(font3)
		local icon3 = CCSprite:create("images/common/exp.png")
		icon3:setAnchorPoint(ccp(0,0.5))
		icon3:setPosition(ccp(199,bg3:getContentSize().height*0.5))
		bg3:addChild(icon3)
		-- 获得将魂数量
		local expData = tAllData.reward.exp or 0
		local exp_data = CCLabelTTF:create( expData, g_sFontName, 24)
		exp_data:setAnchorPoint(ccp(0,0.5))
		exp_data:setColor(ccc3(0x00,0x00,0x00))
		exp_data:setPosition(ccp(262,bg3:getContentSize().height*0.5))
		bg3:addChild(exp_data)

        -- 掉落物品背景
		flop_bg = CCScale9Sprite:create("images/common/bg/9s_1.png")
		flop_bg:setContentSize(CCSizeMake(450, 280))
		flop_bg:setAnchorPoint(ccp(0.5, 1))
		flop_bg:setPosition(ccp(bg_sprite:getContentSize().width*0.5, bg_sprite:getContentSize().height - 300))
		bg_sprite:addChild(flop_bg)
		-- 掉落标题
		local titleSprite = CCScale9Sprite:create("images/common/astro_labelbg.png")
		titleSprite:setContentSize(CCSizeMake(200, 35))
		titleSprite:setAnchorPoint(ccp(0.5, 0.5))
		titleSprite:setPosition(ccp(flop_bg:getContentSize().width*0.5, flop_bg:getContentSize().height))
		flop_bg:addChild(titleSprite)
		-- 标题文字
		local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2882"), g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	    titleLabel:setPosition(ccp(titleSprite:getContentSize().width*0.5 - titleLabel:getContentSize().width*0.5, titleSprite:getContentSize().height*0.5 + titleLabel:getContentSize().height*0.5))
	    titleSprite:addChild(titleLabel)
       	
       	-- 创建掉落列表
       	createItemTableView()

        -- 对方阵容位置
        userFormationItem:setPosition(ccp(bg_sprite:getContentSize().width*0.3,124))

        -- -- 发送战报
        _sendMsgItem:setPosition(bg_sprite:getContentSize().width*0.7,124)

        -- 重播位置
        replayItem:setPosition(ccp(bg_sprite:getContentSize().width*0.3,57))
        -- 确定位置
        okItem:setPosition(ccp(bg_sprite:getContentSize().width*0.7,57))

        -- 胜利特效
        backAnimSprite2 = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushengli03"), -1,CCString:create(""));
        backAnimSprite2:setAnchorPoint(ccp(0.5, 0.5))
        backAnimSprite2:setPosition(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height)
        bg_sprite:addChild(backAnimSprite2,-1)
        backAnimSprite2:setVisible(false)
        
        local function showBg2()
            --print("================showBg2")
            backAnimSprite2:setVisible(true)
        end
        
        local layerActionArray = CCArray:create()
        layerActionArray:addObject(CCDelayTime:create(0.1))
        layerActionArray:addObject(CCCallFunc:create(showBg2))
        backAnimSprite2:runAction(CCSequence:create(layerActionArray))

        backAnimSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushengli02"), -1,CCString:create(""));
        
        backAnimSprite:setAnchorPoint(ccp(0.5, 0.5))
        backAnimSprite:setPosition(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height-10)
        bg_sprite:addChild(backAnimSprite,0)
        
        animSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushengli01"), -1,CCString:create(""))
    else
        -- 对方阵容位置
        userFormationItem:setPosition(ccp(bg_sprite:getContentSize().width*0.3,130))

        -- 发送战报
        _sendMsgItem:setPosition(bg_sprite:getContentSize().width*0.7, 130)

        -- 重播位置
        replayItem:setPosition(ccp(bg_sprite:getContentSize().width*0.3,57))
        -- 确定位置
        okItem:setPosition(ccp(bg_sprite:getContentSize().width*0.7,57))
   
        -- 创建中间ui
        local middle_bg = BaseUI.createContentBg(CCSizeMake(463,414))
        middle_bg:setAnchorPoint(ccp(0.5,1))
        middle_bg:setPosition(ccp(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height-145))
        bg_sprite:addChild(middle_bg)
        -- 花纹
        -- local huawen = CCSprite:create("images/arena/huawen.png")
        -- huawen:setAnchorPoint(ccp(0.5,0.5))
        -- huawen:setPosition(ccp(middle_bg:getContentSize().width*0.5,middle_bg:getContentSize().height-35))
        -- middle_bg:addChild(huawen)
        -- -- 恭喜获得
        -- local huode = CCRenderLabel:create( GetLocalizeStringBy("key_1400") , g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        -- huode:setColor(ccc3(0xff, 0xf6, 0x00))
        -- huode:setAnchorPoint(ccp(0.5,0.5))
        -- huode:setPosition(ccp(huawen:getContentSize().width*0.5,huawen:getContentSize().height*0.5))
        -- huawen:addChild(huode)
        -- -- 银币
        -- local yibi = CCSprite:create("images/arena/yibi.png")
        -- yibi:setAnchorPoint(ccp(0,1))
        -- yibi:setPosition(ccp(10,middle_bg:getContentSize().height-65))
        -- middle_bg:addChild(yibi)
        -- local silverData = silverData or 0
        -- local yibi_data = CCRenderLabel:create("+".. silverData , g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        -- yibi_data:setColor(ccc3(0x70,0xff,0x18))
        -- yibi_data:setPosition(ccp(65,middle_bg:getContentSize().height-61))
        -- middle_bg:addChild(yibi_data)
        -- -- exp
        -- local exp = CCSprite:create("images/arena/exp.png")
        -- exp:setAnchorPoint(ccp(0,1))
        -- exp:setPosition(ccp(180,middle_bg:getContentSize().height-65))
        -- middle_bg:addChild(exp)
        -- local expData = expData or 0
        -- local exp_data = CCRenderLabel:create("+".. expData, g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        -- exp_data:setColor(ccc3(0x00,0xe4,0xff))
        -- exp_data:setPosition(ccp(238,middle_bg:getContentSize().height-61))
        -- middle_bg:addChild(exp_data)
        -- -- 耐力
        -- local naili = CCSprite:create("images/arena/naili.png")
        -- naili:setAnchorPoint(ccp(0,1))
        -- naili:setPosition(ccp(360,middle_bg:getContentSize().height-65))
        -- middle_bg:addChild(naili)
        -- local naili_data = CCRenderLabel:create("-2", g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        -- naili_data:setColor(ccc3(0xff,0x17,0x0c))
        -- naili_data:setPosition(ccp(415,middle_bg:getContentSize().height-61))
        -- middle_bg:addChild(naili_data)

        local str1 = GetLocalizeStringBy("key_3053")
        local text1 = CCRenderLabel:create( str1 , g_sFontPangWa, 26, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        text1:setColor(ccc3(0xff, 0xff, 0xff))
        text1:setPosition(ccp(45,middle_bg:getContentSize().height-20))
        middle_bg:addChild(text1)
        local str2 = GetLocalizeStringBy("key_1175")
        local text2 = CCRenderLabel:create( str2 , g_sFontPangWa, 26, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        text2:setColor(ccc3(0xff, 0xff, 0xff))
        text2:setPosition(ccp(10,middle_bg:getContentSize().height-66))
        middle_bg:addChild(text2)

        -- 四个按钮
        local middle_menu = CCMenu:create()
        middle_menu:setPosition(ccp(0,0))
        middle_menu:setTouchPriority(-570)
        middle_bg:addChild(middle_menu)

        -- 武将强化
        local strengthen_hero_item = CCMenuItemImage:create("images/common/strengthen_hero_n.png","images/common/strengthen_hero_h.png")
        strengthen_hero_item:setAnchorPoint(ccp(0,0.5))
        strengthen_hero_item:setPosition(ccp(18,181))
        middle_menu:addChild(strengthen_hero_item)
        strengthen_hero_item:registerScriptTapHandler(strengthenHeroFun)

        -- 调整整容， changed by zhz。
        local formation_item= CCMenuItemImage:create("images/common/change_formation_n.png","images/common/change_formation_h.png")
        formation_item:setAnchorPoint(ccp(0.5,0.5))
        formation_item:setPosition(ccp(middle_bg:getContentSize().width/2 ,181))
        middle_menu:addChild(formation_item)
        formation_item:registerScriptTapHandler(formationFun)

        -- 装备强化
        local strengthen_arm_item = CCMenuItemImage:create("images/common/strengthen_arm_n.png","images/common/strengthen_arm_h.png")
        strengthen_arm_item:setAnchorPoint(ccp(0.5,0.5))
        strengthen_arm_item:setPosition(ccp(387,181))
        middle_menu:addChild(strengthen_arm_item)
        strengthen_arm_item:registerScriptTapHandler(strengthenArmFun)
        -- 培养名将
        local train_star_item = CCMenuItemImage:create("images/common/train_star_n.png","images/common/train_star_h.png")
        train_star_item:setAnchorPoint(ccp(0.5,0.5))
        train_star_item:setPosition(ccp(123,58))
        middle_menu:addChild(train_star_item)
        train_star_item:registerScriptTapHandler(trainStarFun)
        -- -- 喂养宠物
        -- local feed_pet_item = CCMenuItemImage:create("images/common/feed_pet_n.png","images/common/feed_pet_h.png")
        -- feed_pet_item:setAnchorPoint(ccp(0.5,0.5))
        -- feed_pet_item:setPosition(ccp(337,58))
        -- middle_menu:addChild(feed_pet_item)
        -- feed_pet_item:registerScriptTapHandler(feedPetFun)

          -- 升级战魂
        local fight_soul_item = CCMenuItemImage:create("images/common/up_fightsoul_n.png","images/common/up_fightsoul_h.png")
        fight_soul_item:setAnchorPoint(ccp(0.5,0.5))
        fight_soul_item:setPosition(ccp(337,56))
        middle_menu:addChild(fight_soul_item)
        fight_soul_item:registerScriptTapHandler(fightSoulFun)

        animSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushibai"), -1,CCString:create(""))
    end
    
    animSprite:setAnchorPoint(ccp(0.5, 0.5));
    animSprite:setPosition(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height-20)
    bg_sprite:addChild(animSprite)
    
    delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animationEnd)
    delegate:registerLayerChangedHandler(animationFrameChanged)
    animSprite:setDelegate(delegate)

    -- 适配
    setAdaptNode(bg_sprite)

    -- 为保持数据一致 已创建就开始加数值
    bg_sprite:registerScriptHandler(function ( eventType,node )
        if(eventType == "enter") then
            -- 加奖励数据
            -- 胜利了
            if(_isReplay ~= true)then 
                local appraisal = _allData.server.result
                if( appraisal == "true" or appraisal == true )then
                    -- 加银币
                    local coin = tonumber(_allData.reward.silver) or 0
                    UserModel.addSilverNumber(coin)
                    -- 加将魂
                    local soul = tonumber(_allData.reward.soul) or 0
                    UserModel.addSoulNum(soul)
                    -- 加经验
                    local exp = tonumber(_allData.reward.exp) or 0
                    UserModel.addExpValue(exp,"GuildAfterBattleLayer")
                    -- 扣除体力
                    require "script/ui/teamGroup/TeamGroupData"
                    TeamGroupData.changeExecution()
                end
            end
            require "script/ui/login/LoginScene"
            LoginScene.setBattleStatus(false)
        end
        if(eventType == "exit") then
        end
    end)
    return mainLayer
end

-- 特效播放结束后回调
function animationEnd( ... )
    if(backAnimSprite~=nil)then
        backAnimSprite:cleanup()
    end
    if(animSprite~=nil)then
        animSprite:cleanup()
    end
end

function animationFrameChanged( ... )
    -- body
end

-- 按钮item
function createButtonItem()
    local normalSprite  = CCScale9Sprite:create("images/common/btn/btn_green_n.png")
    local selectSprite  = CCScale9Sprite:create("images/common/btn/btn_green_h.png")
    local disabledSprite = CCScale9Sprite:create("images/common/btn/btn_hui.png")
    local item = CCMenuItemSprite:create(normalSprite,selectSprite,disabledSprite)
    return item
end


-- 查看战报回调
function userFormationItemFun( tag, item_obj )
    --add by zhang zihang
    if table.count(_allData.server.team1.memberList) == 0 or table.count(_allData.server.team2.memberList) == 0 then
        require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("key_2383"))
    else
        -- 音效
        require "script/audio/AudioUtil"
        AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
        print(GetLocalizeStringBy("key_1742") .. tag )

        require "script/ui/guild/copy/GuildBattleReportLayer"
        GuildBattleReportLayer.showLayer(_allData,false,-580)
    end
end

-- 重播回调
function replayItemFun( tag, item_obj )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print(GetLocalizeStringBy("key_2460") .. tag )
    -- require "script/battle/BattleLayer"
    -- BattleLayer.replay()
end

-- 确定回调
function okItemFun( tag, item_obj )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print(GetLocalizeStringBy("key_2060") .. tag )
    require "script/battle/GuildBattle"
    GuildBattle.closeLayer()

    require "script/ui/guild/GuildDataCache"
    print("GuildDataCache.getMineSigleGuildId() ",GuildDataCache.getMineSigleGuildId() )
    if(GuildDataCache.getMineSigleGuildId() > 0 )then
        -- 有军团 把下边的一排按钮隐藏
        MainScene.setMainSceneViewsVisible(false, false, true)
    else
        -- 没军团 把下边的一排按钮显示
        MainScene.setMainSceneViewsVisible(true, false, true)
    end

     -- 胜利了
    if(_isReplay ~= true)then 
        local appraisal = _allData.server.result
        if( appraisal == "true" or appraisal == true )then
            -- 扣除打副本次数
            require "script/ui/guild/copy/GuildCopyLayer"
            GuildCopyLayer.refreshUI()
        else
            -- 打副本次数
            require "script/ui/guild/copy/GuildCopyLayer"
            GuildCopyLayer.refreshTableView()
        end
    end

    -- 点确定后 调用回调
    if(afterOKCallFun ~= nil)then
        afterOKCallFun()
    end
end

-- added by zhz 发送战报的回调
function sendMegFun( tag, item )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    require "script/ui.chat/ChatUtil"
    local function sendClickCallback( )
         _sendMsgItem:setEnabled(false)
        _sendMsgItem_font:setColor(ccc3(0xf1,0xf1,0xf1))
        AnimationTip.showTip( GetLocalizeStringBy("key_4001") )
    end

    local fightStr = _allData.server
    ChatUtil.sendChatinfo(fightStr, ChatCache.ChatInfoType.battle_report_union, ChatCache.ChannelType.world, sendClickCallback)
end


-- 武将强化回调
function strengthenHeroFun()
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print(GetLocalizeStringBy("key_2409"))

    if not DataCache.getSwitchNodeState(ksSwitchGeneralForge) then
        return
    end
    -- 先关闭战斗场景
    require "script/battle/GuildBattle"
    GuildBattle.closeLayer()

    require "script/ui/hero/HeroLayer"
    MainScene.changeLayer(HeroLayer.createLayer(), "HeroLayer")
end

-- 装备强化回调
function strengthenArmFun()
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print(GetLocalizeStringBy("key_1244"))
    if not DataCache.getSwitchNodeState(ksSwitchWeaponForge) then
        return
    end
    -- 先关闭战斗场景
    require "script/battle/GuildBattle"
    GuildBattle.closeLayer() 

    require "script/ui/bag/BagLayer"
    local bagLayer = BagLayer.createLayer(BagLayer.Tag_Init_Arming)
    MainScene.changeLayer(bagLayer, "bagLayer")
end

-- 培养名将回调
function trainStarFun()
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print(GetLocalizeStringBy("key_2827"))

    if not DataCache.getSwitchNodeState(ksSwitchGreatSoldier) then
        return
    end
    -- 先关闭战斗场景
    require "script/battle/GuildBattle"
    GuildBattle.closeLayer()
    
    require "script/ui/star/StarLayer"
    local starLayer = StarLayer.createLayer()
    MainScene.changeLayer(starLayer, "starLayer")
end

-- 喂养宠物回调
function feedPetFun()
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print(GetLocalizeStringBy("key_2236"))
    if not DataCache.getSwitchNodeState(ksSwitchPet) then
        return
    end
    -- 先关闭战斗场景
    require "script/battle/GuildBattle"
    GuildBattle.closeLayer()

    require "script/ui/pet/PetMainLayer"
    local layer= PetMainLayer.createLayer()
    MainScene.changeLayer(layer, "PetMainLayer")
end

-- 跳到阵容的回调函数 , added by zhz
function formationFun(  )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print(GetLocalizeStringBy("key_2236"))
    -- 先关闭战斗场景
    require "script/battle/GuildBattle"
    GuildBattle.closeLayer()

    require("script/ui/formation/FormationLayer")
    local formationLayer = FormationLayer.createLayer()
    MainScene.changeLayer(formationLayer, "formationLayer")

end

-- 猎魂的回调函数 ，added by zhz
function fightSoulFun( )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print(GetLocalizeStringBy("key_2236"))
     -- 先关闭战斗场景
    require "script/battle/GuildBattle"
    GuildBattle.closeLayer()

    if not DataCache.getSwitchNodeState(ksSwitchBattleSoul) then
        return
    end
    require "script/ui/huntSoul/HuntSoulLayer"
    local layer = HuntSoulLayer.createHuntSoulLayer()
    MainScene.changeLayer(layer, "huntSoulLayer")
end


-- 玩家名字的颜色
function getHeroNameColor( utid )
    local name_color = nil
    local stroke_color = nil
    if(tonumber(utid) == 1)then
        -- 女性玩家
        name_color = ccc3(0xf9,0x59,0xff)
        stroke_color = ccc3(0x00,0x00,0x00)
    elseif(tonumber(utid) == 2)then
        -- 男性玩家 
        name_color = ccc3(0x00,0xe4,0xff)
        stroke_color = ccc3(0x00,0x00,0x00)
    end
    return name_color, stroke_color
end

-- 得到敌方的名字
function getEnemyNameByCopyId( id )
	require "db/DB_Copy_team"
	local data1 = DB_Copy_team.getDataById(tonumber(id))
	local strongHold_id = tonumber(data1.strongHold)
	require "db/DB_Stronghold"
	local data2 = DB_Stronghold.getDataById(strongHold_id)
	return data2.name
end


-- 创建物品列表
function createItemTableView()
	local itemData = getGuildBattleDropItem(_flopData)
	local cellSize = CCSizeMake(450, 140)
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = cellSize
		elseif fn == "cellAtIndex" then
			a2 = CCTableViewCell:create()
			local posArrX = {0.2,0.5,0.8}
			for i=1,3 do
				if(itemData[a1*3+i] ~= nil)then
					local item_sprite = createRewardCell(itemData[a1*3+i])
					item_sprite:setAnchorPoint(ccp(0.5,1))
					item_sprite:setPosition(ccp(450*posArrX[i],130))
					a2:addChild(item_sprite)
				end
			end
			r = a2
		elseif fn == "numberOfCells" then
			local num = #itemData
			r = math.ceil(num/3)
			print("num is : ", num)
		elseif fn == "cellTouched" then
			
		elseif (fn == "scroll") then
			
		end
		return r
	end)

	local goodTableView = LuaTableView:createWithHandler(h, CCSizeMake(450, 261))
	goodTableView:setBounceable(true)
	goodTableView:setTouchPriority(-580)
	-- 上下滑动
	goodTableView:setDirection(kCCScrollViewDirectionVertical)
	goodTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	goodTableView:setPosition(ccp(0,2))
	flop_bg:addChild(goodTableView)
end


-- 创建物品图标
function createRewardCell( cellValues )
	local iconBg = nil
	local iconName = nil
	local nameColor = nil
	if(cellValues.type == "silver") then
		-- 银币
		iconBg= ItemSprite.getSiliverIconSprite()
		iconName = GetLocalizeStringBy("key_1687")
		local quality = ItemSprite.getSilverQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	elseif(cellValues.type == "soul") then
		-- 将魂
		iconBg= ItemSprite.getSoulIconSprite()
		iconName = GetLocalizeStringBy("key_1616")
		local quality = ItemSprite.getSoulQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	elseif(cellValues.type == "gold") then
		-- 金币
		iconBg= ItemSprite.getGoldIconSprite()
		iconName = GetLocalizeStringBy("key_1491")
		local quality = ItemSprite.getGoldQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	elseif(cellValues.type == "item") then
		-- 物品
		iconBg =  ItemSprite.getItemSpriteById(tonumber(cellValues.tid),nil, nil, nil, -491,11112)
		local itemData = ItemUtil.getItemById(cellValues.tid)
        iconName = itemData.name
        nameColor = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
	elseif(cellValues.type == "hero") then
		-- 英雄
		require "db/DB_Heroes"
		-- iconBg = HeroPublicCC.getCMISHeadIconByHtid(cellValues.tid)
		iconBg = ItemSprite.getHeroIconItemByhtid(cellValues.tid,-491,11112)
		local heroData = DB_Heroes.getDataById(cellValues.tid)
		iconName = heroData.name
		nameColor = HeroPublicLua.getCCColorByStarLevel(heroData.star_lv)
	elseif(cellValues.type == "prestige") then
		-- 声望
		iconBg= ItemSprite.getPrestigeSprite()
		iconName = GetLocalizeStringBy("key_2231")
		local quality = ItemSprite.getPrestigeQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(cellValues.type == "jewel") then
		-- 魂玉
		iconBg= ItemSprite.getJewelSprite()
		iconName = GetLocalizeStringBy("key_1510")
		local quality = ItemSprite.getJewelQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(cellValues.type == "execution") then
		-- 体力
		iconBg= ItemSprite.getExecutionSprite()
		iconName = GetLocalizeStringBy("key_1032")
		local quality = ItemSprite.getExecutionQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(cellValues.type == "stamina") then
		-- 耐力
		iconBg= ItemSprite.getStaminaSprite()
		iconName = GetLocalizeStringBy("key_2021")
		local quality = ItemSprite.getStaminaQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	end

	-- 物品数量
	if( tonumber(cellValues.num) > 1 )then
		local numberLabel =  CCRenderLabel:create("" .. cellValues.num , g_sFontName,21,2,ccc3(0x00,0x00,0x00),type_stroke)
		numberLabel:setColor(ccc3(0x00,0xff,0x18))
		numberLabel:setAnchorPoint(ccp(0,0))
		local width = iconBg:getContentSize().width - numberLabel:getContentSize().width - 6
		numberLabel:setPosition(ccp(width,5))
		iconBg:addChild(numberLabel)
	end

	--- desc 物品名字
	local descLabel = CCRenderLabel:create("" .. iconName , g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
	descLabel:setColor(nameColor)
	descLabel:setAnchorPoint(ccp(0.5,0.5))
	descLabel:setPosition(ccp(iconBg:getContentSize().width*0.5 ,-iconBg:getContentSize().height*0.2))
	iconBg:addChild(descLabel)

	return iconBg
end

-- 整理掉落数据结构
-- 现在只掉落物品
function getGuildBattleDropItem( drop  )
	local items = {}
	if( not table.isEmpty(drop)) then
	 for k,v in  pairs(drop) do
			local item = {}
			item.tid  = k
			item.num = v
			item.type = "item"
			item.name = ItemUtil.getItemById(tonumber(item.tid)).name 
			table.insert(items, item)
		end
	end
	return items
end


