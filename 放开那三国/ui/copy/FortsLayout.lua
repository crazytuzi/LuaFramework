-- Filename：	FortsLayout.lua
-- Author：		Cheng Liang
-- Date：		2013-5-24
-- Purpose：		据点的布局

module ("FortsLayout", package.seeall)

require "db/DB_Stronghold"
require "script/network/RequestCenter"
require "script/ui/copy/CopyRewardBtn"
require "script/ui/copy/CopyRewardLayer"
require "script/ui/copy/CopyUtil"
require "script/model/DataCache"


local IMG_PATH = "images/main/"				-- 主城场景图片主路径

local containerLayer				--scrollView的容器
local fortMenuBar                   --所有据点都做成menuItem

local menuCloseBar

local curCopyForts = {}
local curFortId

local testLevelParams = {}
local testArmyIDsParams = {}

local curRound = 1
local curHardLevel = -1

local fortScrollView

local absY = 0
local absX = 0
local rewardMenuBar = nil

local closeMenuItem = nil

local layoutSprite = nil


-- 副本奖励
-- 相应的数据
local stars_t, copper_t, silver_t, gold_t
local box_status_t 		= nil
-- 青铜宝箱按钮
local _copperBox 		= nil
-- 白银宝箱按钮
local _silverBox 		= nil
-- 黄金宝箱按钮
local _goldBox			= nil
-- 奖励背景
local rewardSprite

local lastFortMenuItem 	= nil

local _ccExpProgress 	= nil
local _ccLabelExp 		= nil
local _ccEnergyProgress = nil
local _nExpProgressOriWidth = nil
local _energy 			= nil


local _lastCopyIdAndBaseId = {} 	-- 保存最后点击的copy_id和据点

local _openTargetStongholdId = nil

function init()
	containerLayer		= nil 	--scrollView的容器
	fortMenuBar			= nil 	--所有据点都做成menuItem

	menuCloseBar		= nil

	curCopyForts 		= {}
	curFortId			= nil

	testLevelParams 	= {}
	testArmyIDsParams 	= {}

	curRound 			= 1
	curHardLevel 		= -1

	fortScrollView		= nil

	absY 				= 0
	absX				= 0
	rewardMenuBar 		= nil

	closeMenuItem 		= nil
	_openTargetStongholdId = nil

	layoutSprite = nil


-- 副本奖励
-- 相应的数据
	stars_t, copper_t, silver_t, gold_t = nil, nil, nil, nil
	box_status_t 		= nil
-- 青铜宝箱按钮
	_copperBox 			= nil
-- 白银宝箱按钮
	_silverBox 			= nil
-- 黄金宝箱按钮
	_goldBox			= nil
-- 奖励背景
	rewardSprite		= nil

	lastFortMenuItem 	= nil

	_ccExpProgress 		= nil
	_ccLabelExp 		= nil
	_ccEnergyProgress 	= nil
	_energy 			= nil
	_nExpProgressOriWidth = nil

end


--[[
 @desc	 处理touches事件
 @para 	 string event
 @return
--]]
local function onTouchesHandler( eventType, x, y )
	-- print("eventType=" .. eventType)
	if (eventType == "began") then
        -- touchBeganPoint = ccp(x, y)
        -- print("began.x= " .. touchBeganPoint.x .. ", began.y=" .. touchBeganPoint.y)
        return true
    elseif (eventType == "moved") then
        -- print("scrollView.x=", fortScrollView:getContentOffset().x, "   scrollView.y=", fortScrollView:getContentOffset().y)
    else
        -- print("touchBeganPoint.x= " .. touchBeganPoint.x .. "touchBeganPoint,y=" .. touchBeganPoint.y)
        -- print("end.x= " .. x .. ", end.y= " .. y)
	end
end


--[[
 @desc	 回调onEnter和onExit时间
 @para 	 string event
 @return void
 --]]
local function onNodeEvent( event )
	if (event == "enter") then
		-- print("enter")
		containerLayer:registerScriptTouchHandler(onTouchesHandler, false, -130, true)
		containerLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		-- print("exit")
		containerLayer:unregisterScriptTouchHandler()
	end
end

--[[
	@desc	关闭FortsLayout
	@para 	void
	@return void
--]]
local function closeFortsLayoutAction( ... )
	---[==[副本箱子 新手引导屏蔽层
	---------------------新手引导---------------------------------
		--add by licong 2013.09.11
		require "script/guide/NewGuide"
		if(NewGuide.guideClass ==  ksGuideCopyBox) then
			require "script/guide/CopyBoxGuide"
			CopyBoxGuide.changLayer()
		end
	---------------------end-------------------------------------
	--]==]
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	--增加背景音乐
    require "script/audio/AudioUtil"
    AudioUtil.playMainBgm()
	if (containerLayer) then
		containerLayer:removeFromParentAndCleanup(true)
		containerLayer = nil
	end
	menuCloseBar:removeFromParentAndCleanup(true)
	menuCloseBar = nil
	require "script/ui/copy/CopyLayer"
	local copyLayer = CopyLayer.createLayer( false)
	MainScene.changeLayer(copyLayer, "copyLayer")
	--[==[  副本箱子 第4步 商店
	---------------------新手引导---------------------------------
	    --add by licong 2013.09.11
	    require "script/guide/NewGuide"
		require "script/guide/CopyBoxGuide"
	    if(NewGuide.guideClass ==  ksGuideCopyBox and CopyBoxGuide.stepNum == 3) then
		   require "script/ui/main/MenuLayer"
        	local copyBoxGuide_button = MenuLayer.getMenuItemNode(5)
		    local touchRect = getSpriteScreenRect(copyBoxGuide_button)
		    CopyBoxGuide.show(4, touchRect)
	   	end
	 ---------------------end-------------------------------------
	--]==]
end

-- 隐藏或者显示
-- function setVisible( isVisible )
-- 	-- containerLayer:setVisible(isVisible)
-- 	fortScrollView:setTouchEnabled(isVisible)
-- end

-- 副本排行按钮
local function rankAction( ... )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 排名
	require "script/ui/copy/CopyRankLayer"
    local layer = CopyRankLayer.createRankingsLayer()
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    runningScene:addChild(layer,999)
end

