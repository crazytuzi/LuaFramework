-- FileName: RestTimeLayer.lua 
-- Author: Li Cong 
-- Date: 13-11-15 
-- Purpose: function description of module 


require "script/utils/TimeUtil"
module("RestTimeLayer", package.seeall)

_bgLayer                       = nil   -- 休息时间比武层
local _staminaLabel 			= nil   -- 耐力
local _contestNumLabel          = nil   -- 比武次数 
local _rankingLabel		 		= nil	-- 排名
local _scoreLabel 				= nil	-- 积分
local _layerSize 				= nil   -- 比武层大小
local downTime_font             = nil   -- 倒计时文字

function init( ... )
    _bgLayer                    = nil   -- 休息时间比武层
	_staminaLabel 				= nil   -- 耐力
	_rankingLabel		 		= nil	-- 排名
	_scoreLabel 				= nil	-- 积分
 	_layerSize 					= nil   -- 比武层大小
    downTime_font               = nil   -- 倒计时文字
   _contestNumLabel              = nil   -- 比武次数 
end

-- 购买次数回调
local function addNumMenuAction( tag, itemBtn )
    local haveBuyNum = MatchData.getBuyNum()
    local maxBuyNum,b  = MatchData.getCanBuyMaxNum()
    if(haveBuyNum >= maxBuyNum)then
        require "script/ui/tip/AnimationTip"
        local str = GetLocalizeStringBy("lic_1078")
        AnimationTip.showTip(str)
        return
    end
    require "script/ui/match/BuyMatchNum"
    BuyMatchNum.showBatchUseLayer("RestTimeLayer")
end

