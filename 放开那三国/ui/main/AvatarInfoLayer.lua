-- Filename: AvatarInfoLayer.lua
-- Author: fang
-- Date: 2013-08-26
-- Purpose: 该文件用于: 显示“角色信息”面板

module("AvatarInfoLayer", package.seeall)

require "script/utils/TimeUtil"
require "script/model/user/UserModel"
require "script/ui/formation/FormationUtil"
require "script/audio/AudioUtil"
require "script/ui/main/ChangeUserNameLayer"
require "db/DB_Normal_config"
local _ccLayerOfAvatarInfo

-- added by zhz
local _bg	
local _ccHeadIcon
local _headIconTwo
local _headIcon			
local _curHaveNumLabel		
local _userInfo 				
local _ccLabelExp				-- 经验值信息
local _ccExpProgress			-- 经验值进度条
local _nExpProgressOriWidth		-- 经验值进度条初始宽度
local _updateTimeScheduler 		-- scheduler
local _ccLabelSRestoreTime 		-- 耐力回复时间
local _ccLabelSFullTime			-- 耐力全部回满时间
local _ccLabelEFullTime			-- 体力全部回满时间
local _ccLabelERestoreTime		-- 体力恢复时间：
local _energyMaxNum				-- 体力最大值			
local _showEnergy				-- 初始的体力值
local _showStamina				-- 初始的耐力值
local _ccLabelExecutionValue	-- 体力的label "134/150" 形式
local _ccLabelStaminaValue      -- 耐力的label "14/15" 的形式
local _energyRestoreTime 
local _stainRestoreTime
local _nameLabel
local _ccGoldValue

local _touchPriority

local function init( )
	_ccHeadIcon = nil
	_curHaveNumLabel = nil
	_bg = nil
	_headIconTwo = nil
	_headIcon = nil
 	_updateTimeScheduler = nil
	_ccLabelSFullTime = nil 
	_ccLabelSRestoreTime = nil
	_ccLabelEFullTime = nil
	_ccLabelERestoreTime = nil
	_ccLabelExecutionValue = nil
	_ccLabelStaminaValue = nil
	_energyMaxNum = UserModel.getMaxExecutionNumber()
	_userInfo = UserModel.getUserInfo()
	--_startEnergy = _userInfo.execution
	_showEnergy = _userInfo.execution
	_showStamina = _userInfo.stamina	
	_energyRestoreTime = g_energyTime --6*60
	_stainRestoreTime = g_stainTime -- 30*60
	_nameLabel= nil
	_ccGoldValue= nil
end

    -- [soul_num] => 21080
    -- [stamina_max_num] => 100
    -- UserModel.getMaxStaminaNumber
    -- [ban_chat_time] => 0
    -- [buy_execution_accum] => 0
    -- [uid] => 22616
    -- [gold_num] => 21710
    -- [vip] => 7
    -- [stamina] => 462
    -- [execution_time] => 1377671760.000000
    -- [level] => 89
    -- [htid] => 20001
    -- [fight_cdtime] => 0
    -- [exp_num] => 2000
    -- [utid] => 2
    -- [execution] => 359
    -- [silver_num] => 152340
    -- [stamina_time] => 1377671400.000000
    -- [uname] => 78978902
    -- 体力每6分钟恢复1点
    -- 耐力每半小时恢复1点

-- 计算当前时间玩家的体力 ，耐力值
local function getCurUserInfo()
	-- 计算体力值,通过服务器当前的时间按减去后端给的时间戳，
	local passTime =  BTUtil:getSvrTimeInterval()- _userInfo.execution_time
	local passStainTime = BTUtil:getSvrTimeInterval()- _userInfo.stamina_time
	--local showExction 
	local addExecution = math.floor(passTime/(_energyRestoreTime))

	if(tonumber(_userInfo.execution) < tonumber(_energyMaxNum) ) then
		_showEnergy = _userInfo.execution+ addExecution	
	end

	-- 计算耐力值 ，通过服务器当前的时间按减去后端给的时间戳，
	local addStamina = math.floor(passStainTime/(_stainRestoreTime))
	if(tonumber(_userInfo.stamina)< tonumber(UserModel.getMaxStaminaNumber())) then
		_showStamina = _userInfo.stamina + addStamina
	end
end

-- 停止scheduler
function stopScheduler( )
	if(_updateTimeScheduler)then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateTimeScheduler)
		_updateTimeScheduler = nil
	end
end

-- 耐力每半小时恢复1点
-- 计算耐力恢复的时间
local function getStainTime()
	local stainNum = UserModel.getMaxStaminaNumber() - _userInfo.stamina
	local stainAddTime = stainNum*_stainRestoreTime
	-- 耐力恢复的全部时间
	local stainFullTime
	-- 耐力恢复的时间
	local stainTime 
	if(tonumber(UserModel.getMaxStaminaNumber()) > tonumber(_userInfo.stamina)) then
		stainFullTime=  TimeUtil.getTimeString(stainAddTime + _userInfo.stamina_time - BTUtil:getSvrTimeInterval())
		local leftTime = tonumber(BTUtil:getSvrTimeInterval() - _userInfo.stamina_time)%(_stainRestoreTime)
		stainTime = TimeUtil.getTimeString(_stainRestoreTime - leftTime)

	else
		stainFullTime = "00:00:00"
		stainTime = "00:00:00"
	end

	return stainFullTime ,stainTime
end

-- 体力每6分钟恢复1点
-- 计算体力恢复的时间
local function getEnergyTime( )
	local energyNum = _energyMaxNum - _userInfo.execution
	local energyAddTime = energyNum*_energyRestoreTime
	-- 体力恢复的全部剩余时间
	local energyFullTime 
	-- 体力恢复时间
	local energyTime
	if(tonumber(_energyMaxNum) > tonumber(_userInfo.execution)) then
		energyFullTime = TimeUtil.getTimeString(energyAddTime + _userInfo.execution_time - BTUtil:getSvrTimeInterval())
		local leftTime = tonumber(BTUtil:getSvrTimeInterval() - _userInfo.execution_time)%(_energyRestoreTime)
		--print("all leftTime is : ," , leftTime )
		energyTime =  TimeUtil.getTimeString(_energyRestoreTime - leftTime)

	else 
		energyFullTime = "00:00:00"
		energyTime = "00:00:00"
	end

	return energyFullTime, energyTime