local function arrayAction( ... )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	--布阵
	-- require "script/ui/formation/MakeUpFormationLayer"
	-- MakeUpFormationLayer.showLayer()
	-- require "script/ui/warcraft/WarcraftLayer"
	-- WarcraftLayer.show()
	if(DataCache.getSwitchNodeState(ksSwitchWarcraft, false) == true)then
		require "script/ui/warcraft/WarcraftLayer"
		WarcraftLayer.show()
	else
		require "script/ui/formation/MakeUpFormationLayer"
		MakeUpFormationLayer.showLayer()
	end
end

--[[
	@desc	关闭FortsLayout的按钮
--]]
local function addCloseFortsLayoutMenu( ... )
	menuCloseBar = CCMenu:create()
	menuCloseBar:setPosition(ccp(1,0))
	menuCloseBar:setTouchPriority(-402)
	containerLayer:addChild(menuCloseBar, 1, 1)

	require "script/ui/main/MainScene"
	closeMenuItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	closeMenuItem:setAnchorPoint(ccp(1, 1))
	closeMenuItem:registerScriptTapHandler(closeFortsLayoutAction)
	closeMenuItem:setPosition(MainScene.getMenuPositionInTruePoint(containerLayer:getContentSize().width*0.99, containerLayer:getContentSize().height*0.95-20))
	menuCloseBar:addChild(closeMenuItem)

	-- 排行
	local rankMenuItem = CCMenuItemImage:create("images/match/paihang_n.png", "images/match/paihang_h.png")
	rankMenuItem:setAnchorPoint(ccp(1, 1))
	rankMenuItem:registerScriptTapHandler(rankAction)
	rankMenuItem:setPosition(MainScene.getMenuPositionInTruePoint(containerLayer:getContentSize().width*0.84, containerLayer:getContentSize().height*0.95))
	menuCloseBar:addChild(rankMenuItem)

	--布阵
	if(DataCache.getSwitchNodeState(ksSwitchWarcraft, false) == true )then
		local arrayMenuItem = CCMenuItemImage:create("images/copy/array_n.png","images/copy/array_h.png")
		arrayMenuItem:setAnchorPoint(ccp(1,1))
		arrayMenuItem:registerScriptTapHandler(arrayAction)
		arrayMenuItem:setPosition(MainScene.getMenuPositionInTruePoint(containerLayer:getContentSize().width*0.69, containerLayer:getContentSize().height*0.95))
		menuCloseBar:addChild(arrayMenuItem)
	else
		local arrayMenuItem = CCMenuItemImage:create("images/copy/arraybu_n.png","images/copy/arraybu_h.png")
		arrayMenuItem:setAnchorPoint(ccp(1,1))
		arrayMenuItem:registerScriptTapHandler(arrayAction)
		arrayMenuItem:setPosition(MainScene.getMenuPositionInTruePoint(containerLayer:getContentSize().width*0.69, containerLayer:getContentSize().height*0.95))
		menuCloseBar:addChild(arrayMenuItem)
	end
end



--[[
 @desc	战斗回调
 @para
 @return
 --]]
function doBattleCallback( newData, isVictory )
	local isHadVictory = CopyUtil.isStrongHoldIsVict(curFortId)
	require "script/utils/LuaUtil"
	if (newData) then
		CopyUtil.hanleNewCopyData(newData)
	end
	-- 不得已而为之
	local curData = DataCache.getNormalCopyData()
	for k,v in pairs(curData) do
		if(tonumber(v.copy_id) == tonumber(curCopyForts.copy_id))then
			curCopyForts = v
			break
		end
	end
	local fortDesc = DB_Stronghold.getDataById(tonumber(curFortId))

	local isHasDialog = false
	if(isVictory and (not isHadVictory) )then
		-- 对话
	    if(fortDesc.victor_dialog_id and tonumber(fortDesc.victor_dialog_id) > 0 and (not CopyUtil.isFortIdVicHadDisplay(fortDesc.id)))then

	    	CopyUtil.addHadVicDialogFortId(fortDesc.id)
	    	require "script/ui/talk/talkLayer"
		    local talkLayer = TalkLayer.createTalkLayer(fortDesc.victor_dialog_id)
		    local runningScene = CCDirector:sharedDirector():getRunningScene()
		    runningScene:addChild(talkLayer,10001)
		    TalkLayer.setCallbackFunction(doBattleOverCallback)
		    isHasDialog = true
	    end
	else
		-- 对话
	    if( (not isHadVictory) and fortDesc.fail_dialog_id and tonumber(fortDesc.fail_dialog_id) > 0 and (not CopyUtil.isFortIdFailHadDisplay(fortDesc.id)))then
	    	CopyUtil.addHadFailDialogFortId(fortDesc.id)
	    	require "script/ui/talk/talkLayer"
		    local talkLayer = TalkLayer.createTalkLayer(fortDesc.fail_dialog_id)
		    local runningScene = CCDirector:sharedDirector():getRunningScene()
		    runningScene:addChild(talkLayer,10001)
		    TalkLayer.setCallbackFunction(doBattleOverCallback)
		    isHasDialog = true
	    end
	end

	local fortsLayer = FortsLayout.createFortsLayout(curCopyForts)
	MainScene.changeLayer(fortsLayer, "fortsLayer")

	-- 新手引导用
	if(not isHasDialog) then
		doBattleOverCallback()
	end
end

local function npcOrNotFunc()
	local enterNPC = 0
	local enterSimple = 1
	local enterNormal = 2
	local enterHard = 3
	local progressState = curCopyForts.va_copy_info.progress[curFortId .. ""]
	local defeat_num = curCopyForts.va_copy_info.defeat_num[curFortId .. ""]

	local fortDesc = DB_Stronghold.getDataById(tonumber(curFortId))
