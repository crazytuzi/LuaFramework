-- Filename: CheerUpLayer.lua
-- Author: Zhang Zihang
-- Date: 2014-07-18
-- Purpose: 助威提示界面

module("CheerUpLayer", package.seeall)

require "script/ui/main/MainScene"
require "script/audio/AudioUtil"
require "script/model/hero/HeroModel"
require "script/model/utils/HeroUtil"
require "script/utils/BaseUI"
require "script/model/user/UserModel"
require "script/ui/tip/AnimationTip"
require "script/ui/olympic/OlympicData"

local _bgLayer
local _brownBgSprite
local _touchPriority
local _ZOder
local _callBackFunc
local _playerInfo

----------------------------------------初始化函数----------------------------------------
local function init()
	_bgLayer = nil 			--触摸屏蔽层
	_brownBgSprite = nil 	--棕色二级背景图
	_touchPriority = nil 	--触摸优先级
	_ZOder = nil 			--Z轴
	_callBackFunc = nil 	--回调函数
	_playerInfo = nil 		--受鼓舞人信息
end

----------------------------------------触摸事件函数----------------------------------------
local function onTouchesHandler(eventType,x,y)
	if (eventType == "began") then
	    return true
    elseif (eventType == "moved") then
    	print("moved")
    else
        print("end")
	end
end

local function onNodeEvent(event)
	if event == "enter" then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler,false,_touchPriority,true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

----------------------------------------回调函数----------------------------------------
--[[
	@des 	:关闭按钮回调
	@param 	:
	@return :
--]]
function closeCallBack()
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end

--[[
	@des 	:确定按钮回调
	@param 	:
	@return :
--]]
function sureCallBack()
	if tonumber(UserModel.getSilverNumber()) < tonumber(OlympicData.getCheerCostSilver()) then
		AnimationTip.showTip(GetLocalizeStringBy("zzh_1045"))
	elseif OlympicData.getStage() >= 7 then
		AnimationTip.showTip(GetLocalizeStringBy("zzh_1056"))
	else
		cheerOverCallback = function(cbFlag,dictData,bRet)
			if not bRet then
				return
			end
			if cbFlag == "olympic.cheer" then
				--增加助威数目
				--OlympicData.addPlayerCheerNum(_playerInfo.uid)
				UserModel.addSilverNumber(tonumber(-OlympicData.getCheerCostSilver()))
				_callBackFunc()
				closeCallBack()
			end
		end

		require "script/network/Network"
		local arg = CCArray:create()
		arg:addObject(CCInteger:create(_playerInfo.uid))
		Network.rpc(cheerOverCallback,"olympic.cheer","olympic.cheer",arg,true)
	end
end

