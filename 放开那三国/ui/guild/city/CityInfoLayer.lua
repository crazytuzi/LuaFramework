-- FileName: CityInfoLayer.lua
-- Author: licong
-- Date: 14-4-18
-- Purpose: 军团城池战 城池信息界面


module("CityInfoLayer", package.seeall)

require "script/utils/BaseUI"
require "script/libs/LuaCC"
require "script/ui/item/ItemUtil"
require "script/ui/guild/GuildDataCache"
require "script/ui/guild/city/CityData"
require "script/ui/guild/city/CityService"
require "script/ui/guild/GuildImpl"
require "script/ui/battlemission/MissionAfterBattle"
require "script/ui/battlemission/MissionData"
local _bgLayer     				= nil
local _backGround 				= nil
local second_bg 				= nil
local _stepTipSprite			= nil
local _stepTipLabel 			= nil
local lastFightButton 			= nil
local _butStrFont 				= nil
local isShow 					= true

local _thisCityID 				= nil
local _thisCityBaseData 		= nil
local _thisCityServiceData 		= nil
local _allTimeTab 				= nil
local _isQuick 					= nil
local isReplace 				= false
local breakButton 				= nil
local repairButton 				= nil
local _clearCDButton 			= nil
local lookButton  				= nil

local _CDTime 					= nil -- 破坏修复城池cd时间
local _clearCdCost 				= nil -- 清除cd花费
local _cdLable 					= nil -- cd倒计时lable
local tipLable 					= nil -- 消耗耐力5
function init( ... )
	_bgLayer 					= nil
	_backGround 				= nil
	second_bg 					= nil
	_thisCityID 				= nil
	_thisCityServiceData 		= nil
	_thisCityBaseData 			= nil
	_allTimeTab 				= nil
	_stepTipSprite				= nil
	_stepTipLabel 				= nil
	_isQuick 					= nil
	lastFightButton 			= nil
	_butStrFont 				= nil
	isReplace 					= false
	isShow 						= true
	breakButton 				= nil
	repairButton 				= nil
	_clearCDButton 				= nil
	_CDTime 					= nil
	_clearCdCost 				= nil
	_cdLable 					= nil
	tipLable 					= nil
	lookButton  				= nil
end

-- touch事件处理
function cardLayerTouch(eventType, x, y)
    return true
end

-- 关闭按钮回调
function closeButtonCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	-- print("closeButtonCallback")
	if(_bgLayer)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end

function onNodeEvent( event )
	if (event == "enter") then
		print("enter")
		_bgLayer:registerScriptTouchHandler(cardLayerTouch,false,-450,true)
		_bgLayer:setTouchEnabled(true)
		-- 注册删除回调
		GuildImpl.registerCallBackFun("CityInfoLayer",closeButtonCallback)
	elseif (event == "exit") then
		print("exit")
		_bgLayer:unregisterScriptTouchHandler()
		_bgLayer = nil
		_butStrFont = nil
		GuildImpl.registerCallBackFun("CityInfoLayer",nil)
	end
end

