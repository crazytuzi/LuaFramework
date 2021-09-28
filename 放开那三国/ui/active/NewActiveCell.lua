-- Filename: NewActiveCell.lua
-- Author: llp
-- Date: 2015-10-8
-- Purpose: 该文件用于:新活动的cell

module("NewActiveCell", package.seeall)

require "script/ui/tip/AnimationTip"
require "script/ui/item/ItemSprite"
require "script/ui/active/NewActiveUtil"

local _curItem = nil
local _curReceiveSp = nil
local getCallback = nil
local _tagCopy 					= 1
local _tagBattle 				= 2
local _tagRob					= 3
local _tagFight					= 5
local _tagOpenBag				= 4

local function copyAction()
	-- body
	require "script/ui/copy/CopyLayer"
	CopyLayer.registerDidTableViewCallBack(didCreateTableView)
	CopyLayer.registerSelectCopyCallback(didClickCopyCallback)

	local copyLayer = CopyLayer.createLayer()
	MainScene.changeLayer(copyLayer, "copyLayer")
end

local function battleAction()
	-- body
	if(ItemUtil.isBagFull() == true )then
		ArenaGuide.closeGuide()
		return
	end
	-- 判断武将满了
	require "script/ui/hero/HeroPublicUI"
    if HeroPublicUI.showHeroIsLimitedUI() then

    	return
    end
	---[==[竞技场 清除新手引导
	---------------------新手引导---------------------------------
	--add by licong 2013.09.29
	require "script/guide/NewGuide"
	if(NewGuide.guideClass == ksGuideArena) then
		require "script/guide/ArenaGuide"
		ArenaGuide.cleanLayer()
	end
	---------------------end-------------------------------------
	--]==]
	local canEnter = DataCache.getSwitchNodeState( ksSwitchArena )
	if( canEnter ) then
		require "script/ui/arena/ArenaLayer"
		local arenaLayer = ArenaLayer.createArenaLayer()
		MainScene.changeLayer(arenaLayer, "arenaLayer")
	end
end

local function robAction()
	-- body
	require "script/guide/NewGuide"
	if(ItemUtil.isBagFull() == true )then
		if(NewGuide.guideClass == ksGuideRobTreasure) then
			--	如果背包满的话，关闭夺宝新手引导
			RobTreasureGuide.cleanLayer()
			RobTreasureGuide.stepNum =0
			NewGuide.guideClass = ksGuideClose
			BTUtil:setGuideState(false)
		end
		return
	end
	-- 判断武将满了
	require "script/ui/hero/HeroPublicUI"
    if HeroPublicUI.showHeroIsLimitedUI() then
		if(NewGuide.guideClass == ksGuideRobTreasure) then
			--	如果武将满的话，关闭夺宝新手引导
			RobTreasureGuide.cleanLayer()
			RobTreasureGuide.stepNum =0
			NewGuide.guideClass = ksGuideClose
			BTUtil:setGuideState(false)
		end
    	return
    end
	if(DataCache.getSwitchNodeState( ksSwitchRobTreasure ) ~= true) then
		return
	end
	require "script/ui/treasure/TreasureMainView"
	local treasureLayer = TreasureMainView.create()
	MainScene.changeLayer(treasureLayer,"treasureLayer")

	require "script/guide/NewGuide"
	if(NewGuide.guideClass == ksGuideRobTreasure) then
		RobTreasureGuide.changLayer()
	end
end

local function fightAction()
	-- body
	if(ItemUtil.isBagFull() == true )then
		return
	end
	-- 判断武将满了
	require "script/ui/hero/HeroPublicUI"
    if HeroPublicUI.showHeroIsLimitedUI() then
    	return
    end
	---[==[比武 新手引导屏蔽层
	---------------------新手引导---------------------------------
	--add by licong 2013.09.29
	require "script/guide/NewGuide"
	if(NewGuide.guideClass == ksGuideContest) then
		require "script/guide/MatchGuide"
		MatchGuide.changLayer()
	end
	---------------------end-------------------------------------
	--]==]
	local canEnter = DataCache.getSwitchNodeState( ksSwitchContest )
	if( canEnter ) then
		require "script/ui/match/MatchLayer"
		local matchLayer = MatchLayer.createMatchLayer()
		MainScene.changeLayer(matchLayer, "matchLayer")
	end
end

local function bagAction()
	-- body
	require "script/ui/bag/BagLayer"
    if( BagLayer.getShowBagType() == BagLayer.Type_Bag_Prop_Treas )then 
    	return
    end

	local bagLayer = BagLayer.createLayer(BagLayer.Tag_Init_Props, BagLayer.Type_Bag_Prop_Treas)
	MainScene.changeLayer(bagLayer, "bagLayer")
end

local function goAction(tag,pBtn)
	-- body
	if(tag==_tagCopy)then
		copyAction()
	elseif(tag==_tagBattle)then
		battleAction()
	elseif(tag==_tagRob)then
		robAction()
	elseif(tag==_tagFight)then
		fightAction()
	else
		bagAction()
	end
