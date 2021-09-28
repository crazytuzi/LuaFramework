-- Filename：	BattleLand.lua
-- Author：		LiuLiPeng
-- Date：		2014-4-24
-- Purpose：		城池大地图

module ("BattleLand", package.seeall)
require "script/ui/guild/city/CityData"
require "db/DB_Legion_citybattle"
require "script/ui/tip/AnimationTip"
require "script/ui/tip/AlertTip"
require "script/ui/active/RivalInfoLayer"
require "script/ui/formation/MakeUpFormationLayer"

local IMG_PATH 			= "images/readybattle/"			-- 主城场景图片主路径
local readyLayer 		= nil							-- 准备层
local bgSprite 			= nil							-- 背景图
local _upTableView 		= nil
local _downTableView 	= nil
local bg_sprite_up		= nil
local bg_sprite_down	= nil
local attSprite			= nil
local leftTime 			= 0
local _cityId			= 0
local _data				= nil
local defSprite 		= nil
local onCountLabel 		= nil
local totalCountLabel 	= nil
local onCountLabel_down = nil
local totalCountLabel_down = nil
local vsSprite			= nil
local attNameLabel		= nil
local defNameLabel		= nil
local normalMenu		= nil
local enterData			= nil
local agspreItem 		= nil
local goldItem          = nil
local canclick			= true
local attAddSprite      = nil
local defAddSprite	 	= nil
local addGoldCount		= 0
local canspre 			= true
local t1				= {}
local t2 				= {}
local goldCoinSprite    = nil
local goldLabel			= nil
local defLabel  		= nil
local attLabel 			= nil
local spreLabel			= nil
local addWinLabel  		= nil
local attackTable 		= {}
local defendTable       = {}
local offlineAttackNum 	= 0
local offlineDefineNum 	= 0
local cityNameLabel 	= nil 							--城池名称label
local ownGuildSprite	= nil 							--占领图标
local guildNameLabel	= nil 							--军团名称label
local cityPowerSprite 	= nil 							--城防图标
local cityPowerLabel 	= nil 							--城防值label
local guildPowerSprite	= nil 							--军团战力图标
local guildPowerLabel 	= nil 							--军团战力label
local guildName 		= nil
local chengfangNum 		= nil
local fightNum 			= nil
local battleValuSpriteUp= nil
local battleValuSpriteDown= nil
local defenderPower 	= nil
local attackerPower 	= nil
function init()
	IMG_PATH 			= "images/readybattle/"			-- 主城场景图片主路径
	readyLayer 			= nil							-- 准备层
	bgSprite 			= nil							-- 背景图
	_upTableView 		= nil
	_downTableView 		= nil
	bg_sprite_up		= nil
	bg_sprite_down		= nil
	attSprite			= nil
	leftTime 			= 0
	_cityId				= 0
	_data				= nil
	defSprite 			= nil
	onCountLabel 		= nil
	totalCountLabel 	= nil
	onCountLabel_down 	= nil
	totalCountLabel_down = nil
	vsSprite			= nil
	attNameLabel		= nil
	defNameLabel		= nil
	normalMenu			= nil
	enterData			= nil
	agspreItem 			= nil
	goldItem         	= nil
	canclick			= true
	attAddSprite      	= nil
	defAddSprite	 	= nil
	addGoldCount		= 0
	t1 					= {}
	t2					= {}
	goldCoinSprite      = nil
	goldLabel			= nil
	defLabel  			= nil
	attLabel 			= nil
	spreLabel			= nil
	addWinLabel			= nil
	guildNameLabel		= nil
	cityPowerSprite 	= nil
	cityPowerLabel 		= nil
	guildPowerSprite	= nil
	guildPowerLabel 	= nil
	guildName 			= nil
	chengfangNum 		= nil
	attackTable 		= {}
	defendTable         = {}
	offlineAttackNum 	= 0
	offlineDefineNum 	= 0
	fightNum 			= nil
	battleValuSpriteUp	= nil
	battleValuSpriteDown= nil
	defenderPower 		= nil
	attackerPower 		= nil
end

-- function getData( cityId )
-- 	-- body
-- 	-- local tempArgs = CCArray:create()
-- 	-- tempArgs:addObject(CCInteger:create(cityId))
-- 	-- RequestCenter.enterBattleLand(messageCallBack, tempArgs)
-- end
local function onNodeEvent( event )
	if (event == "enter") then
		-- print("enter")
		GuildDataCache.setIsInGuildFunc(true)
	elseif (event == "exit") then
		-- print("exit")
		GuildDataCache.setIsInGuildFunc(false)
		readyLayer = nil
	end
end

--[[
 @desc	创建准备界面的布局
 @return
 --]]