-- 初始化界面
function initCityInfoLayer( ... )

	_bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
    _bgLayer:registerScriptHandler(onNodeEvent)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,1000,1)

	-- 创建背景
	_backGround = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
    _backGround:setContentSize(CCSizeMake(597, 800))
    _backGround:setAnchorPoint(ccp(0.5,0.5))
    _backGround:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.46))
    _bgLayer:addChild(_backGround)
    -- 适配
    setAdaptNode(_backGround)

    -- 标题
    local quality = tonumber(_thisCityBaseData.cityLevel) or 1
    cityName = _thisCityBaseData.name or GetLocalizeStringBy("key_3392")
    local titlePanel = createCtiyName(quality,cityName)
	titlePanel:setAnchorPoint(ccp(0.5, 0))
	-- local posY = {0.927,0.93,0.93,0.9}
	local posY = {0.9,0.93,0.93,0.927}
	titlePanel:setPosition(ccp(_backGround:getContentSize().width*0.5, _backGround:getContentSize().height*posY[quality]))
	_backGround:addChild(titlePanel)

	-- 关闭按钮
	local menu = CCMenu:create()
    menu:setTouchPriority(-451)
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	titlePanel:addChild(menu,3)
	-- local posX = {0.88,0.99,0.97,0.99}
	-- local posY = {0.72,0.78,0.93,1}
	local posX = {0.99,0.97,0.99,0.88}
	local posY = {1,0.93,0.78,0.72}
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(1, 1))
	closeButton:setPosition(ccp(titlePanel:getContentSize().width*posX[quality], titlePanel:getContentSize().height*posY[quality]))
	closeButton:registerScriptTapHandler(closeButtonCallback)
	menu:addChild(closeButton)

	-- 二级背景
	second_bg = BaseUI.createContentBg(CCSizeMake(550,381))
 	second_bg:setAnchorPoint(ccp(0.5,0))
 	second_bg:setPosition(ccp(_backGround:getContentSize().width*0.5,340))
 	_backGround:addChild(second_bg)

 	-- 占领军团
 	local levelNum = nil
 	local guildName = nil
 	local chengfangNum = nil
 	local fightNum = nil
 	local guildFightNum = nil
 	print("_thisCityServiceData ==")
 	print_t(_thisCityServiceData)
 	if( _thisCityServiceData and not table.isEmpty(_thisCityServiceData))then
 		-- 不为空 则被军团占领
 		guildName = _thisCityServiceData.guild_name
 		levelNum = _thisCityServiceData.guild_level
 		chengfangNum = tonumber(_thisCityServiceData.city_defence)
 		fightNum = tonumber(_thisCityServiceData.city_force)
 		guildFightNum = _thisCityServiceData.fight_force or 0
 		if(tonumber(guildName) == 0 and tonumber(levelNum) == 0 and tonumber(guildFightNum) == 0 )then
 			-- 隐藏NPC 不显示
 			guildName = nil
			levelNum = nil
			guildFightNum = nil
 		end
 	else
 		if( _thisCityBaseData.defendEnemy == nil)then
 			guildName = nil
	 		levelNum = nil
 		else
 			-- 则显示npc
	 		require "db/DB_Copy_team"
	 		local npcData = DB_Copy_team.getDataById(_thisCityBaseData.defendEnemy)
	 		guildName = npcData.name
	 		levelNum = npcData.level
 		end

 		chengfangNum = tonumber(_thisCityBaseData.defaultCityDefend)
 		fightNum = 100
 	end
 	local zhanlingSp = CCSprite:create("images/guild/city/zhanling.png")
 	zhanlingSp:setAnchorPoint(ccp(1,0.5))
 	zhanlingSp:setPosition(ccp(104,second_bg:getContentSize().height-27))
 	second_bg:addChild(zhanlingSp)
 	-- bg
 	local zhanlingBg = CCScale9Sprite:create("images/guild/city/fontbg.png")
 	zhanlingBg:setContentSize(CCSizeMake(426,40))
 	zhanlingBg:setAnchorPoint(ccp(0,0.5))
 	zhanlingBg:setPosition(ccp(107,second_bg:getContentSize().height-27))
 	second_bg:addChild(zhanlingBg)
 	-- 等级
 	if(levelNum)then
	 	local lvsp = CCSprite:create("images/common/lv.png")
	 	lvsp:setAnchorPoint(ccp(0,0.5))
	 	lvsp:setPosition(ccp(12,zhanlingBg:getContentSize().height*0.5))
	 	zhanlingBg:addChild(lvsp)
	 	local lvFont = CCLabelTTF:create(levelNum,g_sFontPangWa,18)
	 	lvFont:setAnchorPoint(ccp(0,0.5))
	 	lvFont:setColor(ccc3(0xff,0xf6,0x00))
	 	lvFont:setPosition(ccp(lvsp:getPositionX()+lvsp:getContentSize().width+1,zhanlingBg:getContentSize().height*0.5))
	 	zhanlingBg:addChild(lvFont)
	end
 	-- 军团名字
 	if(guildName)then
	 	local guildFont = CCLabelTTF:create(guildName, g_sFontPangWa,21)
	 	guildFont:setAnchorPoint(ccp(0,0.5))
	 	guildFont:setColor(ccc3(0x00,0xe4,0xff))
	 	guildFont:setPosition(ccp(96,zhanlingBg:getContentSize().height*0.5))
	 	zhanlingBg:addChild(guildFont)
	 	-- 军团战斗力
	 	local zhanSp = CCSprite:create("images/common/fight_value.png")
	 	zhanSp:setAnchorPoint(ccp(0,0.5))
	 	zhanSp:setPosition(ccp(guildFont:getPositionX()+guildFont:getContentSize().width+10,zhanlingBg:getContentSize().height*0.5))
	 	zhanlingBg:addChild(zhanSp)
	 	local fightFont = CCLabelTTF:create(guildFightNum, g_sFontPangWa,18)
	 	fightFont:setAnchorPoint(ccp(0,0.5))
	 	fightFont:setColor(ccc3(0xff,0xf6,0x00))
	 	fightFont:setPosition(ccp(zhanSp:getPositionX()+zhanSp:getContentSize().width+3,zhanlingBg:getContentSize().height*0.5))
	 	zhanlingBg:addChild(fightFont)
	 else
	 	local guildFont = CCLabelTTF:create(GetLocalizeStringBy("key_3091"), g_sFontPangWa,21)
	 	guildFont:setAnchorPoint(ccp(0,0.5))
	 	guildFont:setColor(ccc3(0x00,0xe4,0xff))
	 	guildFont:setPosition(ccp(96,zhanlingBg:getContentSize().height*0.5))
	 	zhanlingBg:addChild(guildFont)
	 end

 	-- 收益
 	local shouyiSp = CCSprite:create("images/guild/city/shouyi.png")
 	shouyiSp:setAnchorPoint(ccp(1,1))
 	shouyiSp:setPosition(ccp(104,second_bg:getContentSize().height-61))
 	second_bg:addChild(shouyiSp)
 	-- 军团成员收益系数
 	-- bg
 	local shouyiBg = CCScale9Sprite:create("images/guild/city/fontbg.png")
 	shouyiBg:setContentSize(CCSizeMake(426,177))
 	shouyiBg:setAnchorPoint(ccp(0,1))
 	shouyiBg:setPosition(ccp(107,second_bg:getContentSize().height-51))
 	second_bg:addChild(shouyiBg)
 	-- 收益奖励图标
 	print("收益奖励",_thisCityBaseData.baseReward)
 	-- num1普通成员 num2军团长 num3副军团长
 	local num1,num2,num3 = CityData.getGuildPosionNum()
 	-- 军团长
 	local iconData1 = ItemUtil.getItemsDataByStr( _thisCityBaseData.baseReward )
 	for k,v in pairs(iconData1) do
		-- 真实数据 表配置基础值*系数 向下取整
		v.num = math.floor(v.num * num1)
	end
 	local rewardIcon1 = ItemUtil.createGoodsIcon(iconData1[1], -422, 1001, -423 )
 	rewardIcon1:setAnchorPoint(ccp(0,1))
 	rewardIcon1:setPosition(ccp(25,shouyiBg:getContentSize().height-7))
 	shouyiBg:addChild(rewardIcon1)
 	local name1 = CCLabelTTF:create(GetLocalizeStringBy("lic_1031"),g_sFontPangWa,18)
 	name1:setColor(ccc3(0xe4,0x00,0xff))
 	name1:setAnchorPoint(ccp(0.5,0.5))
 	name1:setPosition(ccp(rewardIcon1:getContentSize().width*0.5,-35))
 	rewardIcon1:addChild(name1)
 	-- 副军团长
 	local iconData2 = ItemUtil.getItemsDataByStr( _thisCityBaseData.baseReward )
 	for k,v in pairs(iconData2) do
		-- 真实数据 表配置基础值*系数 向下取整
		v.num = math.floor(v.num * num2)
	end
	local rewardIcon2 = ItemUtil.createGoodsIcon(iconData2[1], -422, 1001, -423 )
 	rewardIcon2:setAnchorPoint(ccp(0,1))
 	rewardIcon2:setPosition(ccp(rewardIcon1:getPositionX()+rewardIcon1:getContentSize().width+25,shouyiBg:getContentSize().height-7))
 	shouyiBg:addChild(rewardIcon2)
 	local name2 = CCLabelTTF:create(GetLocalizeStringBy("lic_1032"),g_sFontPangWa,18)
 	name2:setColor(ccc3(0x00,0xe4,0xff))
 	name2:setAnchorPoint(ccp(0.5,0.5))
 	name2:setPosition(ccp(rewardIcon1:getContentSize().width*0.5,-35))
 	rewardIcon2:addChild(name2)
 	-- 成员
 	local iconData3 = ItemUtil.getItemsDataByStr( _thisCityBaseData.baseReward )
 	for k,v in pairs(iconData3) do
		-- 真实数据 表配置基础值*系数 向下取整
		v.num = math.floor(v.num * num3)
	end
	local rewardIcon3 = ItemUtil.createGoodsIcon(iconData3[1], -422, 1001, -423 )
 	rewardIcon3:setAnchorPoint(ccp(0,1))
 	rewardIcon3:setPosition(ccp(rewardIcon2:getPositionX()+rewardIcon2:getContentSize().width+25,shouyiBg:getContentSize().height-7))
 	shouyiBg:addChild(rewardIcon3)
 	local name3 = CCLabelTTF:create(GetLocalizeStringBy("lic_1033"),g_sFontPangWa,18)
 	name3:setColor(ccc3(0x00,0xff,0x18))
 	name3:setAnchorPoint(ccp(0.5,0.5))
 	name3:setPosition(ccp(rewardIcon1:getContentSize().width*0.5,-35))
 	rewardIcon3:addChild(name3)
 	-- 收益发奖时间
	local reward_time_interval = _allTimeTab.rewardStart
 	local timeStr = CityData.getTimeStrByNum(reward_time_interval)
 	local timeFont = CCLabelTTF:create(GetLocalizeStringBy("key_2878") .. timeStr .. GetLocalizeStringBy("key_2818"),g_sFontName,18)
 	timeFont:setColor(ccc3(0x00,0xff,0x18))
 	timeFont:setAnchorPoint(ccp(0.5,0))
 	timeFont:setPosition(ccp(shouyiBg:getContentSize().width*0.5,7))
 	shouyiBg:addChild(timeFont)


 	-- 占领效果
 	local xiaoguoSp = CCSprite:create("images/guild/city/xiaoguo.png")
 	xiaoguoSp:setAnchorPoint(ccp(1,0.5))
 	xiaoguoSp:setPosition(ccp(104,second_bg:getContentSize().height-253))
 	second_bg:addChild(xiaoguoSp)
 	-- bg
 	local xiaoguoBg = CCScale9Sprite:create("images/guild/city/fontbg.png")
 	xiaoguoBg:setContentSize(CCSizeMake(426,40))
 	xiaoguoBg:setAnchorPoint(ccp(0,0.5))
 	xiaoguoBg:setPosition(ccp(107,second_bg:getContentSize().height-253))
 	second_bg:addChild(xiaoguoBg)
 	-- 加成类型
 	local font = CCLabelTTF:create(GetLocalizeStringBy("key_3080"),g_sFontName,18)
 	font:setAnchorPoint(ccp(0,0.5))
 	font:setColor(ccc3(0xff,0xff,0xff))
 	font:setPosition(ccp(10,xiaoguoBg:getContentSize().height*0.5))
 	xiaoguoBg:addChild(font)
 	local nameStr,effectNum = CityData.getEffectDataByCityId(_thisCityID)
 	local nameFont = CCLabelTTF:create(nameStr,g_sFontName,18)
 	nameFont:setAnchorPoint(ccp(0,0.5))
 	nameFont:setColor(ccc3(0x00,0xe4,0xff))
 	nameFont:setPosition(ccp(font:getPositionX()+font:getContentSize().width,xiaoguoBg:getContentSize().height*0.5))
 	xiaoguoBg:addChild(nameFont)
 	-- 获得1
 	local font1 = CCLabelTTF:create(GetLocalizeStringBy("key_1071"),g_sFontName,18)
 	font1:setColor(ccc3(0xff,0xff,0xff))
 	font1:setAnchorPoint(ccp(0,0.5))
 	font1:setPosition(ccp(nameFont:getPositionX()+nameFont:getContentSize().width,xiaoguoBg:getContentSize().height*0.5))
 	xiaoguoBg:addChild(font1)
 	local iconsp1 = CCSprite:create("images/common/coin.png")
 	iconsp1:setAnchorPoint(ccp(0,0.5))
 	iconsp1:setPosition(ccp(font1:getPositionX()+font1:getContentSize().width,xiaoguoBg:getContentSize().height*0.5))
 	xiaoguoBg:addChild(iconsp1)
 	-- 加成值
 	local num1 = string.format("%.1f", effectNum/100)
 	if( tonumber(num1) - math.floor(tonumber(num1)) == 0 )then
 		num1 = math.floor(tonumber(num1))
 	end
 	local numFont1 = CCLabelTTF:create(GetLocalizeStringBy("key_2822") .. num1 .. "%", g_sFontName, 18)
 	numFont1:setAnchorPoint(ccp(0,0.5))
 	numFont1:setColor(ccc3(0x00,0xff,0x18))
 	numFont1:setPosition(ccp(iconsp1:getPositionX()+iconsp1:getContentSize().width,xiaoguoBg:getContentSize().height*0.5))
 	xiaoguoBg:addChild(numFont1)
 	-- 句号
 	-- local font3 = CCLabelTTF:create("。", g_sFontName, 18)
 	-- font3:setAnchorPoint(ccp(0,0.5))
 	-- font3:setPosition(ccp(numFont1:getPositionX()+numFont1:getContentSize().width,xiaoguoBg:getContentSize().height*0.5))
 	-- xiaoguoBg:addChild(font3)


 	-- 城防
 	local chengFangSp = CCSprite:create("images/guild/city/chengfang.png")
 	chengFangSp:setAnchorPoint(ccp(1,0.5))
 	chengFangSp:setPosition(ccp(104,second_bg:getContentSize().height-301))
 	second_bg:addChild(chengFangSp)
 	-- bg
 	local chengfangBg = CCScale9Sprite:create("images/guild/city/fontbg.png")
 	chengfangBg:setContentSize(CCSizeMake(426,40))
 	chengfangBg:setAnchorPoint(ccp(0,0.5))
 	chengfangBg:setPosition(ccp(107,second_bg:getContentSize().height-301))
 	second_bg:addChild(chengfangBg)
 	-- 城防值
 	local chengfangNumStr = chengfangNum or GetLocalizeStringBy("key_3392")
 	local chengfangFont = CCLabelTTF:create(chengfangNumStr, g_sFontName, 18)
 	chengfangFont:setAnchorPoint(ccp(0,0.5))
 	chengfangFont:setPosition(ccp(10,chengfangBg:getContentSize().height*0.5))
 	chengfangBg:addChild(chengfangFont)
 	if( chengfangNum < tonumber(_thisCityBaseData.defaultCityDefend))then
 		chengfangFont:setColor(ccc3(0xff,0x00,0x00))
 	else
 		chengfangFont:setColor(ccc3(0x00,0xff,0x18))
 	end
 	local str1 = GetLocalizeStringBy("key_3156")
 	local font1 = CCLabelTTF:create(str1, g_sFontName, 18)
 	font1:setAnchorPoint(ccp(0,0.5))
 	font1:setColor(ccc3(0xff,0xff,0xff))
 	font1:setPosition(ccp(chengfangFont:getPositionX()+chengfangFont:getContentSize().width+2,chengfangBg:getContentSize().height*0.5))
 	chengfangBg:addChild(font1)
 	-- 下降值
 	local downNum = _thisCityBaseData.fallCityDefend or GetLocalizeStringBy("key_3392")
 	local font2 = CCLabelTTF:create(downNum, g_sFontName, 18)
 	font2:setAnchorPoint(ccp(0,0.5))
 	font2:setColor(ccc3(0xff,0x00,0x00))
 	font2:setPosition(ccp(font1:getPositionX()+font1:getContentSize().width,chengfangBg:getContentSize().height*0.5))
 	chengfangBg:addChild(font2)
 	local font3 = CCLabelTTF:create(")", g_sFontName, 18)
 	font3:setAnchorPoint(ccp(0,0.5))
 	font3:setColor(ccc3(0xff,0xff,0xff))
 	font3:setPosition(ccp(font2:getPositionX()+font2:getContentSize().width,chengfangBg:getContentSize().height*0.5))
 	chengfangBg:addChild(font3)


 	-- 战斗力
 	local fightscoreSp = CCSprite:create("images/common/fight_value02.png")
 	fightscoreSp:setAnchorPoint(ccp(1,0.5))
 	fightscoreSp:setPosition(ccp(104,second_bg:getContentSize().height-354))
 	second_bg:addChild(fightscoreSp)
 	-- bg
 	local fightscroeBg = CCScale9Sprite:create("images/guild/city/fontbg.png")
 	fightscroeBg:setContentSize(CCSizeMake(426,40))
 	fightscroeBg:setAnchorPoint(ccp(0,0.5))
 	fightscroeBg:setPosition(ccp(107,second_bg:getContentSize().height-354))
 	second_bg:addChild(fightscroeBg)
 	-- 城池战斗力
 	local fightNumStr = fightNum
 	local fightFont = CCLabelTTF:create(fightNum .. "%", g_sFontName, 18)
 	fightFont:setAnchorPoint(ccp(0,0.5))
 	fightFont:setPosition(ccp(10,fightscroeBg:getContentSize().height*0.5))
 	fightscroeBg:addChild(fightFont)
 	if( fightNum < 100 )then
 		fightFont:setColor(ccc3(0xff,0x00,0x00))
 	else
 		fightFont:setColor(ccc3(0x00,0xff,0x18))
 	end
 	local str1 = GetLocalizeStringBy("key_2754")
 	local font1 = CCLabelTTF:create(str1, g_sFontName, 18)
 	font1:setAnchorPoint(ccp(0,0.5))
 	font1:setColor(ccc3(0xff,0xff,0xff))
 	font1:setPosition(ccp(fightFont:getPositionX()+fightFont:getContentSize().width+2,fightscroeBg:getContentSize().height*0.5))
 	fightscroeBg:addChild(font1)


 	-- 报名攻打按钮
 	local curTime = BTUtil:getSvrTimeInterval()
 	local isHave = CityData.getIsSignupById(_thisCityID)
 	if(isHave)then
 		createSignupStateUi(3)
 	else
	 	if( tonumber(curTime) < tonumber(_allTimeTab.signupEnd) )then
	 		createSignupStateUi(1)
	 	else
	 		createSignupStateUi(2)
	 	end
	end

 	-- 剑花
 	local sprite1 = CCSprite:create("images/guild/city/jian.png")
 	sprite1:setAnchorPoint(ccp(0,0.5))
 	sprite1:setPosition(ccp(223,290))
 	_backGround:addChild(sprite1)
 	sprite1:setScaleX(sprite1:getScaleX() * -1)
	local sprite2 = CCSprite:create("images/guild/city/jian.png")
 	sprite2:setAnchorPoint(ccp(0,0.5))
 	sprite2:setPosition(ccp(373,290))
 	_backGround:addChild(sprite2)

 	-- 时间提示
 	-- 报名截止时间
	local star_time_interVal = _allTimeTab.signupStart
	local startStr = CityData.getTimeStrByNum(star_time_interVal)
	local end_time_interval = _allTimeTab.signupEnd
 	local endStr = CityData.getTimeStrByNum(end_time_interval)
 	local str = GetLocalizeStringBy("key_1943") .. startStr .. GetLocalizeStringBy("key_2291") .. endStr
 	local timeOutFont = CCLabelTTF:create(str, g_sFontPangWa, 21)
 	timeOutFont:setAnchorPoint(ccp(0.5,0))
 	timeOutFont:setColor(ccc3(0x78,0x25,0x00))
 	timeOutFont:setPosition(ccp(_backGround:getContentSize().width*0.5,197))
 	_backGround:addChild(timeOutFont)

 	-- 开战时间
 	local star_time = tonumber(_allTimeTab.arrAttack[1][1]) - tonumber(_allTimeTab.prepare)
	local startStr = CityData.getTimeStrByNum(star_time)
	local str = GetLocalizeStringBy("key_1278") .. startStr
 	local timeFont = CCLabelTTF:create(str, g_sFontPangWa, 21)
 	timeFont:setAnchorPoint(ccp(0.5,0))
 	timeFont:setColor(ccc3(0x78,0x25,0x00))
 	timeFont:setPosition(ccp(_backGround:getContentSize().width*0.5,167))
 	_backGround:addChild(timeFont)

 	showTimeStepTip()

 	-- 修复和破坏按钮不显示
 	isShowBreakAndRepairButton()

 	-- 查看报名按钮
 	local menuBar = CCMenu:create()
    menuBar:setTouchPriority(-451)
	menuBar:setPosition(ccp(0, 0))
	menuBar:setAnchorPoint(ccp(0, 0))
	_backGround:addChild(menuBar,3)
 	lookButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn_purple2_n.png","images/common/btn/btn_purple2_h.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_1240"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	lookButton:setAnchorPoint(ccp(0.5 , 0))
    lookButton:registerScriptTapHandler(lookButtonAction)
	menuBar:addChild(lookButton)

	-- 上轮战报按钮 进入战场界面
	local zhunbeiTime = tonumber(_allTimeTab.arrAttack[1][1]) - tonumber(_allTimeTab.prepare)
	local curTime = BTUtil:getSvrTimeInterval()
	local btnStr = nil
	if(curTime >= zhunbeiTime and curTime <  tonumber(_allTimeTab.arrAttack[#_allTimeTab.arrAttack][1]) )then
		btnStr = GetLocalizeStringBy("key_1761")
		isReplace = true
	else
		btnStr = GetLocalizeStringBy("key_2063")
		isReplace = false
	end
	local normalSprite  = CCScale9Sprite:create("images/common/btn/btn_purple2_n.png")
	normalSprite:setContentSize(CCSizeMake(200,73))
    local selectSprite  = CCScale9Sprite:create("images/common/btn/btn_purple2_h.png")
    selectSprite:setContentSize(CCSizeMake(200,73))
	lastFightButton = CCMenuItemSprite:create(normalSprite,selectSprite)
	lastFightButton:setAnchorPoint(ccp(0.5 , 0))
    lastFightButton:registerScriptTapHandler(lastFightAction)
	menuBar:addChild(lastFightButton)
	-- 上轮战报上的按钮文字
	_butStrFont = CCRenderLabel:create(btnStr, g_sFontPangWa,35,1, ccc3(0x00, 0x00, 0x00), type_stroke)
	_butStrFont:setColor(ccc3(0xfe, 0xdb, 0x1c))
	_butStrFont:setAnchorPoint(ccp(0.5,0.5))
	_butStrFont:setPosition(ccp(lastFightButton:getContentSize().width*0.5,lastFightButton:getContentSize().height*0.5))
	lastFightButton:addChild(_butStrFont)

	-- 破坏修复 清除cd按钮
    local normalSprite  = CCScale9Sprite:create("images/common/btn/btn_blue2_n.png")
	normalSprite:setContentSize(CCSizeMake(200,73))
    local selectSprite  = CCScale9Sprite:create("images/common/btn/btn_blue2_h.png")
    selectSprite:setContentSize(CCSizeMake(200,73))
	_clearCDButton = CCMenuItemSprite:create(normalSprite,selectSprite)
	_clearCDButton:setAnchorPoint(ccp(0.5 , 0))
	_clearCDButton:setPosition(ccp(_backGround:getContentSize().width*0.5,60))
	_clearCDButton:registerScriptTapHandler(clearCDButtonAction)
	menuBar:addChild(_clearCDButton)
	_clearCDButton:setVisible(false)

	-- 清除按钮描述
 	local clearCDLabel = CCRenderLabel:create(GetLocalizeStringBy("lic_1279"), g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    clearCDLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
    -- 金币
    local goldIcon = CCSprite:create("images/common/gold.png")
    -- 金币数量
    local clearGoldLabel = CCLabelTTF:create(tostring(_clearCdCost), g_sFontPangWa, 24)
    clearGoldLabel:setColor(ccc3(0x00, 0xff, 0x18))

    local clearDesNode = BaseUI.createHorizontalNode({clearCDLabel, goldIcon, clearGoldLabel})
    clearDesNode:setAnchorPoint(ccp(0.5, 0.5))
    clearDesNode:setPosition(ccpsprite(0.5, 0.5, _clearCDButton))
    _clearCDButton:addChild(clearDesNode)

	-- 按钮类型
	local guildTaskType = getRuinOrMendStatus()
	if( guildTaskType == 2)then
		-- 破坏城防按钮
		breakButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn_purple2_n.png","images/common/btn/btn_purple2_h.png",CCSizeMake(200, 73),GetLocalizeStringBy("lic_1072"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		breakButton:setAnchorPoint(ccp(0.5 , 0))
	    breakButton:registerScriptTapHandler(breakButtonAction)
		menuBar:addChild(breakButton)
		-- 消耗体力5
		tipLable = CCRenderLabel:create(GetLocalizeStringBy("lic_1073"), g_sFontName,18,1, ccc3(0x00, 0x00, 0x00), type_stroke)
		tipLable:setColor(ccc3(0x00,0xff,0x18))
		tipLable:setAnchorPoint(ccp(0.5,1))
		tipLable:setPosition(ccp(_backGround:getContentSize().width*0.5,63))
		_backGround:addChild(tipLable)
		if(isShow==false)then
			breakButton:setVisible(false)
			tipLable:setVisible(false)
			lookButton:setPosition(ccp(_backGround:getContentSize().width*0.3,60))
			lastFightButton:setPosition(ccp(_backGround:getContentSize().width*0.7,60))
		else
			tipLable:setVisible(true)
			-- 按钮坐标
			lookButton:setPosition(ccp(_backGround:getContentSize().width*0.18,60))
			breakButton:setPosition(ccp(_backGround:getContentSize().width*0.5,60))
			lastFightButton:setPosition(ccp(_backGround:getContentSize().width*0.82,60))
		end
		-- 破坏城防cd时间
		_cdLable = CCLabelTTF:create("00:00:00", g_sFontName,24)
		_cdLable:setColor(ccc3(0x0e,0x79,0x00))
		_cdLable:setAnchorPoint(ccp(0.5,1))
		_cdLable:setPosition(ccp(_backGround:getContentSize().width*0.5,42))
		_backGround:addChild(_cdLable)
		_cdLable:setVisible(false)
		local lastTime = getBreakCDTime()
		print("lastTime==",lastTime)
		if(lastTime ~= 0)then
			local disTime = tonumber(lastTime) + _CDTime
			if( TimeUtil.getSvrTimeByOffset() < disTime )then
				-- 需要倒计时
				local function showTimeDown( ... )
					if(disTime - TimeUtil.getSvrTimeByOffset() < 0)then
						_backGround:stopAllActions()
						_cdLable:setVisible(false)
						_clearCDButton:setVisible(false)
						breakButton:setVisible(true)
						return
					end
					_cdLable:setString(TimeUtil.getTimeString(disTime - TimeUtil.getSvrTimeByOffset()))
					local actionArray = CCArray:create()
					actionArray:addObject(CCDelayTime:create(1))
					actionArray:addObject(CCCallFunc:create(showTimeDown))
					_backGround:runAction(CCSequence:create(actionArray))
				end
				_cdLable:setVisible(true)
				-- 清除冷却按钮
				if(isShow == true)then
					_clearCDButton:setVisible(true)
					breakButton:setVisible(false)
				end
				showTimeDown()
			end
		end
	elseif( guildTaskType == 1)then
		-- 修复城防按钮
		repairButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn_purple2_n.png","images/common/btn/btn_purple2_h.png",CCSizeMake(200, 73),GetLocalizeStringBy("lic_1077"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		repairButton:setAnchorPoint(ccp(0.5 , 0))
	    repairButton:registerScriptTapHandler(repairButtonAction)
		menuBar:addChild(repairButton)
		-- 消耗体力5
		tipLable = CCRenderLabel:create(GetLocalizeStringBy("lic_1073"), g_sFontName,18,1, ccc3(0x00, 0x00, 0x00), type_stroke)
		tipLable:setColor(ccc3(0x00,0xff,0x18))
		tipLable:setAnchorPoint(ccp(0.5,1))
		tipLable:setPosition(ccp(_backGround:getContentSize().width*0.5,63))
		_backGround:addChild(tipLable)
		if(isShow==false)then
			repairButton:setVisible(false)
			tipLable:setVisible(false)
			lookButton:setPosition(ccp(_backGround:getContentSize().width*0.3,60))
			lastFightButton:setPosition(ccp(_backGround:getContentSize().width*0.7,60))
		else
			tipLable:setVisible(true)
			lookButton:setPosition(ccp(_backGround:getContentSize().width*0.18,60))
			repairButton:setPosition(ccp(_backGround:getContentSize().width*0.5,60))
			lastFightButton:setPosition(ccp(_backGround:getContentSize().width*0.82,60))
		end
		-- 修复城防cd时间
		_cdLable = CCLabelTTF:create("00:00:00", g_sFontName,24)
		_cdLable:setColor(ccc3(0x0e,0x79,0x00))
		_cdLable:setAnchorPoint(ccp(0.5,1))
		_cdLable:setPosition(ccp(_backGround:getContentSize().width*0.5,42))
		_backGround:addChild(_cdLable)
		_cdLable:setVisible(false)
		local lastTime = getRepairCDTime()
		print("lastTime==",lastTime)
		if(lastTime ~= 0)then
			local disTime = tonumber(lastTime) + _CDTime
			if( TimeUtil.getSvrTimeByOffset() < disTime )then
				-- 需要倒计时
				local function showTimeDown( ... )
					if(disTime - TimeUtil.getSvrTimeByOffset() < 0)then
						_backGround:stopAllActions()
						_cdLable:setVisible(false)
						_clearCDButton:setVisible(false)
						repairButton:setVisible(true)
						return
					end
					_cdLable:setString(TimeUtil.getTimeString(disTime - TimeUtil.getSvrTimeByOffset()))
					local actionArray = CCArray:create()
					actionArray:addObject(CCDelayTime:create(1))
					actionArray:addObject(CCCallFunc:create(showTimeDown))
					_backGround:runAction(CCSequence:create(actionArray))
				end
				_cdLable:setVisible(true)
				-- 清除冷却按钮
				if(isShow == true)then
					_clearCDButton:setVisible(true)
					repairButton:setVisible(false)
				end
				showTimeDown()
			end
		end
	else
		lookButton:setPosition(ccp(_backGround:getContentSize().width*0.3,60))
		lastFightButton:setPosition(ccp(_backGround:getContentSize().width*0.7,60))
	end

	-- 快速入口用 打开战报按钮
	if(_isQuick)then
		lastFightAction()
	end
end

-- 创建城池名称、
function createCtiyName( quality, name )
	local sprite = CCSprite:create("images/guild/city/title_" .. quality .. ".png")
	local titleLabel = CCRenderLabel:create(name, g_sFontPangWa, 33, 1, ccc3(0,0,0), type_stroke)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	-- local posY = {0.37,0.53,0.6,0.7}
	local posY = {0.7,0.6,0.53,0.37}
	titleLabel:setPosition(ccp(sprite:getContentSize().width*0.5, sprite:getContentSize().height*posY[tonumber(quality)]))
	sprite:addChild(titleLabel)
	return sprite
end

-- 创建三种状态ui 1.报名按钮 2.报名已结束 3.已报名
function createSignupStateUi( state_type )

	if(_backGround:getChildByTag(1010) ~= nil)then
		_backGround:removeChildByTag(1010,true)
	end

	if( tonumber(state_type) == 1 )then
		-- 报名攻打按钮
	 	local menu = CCMenu:create()
	 	menu:setPosition(ccp(0,0))
	 	_backGround:addChild(menu,1,1010)
	 	menu:setTouchPriority(-451)
	 	local baomingButton = CCMenuItemImage:create("images/guild/city/baoming_n.png","images/guild/city/baoming_h.png")
	 	baomingButton:setAnchorPoint(ccp(0.5,0.5))
	 	baomingButton:setPosition(ccp(_backGround:getContentSize().width*0.5,290))
	 	menu:addChild(baomingButton)
	 	baomingButton:registerScriptTapHandler(baomingButtonAction)
	elseif(tonumber(state_type) == 2)then
		-- 报名已结束
		local sprite = CCSprite:create("images/guild/city/jieshu.png")
		sprite:setAnchorPoint(ccp(0.5,0.5))
		sprite:setPosition(ccp(_backGround:getContentSize().width*0.5,290))
		_backGround:addChild(sprite,1,1010)
	elseif(tonumber(state_type) == 3)then
		-- 已报名
		local sprite = CCSprite:create("images/guild/city/yibaoming.png")
		sprite:setAnchorPoint(ccp(0.5,0.5))
		sprite:setPosition(ccp(_backGround:getContentSize().width*0.5,290))
		_backGround:addChild(sprite,1,1010)
	else
		print("不知道你想咋的。。")
	end
end

-- 城池战 阶段提示
function showTimeStepTip()
	local timesInfo = CityData.getTimeTable()

	if(_stepTipSprite == nil)then
		-- 背景
		_stepTipSprite = CCScale9Sprite:create("images/guild/city/lvdi.png")
		_stepTipSprite:setAnchorPoint(ccp(0.5, 0.5))
		_stepTipSprite:setPosition(ccp(_backGround:getContentSize().width*0.5, 145))
		_backGround:addChild(_stepTipSprite, 19)

		-- 文字
		_stepTipLabel = CCLabelTTF:create( "00:00:00", g_sFontPangWa,23)
		_stepTipLabel:setAnchorPoint(ccp(0.5, 0.5))
		_stepTipLabel:setColor(ccc3(0x0e,0x79,0x00))
		_stepTipLabel:setPosition(ccp(_stepTipSprite:getContentSize().width*0.5, _stepTipSprite:getContentSize().height*0.5))
		_stepTipSprite:addChild(_stepTipLabel)
	end

	-- 提示信息
	if( TimeUtil.getSvrTimeByOffset() >= timesInfo.signupStart and TimeUtil.getSvrTimeByOffset() <= timesInfo.signupEnd )then
		-- 报名阶段
		_stepTipLabel:setString(GetLocalizeStringBy("key_1548") .. TimeUtil.getTimeString(timesInfo.signupEnd - TimeUtil.getSvrTimeByOffset()))

	elseif(TimeUtil.getSvrTimeByOffset() >= timesInfo.signupEnd and TimeUtil.getSvrTimeByOffset() < tonumber(timesInfo.arrAttack[1][1]) - timesInfo.prepare)then
		-- 间歇期间
		_stepTipLabel:setString(GetLocalizeStringBy("key_2192") .. CityData.getTimeStrByNum(tonumber(timesInfo.arrAttack[1][1]) ) .. GetLocalizeStringBy("key_2813") )

	elseif(TimeUtil.getSvrTimeByOffset() >= tonumber(timesInfo.arrAttack[1][1]) - timesInfo.prepare and TimeUtil.getSvrTimeByOffset() < tonumber(timesInfo.arrAttack[1][1]) )then
		-- 第一场准备时间
		_stepTipLabel:setString(GetLocalizeStringBy("key_1306") .. TimeUtil.getTimeString(tonumber(timesInfo.arrAttack[1][1]) - TimeUtil.getSvrTimeByOffset()))

		-- 准备时间 上轮战报 改成 进入战场
		if(isReplace == false)then
			isReplace = true
			if(_butStrFont ~= nil)then
				_butStrFont:removeFromParentAndCleanup(true)
				_butStrFont = nil
				_butStrFont = CCRenderLabel:create(GetLocalizeStringBy("key_1761"), g_sFontPangWa,35,1, ccc3(0x00, 0x00, 0x00), type_stroke)
				_butStrFont:setColor(ccc3(0xfe, 0xdb, 0x1c))
				_butStrFont:setAnchorPoint(ccp(0.5,0.5))
				_butStrFont:setPosition(ccp(lastFightButton:getContentSize().width*0.5,lastFightButton:getContentSize().height*0.5))
				lastFightButton:addChild(_butStrFont)
			end
		end
	elseif(TimeUtil.getSvrTimeByOffset() >= tonumber(timesInfo.arrAttack[1][1]) and TimeUtil.getSvrTimeByOffset() < tonumber(timesInfo.arrAttack[1][2]) )then
		-- 第一场 战斗中
		_stepTipLabel:setString(GetLocalizeStringBy("key_3120"))

	elseif(TimeUtil.getSvrTimeByOffset() >= tonumber(timesInfo.arrAttack[2][1]) - timesInfo.prepare and TimeUtil.getSvrTimeByOffset() < tonumber(timesInfo.arrAttack[2][1]) )then
		-- 第二场准备时间
		_stepTipLabel:setString(GetLocalizeStringBy("key_1631") .. TimeUtil.getTimeString(tonumber(timesInfo.arrAttack[2][1]) - TimeUtil.getSvrTimeByOffset()))
	elseif(TimeUtil.getSvrTimeByOffset() >= tonumber(timesInfo.arrAttack[2][1]) and TimeUtil.getSvrTimeByOffset() < tonumber(timesInfo.arrAttack[2][2]) )then
		-- 第二场 战斗中
		_stepTipLabel:setString(GetLocalizeStringBy("key_2633"))
	elseif(TimeUtil.getSvrTimeByOffset() >= tonumber(timesInfo.arrAttack[2][2]) and TimeUtil.getSvrTimeByOffset() < tonumber(timesInfo.rewardStart) )then
		-- 开始发奖 倒计时
		_stepTipLabel:setString(GetLocalizeStringBy("key_2596") .. TimeUtil.getTimeString(timesInfo.rewardStart - TimeUtil.getSvrTimeByOffset()))
		-- 战斗结束 进入战场 改成 上轮战报
		if(isReplace == true)then
			isReplace = false
			if(_butStrFont ~= nil)then
				_butStrFont:removeFromParentAndCleanup(true)
				_butStrFont = nil
				_butStrFont = CCRenderLabel:create(GetLocalizeStringBy("key_2063"), g_sFontPangWa,35,1, ccc3(0x00, 0x00, 0x00), type_stroke)
				_butStrFont:setColor(ccc3(0xfe, 0xdb, 0x1c))
				_butStrFont:setAnchorPoint(ccp(0.5,0.5))
				_butStrFont:setPosition(ccp(lastFightButton:getContentSize().width*0.5,lastFightButton:getContentSize().height*0.5))
				lastFightButton:addChild(_butStrFont)
			end
		end

	else
		print(GetLocalizeStringBy("key_2013"),TimeUtil.getSvrTimeByOffset())
		if(_stepTipSprite)then
			_stepTipSprite:removeFromParentAndCleanup(true)
			_stepTipSprite = nil
		end
		return
	end

	local actionArray = CCArray:create()
	actionArray:addObject(CCDelayTime:create(1))
	actionArray:addObject(CCCallFunc:create(showTimeStepTip))
	_stepTipSprite:runAction(CCSequence:create(actionArray))
end

-- 关于破坏修复按钮显示问题 城池战开战前10分钟到城池战结束后10分钟 不能破坏城池也不能修复
function isShowBreakAndRepairButton( ... )
	local guildTaskType = getRuinOrMendStatus()
	if(guildTaskType ~= 0)then
		local timesInfo = CityData.getTimeTable()
		-- 战前十分钟到第一场期间
		if(TimeUtil.getSvrTimeByOffset() >= tonumber(timesInfo.arrAttack[1][1]) - timesInfo.prepare - 600 and TimeUtil.getSvrTimeByOffset() <= tonumber(timesInfo.arrAttack[2][2]) + 600 )then
			print(tonumber(timesInfo.arrAttack[1][1]) - timesInfo.prepare - 600)
			print(TimeUtil.getSvrTimeByOffset())
			print(tonumber(timesInfo.arrAttack[2][2]) + 600)

			isShow = false
			if(breakButton~=nil)then
				breakButton:setVisible(false)
			end

			if(repairButton~=nil)then
				repairButton:setVisible(false)
			end

			if(tipLable~=nil)then
				tipLable:setVisible(false)
			end
			if(lookButton ~= nil)then
				lookButton:setPosition(ccp(_backGround:getContentSize().width*0.3,60))
			end
			if(lastFightButton ~= nil)then
				lastFightButton:setPosition(ccp(_backGround:getContentSize().width*0.7,60))
			end
		end

		if( TimeUtil.getSvrTimeByOffset() > tonumber(timesInfo.arrAttack[2][2]) + 600 )then
			-- print("11111111111111111111111111111111111111")
			-- print(TimeUtil.getSvrTimeByOffset() , (tonumber(timesInfo.arrAttack[2][2]) + 600) )
			isShow = true

			if(lookButton ~= nil)then
				lookButton:setPosition(ccp(_backGround:getContentSize().width*0.18,60))
			end
			if(lastFightButton ~= nil)then
				lastFightButton:setPosition(ccp(_backGround:getContentSize().width*0.82,60))
			end
			if(breakButton~=nil)then
				local lastTime = getBreakCDTime()
				local disTime = tonumber(lastTime) + _CDTime
				if( TimeUtil.getSvrTimeByOffset() < disTime )then
					_clearCDButton:setVisible(true)
				else
					breakButton:setVisible(true)
				end
			end

			if(repairButton~=nil)then
				local lastTime = getRepairCDTime()
				local disTime = tonumber(lastTime) + _CDTime
				if( TimeUtil.getSvrTimeByOffset() < disTime )then
					_clearCDButton:setVisible(true)
				else
					repairButton:setVisible(true)
				end
			end

			if(tipLable~=nil)then
				tipLable:setVisible(true)
			end
		end
	else
		if(lookButton ~= nil)then
			lookButton:setPosition(ccp(_backGround:getContentSize().width*0.3,60))
		end
		if(lastFightButton ~= nil)then
			lastFightButton:setPosition(ccp(_backGround:getContentSize().width*0.7,60))
		end
	end

	local actionArray = CCArray:create()
	actionArray:addObject(CCDelayTime:create(1))
	actionArray:addObject(CCCallFunc:create(isShowBreakAndRepairButton))
	_backGround:runAction(CCSequence:create(actionArray))
end


-- 刷新界面
function refreshCityStateUi( ... )
	if(_bgLayer)then
		local signCity = CityData.getSignCity()
		if( not table.isEmpty(signCity)) then
			for k, cityid in pairs(signCity) do
				if( tonumber(cityid) == tonumber(_thisCityID))then
					-- 已报名状态
					createSignupStateUi(3)
					break
				end
			end
		end
	end
end

-- 获得占领军团的信息
function getOccupyInfo( ... )
	return _thisCityServiceData
end

-- 报名action
function baomingButtonAction( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	local typeNum = CityData.getIsOverApplyTime()
	-- 报名时间没开始 拦截
	if(typeNum == 1)then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("key_1407"))
		return
	end
	-- 时间已截止 拦截
	if(typeNum == 2)then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("key_2654"))
		return
	end
	-- 拦截普通成员
	if(CityData.getMyPositionType() == 0)then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("key_3358"))
		return
	end
	-- 不够级别拦截
	if(GuildDataCache.getGuildHallLevel() < tonumber(_thisCityBaseData.needLegionLevel) )then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(_thisCityBaseData.needLegionLevel .. GetLocalizeStringBy("key_3077"))
		return
	end
	-- 已报名了 拦截
	local isHave = CityData.getIsSignupById( _thisCityID )
	if(isHave)then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("key_1314"))
		return
	end
	-- 报名城池数量已达上限
 	local num = CityData.getNumForSignupCity()
 	if(num <= 0)then
 		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("key_1104"))
		return
 	end
 	-- 城市的占领者不能报名
 	local zhanlingGuildId = tonumber(_thisCityServiceData.guild_id)
 	local data = GuildDataCache.getMineSigleGuildInfo()
 	local myGuildId = tonumber(data.guild_id)
 	if(zhanlingGuildId == myGuildId)then
 		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("key_2359"))
		return
 	end
	require "script/ui/guild/city/ApplyCityLayer"
	ApplyCityLayer.showApplyCityLayer( _thisCityID )