-- base_status的取值：0可显示 1可攻击 2npc通关 3简单通关 4普通通关 5困难通关
	if( progressState == 0) then
		print(GetLocalizeStringBy("key_2676"))
		return
	elseif (progressState == "1") then


		if(fortDesc.npc_army_num_simple and fortDesc.npc_army_num_simple > 0) then
			curHardLevel = enterNPC
			level = 0
			require "script/utils/LuaUtil"
			local armyIDs = lua_string_split(fortDesc.npc_army_ids_simple, ",")

			for k,v in pairs(armyIDs) do
				table.insert(testArmyIDsParams,v)
			end
		else
			curHardLevel = enterSimple
		end
	elseif (progressState == "2") then
		curHardLevel = enterSimple
	elseif (progressState == "3") then
		curHardLevel = enterNormal
	elseif (progressState == "4") then
		curHardLevel = enterHard
	elseif (progressState == "5") then
		curHardLevel = enterHard
	else
	end



	if(curHardLevel == enterNPC) then
		-- 检查体力是否足够
		require "script/model/user/UserModel"
		if( fortDesc.cost_energy_simple > UserModel.getEnergyValue() )then
			require "script/ui/item/EnergyAlertTip"
            EnergyAlertTip.showTip()
			return
		end
		require "script/battle/BattleLayer"
		local battleLayer = BattleLayer.enterBattle(curCopyForts.copy_id,curFortId,curHardLevel, FortsLayout.doBattleCallback)
	else

		---[==[等级礼包新手引导屏蔽层
		---------------------新手引导---------------------------------
		--add by licong 2013.09.09
		require "script/guide/NewGuide"
		if(NewGuide.guideClass == ksGuideFiveLevelGift) then
			require "script/guide/LevelGiftBagGuide"
			LevelGiftBagGuide.changLayer()
		end
		---------------------end-------------------------------------
		--]==]

        require "script/ui/copy/FortInfoLayer"
		local fortInfoLayer = FortInfoLayer.createLayer(curCopyForts.copy_id,curFortId, progressState, defeat_num)
		local runningScene = CCDirector:sharedDirector():getRunningScene()
		runningScene:addChild(fortInfoLayer, 99)

		local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
				addLevelGiftBagNewGuide()
		end))
		fortInfoLayer:runAction(seq)
	end
end

--[[
 @desc	选中据点的处理
 @para
 @return
 --]]
local function menuAction( tag, menuItem )
	print(GetLocalizeStringBy("key_2412")..tag)
	---[==[等级礼包新手引导清除
	---------------------新手引导---------------------------------
	--add by licong 2013.09.09
	require "script/guide/NewGuide"
	require "script/guide/LevelGiftBagGuide"
	if(NewGuide.guideClass == ksGuideFiveLevelGift and LevelGiftBagGuide.stepNum == 21) then
		LevelGiftBagGuide.cleanLayer()
	end
	---------------------end-------------------------------------
	--]==]

	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/start_fight.mp3")
    require "script/ui/hero/HeroPublicUI"
	if(ItemUtil.isBagFull() == true)then
		--AnimationTip.showTip(GetLocalizeStringBy("key_2094"))
		return
	elseif HeroPublicUI.showHeroIsLimitedUI() then
		return
	end

	----------------新手引导代码----------------
    require "script/guide/NewGuide"
    if(NewGuide.guideClass ==  ksGuideFormation) then
	    --add by lichenyang 2013.08.29
	    -- 阵型引导结束
	    require "script/guide/FormationGuide"
	    FormationGuide.cleanLayer()
	    NewGuide.guideClass = ksGuideClose
	    BTUtil:setGuideState(false)
	    NewGuide.saveGuideClass()
	end
    -------------------end--------------------

    ---[==[强化所新手引导清除引导
	---------------------新手引导---------------------------------
		--add by licong 2013.09.06
		require "script/guide/NewGuide"
		require "script/guide/StrengthenGuide"
		if(NewGuide.guideClass ==  ksGuideForge and StrengthenGuide.stepNum == 12) then
			StrengthenGuide.cleanLayer()
			NewGuide.guideClass = ksGuideClose
			BTUtil:setGuideState(false)
			NewGuide.saveGuideClass()
		end

		if(NewGuide.guideClass ==  ksGuideForge and StrengthenGuide.stepNum == 11) then
			StrengthenGuide.cleanLayer()
		end
	---------------------end-------------------------------------
	--]==]

	require "script/guide/NewGuide"
	require "script/guide/GeneralUpgradeGuide"
    if(NewGuide.guideClass ==  ksGuideGeneralUpgrade and GeneralUpgradeGuide.stepNum == 8) then
    	GeneralUpgradeGuide.cleanLayer()
    	BTUtil:setGuideState(false)
    	NewGuide.guideClass = ksGuideClose
    end

    if(NewGuide.guideClass ==  ksGuideGeneralUpgrade) then
    	GeneralUpgradeGuide.cleanLayer()
    end

	curFortId = tag
	curRound = 1
	local fortDesc = DB_Stronghold.getDataById(tonumber(curFortId))

	-- -- 对话
    if(fortDesc.pre_dialog_id and fortDesc.pre_dialog_id > 0 and (not CopyUtil.isFortIdHadDisplay(curFortId)) and (not CopyUtil.isStrongHoldIsVict(curFortId)))then
    	CopyUtil.addHadDialogFortId(curFortId)
    	require "script/ui/talk/talkLayer"
	    local talkLayer = TalkLayer.createTalkLayer(fortDesc.pre_dialog_id)
	    local runningScene = CCDirector:sharedDirector():getRunningScene()
	    runningScene:addChild(talkLayer,999999)
	    isCreateHavaTalk = true
	    TalkLayer.setCallbackFunction(npcOrNotFunc)
    else
    	npcOrNotFunc()
    end

    _lastCopyIdAndBaseId[curCopyForts.copy_id] = curFortId

end


local function scrollToPoint( toPoint )
	local scrollY = containerLayer:getContentSize().height/2 - toPoint.y * MainScene.bgScale
	local scrollX = containerLayer:getContentSize().width/2 - toPoint.x * MainScene.bgScale
	local t_absY = absY * MainScene.bgScale
	local t_absX = absX * MainScene.bgScale
	if(scrollY>0)then
		scrollY=0
	end
	if(scrollY< -(t_absY - containerLayer:getContentSize().height)) then
		scrollY = -(t_absY - containerLayer:getContentSize().height)
	end

	if(scrollX>0)then
		scrollX=0
	end
	if(scrollX < -(t_absX - containerLayer:getContentSize().width)) then
		scrollX = -(t_absX - containerLayer:getContentSize().width)
	end
	print("scrollToPoint,=1111=", scrollX, scrollY)
	fortScrollView:setContentOffset(ccp(scrollX, scrollY))
	-- fortScrollView:setContentOffsetInDuration(ccp(scrollX, scrollY), 1)
end

