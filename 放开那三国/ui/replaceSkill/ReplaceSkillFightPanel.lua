-- Filename: ReplaceSkillFightPanel.lua
-- Author: zhangqiang
-- Date: 2014-08-08
-- Purpose: 创建武艺切磋面板

module("ReplaceSkillFightPanel", package.seeall)

local kUINodeContentSize = CCSizeMake(620, 676)
local kMainLayerZOrder = 999
local kMainLayerTouchPriority = -480
local kMenuTouchPriority = -481

local _mainLayer = nil
local _uiNode = nil
local _attackSprite = nil
local _attackNameLabel = nil
--local _attackLevelLabel = nil
local _defendSprite = nil
local _defendNameLabel = nil
--local _defendLevelLabel = nil
local _freeFightNumLabel = nil
local _goldFightNumLabel = nil
local _goldCostNumLabel = nil
local _goldSprite = nil

--[[
	@desc :	初始化数据
--]]
function init( ... )
	_mainLayer = nil
	_uiNode = nil
	_attackSprite = nil
	_attackNameLabel = nil
	--_attackLevelLabel = nil
	_defendSprite = nil
	_defendNameLabel = nil
	--_defendLevelLabel = nil
	_freeFightNumLabel = nil
	_goldFightNumLabel = nil
	_goldCostNumLabel = nil
	_goldSprite = nil
end

--[[
	desc :	创建界面层
--]]
function createLayer( ... )
	_mainLayer = CCLayerColor:create(ccc4(0,0,0,127))
	_mainLayer:registerScriptHandler(onNodeEvent)
	_mainLayer:setContentSize(g_winSize)

	createUINode()
end

