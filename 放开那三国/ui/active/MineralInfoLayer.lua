-- Filename：	MineralInfoLayer.lua
-- Author：		Cheng Liang
-- Date：		2013-8-15
-- Purpose：		资源矿的详细信息

module ("MineralInfoLayer", package.seeall)

require "script/network/RequestCenter"
require "script/model/DataCache"
require "script/ui/main/MainScene"
require "script/ui/common/LuaMenuItem"
require "script/ui/tip/AnimationTip"
require "script/model/user/UserModel"
require "script/ui/active/MineralMenuItem"
require "script/utils/BaseUI"
require "script/ui/active/MineralUtil"
require "db/DB_Normal_config"
require "script/ui/tip/SingleTip"
require "script/utils/LuaUtil"
require "db/DB_Vip"
require "script/libs/LuaCCSprite"
require "script/libs/LuaCCLabel"
----------------------------------
local _bgLayer 				= nil
local _curMineralInfo 		= nil	-- 当前矿的信息
local _occupyBtn			= nil	-- 占领按钮
local _forceOccupyBtn 		= nil	-- 强占
local _occupyCountUpLabel 	= nil	-- 占领市场
local _protectLabel			= nil	-- 保护时间

local attr_arr				= nil	-- 属性的解析
local _updateTimeScheduler	= nil	-- sche
------------------------------------------ added by bzx
local _layer_touch_priority = -450
local _helper_name_labels
local _guard_time_label
------------------------------------------

-- 初始化
local function init( )
	_bgLayer 				= nil
	_curMineralInfo 		= nil	-- 当前矿的信息
	_occupyBtn				= nil	-- 占领按钮
	_forceOccupyBtn 		= nil	-- 强占
	_occupyCountUpLabel 	= nil	-- 占领市场
    _guard_time_label       = nil
	attr_arr				= nil	-- 属性的解析
	_protectLabel			= nil	-- 保护时间
    
    _helper_name_labels     = {}
end

-- create
function create()
	local bgLayerSize = _bgLayer:getContentSize()
end


--[[
 @desc	 处理touches事件
 @para 	 string event
 @return 
--]]
local function onTouchesHandler( eventType, x, y )
	
	if (eventType == "began") then
		return true
    elseif (eventType == "moved") then
	
    else
    	
	end
end


--[[
 @desc	 回调onEnter和onExit时间
 @para 	 string event
 @return void
 --]]
local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _layer_touch_priority, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
        stopTimeScheduler()
		_bgLayer:unregisterScriptTouchHandler()
	end
end

-- 关闭
function closeAction( tag, itembtn )
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end 

function stopTimeScheduler()
    if _updateTimeScheduler ~= nil then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateTimeScheduler)
		_updateTimeScheduler = nil
	end
end

function starTimeScheduler()
    if _updateTimeScheduler == nil then
        _updateTimeScheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateTime, 1, false)
    end
end
-- 获取标题 的sprite格式
local function getTitleSpriteByText( text )
	local titleSp = CCSprite:create("images/hero/info/title_bg.png")
	titleSp:setAnchorPoint(ccp(0,0.5))
	local titleLabel = CCLabelTTF:create(text, g_sFontName, 21)
	titleLabel:setColor(ccc3(0x00, 0x00, 0x00))
	titleLabel:setAnchorPoint(ccp(0, 0.5))
	titleLabel:setPosition(ccp(titleSp:getContentSize().width * 0.1, titleSp:getContentSize().height * 0.5 + 2))
	titleSp:addChild(titleLabel)
	
	return titleSp
end

-- 是否可以免费占领
local function isCanFreeOccupy()
    if _curMineralInfo.domain_type ~= "3" then
        return true
    end
    local star_time = "090000"
	local end_time = "230000"
    
    --local star_time = "130000"
	--local end_time = "140000"
    
	local star_time_interval 	= TimeUtil.getIntervalByTime(star_time) 
	local end_time_interval 	= TimeUtil.getIntervalByTime(end_time) 

	local isFree = false
	if(BTUtil:getSvrTimeInterval()>star_time_interval and BTUtil:getSvrTimeInterval() < end_time_interval) then
		isFree = true
	end
	return isFree
end

-- 放弃回调
function giveUpCallback( cbFlag,dictData, bRet )
	MineralLayer.giveUpMyMineralDelegate(_curMineralInfo)
	closeAction()
end

-- 
function occupyCallback( cbFlag, dictData, bRet )
	if(dictData.err ~= "ok") then
        return
    end
    if dictData.ret.err ~= "ok" then
        return
    end
    UserModel.addEnergyValue(-5)
    if dictData.ret.pitInfo.guards == nil then
        dictData.ret.pitInfo.guards = {}
    end
    if(dictData.ret.gold and tonumber(dictData.ret.gold)>0 ) then
        UserModel.addGoldNumber(-tonumber(dictData.ret.gold))
    end
    if( not table.isEmpty(dictData.ret) and dictData.ret.appraisal ~= "E" and dictData.ret.appraisal~="F")then
        
        MineralLayer.modifyMineralList( dictData.ret.pitInfo )
    end
    
    require "script/battle/BattleLayer"
    -- BattleLayer.showBattleWithString(dictData.ret.fight_ret, nil, AfterBattleLayer.createAfterBattleLayer( dictData.ret.appraisal, _curMineralInfo.uid, nil, nil, false ), "shandong.jpg")	
    local amf3_obj = Base64.decodeWithZip(dictData.ret.fight_ret)
    local lua_obj = amf3.decode(amf3_obj)
    print(GetLocalizeStringBy("key_1606"))
    print_t(lua_obj)
    local appraisal = lua_obj.appraisal
    -- 敌人uid
    local uid1 = lua_obj.team1.uid
    local uid2 = lua_obj.team2.uid
    local enemyUid = 0
    if(tonumber(uid1) ==  UserModel.getUserUid() )then
        enemyUid = tonumber(uid2)
    end
    if(tonumber(uid2) ==  UserModel.getUserUid() )then
        enemyUid = tonumber(uid1)
    end
    require "script/ui/active/AfterMineral"
    local is_npc = true
    if _curMineralInfo.uid ~= "0" then
        is_npc = nil
    end
    local layer = AfterMineral.createAfterMineralLayer( dictData.ret.appraisal, enemyUid, MineralLayer.callbackBattleLayerEnd, dictData.ret.fight_ret, is_npc)
    BattleLayer.showBattleWithString(dictData.ret.fight_ret, nil, layer, "shandong.jpg")
    --
    -- CCNotificationCenter:sharedNotificationCenter():postNotification("NC_FightOver")
    MineralLayer.refreshTopUI()
	closeAction()
