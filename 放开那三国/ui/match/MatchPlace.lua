-- FileName: MatchPlace.lua 
-- Author: Li Cong 
-- Date: 13-11-7 
-- Purpose: function description of module 

require "script/utils/TimeUtil"
module("MatchPlace", package.seeall)

local _bgLayer                  = nil   -- 比武层
local _staminaLabel 			= nil   -- 耐力
local _contestNumLabel          = nil   -- 比武次数 
_rankingLabel		 		    = nil	-- 排名
_scoreLabel 				    = nil	-- 积分
local _layerSize 				= nil   -- 比武层大小
local downTime_font             = nil   -- 倒计时文字

function init( ... )
    _bgLayer                    = nil   -- 比武层
	_staminaLabel 				= nil   -- 耐力
	_rankingLabel		 		= nil	-- 排名
	_scoreLabel 				= nil	-- 积分
 	_layerSize 					= nil   -- 比武层大小
    downTime_font               = nil   -- 倒计时文字
    _contestNumLabel            = nil   -- 比武次数 
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
    BuyMatchNum.showBatchUseLayer("MatchPlace")
end

-- 初始化比武Layer
function initMatchPlaceLayer( ... )
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
    _bgLayer:addChild(_staminaLabel,1,11111)
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
    local addNumBtn = CCMenuItemImage:create("images/common/btn/btn_plus_h.png","images/common/btn/btn_plus_n.png")
    addNumBtn:setAnchorPoint(ccp(0,0.5))
    addNumBtn:setPosition(ccp(180*g_fScaleX, _layerSize.height-65*g_fScaleX))
    menu:addChild(addNumBtn)
    addNumBtn:registerScriptTapHandler(addNumMenuAction)
    addNumBtn:setScale(MainScene.elementScale)

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
    _bgLayer:addChild(_rankingLabel,1,11112)
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
    _bgLayer:addChild(_scoreLabel,1,11113)
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

 
    -- 刷新对手按钮
    local normalSprite  = CCScale9Sprite:create("images/common/btn/btn_purple2_n.png")
    normalSprite:setContentSize(CCSizeMake(200,64))
    local selectSprite  = CCScale9Sprite:create("images/common/btn/btn_purple2_h.png")
    selectSprite:setContentSize(CCSizeMake(200,64))
    local disabledSprite = CCScale9Sprite:create("images/common/btn/btn_purple2_n.png")
    disabledSprite:setContentSize(CCSizeMake(200,64))
    local refreshMenuItem = CCMenuItemSprite:create(normalSprite,selectSprite,disabledSprite)
    refreshMenuItem:setAnchorPoint(ccp(0.5,0))
    refreshMenuItem:setPosition(ccp(_layerSize.width*0.5,40*g_fScaleX))
    menu:addChild(refreshMenuItem)
    local  refreshMenuItem_font = CCRenderLabel:create( GetLocalizeStringBy("key_2366"), g_sFontPangWa, 35, 1, ccc3(0x00,0x00,0x00), type_stroke)
    refreshMenuItem_font:setAnchorPoint(ccp(0.5,0.5))
    refreshMenuItem_font:setColor(ccc3(0xfe,0xdb,0x1c))
    refreshMenuItem_font:setPosition(ccp(refreshMenuItem:getContentSize().width*0.5,refreshMenuItem:getContentSize().height*0.5+2))
    refreshMenuItem:addChild(refreshMenuItem_font)
    refreshMenuItem:registerScriptTapHandler(fnRefreshMenuItemAction)
    refreshMenuItem:setScale(MainScene.elementScale)

    -- 下次刷新
    local nextRefresh_font = CCRenderLabel:create( GetLocalizeStringBy("key_2361"), g_sFontPangWa, 20, 1, ccc3(0x00,0x00,0x00), type_stroke)
    nextRefresh_font:setAnchorPoint(ccp(1,0))
    nextRefresh_font:setColor(ccc3(0xff,0xff,0xff))
    nextRefresh_font:setPosition(ccp(300*g_fScaleX,18*g_fScaleX))
    _bgLayer:addChild(nextRefresh_font)
    nextRefresh_font:setScale(MainScene.elementScale)

    -- 刷新时间
    downTime_font = CCLabelTTF:create("", g_sFontPangWa, 20)
    downTime_font:setColor(ccc3(0xff,0xff,0xff))
    downTime_font:setAnchorPoint(ccp(0,0))
    downTime_font:setPosition(ccp(312*g_fScaleX,18*g_fScaleX))
    _bgLayer:addChild(downTime_font)
    downTime_font:setScale(MainScene.elementScale)
    -- 更新倒计时
    local function updateDownTime()
        -- 减一秒
        MatchData.setDownTimeData( MatchData.getDownTimeData() - 1 )
        if (MatchData.getDownTimeData() <= 0) then 
            downTime_font:setString("00:00:00")
            -- 到期取消定时器
            if(MatchData.m_refreshScheduleId ~= nil)then
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(MatchData.m_refreshScheduleId)
                MatchData.m_refreshScheduleId = nil
            end
            return
        end
        local timeStr = TimeUtil.getTimeString(MatchData.getDownTimeData())
        downTime_font:setString(timeStr)
    end
    if ( MatchData.getDownTimeData() > 0 ) then 
        -- 启动定时器
        if( MatchData.m_refreshScheduleId == nil )then
            MatchData.m_refreshScheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateDownTime, 1, false)
        end
    else
        downTime_font:setString("00:00:00")
    end
    downTime_font:registerScriptHandler(function ( eventType,node )
        if(eventType == "exit") then
            -- 到期取消定时器
            if(MatchData.m_refreshScheduleId ~= nil)then
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(MatchData.m_refreshScheduleId)
                MatchData.m_refreshScheduleId = nil
            end
        end
    end)

    -- 创建玩家列表
    createMatchUserList( MatchData.m_userData )