function rewardDelegate( box_index )
	local t_prized = CopyUtil.handleRewardStatus(curCopyForts.prized_num)
	t_prized[box_index] = 1
	local prized_num = CopyUtil.revertToPrizedNum( t_prized )
	DataCache.changeCopyBoxStatus( curCopyForts.copy_id, prized_num )
	box_status_t = CopyUtil.handleBoxStatus(prized_num, curCopyForts.score, stars_t)

	if(box_index == 1 and box_status_t[1] >0) then
		_copperBox:removeFromParentAndCleanup(true)
		_copperBox = nil
		-- 青铜宝箱按钮
		_copperBox = CopyRewardBtn.createBtn("copper", box_status_t[1], stars_t[1])
		_copperBox:setAnchorPoint(ccp(0.5, 0))
		_copperBox:setPosition(ccp(rewardSprite:getContentSize().width*0.15, 0))
		_copperBox:registerScriptTapHandler(rewardBtnAction)
		rewardMenuBar:addChild(_copperBox,1, 1001)
	end
	if(box_index == 2 and box_status_t[2] >0) then
		_silverBox:removeFromParentAndCleanup(true)
		_silverBox = nil
		-- 白银宝箱按钮
		_silverBox = CopyRewardBtn.createBtn("silver", box_status_t[2], stars_t[2])
		_silverBox:setAnchorPoint(ccp(0.5, 0))
		_silverBox:setPosition(ccp(rewardSprite:getContentSize().width*0.5, 0))
		_silverBox:registerScriptTapHandler(rewardBtnAction)
		rewardMenuBar:addChild(_silverBox, 1, 1002)
	end
	if(box_index == 3 and box_status_t[3] >0 ) then
		_goldBox:removeFromParentAndCleanup(true)
		_goldBox = nil
		-- 黄金宝箱按钮
		_goldBox = CopyRewardBtn.createBtn("gold", box_status_t[3], stars_t[3])
		_goldBox:setAnchorPoint(ccp(0.5, 0))
		_goldBox:setPosition(ccp(rewardSprite:getContentSize().width*0.85, 0))
		_goldBox:registerScriptTapHandler(rewardBtnAction)
		rewardMenuBar:addChild(_goldBox, 1, 1003)
	end
end

function rewardBtnAction( tag, itemBtn )
	---[==[副本箱子 新手引导屏蔽层
	---------------------新手引导---------------------------------
		--add by licong 2013.09.11
		require "script/guide/NewGuide"
		if(NewGuide.guideClass ==  ksGuideCopyBox) then
			require "script/guide/CopyBoxGuide"
			CopyBoxGuide.changLayer()
		end
	---------------------end-------------------------------------
	--]==]
	local box_index = tag - 1000
	local reward_t = nil
	if(box_index == 1) then
		reward_t = copper_t
	elseif(box_index == 2) then
		reward_t = silver_t
	elseif(box_index == 3) then
		reward_t = gold_t
	end

	local rewardLayer = CopyRewardLayer.createLayer(box_status_t[box_index], stars_t[box_index], reward_t, box_index, curCopyForts.copy_id, rewardDelegate)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(rewardLayer, 1888)

	---[==[  副本箱子 第2步 领取奖励
	---------------------新手引导---------------------------------
	    --add by licong 2013.09.11
	    require "script/guide/NewGuide"
		require "script/guide/CopyBoxGuide"
	    if(NewGuide.guideClass ==  ksGuideCopyBox and CopyBoxGuide.stepNum == 1) then
		    require "script/ui/copy/CopyRewardLayer"
		    local copyBoxGuide_button = CopyRewardLayer.getGuideObject()
		    local touchRect = getSpriteScreenRect(copyBoxGuide_button)
		    CopyBoxGuide.show(2, touchRect)
	   	end
	 ---------------------end-------------------------------------
	--]==]

end

-- 副本奖励
local function copyRewardUI( )
	-- 背景
	rewardSprite = CCSprite:create("images/copy/reward/progress.png")
	rewardSprite:setAnchorPoint(ccp(0, 0))
	rewardSprite:setPosition(ccp(0, 0))
	containerLayer:addChild(rewardSprite)

	-- 准备相应的数据
	stars_t, copper_t, silver_t, gold_t = CopyUtil.handleCopyRewardData( curCopyForts.copyInfo )

	box_status_t = CopyUtil.handleBoxStatus(curCopyForts.prized_num, curCopyForts.score, stars_t)


	local image_path = "images/copy/reward/box/box_"

	local type_str = "copper"

	-- 宝箱奖励按钮Bar
	rewardMenuBar = CCMenu:create()
	rewardMenuBar:setAnchorPoint(ccp(0,0))
	rewardMenuBar:setPosition(ccp(0,0))
	rewardMenuBar:setTouchPriority(-402)
	rewardSprite:addChild(rewardMenuBar)

	-- 青铜宝箱按钮
	if(box_status_t[1]>0)then
		_copperBox = CopyRewardBtn.createBtn("copper", box_status_t[1], stars_t[1])
		_copperBox:setAnchorPoint(ccp(0.5, 0))
		_copperBox:setPosition(ccp(rewardSprite:getContentSize().width*0.15, 0))
		_copperBox:registerScriptTapHandler(rewardBtnAction)
		rewardMenuBar:addChild(_copperBox,1, 1001)
	end
	-- 白银宝箱按钮
	if(box_status_t[2]>0)then
		_silverBox = CopyRewardBtn.createBtn("silver", box_status_t[2], stars_t[2])
		_silverBox:setAnchorPoint(ccp(0.5, 0))
		_silverBox:setPosition(ccp(rewardSprite:getContentSize().width*0.5, 0))
		_silverBox:registerScriptTapHandler(rewardBtnAction)
		rewardMenuBar:addChild(_silverBox, 1, 1002)
	end
	-- 黄金宝箱按钮
	if(box_status_t[3]>0)then
		_goldBox = CopyRewardBtn.createBtn("gold", box_status_t[3], stars_t[3])
		_goldBox:setAnchorPoint(ccp(0.5, 0))
		_goldBox:setPosition(ccp(rewardSprite:getContentSize().width*0.85, 0))
		_goldBox:registerScriptTapHandler(rewardBtnAction)
		rewardMenuBar:addChild(_goldBox, 1, 1003)
	end
end

