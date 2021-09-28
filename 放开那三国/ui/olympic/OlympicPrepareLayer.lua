-- Filename: OlympicPrepareLayer.lua
-- Author: lichenyang
-- Date: 2014-07-14
-- Purpose: 擂台争霸准备界面

require "script/utils/BaseUI"
require "script/ui/olympic/OlympicService"
require "script/ui/olympic/OlympicData"

module("OlympicPrepareLayer",package.seeall)

local _bgLayer         = nil
local _timeString      = nil
local _enterTime       = nil
local _nowStageEndTime = 0
local _desTimeNode     = nil
local _preLabel 	   = nil
local _startLabel 	   = nil
function init( ... )
	_bgLayer         = nil
	_timeString      = nil
	_enterTime       = nil
	_desTimeNode	 = nil
	_nowStageEndTime = 0
	_preLabel 	     = nil
	_startLabel 	 = nil
end

-----------------------------------[[ 节点事件 ]]------------------------------
function registerNodeEvent( ... )
	_bgLayer:registerScriptHandler(function ( nodeType )
		if(nodeType == "exit") then

		end
	end)
end


------------------------------------[[ ui 创建方法 ]]-----------------------------------------

--[[
	@des: 进入擂台争霸场景
--]]
function enter( ... )
	local seq = CCSequence:createWithTwoActions(
		CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
			local stageIndex = OlympicData.getStage()
			if(stageIndex == 0) then
    			OlympicPrepareLayer.show()
			elseif(stageIndex == 1 or stageIndex == 2) then
				require "script/ui/olympic/OlympicRegisterLayer"
				OlympicRegisterLayer.show()
			elseif(stageIndex >= 3 and stageIndex <6) then
				require "script/ui/olympic/Olympic32Layer"
				Olympic32Layer.show()
			elseif(stageIndex >=6) then
				require "script/ui/olympic/Olympic4Layer"
				Olympic4Layer.show()
			else
				require "script/ui/tip/AnimationTip"
            	AnimationTip.showTip(GetLocalizeStringBy("zz_130"))
			end
		end
	))
	seq:retain()
	OlympicService.enterOlympic(function ( ... )
		OlympicService.getInfo(function ( ... )
			local runningScene = CCDirector:sharedDirector():getRunningScene()
			runningScene:runAction(seq)
			seq:release()
		end)
	end)
end

--[[
	@des : 显示擂台争霸场景
--]]
function show( ... )
    local layer = OlympicPrepareLayer.createLayer()
    MainScene.changeLayer(layer, "OlympicPrepareLayer")
end

--[[
	@des : 创建擂台争霸准备场景
--]]
function createLayer( ... )
	init()
	_bgLayer = CCLayer:create()

	local bgSprite = CCSprite:create("images/olympic/main_bg.jpg")
	bgSprite:setAnchorPoint(ccp(0.5, 0))
	bgSprite:setPosition(ccps(0.5, 0))
	bgSprite:setScale(g_fBgScaleRatio)
	_bgLayer:addChild(bgSprite)

	MainScene.setMainSceneViewsVisible(false, false, true)
	local bulletinLayerSize = BulletinLayer.getLayerContentSize()
	_layerSize              = {width= 0, height=0}
	_layerSize.width        = g_winSize.width 
	_layerSize.height       =g_winSize.height - (bulletinLayerSize.height)*g_fScaleX
	_bgLayer:setContentSize(CCSizeMake(_layerSize.width, _layerSize.height))


	crateTopUI()
	createCenterUI()
	OlympicService.regisgerStagechangePush(stageChangePushCallback)
	schedule(_bgLayer, updateTimeFunc, 1)

	return _bgLayer
end