end

--
local function isCanOccupy()
	local my_minerals = MineralLayer.getMyMineralInfo()
    --local my_mineral_count_limit = 1
    --local vip_level = UserModel.getVipLevel()
    
    --[[local second_mineral_vip_limit = DB_Normal_config.getDataById(1).resPlayerVip
    if vip_level >= second_mineral_vip_limit then
        my_mineral_count_limit = 2
    end
    
	if #myMineral >= my_mineral_count_limit then
		AnimationTip.showTip(GetLocalizeStringBy("key_1282"))
		return false
	end
    --]]
    if _curMineralInfo.domain_type == "3" then
        if my_minerals["2"] ~= nil then
            AnimationTip.showTip(GetLocalizeStringBy("key_8090"))
            return false
        end
    elseif my_minerals["1"] ~= nil then
        AnimationTip.showTip(GetLocalizeStringBy("key_1282"))
        return false
    end
	if( UserModel.getEnergyValue() < 5)then
		-- AnimationTip.showTip(GetLocalizeStringBy("key_1894"))
		require "script/ui/item/EnergyAlertTip"
		EnergyAlertTip.showTip(MineralLayer.refreshTopUI)
		closeAction()
		return false
	end
	if(  tonumber(_curMineralInfo.uid) >0 and (_curMineralInfo.protectExpireTime - BTUtil:getSvrTimeInterval()) >0 ) then
		AnimationTip.showTip(GetLocalizeStringBy("key_1315"))
		return false
	end

	return true
end

-- 占领的Action
local function occupyAction	( tag, itembtn)
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
	local args = Network.argsHandler(_curMineralInfo.domain_id, _curMineralInfo.pit_id)
	if(tag == 10003) then
		-- 放弃
        require "script/ui/tip/AlertTip"
        local giveUp = function(is_confirmed, arg)
            if is_confirmed == true then
                local args = Network.argsHandler(_curMineralInfo.domain_id, _curMineralInfo.pit_id)
                RequestCenter.mineral_giveUpPit(giveUpCallback, args)
            end
            AlertTip.closeAction()
        end
        AlertTip.showAlert(GetLocalizeStringBy("key_1679"), giveUp, true, nil)
	elseif(isCanOccupy()) then
		-- 占领
        local cost_gold_count = 0
        if _curMineralInfo.domain_type == "3" then
        	cost_gold_count = DB_Normal_config.getDataById(1).goldResCost
        end
        local my_minerals = MineralLayer.getMyMineralInfo()
        if( tonumber(_curMineralInfo.uid) > 0) then
            if not isCanFreeOccupy() then
                cost_gold_count = cost_gold_count + 20--todo
                if(UserModel.getGoldNumber() >= cost_gold_count)then
                    RequestCenter.mineral_grabPitByGold(occupyCallback, args)
                else
                    AnimationTip.showTip( GetLocalizeStringBy("key_8038").. tostring(cost_gold_count) ..GetLocalizeStringBy("key_8039"))
                end
            else
                if(UserModel.getGoldNumber() >= cost_gold_count)then
                    RequestCenter.mineral_grabPit(occupyCallback, args)
                else
                    AnimationTip.showTip(GetLocalizeStringBy("key_8038") .. tostring(cost_gold_count) ..GetLocalizeStringBy("key_8039"))
                end
            end
		else
            if(UserModel.getGoldNumber() >= cost_gold_count)then
                RequestCenter.mineral_capturePit(occupyCallback, args)
            else
                AnimationTip.showTip(GetLocalizeStringBy("key_8038") .. tostring(cost_gold_count) ..GetLocalizeStringBy("key_8039"))
            end
		end
	end
end 

function getAddTimeTipText()
    local guard_total_time = 0
    local my_minerals = MineralLayer.getMyMineralInfo()
    for i = 1, #_curMineralInfo.guards do
        local guard = _curMineralInfo.guards[i]
        if tonumber(guard.uid) == UserModel. getUserUid() then
            guard_total_time = BTUtil:getSvrTimeInterval() - tonumber(guard.guard_time)
        end
    end
    local guard_total_time_str = TimeUtil.getTimeString(guard_total_time)
    local addition = GuildDataCache.getGuildCityRewardRate(6).rate
    local lv = math.max(UserModel.getHeroLevel(), 30) + DB_Normal_config.getDataById(1).resPlayerLv
    local guard_coefficient = DB_Normal_config.getDataById(1).helpArmyIncomeRatio / 100
    local silver_count = math.ceil(tonumber(attr_arr[1]) *  guard_total_time * 5 / 100000 * lv * guard_coefficient * (1 + addition))
    return  GetLocalizeStringBy("key_8040").. guard_total_time_str .. GetLocalizeStringBy("key_8041") ..  silver_count .. GetLocalizeStringBy("key_8042")
end