end

-- scheduler 刷新
local function updateTime( )
	-- 耐力全部回满时间 ，耐力恢复时间
	local stainFullTime , stainTime = getStainTime()
	if _ccLabelSFullTime then
		_ccLabelSFullTime:setString(stainFullTime)
		_ccLabelSRestoreTime:setString(stainTime)
	end
	
	 --体力全部回满时间 ,体力恢复时间
	local energyFullTime , energyTime = getEnergyTime()
	if _ccLabelEFullTime then
		_ccLabelEFullTime:setString(energyFullTime)
		_ccLabelERestoreTime:setString(energyTime)
	end

	
	-- 当前的体力和耐力
	getCurUserInfo()
	-- 修改当前的体力
	_ccLabelExecutionValue:setString(_showEnergy .. "/" .. _energyMaxNum)
	_ccLabelStaminaValue:setString(_showStamina .. "/" .. UserModel.getMaxStaminaNumber())

end

-- “关闭”按钮事件回调处理
local function fnHandlerCloseButton(tag, obj)
	stopScheduler()
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_ccLayerOfAvatarInfo:removeFromParentAndCleanup(true)
	_ccLayerOfAvatarInfo = nil
end

-- 添加GetLocalizeStringBy("key_1465")按钮
local function addSureButton(menu, ccBg)
	local ccMenuItemSure = CCMenuItemImage:create("images/battle/btn/btn_commit_n.png", "images/battle/btn/btn_commit_h.png")
	-- changed by zhz height 15
	ccMenuItemSure:setPosition(ccBg:getContentSize().width/2, 15)
	ccMenuItemSure:setAnchorPoint(ccp(0.5, 0))
	ccMenuItemSure:registerScriptTapHandler(fnHandlerCloseButton)

	menu:addChild(ccMenuItemSure)
end
-- 创建“体力”，“耐力”显示区域
local function createESPanel( ccBg )
	-- 九宫格背景图
	local fullRect = CCRectMake(0, 0, 75, 75)
    local insetRect = CCRectMake(30, 30, 15, 10)
	local ccBgNg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png", fullRect, insetRect)
	local bgPreferredSize = CCSizeMake(426, 306)
	ccBgNg:setPreferredSize(bgPreferredSize)

	local x01=90
	local x02=0
	local x03=34
	local x04=128

	-- added by zhz
	-- 耐力全部回满时间 ，耐力恢复时间
	local stainFullTime , stainTime = getStainTime()
	 --体力全部回满时间 ,体力恢复时间
	local energyFullTime , energyTime = getEnergyTime()

	-- 耐力相关信息

	local ccLabelSFull = CCLabelTTF:create(GetLocalizeStringBy("key_1778"), g_sFontName, 22)
	ccLabelSFull:setPosition(x01, 20)
	x02 = x01 + ccLabelSFull:getContentSize().width
	_ccLabelSFullTime = CCLabelTTF:create("" .. stainFullTime, g_sFontName, 22)
	_ccLabelSFullTime:setColor(ccc3(0, 0xe4, 0xff))
	_ccLabelSFullTime:setPosition(x02, 20)

	local ccLabelSRestore = CCLabelTTF:create(GetLocalizeStringBy("key_1958"), g_sFontName, 22)
	ccLabelSRestore:setPosition(x01, 54)
	_ccLabelSRestoreTime = CCLabelTTF:create("" .. stainTime, g_sFontName, 22)
	_ccLabelSRestoreTime:setPosition(x02, 54)
	_ccLabelSRestoreTime:setColor(ccc3(0, 0xe4, 0xff))

	ccBgNg:addChild(ccLabelSFull)
	ccBgNg:addChild(_ccLabelSFullTime)
	ccBgNg:addChild(ccLabelSRestore)
	ccBgNg:addChild(_ccLabelSRestoreTime)

 	-- 凹线槽01

	local ccSpriteLine01 = CCSprite:create("images/chat/spliter.png")
	ccSpriteLine01:setPosition(ccBgNg:getContentSize().width/2, 94)
	ccSpriteLine01:setAnchorPoint(ccp(0.5, 0))
	ccSpriteLine01:setScaleX(3.8)
	ccBgNg:addChild(ccSpriteLine01)

	--added by zhz
	getCurUserInfo()

	local ccLabelStamina = CCLabelTTF:create(GetLocalizeStringBy("key_2268"), g_sFontName, 24)
	ccLabelStamina:setPosition(x03, 100)
	ccLabelStamina:setColor(ccc3(0x36, 0xff, 0))
	ccBgNg:addChild(ccLabelStamina)
	_ccLabelStaminaValue = CCLabelTTF:create(_showStamina.. "/" .. UserModel.getMaxStaminaNumber() ,g_sFontName, 24)
	_ccLabelStaminaValue:setPosition(x04, 100)
	_ccLabelStaminaValue:setColor(ccc3(0x36, 0xff, 0))
	ccBgNg:addChild(_ccLabelStaminaValue)

 	-- 体力相关信息
	local ccLabelEFull = CCLabelTTF:create(GetLocalizeStringBy("key_3046"), g_sFontName, 22)
	ccLabelEFull:setPosition(x01, 165)
	print("x01 is : ", x01)
	_ccLabelEFullTime = CCLabelTTF:create("" .. energyFullTime, g_sFontName, 22)
	_ccLabelEFullTime:setColor(ccc3(0, 0xe4, 0xff))
	_ccLabelEFullTime:setPosition(x02, 165)
	local ccLabelERestore = CCLabelTTF:create(GetLocalizeStringBy("key_1012"), g_sFontName, 22)
	ccLabelERestore:setPosition(x01, 199)
	_ccLabelERestoreTime = CCLabelTTF:create("" .. energyTime, g_sFontName, 22)
	_ccLabelERestoreTime:setColor(ccc3(0, 0xe4, 0xff))
	_ccLabelERestoreTime:setPosition(x02, 199)
	
	ccBgNg:addChild(ccLabelEFull)
	ccBgNg:addChild(_ccLabelEFullTime)
	ccBgNg:addChild(ccLabelERestore)
	ccBgNg:addChild(_ccLabelERestoreTime)

 	-- 凹线槽02
	local ccSpriteLine02 = CCSprite:create("images/chat/spliter.png")
	ccSpriteLine02:setPosition(ccBgNg:getContentSize().width/2, 240)
	ccSpriteLine02:setAnchorPoint(ccp(0.5, 0))
	ccSpriteLine02:setScaleX(3.8)
	ccBgNg:addChild(ccSpriteLine02)

	local ccLabelExecution = CCLabelTTF:create(GetLocalizeStringBy("key_1299"), g_sFontName, 24)
	ccLabelExecution:setPosition(x03, 246)
	ccLabelExecution:setColor(ccc3(0x36, 0xff, 0))
	ccBgNg:addChild(ccLabelExecution)
	_ccLabelExecutionValue = CCLabelTTF:create( _showEnergy .. "/" .. _energyMaxNum , g_sFontName, 24)
	_ccLabelExecutionValue:setPosition(x04, 246)
	_ccLabelExecutionValue:setColor(ccc3(0x36, 0xff, 0))
	ccBgNg:addChild(_ccLabelExecutionValue)

	_updateTimeScheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateTime, 1, false)
	return ccBgNg