local function createAnimation( toPoint, k_type, imageIcon )
	k_type = tonumber(k_type)
	local animationNameType = nil
	if(k_type == 1) then
		animationNameType = "fbjdmu"
	elseif(k_type == 2) then
		animationNameType = "fbjdying"
	elseif(k_type == 3) then
		animationNameType = "fbjdjin"
	end

	local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/copy/" .. animationNameType), -1,CCString:create(""));

    --替换头像
    local replaceXmlSprite = tolua.cast( spellEffectSprite:getChildByTag(1002) , "CCXMLSprite")
    replaceXmlSprite:setReplaceFileName(CCString:create(imageIcon))

    spellEffectSprite:setPosition(toPoint)
    spellEffectSprite:setAnchorPoint(ccp(0, 0));
    fortScrollView:addChild(spellEffectSprite,9999);

     --delegate
    -- 结束回调
    local animationEnd = function(actionName,xmlSprite)
	    spellEffectSprite:retain()
	    spellEffectSprite:autorelease()
        spellEffectSprite:removeFromParentAndCleanup(true)
        lastFortMenuItem:setVisible(true)
    end
    -- 每次回调
    local animationFrameChanged = function(frameIndex,xmlSprite)

    end

    --增加动画监听
    local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animationEnd)
    delegate:registerLayerChangedHandler(animationFrameChanged)
    spellEffectSprite:setDelegate(delegate)
end