end


-- 创建比武玩家
function createMatchUserList( userInfo )
	local function fnSortFun( a, b )
		return tonumber(a.point) < tonumber(b.point)
	end 
	-- 排序
	table.sort( userInfo, fnSortFun )
	print(GetLocalizeStringBy("key_2506"))
	print_t(userInfo)
	-- 创建
	local i = 0
	for k,v in pairs(userInfo) do
		local winScore = MatchData.getWinScore( v.point )
		-- print(winScore)
		local desc,font_color,fileName = MatchData.getDescFromWinScore( winScore )
		require "script/battle/BattleCardUtil"
        local dressId = nil
        local genderId = nil
        if(v.squad[1].dress)then
            if( not table.isEmpty(v.squad[1].dress) and (v.squad[1].dress["1"])~= nil and tonumber(v.squad[1].dress["1"]) > 0 )then
                dressId = v.squad[1].dress["1"]
                genderId = HeroModel.getSex(v.squad[1].htid)
            end
        end
	    local sprite1 = BattleCardUtil.getFormationPlayerCard(111111111,nil,v.squad[1].htid,dressId)
	    local sprite2 = BattleCardUtil.getFormationPlayerCard(111111111,nil,v.squad[1].htid,dressId)
	    local icon = createMatchUserInfo(desc, font_color, fileName,sprite1,sprite2, v.uname, v.level, v.uid, v.guild_name,v.title)
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
		pos = ccp(_layerSize.width*0.2,_layerSize.height*0.35)
	elseif( i == 2 )then
		pos = ccp(_layerSize.width*0.8,_layerSize.height*0.35)
	elseif( i == 3 )then
		pos = ccp(_layerSize.width*0.5,_layerSize.height*0.5)
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