-- 初始化比武Layer
function initRestTimeLayer( ... )
	-- 比武层layer大小
	_layerSize = _bgLayer:getContentSize()
	-- 耐力
	local stamina_sprite = CCSprite:create("images/match/stamina.png")
	stamina_sprite:setAnchorPoint(ccp(0,1))
	stamina_sprite:setPosition(ccp(20*g_fScaleX,_layerSize.height - 10*g_fScaleX))
	_bgLayer:addChild(stamina_sprite)
    stamina_sprite:setScale(MainScene.elementScale)
	-- 耐力数值
    _staminaLabel = CCRenderLabel:create( UserModel.getStaminaNumber() .. "/" .. UserModel.getMaxStaminaNumber(), g_sFontPangWa, 24, 1, ccc3(0x00,0x00,0x00), type_stroke)
    _staminaLabel:setColor(ccc3(0xff,0x17,0x0c))
    _staminaLabel:setPosition(ccp(100*g_fScaleX,_layerSize.height - 10*g_fScaleX))
    _bgLayer:addChild(_staminaLabel)
    _staminaLabel:setScale(MainScene.elementScale)
    -- 注册耐力更新函数
    require "script/ui/main/MainScene"
    MainScene.registerStaminaNumberChangeCallback( upDateStamina )

    -- 次数 取消次数显示 by 2013.12.2  2014.05.22再次启用
    local contestNum_sprite = CCSprite:create("images/match/contest_num.png")
    contestNum_sprite:setAnchorPoint(ccp(0,1))
    contestNum_sprite:setPosition(ccp(20*g_fScaleX,_layerSize.height - 50*g_fScaleX))
    _bgLayer:addChild(contestNum_sprite)
    contestNum_sprite:setScale(MainScene.elementScale)
    -- 次数数值
    -- 剩余次数
    local numData = MatchData.getContestNum()
    -- 总次数
    local allNum = MatchData.getAllContestNum()
    _contestNumLabel = CCRenderLabel:create( numData .. "/" .. allNum, g_sFontPangWa, 24, 1, ccc3(0x00,0x00,0x00), type_stroke)
    _contestNumLabel:setColor(ccc3(0xff,0x17,0x0c))
    _contestNumLabel:setPosition(ccp(100*g_fScaleX,_layerSize.height - 50*g_fScaleX))
    _bgLayer:addChild(_contestNumLabel,1,11111)
    _contestNumLabel:setScale(MainScene.elementScale)

    -- 按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    _bgLayer:addChild(menu)

    -- 购买次数button
    -- local addNumBtn = CCMenuItemImage:create("images/common/btn/btn_plus_n.png","images/common/btn/btn_plus_h.png")
    -- addNumBtn:setAnchorPoint(ccp(0,0.5))
    -- addNumBtn:setPosition(ccp(180*g_fScaleX, _layerSize.height-65*g_fScaleX))
    -- menu:addChild(addNumBtn)
    -- addNumBtn:registerScriptTapHandler(addNumMenuAction)
    -- addNumBtn:setScale(MainScene.elementScale)

    -- 排名
	local ranking_sprite = CCSprite:create("images/match/ranking.png")
	ranking_sprite:setAnchorPoint(ccp(0,1))
	ranking_sprite:setPosition(ccp(20*g_fScaleX,_layerSize.height - 90*g_fScaleX))
	_bgLayer:addChild(ranking_sprite)
    ranking_sprite:setScale(MainScene.elementScale)
	-- 排名数值
	local ranking_data = MatchData.getMyRank()
    _rankingLabel = CCRenderLabel:create( ranking_data, g_sFontPangWa, 24, 1, ccc3(0x00,0x00,0x00), type_stroke)
    _rankingLabel:setColor(ccc3(0x00,0xe4,0xff))
    _rankingLabel:setPosition(ccp(100*g_fScaleX,_layerSize.height - 90*g_fScaleX))
    _bgLayer:addChild(_rankingLabel)
    _rankingLabel:setScale(MainScene.elementScale)

    -- 积分
	local score_sprite = CCSprite:create("images/match/score.png")
	score_sprite:setAnchorPoint(ccp(0,1))
	score_sprite:setPosition(ccp(20*g_fScaleX,_layerSize.height - 130*g_fScaleX))
	_bgLayer:addChild(score_sprite)
    score_sprite:setScale(MainScene.elementScale)
	-- 积分数值
	local score_data = MatchData.getMyScore()
    _scoreLabel = CCRenderLabel:create( score_data, g_sFontPangWa, 24, 1, ccc3(0x00,0x00,0x00), type_stroke)
    _scoreLabel:setColor(ccc3(0x70,0xff,0x18))
    _scoreLabel:setPosition(ccp(100*g_fScaleX,_layerSize.height - 130*g_fScaleX))
    _bgLayer:addChild(_scoreLabel)
    _scoreLabel:setScale(MainScene.elementScale)

    -- 奖励预览按钮

    local rewardMenuItem = CCMenuItemImage:create("images/match/reward_n.png","images/match/reward_h.png")
    rewardMenuItem:setAnchorPoint(ccp(1,1))
    rewardMenuItem:setPosition(ccp(_layerSize.width-100*g_fScaleX, _layerSize.height))
    menu:addChild(rewardMenuItem)
    rewardMenuItem:registerScriptTapHandler(fnRewardMenuAction)
    rewardMenuItem:setScale(MainScene.elementScale)

    -- 排行榜按钮
    local rankingMenuItem = CCMenuItemImage:create("images/match/paihang_n.png","images/match/paihang_h.png")
    rankingMenuItem:setAnchorPoint(ccp(1,1))
    rankingMenuItem:setPosition(ccp(_layerSize.width-10*g_fScaleX,_layerSize.height))
    menu:addChild(rankingMenuItem)
    rankingMenuItem:registerScriptTapHandler(fnRankingMenuItemAction)
    rankingMenuItem:setScale(MainScene.elementScale)

    -- 正在发奖中
    local state = MatchData.getRewardState()
    if(state == "start" or MatchData.m_rewardState == "start")then
        if( _bgLayer:getChildByTag(10001) ~= nil )then
            _bgLayer:removeChildByTag(10001,true)
        end
        if( _bgLayer:getChildByTag(10002) ~= nil )then
            _bgLayer:removeChildByTag(10002,true)
        end
	    local str = GetLocalizeStringBy("key_2619")
	    local below_font = CCRenderLabel:create( str, g_sFontPangWa, 30, 1, ccc3(0x00,0x00,0x00), type_stroke)
	    below_font:setAnchorPoint(ccp(0.5,0))
	    below_font:setColor(ccc3(0xff,0xe4,0x00))
	    below_font:setPosition(ccp(_layerSize.width*0.5,38*g_fScaleX))
	    _bgLayer:addChild(below_font,1,10001)
	    below_font:setScale(MainScene.elementScale)
	end
    -- 发奖结束
	if(state == "end" or MatchData.m_rewardState == "end")then
        if( _bgLayer:getChildByTag(10001) ~= nil )then
            _bgLayer:removeChildByTag(10001,true)
        end
        if( _bgLayer:getChildByTag(10002) ~= nil )then
            _bgLayer:removeChildByTag(10002,true)
        end
	    local str = GetLocalizeStringBy("key_1449")
	    local below_font = CCRenderLabel:create( str, g_sFontPangWa, 30, 1, ccc3(0x00,0x00,0x00), type_stroke)
	    below_font:setAnchorPoint(ccp(0.5,0))
	    below_font:setColor(ccc3(0xff,0xe4,0x00))
	    below_font:setPosition(ccp(_layerSize.width*0.5,58*g_fScaleX))
	    _bgLayer:addChild(below_font,1,10001)
	    below_font:setScale(MainScene.elementScale)
        local str2 = GetLocalizeStringBy("key_2891")
        local below_font2 = CCRenderLabel:create( str2, g_sFontPangWa, 30, 1, ccc3(0x00,0x00,0x00), type_stroke)
        below_font2:setAnchorPoint(ccp(0.5,0))
        below_font2:setColor(ccc3(0xff,0xe4,0x00))
        below_font2:setPosition(ccp(_layerSize.width*0.5,18*g_fScaleX))
        _bgLayer:addChild(below_font2,1,10002)
        below_font2:setScale(MainScene.elementScale)
	end

    -- 创建玩家to3列表
    createMatchUserList( MatchData.m_top3Data )