-- 经验和体力进度条
function createExpAndEnergyProgress()

	-- 标题栏
	local titleSprite = CCScale9Sprite:create("images/copy/bg.png")
	--scale changed by zhang zihang
	titleSprite:setContentSize(CCSizeMake(containerLayer:getContentSize().width/g_fElementScaleRatio, 34))
	titleSprite:setAnchorPoint(ccp(0.5, 1))
	titleSprite:setPosition(ccp(containerLayer:getContentSize().width*0.5, containerLayer:getContentSize().height))
	containerLayer:addChild(titleSprite)

	local lvSprite = CCSprite:create("images/common/lv.png")
	lvSprite:setAnchorPoint(ccp(0.5, 0.5))
	lvSprite:setPosition(ccp(70, titleSprite:getContentSize().height*0.5))
	titleSprite:addChild(lvSprite)

	-- 等级
	local lvLabel = CCRenderLabel:create(UserModel.getHeroLevel(), g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    lvLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    lvLabel:setAnchorPoint(ccp(0, 0.5))
    lvLabel:setPosition(ccp(90, titleSprite:getContentSize().height*0.5))
    titleSprite:addChild(lvLabel)

	local expProgressBg = CCSprite:create("images/common/progress_bg.png")
	expProgressBg:setPosition(130, titleSprite:getContentSize().height*0.5)
	expProgressBg:setAnchorPoint(ccp(0, 0.5))
	titleSprite:addChild(expProgressBg)
	-- 经验进度条
    _ccExpProgress = CCSprite:create(IMG_PATH .. "progress_blue.png")
    local size = _ccExpProgress:getContentSize()
    _nExpProgressOriWidth = size.width
    _ccExpProgress:setPosition(130, titleSprite:getContentSize().height*0.5)
    _ccExpProgress:setAnchorPoint(ccp(0, 0.5))
    _ccExpProgress:setTextureRect(CCRectMake(0, 0, size.width/2, size.height))
    titleSprite:addChild(_ccExpProgress)
	-- 经验值信息
    _ccLabelExp = CCLabelTTF:create ("1/1", g_sFontName, 18)
    _ccLabelExp:setPosition(size.width/2, size.height/2-2)
    _ccLabelExp:setColor(ccc3(0, 0, 0))
    _ccLabelExp:setAnchorPoint(ccp(0.5, 0.5))
    _ccExpProgress:addChild(_ccLabelExp)


-- 体力
	--position changed by zhang zihang
	local energyLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1032"), g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    energyLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    energyLabel:setAnchorPoint(ccp(0, 0.5))
    energyLabel:setPosition(ccp(titleSprite:getContentSize().width/2+70, titleSprite:getContentSize().height*0.5))
    titleSprite:addChild(energyLabel)

    local energyProgressBg = CCSprite:create("images/common/progress_bg.png")
    energyProgressBg:setAnchorPoint(ccp(0, 0.5))
	energyProgressBg:setPosition(titleSprite:getContentSize().width/2+115, titleSprite:getContentSize().height*0.5)
	titleSprite:addChild(energyProgressBg)

	-- 体力进度条
    _ccEnergyProgress = CCSprite:create(IMG_PATH .. "progress_yellow.png")
    _ccEnergyProgress:setAnchorPoint(ccp(0, 0.5))
    size = _ccEnergyProgress:getContentSize()
    _nEnergyProgressOriWidth = size.width
    _ccEnergyProgress:setPosition(titleSprite:getContentSize().width/2+115, titleSprite:getContentSize().height*0.5)
    _ccEnergyProgress:setTextureRect(CCRectMake(0, 0, size.width/2, size.height))
    titleSprite:addChild(_ccEnergyProgress)

    local maxEnergyNum = UserModel.getMaxExecutionNumber()

    -- 体力值信息
    _energy = CCLabelTTF:create (maxEnergyNum.."/"..maxEnergyNum, g_sFontName, 18)
    _energy:setColor(ccc3(0, 0, 0))
    _energy:setPosition(ccp(size.width/2, size.height/2-2))
    _energy:setAnchorPoint(ccp(0.5, 0.5))
    _ccEnergyProgress:addChild(_energy)

    refreshExpAndEnergy()
end

function refreshExpAndEnergy()
	updateEnergyValueUI()
	updateExpValueUI()
end

-- 更新体力值方法
function updateEnergyValueUI()
    if tolua.isnull(_energy) then
        return
    end
    local maxEnergyNum = UserModel.getMaxExecutionNumber()

    -- 体力值信息显示
    require "script/model/user/UserModel"
    local userInfo = UserModel.getUserInfo()
    local energyValue = tonumber(userInfo.execution)
    _energy:setString(energyValue.."/"..maxEnergyNum)
    local width = _nEnergyProgressOriWidth
    if energyValue < maxEnergyNum then
        width = math.floor(energyValue*_nEnergyProgressOriWidth/maxEnergyNum)
    end
    _ccEnergyProgress:setTextureRect(CCRectMake(0, 0, width, _ccEnergyProgress:getContentSize().height))
end

-- 更新经验值显示方法及进度条
function updateExpValueUI()
    -- 更新显示数据
    require "script/model/user/UserModel"
    local userInfo = UserModel.getUserInfo()
    require "db/DB_Level_up_exp"
    local tUpExp = DB_Level_up_exp.getDataById(2)
    local nLevelUpExp = tUpExp["lv_"..(tonumber(userInfo.level)+1)]
    if tolua.isnull(_ccLabelExp) then
        return
    end
    _ccLabelExp:setString(math.floor(userInfo.exp_num).."/"..nLevelUpExp)
    -- 更新进度条
    local nExpNum = tonumber(userInfo.exp_num)
    width = _nExpProgressOriWidth
    if nExpNum < nLevelUpExp then
        width = math.floor(nExpNum*_nExpProgressOriWidth/nLevelUpExp)
    end
    _ccExpProgress:setTextureRect(CCRectMake(0, 0, width, _ccExpProgress:getContentSize().height))
end

--[[
 @desc	创建据点的布局
 @para  table fortsData
 @return
 --]]
function createFortsLayout( fortsData, openTargetStongholdId)

	init()
	curCopyForts = fortsData
	_openTargetStongholdId = tonumber(openTargetStongholdId)


	containerLayer = MainScene.createBaseLayer(nil ,false, false, false)
	fortScrollView = CCScrollView:create()

	--增加背景音乐
    require "script/audio/AudioUtil"
    AudioUtil.playBgm("audio/bgm/" .. curCopyForts.copyInfo.music_path)

	require "script/utils/LuaUtil"

	fortMenuBar = CCMenu:create()
	require "script/ui/main/MainScene"

	local copyFileLua = "db/cxmlLua/copy_" .. curCopyForts.copy_id
	_G[copyFileLua] = nil
	package.loaded[copyFileLua] = nil
	require (copyFileLua)
	-- 该副本的第一个据点是否通过
    local isPassFirst = true
    if(table.count(curCopyForts.va_copy_info.progress)==1 ) then
    	for k,v in pairs(curCopyForts.va_copy_info.progress) do
    		if(tonumber(v) < 2)then
    			isPassFirst = false
    			break
    		end
    	end
    end

    if(curCopyForts.copyInfo.trans_bg and curCopyForts.copyInfo.trans_bg ~= "" and (isPassFirst == true or CopyUtil.isCopyIdHadDisplay(curCopyForts.copy_id) ) )then
    	-- 如果已经打过第一个据点，或者当前副本的对话已经展示过
    	layoutSprite = CCSprite:create("images/copy/ncopy/overallimage/" .. curCopyForts.copyInfo.trans_bg)
    	---------------------------------------- 副本特效 -----------------------------
		showCopyEffect()
    else
    	layoutSprite = CCSprite:create("images/copy/ncopy/overallimage/" .. copy.background)
    	if( curCopyForts.copyInfo.trans_bg == nil or curCopyForts.copyInfo.trans_bg == "" )then
    		showCopyEffect()
    	end
    end
	layoutSprite:setScale(1/MainScene.elementScale)
	absY = layoutSprite:getContentSize().height
	absX = layoutSprite:getContentSize().width
	layoutSprite:setScale(MainScene.bgScale)
	fortScrollView:setContainer(layoutSprite)
	fortScrollView:setTouchEnabled(true)
	fortScrollView:setViewSize(g_winSize)
	fortScrollView:setAnchorPoint(ccp(0,0))
	fortScrollView:setBounceable(false)
	fortScrollView:setScale(1/MainScene.elementScale)
	containerLayer:addChild(fortScrollView)
	-- containerLayer:registerScriptHandler(onNodeEvent)
	require "script/ui/copy/FortItem"

	local lastBaseId = 0
	local toPoint = nil
	lastFortMenuItem = nil
	local pngIndex = nil
	local animateIconName = nil

	for baseid,fVal in pairs(curCopyForts.va_copy_info.progress) do
		if( tonumber(baseid) > lastBaseId ) then
			lastBaseId = tonumber (baseid)
		end
	end

	-- 最后点击的据点
	local m_toPoint = nil
	-- 最后点击的据点
	local m_lastBaseId = nil

	-- 是否有最后一次记录
	for m_copyId, m_baseId in pairs(_lastCopyIdAndBaseId) do
		if( tonumber(m_copyId) == tonumber(curCopyForts.copy_id) ) then
			m_lastBaseId = tonumber (m_baseId)
			break
		end
	end

	-- 是否能够自动打开据点详情页
	local isNeedOpenBase = false
	local x = 1
	for baseid,fVal in pairs(curCopyForts.va_copy_info.progress) do
		local fortDesc = DB_Stronghold.getDataById(tonumber(baseid))

		if(_openTargetStongholdId and _openTargetStongholdId == tonumber(baseid)  )then
			-- 有要开启的据点
			isNeedOpenBase = true
		end
		fortDesc.progressStatus = fVal

		for k,fortInfo in pairs(copy.models.normal) do
			-- print("baseid == " .. baseid .. " , fortInfo.looks.look.armyID == " .. fortInfo.looks.look.armyID)
			if ( baseid == fortInfo.looks.look.armyID) then
				fortDesc.fortInfo = fortInfo
				local fortMenuItem = nil

				-- 最后点击的据点
				if(m_lastBaseId and tonumber(m_lastBaseId) == tonumber(baseid) )then
					m_toPoint = ccp(fortInfo.x, absY -fortInfo.y)
				end

				if( tonumber(baseid) == lastBaseId )then
					-- lastBaseId = tonumber (baseid)
					--added by 张梓航
					if tostring(fortDesc.progressStatus) <= "2" then
						fortMenuItem = FortItem.createItemImage(fortDesc, true)
					else
						fortMenuItem = FortItem.createItemImage(fortDesc, false)
					end
					toPoint = ccp(fortInfo.x, absY -fortInfo.y)
					lastFortMenuItem = fortMenuItem
					animateIconName = "images/base/hero/head_icon/" .. fortDesc.icon
					pngIndex = string.sub(fortDesc.fortInfo.looks.look.modelURL, 1, 1)
				else
					fortMenuItem = FortItem.createItemImage(fortDesc, false)
				end
				fortMenuItem:setAnchorPoint(ccp(0.5, 0))
				fortMenuItem:setPosition(ccp(fortInfo.x, absY -fortInfo.y))
				fortMenuBar:addChild(fortMenuItem, k, fortInfo.looks.look.armyID)
				fortMenuItem:registerScriptTapHandler(menuAction)
				break
			end
		end
	end

	if(m_lastBaseId and m_lastBaseId>0 and m_toPoint)then
		scrollToPoint(m_toPoint)
	elseif(lastBaseId>0 and toPoint ) then
		scrollToPoint(toPoint)
	end

	if( not CopyUtil.isOpendHadDisplay(lastBaseId))then
		CopyUtil.addOpenedFortId(lastBaseId)
		lastFortMenuItem:setVisible(false)
		createAnimation(toPoint, pngIndex, animateIconName)
	end
	fortMenuBar:setPosition(ccp(0,0))
	layoutSprite:addChild(fortMenuBar,10)

	if(isNeedOpenBase == true)then
		menuAction(_openTargetStongholdId, nil)
	else
		if(_openTargetStongholdId and _openTargetStongholdId >0 )then
			AnimationTip.showTip(GetLocalizeStringBy("key_1561"))
		end
	end


	addCloseFortsLayoutMenu()



------------------------------------------------ 标题--------------------------
	-- 标题栏
	local titleSprite = CCSprite:create("images/copy/bg.png")
	titleSprite:setAnchorPoint(ccp(1, 0))
	titleSprite:setPosition(ccp(containerLayer:getContentSize().width,0))
	containerLayer:addChild(titleSprite)
	local titleSpriteSize = titleSprite:getContentSize()
	local myScale = containerLayer:getContentSize().width/titleSprite:getContentSize().width/containerLayer:getElementScale()
	-- 标题文字
	-- local titleLabel = CCLabelTTF:create(curCopyForts.copyInfo.name, g_sFontName, 24)
	-- titleLabel:setAnchorPoint(ccp(0,0.5))
	-- titleLabel:setPosition(ccp(titleSprite:getContentSize().width * 0.05, titleSprite:getContentSize().height/2))
 --    titleLabel:setColor(ccc3(0xff, 0xdc, 0x20))
 --    titleSprite:addChild(titleLabel)
 --    titleSprite:setScale(myScale)

    --副本名称
    local nameSprite = CCSprite:create("images/copy/ncopy/nameimage/" .. curCopyForts.copyInfo.image)
    nameSprite:setAnchorPoint(ccp(0, 1))
    nameSprite:setPosition(containerLayer:getContentSize().width*0.03, containerLayer:getContentSize().height*0.95);
    containerLayer:addChild(nameSprite)

    -- 得心数
    local f_star_sp = CCSprite:create("images/hero/star.png")
    f_star_sp:setAnchorPoint(ccp(0, 0.5))
    f_star_sp:setPosition(ccp(80, titleSprite:getContentSize().height/2))
    titleSprite:addChild(f_star_sp)
    -- 数值
    local f_star_label = CCLabelTTF:create(curCopyForts.score, g_sFontPangWa, 24)
	f_star_label:setAnchorPoint(ccp(1, 0.5))
	f_star_label:setPosition(ccp( 70, titleSprite:getContentSize().height*0.45))
    f_star_label:setColor(ccc3(0xff, 0xdc, 0x20))
    titleSprite:addChild(f_star_label)

    -- 总星数
    local s_star_sp = CCSprite:create("images/hero/star.png")
    s_star_sp:setAnchorPoint(ccp(0, 0.5))
    s_star_sp:setPosition(ccp(160, titleSprite:getContentSize().height/2))
    titleSprite:addChild(s_star_sp)
    -- 数值
    local s_star_label = CCLabelTTF:create("/" .. curCopyForts.copyInfo.all_stars, g_sFontPangWa, 24)
	s_star_label:setAnchorPoint(ccp(0, 0.5))
	s_star_label:setPosition(ccp(110, titleSprite:getContentSize().height*0.45))
    s_star_label:setColor(ccc3(0xff, 0xdc, 0x20))
    titleSprite:addChild(s_star_label)


    createExpAndEnergyProgress()

------------------------------------------ 副本奖励
	copyRewardUI()
    copy = nil
    package.loaded[copyFileLua] = nil

    
    -- 对话
    if( (not isPassFirst) and curCopyForts.copyInfo.dialogid and  tonumber(curCopyForts.copyInfo.dialogid)>0 and (not CopyUtil.isCopyIdHadDisplay(curCopyForts.copy_id)) ) then
    	CopyUtil.addHadDialogCopyId(curCopyForts.copy_id)
    	require "script/ui/talk/talkLayer"
	    local talkLayer = TalkLayer.createTalkLayer(curCopyForts.copyInfo.dialogid)
	    local runningScene = CCDirector:sharedDirector():getRunningScene()
	    runningScene:addChild(talkLayer,999999)
	    TalkLayer.setCallbackFunction(endTalkCallbackFunc)
	else
		guideFunc()
    end
	return containerLayer
end

--  切换背景
function transBG( talk_layer)
	if( layoutSprite ~= nil and tolua.cast(layoutSprite, "CCSprite") and curCopyForts.copyInfo.trans_effect )then
		talk_layer:setVisible(false)
		local runningScene = CCDirector:sharedDirector():getRunningScene()
		local trans_effect = XMLSprite:create("images/base/effect/copy/trans/" ..curCopyForts.copyInfo.trans_effect )    
        -- trans_effect:setReplayTimes(5)
        trans_effect:registerEndCallback(function( ... )
        	
        	trans_effect:removeFromParentAndCleanup(true)
        	talk_layer:setVisible(true)
        	layoutSprite:setTexture(CCTextureCache:sharedTextureCache():addImage("images/copy/ncopy/overallimage/" .. curCopyForts.copyInfo.trans_bg))
        end)
        trans_effect:setPosition(ccp(runningScene:getContentSize().width * 0.5, runningScene:getContentSize().height * 0.5))
        trans_effect:setAnchorPoint(ccp(0.5, 0.5))
        trans_effect:setScale(g_fBgScaleRatio)
        
    	runningScene:addChild(trans_effect, 999999)

    	-- 显示副本特效
		showCopyEffect()
	end
end

function showCopyEffect()
	---------------------------------------- 副本特效 -----------------------------
	-- 据点下层特效
	print("curCopyForts.copy_id",curCopyForts.copy_id)
	local downEffectTab = CopyUtil.getDownEffectByCopyId( curCopyForts.copy_id )
	for i=1,#downEffectTab do
		-- 特效
    	local effectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/copy/bg_effect/" .. downEffectTab[i].effect_name ), -1,CCString:create(""))
	    effectSprite:setPosition(ccp(downEffectTab[i].effect_posx,downEffectTab[i].effect_posy))
	    layoutSprite:addChild(effectSprite,1)
	end

	-- 据点上层特效
	local upEffectTab = CopyUtil.getUpEffectByCopyId( curCopyForts.copy_id )
	for i=1,#upEffectTab do
		-- 特效
    	local effectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/copy/bg_effect/" .. upEffectTab[i].effect_name ), -1,CCString:create(""))
	    effectSprite:setPosition(ccp(upEffectTab[i].effect_posx,upEffectTab[i].effect_posy))
	    layoutSprite:addChild(effectSprite,20)
	end
end

function doBattleOverCallback()

	-- add by chengliang
	require "script/ui/copy/ShowNewCopyLayer"
	ShowNewCopyLayer.showNewCopy()


	require "script/guide/CopyBoxGuide"

	if(CopyUtil.isFirstPassCopy_1 == true) then
		CopyBoxGuide.CopyFirstDidOver()
	end


    -- CCNotificationCenter:sharedNotificationCenter():postNotification("NC_FightOver")
    guideFunc()
end

-- 对话结束回调
function endTalkCallbackFunc()

end

function guideFunc( )
	local newGuideAction = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(addNewGuide))
	containerLayer:runAction(newGuideAction)