function create(cityId,dictData)
	init()

	local data = DB_Legion_citybattle.getDataById(1)
	t1 = string.split(data.WinCost, ",")
	for i=1,#t1 do
		t2[i] = string.split(t1[i],"|")
	end


	MainScene.setMainSceneViewsVisible(false,false,false)
	_cityId = cityId


	--背景图
	readyLayer = CCLayer:create()
	readyLayer:registerScriptHandler(onNodeEvent)
	local layerSize = readyLayer:getContentSize()

	bgSprite = CCSprite:create("images/readybattle/readyBattleBg.jpg")
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setPosition(ccp(layerSize.width*0.5, layerSize.height*0.5))
	bgSprite:setScale(g_fBgScaleRatio)
	readyLayer:addChild(bgSprite)

	--上方格
	bg_sprite_up = CCScale9Sprite:create("images/common/bg/9s_1.png")
	bg_sprite_up:setContentSize(CCSizeMake(640, 250))
	bg_sprite_up:setAnchorPoint(ccp(0.5, 1))
	bg_sprite_up:setPosition(ccp(layerSize.width*0.5, layerSize.height))
	bg_sprite_up:setScale(g_fScaleX)
	readyLayer:addChild(bg_sprite_up)
	--在军团战准备界面增加占领军团信息、城防值和军团战斗力的加成状况，交战双方都有直观了解。
	-- local cityNameLabel 		= nil 							--城池名称label
	-- local ownGuildSprite		= nil 							--占领图标
	-- local guildNameLabel		= nil 							--军团名称label
	-- local cityPowerSprite 	= nil 							--城防图标
	-- local cityPowerLabel 	= nil 							--城防值label
	-- local guildPowerSprite	= nil 							--军团战力图标
	-- local guildPowerLabel 	= nil 							--军团战力label
	--新加图标数据
	local cityInfoData =CityData.getLookingCityInfo()

	if(cityInfoData~=nil)then
		local quality = tonumber(cityInfoData.cityLevel) or 1
	    local cityName = cityInfoData.dbData.name or GetLocalizeStringBy("key_3392")
	    cityNameLabel = createCtiyName(quality,cityName)
	    readyLayer:addChild(cityNameLabel)
	    cityNameLabel:setAnchorPoint(ccp(0,1))
	    cityNameLabel:setPosition(ccp(30,layerSize.height-bg_sprite_up:getContentSize().height* g_fScaleX-5))
	    cityNameLabel:setScale(g_fScaleX)

	    ownGuildSprite = CCSprite:create("images/guild/city/zhanling.png")
	    ownGuildSprite:setAnchorPoint(ccp(0,1))
	    ownGuildSprite:setPosition(ccp(cityNameLabel:getContentSize().width* g_fScaleX,layerSize.height-bg_sprite_up:getContentSize().height* g_fScaleX-10))
	    readyLayer:addChild(ownGuildSprite)
	    ownGuildSprite:setScale(g_fScaleX)

	    -- 占领军团
	 	local levelNum = nil
	 	guildName = nil
	 	chengfangNum = nil
	 	fightNum = nil
	 	local guildFightNum = nil

	 	if( cityInfoData and not table.isEmpty(cityInfoData))then
	 		-- 不为空 则被军团占领
	 		guildName = cityInfoData.serData.guild_name
	 		levelNum = cityInfoData.serData.guild_level
	 		chengfangNum = tonumber(cityInfoData.serData.city_defence)
	 		fightNum = tonumber(cityInfoData.serData.city_force)
	 		guildFightNum = cityInfoData.serData.fight_force or 0
	 		if(tonumber(guildName) == 0 and tonumber(levelNum) == 0 and tonumber(guildFightNum) == 0 )then
	 			-- 隐藏NPC 不显示
	 			guildName = nil
				levelNum = nil
				guildFightNum = nil
	 		end
	 	else
	 		if( cityInfoData.dbData.defendEnemy == nil)then
	 			guildName = nil
		 		levelNum = nil
	 		else
	 			-- 则显示npc
		 		require "db/DB_Copy_team"
		 		local npcData = DB_Copy_team.getDataById(cityInfoData.dbData.defendEnemy)
		 		guildName = npcData.name
		 		levelNum = npcData.level
	 		end

	 		chengfangNum = tonumber(cityInfoData.dbData.defaultCityDefend)
	 		fightNum = 100
	 	end

	 	--军团名字
	 	if(guildName)then
		 	guildNameLabel = CCLabelTTF:create(guildName, g_sFontPangWa,25)
		else
		 	guildNameLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3091"), g_sFontPangWa,25)
		end
		guildNameLabel:setAnchorPoint(ccp(0,1))
	 	guildNameLabel:setColor(ccc3(0x00,0xe4,0xff))
	 	guildNameLabel:setPosition(ccp(cityNameLabel:getContentSize().width* g_fScaleX+ownGuildSprite:getContentSize().width* g_fScaleX,layerSize.height-bg_sprite_up:getContentSize().height * g_fScaleX))
	 	guildNameLabel:setScale(g_fScaleX)
	 	readyLayer:addChild(guildNameLabel)

	 	--城防图标
	 	cityPowerSprite = CCSprite:create("images/guild/city/chengfang.png")
	 	cityPowerSprite:setAnchorPoint(ccp(0,1))
	 	cityPowerSprite:setPosition(ccp(0,layerSize.height-cityNameLabel:getContentSize().height-bg_sprite_up:getContentSize().height* g_fScaleX-20))
	 	cityPowerSprite:setScale(g_fScaleX)
	 	readyLayer:addChild(cityPowerSprite)

	 	-- 城防值
	 	local chengfangNumStr = chengfangNum or GetLocalizeStringBy("key_3392")
	 	local cityPowerLabel = CCLabelTTF:create(chengfangNumStr, g_sFontName, 25)
	 	cityPowerLabel:setAnchorPoint(ccp(0,0))
	 	cityPowerLabel:setPosition(ccp(cityPowerSprite:getContentSize().width* g_fScaleX,layerSize.height-cityPowerLabel:getContentSize().height-cityNameLabel:getContentSize().height-bg_sprite_up:getContentSize().height* g_fScaleX-cityPowerSprite:getContentSize().height))
	 	readyLayer:addChild(cityPowerLabel)
	 	cityPowerLabel:setScale(g_fScaleX)
	 	if( chengfangNum < tonumber(cityInfoData.dbData.defaultCityDefend))then
	 		cityPowerLabel:setColor(ccc3(0xff,0x00,0x00))
	 	else
	 		cityPowerLabel:setColor(ccc3(0x00,0xff,0x18))
	 	end

		guildPowerSprite = CCSprite:create("images/common/fight_value02.png")
		guildPowerSprite:setAnchorPoint(ccp(0,1))
		guildPowerSprite:setPosition(ccp(guildPowerSprite:getContentSize().width* g_fScaleX+guildPowerSprite:getContentSize().width* g_fScaleX,layerSize.height-20-cityNameLabel:getContentSize().height-bg_sprite_up:getContentSize().height* g_fScaleX))
		readyLayer:addChild(guildPowerSprite)
		guildPowerSprite:setScale(g_fScaleX)

		 ownGuildSprite:setPosition(ccp(guildPowerSprite:getContentSize().width* g_fScaleX+guildPowerSprite:getContentSize().width* g_fScaleX,layerSize.height-bg_sprite_up:getContentSize().height* g_fScaleX-5))
		 guildNameLabel:setPosition(ccp(guildPowerSprite:getContentSize().width* g_fScaleX+guildPowerSprite:getContentSize().width* g_fScaleX+ownGuildSprite:getContentSize().width* g_fScaleX,layerSize.height-bg_sprite_up:getContentSize().height* g_fScaleX-5))
		local fightNumStr = fightNum
	 	guildPowerLabel = CCLabelTTF:create(fightNum .. "%", g_sFontName, 25)
	 	guildPowerLabel:setAnchorPoint(ccp(0,0))
	 	guildPowerLabel:setPosition(ccp(guildPowerSprite:getContentSize().width* g_fScaleX+guildPowerSprite:getContentSize().width* g_fScaleX+ownGuildSprite:getContentSize().width* g_fScaleX,layerSize.height-guildPowerLabel:getContentSize().height-cityPowerSprite:getContentSize().height-bg_sprite_up:getContentSize().height* g_fScaleX-cityNameLabel:getContentSize().height))
	 	readyLayer:addChild(guildPowerLabel)
	 	if( fightNum < 100 )then
	 		guildPowerLabel:setColor(ccc3(0xff,0x00,0x00))
	 	else
	 		guildPowerLabel:setColor(ccc3(0x00,0xff,0x18))
	 	end

	end

	--下方格
	bg_sprite_down = CCScale9Sprite:create("images/common/bg/9s_1.png")
	bg_sprite_down:setContentSize(CCSizeMake(640, 250))
	bg_sprite_down:setAnchorPoint(ccp(0.5, 0))
	bg_sprite_down:setPosition(ccp(layerSize.width*0.5, 0))
	bg_sprite_down:setScale(g_fScaleX)
	readyLayer:addChild(bg_sprite_down)

	--守方
	defSprite = CCSprite:create(IMG_PATH.."defPoint.png")
	defSprite:setAnchorPoint(ccp(0.5,1))
	defSprite:setPosition(ccp(bg_sprite_up:getContentSize().width-defSprite:getContentSize().width*0.6,bg_sprite_up:getContentSize().height))
	bg_sprite_up:addChild(defSprite)

	--攻方
	attSprite = CCSprite:create(IMG_PATH.."attPoint.png")
	attSprite:setAnchorPoint(ccp(0.5,1))
	attSprite:setPosition(ccp(attSprite:getContentSize().width*0.6,bg_sprite_up:getContentSize().height))
	bg_sprite_down:addChild(attSprite)

	--vs底图
	vsSprite = CCSprite:create(IMG_PATH.."vsbg.png")
	vsSprite:setAnchorPoint(ccp(0.5,0.5))
	vsSprite:setPosition(ccp(layerSize.width*0.5,layerSize.height*0.55))
	vsSprite:setScale(g_fElementScaleRatio)
	readyLayer:addChild(vsSprite)

	--准备倒计时
	local dataTable = CityData.getTimeTable()

	for i=1,table.count(dataTable.arrAttack) do
		local curTime = TimeUtil.getSvrTimeByOffset()
		if(curTime<tonumber(dataTable.arrAttack[i][1]))then
			leftTime = dataTable.arrAttack[i][1]
			break
		end
	end

	local timeLabel = CCLabelTTF:create(TimeUtil.getTimeString(leftTime), g_sFontPangWa, 23)
	timeLabel:setAnchorPoint(ccp(0.5,1))
	timeLabel:setPosition(ccp(vsSprite:getContentSize().width*0.5, vsSprite:getContentSize().height*0.1))
	vsSprite:addChild(timeLabel,1)
	timeLabel:setColor(ccc3(0x00,0xff,0x18))

	local function refreshTime( ... )
	-- body
		if(leftTime~=TimeUtil.getSvrTimeByOffset())then
			leftTimeInterval = tonumber(leftTime) - TimeUtil.getSvrTimeByOffset()
			timeLabel:setString(TimeUtil.getTimeString(leftTimeInterval))
		else
			timeLabel:stopAllActions()
			timeLabel:setVisible(false)
		end
	end

	local delay = CCDelayTime:create(1)
    local callfunc = CCCallFunc:create(function ( ... )refreshTime() end)
    local sequence = CCSequence:createWithTwoActions(delay, callfunc)
    local action = CCRepeatForever:create(sequence)
    timeLabel:runAction(action)

	--普通按钮menu
	normalMenu = CCMenu:create()
	normalMenu:setTouchPriority(-462)
	normalMenu:setPosition(ccp(0,0))
	readyLayer:addChild(normalMenu)

	--返回按钮
	-- local backItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	--离开战场
	local leaveItem = CCMenuItemImage:create(IMG_PATH.."leave_n.png",IMG_PATH.."leave_h.png")
	--银币鼓舞
	agspreItem = CCMenuItemImage:create("images/boss/silver_inspire_normal.png","images/boss/silver_inspire_selected.png")
	--金币增加连胜
	goldItem = CCMenuItemImage:create("images/citybattle/addnormal.png","images/citybattle/addselected.png")
	--攻击加成
	attAddSprite= CCSprite:create("images/citybattle/att.png")
	--防御加成
	defAddSprite= CCSprite:create("images/citybattle/def.png")
	--连胜数目
	addWinSprite = CCSprite:create("images/citybattle/addwin.png")

	-- backItem:registerScriptTapHandler(backAction)
	-- backItem:setAnchorPoint(ccp(1, 0.5))
	-- backItem:setPosition(ccp(layerSize.width*0.99, layerSize.height - (bg_sprite_up:getContentSize().height + 60) * g_fScaleX))
	-- backItem:setScale(g_fElementScaleRatio)
	-- normalMenu:addChild(backItem)
	-- backItem:setTag(cityId)

	--离开战场
	leaveItem:registerScriptTapHandler(leaveAction)
	leaveItem:setAnchorPoint(ccp(1, 0.5))
	leaveItem:setPosition(ccp(layerSize.width*0.99 , layerSize.height - (bg_sprite_up:getContentSize().height+60) * g_fScaleX))
	leaveItem:setScale(g_fElementScaleRatio)
	normalMenu:addChild(leaveItem)
	-- leaveItem:setTag(cityId)

	-- 聊天
	local chatItem = CCMenuItemImage:create("images/guild/btn_chat_n.png","images/guild/btn_chat_h.png")
	chatItem:setAnchorPoint(ccp(1, 0.5))
	chatItem:registerScriptTapHandler(bottomMenuAction)
	chatItem:setPosition(ccp(layerSize.width * 0.8, layerSize.height - (bg_sprite_up:getContentSize().height+60) * g_fScaleX))
	chatItem:setScale(g_fElementScaleRatio)
	normalMenu:addChild(chatItem, 1)

	-- added by zhz
	--布阵
	if(DataCache.getSwitchNodeState(ksSwitchWarcraft, false) == true)then
		local arrayMenuItem = CCMenuItemImage:create("images/copy/array_n.png","images/copy/array_h.png")
		arrayMenuItem:setAnchorPoint(ccp(1, 0.5))
		arrayMenuItem:registerScriptTapHandler(arrayAction)
		arrayMenuItem:setScale(g_fElementScaleRatio)
		arrayMenuItem:setPosition(ccp(layerSize.width, (bg_sprite_down:getContentSize().height+60) * g_fScaleX))
		normalMenu:addChild(arrayMenuItem)
	else
		local arrayMenuItem = CCMenuItemImage:create("images/copy/arraybu_n.png","images/copy/arraybu_h.png")
		arrayMenuItem:setAnchorPoint(ccp(1, 0.5))
		arrayMenuItem:registerScriptTapHandler(arrayAction)
		arrayMenuItem:setScale(g_fElementScaleRatio)
		arrayMenuItem:setPosition(ccp(layerSize.width, (bg_sprite_down:getContentSize().height+60) * g_fScaleX))
		normalMenu:addChild(arrayMenuItem)
	end

	-- 鼓舞灰色的背景
	local agspreSprite = CCScale9Sprite:create("images/common/name_bg_9s.png")
	agspreSprite:setContentSize(CCSizeMake(175, 175))
	agspreSprite:setAnchorPoint(ccp(0, 0))
	agspreSprite:setPosition(ccp(33*g_fScaleX, bg_sprite_down:getContentSize().height*g_fScaleX))
	agspreSprite:setScale(g_fElementScaleRatio)
	readyLayer:addChild(agspreSprite,11)
	local spreMenuBar = CCMenu:create()
	spreMenuBar:setPosition(ccp(0,0))
	agspreSprite:addChild(spreMenuBar)

	local coinSprite = CCSprite:create("images/common/coin.png")
	coinSprite:setPosition(ccp(agspreSprite:getContentSize().width*0.3,agspreSprite:getContentSize().height*0.25))
	agspreSprite:addChild(coinSprite)
	local coinLabel = CCLabelTTF:create(data.inspireCostSilver,g_sFontPangWa,21)
	coinLabel:setPosition(ccp(coinSprite:getContentSize().width,0))
	coinSprite:addChild(coinLabel)

	-- 连胜灰色的背景
	local goldSprite = CCScale9Sprite:create("images/common/name_bg_9s.png")
	goldSprite:setContentSize(CCSizeMake(175, 175))
	goldSprite:setAnchorPoint(ccp(0, 0))
	goldSprite:setPosition(ccp(240*g_fScaleX, bg_sprite_down:getContentSize().height*g_fScaleX))
	goldSprite:setScale(g_fElementScaleRatio)
	readyLayer:addChild(goldSprite)
	local goldMenuBar = CCMenu:create()
	goldMenuBar:setPosition(ccp(0,0))
	goldSprite:addChild(goldMenuBar)

	goldCoinSprite = CCSprite:create("images/common/gold.png")
	goldCoinSprite:setPosition(ccp(goldSprite:getContentSize().width*0.3,goldSprite:getContentSize().height*0.25))
	goldSprite:addChild(goldCoinSprite)

	--银币鼓舞
	agspreItem:registerScriptTapHandler(spreAction)
	agspreItem:setAnchorPoint(ccp(0.5, 0.5))
	agspreItem:setPosition(ccp(agspreSprite:getContentSize().width*0.5, agspreSprite:getContentSize().height*0.7))
	spreMenuBar:addChild(agspreItem)
	-- leaveItem:setTag(_cityId)

	--金币增加连胜
	goldItem:registerScriptTapHandler(goldAction)
	goldItem:setAnchorPoint(ccp(0.5,0.5))
	goldItem:setPosition(ccp(goldSprite:getContentSize().width*0.5, goldSprite:getContentSize().height*0.7))
	goldMenuBar:addChild(goldItem)
	-- goldItem:setTag(cityId)

	--攻击加成
	attAddSprite:setAnchorPoint(ccp(0.5, 0))
	attAddSprite:setPosition(ccp(agspreSprite:getContentSize().width*0.2, 0))
	agspreSprite:addChild(attAddSprite)

	--防御加成
	defAddSprite:setAnchorPoint(ccp(0.5,0))
	defAddSprite:setPosition(ccp(agspreSprite:getContentSize().width*0.9, 0))
	agspreSprite:addChild(defAddSprite)

	--连胜数目
	addWinSprite:setAnchorPoint(ccp(0.5,0))
	addWinSprite:setPosition(ccp(goldSprite:getContentSize().width*0.5, 0))
	goldSprite:addChild(addWinSprite)

	--聊天
	-- local talkItem = CCMenuItemImage:create()
	messageCallBack(dictData)
	Network.re_rpc(push_begin_battle, "push.citywar.battleResult", "push.citywar.battleResult")
	-- Network.re_rpc(one_in, "push.citywar.userLogin", "push.citywar.userLogin")
	-- Network.re_rpc(one_out, "push.citywar.userLogoff", "push.citywar.userLogoff")
	Network.re_rpc(refreshAction, "push.citywar.refresh", "push.citywar.refresh")

	return readyLayer