--[[
	desc :	创建各个节点
--]]
function createUINode( ... )
	_uiNode = CCNode:create()
	_uiNode:setScale(g_fScaleX)
	_uiNode:setContentSize(kUINodeContentSize)
	_uiNode:setAnchorPoint(ccp(0.5,0.5))
	_uiNode:setPosition(g_winSize.width*0.5,g_winSize.height*0.5)
	_mainLayer:addChild(_uiNode)

	--面板背景
	local panelBg = CCScale9Sprite:create("images/battle/report/bg.png")
	panelBg:setPreferredSize(kUINodeContentSize)
	panelBg:setAnchorPoint(ccp(0.5,0.5))
	panelBg:setPosition(kUINodeContentSize.width/2, kUINodeContentSize.height/2)
	_uiNode:addChild(panelBg)

	--标题修饰
	local starSprite = CCSprite:create("images/upgrade/star.png")
	starSprite:setAnchorPoint(ccp(0.5,0))
	starSprite:setPosition(kUINodeContentSize.width/2,kUINodeContentSize.height-41)
	panelBg:addChild(starSprite)

	--面板标题
	local panelTitleBg = CCSprite:create("images/battle/report/title_bg.png")
	panelTitleBg:setAnchorPoint(ccp(0.5,0.5))
	panelTitleBg:setPosition(kUINodeContentSize.width/2,kUINodeContentSize.height-7)
	panelBg:addChild(panelTitleBg)

	local panelTitleBgSize = panelTitleBg:getContentSize()
	local panelTitleLabel = CCLabelTTF:create(GetLocalizeStringBy("zz_39"), g_sFontPangWa, 33)
	panelTitleLabel:setColor(ccc3(0xff,0xe4,0x00))
	panelTitleLabel:setAnchorPoint(ccp(0.5,0.5))
	panelTitleLabel:setPosition(panelTitleBgSize.width/2, panelTitleBgSize.height/2)
	panelTitleBg:addChild(panelTitleLabel)

	--二级背景
	local secondBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	secondBg:setPreferredSize(CCSizeMake(572,420))
	secondBg:setAnchorPoint(ccp(0.5,1))
	secondBg:setPosition(kUINodeContentSize.width/2, kUINodeContentSize.height-80)
	panelBg:addChild(secondBg)

	--武将和台子
	local stagePositionTable = {ccp(128,71),ccp(442,71)}
	local nameLabelPositionTable = {ccp(128,45),ccp(442,45)}
	for i=1,2 do
		local stageSprite = CCSprite:create("images/olympic/tai_zi.png")
		stageSprite:setScale(0.6)
		stageSprite:setAnchorPoint(ccp(0.5,0))
		stageSprite:setPosition(stagePositionTable[i])
		secondBg:addChild(stageSprite)

		local generalSprite = CCSprite:create()
		generalSprite:setAnchorPoint(ccp(0.5,0))
		generalSprite:setPosition(stageSprite:getContentSize().width/2,75)
		stageSprite:addChild(generalSprite)

		local nameLabel = CCRenderLabel:create("", g_sFontPangWa, 21, 1, ccc3(0x00,0x00,0x00), type_shadow)
		nameLabel:setColor(ccc3(0xff,0xff,0xff))
		nameLabel:setAnchorPoint(ccp(0.5,0))
		nameLabel:setPosition(nameLabelPositionTable[i])
		--不设zorder：setString前能显示字符串，setString后内容消失, 改为CCLabelTTF则setString前后都能显示
		--设置zorder：setString前后均能显示字符串
		secondBg:addChild(nameLabel,1)

		-- local levelLabel = CCRenderLabel:create("", g_sFontPangWa, 21, 1, ccc3(0x00,0x00,0x00), type_shadow)
		-- levelLabel:setColor(ccc3(0xff,0xe4,0x00))
		-- levelLabel:setAnchorPoint(ccp(0,0))
		-- levelLabel:setPosition(nameLabelPositionTable[i].x+10,nameLabelPositionTable[i].y)
		-- secondBg:addChild(levelLabel,1)

		if i == 1 then
			_attackSprite = generalSprite
			_attackNameLabel = nameLabel
			-- _attackLevelLabel = levelLabel
		else
			_defendSprite = generalSprite
			_defendNameLabel = nameLabel
			-- _defendLevelLabel = levelLabel
		end
	end

	--vs图标
	local vsSprite = CCSprite:create("images/arena/vs.png")
	vsSprite:setAnchorPoint(ccp(0.5,0.5))
	vsSprite:setPosition(secondBg:getContentSize().width/2,221)
	secondBg:addChild(vsSprite)

	--顶部和底部的描述
	local descLabelString = {GetLocalizeStringBy("zz_40"), GetLocalizeStringBy("zz_41"), GetLocalizeStringBy("zz_42")}
	local descLabelPosition = {ccp(140,608),ccp(192,62),ccp(192,30),ccp(384,62),ccp(384,30),ccp(423,114)}
	local anchorPoint = ccp(0,0)
	local descLabel = nil
	for i =1,6 do
		if i == 1 then
			descLabel = CCLabelTTF:create(descLabelString[1], g_sFontPangWa, 21)
			descLabel:setColor(ccc3(0x78,0x25,0x00))
		elseif i ==2 or i == 3 then
			descLabel = CCRenderLabel:create(descLabelString[i], g_sFontPangWa, 21, 1, ccc3(0x00,0x00,0x00), type_shadow)
			descLabel:setColor(ccc3(0x00,0xff,0x18))
		elseif i == 4 or i == 5 then
			descLabel = CCRenderLabel:create("0", g_sFontPangWa, 21, 1, ccc3(0x00,0x00,0x00), type_shadow)
			descLabel:setColor(ccc3(0xff,0xff,0xff))
			if i == 4 then
				_freeFightNumLabel = descLabel
			else
				_goldFightNumLabel = descLabel
			end
		else
			descLabel = CCLabelTTF:create("0", g_sFontPangWa, 21)
			descLabel:setColor(ccc3(0xff,0xe4,0x00))
			_goldCostNumLabel = descLabel
			anchorPoint = ccp(1,0)
		end
		descLabel:setAnchorPoint(anchorPoint)
		descLabel:setPosition(descLabelPosition[i])
		panelBg:addChild(descLabel,1)
	end

	--金币图标
	_goldSprite = CCSprite:create("images/common/gold.png")
	_goldSprite:setAnchorPoint(ccp(0,0))
	_goldSprite:setPosition(425,113)
	panelBg:addChild(_goldSprite,1)

	local menu = CCMenu:create()
	menu:setPosition(0,0)
	menu:setTouchPriority(kMenuTouchPriority)
	panelBg:addChild(menu)
	--开始切磋按钮
	local startFightMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png", "images/common/btn/btn1_n.png",
		                                                  CCSizeMake(320,73), GetLocalizeStringBy("zz_43"), ccc3(255,222,0))
	startFightMenuItem:setAnchorPoint(ccp(0.5,0.5))
	startFightMenuItem:setPosition(317,127)
	startFightMenuItem:registerScriptTapHandler(tapStartFightMenuItemCb)
	menu:addChild(startFightMenuItem)

	--返回按钮
	local goBackMenuItem = CCMenuItemImage:create("images/common/btn_close_n.png","images/common/btn_close_h.png")
	goBackMenuItem:registerScriptTapHandler(goBackMenuItemCb)
	goBackMenuItem:setAnchorPoint(ccp(0.5,0.5))
	goBackMenuItem:setPosition(595,656)
	menu:addChild(goBackMenuItem)

	refreshHeroSprite()
	refreshGoldIcon()
	refreshFightNum()