end

-- 领取按钮的回调
local function receiveAction( tag,item )
	require "script/ui/item/ItemUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if(ItemUtil.isBagFull() == true )then
		return
	end
	local pitem = item
	local pMenu = item:getParent()

	NewActiveController.getReward(tag)
end


function createCell(cellValues,p_index)

	local tCell = CCTableViewCell:create()

	local cellbg = CCSprite:create("images/common/newbg.png")
		  cellbg:setScale(g_fScaleX)
	tCell:addChild(cellbg,1,1)
	
	local signBottom = CCSprite:create("images/sign/sign_bottom.png")
		  signBottom:setPosition(ccp(3,cellbg:getContentSize().height*0.72))
	cellbg:addChild(signBottom)

	local str = string.format(cellValues.config.desc, cellValues.config.reward[p_index+1].num)
	local signDaysLabel = CCRenderLabel:create(str, g_sFontName,26,1,ccc3(0x00,0x00,0x00),type_stroke)
		  signDaysLabel:setPosition(ccp(signBottom:getContentSize().width*0.13,signBottom:getContentSize().height*0.8))
	signBottom:addChild(signDaysLabel)

	local progressStr = string.format(GetLocalizeStringBy("llp_254"),cellValues.taskInfo.num,cellValues.config.reward[p_index+1].num)
	local progressLabel = CCRenderLabel:create(progressStr, g_sFontName,24,2,ccc3(0x00,0x00,0x00),type_stroke)
		  progressLabel:setAnchorPoint(ccp(0.5,1))
		  progressLabel:setPosition(ccp(cellbg:getContentSize().width-progressLabel:getContentSize().width*0.7,cellbg:getContentSize().height*0.9))
	cellbg:addChild(progressLabel)
	if(tonumber(cellValues.taskInfo.num)>=tonumber(cellValues.config.reward[p_index+1].num))then
		progressLabel:setColor(ccc3(0x00,0xff,0x18))
	end

	local all_good = ItemUtil.getServiceReward(cellValues.config.reward[p_index+1].reward)
	for i=1,table.count(all_good) do
		local data = all_good[i]
		local iconBg
		local iconSp
		local itemdata = ItemUtil.getItemById(data.tid)
		iconBg = ItemUtil.createGoodsIcon(data,-498,nil,-499,nil,true)
		iconBg:setPosition(ccp(cellbg:getContentSize().width*0.055+cellbg:getContentSize().width*(i-1)*0.18,cellbg:getContentSize().height*0.23))
		cellbg:addChild(iconBg)
	end

	local menu = CCMenu:create()
		  menu:setPosition(ccp(0,0))
		  menu:setTouchPriority(-498)
	cellbg:addChild(menu,11,101)

	local receiveBtn = LuaCC.create9ScaleMenuItem("images/common/btn/green01_n.png", "images/common/btn/green01_h.png",CCSizeMake(134, 64), GetLocalizeStringBy("llp_253"),ccc3(0xfe, 0xdb, 0x1c),fontSize,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		  receiveBtn:setAnchorPoint(ccp(1,0.5))
		  receiveBtn:setPosition(ccp(cellbg:getContentSize().width,cellbg:getContentSize().height*0.4))
		  receiveBtn:registerScriptTapHandler(receiveAction)
		  receiveBtn:setVisible(false)
	menu:addChild(receiveBtn,1 ,cellValues.config.reward[p_index+1].id)

	local receive_alreadySp = CCSprite:create("images/sign/receive_already.png")
		  receive_alreadySp:setAnchorPoint(ccp(1,0.5))
		  receive_alreadySp:setPosition(ccp(cellbg:getContentSize().width,cellbg:getContentSize().height*0.4))
		  receive_alreadySp:setVisible(false)
	cellbg:addChild(receive_alreadySp,0,4)

	local goBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png",CCSizeMake(134, 64), GetLocalizeStringBy("llp_252"),ccc3(0xfe, 0xdb, 0x1c),fontSize,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		  goBtn:setAnchorPoint(ccp(1,0.5))
		  goBtn:setPosition(ccp(cellbg:getContentSize().width,cellbg:getContentSize().height*0.4))
		  goBtn:registerScriptTapHandler(goAction)
		  goBtn:setVisible(false)
	menu:addChild(goBtn,1,cellValues.config.id)

	if(cellValues.config.reward[p_index+1].status==0)then
		receiveBtn:setVisible(true)
		goBtn:setVisible(false)
		receive_alreadySp:setVisible(false)
	elseif(cellValues.config.reward[p_index+1].status==1)then
		receiveBtn:setVisible(false)
		goBtn:setVisible(true)
		receive_alreadySp:setVisible(false)
	else
		receiveBtn:setVisible(false)
		goBtn:setVisible(false)
		receive_alreadySp:setVisible(true)
	end

	return tCell
end