end

function bottomMenuAction( ... )
	-- body
	-- 聊天
		require "script/ui/chat/ChatMainLayer"
		print("chat1")
        ChatMainLayer.showChatLayer(3)
        print("chat2")
end

-- 创建城池名称、
function createCtiyName( quality, name )
	-- local sprite = CCSprite:create("images/guild/city/title_" .. quality .. ".png")
	local titleLabel = CCRenderLabel:create(name, g_sFontPangWa, 25, 1, ccc3(0,0,0), type_stroke)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	-- local posY = {0.37,0.53,0.6,0.7}
	-- local posY = {0.7,0.6,0.53,0.37}
	-- titleLabel:setPosition(ccp(sprite:getContentSize().width*0.5, sprite:getContentSize().height*posY[tonumber(quality)]))
	-- sprite:addChild(titleLabel)
	return titleLabel
end

-- 布阵的回调函数， aded by zhz
function arrayAction( ... )
	if(DataCache.getSwitchNodeState(ksSwitchWarcraft, false) == true)then
		require "script/ui/warcraft/WarcraftLayer"
		WarcraftLayer.show()
	else
		MakeUpFormationLayer.showLayer()
	end
end

function refreshAction( cbFlag, dictData, bRet )
	-- body
	if(dictData.err == "ok")then
		--攻方进入
		if(not table.isEmpty(dictData.ret.attacker.enter))then
			-- table.insert(enterData.ret.attacker.list,dictData.ret.attacker.enter[1])
			for k,enterInfo in pairs(dictData.ret.attacker.enter) do

				if(table.isEmpty(enterData.ret.attacker.list) == true )then
					-- 如果为空
					enterData.ret.attacker.list = {}
					table.insert(enterData.ret.attacker.list, enterInfo)
				else
					local isIn = false
					for k,v in pairs(enterData.ret.attacker.list) do
						if(tonumber(v.uid) == tonumber(enterInfo.uid))then
							isIn = true
							break
						end
					end
					if(isIn == false)then
						table.insert(enterData.ret.attacker.list, enterInfo)
					end
				end
				-- if(not table.isEmpty(enterData.ret.attacker.offline))then
				-- 	for attackuid,ischoose in pairs(enterData.ret.attacker.offline)do
				-- 		-- print("attackuid"..attackuid.."ischoose"..ischoose.."enterInfo"..enterInfo.uid)
				-- 		if(tonumber(ischoose)==tonumber(enterInfo.uid))then
				-- 			table.remove(enterData.ret.attacker.offline,ischoose)
				-- 		end
				-- 	end
				-- end
				for i=1,table.count(enterData.ret.attacker.offline)do
					for j=1,table.count(dictData.ret.attacker.enter)do
						if(tonumber(enterData.ret.attacker.offline[i].uid)==tonumber(dictData.ret.attacker.enter[j].uid))then
							table.remove(enterData.ret.attacker.offline,i)
						end
					end
				end
			end
		end
		--攻方离开
		if(not table.isEmpty(dictData.ret.attacker.leave) and not table.isEmpty(enterData.ret.attacker.list) )then
			-- for k, leaveUid in pairs(dictData.ret.attacker.leave) do
			-- 	for i=1,table.count(enterData.ret.attacker.list)do
			-- 		if(tonumber(leaveUid)== tonumber(enterData.ret.attacker.list[i].uid) )then
			-- 			table.remove(enterData.ret.attacker.list,i)
			-- 			break
			-- 		end
			-- 	end
			-- end
			for leaveUid,isChoose in pairs(dictData.ret.attacker.leave) do
				if(tonumber(isChoose)==0)then
					for i=1,table.count(enterData.ret.attacker.list)do
						if(tonumber(leaveUid)== tonumber(enterData.ret.attacker.list[i].uid) )then
							table.remove(enterData.ret.attacker.list,i)
							break
						end
					end
				else
					if(enterData.ret.attacker.offline == nil)then
						enterData.ret.attacker.offline = {}
					end

					for i=1,table.count(enterData.ret.attacker.list)do
						if(tonumber(leaveUid)== tonumber(enterData.ret.attacker.list[i].uid) )then
							table.insert(enterData.ret.attacker.offline,enterData.ret.attacker.list[i])
							table.remove(enterData.ret.attacker.list,i)
							break
						end
					end
				end
			end
		end

		--守方进入
		if(not table.isEmpty(dictData.ret.defender.enter))then
			for k,enterInfo in pairs(dictData.ret.defender.enter) do

				if(table.isEmpty(enterData.ret.defender.list))then
					-- 如果为空
					enterData.ret.defender.list = {}
					table.insert(enterData.ret.defender.list, enterInfo)
				else
					local isIn = false
					for k,v in pairs(enterData.ret.defender.list) do
						if(tonumber(v.uid) == tonumber(enterInfo.uid))then
							isIn = true
							break
						end
					end
					if(isIn == false)then
						table.insert(enterData.ret.defender.list, enterInfo)
					end
				end
				-- if(not table.isEmpty(enterData.ret.defender.offline))then
				-- 	for defenduid,ischoose in pairs(enterData.ret.defender.offline)do
				-- 		print("defenduid"..defenduid.."ischoose"..ischoose.."enterInfo"..enterInfo.uid)
				-- 		if(tonumber(defenduid)==tonumber(enterInfo.uid))then
				-- 			table.remove(enterData.ret.defender.offline,ischoose)
				-- 		end
				-- 	end
				-- end
				for i=1,table.count(enterData.ret.defender.offline)do
					for j=1,table.count(dictData.ret.defender.enter)do
						if(tonumber(enterData.ret.defender.offline[i].uid)==tonumber(dictData.ret.defender.enter[j].uid))then
							table.remove(enterData.ret.defender.offline,i)
						end
					end
				end
			end
		end
		--守方离开

		if(not table.isEmpty(dictData.ret.defender.leave) and not table.isEmpty(enterData.ret.defender.list) )then
			-- for k, leaveUid in pairs(dictData.ret.defender.leave) do
			-- 	for i=1,table.count(enterData.ret.defender.list)do
			-- 	print("leaveuid=="..leaveUid.."enterUId"..enterData.ret.defender.list[i].uid)
			-- 		if(tonumber(leaveUid)== tonumber(enterData.ret.defender.list[i].uid) )then
			-- 			table.remove(enterData.ret.defender.list,i)
			-- 			break
			-- 		end
			-- 	end
			-- end
			for leaveUid,isChoose in pairs(dictData.ret.defender.leave) do
				if(tonumber(isChoose)==0)then
					for i=1,table.count(enterData.ret.defender.list)do
						if(tonumber(leaveUid)== tonumber(enterData.ret.defender.list[i].uid) )then
							table.remove(enterData.ret.defender.list,i)
							break
						end
					end
				else
					if(enterData.ret.defender.offline==nil)then
						enterData.ret.defender.offline = {}
					end

					for i=1,table.count(enterData.ret.defender.list)do
						if(tonumber(leaveUid)== tonumber(enterData.ret.defender.list[i].uid) )then
							table.insert(enterData.ret.defender.offline,enterData.ret.defender.list[i])
							table.remove(enterData.ret.defender.list,i)
							break
						end
					end
				end
			end
		end
		refreshwinData(enterData)
		createupTableView(enterData.ret)
	end