function updateTime()

    if _guard_time_label ~= nil then
        _guard_time_label:setString(getAddTimeTipText())
    end
    
	if((_curMineralInfo.expireTime - BTUtil:getSvrTimeInterval()) <=0 ) then
		stopTimeScheduler()
		_occupyCountUpLabel:setString("00:00:00")

	else
		-- local time_str = TimeUtil.getTimeString( tonumber(attr_arr[2]) -(_curMineralInfo.expireTime - os.time()))
		local time_str = TimeUtil.getTimeString( (_curMineralInfo.expireTime - BTUtil:getSvrTimeInterval()))
		_occupyCountUpLabel:setString(time_str)
	end
	--[[
    if((_curMineralInfo.protectExpireTime - BTUtil:getSvrTimeInterval()) <=0 ) then
	else
		local time_str = TimeUtil.getTimeString( (_curMineralInfo.protectExpireTime - BTUtil:getSvrTimeInterval()))
	end
    -]]
end 

--
local function createUI()
	local fullRect = CCRectMake(0,0,213,171)
	local insetRect = CCRectMake(50,50,113,71)
	local bgSprite = CCScale9Sprite:create("images/formation/changeformation/bg.png", fullRect, insetRect)
    if true then
        bgSprite:setPreferredSize(CCSizeMake(515, 713))
    else
        bgSprite:setPreferredSize(CCSizeMake(515, 537))
    end

	bgSprite:setAnchorPoint(ccp(0.5, 0.5))
	bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height*0.45))
	bgSprite:setScale(MainScene.elementScale)
	_bgLayer:addChild(bgSprite)

	-- 本地数据
	require "db/DB_Res"
	local mineralDesc = DB_Res.getDataById(tonumber(_curMineralInfo.domain_id))


	-- 标题
	local titleSp = CCSprite:create("images/formation/changeformation/titlebg.png")
	titleSp:setAnchorPoint(ccp(0.5,0.5))
	titleSp:setPosition(ccp(bgSprite:getContentSize().width/2, bgSprite:getContentSize().height*0.99))
	bgSprite:addChild(titleSp)
	local titleLabel = CCLabelTTF:create(mineralDesc["res_name" .. _curMineralInfo.pit_id], g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5, 0.5))
	titleLabel:setPosition(ccp(titleSp:getContentSize().width/2, titleSp:getContentSize().height/2))
	titleSp:addChild(titleLabel)

    -- 关闭按钮bar
	local closeMenuBar = CCMenu:create()
	closeMenuBar:setPosition(ccp(0, 0))
	bgSprite:addChild(closeMenuBar)
	closeMenuBar:setTouchPriority(_layer_touch_priority - 1)
	-- 关闭按钮
	local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png", closeAction )
	closeBtn:setAnchorPoint(ccp(0.5, 0.5))
    closeBtn:setPosition(ccp(bgSprite:getContentSize().width*0.97, bgSprite:getContentSize().height*0.98))
	closeMenuBar:addChild(closeBtn)

---- 中间的UI
	-- 
	local fullRect_2 = CCRectMake(0, 0, 48, 48)
	local insetRect_2 = CCRectMake(20, 20, 10, 8)

	attr_arr = string.split(mineralDesc["res_attr" .. _curMineralInfo.pit_id],",")


	local time_hour = nil
    if tonumber(_curMineralInfo.uid) == UserModel. getUserUid() then
        time_hour = math.floor( tonumber(_curMineralInfo.due_time) / 60 / 60 )
    else
        time_hour = math.floor( tonumber(attr_arr[2]) / 60 / 60 )
    end
    -- 当前位置
    local info_bar_y = bgSprite:getContentSize().height - 44
    -- 间距
    local info_bar_pitch = 7
    -- 单行的高度
    local info_bar_height_1 = 48
    local cell_x = 140
	-- 产量 
	local productSprite = CCScale9Sprite:create("images/common/s9_1.png", fullRect_2, insetRect_2)
	productSprite:setPreferredSize(CCSizeMake(460, info_bar_height_1))
	productSprite:setAnchorPoint(ccp(0.5, 1))
	productSprite:setPosition(ccp( bgSprite:getContentSize().width * 0.5, info_bar_y))
	bgSprite:addChild(productSprite)
	-- 标题
	local productTitleSp = getTitleSpriteByText(GetLocalizeStringBy("key_1965"))
	productTitleSp:setPosition(ccp(0, productSprite:getContentSize().height * 0.5))
	productSprite:addChild(productTitleSp)
	-- 
	local productNumLabel = CCLabelTTF:create(attr_arr[1], g_sFontName, 23)
	productNumLabel:setColor(ccc3(0x00, 0x6d, 0x2f))
	productNumLabel:setAnchorPoint(ccp(0, 0.5))
	productNumLabel:setPosition(ccp(cell_x, productSprite:getContentSize().height * 0.5))
	productSprite:addChild(productNumLabel)
    info_bar_y = info_bar_y - productSprite:getContentSize().height - info_bar_pitch
    
