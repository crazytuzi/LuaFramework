-- FileName: AfterMineral.lua 
-- Author: Li Cong 
-- Date: 13-11-4 
-- Purpose: function description of module 资源矿


module("AfterMineral", package.seeall)

local mainLayer = nil
local menu = nil
local backAnimSprite = nil
local animSprite = nil
local winSize = nil
local bg_sprite = nil
-- 回调函数
local afterOKCallFun = nil

local _fightStr       =nil      -- added by zhz: 战斗串
local _ksTagTxt       = 101
local _battleInfo     = nil

-- touch事件处理
local function cardLayerTouch(eventType, x, y)
   
    return true
    
end

-- 创建挑战结算面板
-- appraisal:战斗评价
-- enemyUid:对方的uid
function createAfterMineralLayer( appraisal, enemyUid, CallFun ,fightStr, isNpc)
	-- 点击确定按钮传入回调
	afterOKCallFun = CallFun
    _fightStr= fightStr
    local amf3Obj = Base64.decodeWithZip( _fightStr)
    _battleInfo = amf3.decode(amf3Obj)

   	winSize = CCDirector:sharedDirector():getWinSize()
	mainLayer = CCLayerColor:create(ccc4(11,11,11,200))
	mainLayer:setTouchEnabled(true)
    mainLayer:registerScriptTouchHandler(cardLayerTouch,false,-600,true)

    -- 战斗胜负判断
    local isWin = nil
    if(	appraisal ~= "E" and appraisal ~= "F" )then
    	isWin = true
    	-- 创建胜利背景框
    	bg_sprite = BaseUI.createViewBg(CCSizeMake(520,470))
    	bg_sprite:setAnchorPoint(ccp(0.5,0.5))
    	bg_sprite:setPosition(ccp(winSize.width/2,winSize.height*0.484))
    	mainLayer:addChild(bg_sprite)
    else
    	isWin = false
    	-- 创建失败背景框
    	bg_sprite = BaseUI.createViewBg(CCSizeMake(520,738))
    	bg_sprite:setAnchorPoint(ccp(0.5,0.5))
    	bg_sprite:setPosition(ccp(winSize.width/2,winSize.height*0.42))
    	mainLayer:addChild(bg_sprite)
    end
    local vsInfo = createVsInfo()
    bg_sprite:addChild(vsInfo)
    vsInfo:setAnchorPoint(ccp(0.5, 1))
    vsInfo:setPosition(ccp(bg_sprite:getContentSize().width * 0.5, bg_sprite:getContentSize().height - 50))
	-- -- 创建获得奖励
	-- local line = CCSprite:create("images/common/line2.png")
	-- line:setAnchorPoint(ccp(0.5,0.5))
	-- line:setPosition(ccp(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height-50))
	-- bg_sprite:addChild(line)
	-- local font = CCRenderLabel:create( GetLocalizeStringBy("key_1809") , g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	-- font:setAnchorPoint(ccp(0.5,0.5))
	-- font:setColor(ccc3(0xff,0xe4,0x00))
	-- font:setPosition(ccp(line:getContentSize().width*0.5,line:getContentSize().height*0.5))
	-- line:addChild(font)
	-- -- 获得银币
	-- local bg1 = CCScale9Sprite:create("images/common/labelbg_white.png")
	-- bg1:setContentSize(CCSizeMake(384,40))
	-- bg1:setAnchorPoint(ccp(0.5,0.5))
	-- bg1:setPosition(ccp(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height-100))
	-- bg_sprite:addChild(bg1)
	-- local font1 = CCLabelTTF:create(GetLocalizeStringBy("key_2415"), g_sFontName, 24)
	-- font1:setAnchorPoint(ccp(0,0.5))
	-- font1:setColor(ccc3(0x78,0x25,0x00))
	-- font1:setPosition(ccp(75,bg1:getContentSize().height*0.5))
	-- bg1:addChild(font1)
	-- local icon1 = CCSprite:create("images/common/coin.png")
	-- icon1:setAnchorPoint(ccp(0,0.5))
	-- icon1:setPosition(ccp(222,bg1:getContentSize().height*0.5))
	-- bg1:addChild(icon1)
	-- -- 获得银币数量
	-- local coinData = silverData or 0
	-- local coin_data = CCLabelTTF:create( coinData, g_sFontName, 24)
	-- coin_data:setAnchorPoint(ccp(0,0.5))
	-- coin_data:setColor(ccc3(0x00,0x00,0x00))
	-- coin_data:setPosition(ccp(258,bg1:getContentSize().height*0.5))
	-- bg1:addChild(coin_data)
	-- -- 获得将魂
	-- local bg2 = CCScale9Sprite:create("images/common/labelbg_white.png")
	-- bg2:setContentSize(CCSizeMake(384,40))
	-- bg2:setAnchorPoint(ccp(0.5,0.5))
	-- bg2:setPosition(ccp(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height-150))
	-- bg_sprite:addChild(bg2)
	-- local font2 = CCLabelTTF:create(GetLocalizeStringBy("key_1228"), g_sFontName, 24)
	-- font2:setAnchorPoint(ccp(0,0.5))
	-- font2:setColor(ccc3(0x78,0x25,0x00))
	-- font2:setPosition(ccp(75,bg2:getContentSize().height*0.5))
	-- bg2:addChild(font2)
	-- local icon2 = CCSprite:create("images/common/icon_soul.png")
	-- icon2:setAnchorPoint(ccp(0,0.5))
	-- icon2:setPosition(ccp(222,bg2:getContentSize().height*0.5))
	-- bg2:addChild(icon2)
	-- -- 获得将魂数量
	-- local soulData = heroSoulData or 0
	-- local soul_data = CCLabelTTF:create( soulData, g_sFontName, 24)
	-- soul_data:setAnchorPoint(ccp(0,0.5))
	-- soul_data:setColor(ccc3(0x00,0x00,0x00))
	-- soul_data:setPosition(ccp(258,bg2:getContentSize().height*0.5))
	-- bg2:addChild(soul_data)

	-- 三个按钮
    menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-600)
    bg_sprite:addChild(menu)

    -- 对方阵容
    local userFormationItem = createButtonItem(GetLocalizeStringBy("key_3305"))
    userFormationItem:setAnchorPoint(ccp(0.5,0.5))
    userFormationItem:registerScriptTapHandler(userFormationItemFun)
    menu:addChild(userFormationItem,1,tonumber(enemyUid))
    if(isNpc)then
        userFormationItem:setEnabled(false)
        local label = tolua.cast(userFormationItem:getChildByTag(_ksTagTxt), "CCRenderLabel")
        label:setColor(ccc3(0xf1,0xf1,0xf1))
    end

    -- 发送战报
    local sendMsgItem= createButtonItem(GetLocalizeStringBy("key_4000"))
    sendMsgItem:setAnchorPoint(ccp(0.5,0.5))
    sendMsgItem:registerScriptTapHandler(sendMegFun)
    menu:addChild(sendMsgItem)

    -- 重播
    local replayItem = createButtonItem(GetLocalizeStringBy("key_2184"))
    replayItem:setAnchorPoint(ccp(0.5,0.5))
    replayItem:registerScriptTapHandler(replayItemFun)
    menu:addChild(replayItem)
    -- 确定
    local okItem = createButtonItem(GetLocalizeStringBy("key_1985"))
    okItem:setAnchorPoint(ccp(0.5,0.5))
    okItem:registerScriptTapHandler(okItemFun)
    menu:addChild(okItem)

    --播放胜负动画
    animSprite = nil
    if(isWin) then
    	-- 对方阵容位置
    	userFormationItem:setPosition(ccp(bg_sprite:getContentSize().width*0.3,204))
        -- 发送战报
        sendMsgItem:setPosition(bg_sprite:getContentSize().width*0.7,204)
    	-- 重播位置
    	replayItem:setPosition(ccp(bg_sprite:getContentSize().width*0.3,117))
    	-- 确定位置
    	okItem:setPosition(ccp(bg_sprite:getContentSize().width*0.7,117))

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
    
        bg_sprite:registerScriptHandler(function ( eventType,node )
            if(eventType == "enter") then
               if(file_exists("audio/effect/zhandoushengli.mp3")) then
                   AudioUtil.playEffect("audio/effect/zhandoushengli.mp3")
               end
            end
            if(eventType == "exit") then
            end
        end)
    else
    	-- 对方阵容位置
    	userFormationItem:setPosition(ccp(bg_sprite:getContentSize().width*0.3,130))
        -- 发送战报的位置 added by zhz
        sendMsgItem:setPosition(bg_sprite:getContentSize().width*0.7,130)

    	-- 重播位置
    	replayItem:setPosition(ccp(bg_sprite:getContentSize().width*0.3,57))
    	-- 确定位置
    	okItem:setPosition(ccp(bg_sprite:getContentSize().width*0.7,57))
    	-- 创建中间ui
    	local middle_bg = BaseUI.createContentBg(CCSizeMake(463,374))
    	middle_bg:setAnchorPoint(ccp(0.5,1))
    	middle_bg:setPosition(ccp(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height-190))
    	bg_sprite:addChild(middle_bg)
    	local str1 = GetLocalizeStringBy("key_3053")
    	local text1 = CCRenderLabel:create( str1 , g_sFontPangWa, 26, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    text1:setColor(ccc3(0xff, 0xff, 0xff))
	    text1:setPosition(ccp(45,middle_bg:getContentSize().height-10))
	   	middle_bg:addChild(text1)
	   	local str2 = GetLocalizeStringBy("key_1175")
    	local text2 = CCRenderLabel:create( str2 , g_sFontPangWa, 26, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    text2:setColor(ccc3(0xff, 0xff, 0xff))
	    text2:setPosition(ccp(10,middle_bg:getContentSize().height-50))
	   	middle_bg:addChild(text2)
	   	local str3 = GetLocalizeStringBy("key_2265")
    	local text3 = CCRenderLabel:create( str3 , g_sFontPangWa, 26, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    text3:setColor(ccc3(0xff, 0xff, 0xff))
	    text3:setPosition(ccp(10,middle_bg:getContentSize().height-90))
	   	middle_bg:addChild(text3)

	   	-- 四个按钮
	   	local middle_menu = CCMenu:create()
	    middle_menu:setPosition(ccp(0,0))
	    middle_menu:setTouchPriority(-600)
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

        backAnimSprite = nil
        animSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushibai"), -1,CCString:create(""))
    
        bg_sprite:registerScriptHandler(function ( eventType,node )
            if(eventType == "enter") then
               if(file_exists("audio/effect/zhandoushibai.mp3")) then
                    AudioUtil.playEffect("audio/effect/zhandoushibai.mp3")
                end
            end
            if(eventType == "exit") then
            end
        end)
    end
    animSprite:retain()
    animSprite:setAnchorPoint(ccp(0.5, 0.5));
    animSprite:setPosition(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height-20)
    -- require "script/ui/main/MainScene"
    -- animSprite:setScale(MainScene.elementScale)
    bg_sprite:addChild(animSprite)
    animSprite:release()
    
    delegate = BTAnimationEventDelegate:create()
    --delegate:retain()
    delegate:registerLayerEndedHandler(animationEnd)
    delegate:registerLayerChangedHandler(animationFrameChanged)
    animSprite:setDelegate(delegate)

    -- 适配
    setAdaptNode(bg_sprite)

    return mainLayer
end

function createVsInfo( ... )
    local fullRect = CCRectMake(0, 0, 469, 89)
    local insetRect = CCRectMake(198,41,70, 25)
    local vs_bg = CCScale9Sprite:create("images/arena/vs_bg.png", fullRect, insetRect)
    vs_bg:setContentSize(CCSizeMake(469, 110))
    -- 攻方名字
    local myNameStr = _battleInfo.team1.name
    local name_color,stroke_color = getHeroNameColor(2)
    local myName_font = CCRenderLabel:create( myNameStr, g_sFontPangWa, 25, 1, stroke_color, type_stroke)
    myName_font:setColor(name_color)
    myName_font:setAnchorPoint(ccp(0.5,0.5))
    myName_font:setPosition(ccp(80, vs_bg:getContentSize().height - 20))
    vs_bg:addChild(myName_font)

    -- 守方名字 
    local enemyNameStr = _battleInfo.team2.name
    local name_color,stroke_color = getHeroNameColor( 1 )
    local enemyName_font = CCRenderLabel:create( enemyNameStr, g_sFontPangWa, 25, 1, stroke_color, type_stroke)
    enemyName_font:setColor(name_color)
    enemyName_font:setAnchorPoint(ccp(0.5,0.5))
    enemyName_font:setPosition(ccp(vs_bg:getContentSize().width - 80, vs_bg:getContentSize().height - 20))
    vs_bg:addChild(enemyName_font)
    enemyName_font:setScale(enemyName_font:getScaleX())

    local vs_sprite = CCSprite:create("images/arena/vs.png")
    vs_sprite:setAnchorPoint(ccp(0.5,0.5))
    vs_sprite:setPosition(ccpsprite(0.5, 0.5, vs_bg))
    vs_bg:addChild(vs_sprite)

    -- 攻方战力
    local zhan = CCSprite:create("images/arena/zhan.png")
    zhan:setAnchorPoint(ccp(0,0))
    zhan:setPosition(ccp(15,8))
    zhan:setPosition(ccp(15,34))
    vs_bg:addChild(zhan)
    local zhan_data = CCRenderLabel:create(_battleInfo.team1.fightForce , g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    zhan_data:setColor(ccc3(0xff,0xf6,0x00))
    --兼容泰文版
    --added by Zhang Zihang
    if(Platform.getPlatformFlag() == "ios_thailand" or Platform.getPlatformFlag() == "Android_taiguo" )then
        zhan_data:setPosition(ccp(74,zhan_data:getContentSize().height + 10))
        zhan_data:setPosition(ccp(74,zhan_data:getContentSize().height + 38))
    else
        zhan_data:setPosition(ccp(60,zhan_data:getContentSize().height + 10))
        zhan_data:setPosition(ccp(60,zhan_data:getContentSize().height + 38))
    end
    vs_bg:addChild(zhan_data)

     -- 敌方战力
    local zhan = CCSprite:create("images/arena/zhan.png")
    zhan:setAnchorPoint(ccp(0,0))
    zhan:setPosition(ccp(308,8))
    zhan:setPosition(ccp(308,34))
    vs_bg:addChild(zhan)
    local zhan_data = CCRenderLabel:create(_battleInfo.team2.fightForce, g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    zhan_data:setColor(ccc3(0xff,0xf6,0x00))
    --兼容泰文版
    --added by Zhang Zihang
    if(Platform.getPlatformFlag() == "ios_thailand" or Platform.getPlatformFlag() == "Android_taiguo" )then
        zhan_data:setPosition(ccp(362,zhan_data:getContentSize().height + 10))
        zhan_data:setPosition(ccp(362,zhan_data:getContentSize().height + 38))
    else
        zhan_data:setPosition(ccp(348,zhan_data:getContentSize().height + 10))
        zhan_data:setPosition(ccp(348,zhan_data:getContentSize().height + 38))
    end
    vs_bg:addChild(zhan_data)

    -- 攻方伤害
    local team1damageIcon = CCSprite:create("images/battle/report/damage.png")
    team1damageIcon:setAnchorPoint(ccp(0,0.5))
    team1damageIcon:setPosition(ccp(10, 20))
    vs_bg:addChild(team1damageIcon)
    local team1DamageLabel = CCRenderLabel:create(math.abs(tonumber(_battleInfo.team2.totalDamage) or 0) , g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    team1DamageLabel:setColor(ccc3(45,253,46))
    team1DamageLabel:setAnchorPoint(ccp(0, 0.5))
    team1DamageLabel:setPosition(team1damageIcon:getContentSize().width + 10, team1damageIcon:getContentSize().height/2)
    team1damageIcon:addChild(team1DamageLabel)

    -- 敌方伤害
    local team2damageIcon = CCSprite:create("images/battle/report/damage.png")
    team2damageIcon:setAnchorPoint(ccp(0,0.5))
    team2damageIcon:setPosition(ccp(vs_bg:getContentSize().width/2+60, 20))
    vs_bg:addChild(team2damageIcon)
    local team2DamageLabel = CCRenderLabel:create(math.abs(tonumber(_battleInfo.team1.totalDamage) or 0) , g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    team2DamageLabel:setColor(ccc3(45,253,46))
    team2DamageLabel:setAnchorPoint(ccp(0, 0.5))
    team2DamageLabel:setPosition(team2damageIcon:getContentSize().width + 10, team1damageIcon:getContentSize().height/2)
    team2damageIcon:addChild(team2DamageLabel)

    if _battleInfo.team2.totalDamage == nil then
        team1damageIcon:setVisible(false)
        team1DamageLabel:setVisible(false)
        team2damageIcon:setVisible(false)
        team2DamageLabel:setVisible(false)
    end

    return vs_bg
end

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
function createButtonItem( str )
	local normalSprite  =CCScale9Sprite:create("images/common/btn/btn_green_n.png")
    local selectSprite  =CCScale9Sprite:create("images/common/btn/btn_green_h.png")
    local disableSprite= CCScale9Sprite:create("images/common/btn/btn_hui.png")
    local item = CCMenuItemSprite:create(normalSprite,selectSprite, disableSprite)
    -- 字体
	local item_font = CCRenderLabel:create( str , g_sFontPangWa, 35, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    item_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
    item_font:setAnchorPoint(ccp(0.5,0.5))
    item_font:setPosition(ccp(item:getContentSize().width*0.5,item:getContentSize().height*0.5))
   	item:addChild(item_font,1, _ksTagTxt)
   	return item
end


-- 对方阵容回调
function userFormationItemFun( tag, item_obj )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	print(GetLocalizeStringBy("key_2710") .. tag )
    -- local str1 = GetLocalizeStringBy("key_3038")
    -- require "script/ui/tip/AnimationTip"
    -- AnimationTip.showTip(str1)
    require "script/ui/active/RivalInfoLayer"
    RivalInfoLayer.createLayer(tonumber(tag))
end

-- 重播回调
function replayItemFun( tag, item_obj )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	print(GetLocalizeStringBy("key_2460") .. tag )
    require "script/battle/BattleLayer"
    BattleLayer.replay()
end

-- 确定回调
function okItemFun( tag, item_obj )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	print(GetLocalizeStringBy("key_2060") .. tag )
	require "script/battle/BattleLayer"
    BattleLayer.closeLayer()

    -- 点确定后 调用回调
    if(afterOKCallFun ~= nil)then
    	afterOKCallFun()
    end
end

-- 发送战报 added by zhz
function sendMegFun(tag, item )
   -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    require "script/ui.chat/ChatUtil"
    local function sendClickCallback( )
        item:setEnabled(false)
        local label = tolua.cast(item:getChildByTag(_ksTagTxt), "CCRenderLabel")
        label:setColor(ccc3(0xf1,0xf1,0xf1))
        AnimationTip.showTip( GetLocalizeStringBy("key_4001") )
    end

    if(_fightStr == nil) then
        AnimationTip.showTip( GetLocalizeStringBy("key_4002"))
        return
    end
    local amf3_obj = Base64.decodeWithZip( _fightStr)
    local lua_obj = amf3.decode(amf3_obj)
    ChatUtil.sendChatinfo(lua_obj, ChatCache.ChatInfoType.battle_report_player, ChatCache.ChannelType.world, sendClickCallback)
    
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
    require "script/battle/BattleLayer"
    BattleLayer.closeLayer()

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
    require "script/battle/BattleLayer"
    BattleLayer.closeLayer()

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
	require "script/battle/BattleLayer"
    BattleLayer.closeLayer()
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
	require "script/battle/BattleLayer"
    BattleLayer.closeLayer()

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
    require "script/battle/BattleLayer"
    BattleLayer.closeLayer()

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
    require "script/battle/BattleLayer"
    BattleLayer.closeLayer()

    if not DataCache.getSwitchNodeState(ksSwitchBattleSoul) then
        return
    end
    require "script/ui/huntSoul/HuntSoulLayer"
    local layer = HuntSoulLayer.createHuntSoulLayer()
    MainScene.changeLayer(layer, "huntSoulLayer")
end