--[[
	@des : 	创建顶部ui
--]]
function crateTopUI( ... )

	local _topBg = CCSprite:create("images/hero/avatar_attr_bg.png")
    _topBg:setAnchorPoint(ccp(0,1))
    _topBg:setPosition(0,_layerSize.height)
    _topBg:setScale(g_fScaleX)
    _bgLayer:addChild(_topBg, 10)

    local powerDescLabel = CCSprite:create("images/common/fight_value.png")
    powerDescLabel:setAnchorPoint(ccp(0.5,0.5))
    powerDescLabel:setPosition(_topBg:getContentSize().width*0.13,_topBg:getContentSize().height*0.43)
    _topBg:addChild(powerDescLabel)
    
    local _powerLabel = CCRenderLabel:create( UserModel.getFightForceValue(), g_sFontName, 23, 1.5, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _powerLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    _powerLabel:setPosition(_topBg:getContentSize().width*0.23,_topBg:getContentSize().height*0.66)
    _topBg:addChild(_powerLabel)
    
    local _silverLabel = CCLabelTTF:create(string.convertSilverUtilByInternational(UserModel.getSilverNumber()),g_sFontName,18)-- modified by yangrui at 2015-12-03
    _silverLabel:setColor(ccc3(0xe5,0xf9,0xff))
    _silverLabel:setAnchorPoint(ccp(0,0.5))
    _silverLabel:setPosition(_topBg:getContentSize().width*0.61,_topBg:getContentSize().height*0.43)
    _topBg:addChild(_silverLabel)
    
    _goldLabel = CCLabelTTF:create(UserModel.getGoldNumber()  ,g_sFontName,18)
    _goldLabel:setColor(ccc3(0xff,0xe2,0x44))
    _goldLabel:setAnchorPoint(ccp(0,0.5))
    _goldLabel:setPosition(_topBg:getContentSize().width*0.82,_topBg:getContentSize().height*0.43)
    _topBg:addChild(_goldLabel)

    --更新layerSize
    _layerSize.height       =_layerSize.height - _topBg:getContentSize().height*g_fScaleX
    _bgLayer:setContentSize(CCSizeMake(_layerSize.width, _layerSize.height))


	local menu = CCMenu:create()
	menu:setPosition(ccp(0,0))
	menu:setAnchorPoint(ccp(0,0))
	_bgLayer:addChild(menu)

	local closeButton = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:registerScriptTapHandler(closeButtonCallFunc)
	closeButton:setPosition(ccp(_layerSize.width * 0.9 ,_layerSize.height * 0.93))
	menu:addChild(closeButton)
	closeButton:setScale(MainScene.elementScale)

	--奖池按钮
	local rewardPoolButton = CCMenuItemImage:create("images/olympic/reward_pool_n.png","images/olympic/reward_pool_h.png")
	rewardPoolButton:setAnchorPoint(ccp(0.5, 0.5))
	rewardPoolButton:registerScriptTapHandler(rewardPoolButtonCallback)
	rewardPoolButton:setPosition(ccp(_layerSize.width * 0.55 ,_layerSize.height * 0.93))
	menu:addChild(rewardPoolButton)
	rewardPoolButton:setScale(MainScene.elementScale)

	--奖励预览按钮
	local rewardPreviewButton = CCMenuItemImage:create("images/olympic/olympic_reward_n.png","images/olympic/olympic_reward_h.png")
	rewardPreviewButton:setAnchorPoint(ccp(0.5, 0.5))
	rewardPreviewButton:registerScriptTapHandler(rewardPreviewButtonCallback)
	rewardPreviewButton:setPosition(ccp(_layerSize.width * 0.73 ,_layerSize.height * 0.93))
	menu:addChild(rewardPreviewButton)
	rewardPreviewButton:setScale(MainScene.elementScale)

	 -- local powerDescLabel = CCSprite:create("images/common/fight_value.png")
  --   powerDescLabel:setAnchorPoint(ccp(0.5,0.5))
  --   powerDescLabel:setPosition(_topBg:getContentSize().width*0.13,_topBg:getContentSize().height*0.43)
  --   _bgLayer:addChild(powerDescLabel)


    local titleSprite = CCSprite:create("images/olympic/title.png")
    titleSprite:setPosition(ccp(_layerSize.width * 0.05 ,_layerSize.height * 0.93))
    titleSprite:setAnchorPoint(ccp(0,0.5))
    _bgLayer:addChild(titleSprite)
    titleSprite:setScale(MainScene.elementScale)


end

--[[
	@des :	创建中部ui
--]]
function createCenterUI( ... )
	
	local championInfo = OlympicData.getChampionInfo()
	if(championInfo ~= nil and tonumber(championInfo.uid) ~= 0) then
		local taiZi = CCSprite:create("images/olympic/tai_zi.png")
		taiZi:setPosition(ccp(_layerSize.width *0.5, _layerSize.height * 0.35))
		taiZi:setAnchorPoint(ccp(0.5, 0))
		_bgLayer:addChild(taiZi)
		taiZi:setScale(MainScene.elementScale)

		local kingSprite = HeroUtil.getHeroBodySpriteByHTID(championInfo.htid, championInfo.dress["1"], HeroModel.getSex(championInfo.htid))
		kingSprite:setPosition(ccp(taiZi:getContentSize().width *0.4, taiZi:getContentSize().height * 0.5))
		kingSprite:setAnchorPoint(ccp(0.5, 0))
		taiZi:addChild(kingSprite)
		kingSprite:setScale(0.7)

		local kingHat = CCSprite:create("images/olympic/king_hat.png")
		kingHat:setPosition(ccp(kingSprite:getContentSize().width *0.55, kingSprite:getContentSize().height * 0.85))
		kingHat:setAnchorPoint(ccp(0.5, 0))
		kingSprite:addChild(kingHat)
		kingHat:setScale(1.6)

		local nameLabel = CCRenderLabel:create( championInfo.uname , g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		nameLabel:setColor(ccc3(0xff,0xf6,0x00))

		local levelLabel = CCRenderLabel:create( "Lv." .. championInfo.level, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		levelLabel:setColor(ccc3(0xff,0xf6,0x00))

		local desNodeTable = BaseUI.createHorizontalNode({nameLabel,levelLabel})
		desNodeTable:setAnchorPoint(ccp(0.5, 0))
		desNodeTable:setPosition(ccp(0.5*_layerSize.width, _layerSize.height * 0.28))
		_bgLayer:addChild(desNodeTable)
		desNodeTable:setScale(MainScene.elementScale)
	end

	
	local menu = CCMenu:create()
	menu:setTouchPriority(-600)
	menu:setPosition(ccp(0,0))
	menu:setAnchorPoint(ccp(0,0))
	_bgLayer:addChild(menu)

	--活动说明按钮
	local explainButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", CCSizeMake(180,73), GetLocalizeStringBy("lcy_10048"), ccc3(255,222,0))
	explainButton:setAnchorPoint(ccp(0.5, 0.5))
	explainButton:registerScriptTapHandler(explainButtonCallback)
	explainButton:setPosition(ccp(_layerSize.width * 0.25 ,_layerSize.height * 0.12))
	menu:addChild(explainButton)
	explainButton:setScale(MainScene.elementScale)

	--进入赛场
	local enterButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", CCSizeMake(180,73), GetLocalizeStringBy("lcy_10049"), ccc3(255,222,0))
	enterButton:setAnchorPoint(ccp(0.5, 0.5))
	enterButton:registerScriptTapHandler(enterButtonCallback)
	enterButton:setPosition(ccp(_layerSize.width * 0.75 ,_layerSize.height * 0.12))
	menu:addChild(enterButton)
	enterButton:setScale(MainScene.elementScale)

	local openTimeSprite = CCSprite:create("images/olympic/open_time_des.png")
	openTimeSprite:setAnchorPoint(ccp(0.5, 0.5))
	openTimeSprite:setPosition(ccp(_layerSize.width * 0.5 ,_layerSize.height * 0.18))
	_bgLayer:addChild(openTimeSprite)
	openTimeSprite:setScale(MainScene.elementScale)

	local openTimeLabel = CCRenderLabel:create(OlympicData.getStartTimeDes(), g_sFontPangWa, 26, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
	openTimeLabel:setAnchorPoint(ccp(0.5,0.5))
	openTimeLabel:setPosition(93, 18)
	openTimeLabel:setColor(ccc3(237, 184, 0))
	openTimeSprite:addChild(openTimeLabel)


	--倒计时
	_nowStageEndTime = OlympicData.getStageNowEndTime() - BTUtil:getSvrTimeInterval()
	if(_nowStageEndTime <0) then
		_nowStageEndTime = 0
	end

	local desNodeTable = {}
	if _nowStageEndTime == 0 then
		local alreadyStartLabel = CCRenderLabel:create(GetLocalizeStringBy("lcy_50001"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		alreadyStartLabel:setColor(ccc3(0x00,0xff,0x18))
		desNodeTable = {alreadyStartLabel}
	else
		local timeDes = CCRenderLabel:create( GetLocalizeStringBy("lcy_10050") , g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		timeDes:setColor(ccc3(0x00,0xff,0x18))
		local timeBg = CCSprite:create("images/olympic/time_bg.png")
		_timeString = CCLabelTTF:create(getTimeDes(_nowStageEndTime), g_sFontPangWa, 21)
		_timeString:setAnchorPoint(ccp(0.5, 0.5))
		_timeString:setPosition(ccpsprite(0.5, 0.5, timeBg))
		timeBg:addChild(_timeString)
		desNodeTable = {timeDes,timeBg}
	end
	_desTimeNode = BaseUI.createHorizontalNode(desNodeTable)
	_desTimeNode:setAnchorPoint(ccp(0.5, 0.5))
	_desTimeNode:setPosition(ccp(0.5*_layerSize.width, _layerSize.height * 0.25))
	_bgLayer:addChild(_desTimeNode)
	_desTimeNode:setScale(MainScene.elementScale)

	_preLabel = CCRenderLabel:create( GetLocalizeStringBy("lcy_50032") , g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_preLabel:setAnchorPoint(ccp(0.5, 0.5))
	_preLabel:setPosition(ccp(0.5*_layerSize.width, _layerSize.height * 0.25))
	_bgLayer:addChild(_preLabel)
	_preLabel:setScale(MainScene.elementScale)
	_preLabel:setVisible(false)
	_preLabel:setColor(ccc3(0x00,0xff,0x18))

	_startLabel = CCRenderLabel:create( GetLocalizeStringBy("lcy_50033") , g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_startLabel:setAnchorPoint(ccp(0.5, 0.5))
	_startLabel:setPosition(ccp(0.5*_layerSize.width, _layerSize.height * 0.25))
	_bgLayer:addChild(_startLabel)
	_startLabel:setScale(MainScene.elementScale)
	_startLabel:setVisible(false)
	_startLabel:setColor(ccc3(0x00,0xff,0x18))
	updateTimeFunc()
end


function getTimeDes( p_timeInterval )
	if(p_timeInterval <= 0) then
		return GetLocalizeStringBy("lcy_50001")
	end

	local hour = math.floor(p_timeInterval/3600)
	local min  = math.floor((p_timeInterval - hour*3600)/60)
	local sec  = p_timeInterval - hour*3600 - 60*min
	return string.format("%02d",hour) .. "  :  " .. string.format("%02d",min) .. "  :  ".. string.format("%02d",sec)
end


-------------------------------------[[ 事件回调方法 ]]-----------------------------------------


--[[
	@des :	定时器
--]]
function updateTimeFunc( ... )
	if(_timeString) then
		_nowStageEndTime = _nowStageEndTime - 1
		if(_nowStageEndTime <=0) then
			_nowStageEndTime = 0
			_timeString:setString("00  :  00  :  00")
		else
			_timeString:setString(getTimeDes(_nowStageEndTime))
		end
	end

	if(OlympicData.getStage() == OlympicData.kPreOlympicStag and _nowStageEndTime == 0) then
		_desTimeNode:setVisible(false)
		_preLabel:setVisible(true)
		_startLabel:setVisible(false)
		OlympicData.setWaitRegisterStatus(true)
	elseif(OlympicData.getStage() >= OlympicData.kRegisterStage and _nowStageEndTime == 0) then
		_desTimeNode:setVisible(false)
		_startLabel:setVisible(true)
		_preLabel:setVisible(false)
	else
		_desTimeNode:setVisible(true)
		_preLabel:setVisible(false)
		_startLabel:setVisible(false)
	end
end


--[[
	@des : 	关闭按钮回调
--]]
function closeButtonCallFunc( ... )
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	local requestCallback = function ( ... )
		require "script/ui/active/ActiveList"
		local  activeList = ActiveList.createActiveListLayer()
		MainScene.changeLayer(activeList, "activeList")
	end
	OlympicService.leave(requestCallback)
end

--[[
	@des : 	奖池按钮回调
--]]
function rewardPoolButtonCallback( ... )
	require "script/ui/olympic/AwardPoolLayer"
	AwardPoolLayer.showLayer()
end

--[[
	@des : 	奖励预览按钮
--]]
function rewardPreviewButtonCallback( ... )
	print("奖励预览按钮")
	require "script/ui/olympic/rewardPreview/OlympicRewardLayer"
	OlympicRewardLayer.showLayer()
end


--[[
	@des : 	活动说明按钮
--]]
function explainButtonCallback( ... )
	print("活动说明按钮")
	require "script/ui/olympic/ExplainDialog"
	ExplainDialog.show(-3000)
end

--[[
	@des : 	进入赛场
--]]
function enterButtonCallback( ... )
	local stageIndex = OlympicData.getStage()
	if(stageIndex == 1 or stageIndex == 2 ) then
		require "script/ui/olympic/OlympicRegisterLayer"
		OlympicRegisterLayer.show()
	elseif(stageIndex >= 3 and stageIndex < 6) then
		require "script/ui/olympic/Olympic32Layer"
		Olympic32Layer.show()
	elseif(stageIndex >= 6) then
		require "script/ui/olympic/Olympic4Layer"
		Olympic4Layer.show()
	else
		require "script/ui/tip/AnimationTip"
    	AnimationTip.showTip(GetLocalizeStringBy("zz_130"))
	end
end

--[[
	@des : 擂台争霸阶段变化推送
--]]
function stageChangePushCallback( p_StageIndex )

end