---- 估计收益
	local rewardSprite = CCScale9Sprite:create("images/common/s9_1.png", fullRect_2, insetRect_2)
	rewardSprite:setPreferredSize(CCSizeMake(460, info_bar_height_1))
	rewardSprite:setAnchorPoint(ccp(0.5, 1))
	rewardSprite:setPosition(ccp( bgSprite:getContentSize().width * 0.5, info_bar_y))
	bgSprite:addChild(rewardSprite)
	-- 标题
	local rewardTitleSp = getTitleSpriteByText(GetLocalizeStringBy("key_1595"))
	rewardTitleSp:setPosition(ccp(0,rewardSprite:getContentSize().height * 0.5))
	rewardSprite:addChild(rewardTitleSp)
	-- 占领时长
    
	local timeLabel = CCLabelTTF:create( GetLocalizeStringBy("key_3409") .. time_hour .. GetLocalizeStringBy("key_1769") , g_sFontName, 23)
	timeLabel:setColor(ccc3(0x78, 0x25, 0x00))
	timeLabel:setAnchorPoint(ccp(0, 0.5))
	timeLabel:setPosition(ccp(cell_x, rewardSprite:getContentSize().height * 0.5))
	rewardSprite:addChild(timeLabel)
	-- 
	local lv = math.max(UserModel.getHeroLevel(), 30) + DB_Normal_config.getDataById(1).resPlayerLv
    require "script/ui/guild/GuildDataCache"
	local addition = GuildDataCache.getGuildCityRewardRate(6).rate + MineralUtil.getUnionAddition() / 10000
    local total_guards_time = 0
    if tonumber(_curMineralInfo.uid) == UserModel. getUserUid() then
        total_guards_time = tonumber(_curMineralInfo.total_guards_time)
    end
	local allMoneys = math.ceil(attr_arr[1] * (time_hour * 60 * 60 + total_guards_time * DB_Normal_config.getDataById(1).oneHelpArmyEnhance / 100) * 5 / 100000 * lv * (1 + addition))
	local rewardNumLabel = CCLabelTTF:create( GetLocalizeStringBy("key_8078") .. (allMoneys) .. GetLocalizeStringBy("key_1687") , g_sFontName, 23)
	rewardNumLabel:setColor(ccc3(0x00, 0x6d, 0x2f))
	rewardNumLabel:setAnchorPoint(ccp(0, 0.5))
	rewardNumLabel:setPosition(ccp(cell_x + timeLabel:getContentSize().width, rewardSprite:getContentSize().height * 0.5))
	rewardSprite:addChild(rewardNumLabel)
    info_bar_y = info_bar_y - rewardSprite:getContentSize().height - info_bar_pitch
    
---- 占领时间
	local occupyTimeSprite = CCScale9Sprite:create("images/common/s9_1.png", fullRect_2, insetRect_2)
	occupyTimeSprite:setPreferredSize(CCSizeMake(460, info_bar_height_1))
	occupyTimeSprite:setAnchorPoint(ccp(0.5, 1))
	occupyTimeSprite:setPosition(ccp( bgSprite:getContentSize().width * 0.5, info_bar_y))
	bgSprite:addChild(occupyTimeSprite)
	-- 标题
	local occupyTitleSp = getTitleSpriteByText(GetLocalizeStringBy("key_1348"))
	occupyTitleSp:setPosition(ccp(0, occupyTimeSprite:getContentSize().height*0.5))
	occupyTimeSprite:addChild(occupyTitleSp)
	-- 

	_occupyCountUpLabel = CCLabelTTF:create("00:00:00", g_sFontName, 23)
	_occupyCountUpLabel:setColor(ccc3(0x00, 0x6d, 0x2f))
	_occupyCountUpLabel:setAnchorPoint(ccp(0, 0.5))
	_occupyCountUpLabel:setPosition(ccp(cell_x, occupyTimeSprite:getContentSize().height/2))
	occupyTimeSprite:addChild(_occupyCountUpLabel)
    
    -- 延迟次数
    if _curMineralInfo.delay_times ~= "0" then
        local add_times_label = CCRenderLabel:create(GetLocalizeStringBy("key_8043") .. _curMineralInfo.delay_times .. GetLocalizeStringBy("key_8044"), g_sFontName, 23, 1, ccc3(0x00,0x00,0x00),type_shadow)
        occupyTimeSprite:addChild(add_times_label)
        add_times_label:setColor(ccc3(0x00, 0xff, 0x18))
        add_times_label:setAnchorPoint(ccp(0, 0.5))
        add_times_label:setPosition(ccp(300, occupyTimeSprite:getContentSize().height * 0.5))
    end


	if(tonumber(_curMineralInfo.uid) >0 and (_curMineralInfo.expireTime - BTUtil:getSvrTimeInterval())>0 ) then
		-- local time_str = TimeUtil.getTimeString( tonumber(attr_arr[2]) -(_curMineralInfo.expireTime - os.time()))
		local time_str = TimeUtil.getTimeString((_curMineralInfo.expireTime - BTUtil:getSvrTimeInterval()))
		_occupyCountUpLabel:setString(time_str)
		-- 计时
		starTimeScheduler()
	end
    info_bar_y = info_bar_y - occupyTimeSprite:getContentSize().height - info_bar_pitch

---- 占领者
	local occupyManSprite = CCScale9Sprite:create("images/common/s9_1.png", fullRect_2, insetRect_2)
	occupyManSprite:setPreferredSize(CCSizeMake(460, info_bar_height_1))
	occupyManSprite:setAnchorPoint(ccp(0.5, 1))
	occupyManSprite:setPosition(ccp( bgSprite:getContentSize().width * 0.5, info_bar_y))
	bgSprite:addChild(occupyManSprite)
	-- 标题
	local occupyManTitleSp = getTitleSpriteByText(GetLocalizeStringBy("key_3200"))
	occupyManTitleSp:setPosition(ccp(0, occupyManSprite:getContentSize().height*0.5))
	occupyManSprite:addChild(occupyManTitleSp)
	-- 
	local uname = GetLocalizeStringBy("key_1554")
	if(tonumber(_curMineralInfo.uid) >0 ) then
		uname = _curMineralInfo.uname
	end
	local occupyNumLabel = CCRenderLabel:create(uname, g_sFontName, 23, 1,ccc3(0x00, 0x00, 0x00), type_stroke)
    --occupyNumLabel:setColor(ccc3(0x78, 0x25, 0x00))
    if tonumber(_curMineralInfo.uid) == UserModel. getUserUid() then
        occupyNumLabel:setColor(ccc3(0x00, 0xff, 0x18))
    end
	occupyNumLabel:setAnchorPoint(ccp(0, 0.5))
	occupyNumLabel:setPosition(ccp(220, occupyManSprite:getContentSize().height/2))
	occupyManSprite:addChild(occupyNumLabel)

	if(tonumber(_curMineralInfo.uid) >0 ) then
		local levelLabel = CCRenderLabel:create("Lv." .. _curMineralInfo.level, g_sFontName, 21, 1,ccc3(0x00, 0x00, 0x00), type_stroke)
		levelLabel:setColor(ccc3(0xff, 0xf6, 0x00))
		levelLabel:setPosition(ccp(cell_x, occupyManSprite:getContentSize().height - (occupyManSprite:getContentSize().height-levelLabel:getContentSize().height)/2))
		occupyManSprite:addChild(levelLabel)
	end
    info_bar_y = info_bar_y - occupyManSprite:getContentSize().height - info_bar_pitch