end


-- 创建比武玩家
function createMatchUserList( userInfo )
	local function fnSortFun( a, b )
		return tonumber(a.rank) < tonumber(b.rank)
	end 
	-- 排序
	table.sort( userInfo, fnSortFun )
	print(GetLocalizeStringBy("key_2506"))
	print_t(userInfo)
	-- 创建
	local i = 0
	for k,v in pairs(userInfo) do
		-- 名次图标
	    local des_sprite = nil
	    local font_color = nil
	    local fileName = nil
	    local card_bg = nil
	    if( tonumber(v.rank) == 1 )then
	        des_sprite = CCSprite:create("images/match/one.png")
	        -- 橙色
	        font_color = ccc3(0xf9,0x90,0x08)
	        fileName = "huang"
	        card_bg = "images/match/jin_bg.png"
	    elseif( tonumber(v.rank) == 2 )then
	        des_sprite = CCSprite:create("images/match/two.png")
	        -- 紫色
	        font_color = ccc3(0xf9,0x59,0xff)
	        fileName = "zi"
	        card_bg = "images/match/yin_bg.png"
	    elseif( tonumber(v.rank) == 3 )then
	        des_sprite = CCSprite:create("images/match/three.png")
	        -- 蓝色
	        font_color = ccc3(0x00,0xe4,0xff)
	        fileName = "lan"
	        card_bg = "images/match/tong_bg.png"
	    end
		require "script/battle/BattleCardUtil"

        if(v.squad[1].dress)then
            if( not table.isEmpty(v.squad[1].dress) and (v.squad[1].dress["1"])~= nil and tonumber(v.squad[1].dress["1"]) > 0 )then
                dressId = v.squad[1].dress["1"]
                genderId = HeroModel.getSex(v.squad[1].htid)
            end
        end
        local sprite1 = BattleCardUtil.getFormationPlayerCard(111111111,nil,v.squad[1].htid,dressId)
        local sprite2 = BattleCardUtil.getFormationPlayerCard(111111111,nil,v.squad[1].htid,dressId)

	    local icon = createMatchUserInfo(des_sprite, font_color, fileName,sprite1,sprite2, v.uname, v.level, v.uid, card_bg, v.guild_name, v.title)
	    icon:setAnchorPoint(ccp(0.5,0.5))
	    i = i + 1
	    icon:setPosition(getPos( i ))
	    _bgLayer:addChild(icon,1,100+i)
        -- 适配
        icon:setScale(MainScene.elementScale)
	end