----------------------------------------UI函数----------------------------------------
--[[
	@des 	:背景UI
	@param 	:
	@return :
--]]
function createBgUI()
	--主背景UI
	local bgSprite = CCScale9Sprite:create("images/common/viewbg1.png")
	bgSprite:setContentSize(CCSizeMake(620,570))
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setPosition(ccp(_bgLayer:getContentSize().width/2,_bgLayer:getContentSize().height/2))
	bgSprite:setScale(MainScene.elementScale)
	_bgLayer:addChild(bgSprite)

	--标题背景
	local titleBgSprite = CCSprite:create("images/common/viewtitle1.png")
	titleBgSprite:setAnchorPoint(ccp(0.5,0.5))
	titleBgSprite:setPosition(ccp(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height - 6))
	bgSprite:addChild(titleBgSprite)

	--标题文字
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1038"),g_sFontPangWa,33)
	titleLabel:setColor(ccc3(0xff,0xe4,0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titleBgSprite:getContentSize().width/2,titleBgSprite:getContentSize().height/2))
	titleBgSprite:addChild(titleLabel)

	--描述文字图
	local desSprite = CCSprite:create("images/olympic/cheer_up/describe.png")
	desSprite:setAnchorPoint(ccp(0.5,1))
	desSprite:setPosition(ccp(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height - 75))
	bgSprite:addChild(desSprite)

	--棕色二级背景框
	_brownBgSprite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	_brownBgSprite:setContentSize(CCSizeMake(575,200))
	_brownBgSprite:setAnchorPoint(ccp(0.5,1))
	_brownBgSprite:setPosition(ccp(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height - 140))
	bgSprite:addChild(_brownBgSprite)

	--说明文本 1
	local tipLabel_1 = CCRenderLabel:create(GetLocalizeStringBy("key_1088"),g_sFontPangWa,21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	tipLabel_1:setColor(ccc3(0x00,0xe4,0xff))
	local silverSprite = CCSprite:create("images/common/coin.png")
	local costNumLabel = CCRenderLabel:create(tostring(OlympicData.getCheerCostSilver()),g_sFontPangWa,21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	costNumLabel:setColor(ccc3(0x00,0xff,0x18))
	local toLabel = CCRenderLabel:create(GetLocalizeStringBy("zzh_1040"),g_sFontPangWa,21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	toLabel:setColor(ccc3(0x00,0xe4,0xff))
	local playerNameLabel = CCRenderLabel:create(tostring(_playerInfo.uname),g_sFontPangWa,21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	playerNameLabel:setColor(ccc3(0x00,0xe4,0xff))
	local tipLabel_2 = CCRenderLabel:create(GetLocalizeStringBy("zzh_1041"),g_sFontPangWa,21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	tipLabel_2:setColor(ccc3(0x00,0xe4,0xff))

	--拼接node 1
	local node_1 = BaseUI.createHorizontalNode({tipLabel_1,silverSprite,costNumLabel,toLabel,playerNameLabel,tipLabel_2})
	node_1:setAnchorPoint(ccp(0.5,0))
	node_1:setPosition(ccp(bgSprite:getContentSize().width/2,180))
	bgSprite:addChild(node_1)

	--说明文本 2
	local tipLabel_3 = CCRenderLabel:create(GetLocalizeStringBy("zzh_1042"),g_sFontPangWa,21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	tipLabel_3:setColor(ccc3(0x00,0xff,0x18))
	local tipLabel_4 = CCRenderLabel:create(GetLocalizeStringBy("zzh_1043"),g_sFontPangWa,21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	tipLabel_4:setColor(ccc3(0xe4,0x00,0xff))
	local tipLabel_5 = CCRenderLabel:create(GetLocalizeStringBy("zzh_1044"),g_sFontPangWa,21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	tipLabel_5:setColor(ccc3(0x00,0xff,0x18))

	--拼接node 2
	local node_2 = BaseUI.createHorizontalNode({tipLabel_3,tipLabel_4,tipLabel_5})
	node_2:setAnchorPoint(ccp(0.5,0))
	node_2:setPosition(ccp(bgSprite:getContentSize().width/2,140))
	bgSprite:addChild(node_2)

	--背景按钮层
	local bgMenu = CCMenu:create()
	bgMenu:setAnchorPoint(ccp(0,0))
	bgMenu:setPosition(ccp(0,0))
	bgMenu:setTouchPriority(_touchPriority - 1)
	bgSprite:addChild(bgMenu)

	--关闭按钮
	local closeMenuItem = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeMenuItem:setPosition(ccp(bgSprite:getContentSize().width*1.03,bgSprite:getContentSize().height*1.03))
    closeMenuItem:setAnchorPoint(ccp(1,1))
    closeMenuItem:registerScriptTapHandler(closeCallBack)
    bgMenu:addChild(closeMenuItem)

    --确定按钮
    local sureMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_1465"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    sureMenuItem:setAnchorPoint(ccp(0,0))
    sureMenuItem:setPosition(ccp(70,45))
    sureMenuItem:registerScriptTapHandler(sureCallBack)
    bgMenu:addChild(sureMenuItem)

    --取消按钮
    local undoMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_2326"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    undoMenuItem:setAnchorPoint(ccp(1,0))
    undoMenuItem:setPosition(ccp(bgSprite:getContentSize().width - 70,45))
    undoMenuItem:registerScriptTapHandler(closeCallBack)
    bgMenu:addChild(undoMenuItem)
end

--[[
	@des 	:创建二级背景内部UI
	@param 	:
	@return :
--]]
function createInnerUI()
	--金色头像背景
	local goldSquareSprite = CCSprite:create("images/everyday/headBg1.png")
	goldSquareSprite:setAnchorPoint(ccp(0,0.5))
	goldSquareSprite:setPosition(ccp(30,_brownBgSprite:getContentSize().height/2))
	_brownBgSprite:addChild(goldSquareSprite)

	local genderId = HeroModel.getSex(_playerInfo.htid)

	local playerSprite

	if (table.count(_playerInfo.dress) == 0 ) then
		playerSprite = HeroUtil.getHeroIconByHTID(_playerInfo.htid,nil,nil,_playerInfo.vip)
	else
		playerSprite = HeroUtil.getHeroIconByHTID(_playerInfo.htid,_playerInfo.dress["1"],genderId,_playerInfo.vip)
	end

	playerSprite:setAnchorPoint(ccp(0.5,0.5))
	playerSprite:setPosition(ccp(goldSquareSprite:getContentSize().width/2,goldSquareSprite:getContentSize().height/2))
	goldSquareSprite:addChild(playerSprite)

	local namePosX = 180
	local namePosY = _brownBgSprite:getContentSize().height - 30

	--玩家名字
	local playerNameLabel = CCLabelTTF:create(tostring(_playerInfo.uname),g_sFontPangWa,21)
	playerNameLabel:setColor(ccc3(0xff,0xf6,0x00))
	playerNameLabel:setAnchorPoint(ccp(0,1))
	playerNameLabel:setPosition(ccp(namePosX,namePosY))
	_brownBgSprite:addChild(playerNameLabel)

	namePosX = namePosX + 10 + playerNameLabel:getContentSize().width

	--等级图片
	local lvSprite = CCSprite:create("images/common/lv.png")
	lvSprite:setAnchorPoint(ccp(0,1))
	lvSprite:setPosition(ccp(namePosX,namePosY))
	_brownBgSprite:addChild(lvSprite)

	namePosX = namePosX + lvSprite:getContentSize().width

	--等级label
	local lvLabel = CCLabelTTF:create(tostring(_playerInfo.level),g_sFontName,18)
	lvLabel:setColor(ccc3(0xff,0xf6,0x00))
	lvLabel:setAnchorPoint(ccp(0,1))
	lvLabel:setPosition(ccp(namePosX,namePosY))
	_brownBgSprite:addChild(lvLabel)

	local fightPosX = 180

	--战斗力图片
	local fightNumSprite = CCSprite:create("images/common/fight_value.png")
	fightNumSprite:setAnchorPoint(ccp(0,1))
	fightNumSprite:setPosition(ccp(fightPosX,namePosY - 50))
	_brownBgSprite:addChild(fightNumSprite)

	fightPosX = fightPosX + 10 + fightNumSprite:getContentSize().width

	--战斗力label
	local fightForceLabel = CCLabelTTF:create(tostring(_playerInfo.fight_force),g_sFontPangWa,18)
	fightForceLabel:setColor(ccc3(0xff,0xf6,0x00))
	fightForceLabel:setAnchorPoint(ccp(0,1))
	fightForceLabel:setPosition(ccp(fightPosX,namePosY - 50))
	_brownBgSprite:addChild(fightForceLabel)

	--阴影背景
	local shadowSprite = CCSprite:create("images/arena/item_name_bg.png")
	shadowSprite:setAnchorPoint(ccp(0,1))
	shadowSprite:setPosition(ccp(180,namePosY - 100))
	_brownBgSprite:addChild(shadowSprite)

	--获得助威数 文本
	local gainLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1039"),g_sFontName,21)
	gainLabel:setColor(ccc3(0xff,0xff,0xff))
	gainLabel:setAnchorPoint(ccp(0,0.5))
	gainLabel:setPosition(ccp(20,shadowSprite:getContentSize().height/2))
	shadowSprite:addChild(gainLabel)

	--助威数
	local gainNumLabel
	if _playerInfo.be_cheer_num == nil then
		gainNumLabel = CCLabelTTF:create("0",g_sFontName,21)
	else
		gainNumLabel = CCLabelTTF:create(tostring(_playerInfo.be_cheer_num),g_sFontName,21)
	end
	gainNumLabel:setColor(ccc3(0x00,0xff,0x18))
	gainNumLabel:setAnchorPoint(ccp(0,0.5))
	gainNumLabel:setPosition(ccp(20 + gainLabel:getContentSize().width,shadowSprite:getContentSize().height/2))
	shadowSprite:addChild(gainNumLabel)
end

----------------------------------------入口函数----------------------------------------
function showLayer(p_playerInfo,p_callBack,p_touchPriority,p_ZOrder)
	init()

	_touchPriority = p_touchPriority or -550
	_ZOder = p_ZOrder or 999
	_callBackFunc = p_callBack
	--playerInfo结构
	--		   sign_up_index:int    报名位置
    --         olympic_index:int    比赛位置
    --         final_rank:int        排名
    --         uid:int
    --         uname:int
    --         dress:array
    --         htid:int
    --     	   level:int
    --         fight_force:int
    --         be_cheer_num:int
	_playerInfo = p_playerInfo

	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)
	local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,_ZOder)

    --创建背景UI
    createBgUI()

    --创建二级背景内部UI
    createInnerUI()
end