--[[
    ---- 保护时间
	local protectTimeSprite = CCScale9Sprite:create("images/common/s9_1.png", fullRect_2, insetRect_2)
	protectTimeSprite:setPreferredSize(CCSizeMake(460, info_bar_height_1))
	protectTimeSprite:setAnchorPoint(ccp(0.5, 1))
	protectTimeSprite:setPosition(ccp( bgSprite:getContentSize().width * 0.5, info_bar_y))
	bgSprite:addChild(protectTimeSprite)
	-- 标题
	local protectTitleSp = getTitleSpriteByText(GetLocalizeStringBy("key_2034"))
	protectTitleSp:setPosition(ccp(0,protectTimeSprite:getContentSize().height*0.5))
	protectTimeSprite:addChild(protectTitleSp)
	-- 
	_protectLabel = CCLabelTTF:create("00:00:00", g_sFontName, 23)
	_protectLabel:setColor(ccc3(0x78, 0x25, 0x00))
	_protectLabel:setAnchorPoint(ccp(0, 0.5))
	_protectLabel:setPosition(ccp(170, protectTimeSprite:getContentSize().height/2))
	protectTimeSprite:addChild(_protectLabel)
    info_bar_y = info_bar_y - protectTimeSprite:getContentSize().height - info_bar_pitch
--]]
    
    -- 协助军
    local help_sprite = CCScale9Sprite:create("images/common/s9_1.png", fullRect_2, insetRect_2)
	help_sprite:setPreferredSize(CCSizeMake(460, info_bar_height_1))
	help_sprite:setAnchorPoint(ccp(0.5, 1))
	help_sprite:setPosition(ccp( bgSprite:getContentSize().width * 0.5, info_bar_y))
	bgSprite:addChild(help_sprite)
	-- 标题
    if true then
        help_sprite:setPreferredSize(CCSizeMake(460, 155))
        local help_title_sp = CCScale9Sprite:create("images/hero/info/title_bg.png", CCRectMake(0, 0, 122, 40))
        help_title_sp:setPreferredSize(CCSizeMake(151, 40))
      
        local guards_count = #_curMineralInfo.guards
        
        
        local res_attr = mineralDesc["res_attr" .. _curMineralInfo.pit_id]
        local res_attr_arry = string.split(res_attr, ",")
        local guard_limit = tonumber(res_attr_arry[5])
    
        local title_label = CCLabelTTF:create(GetLocalizeStringBy("key_8045") .. guards_count .. "/" .. guard_limit, g_sFontName, 21)
        title_label:setColor(ccc3(0x00, 0x00, 0x00))
        title_label:setAnchorPoint(ccp(0, 0.5))
        title_label:setPosition(ccp(help_title_sp:getContentSize().width * 0.1, help_title_sp:getContentSize().height * 0.5 + 2))
        help_title_sp:addChild(title_label)
        
        help_title_sp:setPosition(ccp(0, help_sprite:getContentSize().height - help_title_sp:getContentSize().height - 4))
        help_sprite:addChild(help_title_sp)
        
        if  _curMineralInfo.domain_type == "3" then
            local tip_label = CCRenderLabel:create(GetLocalizeStringBy("key_8091"), g_sFontName, 23, 1, ccc3(0x00,0x00,0x00),type_shadow)
            help_sprite:addChild(tip_label)
            tip_label:setAnchorPoint(ccp(0.5, 0.5))
            tip_label:setPosition(ccp(226, 45))
            -- tip_label:setColor(ccc3(0xff, 0xf6, 0x00))
        else
            for i = 1, guard_limit do
                local text = nil
                if i <= guards_count then
                    local guard_info = _curMineralInfo.guards[i]
                    text = guard_info.uname
                else
                    text = GetLocalizeStringBy("key_8046")
                end
                _helper_name_labels[i] = CCLabelTTF:create(text, g_sFontName, 23)
                help_sprite:addChild(_helper_name_labels[i])
                _helper_name_labels[i]:setColor(ccc3(0x78, 0x25, 0x00))
                _helper_name_labels[i]:setAnchorPoint(ccp(0, 0.5))
                _helper_name_labels[i]:setPosition(ccp(170 * ((i- 1) % 2) + 40, 100 - math.floor((i - 1) / 2) * 30))
            end
            local info_bar_menu = CCMenu:create()
            help_sprite:addChild(info_bar_menu)
            info_bar_menu:setTouchPriority(_layer_touch_priority - 1)
            info_bar_menu:setPosition(ccp(0, 0))
            -- 抢
            local grab_item = CCMenuItemImage:create("images/active/mineral/btn_grab_n.png",
                                                    "images/active/mineral/btn_grab_h.png")
            info_bar_menu:addChild(grab_item)
            grab_item:setAnchorPoint(ccp(0.5, 0.5))
            grab_item:setPosition(ccp(410, 83))
            grab_item:registerScriptTapHandler(callbackGrabGuard)
            
            if MineralUtil.isMyGuardMineral(_curMineralInfo) then
                _guard_time_label = CCRenderLabel:create(getAddTimeTipText(), g_sFontName, 21, 1, ccc3(0x00,0x00,0x00),type_shadow)
                help_sprite:addChild(_guard_time_label)
                _guard_time_label:setAnchorPoint(ccp(0.5, 0.5))
                _guard_time_label:setPosition(ccp(help_sprite:getContentSize().width * 0.5, 22))
                _guard_time_label:setColor(ccc3(0x00, 0xff, 0x18))
            end
        end
    else
        local guardTitleSp = getTitleSpriteByText(GetLocalizeStringBy("key_8045"))
        guardTitleSp:setPosition(ccp(0, help_sprite:getContentSize().height*0.5))
        help_sprite:addChild(guardTitleSp)
        local guardLabel = CCRenderLabel:create(GetLocalizeStringBy("key_8047"), g_sFontName, 23, 1,ccc3(0x00, 0x00, 0x00), type_stroke)
        guardLabel:setAnchorPoint(ccp(0, 0.5))
        guardLabel:setPosition(ccp(230, help_sprite:getContentSize().height * 0.5))
        help_sprite:addChild(guardLabel)
    end
	--if(tonumber(_curMineralInfo.uid) >0 and (_curMineralInfo.protectExpireTime - BTUtil:getSvrTimeInterval())>0) then
		-- _protectLabel:setString(TimeUtil.getTimeString(_curMineralInfo.protectExpireTime - os.time()))
      --  starTimeScheduler()
	--end

    -- 说明
	local fullRect_3 = CCRectMake(0,0,162,43)
	local insetRect_3 = CCRectMake(70,20,22,3)
	local descSprite = CCScale9Sprite:create("images/common/bg/bg_9s_1.png", fullRect, insetRect)
	descSprite:setPreferredSize(CCSizeMake(420, 130))
	descSprite:setAnchorPoint(ccp(0.5, 0))
	descSprite:setPosition(ccp(bgSprite:getContentSize().width * 0.5, 140))
	bgSprite:addChild(descSprite)	

	local descLabel = CCRenderLabel:create(GetLocalizeStringBy("key_8048"), g_sFontPangWa, 25, 1, ccc3(0x00,0x00,0x00), type_shadow)
	descLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	local descLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3022"), g_sFontPangWa, 33)
	descLabel:setColor(ccc3(0xff, 0xff, 0xff))
	descLabel:setAnchorPoint(ccp(0.5, 0))
	descLabel:setPosition(ccp(descSprite:getContentSize().width * 0.5, 85))
	descSprite:addChild(descLabel)
    require "db/DB_Normal_config"
    local gold_res_cost = DB_Normal_config.getDataById(1).goldResCost
    local descLabel_1 = {}
    local descLabel_1_node_position = ccp(descSprite:getContentSize().width * 0.5, 50)
    if _curMineralInfo.domain_type == "3" then
        descLabel_1[1] = CCRenderLabel:create(GetLocalizeStringBy("key_8092"), g_sFontName, 21, 1, ccc3(0x00,0x00,0x00),type_shadow)
        descLabel_1[2] = CCRenderLabel:create(GetLocalizeStringBy("key_8093"), g_sFontName, 21, 1, ccc3(0x00,0x00,0x00),type_shadow)
        descLabel_1[2]:setColor(ccc3(0x00, 0xe4, 0xff))
        descLabel_1[3] = CCRenderLabel:create(GetLocalizeStringBy("key_8094"), g_sFontName, 21, 1, ccc3(0x00,0x00,0x00),type_shadow)
        descLabel_1[4] = CCRenderLabel:create(string.format(GetLocalizeStringBy("key_8095"), gold_res_cost), g_sFontName, 21, 1, ccc3(0x00,0x00,0x00),type_shadow)
        descLabel_1[4]:setColor(ccc3(0xff, 0xf6, 0x00))
        descLabel_1_node_position = ccp(descSprite:getContentSize().width * 0.5, 60)
    else
        descLabel_1[1] = CCRenderLabel:create(GetLocalizeStringBy("key_8049"), g_sFontName, 21, 1, ccc3(0x00,0x00,0x00),type_shadow)
        descLabel_1[2] = CCRenderLabel:create(GetLocalizeStringBy("key_8050"), g_sFontName, 21, 1, ccc3(0x00,0x00,0x00),type_shadow)
        descLabel_1[2]:setColor(ccc3(0x00, 0xff, 0x18))
        descLabel_1[3] = CCRenderLabel:create(GetLocalizeStringBy("key_8051"), g_sFontName, 21, 1, ccc3(0x00,0x00,0x00),type_shadow)
    end
    local descLabel_1_node = BaseUI.createHorizontalNode(descLabel_1)
    descSprite:addChild(descLabel_1_node)
	descLabel_1_node:setPosition(descLabel_1_node_position)
    descLabel_1_node:setAnchorPoint(ccp(0.5, 0))
    local descLabel_2_node = nil
    if _curMineralInfo.domain_type == "3" then
        local descLabel_2 = {}
        descLabel_2[1] = CCRenderLabel:create(GetLocalizeStringBy("key_8096"), g_sFontName, 21, 1, ccc3(0x00,0x00,0x00),type_shadow)
        descLabel_2[1]:setColor(ccc3(0x00, 0xff, 0x18))
        descLabel_2[2] =  CCRenderLabel:create("20", g_sFontName, 21, 1, ccc3(0x00,0x00,0x00),type_shadow)
        descLabel_2[2]:setColor(ccc3(0xff, 0xf6, 0x00))
        descLabel_2[3] = CCRenderLabel:create(GetLocalizeStringBy("key_8097"), g_sFontName, 21, 1, ccc3(0x00,0x00,0x00),type_shadow)
        descLabel_2[3]:setColor(ccc3(0x00, 0xff, 0x18))
        descLabel_2_node = BaseUI.createHorizontalNode(descLabel_2)
        descLabel_2_node:setAnchorPoint(ccp(0.5, 0))
        descLabel_2_node:setPosition(ccp(descSprite:getContentSize().width * 0.5, 32))
        descSprite:addChild(descLabel_2_node)

        local richInfo = {}
        richInfo.defaultType = "CCRenderLabel"
       	richInfo.labelDefaultSize = 21
        richInfo.elements = {
        	{
        		text = GetLocalizeStringBy("key_8426"),
        		color = ccc3(0xff, 0xf6, 0x00)
        	}
    	}
    	local descLabel_3_node = GetLocalizeLabelSpriteBy_2("key_8427", richInfo)
    	descSprite:addChild(descLabel_3_node)
    	descLabel_3_node:setAnchorPoint(ccp(0.5, 0))
    	descLabel_3_node:setPosition(ccp(descSprite:getContentSize().width * 0.5, 5))
    end
        --descLabel_2_node = CCRenderLabel:create(GetLocalizeStringBy("key_8052"), g_sFontName, 21, 1, ccc3(0x00,0x00,0x00),type_shadow)
        --descLabel_2_node:setColor(ccc3(0x00, 0xff, 0x18))
   	--[[
    local descLabel_3 = {}
    descLabel_3[1] = CCRenderLabel:create("占领第二座资源矿需额外花费", g_sFontName, 21, 1, ccc3(0x00,0x00,0x00),type_shadow)
    descLabel_3[2] = CCSprite:create("images/common/gold.png")
    descLabel_3[3] = CCRenderLabel:create("50", g_sFontName, 21, 1, ccc3(0x00,0x00,0x00),type_shadow)
    descLabel_3[3]:setColor(ccc3(0xff, 0xf6, 0x00))
    local descLabel_3_node = BaseUI.createHorizontalNode(descLabel_3)
    descSprite:addChild(descLabel_3_node)
	descLabel_3_node:setAnchorPoint(ccp(0.5, 0))
	descLabel_3_node:setPosition(ccp(descSprite:getContentSize().width * 0.5, 15))
    --]]