-- 刷新对手按钮
function fnRefreshMenuItemAction( tag, itemBtn )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    -- 判断是否休息 为true 是休息
    if( MatchData.getIsOverMatchTime() == false )then
        require "script/ui/tip/AnimationTip"
        local str = GetLocalizeStringBy("key_3278")
        AnimationTip.showTip(str)
        return
    end
    if ( MatchData.getDownTimeData() > 0 ) then 
        require "script/ui/tip/AnimationTip"
        local str = GetLocalizeStringBy("key_2023")
        AnimationTip.showTip(str)
        return
    end
    -- 判断是否休息 为true 是休息
    if( MatchData.getIsRest() )then
        require "script/ui/tip/AnimationTip"
        local str = GetLocalizeStringBy("key_1941")
        AnimationTip.showTip(str)
        return 
    end
    -- 满足条件后逻辑处理
    local function createNextFun( ... )
        -- 移除原来的
        _bgLayer:removeChildByTag(101,true)
        _bgLayer:removeChildByTag(102,true)
        _bgLayer:removeChildByTag(103,true)
        -- 重新创建玩家列表
        createMatchUserList( MatchData.m_userData )
        -- 开倒计时
        local data = MatchData.getCDTiemFormXml()
        MatchData.setDownTimeData(data)
        -- 启动定时器
        local function updateDownTime()
            -- 减一秒
            MatchData.setDownTimeData( MatchData.getDownTimeData() - 1 )
            if (MatchData.getDownTimeData() <= 0) then 
                downTime_font:setString("00:00:00")
                -- 到期取消定时器
                if(MatchData.m_refreshScheduleId ~= nil)then
                    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(MatchData.m_refreshScheduleId)
                    MatchData.m_refreshScheduleId = nil
                end
                return
            end
            local timeStr = TimeUtil.getTimeString(MatchData.getDownTimeData())
            downTime_font:setString(timeStr)
        end
        if ( MatchData.getDownTimeData() > 0 ) then 
            -- 启动定时器
            if( MatchData.m_refreshScheduleId == nil )then
                MatchData.m_refreshScheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateDownTime, 1, false)
            end
        end
    end
    MatchService.refreshRivalList(createNextFun)
end