end

function leaveAction( tag,item )
	-- body
	local tempArgs = CCArray:create()
	tempArgs:addObject(CCInteger:create(_cityId))
	RequestCenter.leaveBattleLand(leaveCallBack,tempArgs)
end

function leaveCallBack( cbFlag, dictData, bRet )
	-- body
	if(dictData.err == "ok")then
		readyLayer:setVisible(false)
		_upTableView = nil
		_downTableView = nil
		readyLayer:removeFromParentAndCleanup(true)
		readyLayer = nil
		MainScene.setMainSceneViewsVisible(true,true,true)

		require "script/ui/copy/BigMap"
		local fortsLayer = BigMap.createFortsLayout()
		MainScene.changeLayer(fortsLayer, "BigMap")
	end
end

function spreAction( tag,item )
	-- body
	if(canclick == true)then
		if(canspre == true)then
			local data = DB_Legion_citybattle.getDataById(1)

			local sliverCount = UserModel.getSilverNumber()
			if(sliverCount<tonumber(data.inspireCostSilver))then
				AnimationTip.showTip(GetLocalizeStringBy("key_3320"))
			else
				local tempArgs = CCArray:create()
				tempArgs:addObject(CCInteger:create(_cityId))
				RequestCenter.inspireBattleLand(spreCallBack,tempArgs)
			end
		else
			AnimationTip.showTip(GetLocalizeStringBy("key_3098"))
		end
	else
		AnimationTip.showTip(GetLocalizeStringBy("key_1594"))
	end

end