end

-- 新手引导
function getGuideObject()
	return lastFortMenuItem
end

function getGuideObject_2(  )
	return _copperBox
end

function getGuideObject_3()
	return closeMenuItem
end



--add by lichenyang
function addNewGuide( ... )
		---[==[ 强化所第12步 第4个据点
    ---------------------新手引导---------------------------------
        --add by licong 2013.09.07
        require "script/guide/NewGuide"
        require "script/guide/StrengthenGuide"
        if(NewGuide.guideClass ==  ksGuideForge and StrengthenGuide.stepNum == 11 and StrengthenGuide.fightTimes == 1) then
            local strengthenButton = getGuideObject()
            local touchRect = getSpriteScreenRect(strengthenButton)
            StrengthenGuide.show(12, touchRect)
        end
    ---------------------end-------------------------------------
    --]==]

	---[==[ 强化所第11步 第3个据点
        ---------------------新手引导---------------------------------
            --add by licong 2013.09.07
            require "script/guide/NewGuide"
            require "script/guide/StrengthenGuide"
            if(NewGuide.guideClass ==  ksGuideForge and StrengthenGuide.stepNum == 10 and StrengthenGuide.fightTimes == 0) then
                local strengthenButton = getGuideObject()
                local touchRect = getSpriteScreenRect(strengthenButton)
                StrengthenGuide.show(11, touchRect)
            end
         ---------------------end-------------------------------------
    --]==]

    ---[==[ 等级礼包第19步 第5个据点
        ---------------------新手引导---------------------------------
        --add by licong 2013.09.09
        require "script/guide/NewGuide"
        require "script/guide/LevelGiftBagGuide"
        if(NewGuide.guideClass ==  ksGuideFiveLevelGift and LevelGiftBagGuide.stepNum == 18 and LevelGiftBagGuide.fightTimes == 0) then
            local levelGiftBagGuide_button = getGuideObject()
            local touchRect = getSpriteScreenRect(levelGiftBagGuide_button)
            LevelGiftBagGuide.show(19, touchRect)
        end
        ---------------------end-------------------------------------
   	--]==]

	---------------------新手引导---------------------------------
    require "script/guide/NewGuide"
    if(NewGuide.guideClass ==  ksGuideFormation and FormationGuide.stepNum == 6) then
	    --add by lichenyang 2013.08.29
	    require "script/guide/FormationGuide"
	    local formationButton = FortsLayout.getGuideObject()
	    local touchRect       = getSpriteScreenRect(formationButton)
	    FormationGuide.show(7, touchRect)
	end
    ---------------------end-------------------------------------

 --    require "script/guide/CopyBoxGuide"
 --   	if(NewGuide.guideClass ==  ksGuideCopyBox and CopyBoxGuide.stepNum == 0 ) then
	--     require "script/ui/copy/FortsLayout"
	--     local copyBoxGuide_button = FortsLayout.getGuideObject_2()
	--     local touchRect = getSpriteScreenRect(copyBoxGuide_button)
	--     CopyBoxGuide.show(1, touchRect)
	-- end
	print("ksGuideGeneralUpgrade GeneralUpgradeGuide.stepNum == 5")
	require "script/guide/NewGuide"
	require "script/guide/GeneralUpgradeGuide"

    if(NewGuide.guideClass ==  ksGuideGeneralUpgrade and GeneralUpgradeGuide.stepNum == 5) then
       	require "script/ui/main/MainBaseLayer"
     	local equipButton = getGuideObject()
        local touchRect   = getSpriteScreenRect(equipButton)
        GeneralUpgradeGuide.show(6,touchRect)
    end

    print("进阶引导打于吉 step = ", GeneralUpgradeGuide.stepNum)
	--进阶引导打于吉
	if(NewGuide.guideClass ==  ksGuideGeneralUpgrade and GeneralUpgradeGuide.stepNum == 7) then
		print(GetLocalizeStringBy("key_1888"))
       	require "script/ui/main/MainBaseLayer"
       	GeneralUpgradeGuide.changeLayer()
     	local equipButton = getGuideObject()
        local touchRect   = getSpriteScreenRect(equipButton)
        GeneralUpgradeGuide.show(8,touchRect)
    end