end

-- 创建金、银币显示面板
local function createCoinPanel(ccBg)
	-- 九宫格背景图
	local fullRect = CCRectMake(0, 0, 75, 75)
    local insetRect = CCRectMake(30, 30, 15, 10)
	local ccBgNg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png", fullRect, insetRect)
	local bgPreferredSize = CCSizeMake(426, 172)
	ccBgNg:setPreferredSize(bgPreferredSize)

	--银币
	local x=140
	local y= 72
	local ccSilverHint = CCRenderLabel:create(GetLocalizeStringBy("key_3341"), g_sFontName, 24, 2, ccc3(0, 0, 0), type_stroke)
	ccSilverHint:setPosition(x, y)
	ccSilverHint:setAnchorPoint(ccp(0, 0))
	ccBgNg:addChild(ccSilverHint)
	x = x+ccSilverHint:getContentSize().width 
	local ccSilverSprite = CCSprite:create("images/common/coin_silver.png")
	
	ccSilverSprite:setPosition(x - 10, y+2)
	ccBgNg:addChild(ccSilverSprite)
	x = x+ccSilverSprite:getContentSize().width
	local ccSilverValue = CCRenderLabel:create(UserModel.getSilverNumber(),g_sFontName,24,2,ccc3(0,0,0),type_stroke)
	ccSilverValue:setAnchorPoint(ccp(0, 0))
	local size = ccSilverValue:getContentSize()
	--x = x + size.width/2 + 8
	ccSilverValue:setPosition(x, y)
	ccBgNg:addChild(ccSilverValue)

 	-- 金币
	local x=140
	local y= 102
	local ccGoldHint = CCRenderLabel:create(GetLocalizeStringBy("key_1298"), g_sFontName, 24, 2, ccc3(0, 0, 0), type_stroke)
	ccGoldHint:setColor(ccc3(0xfe, 0xdb, 0x1c))
	ccGoldHint:setPosition(x, y)
	-- ccGoldHint:setAnchorPoint(ccp(1, 0))
	ccGoldHint:setAnchorPoint(ccp(0,0))
	ccBgNg:addChild(ccGoldHint)
	x = x+ccGoldHint:getContentSize().width 
	local ccGoldSprite = CCSprite:create("images/common/gold.png")
	
	ccGoldSprite:setPosition(x- 10, y+2)
	ccBgNg:addChild(ccGoldSprite)
	x = x+ccGoldSprite:getContentSize().width
	_ccGoldValue =  CCRenderLabel:create(tostring(UserModel.getGoldNumber()), g_sFontName, 24, 2, ccc3(0, 0, 0), type_stroke)
	_ccGoldValue:setColor(ccc3(0xfe, 0xdb, 0x1c))
	_ccGoldValue:setAnchorPoint(ccp(0, 0))
	-- local size = ccGoldValue:getContentSize()
	-- x = x  + size.width/2 
	_ccGoldValue:setPosition(x, y)
	ccBgNg:addChild(_ccGoldValue)

	-- add by zhz
	-- -- 将魂
	local x=140
	local y= 42  --32
	local ccSoulHint = CCRenderLabel:create(GetLocalizeStringBy("key_1086"), g_sFontName, 24, 2, ccc3(0, 0, 0), type_stroke)
	-- ccSoulHint:setColor(ccc3(0xfe, 0xdb, 0x1c))
	ccSoulHint:setPosition(x, y)
	ccSoulHint:setAnchorPoint(ccp(0, 0))
	ccBgNg:addChild(ccSoulHint)
	x = x+ccSoulHint:getContentSize().width 
	local ccSoulSprite = CCSprite:create("images/common/icon_soul.png")
	
	ccSoulSprite:setPosition(x- 10, y)
	ccBgNg:addChild(ccSoulSprite)
	x = x+ccSoulSprite:getContentSize().width
	local soul_num = UserModel.getSoulNum()
	if(soul_num == nil) then
		soul_num= 0
	end
	local ccSoulValue =  CCRenderLabel:create(tostring(soul_num), g_sFontName, 24, 2, ccc3(0, 0, 0), type_stroke)
	ccSoulValue:setColor(ccc3(0xfe, 0xdb, 0x1c))
	ccSoulValue:setAnchorPoint(ccp(0, 0))
	local size = ccSoulValue:getContentSize()
	-- x = x + size.width/2 + 14
	ccSoulValue:setPosition(x, y)
	ccBgNg:addChild(ccSoulValue)

	-- 上阵武将比
	local hero, allHeros = FormationUtil.getOnFormationAndLimited()
	local ccHeroes = CCRenderLabel:create(GetLocalizeStringBy("key_1865") .. hero .. "/" .. allHeros, g_sFontName, 24, 2, ccc3(0, 0, 0), type_stroke)
	ccHeroes:setPosition(ccBgNg:getContentSize().width/2, 140)
	ccHeroes:setAnchorPoint(ccp(0.5, 0))
	ccBgNg:addChild(ccHeroes)

	-- 魂玉
	local x=140
	local y= 10
	local ccSoulHint = CCRenderLabel:create(GetLocalizeStringBy("key_3353"), g_sFontName, 24, 2, ccc3(0, 0, 0), type_stroke)
	-- ccSoulHint:setColor(ccc3(0xfe, 0xdb, 0x1c))
	ccSoulHint:setPosition(x, y)
	ccSoulHint:setAnchorPoint(ccp(0, 0))
	ccBgNg:addChild(ccSoulHint)
	x = x+ccSoulHint:getContentSize().width 
	local ccSoulSprite = CCSprite:create("images/common/jewel_small.png")
	
	ccSoulSprite:setPosition(x- 10, 6)
	ccBgNg:addChild(ccSoulSprite)
	x = x+ccSoulSprite:getContentSize().width
	local soul_num = UserModel.getJewelNum()
	if(soul_num == nil) then
		soul_num= 0
	end
	local ccSoulValue =  CCRenderLabel:create(tostring(soul_num), g_sFontName, 24, 2, ccc3(0, 0, 0), type_stroke)
	-- ccSoulValue:setColor(ccc3(0xfe, 0xdb, 0x1c))
	ccSoulValue:setAnchorPoint(ccp(0, 0))
	local size = ccSoulValue:getContentSize()
	ccSoulValue:setPosition(x, y-2)
	ccBgNg:addChild(ccSoulValue)

	return ccBgNg