end

--[[

--]]
require "script/model/utils/HeroUtil"
function refreshHeroSprite( ... )
	--local attackSprite = CCSprite:create("images/base/hero/body_img/quan_jiang_zhoutai.png")
	local attackSprite = HeroUtil.getHeroBodySpriteByHTID( UserModel.getAvatarHtid(), UserModel.getDressIdByPos(1), UserModel.getUserSex() )
	--_attackSprite创建时的contentSize为0, setTexture不会改变它的contentSize, 因此在屏幕中看不见图形
	--setDisplayFrame调用了setTexture方法并对_attackSprite的contentSize进行了重新设置
	_attackSprite:setDisplayFrame(attackSprite:displayFrame())


	local attackNameColor = HeroPublicLua.getCCColorByStarLevel(HeroUtil.getHeroLocalInfoByHtid(UserModel.getAvatarHtid()).star_lv)
	_attackNameLabel:setString(UserModel.getUserName())
	_attackNameLabel:setColor(attackNameColor)
	--_attackLevelLabel:setString("LV." .. UserModel.getAvatarLevel())

	--local defendSprite = CCSprite:create("images/base/hero/body_img/quan_jiang_wuguotai.png")
	local defendInfo = ReplaceSkillData.getCurMasterInfo()
	local defendSprite = StarSprite.createStarSprite(defendInfo.star_tid)
	_defendSprite:setDisplayFrame(defendSprite:displayFrame())

	local denfendNameColor = HeroPublicLua.getCCColorByStarLevel(defendInfo.starTemplate.quality)
	_defendNameLabel:setColor(denfendNameColor)
	_defendNameLabel:setString(defendInfo.starTemplate.name)
	--_defendLevelLabel:setString("LV.")
end

--[[
	desc :	刷新金币图标和下一次切磋需要得金币数
--]]
function refreshGoldIcon( ... )
	if ReplaceSkillData.getRemainFreeFightNum() ~= 0 then
		_goldSprite:setVisible(false)
		_goldCostNumLabel:setVisible(false)
		return
	end

	_goldSprite:setVisible(true)
	_goldCostNumLabel:setVisible(true)
	_goldCostNumLabel:setString(tostring(ReplaceSkillData.getNextGoldNum()))
end

--[[

--]]
function refreshFightNum( ... )
	if _freeFightNumLabel ~= nil then
		_freeFightNumLabel:setString(tostring(ReplaceSkillData.getRemainFreeFightNum()))
	end

	if _goldFightNumLabel ~= nil then
		_goldFightNumLabel:setString(tostring(ReplaceSkillData.getRemainGoldFightNum()))
	end
end

--[[

--]]
function showLayer( ... )
	init()
	createLayer()

	-- require "script/ui/main/MainScene"
	-- MainScene.changeLayer(_mainLayer,"ReplaceSkillFightPanel")
	-- MainScene.setMainSceneViewsVisible(true,true,true)
	local scene = CCDirector:sharedDirector():getRunningScene()
	_mainLayer:setPosition(0,0)
	scene:addChild(_mainLayer,kMainLayerZOrder)
end