end

function addLevelGiftBagNewGuide( ... )
	 ---[==[ 等级礼包第20步 第5个据点战斗面板
     ---------------------新手引导---------------------------------
     --add by licong 2013.09.09
     require "script/guide/NewGuide"
     require "script/guide/LevelGiftBagGuide"
     if(NewGuide.guideClass ==  ksGuideFiveLevelGift and LevelGiftBagGuide.stepNum == 19 and LevelGiftBagGuide.fightTimes == 0) then
        require "script/ui/copy/FortInfoLayer"
        local levelGiftBagGuide_button = FortInfoLayer.getGuideObject()
        local touchRect = getSpriteScreenRect(levelGiftBagGuide_button)
        LevelGiftBagGuide.show(20, touchRect)
     end
     ---------------------end-------------------------------------
	--]==]
	--进阶引导战斗面板
	if(NewGuide.guideClass ==  ksGuideGeneralUpgrade and GeneralUpgradeGuide.stepNum == 6) then
       	require "script/ui/main/MainBaseLayer"
       	GeneralUpgradeGuide.changeLayer()
     	local equipButton = FortInfoLayer.getGuideObject()
        local touchRect   = getSpriteScreenRect(equipButton)
        GeneralUpgradeGuide.show(7,touchRect)
    end
end