end

function getPos( i )
	local pos = nil
	if( i == 1 )then
		pos = ccp(_layerSize.width*0.5,_layerSize.height*0.5)
	elseif( i == 2 )then
		pos = ccp(_layerSize.width*0.2,_layerSize.height*0.35)
	elseif( i == 3 )then
		pos = ccp(_layerSize.width*0.8,_layerSize.height*0.35)
	end
	return pos
end

-- 奖励预览
function fnRewardMenuAction( tag, itemBtn )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    require "script/ui/match/ShowContestReward"
	
    local layer =ShowContestReward.createLayer()
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    runningScene:addChild(layer,999)
end

-- 排行榜
function fnRankingMenuItemAction( tag, itemBtn )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- body
     -- 满足条件后逻辑处理
    local function createNextFun( ... )
        require "script/ui/match/MatchRankingsLayer"
        local rankingsLayer = MatchRankingsLayer.createMatchRankingsLayer()
        local runingScene = CCDirector:sharedDirector():getRunningScene()
        runingScene:addChild(rankingsLayer,18000)
    end
    MatchService.getRankList(createNextFun)
end

-- 卡牌按钮回调 查看阵容
function fnCardItemCallFun( tag, itemBtn )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- print("tag .. " .. tag)
    require "script/ui/active/RivalInfoLayer"
    RivalInfoLayer.createLayer(tonumber(tag))
end