---------------------------------------------------------[[ 回调函数 ]]----------------------------------------------
--[[

--]]
function onNodeEvent( p_eventType )

	local touchCb = function ( p_eventType, p_x, p_y )
		if p_eventType == "began" then
			return true
		elseif p_eventType == "moved" then

		elseif p_eventType == "cancelled" then

		else
			--p_eventType == "ended"
		end
	end

	if p_eventType == "enter" then
		print("主将更换技能 武艺切磋 创建")
		-- _mainLayer:setTouchEnabled(true)
		_mainLayer:registerScriptTouchHandler(touchCb,false,kMainLayerTouchPriority,true)
		_mainLayer:setTouchEnabled(true)
	elseif p_eventType == "exit" then
		print("主将更换技能 武艺切磋 退出")
		_mainLayer:unregisterScriptTouchHandler()
	else

	end
end

--[[

--]]
require "script/ui/tip/SingleTip"
require "script/ui/replaceSkill/ReplaceSkillService"
require "script/battle/BattleLayer"
function tapStartFightMenuItemCb( p_itemTag, p_item )
	local curMasterInfo = ReplaceSkillData.getCurMasterInfo()
	if tonumber(curMasterInfo.starTemplate.isFeel) ~= 1 then
		 SingleTip.showSingleTip(GetLocalizeStringBy("key_10155"))
		 return
	end

	if tonumber(curMasterInfo.feel_level) >= ReplaceSkillData.getMaxConfigFeelLevel() then
		SingleTip.showSingleTip(GetLocalizeStringBy("key_10156"))
		return
	end

	if tonumber(curMasterInfo.feel_level) >= ReplaceSkillData.getMaxUserFeelValue() then
		SingleTip.showSingleTip(GetLocalizeStringBy("key_10157"))
		return
	end

	local remainFreeFightNum = ReplaceSkillData.getRemainFreeFightNum()
	local remainGoldFightNum = ReplaceSkillData.getRemainGoldFightNum()
	local goldNeed = 0
	if remainFreeFightNum == 0 and remainGoldFightNum == 0 then
	   SingleTip.showSingleTip(GetLocalizeStringBy("key_10158"))
	   return
	elseif remainFreeFightNum == 0 and remainGoldFightNum ~= 0 then
		if UserModel.getGoldNumber() < ReplaceSkillData.getNextGoldNum() then
			SingleTip.showSingleTip(GetLocalizeStringBy("key_10159"))
			return
		else
			goldNeed = ReplaceSkillData.getNextGoldNum()
			print("fightCb...",goldNeed)
		end
	else

	end


	local fightCb = function (p_fightRet,p_appraisal)
		if remainFreeFightNum ~= 0 then
			ReplaceSkillData.reduceRemainFreeFightNum()
		else
			ReplaceSkillData.reduceRemainGoldFightNum()
		end

		require "script/ui/replaceSkill/PracticeResultLayer"
		local fightResultLayer = PracticeResultLayer.create(p_appraisal)

		BattleLayer.showBattleWithString(p_fightRet,nil,fightResultLayer,nil,nil,nil,nil,nil,false)
		
		ReplaceSkillData.addCurStarFeel(ReplaceSkillData.getFightFeelValue(p_appraisal))
		
		UserModel.addGoldNumber(-goldNeed)
	
		refreshGoldIcon()
		refreshFightNum()
		print("fightCb......",UserModel.getGoldNumber())
		ReplaceSkillLayer.refreshGoldNum()
		--丢弃下面两个刷新：将刷新放在了ReplaceSkillData.addCurStarFeel方法中自动刷新
		--AttributePanel.refreshTableView()
    	--ReplaceSkillLayer.refreshProgressBar()

		-- --关闭界面，为了方便战斗结算面板展示
		-- _mainLayer:removeFromParentAndCleanup(true)
		-- _mainLayer = nil
	end
	local curMasterInfo = ReplaceSkillData.getCurMasterInfo()
	ReplaceSkillService.startChallenge( curMasterInfo.star_id, fightCb )
end

--[[

--]]
function goBackMenuItemCb( p_itemTag, p_item )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")

	_mainLayer:removeFromParentAndCleanup(true)
	_mainLayer = nil
end