-- 卡牌按钮回调
function fnCardItemCallFun( tag, itemBtn )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	print("tag .. " .. tag)
    -- 判断是否休息 为true 是休息
    if( MatchData.getIsOverMatchTime() == false )then
        require "script/ui/tip/AnimationTip"
        local str = GetLocalizeStringBy("key_3058")
        AnimationTip.showTip(str)
        return
    end
    -- 剩余次数是否足够 
    if( MatchData.getContestNum() <= 0)then
        -- 比武次数已用完
        require "script/ui/tip/AnimationTip"
        local str = GetLocalizeStringBy("key_1266")
        AnimationTip.showTip(str)
        return
    end
    -- 判断背包是否满了
    if(ItemUtil.isBagFull() == true )then
        return
    end
    -- 耐力是否足够 
    -- print("UserModel.getStaminaNumber()",UserModel.getStaminaNumber())
    if( UserModel.getStaminaNumber()-2  < 0 )then
        -- 耐力已用完
        -- require "script/ui/tip/AnimationTip"
        -- local str = GetLocalizeStringBy("key_3157")
        -- AnimationTip.showTip(str)
        require "script/ui/item/StaminaAlertTip"
        StaminaAlertTip.showTip( refreshStaminaAndGold )
        return
    end
    -- 判断武将满了
    require "script/ui/hero/HeroPublicUI"
    if HeroPublicUI.showHeroIsLimitedUI() then
        return
    end
    -- 对手数据
    local enemyData = MatchData.getInfoByuid(tag)
    -- 此处不用计算胜利获得的分数了  后端传
    -- local winScore = MatchData.getWinScore(enemyData.point)
    -- 满足条件后逻辑处理
    local function createNextFun( atk, flopData, rank, myPoint, suc_point )
        local exp = nil
        local honor = nil
        if(atk.appraisal ~= "E" and atk.appraisal ~= "F")then
            -- 胜利 
            exp = MatchData.getExpForWin()
            honor = MatchData.getHonorForWin()
        else
            -- 失败
            exp = MatchData.getExpForFail()
            honor = 0
        end
        local function nextCallFun()
            -- 加经验
            UserModel.addExpValue(exp,"matchplace")
            -- 如果抽取的是抢夺或银币 加银币
            if(flopData ~= nil)then
                for k,v in pairs(flopData) do
                    if(k == "real")then
                        for i,j in pairs(v) do
                            if(i == "rob")then
                                -- 加银币
                                UserModel.addSilverNumber(tonumber(j))
                                if(MatchLayer._silverLabel ~= nil)then
                                    MatchLayer._silverLabel:setString( string.convertSilverUtilByInternational(UserModel.getSilverNumber()) )
                                end
                            elseif(i == "silver")then
                                -- 加银币
                                UserModel.addSilverNumber(tonumber(j))
                                if(MatchLayer._silverLabel ~= nil)then
                                    MatchLayer._silverLabel:setString( string.convertSilverUtilByInternational(UserModel.getSilverNumber()) )
                                end
                            elseif(i == "soul")then
                                -- 加将魂
                                UserModel.addSoulNum(tonumber(j))
                            elseif(i == "gold")then
                                -- 加金币
                                UserModel.addGoldNumber(tonumber(j))
                                if(MatchLayer._goldLabel ~= nil)then
                                    MatchLayer._goldLabel:setString( UserModel.getGoldNumber() )  
                                end  
                            end
                        end
                    end
                end
            end
            -- 更新剩余耐力值 by 2014.05.22
            if( _staminaLabel ~= nil )then
                -- _staminaLabel:setString(UserModel.getStaminaNumber() .. "/" .. UserModel.getMaxStaminaNumber())
                -- 移除原来的
                _staminaLabel:removeFromParentAndCleanup(true)
                _staminaLabel = nil
                -- 更新耐力
                _staminaLabel = CCRenderLabel:create( UserModel.getStaminaNumber() .. "/" .. UserModel.getMaxStaminaNumber(), g_sFontPangWa, 24, 1, ccc3(0x00,0x00,0x00), type_stroke)
                _staminaLabel:setColor(ccc3(0xff,0x17,0x0c))
                _staminaLabel:setPosition(ccp(100*g_fScaleX,_layerSize.height - 10*g_fScaleX))
                _bgLayer:addChild(_staminaLabel,1,11111)
                _staminaLabel:setScale(MainScene.elementScale)
            end
            -- 更新剩余次数
            if(_contestNumLabel ~= nil)then
                -- 移除原来的
                _contestNumLabel:removeFromParentAndCleanup(true)
                _contestNumLabel = nil
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
            -- 更新积分
            if(atk.appraisal ~= "E" and atk.appraisal ~= "F")then
                -- 胜利 
                -- 加荣誉
                MatchData.addHonorNum(honor)
                -- 积分
                if(myPoint ~= nil)then
                    MatchData.setMyScore(myPoint)
                end
                if(_scoreLabel ~= nil)then
                    -- 移除原来的
                    _scoreLabel:removeFromParentAndCleanup(true)
                    _scoreLabel = nil
                    -- 积分数值
                    local score_data = MatchData.getMyScore()
                    _scoreLabel = CCRenderLabel:create( score_data, g_sFontPangWa, 24, 1, ccc3(0x00,0x00,0x00), type_stroke)
                    _scoreLabel:setColor(ccc3(0x70,0xff,0x18))
                    _scoreLabel:setPosition(ccp(100*g_fScaleX,_layerSize.height - 130*g_fScaleX))
                    _bgLayer:addChild(_scoreLabel,1,11113)
                    _scoreLabel:setScale(MainScene.elementScale)
                end
                -- 移除原来的
                _bgLayer:removeChildByTag(101,true)
                _bgLayer:removeChildByTag(102,true)
                _bgLayer:removeChildByTag(103,true)
                -- 重新创建玩家列表
                createMatchUserList( MatchData.m_userData )

            end
            -- 更新排名
            if( rank ~= nil )then
                if( _rankingLabel ~= nil )then
                    MatchData.setMyRank(rank)
                    -- 移除原来的
                    _rankingLabel:removeFromParentAndCleanup(true)
                    _rankingLabel = nil
                    -- 排名数值
                    local ranking_data = MatchData.getMyRank()
                    _rankingLabel = CCRenderLabel:create( ranking_data, g_sFontPangWa, 24, 1, ccc3(0x00,0x00,0x00), type_stroke)
                    _rankingLabel:setColor(ccc3(0x00,0xe4,0xff))
                    _rankingLabel:setPosition(ccp(100*g_fScaleX,_layerSize.height - 90*g_fScaleX))
                    _bgLayer:addChild(_rankingLabel,1,11112)
                    _rankingLabel:setScale(MainScene.elementScale)
                end
            end
            -- 发战斗结束通知
            -- CCNotificationCenter:sharedNotificationCenter():postNotification("NC_FightOver")
        end
        -- 调用战斗接口 参数:atk 
        require "script/battle/BattleLayer"
        require "script/ui/common/CafterBattleLayer"
        local function afterOKcallFun()
            local str = nil
            if(atk.appraisal ~= "E" and atk.appraisal ~= "F")then
                -- 胜利 
                local winScore = suc_point or " "
                str = GetLocalizeStringBy("key_2410") .. winScore .. GetLocalizeStringBy("key_2275") .. honor .. GetLocalizeStringBy("lic_1113")
            end
            -- 返回后提示
            if(str ~= nil)then
                require "script/ui/tip/AnimationTip"
                AnimationTip.showTip(str)
            end
        end
        -- createAfterBattleLayer( appraisal, enemyUid, enemyName, enemyUtid, enemyFightData, silverData, expData, flopData, CallFun )

        local afterBattleLayer = CafterBattleLayer.createAfterBattleLayer( atk.appraisal, tag, enemyData.uname, enemyData.utid, enemyData.fight_force, honor, exp, flopData, afterOKcallFun, atk.fightRet)
        BattleLayer.showBattleWithString(atk.fightRet, nextCallFun, afterBattleLayer,"ducheng.jpg","music11.mp3",nil,nil,nil,true)
    end
    -- 限制不能连发两次请求
    itemBtn:setEnabled(false)

    -- addby chengliang
    PreRequest.setIsCanShowAchieveTip(false)

    MatchService.contest(tag, 0, createNextFun,itemBtn)