-- 创建比武玩家信息
-- m_des:获得积分描述
-- m_color:根据积分给出颜色
-- fileName:光束
-- cradIcon:卡牌
-- m_userName:玩家名字
-- m_lv:玩家等级
-- m_uid:玩家uid
function createMatchUserInfo( m_des, m_color, fileName, cradIcon_n, cradIcon_h, m_userName, m_lv, m_uid, card_bg, guildName, pTitleId)
	local parent = CCNode:create()
	parent:setContentSize(CCSizeMake(168,318))
	-- 数字
	m_des:setAnchorPoint(ccp(0.5,0.5))
	m_des:setPosition(ccp(parent:getContentSize().width*0.5,parent:getContentSize().height-30))
	parent:addChild(m_des,3)
    -- 名
    local ming = CCSprite:create("images/match/ming.png")
    ming:setAnchorPoint(ccp(0,1))
    ming:setPosition(ccp(parent:getContentSize().width*0.5+25,parent:getContentSize().height-20))
    parent:addChild(ming,3)
    -- 光束
    local light = CCSprite:create("images/match/" .. fileName .. ".png")
    light:setAnchorPoint(ccp(0.5,1))
    light:setPosition(ccp(parent:getContentSize().width*0.5,parent:getContentSize().height-30))
    parent:addChild(light,1)
    -- 玩家卡牌按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    parent:addChild(menu,2)
    local normalSprite = CCSprite:create( card_bg )
    cradIcon_n:setAnchorPoint(ccp(0.5,0))
    cradIcon_n:setPosition(ccp(normalSprite:getContentSize().width*0.5,37))
    normalSprite:addChild(cradIcon_n)
    local selectSprite =  CCSprite:create( card_bg )
    cradIcon_h:setAnchorPoint(ccp(0.5,0))
    cradIcon_h:setPosition(ccp(selectSprite:getContentSize().width*0.5,37))
    selectSprite:addChild(cradIcon_h)
    selectSprite:setScale(0.8)
    local item = CCMenuItemSprite:create(normalSprite,selectSprite)
    item:setAnchorPoint(ccp(0.5,1))
    item:setPosition(ccp(parent:getContentSize().width*0.5,parent:getContentSize().height-95))
    menu:addChild(item,1,tonumber(m_uid))
    item:registerScriptTapHandler(fnCardItemCallFun)

    normalSprite:setAnchorPoint(ccp(0.5, 0.5))
    selectSprite:setAnchorPoint(ccp(0.5, 0.5))
    normalSprite:setPosition(ccpsprite(0.5, 0.5, item))
    selectSprite:setPosition(ccpsprite(0.5, 0.5, item))

    -- 玩家名字 和 等级
    local userName = CCRenderLabel:create( m_userName, g_sFontPangWa, 22, 1, ccc3(0x00,0x00,0x00), type_stroke)
    userName:setAnchorPoint(ccp(0.5,1))
    userName:setColor(m_color)
    parent:addChild(userName,2)
    local lvFont = CCRenderLabel:create( "Lv." .. m_lv, g_sFontPangWa, 22, 1, ccc3(0x00,0x00,0x00), type_stroke)
    lvFont:setAnchorPoint(ccp(0.5,1))
    -- lvFont:setColor(ccc3(0xff,0xf6,0x00))
    lvFont:setColor(m_color)
    parent:addChild(lvFont,2)
    -- 合服 显示服务器名字 调整坐标
    lvFont:setPosition(ccp(parent:getContentSize().width*0.5,50))
    userName:setPosition(ccp(parent:getContentSize().width*0.5,25))
    -- -- 居中计算
    -- local xWidth = userName:getContentSize().width + lvFont:getContentSize().width + 10
    -- local posX = (parent:getContentSize().width-xWidth)*0.5
    -- userName:setPosition(ccp(posX,50))
    -- lvFont:setPosition(ccp(userName:getPositionX()+userName:getContentSize().width+10,50))
    -- 玩家军团
    if(guildName)then
        -- 军团名字
        local guildNameStr = guildName or " "
        local guildNameFont = CCRenderLabel:create( "[" .. guildNameStr .. "]", g_sFontPangWa, 22, 1, ccc3(0x00,0x00,0x00), type_stroke)
        guildNameFont:setAnchorPoint(ccp(0.5,1))
        guildNameFont:setColor(ccc3(0xff,0xff,0xff))
        guildNameFont:setPosition(ccp(parent:getContentSize().width*0.5,0))
        parent:addChild(guildNameFont,2)
    end

    -- 添加称号
    if( pTitleId ~= nil and tonumber(pTitleId) > 0 )then
        require "script/ui/title/TitleUtil"
        local titleSprite = TitleUtil.createTitleNormalSpriteById(pTitleId)
        titleSprite:setAnchorPoint(ccp(0.5, 0.5))
        titleSprite:setPosition(ccp(parent:getContentSize().width*0.5, parent:getContentSize().height*0.75))
        parent:addChild(titleSprite,2)
    end

	return parent
end


-- 创建比武层
function createRestTimeLayer( layerSize )
	init()
	_bgLayer = CCLayer:create()
    _bgLayer:registerScriptHandler(function ( eventType,node )
        if(eventType == "enter") then
            
        end
        if(eventType == "exit") then
            init()
        end
    end)
	_bgLayer:setContentSize(layerSize)
	initRestTimeLayer()

	return _bgLayer
end



-- 刷新耐力显示UI
upDateStamina = function()
    if( _staminaLabel ~= nil)then
        _staminaLabel:setString(UserModel.getStaminaNumber() .. "/" .. UserModel.getMaxStaminaNumber())
    end
end


-- 刷新次数
function refreshMatchNum( ... )
    -- 更新剩余次数
    if(_contestNumLabel ~= nil)then
        -- 移除原来的
        _contestNumLabel:removeFromParentAndCleanup(true)
        _contestNumLabel = nil
    end
    -- 剩余次数
    local numData = MatchData.getContestNum()
    -- 总次数
    local allNum = MatchData.getAllContestNum()
    _contestNumLabel = CCRenderLabel:create( numData .. "/" .. allNum, g_sFontPangWa, 24, 1, ccc3(0x00,0x00,0x00), type_stroke)
    _contestNumLabel:setColor(ccc3(0xff,0x17,0x0c))
    _contestNumLabel:setPosition(ccp(100*g_fScaleX,_layerSize.height - 50*g_fScaleX))
    _bgLayer:addChild(_contestNumLabel,1,11111)
    _contestNumLabel:setScale(MainScene.elementScale)
end













