end

local function getAnotherHtid( pSex,pHtid )
	require "db/DB_Sex_change"
	if(pSex==1)then
		for k,v in pairs(DB_Sex_change.Sex_change)do
			if(tonumber(v[2])==tonumber(pHtid))then
				return v[3]
			end
		end
	else
		for k,v in pairs(DB_Sex_change.Sex_change)do
			if(tonumber(v[3])==tonumber(pHtid))then
				return v[2]
			end
		end
	end
end

-- 生成头像
local function createHeadIcon( ... )
	local sQualityFile = "images/hero/quality/1.png"	-- default is 1
	sHeadFile = "images/base/hero/head_icon/head_nanxing.png"		-- default is man
	require "script/model/hero/HeroModel"
	local tAllHeroes = HeroModel.getAllHeroes()
	for k, v in pairs(tAllHeroes) do
		local htid = tonumber(v.htid)
		if HeroModel.isNecessaryHero(htid) then
			require "db/DB_Heroes"
			local db_data = DB_Heroes.getDataById(htid)
			sQualityFile =  "images/hero/quality/"..db_data.star_lv .. ".png"
			sHeadFile = "images/base/hero/head_icon/"..db_data.head_icon_id
		end
	end
	local ccSpriteHeadBg = CCSprite:create(sQualityFile)
	local ccSpriteHead = CCSprite:create(sHeadFile)
	ccSpriteHead:setPosition(ccSpriteHeadBg:getContentSize().width/2, ccSpriteHeadBg:getContentSize().height/2)
	ccSpriteHead:setAnchorPoint(ccp(0.5, 0.5))
	ccSpriteHeadBg:addChild(ccSpriteHead)

	return ccSpriteHeadBg
end

local function createAnotherHeadIcon( ... )
	local sQualityFile = "images/hero/quality/1.png"	-- default is 1
	sHeadFile = "images/base/hero/head_icon/head_nanxing.png"		-- default is man
	require "script/model/hero/HeroModel"
	local tAllHeroes = HeroModel.getAllHeroes()
	for k, v in pairs(tAllHeroes) do
		local htid = tonumber(v.htid)
		if HeroModel.isNecessaryHero(htid) then
			local sex = HeroModel.getSex(htid)
			local htid = getAnotherHtid(sex,htid)
			require "db/DB_Heroes"
			local db_data = DB_Heroes.getDataById(htid)
			sQualityFile =  "images/hero/quality/"..db_data.star_lv .. ".png"
			sHeadFile = "images/base/hero/head_icon/"..db_data.head_icon_id
		end
	end
	local ccSpriteHeadBg = CCSprite:create(sQualityFile)
	local ccSpriteHead = CCSprite:create(sHeadFile)
	ccSpriteHead:setPosition(ccSpriteHeadBg:getContentSize().width/2, ccSpriteHeadBg:getContentSize().height/2)
	ccSpriteHead:setAnchorPoint(ccp(0.5, 0.5))
	ccSpriteHeadBg:addChild(ccSpriteHead)

	return ccSpriteHeadBg
end

-- 更新经验值显示方法及进度条
function updateExpValueUI()
    -- 更新显示数据
    require "script/model/user/UserModel"
    local userInfo = UserModel.getUserInfo()
    require "db/DB_Level_up_exp"
    local tUpExp = DB_Level_up_exp.getDataById(2)
    local nLevelUpExp = tUpExp["lv_"..(tonumber(userInfo.level)+1)]
    _ccLabelExp:setString(tostring(math.floor(userInfo.exp_num)).."/"..nLevelUpExp)
    
    -- 更新进度条
    _ccExpProgress:setPreferredSize(CCSizeMake(200*math.floor(userInfo.exp_num)/nLevelUpExp, _ccExpProgress:getContentSize().height))
end