---- 按钮
	local occupyMenuBar =  CCMenu:create()
	occupyMenuBar:setPosition(ccp(0, 0))
	occupyMenuBar:setTouchPriority(_layer_touch_priority - 1)
	bgSprite:addChild(occupyMenuBar)

    local force_occupy_gold_cost = 20
    if _curMineralInfo.domain_type == "3" then
        force_occupy_gold_cost = force_occupy_gold_cost + gold_res_cost
    end
    local force_occupy_btn_info = {
        normal = "images/common/btn/btn_red_n.png",
        selected = "images/common/btn/btn_red_h.png",
        size = CCSizeMake(200, 73),
        icon = "images/common/gold.png",
        text = GetLocalizeStringBy("key_8053"),
        number = tostring(force_occupy_gold_cost)
    }

    _forceOccupyBtn = LuaCCSprite.createNumberMenuItem(force_occupy_btn_info)
    occupyMenuBar:addChild(_forceOccupyBtn, 2, 10002)
   	_forceOccupyBtn:setAnchorPoint(ccp(0.5, 0))
	_forceOccupyBtn:setPosition(ccp(bgSprite:getContentSize().width*0.5 - 100, 65))
	_forceOccupyBtn:registerScriptTapHandler(occupyAction)
	_forceOccupyBtn:setVisible(false)
    
    local occupy_gold_cost = 0
    if _curMineralInfo.domain_type == "3" then
        occupy_gold_cost = occupy_gold_cost + gold_res_cost
    end
    local occupy_btn_info = {
        normal = "images/common/btn/btn1_d.png",
        selected = "images/common/btn/btn1_n.png",
        size = CCSizeMake(200, 73),
        icon = "images/common/gold.png",
        text = GetLocalizeStringBy("key_3293"),
        number = tostring(occupy_gold_cost)
    }
    _occupyBtn = LuaCCSprite.createNumberMenuItem(occupy_btn_info)
	_occupyBtn:setAnchorPoint(ccp(0.5, 0))
	_occupyBtn:registerScriptTapHandler(occupyAction)
	occupyMenuBar:addChild(_occupyBtn, 2, 10001)
    
    local is_free = isCanFreeOccupy()
    _occupyBtn:setVisible(is_free)
    _forceOccupyBtn:setVisible(not is_free)
                
    if UserModel.getUserUid() ~= tonumber(_curMineralInfo.uid) then
        if tonumber(_curMineralInfo.uid) ~= 0 then
            if MineralUtil.isMyGuardMineral(_curMineralInfo) then
                _occupyBtn:setVisible(false)
                local giveUpBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_red_n.png","images/common/btn/btn_red_h.png",CCSizeMake(230, 73),GetLocalizeStringBy("key_8054"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
                giveUpBtn:setAnchorPoint(ccp(0.5, 0))
                giveUpBtn:setPosition(ccp(bgSprite:getContentSize().width*0.5, 65))
                occupyMenuBar:addChild(giveUpBtn)
                giveUpBtn:registerScriptTapHandler(callbackGiveUpGuard)
                _forceOccupyBtn:setVisible(false)
            else
                if _curMineralInfo. domain_type ~= "3" then
                    _occupyBtn:setPosition(ccp(bgSprite:getContentSize().width*0.5 - 100, 65))
                    local guard_item = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_8055"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
                    occupyMenuBar:addChild(guard_item, 2)
                    guard_item:setAnchorPoint(ccp(0.5, 0))
                    guard_item:setPosition(ccp(bgSprite:getContentSize().width*0.5 + 100, 65))
                    guard_item:registerScriptTapHandler(callbackGuardItem)
                else
                    _occupyBtn:setPosition(ccp(bgSprite:getContentSize().width * 0.5, 65))
                    _forceOccupyBtn:setPosition(ccp(bgSprite:getContentSize().width * 0.5, 65))
                end
            end
        else
                _occupyBtn:setPosition(ccp(bgSprite:getContentSize().width * 0.5, 65))
                _occupyBtn:setVisible(true)
                _forceOccupyBtn:setVisible(false)
        end
    else
    
        _occupyBtn:setVisible(false)
		_forceOccupyBtn:setVisible(false)
        --guard_item:setVisible(false)
       
        local give_up_btn_size = nil
        local give_up_btn_position = nil
        local current_add_times = tonumber( _curMineralInfo.delay_times)
        local add_time_array = strToTable(DB_Normal_config.getDataById(1).resAddTime, {"n", "n", "n"})
        if current_add_times < #add_time_array then
            local add_time_btn = LuaCC.create9ScaleMenuItemWithoutLabel("images/common/btn/btn1_d.png", "images/common/btn/btn1_n.png", "images/common/btn/btn1_n.png", CCSizeMake(250, 73))
            occupyMenuBar:addChild(add_time_btn)
            local add_time = {}
            add_time[1] = CCRenderLabel:create(GetLocalizeStringBy("key_8056"), g_sFontPangWa, 35, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
            add_time[1]:setColor(ccc3(0xfe, 0xdb, 0x1c))
            add_time[2] = CCSprite:create("images/common/gold.png")
            local cost_gold_count = add_time_array[ current_add_times + 1][2]
            add_time[3] = CCLabelTTF:create(tostring(cost_gold_count), g_sFontPangWa, 25)
            add_time[3]:setColor(ccc3(0xfe, 0xdb, 0x1c))
        
            local add_time_node = BaseUI.createHorizontalNode(add_time)
            add_time_node:setAnchorPoint(ccp(0.5, 0.5))
            add_time_node:setPosition(ccp(add_time_btn:getContentSize().width * 0.5,add_time_btn:getContentSize().height * 0.5))
            add_time_btn:addChild(add_time_node)
            add_time_btn:setAnchorPoint(ccp(0.5, 0))
            add_time_btn:setPosition(ccp(168, 65))
            add_time_btn:registerScriptTapHandler(callbackAddTime)
            
            local add_hours = add_time_array[ current_add_times + 1][1] / 60 / 60
            local add_time_tip = CCRenderLabel:create( GetLocalizeStringBy("key_8057").. tostring(add_hours).. GetLocalizeStringBy("key_8058"), g_sFontName, 21, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
            add_time_btn:addChild(add_time_tip)
            add_time_tip:setAnchorPoint(ccp(0.5, 0.5))
            add_time_tip:setPosition(ccp(add_time_btn:getContentSize().width * 0.5, -20))
            add_time_tip:setColor(ccc3(0x00, 0xff, 0x18))
            
            give_up_btn_size = CCSizeMake(210, 73)
            give_up_btn_position = ccp(390, 65)
        end
        if give_up_btn_size == nil then
            give_up_btn_size = CCSizeMake(230, 73)
            give_up_btn_position = ccp(bgSprite:getContentSize().width * 0.5, 65)
        end
        local giveUpBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_red_n.png","images/common/btn/btn_red_h.png",give_up_btn_size,GetLocalizeStringBy("key_8059"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		giveUpBtn:setAnchorPoint(ccp(0.5, 0))
		giveUpBtn:setPosition(give_up_btn_position)
		giveUpBtn:registerScriptTapHandler(occupyAction)
		occupyMenuBar:addChild(giveUpBtn, 2, 10003)

    end
    

    --updateTime()
end

-- 抢按钮回调
function callbackGrabGuard()
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    if not MineralUtil.checkGrabGuard(_curMineralInfo) then
        return
    end
    require "script/ui/active/MineralGrabGuard"
    MineralGrabGuard.show(_curMineralInfo)
end

function callbackAddTime()
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    if not MineralUtil.checkAddTime(_curMineralInfo) then
    	closeAction()
        return
    end
    local args = Network.argsHandler(_curMineralInfo.domain_id, _curMineralInfo.pit_id)
    RequestCenter.mineral_delayPitDueTime(handleAddTime, args)
end

function handleAddTime(cbFlag, dictData, bRet)
    if dictData.err ~= "ok" then
        return
    end
    if dictData.ret.err ~= "ok" then
        return
    end
    local add_time_str = DB_Normal_config.getDataById(1).resAddTime
    local add_time_array = strToTable(add_time_str, {"n", "n", "n"})
    local add_time_limit = #add_time_array
    local current_add_times = tonumber(_curMineralInfo.delay_times) + 1
    UserModel.addGoldNumber(-add_time_array[ current_add_times][2])
    UserModel.addEnergyValue(-add_time_array[ current_add_times][3])
    MineralLayer.refreshTopUI()
    return could_add_time
end

function callbackGiveUpGuard()
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
    local args = Network.argsHandler(_curMineralInfo.domain_id, _curMineralInfo.pit_id)
    RequestCenter.mineral_abandonPit(handleGiveUpGuard, args)
end

function handleGiveUpGuard(cbFlag, dictData, bRet)
    if dictData.err ~= "ok" then
        return
    end
end


function show(mineral_info)
    local mineralInfoLayer = MineralInfoLayer.createLayer(mineral_info)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(mineralInfoLayer)
end

-- create
function createLayer(mineral_info)
	init()
	_curMineralInfo = mineral_info
	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent)

	createUI()

	return _bgLayer
end

-- 协助
function callbackGuardItem()
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
    local my_minerals = MineralLayer.getMyMineralInfo()
    local mineral = my_minerals["1"]
    if mineral ~= nil then
        if MineralUtil.isMyGuardMineral(mineral) then
            SingleTip.showTip(GetLocalizeStringBy("key_8060"))
        else
            SingleTip.showTip(GetLocalizeStringBy("key_8061"))
        end
        return
    end
    if MineralUtil.guardIsFull(_curMineralInfo) then
        SingleTip.showTip(GetLocalizeStringBy("key_8062"))
        return
    end
    local args = Network.argsHandler(_curMineralInfo.domain_id, _curMineralInfo.pit_id)
    RequestCenter.mineral_guardPit(handleGuardPid, args)
end

function handleGuardPid(cbFlag, dictData, bRet)
    if dictData.err ~= "ok" then
        return
    end
end


function refresh(mineral_info)
    if MineralUtil.isEqual(mineral_info, _curMineralInfo) then
        if _bgLayer ~= nil then
            stopTimeScheduler()
            _bgLayer:removeFromParentAndCleanup(true)
            show(mineral_info)
        end
    end
end