end

-- 创建比武玩家信息
-- m_des:获得积分描述
-- m_color:根据积分给出颜色
-- fileName:光束
-- cradIcon:卡牌
-- m_userName:玩家名字
-- m_lv:玩家等级
-- m_uid:玩家uid
-- guildName:玩家军团
function createMatchUserInfo( m_des, m_color, fileName, cradIcon_n, cradIcon_h, m_userName, m_lv, m_uid, guildName, pTitleId)
	local parent = CCNode:create()
	parent:setContentSize(CCSizeMake(168,318))
    -- 描述
	local font2 = CCRenderLabel:create( m_des, g_sFontPangWa, 25, 1, ccc3(0x00,0x00,0x00), type_stroke)
    font2:setAnchorPoint(ccp(0.5,0.5))
    font2:setColor(m_color)
    font2:setPosition(ccp(parent:getContentSize().width*0.5,parent:getContentSize().height*0.26))
    parent:addChild(font2,3)
    -- 玩家卡牌按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    parent:addChild(menu,2)
    local normalSprite = CCSprite:create("images/match/card_bg.png")
    cradIcon_n:setAnchorPoint(ccp(0.5,0))
    cradIcon_n:setPosition(ccp(normalSprite:getContentSize().width*0.5,37))
    normalSprite:addChild(cradIcon_n)
    local selectSprite =  CCSprite:create("images/match/card_bg.png")
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
        titleSprite:setPosition(ccp(parent:getContentSize().width*0.5, parent:getContentSize().height*0.77))
        parent:addChild(titleSprite,2)
    end
	return parent
end