-- 创建头像区域
local function createHeadPanel(ccBg)
	require "script/libs/LuaCC"
 -- 九宫格背景
	_ccBgNg = CCScale9Sprite:create("images/common/transparent.png", CCRectMake(0, 0, 3, 3), CCRectMake(1, 1, 1, 1))
	_ccBgNg:setPreferredSize(CCSizeMake(ccBg:getContentSize().width, 160))
 -- 头像
	-- local _ccHeadIcon = createHeadIcon()
	require "script/model/utils/HeroUtil"
	local htid = UserModel.getAvatarHtid()
	local dressId= nil
	_ccHeadIcon= HeroUtil.getHeroIconByHTID(htid ,UserModel.getDressIdByPos(1), nil,UserModel.getVipLevel())
	_ccHeadIcon:setPosition(40, 22)
	_ccBgNg:addChild(_ccHeadIcon)
-- lv 等级 added by zhz
	local lvElement = {
		{ctype=LuaCC.m_ksTypeSprite, file="images/common/lv.png", hOffset=6, vOffset=4},
	}
	local tLevel = LuaCC.createCCNodesOnHorizontalLine(lvElement)
	tLevel[1]:setPosition(50, 0)
 	_ccBgNg:addChild(tLevel[1])
 	local lvElement2 = {
 		{ctype=LuaCC.m_ksTypeRenderLabel, text=UserModel.getHeroLevel(), color=ccc3(0xfe, 0xdb, 0x1c),strokeColor = ccc3(0x0,0x00,0x00),fontsize=21, vOffset=-8}
	}
	local tLevel2 = LuaCC.createCCNodesOnHorizontalLine(lvElement2)
 	tLevel2[1]:setPosition(90,21)
	_ccBgNg:addChild(tLevel2[1])

 
 -- 线条
	local line_x = _ccHeadIcon:getContentSize().width + _ccHeadIcon:getPositionX()
	local line_y = _ccHeadIcon:getContentSize().height/2 + _ccHeadIcon:getPositionY()
	local ccSpriteLine = CCSprite:create("images/common/line01.png")
	ccSpriteLine:setScaleX(3)
	ccSpriteLine:setPosition(line_x, line_y)
	_ccBgNg:addChild(ccSpriteLine)
 -- 线上名字，vip
	tElements = {
		{ctype=LuaCC.m_ksTypeRenderLabel, text=UserModel.getUserName(), color=ccc3(0x8a, 0xff, 0), strokeColor = ccc3(0x0,0x00,0x00),fontsize=25},
 	}
 	local tObjs = LuaCC.createCCNodesOnHorizontalLine(tElements)

 	-- added by zhz 方老师写的方法太不好用了。。。。。
 	_nameLabel = tObjs[1]
 	tObjs[1]:setPosition(line_x+85, line_y+38)
	_ccBgNg:addChild(tObjs[1])
	-- 现有将魂
 	-- -- vip等级
 	local tElements = {
 		{ctype=LuaCC.m_ksTypeSprite, file="images/main/vip/vip.png"},
 	}
 	require "script/model/user/UserModel"
 	local sVip = tostring(UserModel.getVipLevel())
 	for i=1, #sVip do
 		local tData = {ctype=LuaCC.m_ksTypeSprite}
 		tData.file = "images/main/vip/".. (string.byte(sVip, i)-48) ..".png"
 		table.insert(tElements, tData)
 	end
	local tObjVip = LuaCC.createCCNodesOnHorizontalLine(tElements)
	_ccBgNg:addChild(tObjVip[1])
	local nWidth = 0
	for i=1, #tObjVip do
		nWidth = nWidth + tObjVip[i]:getContentSize().width
	end
	local vip_x = (_ccHeadIcon:getContentSize().width - nWidth)/2 + _ccHeadIcon:getPositionX()
	tObjVip[1]:setPosition(line_x + 14 , line_y+ 10)


	-- 跟名按钮
	local menu= CCMenu:create()
	menu:setPosition(ccp(0,0))
	_ccBgNg:addChild(menu)
	menu:setTouchPriority(_touchPriority - 1)
	local changeNameItem= CCMenuItemImage:create("images/main/btn_name_change/btn_change_n.png", "images/main/btn_name_change/btn_change_h.png")
	changeNameItem:registerScriptTapHandler(changeNameAction)
	changeNameItem:setPosition(ccp(441, line_y+ 5))
	menu:addChild(changeNameItem)

	local changeSexItem = LuaCC.create9ScaleMenuItem("images/common/blue1.png", "images/common/blue2.png",CCSizeMake(140, 60), GetLocalizeStringBy("llp_479"),ccc3(0xfe, 0xdb, 0x1c),25,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	changeSexItem:registerScriptTapHandler(changeSexAction)
	changeSexItem:setPosition(ccp(20, -56))
	menu:addChild(changeSexItem)

	ChangeUserNameLayer.registerNameChangeCb(refreshUI)

	local idLabel = CCRenderLabel:create("ID：",g_sFontName,28,1,ccc3(0x00,0x00,0x00),type_stroke)
	idLabel:setColor(ccc3(0xff,0xf6,0x00))

	local uidStr = UserModel.getUserUid()
	
	if(LoginScene.getFeignRoleId ~=nil and LoginScene.getFeignRoleId() ~= nil)then
		uidStr = LoginScene.getFeignRoleId()
	end
	local uidLabel = CCRenderLabel:create(uidStr,g_sFontName,28,1,ccc3(0x00,0x00,0x00),type_stroke)
	uidLabel:setColor(ccc3(0xff,0xff,0xff))

	require "script/utils/BaseUI"
	local connectNode = BaseUI.createHorizontalNode({idLabel, uidLabel})
	connectNode:setAnchorPoint(ccp(0,0))
	connectNode:setPosition(ccp(line_x + 30,line_y - 35))
	_ccBgNg:addChild(connectNode)

 -- 线下“战斗力”信息
 -- 战斗力text changed by zhz 
	tElements = {
 		{ctype=LuaCC.m_ksTypeSprite, file="images/common/fight_value.png", },
 	}
 	local tObjs = LuaCC.createCCNodesOnHorizontalLine(tElements)
 	tObjs[1]:setPosition(line_x+30, line_y-80)
 	_ccBgNg:addChild(tObjs[1])

 	tElements = {
 		{ctype=LuaCC.m_ksTypeRenderLabel, text="" .. math.floor(MainScene.initFightValue()), color=ccc3(0xfe, 0xdb, 0x1c), strokeColor = ccc3(0x0,0x00,0x00),fontsize=28}
 	}
 	local tObjs2 = LuaCC.createCCNodesOnHorizontalLine(tElements)
 	tObjs2[1]:setPosition(line_x+120, line_y-50)
 	_ccBgNg:addChild(tObjs2[1])

 	-- add by zhz
 	-- 经验值
 	tElements = {
 		{ctype=LuaCC.m_ksTypeRenderLabel, text=GetLocalizeStringBy("key_1907") , color=ccc3(0, 0xe4, 0xff),strokeColor = ccc3(0x0,0x00,0x00),fontsize= 28 }
 	}
 	local tObjsExp = LuaCC.createCCNodesOnHorizontalLine(tElements)
 	tObjsExp[1]:setPosition(line_x+30, line_y-80)
 	_ccBgNg:addChild(tObjsExp[1])

 	local fullRect = CCRectMake(0, 0, 46, 23)
    local insetRect = CCRectMake(20, 8, 5, 1)
    local exp_bg = CCScale9Sprite:create("images/pet/petfeed/exp_bg.png",fullRect,insetRect)
    exp_bg:setContentSize(CCSizeMake(200,23))
    local size = exp_bg:getContentSize()
    exp_bg:setPosition(ccp(line_x+ 100, line_y- 110))
    _ccBgNg:addChild(exp_bg)

     _ccExpProgress = CCScale9Sprite:create( "images/pet/petfeed/exp_progress.png")
    _ccExpProgress:setAnchorPoint(ccp(0, 0))
	_ccExpProgress:setPosition(ccp(0,0))
    exp_bg:addChild(_ccExpProgress)
	-- 阅历值信息
    _ccLabelExp = CCLabelTTF:create ("1/1", g_sFontName, 18)
    _ccLabelExp:setPosition(size.width/2, size.height/2-2)
    _ccLabelExp:setColor(ccc3(0, 0, 0))
    _ccLabelExp:setAnchorPoint(ccp(0.5, 0.5))
    exp_bg:addChild(_ccLabelExp)

    -- 更新经验
    updateExpValueUI()
	return _ccBgNg
end

local function fnFilterTouchEvent(event, x, y)

	return true
end

local function nodeEvent(eventType,x,y )

	if(eventType == "exit") then
		print("exit")
		ChangeUserNameLayer.registerNameChangeCb(nil)
		-- 更新战斗力
		MainScene.fnUpdateFightValue()
	end
end

-- 创建“角色信息”显示layer
function createLayer(touchPriority)
	_touchPriority = touchPriority or - 700
	local layer = CCLayerColor:create(ccc4(11,11,11,166))
	-- add by zhz 
	init()
	-- 背景九宫格图片
	local fullRect = CCRectMake(0, 0, 213, 171)
	local insetRect = CCRectMake(84, 84, 2, 3)
	local ccSpriteBg = CCScale9Sprite:create("images/common/viewbg1.png", fullRect, insetRect)
	ccSpriteBg:setPreferredSize(CCSizeMake(560, 800))
	ccSpriteBg:setScale(g_fElementScaleRatio)
	require "script/ui/main/MenuLayer"
	ccSpriteBg:setPosition(g_winSize.width/2, MenuLayer.getHeight())
	ccSpriteBg:setAnchorPoint(ccp(0.5, 0))
	layer:addChild(ccSpriteBg)

	local bg_size = ccSpriteBg:getContentSize()

	local ccTitleBG = CCSprite:create("images/common/viewtitle1.png")
	ccTitleBG:setPosition(ccp(bg_size.width/2, bg_size.height-6))
	ccTitleBG:setAnchorPoint(ccp(0.5, 0.5))
	ccSpriteBg:addChild(ccTitleBG)

	-- 按星级出售标题文本
	local ccLabelTitle = CCLabelTTF:create (GetLocalizeStringBy("key_2016"), g_sFontPangWa, 36, CCSizeMake(315, 61), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
	ccLabelTitle:setPosition(ccp(ccTitleBG:getContentSize().width/2, (ccTitleBG:getContentSize().height-1)/2))
	ccLabelTitle:setAnchorPoint(ccp(0.5, 0.5))
	ccLabelTitle:setColor(ccc3(0xff, 0xf0, 0x49))
	ccTitleBG:addChild(ccLabelTitle)

	local menu = CCMenu:create()

	local ccButtonClose = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	ccButtonClose:setAnchorPoint(ccp(1, 1))
	ccButtonClose:setPosition(ccp(bg_size.width+14, bg_size.height+14))
	ccButtonClose:registerScriptTapHandler(fnHandlerCloseButton)
	menu:addChild(ccButtonClose)
	menu:setPosition(0, 0)
	menu:setTouchPriority(_touchPriority - 1)
	-- 添加“确定”按钮
	addSureButton(menu, ccSpriteBg)
	-- 创建“体力”，“耐力”显示区域
	local ccESPanel = createESPanel(ccSpriteBg)
	ccESPanel:setAnchorPoint(ccp(0.5, 0))
	ccESPanel:setPosition(ccSpriteBg:getContentSize().width/2, 90)
	ccSpriteBg:addChild(ccESPanel)
	-- 创建金、银币显示面板
	local ccCoinPanel = createCoinPanel(ccSpriteBg)
	ccCoinPanel:setAnchorPoint(ccp(0.5, 0))
	ccCoinPanel:setPosition(ccSpriteBg:getContentSize().width/2, 405)
	ccSpriteBg:addChild(ccCoinPanel)
	ccSpriteBg:addChild(menu)

	local headPanel = createHeadPanel(ccSpriteBg)
	headPanel:setPosition(0, 640)
	ccSpriteBg:addChild(headPanel)

	layer:setTouchEnabled(true)
	layer:registerScriptTouchHandler(fnFilterTouchEvent,false,_touchPriority, true)
	layer:registerScriptHandler(nodeEvent)
	_ccLayerOfAvatarInfo = layer

	return layer
end

-------------------------------------------------[[ 刷新方法]]--------------------------------------------------------------
function refreshUI( )
	print("==== refreshUI  refreshUI  refreshUI")
	_nameLabel:setString(UserModel.getUserName())
	_ccGoldValue:setString(UserModel.getGoldNumber() )
end

------------------------------------------------[[ 按钮事件 added by zhz ]]-------------------------------------------
function changeNameAction( tag,item )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	ChangeUserNameLayer.showLayer(nil,_touchPriority - 10)
end

function changeSexAction( tag,item )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	showChangeSexDialog()
end


function getObject( ... )
	return _ccLayerOfAvatarInfo
end

local function dialogNodeEvent(eventType,x,y )
	if(eventType == "exit") then
	end
end

local function dialogTouchEvent(event, x, y)
	return true
end

local function dialogCloseCallBack( ... )
	local runing_scene = CCDirector:sharedDirector():getRunningScene()
	runing_scene:removeChildByTag(934,true)
end

local function freshMainHeadIcon( pInfo )
	-- body
	_ccHeadIcon:removeFromParentAndCleanup(true)
	local htid = pInfo.htid
	_ccHeadIcon= HeroUtil.getHeroIconByHTID(htid ,UserModel.getDressIdByPos(1), nil,UserModel.getVipLevel())
	-- _ccHeadIcon:setScale(g_fElementScaleRatio)
	_ccHeadIcon:setPosition(40, 22)
	_ccBgNg:addChild(_ccHeadIcon)
end

local function freshHeadIcon( pInfo )
	-- body
	_headIcon:removeFromParentAndCleanup(true)
	local htid = pInfo.htid
	_headIcon = HeroUtil.getHeroIconByHTID(htid ,UserModel.getDressIdByPos(1), nil,UserModel.getVipLevel())
	_headIcon:setScale(g_fElementScaleRatio)
	_headIcon:setAnchorPoint(ccp(1,0))
	_headIcon:setPosition(ccp(_bg:getContentSize().width*0.33,_costTipLabel:getPositionY()+_costTipLabel:getContentSize().height+15*g_fScaleX))
	_bg:addChild(_headIcon)

	local sex = HeroModel.getSex(htid)
	local htid = getAnotherHtid(sex,htid)
	_headIconTwo:removeFromParentAndCleanup(true)
	_headIconTwo = HeroUtil.getHeroIconByHTID(htid ,UserModel.getDressIdByPos(1), nil,UserModel.getVipLevel())
	_headIconTwo:setScale(g_fElementScaleRatio)
	_headIconTwo:setAnchorPoint(ccp(0,0))
	_headIconTwo:setPosition(ccp(_bg:getContentSize().width*0.66,_costTipLabel:getPositionY()+_costTipLabel:getContentSize().height+15*g_fScaleX))
	_bg:addChild(_headIconTwo)
end

function freshCostLabel( ... )
	-- body
	local data = DB_Normal_config.getDataById(1)
	local num = ItemUtil.getCacheItemNumBy(data.sex_change)
	_curHaveNumLabel:setString(num)
end

local function sendCommond( ... )
	-- body
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true) then
			AnimationTip.showTip(GetLocalizeStringBy("llp_483"))
			HeroModel.changeAvatarInfo(dictData.ret)
			freshHeadIcon(dictData.ret)
			local runningScene = CCDirector:sharedDirector():getRunningScene()
        	performWithDelay(runningScene,freshCostLabel,0.2) 
        	UserModel.setAvatarHtid(dictData.ret.htid)
        	MainScene.resetAvatarIcon()
			freshMainHeadIcon(dictData.ret)
		end
	end
	local args = CCArray:create()
	Network.rpc(requestFunc, "user.changeSex", "user.changeSex", nil, true)
end

local function sureCallBack( ... )
	local data = DB_Normal_config.getDataById(1)
	local num = ItemUtil.getCacheItemNumBy(data.sex_change)
	if(tonumber(num)>=1)then
		sendCommond()
	else
		AnimationTip.showTip(GetLocalizeStringBy("llp_482"))
	end
end

function showChangeSexDialog( ... )
	local dialog = CCLayerColor:create(ccc4(11,11,11,166))
		  dialog:setTouchEnabled(true)
		  dialog:registerScriptTouchHandler(dialogTouchEvent,false,_touchPriority-1, true)
		  dialog:registerScriptHandler(dialogNodeEvent)
	_bg = CCScale9Sprite:create("images/holidayhappy/tableviewbg.png")
    dialog:addChild(_bg)
    _bg:setPreferredSize(CCSizeMake(400*g_fBgScaleRatio, 300*g_fBgScaleRatio))
    _bg:setAnchorPoint(ccp(0.5, 1))
    _bg:setPosition(ccp(g_winSize.width*0.5, g_winSize.height*0.7))

    local titleBg = CCSprite:create("images/pet/pet/talent_skill.png")
    	  titleBg:setScale(g_fElementScaleRatio)
		  titleBg:setAnchorPoint(ccp(0.5,0.5))
		  titleBg:setPosition(ccp(_bg:getContentSize().width/2,_bg:getContentSize().height-10))
	_bg:addChild(titleBg)
    local runing_scene = CCDirector:sharedDirector():getRunningScene()
    runing_scene:addChild(dialog,2000,934)

    local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_479"),g_sFontPangWa,22)
    	  titleLabel:setAnchorPoint(ccp(0.5,0.5))
    	  titleLabel:setPosition(ccp(titleBg:getContentSize().width*0.5,titleBg:getContentSize().height*0.5+5*g_fElementScaleRatio))
    titleBg:addChild(titleLabel)

    local dialogMenu = CCMenu:create()
    	  dialogMenu:setPosition(ccp(0,0))
    	  dialogMenu:setTouchPriority(_touchPriority - 2)
    _bg:addChild(dialogMenu)
    local closeItem = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    	  closeItem:setAnchorPoint(ccp(0.5,0.5))
    	  closeItem:setScale(g_fElementScaleRatio)
		  closeItem:setPosition(_bg:getContentSize().width, _bg:getContentSize().height)
		  closeItem:registerScriptTapHandler(dialogCloseCallBack)
	dialogMenu:addChild(closeItem)

	require "script/libs/LuaCC"
	local confirmBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(140, 70), GetLocalizeStringBy("key_8129"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		  confirmBtn:setAnchorPoint(ccp(0.5, 0))
		  confirmBtn:setScale(g_fElementScaleRatio)
		  confirmBtn:setPosition(ccp(_bg:getContentSize().width*0.33,10*g_fElementScaleRatio))
		  confirmBtn:registerScriptTapHandler(sureCallBack)
	dialogMenu:addChild(confirmBtn)

	local cancelBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(140, 70), GetLocalizeStringBy("key_8254"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		  cancelBtn:setAnchorPoint(ccp(0.5, 0))
		  cancelBtn:setScale(g_fElementScaleRatio)
		  cancelBtn:setPosition(ccp(_bg:getContentSize().width*0.66,10*g_fElementScaleRatio))
		  cancelBtn:registerScriptTapHandler(dialogCloseCallBack)
	dialogMenu:addChild(cancelBtn)

	local curHaveSprite = CCSprite:create()

	local curHaveLabel = CCLabelTTF:create(GetLocalizeStringBy("lic_1477"),g_sFontName,22)
		  curHaveLabel:setColor(ccc3(0xff,0xf6,0x00))
		  curHaveLabel:setScale(g_fElementScaleRatio)
		  curHaveLabel:setPosition(ccp(0,0))
	curHaveSprite:addChild(curHaveLabel)
	local data = DB_Normal_config.getDataById(1)
	local num = ItemUtil.getCacheItemNumBy(data.sex_change)
	_curHaveNumLabel = CCLabelTTF:create(num,g_sFontName,22)
		  _curHaveNumLabel:setColor(ccc3(0xff,0xf6,0x00))
		  _curHaveNumLabel:setScale(g_fElementScaleRatio)
		  _curHaveNumLabel:setPosition(ccp(curHaveLabel:getContentSize().width*g_fElementScaleRatio,0))
	curHaveSprite:addChild(_curHaveNumLabel)

	local sexCardSprite = CCSprite:create("images/base/props/bianxingka28.png")
		  sexCardSprite:setScale(g_fElementScaleRatio)
		  sexCardSprite:setPosition(ccp(_curHaveNumLabel:getContentSize().width*g_fElementScaleRatio+curHaveLabel:getContentSize().width*g_fElementScaleRatio,0))
	curHaveSprite:addChild(sexCardSprite)

	curHaveSprite:setContentSize(CCSizeMake(_curHaveNumLabel:getContentSize().width*g_fElementScaleRatio+curHaveLabel:getContentSize().width*g_fElementScaleRatio+sexCardSprite:getContentSize().width*g_fElementScaleRatio,sexCardSprite:getContentSize().height*sexCardSprite:getScale()))
	curHaveSprite:setAnchorPoint(ccp(0.5,0))
	-- curHaveSprite:setScale(g_fElementScaleRatio)
	_bg:addChild(curHaveSprite)
	curHaveSprite:setPosition(ccp(_bg:getContentSize().width*0.5,20*g_fElementScaleRatio+confirmBtn:getContentSize().height*g_fElementScaleRatio))

	_costTipLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_480"),g_sFontName,22)
	_costTipLabel:setScale(g_fElementScaleRatio)
	_costTipLabel:setAnchorPoint(ccp(0.5,0))
	_costTipLabel:setColor(ccc3(0xff,0xf6,0x00))
	_costTipLabel:setPosition(ccp(_bg:getContentSize().width*0.5,curHaveSprite:getPositionY()+curHaveSprite:getContentSize().height*curHaveSprite:getScale()+10*g_fElementScaleRatio))
	_bg:addChild(_costTipLabel)

	local htid = UserModel.getAvatarHtid()
	_headIcon = HeroUtil.getHeroIconByHTID(htid ,UserModel.getDressIdByPos(1), nil,UserModel.getVipLevel())
	_headIcon:setScale(g_fElementScaleRatio)
	_headIcon:setAnchorPoint(ccp(1,0))
	_headIcon:setPosition(ccp(_bg:getContentSize().width*0.33,_costTipLabel:getPositionY()+_costTipLabel:getContentSize().height*_costTipLabel:getScale()+15*g_fElementScaleRatio))
	_bg:addChild(_headIcon)

	local rightIcon = CCSprite:create("images/common/right.png")
		  rightIcon:setScale(g_fElementScaleRatio)
		  rightIcon:setAnchorPoint(ccp(0.5,0.5))
		  rightIcon:setPosition(ccp(_bg:getContentSize().width*0.5,_headIcon:getPositionY()+_headIcon:getContentSize().height*0.5*g_fElementScaleRatio))
	_bg:addChild(rightIcon)

	local sex = HeroModel.getSex(htid)
	local htid = getAnotherHtid(sex,htid)
	_headIconTwo = HeroUtil.getHeroIconByHTID(htid ,UserModel.getDressIdByPos(1), nil,UserModel.getVipLevel())
	_headIconTwo:setScale(g_fElementScaleRatio)
	_headIconTwo:setAnchorPoint(ccp(0,0))
	_headIconTwo:setPosition(ccp(_bg:getContentSize().width*0.66,_costTipLabel:getPositionY()+_costTipLabel:getContentSize().height*_costTipLabel:getScale()+15*g_fElementScaleRatio))
	_bg:addChild(_headIconTwo)
end