function spreCallBack( cbFlag,dictData, bRet )
	-- body
	local data = DB_Legion_citybattle.getDataById(1)

	if(dictData.err == "ok" and dictData.ret.ret == "ok")then
		canclick = false
		--鼓舞倒计时
		local time = data.inspireCd
		if(spreLabel~=nil)then
			spreLabel:setVisible(false)
			spreLabel:removeFromParentAndCleanup(true)
			spreLabel = nil
		end
		spreLabel = CCLabelTTF:create(TimeUtil.getTimeString(time),g_sFontPangWa,21)
		spreLabel:setColor(ccc3(0x00,0xff,0x18))
		spreLabel:setPosition(ccp(0,agspreItem:getContentSize().height*0.5))
		agspreItem:addChild(spreLabel,1)
		local function refreshTime( ... )
			-- body
			if(time~=0)then
				time = time - 1
				spreLabel:setString(TimeUtil.getTimeString(time))
			else
				canclick = true
				spreLabel:stopAllActions()
				spreLabel:setVisible(false)
				spreLabel:removeFromParentAndCleanup(true)
				spreLabel = nil
			end
		end

		local delay = CCDelayTime:create(1)
	    local callfunc = CCCallFunc:create(function ( ... )refreshTime() end)
	    local sequence = CCSequence:createWithTwoActions(delay, callfunc)
	    local action = CCRepeatForever:create(sequence)
	    spreLabel:runAction(action)
	    --
	    ---------
	    UserModel.addSilverNumber(-(data.inspireCostSilver))
	    ---------
	    local affixTable = {}
	    local strNum1 = tonumber(string.split(data.attackAffix,"|")[2])
	    local strNum2 = tonumber(string.split(data.defendAffix,"|")[2])
	    local count1 = dictData.ret.attack_level*(strNum1)
	    local count2 = dictData.ret.defend_level*(strNum2)
	    print("count1"..count1)
	    print("count2"..count2)
	    affixTable[1] = count1
	    affixTable[2] = count2
	    -- affixTable.insert(count1)
	    -- affixTable.insert(count2)
		if(tostring(dictData.ret.suc)=="true" or dictData.ret.suc == true)then

			if((dictData.ret.attack_level==data.maxLevel) and (dictData.ret.defend_level==data.maxLevel))then
				canspre = false
			end
			table.insert(attackTable,dictData.ret.attack_level)
			table.insert(defendTable,dictData.ret.defend_level)
		    attLabel:setString((affixTable[1]/100).."%")
		    defLabel:setString((affixTable[2]/100).."%")
		    if(#attackTable>=2)then
		    	if(tonumber(attackTable[#attackTable]-attackTable[#attackTable-1])~=0 and tonumber(defendTable[#defendTable]-defendTable[#defendTable-1])~=0)then
			    	AnimationTip.showTip(GetLocalizeStringBy("key_2239")..(affixTable[1]/100).."%"..GetLocalizeStringBy("key_1826")..(affixTable[2]/100).."%")
				elseif(tonumber(attackTable[#attackTable]-attackTable[#attackTable-1])~=0)then
					AnimationTip.showTip(GetLocalizeStringBy("key_2239")..(affixTable[1]/100).."%")
				elseif(tonumber(defendTable[#defendTable]-defendTable[#defendTable-1])~=0)then
					AnimationTip.showTip(GetLocalizeStringBy("key_2576")..(affixTable[2]/100).."%")
			    end
		    else
		    	if(tonumber(dictData.ret.attack_level)~=0 and tonumber(dictData.ret.defend_level)~=0)then
			    	AnimationTip.showTip(GetLocalizeStringBy("key_2239")..(affixTable[1]/100).."%"..GetLocalizeStringBy("key_1826")..(affixTable[2]/100).."%")
				elseif(tonumber(dictData.ret.attack_level)~=0)then
					AnimationTip.showTip(GetLocalizeStringBy("key_2239")..(affixTable[1]/100).."%")
				elseif(tonumber(dictData.ret.defend_level)~=0)then
					AnimationTip.showTip(GetLocalizeStringBy("key_2576")..(affixTable[2]/100).."%")
			    end
		    end
		 --    if(tonumber(dictData.ret.attack_level)~=0 and tonumber(dictData.ret.defend_level)~=0)then
		 --    	AnimationTip.showTip(GetLocalizeStringBy("key_2239")..(affixTable[1]/100).."%"..GetLocalizeStringBy("key_1826")..(affixTable[2]/100).."%")
			-- elseif(tonumber(dictData.ret.attack_level)~=0)then
			-- 	AnimationTip.showTip(GetLocalizeStringBy("key_2239")..(affixTable[1]/100).."%")
			-- elseif(tonumber(dictData.ret.defend_level)~=0)then
			-- 	AnimationTip.showTip(GetLocalizeStringBy("key_2576")..(affixTable[2]/100).."%")
		 --    end
		else
			AnimationTip.showTip(GetLocalizeStringBy("key_1416"))
		end
	else
		AnimationTip.showTip(GetLocalizeStringBy("key_1416"))
	end
end

function goldAction( tag,item )
	-- body
	local data = DB_Legion_citybattle.getDataById(1)
	print("addGoldCount"..addGoldCount)
	local t = string.split(data.WinCost, ",")

	if(tonumber(addGoldCount)<(#t))then
		AlertTip.showAlert( GetLocalizeStringBy("key_2526") .. t2[tonumber(addGoldCount) + 1][1] .. GetLocalizeStringBy("key_2883")..tonumber(addGoldCount+data.defaultWin), sureAction, true)
	else
		AnimationTip.showTip(GetLocalizeStringBy("key_2767"))
	end
end

function sureAction( isconf )
	-- body
	if(isconf == true)then
		local data = DB_Legion_citybattle.getDataById(1)
		local goldNum = UserModel.getGoldNumber()

		if(goldNum<tonumber(t2[tonumber(addGoldCount) + 1][1]))then
			AnimationTip.showTip(GetLocalizeStringBy("key_2310"))
		else
			local t = string.split(data.WinCost, ",")

			if(tonumber(addGoldCount)<(#t))then
				local tempArgs = CCArray:create()
				tempArgs:addObject(CCInteger:create(_cityId))
				RequestCenter.addBattleLand(goldCallBack,tempArgs)
			else
				AnimationTip.showTip(GetLocalizeStringBy("key_2767"))
			end

		end
	end
end

function goldCallBack( cbFlag, dictData, bRet )
	-- body
	if(dictData.err == "ok" and dictData.ret.ret == "ok")then
		addWinLabel:setString(dictData.ret.max_win)
		addGoldCount = dictData.ret.buy_num

		UserModel.addGoldNumber(-(tonumber(t2[tonumber(addGoldCount)][1])))
		local data = DB_Legion_citybattle.getDataById(1)
		print("addGoldCount"..addGoldCount)
		local t = string.split(data.WinCost, ",")
		local nextCount = tonumber(addGoldCount) + 1
		if( nextCount > #t  )then
			nextCount = #t
		end
		goldLabel:setString(t2[nextCount][1])
	end
end

function backAction( tag,item )
	-- body
	readyLayer:setVisible(false)
	_upTableView = nil
	_downTableView = nil
	readyLayer:removeFromParentAndCleanup(true)
	readyLayer = nil
	MainScene.setMainSceneViewsVisible(true,true,true)
	require "script/ui/copy/BigMap"
	local fortsLayer = BigMap.createFortsLayout()
	MainScene.changeLayer(fortsLayer, "BigMap")
end


-- 查看对手阵容的回调函数, added by zhz
function rivalInfoAction( tag, item )
	print(" user uid  is ", tag)

	local uid = tonumber(tag)

    RivalInfoLayer.createLayer(uid ,nil, nil,false,false,false )

end

function getHeroIconSprite( heroInfo,num )
	local nameLabel = CCLabelTTF:create(tostring(heroInfo.uname), g_sFontPangWa, 21)
	local dressId = nil
	local genderId = nil
	if(not table.isEmpty(heroInfo.dress) and (heroInfo.dress["1"])~= nil and tonumber(heroInfo.dress["1"]) > 0 )then
    	dressId = heroInfo.dress["1"]
    	genderId = HeroModel.getSex(heroInfo.htid)
	end

	-- added by zhz, vip 特效
	local vip = heroInfo.vip or 0
	if(num~=0)then
		vip = num
	end

	local iconSP = HeroUtil.getHeroIconByHTID(heroInfo.htid, dressId, genderId, vip)

	-- 名称
	local nameLabel = CCLabelTTF:create(tostring(heroInfo.uname), g_sFontPangWa, 18)
	nameLabel:setAnchorPoint(ccp(0.5, 1))
	nameLabel:setColor(ccc3(0x36, 0xff, 0x00))
	nameLabel:setPosition(ccp(iconSP:getContentSize().width*0.5, 0))
    iconSP:addChild(nameLabel)
	return iconSP
end

function getTableDataBy( m_data )
	local t_data = {}
	if( tonumber(m_data.guild_id ) <=0 )then

	else
		if( not table.isEmpty(m_data.list))then
			for k,v in pairs(m_data.list) do
				table.insert(t_data, v)
				-- for i=1,10 do
				-- test
				-- 	table.insert(t_data, v)
				-- end
			end
		end

		if( not table.isEmpty(m_data.offline))then
			for k,v in pairs(m_data.offline) do
				table.insert(t_data, v)
				-- for i=1,10 do
				-- test
				-- 	table.insert(t_data, v)
				-- end
			end
		end
	end
	return t_data
end

function createupTableView(data)

	if(_upTableView ~= nil)then
		_upTableView:setVisible(false)
		_upTableView:removeFromParentAndCleanup(true)
		_upTableView = nil
	end

	if(_downTableView ~= nil)then
		_downTableView:setVisible(false)
		_downTableView:removeFromParentAndCleanup(true)
		_downTableView = nil
	end

	local attackerData = {}
	local defenderData = {}
	if( not table.isEmpty(data) and not table.isEmpty(data.attacker) )then
		attackerData = getTableDataBy(data.attacker)
		offlineAttackNum = table.count(data.attacker.offline)
	end
	if( not table.isEmpty(data) and not table.isEmpty(data.defender) )then
		defenderData = getTableDataBy(data.defender)
		offlineDefineNum = table.count(data.defender.offline)
	end

	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = CCSizeMake( 115*5 , 120) --CCSizeMake(bg_sprite_up:getContentSize().width, bg_sprite_up:getContentSize().height)

		elseif fn == "cellAtIndex" then
			-- if(not a2)then
				a2 = CCTableViewCell:create()

				-- added by zhz, 将原来的sprite，改称menu
				local activeMenu = BTSensitiveMenu:create()
				if(activeMenu:retainCount()>1)then
					activeMenu:release()
					activeMenu:autorelease()
				end
				activeMenu:setPosition(ccp(0,0))
				activeMenu:setTouchPriority(-461)
				a2:addChild(activeMenu)

				-- a2:setContentSize(CCSizeMake(bg_sprite_up:getContentSize().width, bg_sprite_up:getContentSize().height))
				local starIndex = (a1 ) * 5 + 1
				if( starIndex <= #defenderData )then
					local endIndex = (a1+1) * 5
					if( endIndex > #defenderData)then
						endIndex = #defenderData
					end
					--
					local posIndex = 0
					for i=starIndex, endIndex do
						if(i<=endIndex-offlineDefineNum)then
							local heroSprite = getHeroIconSprite(defenderData[i],0)

							-- heroSprite:setAnchorPoint(ccp(0, 0))
							-- heroSprite:setPosition(ccp( 10 + (heroSprite:getContentSize().width ) * posIndex, 20))
							-- a2:addChild(heroSprite)
							-- changed by zhz
							local heroIcon = CCMenuItemSprite:create(heroSprite, heroSprite)
							heroIcon:setAnchorPoint(ccp(0, 0))
							heroIcon:setPosition(ccp( 10 + (heroIcon:getContentSize().width ) * posIndex, 20))
							activeMenu:addChild(heroIcon,1,tonumber(defenderData[i].uid))
							heroIcon:registerScriptTapHandler(rivalInfoAction )
							posIndex = posIndex + 1
						else
							local heroSprite = getHeroIconSprite(defenderData[i],1)
							local heroSpriteGray = BTGraySprite:createWithNodeAndItChild(heroSprite)

							-- heroSprite:setAnchorPoint(ccp(0, 0))
							-- heroSprite:setPosition(ccp( 10 + (heroSprite:getContentSize().width ) * posIndex, 20))
							-- a2:addChild(heroSprite)
							-- changed by zhz
							local heroIcon = CCMenuItemSprite:create(heroSpriteGray, heroSpriteGray)
							heroIcon:setColor(ccc3(166,166,166))
							heroIcon:setAnchorPoint(ccp(0, 0))
							heroIcon:setPosition(ccp( 10 + (heroIcon:getContentSize().width ) * posIndex, 20))
							activeMenu:addChild(heroIcon,1,tonumber(defenderData[i].uid))
							heroIcon:registerScriptTapHandler(rivalInfoAction )
							posIndex = posIndex + 1
							local offlineSprite = CCSprite:create("images/citybattle/offline.png")
							heroIcon:addChild(offlineSprite)
							offlineSprite:setAnchorPoint(ccp(0,1))
							offlineSprite:setPosition(ccp(0,heroIcon:getContentSize().height))
						end
					end
				end

				r = a2
			-- end
		elseif fn == "numberOfCells" then
			r = math.ceil(#defenderData/5.0)
		elseif fn == "cellTouched" then
			print("cellTouched: " .. 1111)

		elseif (fn == "scroll") then

		end
		return r
	end)

	local down = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r =  CCSizeMake( 115*5 , 120) --CCSizeMake(bg_sprite_up:getContentSize().width, bg_sprite_up:getContentSize().height)
		elseif fn == "cellAtIndex" then
			-- if(not a2)then
				a2 = CCTableViewCell:create()

				local activeMenu = BTSensitiveMenu:create()
				if(activeMenu:retainCount()>1)then
					activeMenu:release()
					activeMenu:autorelease()
				end
				activeMenu:setPosition(ccp(0,0))
				activeMenu:setTouchPriority(-462)
				a2:addChild(activeMenu)


				-- a2:setContentSize( CCSizeMake( 115*5 , 115))--(CCSizeMake(bg_sprite_up:getContentSize().width, bg_sprite_up:getContentSize().height))
				local starIndex = (a1) * 5 + 1
				if( starIndex <= #attackerData )then
					local endIndex = (a1+1) * 5
					if( endIndex > #attackerData)then
						endIndex = #attackerData
					end

					--
					local posIndex = 0
					for i=starIndex, endIndex do
						if(i<=endIndex-offlineAttackNum)then
							local heroSprite = getHeroIconSprite(attackerData[i],0)
							-- heroSprite:setAnchorPoint(ccp(0, 0))
							-- heroSprite:setPosition(ccp( 10 + (heroSprite:getContentSize().width) * posIndex, 20))
							-- a2:addChild(heroSprite)
							-- changed by zhz
							local heroIcon = CCMenuItemSprite:create(heroSprite, heroSprite)
							heroIcon:setAnchorPoint(ccp(0, 0))
							heroIcon:setPosition(ccp( 10 + (heroIcon:getContentSize().width ) * posIndex, 20))
							activeMenu:addChild(heroIcon,1,tonumber(attackerData[i].uid))
							heroIcon:registerScriptTapHandler(rivalInfoAction )

							posIndex = posIndex + 1
						else
							local heroSprite = getHeroIconSprite(attackerData[i],1)
							local heroSpriteGray = BTGraySprite:createWithNodeAndItChild(heroSprite)
							-- heroSprite:setColor(ccc3(166,166,166))
							-- heroSprite:setAnchorPoint(ccp(0, 0))
							-- heroSprite:setPosition(ccp( 10 + (heroSprite:getContentSize().width) * posIndex, 20))
							-- a2:addChild(heroSprite)
							-- changed by zhz
							local heroIcon = CCMenuItemSprite:create(heroSpriteGray, heroSpriteGray)
							heroIcon:setColor(ccc3(166,166,166))
							heroIcon:setAnchorPoint(ccp(0, 0))
							heroIcon:setPosition(ccp( 10 + (heroIcon:getContentSize().width ) * posIndex, 20))
							activeMenu:addChild(heroIcon,1,tonumber(attackerData[i].uid))
							heroIcon:registerScriptTapHandler(rivalInfoAction )

							posIndex = posIndex + 1
							local offlineSprite = CCSprite:create("images/citybattle/offline.png")
							heroIcon:addChild(offlineSprite)
							offlineSprite:setAnchorPoint(ccp(0,1))
							offlineSprite:setPosition(ccp(0,heroIcon:getContentSize().height))
						end

					end

				end

				r = a2
			-- end
		elseif fn == "numberOfCells" then
			r = math.ceil(#attackerData/5.0)
		elseif fn == "cellTouched" then
			print("cellTouched: " .. 1111)

		elseif (fn == "scroll") then

		end
		return r
	end)

	_upTableView = LuaTableView:createWithHandler(h, CCSizeMake(640, 240))
    _upTableView:setPosition(ccp(0, 5))
	_upTableView:setBounceable(true)
	_upTableView:setTouchPriority(-461)
	_upTableView:setVerticalFillOrder(kCCTableViewFillTopDown)

	bg_sprite_up:addChild(_upTableView,10)

	_downTableView = LuaTableView:createWithHandler(down, CCSizeMake(640, 240))
    _downTableView:setPosition(ccp(attSprite:getContentSize().width, 5))
	_downTableView:setBounceable(true)
	_downTableView:setTouchPriority(-461)
	_downTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	bg_sprite_down:addChild(_downTableView,10)

	-- local labelSize = CCLabelTTF:create("0",g_sFontPangWa,25)
	-- local battleValuSpriteUp = CCSprite:create("images/common/fight_value.png")
	-- battleValuSpriteUp:setPosition(ccp(labelSize:getContentSize().width*0.5,-labelSize:getContentSize().height*2.5))
	-- defSprite:addChild(battleValuSpriteUp)

	-- local battleValuSpriteDown = CCSprite:create("images/common/fight_value.png")
	-- battleValuSpriteDown:setPosition(ccp(labelSize:getContentSize().width*0.5,-labelSize:getContentSize().height*2.5))
	-- attSprite:addChild(battleValuSpriteDown)

	-- if(data.attacker.guild_name==guildName)then
	-- 	local attackerPower = CCLabelTTF:create(fightNum.."%",g_sFontName,21)
	-- 	attackerPower:setAnchorPoint(ccp(0.5,0))
	-- 	attackerPower:setPosition(ccp(labelSize:getContentSize().width*0.5+battleValuSpriteUp:getContentSize().width*0.5,-labelSize:getContentSize().height*2.5-battleValuSpriteDown:getContentSize().height))
	-- 	if( tonumber(fightNum) < 100 )then
	--  		attackerPower:setColor(ccc3(0xff,0x00,0x00))
	--  	else
	--  		attackerPower:setColor(ccc3(0x00,0xff,0x18))
	--  	end
	-- 	attSprite:addChild(attackerPower)
	-- else
	-- 	local attackerPower = CCLabelTTF:create("100%",g_sFontName,21)
	-- 	attackerPower:setAnchorPoint(ccp(0.5,0))
	-- 	attackerPower:setPosition(ccp(labelSize:getContentSize().width*0.5+battleValuSpriteUp:getContentSize().width*0.5,-labelSize:getContentSize().height*2.5-battleValuSpriteDown:getContentSize().height))
	-- 	-- if( tonumber(fightNum) < 100 )then
	--  -- 		attackerPower:setColor(ccc3(0xff,0x00,0x00))
	--  -- 	else
	--  		attackerPower:setColor(ccc3(0x00,0xff,0x18))
	--  	-- end
	-- 	attSprite:addChild(attackerPower)
	-- end

	-- if(data.defender.guild_name==guildName)then
	-- 	local defenderPower = CCLabelTTF:create(fightNum.."%",g_sFontName,21)
	-- 	defenderPower:setAnchorPoint(ccp(0.5,0))
	-- 	defenderPower:setPosition(ccp(labelSize:getContentSize().width*0.5+battleValuSpriteUp:getContentSize().width*0.5,-labelSize:getContentSize().height*2.5-battleValuSpriteDown:getContentSize().height))
	-- 	if( tonumber(fightNum) < 100 )then
	--  		defenderPower:setColor(ccc3(0xff,0x00,0x00))
	--  	else
	--  		defenderPower:setColor(ccc3(0x00,0xff,0x18))
	--  	end
	-- 	defSprite:addChild(defenderPower)
	-- else
	-- 	local defenderPower = CCLabelTTF:create("100%",g_sFontName,21)
	-- 	defenderPower:setAnchorPoint(ccp(0.5,0))
	-- 	defenderPower:setPosition(ccp(labelSize:getContentSize().width*0.5+battleValuSpriteUp:getContentSize().width*0.5,-labelSize:getContentSize().height*2.5-battleValuSpriteDown:getContentSize().height))
	-- 	-- if( tonumber(fightNum) < 100 )then
	--  -- 		defenderPower:setColor(ccc3(0xff,0x00,0x00))
	--  -- 	else
	--  		defenderPower:setColor(ccc3(0x00,0xff,0x18))
	--  	-- end
	-- 	attSprite:addChild(defenderPower)
	-- end
end




--------------- 开始战斗推送 ----------------------
function push_begin_battle(cbFlag, dictData, bRet)
	if(dictData.err == "ok") then
		if(readyLayer~=nil)then
            ----------------------------- added by bzx
            require "script/ui/chat/ChatMainLayer"
            ChatMainLayer.closeLayer()
            -----------------------------

            -- added by zhz
            RivalInfoLayer.closeCb()
            MakeUpFormationLayer.closeAction()


			readyLayer:setVisible(false)
			_upTableView = nil
			_downTableView = nil
			readyLayer:removeFromParentAndCleanup(true)
			readyLayer = nil
			require "script/battle/GuildBattle"
	    	GuildBattle.createLayer(dictData.ret, GuildBattle.BattleForCity)
			-- MainScene.setMainSceneViewsVisible(true,true,true)
		end
	end
end

--------------有人进入战场推送----------------------
function one_in( cbFlag, dictData, bRet )
	-- body
	getData(_cityId)
end
--------------有人离开战场推送----------------------
function one_out( cbFlag, dictData, bRet )
	-- body
	getData(_cityId)
end
--------------- 进入准备界面回调 ----------------------
function messageCallBack(dictData)
	enterData=dictData

	if(dictData.err == "ok" and dictData.ret.ret == "ok") then
		-- if(tonumber(dictData.ret.user.buy_num)==0)then
		-- 	addGoldCount = 1
		-- else
			addGoldCount = tonumber(dictData.ret.user.buy_num)
		-- end

		print("addGoldCount"..addGoldCount)
		--攻方军团名
		if(attNameLabel == nil)then
			attNameLabel = CCLabelTTF:create(dictData.ret.attacker.guild_name,g_sFontPangWa,30)
			attNameLabel:setAnchorPoint(ccp(1,0.5))
			attNameLabel:setPosition(ccp(vsSprite:getContentSize().width*0.4,vsSprite:getContentSize().height*0.5))
			vsSprite:addChild(attNameLabel)
		end

		--守方军团名
		if(defNameLabel == nil)then
			defNameLabel = CCLabelTTF:create(dictData.ret.defender.guild_name,g_sFontPangWa,30)
			defNameLabel:setAnchorPoint(ccp(0,0.5))
			defNameLabel:setPosition(ccp(vsSprite:getContentSize().width*0.6,vsSprite:getContentSize().height*0.5))
			vsSprite:addChild(defNameLabel)
		end

		--鼓舞时间
		if(tonumber(dictData.ret.user.inspire_cd)>tonumber(TimeUtil.getSvrTimeByOffset()))then
			canclick = false
			local time = dictData.ret.user.inspire_cd-TimeUtil.getSvrTimeByOffset()
			if(spreLabel~=nil)then
				spreLabel:stopAllActions()
				spreLabel:setVisible(false)
				spreLabel:removeFromParentAndCleanup(true)
				spreLabel = nil
			end

			spreLabel = CCLabelTTF:create(TimeUtil.getTimeString(time),g_sFontPangWa,21)
			spreLabel:setColor(ccc3(0x00,0xff,0x18))
			spreLabel:setPosition(ccp(0,agspreItem:getContentSize().height*0.5))
			agspreItem:addChild(spreLabel,1)
			local function refreshTime( ... )
				-- body
				if(tonumber(dictData.ret.user.inspire_cd)~=tonumber(TimeUtil.getSvrTimeByOffset()))then
					spreLabel:setString(TimeUtil.getTimeString(dictData.ret.user.inspire_cd-TimeUtil.getSvrTimeByOffset()))
				else
					print("i'am in")
					canclick = true
					spreLabel:stopAllActions()
					spreLabel:setVisible(false)
					spreLabel:removeFromParentAndCleanup(true)
					spreLabel = nil
				end
			end

			local delay = CCDelayTime:create(1)
		    local callfunc = CCCallFunc:create(function ( ... )refreshTime() end)
		    local sequence = CCSequence:createWithTwoActions(delay, callfunc)
		    local action = CCRepeatForever:create(sequence)
		    spreLabel:runAction(action)
			---------
		end
		local data = DB_Legion_citybattle.getDataById(1)
		local affixTable = {}
	    local strNum1 = tonumber(string.split(data.attackAffix,"|")[2])
	    local strNum2 = tonumber(string.split(data.defendAffix,"|")[2])
	    local count1 = dictData.ret.user.attack_level*(strNum1)
	    local count2 = dictData.ret.user.defend_level*(strNum2)
	    print("count1"..count1)
	    print("count2"..count2)
	    affixTable[1] = count1
	    affixTable[2] = count2

	    -- added by zhz
	    local atkDescLabel = CCRenderLabel:create( GetLocalizeStringBy("key_4007") , g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    atkDescLabel:setAnchorPoint(ccp(0, 1))
	    atkDescLabel:setColor(ccc3(0xf3, 0x00, 0x00))
	    atkDescLabel:setPosition(ccp(attAddSprite:getContentSize().width, attAddSprite:getContentSize().height))
	    attAddSprite:addChild(atkDescLabel)

		--攻击加成数字
		if(attLabel~=nil)then
			attLabel:setString((affixTable[1]/100).."%")
		else
			attLabel = CCLabelTTF:create((affixTable[1]/100).."%",g_sFontPangWa,21)
			attLabel:setColor(ccc3(0xff,0xf6,0x00))
			attLabel:setAnchorPoint(ccp(0,0.5))
			attLabel:setPosition(ccp(attAddSprite:getContentSize().width,attLabel:getContentSize().height*0.5))
			attAddSprite:addChild(attLabel)


		end
		--防御加成数字
		if(defLabel~=nil)then
			defLabel:setString((affixTable[2]/100).."%")
		else
			defLabel = CCLabelTTF:create((affixTable[2]/100).."%",g_sFontPangWa,21)
			defLabel:setColor(ccc3(0xff,0xf6,0x00))
			defLabel:setAnchorPoint(ccp(0,0.5))
			defLabel:setPosition(ccp(defAddSprite:getContentSize().width,defLabel:getContentSize().height*0.5))
			defAddSprite:addChild(defLabel)
		end

		-- added by zhz
	    local defDescLabel = CCRenderLabel:create( GetLocalizeStringBy("key_4008") , g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    defDescLabel:setAnchorPoint(ccp(0, 1))
	    defDescLabel:setColor(ccc3(0x00, 0xff, 0x18))
	    defDescLabel:setPosition(ccp(defAddSprite:getContentSize().width, defAddSprite:getContentSize().height+2 ))
	    defAddSprite:addChild(defDescLabel)
		--连胜加成数字
		if(addWinLabel~=nil)then
			addWinLabel:setVisible(false)
			addWinLabel:removeFromParentAndCleanup(true)
			addWinLabel = nil
		end
			addWinLabel = CCLabelTTF:create(data.defaultWin+addGoldCount,g_sFontPangWa,21)
			addWinLabel:setColor(ccc3(0xff,0xf6,0x00))
			addWinLabel:setAnchorPoint(ccp(0,0.5))
			addWinLabel:setPosition(ccp(addWinSprite:getContentSize().width*0.5+addWinLabel:getContentSize().width*2,addWinLabel:getContentSize().height*0.5))
			addWinSprite:addChild(addWinLabel)


		--金币花费增加连胜
		-- body
		local data = DB_Legion_citybattle.getDataById(1)
		print("addGoldCount"..addGoldCount)
		local t = string.split(data.WinCost, ",")
		local nextCount = tonumber(addGoldCount) + 1
		if( nextCount > #t  )then
			nextCount = #t
		end
		if(goldLabel~=nil)then
			goldLabel:setVisible(false)
			goldLabel:removeFromParentAndCleanup(true)
			goldLabel = nil
		end
		goldLabel = CCLabelTTF:create(t2[nextCount][1],g_sFontPangWa,21)
		goldLabel:setPosition(ccp(goldCoinSprite:getContentSize().width,0))
		goldCoinSprite:addChild(goldLabel)

		refreshwinData(dictData)

		createupTableView(dictData.ret)
	end
end

--------------刷新界面数据---------------------
function refreshwinData(dictData)
		-- body
		--守方阵容人数
		local data = DB_Legion_citybattle.getDataById(1)
		if(onCountLabel == nil)then
			local num = table.count(dictData.ret.defender.list)+table.count(dictData.ret.defender.offline).."/"
			onCountLabel = CCLabelTTF:create(num,g_sFontPangWa,25)
			onCountLabel:setColor(ccc3(0x00,0xff,0x18))
			onCountLabel:setPosition(ccp(onCountLabel:getContentSize().width*0.5,-onCountLabel:getContentSize().height))
			defSprite:addChild(onCountLabel)
		else
			local num = table.count(dictData.ret.defender.list)+table.count(dictData.ret.defender.offline).."/"
			onCountLabel:setString(num)
		end
		if(totalCountLabel == nil)then
			totalCountLabel = CCLabelTTF:create(tostring(data.maxJoinNum),g_sFontPangWa,25)
			totalCountLabel:setColor(ccc3(0xf3,0x00,0x00))
			totalCountLabel:setPosition(ccp(onCountLabel:getContentSize().width+totalCountLabel:getContentSize().width*0.5,-onCountLabel:getContentSize().height))
			defSprite:addChild(totalCountLabel)
		else
			totalCountLabel:setPosition(ccp(onCountLabel:getContentSize().width+totalCountLabel:getContentSize().width*0.5,-onCountLabel:getContentSize().height))
		end

		--攻方阵容人数
		if(onCountLabel_down == nil)then
			local num = table.count(dictData.ret.attacker.list)+table.count(dictData.ret.attacker.offline).."/"
			onCountLabel_down = CCLabelTTF:create(num,g_sFontPangWa,25)
			onCountLabel_down:setColor(ccc3(0x00,0xff,0x18))
			onCountLabel_down:setPosition(ccp(onCountLabel_down:getContentSize().width*0.5,-onCountLabel_down:getContentSize().height))
			attSprite:addChild(onCountLabel_down)
		else
			local num = table.count(dictData.ret.attacker.list)+table.count(dictData.ret.attacker.offline).."/"
			onCountLabel_down:setString(num)
		end

		if(totalCountLabel_down == nil)then
			totalCountLabel_down = CCLabelTTF:create(tostring(data.maxJoinNum),g_sFontPangWa,25)
			totalCountLabel_down:setColor(ccc3(0xf3,0x00,0x00))
			totalCountLabel_down:setPosition(ccp(onCountLabel_down:getContentSize().width+totalCountLabel_down:getContentSize().width*0.5,-onCountLabel_down:getContentSize().height))
			attSprite:addChild(totalCountLabel_down)
		else
			totalCountLabel_down:setPosition(ccp(onCountLabel_down:getContentSize().width+totalCountLabel_down:getContentSize().width*0.5,-onCountLabel_down:getContentSize().height))
		end
		if(battleValuSpriteUp~=nil)then
			battleValuSpriteUp:removeFromParentAndCleanup(true)
			battleValuSpriteUp = nil
		end

		if(battleValuSpriteDown~=nil)then
			battleValuSpriteDown:removeFromParentAndCleanup(true)
			battleValuSpriteDown = nil
		end
		local labelSize = CCLabelTTF:create("0",g_sFontPangWa,25)
		battleValuSpriteUp = CCSprite:create("images/common/fight_value.png")
		battleValuSpriteUp:setPosition(ccp(labelSize:getContentSize().width*0.5,-labelSize:getContentSize().height*2.5))
		defSprite:addChild(battleValuSpriteUp)

		-- print(dictData.ret.defender.guild_name.."dictData.ret.defender.guild_name----~~~~~~~~~")
		-- if(guildName==nil and dictData.ret.defender.guild_name==nil)then
		-- 	battleValuSpriteUp:setVisible(false)
		-- else
		-- 	battleValuSpriteUp:setVisible(true)
		-- end

		battleValuSpriteDown = CCSprite:create("images/common/fight_value.png")
		battleValuSpriteDown:setPosition(ccp(labelSize:getContentSize().width*0.5,-labelSize:getContentSize().height*2.5))
		attSprite:addChild(battleValuSpriteDown)

		if(attackerPower~=nil)then
			attackerPower:removeFromParentAndCleanup(true)
			attackerPower = nil
		end

		if(defenderPower~=nil)then
			defenderPower:removeFromParentAndCleanup(true)
			defenderPower = nil
		end

		if(dictData.ret.attacker.guild_name==guildName)then
			attackerPower = CCLabelTTF:create(fightNum.."%",g_sFontName,21)
			attackerPower:setAnchorPoint(ccp(0.5,0))
			attackerPower:setPosition(ccp(labelSize:getContentSize().width*0.5+battleValuSpriteUp:getContentSize().width*0.5,-labelSize:getContentSize().height*2.5-battleValuSpriteDown:getContentSize().height))
			if( tonumber(fightNum) < 100 )then
		 		attackerPower:setColor(ccc3(0xff,0x00,0x00))
		 	else
		 		attackerPower:setColor(ccc3(0x00,0xff,0x18))
		 	end
			attSprite:addChild(attackerPower)
			attackerPower:setTag(1)
		else
			attackerPower = CCLabelTTF:create("100%",g_sFontName,21)
			attackerPower:setAnchorPoint(ccp(0.5,0))
			attackerPower:setPosition(ccp(labelSize:getContentSize().width*0.5+battleValuSpriteUp:getContentSize().width*0.5,-labelSize:getContentSize().height*2.5-battleValuSpriteDown:getContentSize().height))
		 	attackerPower:setColor(ccc3(0x00,0xff,0x18))
			attSprite:addChild(attackerPower)
			attackerPower:setTag(1)
		end

		if(dictData.ret.defender.guild_name==guildName)then
			defenderPower = CCLabelTTF:create(fightNum.."%",g_sFontName,21)
			defenderPower:setAnchorPoint(ccp(0.5,0))
			defenderPower:setPosition(ccp(labelSize:getContentSize().width*0.5+battleValuSpriteUp:getContentSize().width*0.5,-labelSize:getContentSize().height*2.5-battleValuSpriteDown:getContentSize().height))
			if( tonumber(fightNum) < 100 )then
		 		defenderPower:setColor(ccc3(0xff,0x00,0x00))
		 	else
		 		defenderPower:setColor(ccc3(0x00,0xff,0x18))
		 	end
			defSprite:addChild(defenderPower)
		else
			defenderPower = CCLabelTTF:create("100%",g_sFontName,21)
			defenderPower:setAnchorPoint(ccp(0.5,0))
			defenderPower:setPosition(ccp(labelSize:getContentSize().width*0.5+battleValuSpriteUp:getContentSize().width*0.5,-labelSize:getContentSize().height*2.5-battleValuSpriteDown:getContentSize().height))
		 	defenderPower:setColor(ccc3(0x00,0xff,0x18))
			defSprite:addChild(defenderPower)
		end
end