-- 创建比武层
function createMatchPlaceLayer( layerSize )
	init()
	_bgLayer = CCLayer:create()
    _bgLayer:registerScriptHandler(function ( eventType,node )
        if(eventType == "enter") then
            
        end
        if(eventType == "exit") then
            init()
            require "script/ui/main/MainScene"
            MainScene.registerStaminaNumberChangeCallback( nil )
        end
    end)
	_bgLayer:setContentSize(layerSize)
    -- 初始化比武界面
    initMatchPlaceLayer()
	return _bgLayer
end



-- 刷新耐力显示UI
upDateStamina = function()
    if( _staminaLabel ~= nil)then
        -- _staminaLabel:setString(UserModel.getStaminaNumber() .. "/" .. UserModel.getMaxStaminaNumber())
        -- 移除原来的
        _staminaLabel:removeFromParentAndCleanup(true)
        _staminaLabel = nil
        -- 耐力更新
        _staminaLabel = CCRenderLabel:create( UserModel.getStaminaNumber() .. "/" .. UserModel.getMaxStaminaNumber(), g_sFontPangWa, 24, 1, ccc3(0x00,0x00,0x00), type_stroke)
        _staminaLabel:setColor(ccc3(0xff,0x17,0x0c))
        _staminaLabel:setPosition(ccp(100*g_fScaleX,_layerSize.height - 10*g_fScaleX))
        _bgLayer:addChild(_staminaLabel,1,11111)
        _staminaLabel:setScale(MainScene.elementScale)
    end
end

-- 耐力提示框刷新方法
function refreshStaminaAndGold( ... )
    upDateStamina()
    MatchLayer.refreshMatchGold()
end


-- 比武推送更新函数
function upDateMacthDataAndui( ret )
    print(GetLocalizeStringBy("key_1156"))
    require "script/ui/match/MatchData"
    require "script/ui/match/MatchPlace"
    require "script/ui/match/MatchEnemy"
    -- 设置玩家排名
    if(ret.rank ~= nil)then
        MatchData.setMyRank( ret.rank )
    end
    if( _rankingLabel ~= nil )then
        print("MatchData.getMyRank()",MatchData.getMyRank())
        -- 移除原来的
        _rankingLabel:removeFromParentAndCleanup(true)
        _rankingLabel = nil
        -- 排名数值
        local ranking_data = MatchData.getMyRank()
        _rankingLabel = CCRenderLabel:create( ranking_data, g_sFontPangWa, 24, 1, ccc3(0x00,0x00,0x00), type_stroke)
        _rankingLabel:setColor(ccc3(0x00,0xe4,0xff))
        _rankingLabel:setPosition(ccp(100*g_fScaleX,_layerSize.height - 90*g_fScaleX))
        _bgLayer:addChild(_rankingLabel,1,11112)
        _rankingLabel:setScale(MainScene.elementScale)
    end
    -- 设置积分
    if(ret.point ~= nil)then
        MatchData.setMyScore( ret.point )
    end
    if( _scoreLabel ~= nil )then
        print("MatchData.getMyScore()",MatchData.getMyScore())
        -- 移除原来的
        _scoreLabel:removeFromParentAndCleanup(true)
        _scoreLabel = nil
        -- 积分数值
        local score_data = MatchData.getMyScore()
        _scoreLabel = CCRenderLabel:create( score_data, g_sFontPangWa, 24, 1, ccc3(0x00,0x00,0x00), type_stroke)
        _scoreLabel:setColor(ccc3(0x70,0xff,0x18))
        _scoreLabel:setPosition(ccp(100*g_fScaleX,_layerSize.height - 130*g_fScaleX))
        _bgLayer:addChild(_scoreLabel,1,11113)
        _scoreLabel:setScale(MainScene.elementScale)
    end
    -- 添加仇人数据
    if(ret.addFoeInfo ~= nil)then
        for k,v in pairs(ret.addFoeInfo) do
            if( MatchData.m_enemyData ~= nil )then
                table.insert(MatchData.m_enemyData, v)
            end
        end
    end
    -- 刷新仇人列表
    if(MatchEnemy._enemyTableView ~= nil)then
        MatchEnemy._enemyTableView:reloadData()
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






