end

-- 查看报名action
function lookButtonAction( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	require "script/ui/guild/city/LookApplyLayer"
	LookApplyLayer.showLookApplyLayer(_thisCityID)
end

-- 上轮战报
function lastFightAction( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	require "script/ui/guild/city/BattlefieldReportLayer"
	BattlefieldReportLayer.show(_thisCityID)
end

function doMatchBattleOverDelegate()
	-- body
end

--破坏城防网络回调
function breakCallBack( cbFlag, dictData, bRet )
	-- body
	if(dictData.err~="ok")then
		return
	end
	if (dictData.ret.ret ~= "ok") then
        return
    end
    UserModel.changeEnergyValue(-5)
    if(_bgLayer)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
	require "script/battle/BattleLayer"
	print("hehehehehe",cityName)
	BattleLayer.showBattleWithString(dictData.ret.atk.fightRet, doMatchBattleOverDelegate, MissionAfterBattle.createAfterBattleLayer(dictData.ret,true,dobattleCallback,true,cityName), "ducheng.jpg")
end

-- 破坏城防
function breakButtonAction( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 检查CD时间
	local lastTime = getBreakCDTime()
	if(lastTime ~= nil)then
		if( TimeUtil.getSvrTimeByOffset() < tonumber(lastTime) + _CDTime )then
			-- cd时间未到
			require "script/ui/tip/AnimationTip"
			AnimationTip.showTip(GetLocalizeStringBy("lic_1122"))
			return
		end
	end
	-- 记录本次打的时间
	-- saveBreakCDTime( TimeUtil.getSvrTimeByOffset() )
	-- 检查体力是否足够
	require "script/model/user/UserModel"
	if( 5 > UserModel.getEnergyValue() )then
		require "script/ui/item/EnergyAlertTip"
        EnergyAlertTip.showTip()
		return
	end
	local args =CCArray:create()
    args:addObject(CCInteger:create(_thisCityID))
    RequestCenter.destoryDefence(breakCallBack, args)
end

-- 修复城防网络回调
function repairCallBack( cbFlag, dictData, bRet )
	-- body
	if(dictData.err~="ok")then
		return
	end
	if (dictData.ret.ret ~= "ok") then
        return
    end
    UserModel.changeEnergyValue(-5)
    if(_bgLayer)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
	require "script/battle/BattleLayer"
	BattleLayer.showBattleWithString(dictData.ret.atk.fightRet, doMatchBattleOverDelegate, MissionAfterBattle.createAfterBattleLayer(dictData.ret,true,dobattleCallback,false,cityName), "ducheng.jpg")
end

-- 修复城防
function repairButtonAction( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 检查CD时间
	local lastTime = getRepairCDTime()
	if(lastTime ~= nil)then
		if( TimeUtil.getSvrTimeByOffset() < tonumber(lastTime) + _CDTime )then
			-- cd时间未到
			require "script/ui/tip/AnimationTip"
			AnimationTip.showTip(GetLocalizeStringBy("lic_1123"))
			return
		end
	end
	-- 记录本次打的时间
	-- saveRepairCDTime( TimeUtil.getSvrTimeByOffset() )
	-- 检查体力是否足够
	require "script/model/user/UserModel"
	if( 5 > UserModel.getEnergyValue() )then
		require "script/ui/item/EnergyAlertTip"
        EnergyAlertTip.showTip()
		return
	end
	local args =CCArray:create()
    args:addObject(CCInteger:create(_thisCityID))
    RequestCenter.repairDefence(repairCallBack, args)
end

-- 清除破坏 修复城防cd回调
function clearCDButtonAction( tag, itemBtn )
	-- 金币不足
	if(UserModel.getGoldNumber() < _clearCdCost ) then
		require "script/ui/tip/LackGoldTip"
		LackGoldTip.showTip()
		return
	end
	local tipFont = {}
    tipFont[1] = CCLabelTTF:create(GetLocalizeStringBy("lic_1280") ,g_sFontName,25)
    tipFont[1]:setColor(ccc3(0x78,0x25,0x00))
    tipFont[2] = CCSprite:create("images/common/gold.png")
	tipFont[3] = CCLabelTTF:create(_clearCdCost,g_sFontName,25)
	tipFont[3]:setColor(ccc3(0x78,0x25,0x00))
    tipFont[4] = CCLabelTTF:create(GetLocalizeStringBy("lic_1281"),g_sFontName,25)
    tipFont[4]:setColor(ccc3(0x78,0x25,0x00))
	require "script/utils/BaseUI"
    local tipFontNode = BaseUI.createHorizontalNode(tipFont)
	require "script/ui/tip/TipByNode"
	TipByNode.showLayer(tipFontNode,clearCDServiceCallFun)
end

-- 清除cd网络请求
function clearCDServiceCallFun( ... )
	local typeNum = 0
	local guildTaskType = getRuinOrMendStatus()
	if( guildTaskType == 1)then
		-- 修复城池
		typeNum = 0
	elseif(guildTaskType == 2)then
		-- 破坏城池
		typeNum = 1
	else
	end
	local nextCallFun = function ( ... )
		-- 清除cd后扣除金币
		UserModel.addGoldNumber(-_clearCdCost)
		-- 隐藏清除按钮
		_backGround:stopAllActions()
		_clearCDButton:setVisible(false)
		_cdLable:setVisible(false)
		-- 显示按钮
		if( guildTaskType == 1)then
			-- 修复城池
			setRepairCDTime()
			repairButton:setVisible(true)
		elseif(guildTaskType == 2)then
			-- 破坏城池
			setBreakCDTime()
			breakButton:setVisible(true)
		else
		end
	end
	CityService.clearCd( typeNum, nextCallFun )
end

-- 网络请求回调
function serviceCallFunc( ret )
	-- 城池网络数据
	_thisCityServiceData = ret
	-- 重要时间
	_allTimeTab = CityData.getTimeTable()

	-- 保存正查看城市的详细信息
	local lookingCityInfo = {}
	lookingCityInfo.cityId = _thisCityID
	lookingCityInfo.dbData = _thisCityBaseData
	lookingCityInfo.serData = _thisCityServiceData
	CityData.setLookingCityInfo(lookingCityInfo)

	--刷新军团任务信息
	require "script/ui/battlemission/MissionService"
	if(MissionData.isGuildMissonOpen())then
	    MissionService.getTaskInfo(function ()
	        -- 初始化
			initCityInfoLayer()
	    end)
	else
		-- 初始化
		initCityInfoLayer()
	end

end

-- 创建城战信息界面
function showCityInfoLayer( city_id, isQuick )
	-- 初始化变量
	init()
	-- 获得数据
	_thisCityID = city_id
	-- 是否是快速入口
	_isQuick = isQuick
	-- 表里配置数据
	_thisCityBaseData = CityData.getDataById(_thisCityID)

	-- 破坏修复城池cd时间
	_CDTime = CityData.getBreakAndRepairCityCDTime()

	-- 清除cd花费
	_clearCdCost = CityData.getClearBreakAndRepairCityCDCost()

	-- 网络请求
	CityService.getCityInfo( _thisCityID, serviceCallFunc)
end


----------------------------[[data uitl]]-------------------------------

--得到修复城防和破坏城防状态
-- ret: 1 修复城防
	 -- 2 破坏城防
	 -- 0 不能破坏也不能修复
function getRuinOrMendStatus( ... )
	require "script/ui/battlemission/MissionData"
	local taskType =  MissionData.getNowTaskType()

	local retNum = 0
	if(taskType == 5) then
		--破坏城池
		--检查是否可以破坏
		if(GuildDataCache.getGuildId() ~= tonumber(_thisCityServiceData.guild_id) and
			GuildDataCache.getGuildHallLevel() >= _thisCityBaseData.needLegionLevel and
			MissionData.nowTaskIsFinish() == false) then
			retNum = 2
		end
	elseif(taskType == 6) then
		--修复城池
		if(GuildDataCache.getGuildId() == tonumber(_thisCityServiceData.guild_id) and MissionData.nowTaskIsFinish() == false) then
			retNum = 1
		end
	else
		retNum = 0
	end
	return retNum
end

-- 设置上次破坏城防时间
function setBreakCDTime()
	_thisCityServiceData.ruin_time = 0
end

-- 得到上次破坏城防时间
function getBreakCDTime( )
	return tonumber(_thisCityServiceData.ruin_time)
end

-- 设置上次修复城防时间
function setRepairCDTime()
	_thisCityServiceData.mend_time = 0
end

-- 得到上次修复城防时间
function getRepairCDTime( )
	return tonumber(_thisCityServiceData.mend_time)
end
































