-- Filename: Olympic4Layer.lua
-- Author: Zhang Zihang
-- Date: 2014-07-17
-- Purpose: 擂台争霸4强场景

module("Olympic4Layer",package.seeall)

require "script/ui/main/MainScene"
require "script/audio/AudioUtil"
require "script/ui/olympic/OlympicData"
require "script/model/utils/HeroUtil"
require "script/model/hero/HeroModel"
require "script/ui/olympic/OlympicService"
require "script/utils/BaseUI"
require "script/model/user/UserModel"

local _bgLayer 				--基础背景层
local _middleNode 			--中部node
local _middleNodeMenu 		--中部按钮层
local _finalFourInfo 		--四强信息
local _finalTwoInfo 		--两强信息
local _finalOneInfo 		--冠军信息 
local _battleReportInfo 	--战报信息
local _nowStageEndTime 		--当前阶段结束时间
local _timeString 			--时间string
local _haveFinalTwo			--是否有两强
local _haveFinalOne 		--是否有冠军
local _desTimeNode 			--倒计时底
local _countingLabel 		--倒计时计算结果

local kGrayTag = 1000 		--灰色鼓舞下标
local kGrayLineTag = 2000 	--灰色线下标
local kGoldLineTag = 3000 	--金色线下标
local kReportTag = 4000 	--查看战报下标
local kGrayReportTag = 5000 --灰色战报下标
local kCheerNodeTag = 6000 	--鼓舞node下标
local kBodyTag = 7000		--小人儿下标

----------------------------------------线段tag值是按这个顺序来的^_^----------------------------------------
--                      11
--        7      9             10     8
--        5                           6
-- 1             2             3             4

----------------------------------------初始化函数----------------------------------------
local function init()
	_bgLayer = nil
	_middleNode = nil
	_middleNodeMenu = nil
	_nowStageEndTime = nil
	_timeString = nil
	_countingLabel = nil
	_haveFinalTwo = false
	_haveFinalOne = false
	_finalFourInfo = {}
	_finalTwoInfo = {}
	_finalOneInfo = {}
	_battleReportInfo = {
							0,0,0,
						}
end

--[[
	@des 	:初始化线和按钮的状态
	@param 	:
	@return :
--]]
function initItemState()
	--所有线都初始化为灰，金线不显示
	for i = 1,11 do
		local curGoldLine = _middleNode:getChildByTag(kGoldLineTag + i)
		local curGrayLine = _middleNode:getChildByTag(kGrayLineTag + i)
		curGrayLine:setVisible(true)
		curGoldLine:setVisible(false)
	end

	for i = 1,3 do
		local curMenuItem = _middleNodeMenu:getChildByTag(kReportTag + i)
		local curGraySprite = _middleNode:getChildByTag(kGrayReportTag + i)
		curMenuItem:setVisible(false)
		curGraySprite:setVisible(true)
	end
end

----------------------------------------回调函数----------------------------------------
--[[
	@des 	:奖池回调
	@param 	:
	@return :
--]]
function rewardPoolCallback()
	require "script/ui/olympic/AwardPoolLayer"
	AwardPoolLayer.showLayer()
end

--[[
	@des 	:奖励预览回调
	@param 	:
	@return :
--]]
function rewardPreviewCallback()
	require "script/ui/olympic/rewardPreview/OlympicRewardLayer"
	OlympicRewardLayer.showLayer()
end

--[[
	@des 	:返回回调
	@param 	:
	@return :
--]]
function returnCallBack()
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	--切换到活动界面

	local requestCallback = function ( ... )
		require "script/ui/active/ActiveList"
		local  activeList = ActiveList.createActiveListLayer()
		MainScene.changeLayer(activeList, "activeList")
	end
	OlympicService.leave(requestCallback)
end

--[[
	@des 	:活动描述回调
	@param 	:
	@return :
--]]
function describeCallBack()
	require "script/ui/olympic/ExplainDialog"
	ExplainDialog.show(-3000)
end

--[[
	@des 	:我的战报回调
	@param 	:
	@return :
--]]
function myReportCallBack()
	require "script/ui/olympic/battleReport/CheckBattleReportLayer"
	CheckBattleReportLayer.showLayer()
end

--[[
	@des 	:战况回顾回调
	@param 	:
	@return :
--]]
function memoryCallBack()
	require "script/ui/olympic/Olympic32Layer"
	Olympic32Layer.show()
end

--[[
	@des 	:鼓舞回调
	@param 	:
	@return :
--]]
function cheerUpCallBack(tag,p_item)
	--鼓舞确定按钮回调
	sureCallBack = function()
		--诸位按钮设为不可见
		p_item:setVisible(false)

		--对应位置的鼓舞完成按钮
		local tempOverSprite = _middleNode:getChildByTag(tag)
		tempOverSprite:setVisible(true)

		-- local tempCheerUpNode = tolua.cast(_middleNode:getChildByTag(kCheerNodeTag + tag), "CCNode")
		-- print("得到的node",tempCheerUpNode)
		-- local cheerUpLabel = tolua.cast(tempCheerUpNode:getChildByTag(1), "CCRenderLabel")
		-- print("得到的label",cheerUpLabel)
		-- cheerUpLabel:setString(tostring(OlympicData.getPlayerCheerNum(_finalFourInfo[tag].uid)))

		for i = 1,4 do
			if i ~= tag then
				local otherMenuItem = _middleNodeMenu:getChildByTag(i)
				otherMenuItem:setVisible(false)
				local otherSprite = _middleNode:getChildByTag(i + kGrayTag)
				otherSprite:setVisible(false)
			end
		end
	end

	--过了助威阶段且当前没有助威，则弹出，不可助威
	require "script/ui/tip/AnimationTip"
	print("当前阶段",OlympicData.getStage())
	print("已助威id",OlympicData.getCheerUid())
	print("是否报名",OlympicData.isUserRegister(UserModel.getUserUid()))
	if (OlympicData.getStage() >= 7) and (OlympicData.getCheerUid() == 0) then
		AnimationTip.showTip(GetLocalizeStringBy("zzh_1056"))
	elseif OlympicData.isUserRegister(UserModel.getUserUid()) then
		AnimationTip.showTip(GetLocalizeStringBy("zzh_1057"))
	else
		require "script/ui/olympic/CheerUpLayer"
		CheerUpLayer.showLayer(_finalFourInfo[tag],sureCallBack)
	end
end

--[[
	@des 	:查看战报回调
	@param 	:查看战报按钮tag
	@return :
--]]
function checkReportCallBack(tag)
	--对应_battleReportInfo表的下标
	local tableIndex = tag - kReportTag
	print("#####################################################")
	print("tag,kReportTag",tag)
	print_t(_battleReportInfo)

	-- local battleCallBack = function(cbFlag,dictData,bRet)
	-- 	if not bRet then
	--         return
	--     end
	--     if cbFlag == "battle.getRecord" then
	--     	-- require "script/battle/BattleLayer"
	--     	-- BattleLayer.showBattleWithString(dictData.ret,nil,nil,nil,nil,nil,nil,nil,true)
	--     	require "script/battle/BattleUtil"
	--     	BattleUtil.playerBattleReportById()
	--     end
	-- end

	-- require "script/network/RequestCenter"
	-- local createParams = CCArray:create()
 --   	createParams:addObject(CCInteger:create(_battleReportInfo[tableIndex]))
	-- local backMes = RequestCenter.battle_getRecord(battleCallBack,createParams)
	require "script/battle/BattleUtil"
	BattleUtil.playerBattleReportById(_battleReportInfo[tableIndex])
end

--[[
	@des 	:推送战报回调
	@param 	:$ p_signIndex 		32强报名位置
	@param 	:$ p_showReport 	是否显示战报按钮
	@return :
--]]
function pushReportCallBack(p_signIndexTable,p_showReport)
	if p_showReport ~= false then
		print("战报推送~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	end
	--拉取四强信息，方便战报传递比赛位置
	local finalFourInfo,finalTwoInfo = OlympicData.getFinalFourInfo()
	print("推送后的四强信息")
	print_t(finalFourInfo)
	print("推送后两强的信息")
	print_t(finalTwoInfo)

	for j = 1,#p_signIndexTable do
		--赢家信息
		local winnerData = OlympicData.getUserInfoByOlympicIndex(p_signIndexTable[j])
		print("赢家信息")
		print_t(winnerData)
		--如果赢家是2强之一

		local playerGender = HeroModel.getSex(winnerData.htid)
		local imagePath
		if not table.isEmpty(winnerData.dress) then
			imagePath = HeroUtil.getHeroBodyImgByHTID(winnerData.htid,winnerData.dress["1"],playerGender)
		else
			imagePath = HeroUtil.getHeroBodyImgByHTID(winnerData.htid)
		end
		local playerBodySprite = CCSprite:create(tostring(imagePath))

		playerBodySprite:setAnchorPoint(ccp(0.5,0))
		playerBodySprite:setScale(0.35)

		local playerNameLabel = CCRenderLabel:create(winnerData.uname,g_sFontPangWa,18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		if tonumber(winnerData.uid) == tonumber(UserModel.getUserUid()) then
			playerNameLabel:setColor(ccc3(0xe4,0x00,0xff))
		end
		playerNameLabel:setAnchorPoint(ccp(0.5,0))

		--获得助威数
		local gainCheerUpLabel = CCRenderLabel:create(GetLocalizeStringBy("zzh_1039"),g_sFontName,18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		gainCheerUpLabel:setColor(ccc3(0xff,0xf6,0x00))

		local cheerUpNumLabel
		if winnerData.be_cheer_num ~= nil then
			cheerUpNumLabel = CCRenderLabel:create(tostring(winnerData.be_cheer_num),g_sFontName,18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		else
			cheerUpNumLabel = CCRenderLabel:create("0",g_sFontName,18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		end
		cheerUpNumLabel:setColor(ccc3(0x00,0xff,0x18))

		--阳仔说可以用BaseUI了
		local cheerUpNode = BaseUI.createHorizontalNode({gainCheerUpLabel,cheerUpNumLabel})
		cheerUpNode:setAnchorPoint(ccp(0.5,1))
		
		if tonumber(winnerData.final_rank) == 2 then
			--------------------------------------------------------------创建特效-------------------------------------------------------------------
			local effectGap = (640-160)/3
			local effectPosY = 70
			local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/jinjidibao/jinjidibao" ), -1,CCString:create(""))
			spellEffectSprite:setPosition(ccp(80 + effectGap*(math.floor(winnerData.olympic_index/8)),effectPosY))
		    spellEffectSprite:setAnchorPoint(ccp(0.5, 0))
		    _middleNode:addChild(spellEffectSprite,9999)

		    local animationEnd = function(actionName,xmlSprite)
		   		spellEffectSprite:retain()
				spellEffectSprite:autorelease()
		        spellEffectSprite:removeFromParentAndCleanup(true)
		    end

		    local animationFrameChanged = function(frameIndex,xmlSprite)
		    end

		    local delegate = BTAnimationEventDelegate:create()
		    delegate:registerLayerEndedHandler(animationEnd)
		    delegate:registerLayerChangedHandler(animationFrameChanged)
		    
		    spellEffectSprite:setDelegate(delegate)
			--------------------------------------------------------------创建特效结束-------------------------------------------------------------------

			local secondBeginX = 80 + (640-160)/6
			local secondGap = 640 - secondBeginX*2
			local bodyPosY = 320
			
			playerBodySprite:setPosition(ccp(secondBeginX + math.floor(winnerData.olympic_index/16)*secondGap,bodyPosY))
			playerNameLabel:setPosition(ccp(secondBeginX + math.floor(winnerData.olympic_index/16)*secondGap,bodyPosY - 25))
			cheerUpNode:setPosition(ccp(secondBeginX + math.floor(winnerData.olympic_index/16)*secondGap,bodyPosY - 25))
			
			local grayLine_1 = _middleNode:getChildByTag(kGrayLineTag + math.floor(winnerData.olympic_index/8) + 1)
			grayLine_1:setVisible(false)
			local goldLine_1 = _middleNode:getChildByTag(kGoldLineTag + math.floor(winnerData.olympic_index/8) + 1)
			goldLine_1:setVisible(true)
			local grayLine_2 = _middleNode:getChildByTag(kGrayLineTag + math.floor(winnerData.olympic_index/16) + 5)
			grayLine_2:setVisible(false)
			local goldLine_2 = _middleNode:getChildByTag(kGoldLineTag + math.floor(winnerData.olympic_index/16) + 5)
			goldLine_2:setVisible(true)

			--若没有参数，则代表有战报推来，显示查看战报按钮
			if p_showReport ~= false then
				local grayReportSprite = _middleNode:getChildByTag(kGrayReportTag + math.floor(winnerData.olympic_index/16) + 1)
				grayReportSprite:setVisible(false)
				local reportMenuItem = _middleNodeMenu:getChildByTag(kReportTag + math.floor(winnerData.olympic_index/16) + 1)
				reportMenuItem:setVisible(true)

				if math.floor(winnerData.olympic_index/16) == 0 then
					_battleReportInfo[1] = OlympicData.getReportIdByOlympicPos(finalFourInfo[1].olympic_index,finalFourInfo[2].olympic_index)
				elseif math.floor(winnerData.olympic_index/16) == 1 then
					_battleReportInfo[2] = OlympicData.getReportIdByOlympicPos(finalFourInfo[3].olympic_index,finalFourInfo[4].olympic_index)
				end
			end

			_middleNode:addChild(playerBodySprite,3,kBodyTag + 5 + math.floor(winnerData.olympic_index/16))

			local bodySprite = tolua.cast(_middleNode:getChildByTag(kBodyTag + 1 + math.floor(winnerData.olympic_index/8)),"CCSprite")
			local winSprite = CCSprite:create("images/olympic/win.png")
			winSprite:setAnchorPoint(ccp(1,1))
			winSprite:setPosition(ccp(bodySprite:getContentSize().width/2 - 10,450))
			winSprite:setScale(1/0.35)
			bodySprite:addChild(winSprite)

			if 2*math.floor(winnerData.olympic_index/16) == math.floor(winnerData.olympic_index/8) then
				if not table.isEmpty(finalFourInfo[math.floor(winnerData.olympic_index/8) + 2]) then
					local lostBodySprite = tolua.cast(_middleNode:getChildByTag(kBodyTag + math.floor(winnerData.olympic_index/8) + 2),"CCSprite")
					local grayBodySprite = BTGraySprite:createWithSprite(lostBodySprite)
					grayBodySprite:setAnchorPoint(ccp(0.5,0.5))
					grayBodySprite:setPosition(ccp(lostBodySprite:getContentSize().width/2,lostBodySprite:getContentSize().height/2))
					lostBodySprite:addChild(grayBodySprite)
					local lostSprite = CCSprite:create("images/olympic/lost.png")
					lostSprite:setAnchorPoint(ccp(1,1))
					lostSprite:setPosition(ccp(grayBodySprite:getContentSize().width/2 - 10,450))
					lostSprite:setScale(1/0.35)
					grayBodySprite:addChild(lostSprite)
				end
			else
				if not table.isEmpty(finalFourInfo[math.floor(winnerData.olympic_index/8)]) then
					local lostBodySprite = tolua.cast(_middleNode:getChildByTag(kBodyTag + math.floor(winnerData.olympic_index/8)),"CCSprite")
					local grayBodySprite = BTGraySprite:createWithSprite(lostBodySprite)
					grayBodySprite:setAnchorPoint(ccp(0.5,0.5))
					grayBodySprite:setPosition(ccp(lostBodySprite:getContentSize().width/2,lostBodySprite:getContentSize().height/2))
					lostBodySprite:addChild(grayBodySprite)
					local lostSprite = CCSprite:create("images/olympic/lost.png")
					lostSprite:setAnchorPoint(ccp(1,1))
					lostSprite:setPosition(ccp(grayBodySprite:getContentSize().width/2 - 10,450))
					lostSprite:setScale(1/0.35)
					grayBodySprite:addChild(lostSprite)
				end
			end
		end

		if tonumber(winnerData.final_rank) == 1 then
			--------------------------------------------------------------创建特效-------------------------------------------------------------------
			local beginEffectX = 80 + (640-160)/6
			local effectGap = 640 - beginEffectX*2
			local effectPosY = 320
			local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/jinjidibao/jinjidibao" ), -1,CCString:create(""))
			spellEffectSprite:setPosition(ccp(beginEffectX + math.floor(winnerData.olympic_index/16)*effectGap,effectPosY))
		    spellEffectSprite:setAnchorPoint(ccp(0.5, 0))
		    _middleNode:addChild(spellEffectSprite,9999)

		    local animationEnd = function(actionName,xmlSprite)
		   		spellEffectSprite:retain()
				spellEffectSprite:autorelease()
		        spellEffectSprite:removeFromParentAndCleanup(true)
		    end

		    local animationFrameChanged = function(frameIndex,xmlSprite)
		    end

		    local delegate = BTAnimationEventDelegate:create()
		    delegate:registerLayerEndedHandler(animationEnd)
		    delegate:registerLayerChangedHandler(animationFrameChanged)
		    
		    spellEffectSprite:setDelegate(delegate)
			--------------------------------------------------------------创建特效结束-------------------------------------------------------------------

			local secondBeginX = 80 + (640-160)/6
			local secondGap = 640 - secondBeginX*2
			local bodyPosY = 560

			playerBodySprite:setPosition(ccp(secondBeginX + secondGap/2,bodyPosY))
			_middleNode:addChild(playerBodySprite,3)
			
			playerNameLabel:setPosition(ccp(secondBeginX + secondGap/2,bodyPosY - 25))
			cheerUpNode:setPosition(ccp(secondBeginX + secondGap/2,bodyPosY - 25))

			--皇冠
			local crownSprite = CCSprite:create("images/olympic/king_hat.png")
			crownSprite:setAnchorPoint(ccp(0.5,0))
			crownSprite:setPosition(ccp(playerBodySprite:getContentSize().width/2,285))
			crownSprite:setScale(1/0.35)
			playerBodySprite:addChild(crownSprite)

			local grayLine_1 = _middleNode:getChildByTag(kGrayLineTag + 11)
			grayLine_1:setVisible(false)
			local goldLine_1 = _middleNode:getChildByTag(kGoldLineTag + 11)
			goldLine_1:setVisible(true)

			local grayLine_2 = _middleNode:getChildByTag(kGrayLineTag + math.floor(winnerData.olympic_index/16) + 7)
			grayLine_2:setVisible(false)
			local goldLine_2 = _middleNode:getChildByTag(kGoldLineTag + math.floor(winnerData.olympic_index/16) + 7)
			goldLine_2:setVisible(true)

			local grayLine_3 = _middleNode:getChildByTag(kGrayLineTag + math.floor(winnerData.olympic_index/16) + 9)
			grayLine_3:setVisible(false)
			local goldLine_3 = _middleNode:getChildByTag(kGoldLineTag + math.floor(winnerData.olympic_index/16) + 9)
			goldLine_3:setVisible(true)

			--若没有参数，则代表有战报推来，显示查看战报按钮
			if p_showReport ~= false then
				local grayReportSprite = _middleNode:getChildByTag(kGrayReportTag + 3)
				grayReportSprite:setVisible(false)
				local reportMenuItem = _middleNodeMenu:getChildByTag(kReportTag + 3)
				reportMenuItem:setVisible(true)

				_battleReportInfo[3] = OlympicData.getReportIdByOlympicPos(finalTwoInfo[1].olympic_index,finalTwoInfo[2].olympic_index)
			end

			local bodySprite = tolua.cast(_middleNode:getChildByTag(kBodyTag + 5 + math.floor(winnerData.olympic_index/16)),"CCSprite")
			local winSprite = CCSprite:create("images/olympic/win.png")
			winSprite:setAnchorPoint(ccp(1,1))
			winSprite:setPosition(ccp(bodySprite:getContentSize().width/2 - 10,450))
			winSprite:setScale(1/0.35)
			bodySprite:addChild(winSprite)

			if math.floor(winnerData.olympic_index/16) == 0 then
				if not table.isEmpty(finalTwoInfo[2]) then
					local lostBodySprite = tolua.cast(_middleNode:getChildByTag(kBodyTag + 6),"CCSprite")
					local grayBodySprite = BTGraySprite:createWithSprite(lostBodySprite)
					grayBodySprite:setAnchorPoint(ccp(0.5,0.5))
					grayBodySprite:setPosition(ccp(lostBodySprite:getContentSize().width/2,lostBodySprite:getContentSize().height/2))
					lostBodySprite:addChild(grayBodySprite)
					local lostSprite = CCSprite:create("images/olympic/lost.png")
					lostSprite:setAnchorPoint(ccp(1,1))
					lostSprite:setPosition(ccp(grayBodySprite:getContentSize().width/2 - 10,450))
					lostSprite:setScale(1/0.35)
					grayBodySprite:addChild(lostSprite)
				end
			else
				if not table.isEmpty(finalTwoInfo[1]) then
					local lostBodySprite = tolua.cast(_middleNode:getChildByTag(kBodyTag + 5),"CCSprite")
					local grayBodySprite = BTGraySprite:createWithSprite(lostBodySprite)
					grayBodySprite:setAnchorPoint(ccp(0.5,0.5))
					grayBodySprite:setPosition(ccp(lostBodySprite:getContentSize().width/2,lostBodySprite:getContentSize().height/2))
					lostBodySprite:addChild(grayBodySprite)
					local lostSprite = CCSprite:create("images/olympic/lost.png")
					lostSprite:setAnchorPoint(ccp(1,1))
					lostSprite:setPosition(ccp(grayBodySprite:getContentSize().width/2 - 10,450))
					lostSprite:setScale(1/0.35)
					grayBodySprite:addChild(lostSprite)
				end
			end
		end
		_middleNode:addChild(playerNameLabel,1000)
		_middleNode:addChild(cheerUpNode,1000)
	end
end

function pushStageCallBack(p_stageNum)
	print("阶段",p_stageNum)
	print("阶段改变推送~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	local noEnemyTable = OlympicData.getOlympicIndexTableWithoutEnemy()
	_nowStageEndTime = OlympicData.getStageNowEndTime() - BTUtil:getSvrTimeInterval()
	--阶段改变，且玩家没有助威，则不可助威
	-- if OlympicData.getCheerUid() == 0 then
	-- 	for i = 1,4 do
	-- 		local tempOverSprite = _middleNode:getChildByTag(i)
	-- 		tempOverSprite:setVisible(false)
	-- 		local otherMenuItem = _middleNodeMenu:getChildByTag(i)
	-- 		otherMenuItem:setVisible(false)
	-- 		local otherSprite = _middleNode:getChildByTag(i + kGrayTag)
	-- 		otherSprite:setVisible(true)
	-- 	end
	-- end

	if tonumber(p_stageNum) == 7 then
		require "script/ui/olympic/Olympic32Layer"
		Olympic32Layer.runStageChangeAnimationByOlympicStage(tonumber(p_stageNum))
	end

	for k,v in pairs(noEnemyTable) do
		local outterTable = {}
		table.insert(outterTable,tonumber(v))
		pushReportCallBack(outterTable,false)
		outterTable = nil
	end

	if tonumber(p_stageNum) == 8 then
		OlympicData.addComboTimes()
	end

	require "script/ui/olympic/AwardPoolLayer"
	AwardPoolLayer.changeStageCallBack(p_stageNum)
end

----------------------------------------UI函数----------------------------------------
--[[
	@des 	:顶部UI
	@param 	:
	@return :
--]]
function createTopUI()
	--创建基础node，方便适配
	local topNode = CCNode:create()
	topNode:setAnchorPoint(ccp(0.5,1))
	topNode:setContentSize(CCSizeMake(640,215))
	topNode:setPosition(ccp(g_winSize.width/2, g_winSize.height))
	topNode:setScale(g_fScaleX)
	_bgLayer:addChild(topNode)

	--黄色分割线
	local lineSprite = CCSprite:create("images/copy/fort/top_cutline.png")
	lineSprite:setPosition(ccp(topNode:getContentSize().width/2,0))
	lineSprite:setAnchorPoint(ccp(0.5,0))
	topNode:addChild(lineSprite)

	--擂台争霸背景图片
	local titleBgSprite = CCSprite:create("images/olympic/title_bg.png")
	titleBgSprite:setAnchorPoint(ccp(0.5,1))
	titleBgSprite:setPosition(ccp(topNode:getContentSize().width/2,topNode:getContentSize().height - 20))
	topNode:addChild(titleBgSprite)

	--擂台争霸标题
	local titleSprite = CCSprite:create("images/olympic/title.png")
	titleSprite:setAnchorPoint(ccp(0.5,1))
	titleSprite:setPosition(ccp(topNode:getContentSize().width/2,topNode:getContentSize().height))
	topNode:addChild(titleSprite)

	--冠军争夺战 图片
	-- local championSprite = CCSprite:create("images/olympic/guanjun.png")
	-- championSprite:setAnchorPoint(ccp(0.5,1))
	-- championSprite:setPosition(ccp(topNode:getContentSize().width/2,topNode:getContentSize().height - 95))
	-- topNode:addChild(championSprite)

	-------------------------------------------------------------------------特效
	local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/guanjun/guanjun" ), -1,CCString:create(""))
	spellEffectSprite:setPosition(ccp(topNode:getContentSize().width/2,topNode:getContentSize().height - 120))
    spellEffectSprite:setAnchorPoint(ccp(0.5, 1))
    topNode:addChild(spellEffectSprite,9999)

    local animationEnd = function(actionName,xmlSprite)
  --  		spellEffectSprite:retain()
		-- spellEffectSprite:autorelease()
  --       spellEffectSprite:removeFromParentAndCleanup(true)
    end

    local animationFrameChanged = function(frameIndex,xmlSprite)
    end

    local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animationEnd)
    delegate:registerLayerChangedHandler(animationFrameChanged)
    
    spellEffectSprite:setDelegate(delegate)
	-------------------------------------------------------------------------特效结束

	--顶部菜单层
	local topMenu = CCMenu:create()
	topMenu:setPosition(ccp(0,0))
	topMenu:setAnchorPoint(ccp(0,0))
	topNode:addChild(topMenu)

	--奖池按钮
	local rewardPoolMenuItem = CCMenuItemImage:create("images/olympic/reward_pool_n.png","images/olympic/reward_pool_h.png")
	rewardPoolMenuItem:setAnchorPoint(ccp(0.5,0))
	rewardPoolMenuItem:registerScriptTapHandler(rewardPoolCallback)
	rewardPoolMenuItem:setPosition(ccp(topNode:getContentSize().width*0.1,topNode:getContentSize().height*0.1))
	--rewardPoolMenuItem:setVisible(false)
	topMenu:addChild(rewardPoolMenuItem)

	--擂台争霸奖励
	local rewardPreviewMenuItem = CCMenuItemImage:create("images/olympic/olympic_reward_n.png","images/olympic/olympic_reward_h.png")
	rewardPreviewMenuItem:setAnchorPoint(ccp(0.5,0))
	rewardPreviewMenuItem:registerScriptTapHandler(rewardPreviewCallback)
	rewardPreviewMenuItem:setPosition(ccp(topNode:getContentSize().width*0.9 ,topNode:getContentSize().height*0.1))
	topMenu:addChild(rewardPreviewMenuItem)

	--返回按钮
	local closeMenuItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	closeMenuItem:setAnchorPoint(ccp(1,1))
	closeMenuItem:registerScriptTapHandler(returnCallBack)
	closeMenuItem:setPosition(ccp(topNode:getContentSize().width*0.99 ,topNode:getContentSize().height*0.99))
	topMenu:addChild(closeMenuItem)

	--阳仔叫我抄他的 - -！
	require "script/ui/olympic/OlympicPrepareLayer"

	if OlympicData.getStage() <= 7 then
		_nowStageEndTime = OlympicData.getStageNowEndTime() - BTUtil:getSvrTimeInterval()
	else
		_nowStageEndTime = 0
	end
	if(_nowStageEndTime <0) then
		_nowStageEndTime = 0
	end

	local desNodeTable = {}
	if _nowStageEndTime == 0 then
		local alreadyStartLabel
		if OlympicData.getStage() == 8 then
			alreadyStartLabel = CCRenderLabel:create(GetLocalizeStringBy("zzh_1052"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		else
			alreadyStartLabel = CCRenderLabel:create(GetLocalizeStringBy("zzh_1054"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		end
		alreadyStartLabel:setColor(ccc3(0x00,0xff,0x18))
		desNodeTable = {alreadyStartLabel}
	else
		local timeDes = CCRenderLabel:create( GetLocalizeStringBy("zzh_1053") , g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
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
	_desTimeNode:setPosition(ccp(topNode:getContentSize().width/2, topNode:getContentSize().height * 0.25))
	topNode:addChild(_desTimeNode)

	_gameOverLabel = CCRenderLabel:create(GetLocalizeStringBy("zzh_1052"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_gameOverLabel:setColor(ccc3(0x00,0xff,0x18))
	_gameOverLabel:setAnchorPoint(ccp(0.5,0.5))
	_gameOverLabel:setPosition(ccp(topNode:getContentSize().width/2, topNode:getContentSize().height * 0.25))
	_gameOverLabel:setVisible(false)
	topNode:addChild(_gameOverLabel)

	_countingLabel = CCRenderLabel:create(GetLocalizeStringBy("zzh_1054"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_countingLabel:setColor(ccc3(0x00,0xff,0x18))
	_countingLabel:setAnchorPoint(ccp(0.5,0.5))
	_countingLabel:setPosition(ccp(topNode:getContentSize().width/2, topNode:getContentSize().height * 0.25))
	_countingLabel:setVisible(false)
	topNode:addChild(_countingLabel)
end

--[[
	@des 	:底部UI
	@param 	:
	@return :
--]]
function createBottomUI()
	--底部node
	local bottomNode = CCNode:create()
	bottomNode:setAnchorPoint(ccp(0.5,0))
	bottomNode:setContentSize(CCSizeMake(640,90))
	bottomNode:setPosition(ccp(g_winSize.width/2,0))
	bottomNode:setScale(g_fScaleX)
	_bgLayer:addChild(bottomNode)

	--黄色分割线
	local lineSprite = CCSprite:create("images/common/separator_bottom.png")
	lineSprite:setAnchorPoint(ccp(0.5,1))
	lineSprite:setPosition(ccp(bottomNode:getContentSize().width/2,bottomNode:getContentSize().height + 15))
	bottomNode:addChild(lineSprite)

	--底部菜单层
	local bottomMenu = CCMenu:create()
	bottomMenu:setPosition(ccp(0,0))
	bottomMenu:setAnchorPoint(ccp(0,0))
	bottomMenu:setTouchPriority(-550)
	bottomNode:addChild(bottomMenu)

	--活动描述按钮
	local describeMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200,73),GetLocalizeStringBy("zzh_1035"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	describeMenuItem:setAnchorPoint(ccp(0,0))
	describeMenuItem:setPosition(ccp(10,10))
	describeMenuItem:registerScriptTapHandler(describeCallBack)
	bottomMenu:addChild(describeMenuItem)

	--我的战报按钮
	local myReoprtMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200,73),GetLocalizeStringBy("zzh_1036"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	myReoprtMenuItem:setAnchorPoint(ccp(0.5,0))
	myReoprtMenuItem:setPosition(ccp(bottomNode:getContentSize().width/2,10))
	myReoprtMenuItem:registerScriptTapHandler(myReportCallBack)
	bottomMenu:addChild(myReoprtMenuItem)

	--战况回顾按钮
	local memoryMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200,73),GetLocalizeStringBy("zzh_1037"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	memoryMenuItem:setAnchorPoint(ccp(1,0))
	memoryMenuItem:setPosition(ccp(bottomNode:getContentSize().width - 10,10))
	memoryMenuItem:registerScriptTapHandler(memoryCallBack)
	bottomMenu:addChild(memoryMenuItem)
end

--[[
	@des 	:创建中部UI
	@param 	:
	@return :
--]]
function createMiddleUI()
	--此中有真意，欲辨已忘言
	local middleNodePosY = (g_winSize.height - 215*g_fScaleX - 90*g_fScaleX)/2 + 90*g_fScaleX
	--中部node
	_middleNode = CCNode:create()
	_middleNode:setContentSize(CCSizeMake(640,655))
	_middleNode:setAnchorPoint(ccp(0.5,0.5))
	_middleNode:setPosition(ccp(g_winSize.width/2,middleNodePosY))
	--缩放比例还是太小，在pad上超出，所以乘个系数
	_middleNode:setScale(MainScene.elementScale*0.92)
	_bgLayer:addChild(_middleNode)

	local lookZOder = 5

	--中部按钮层
	_middleNodeMenu = CCMenu:create()
	_middleNodeMenu:setAnchorPoint(ccp(0,0))
	_middleNodeMenu:setPosition(ccp(0,0))
	_middleNode:addChild(_middleNodeMenu,lookZOder)

	--鼓舞间隔
	local gapLength = (640-160)/3

	--第二层开始位置
	local secondBeginX = 80 + gapLength/2
	local secondGap = 640 - secondBeginX*2
	----------------------------------------------------------------------------------------------------------------------------------------------------------------
	--鼓舞按钮
	for i = 1,4 do
		--鼓舞按钮
		local cheerUpMenuItem = CCMenuItemImage:create("images/olympic/cheer_up/cheer_n.png","images/olympic/cheer_up/cheer_h.png")
		cheerUpMenuItem:setAnchorPoint(ccp(0.5,0))
		cheerUpMenuItem:setPosition(ccp(80 + gapLength*(i - 1),0))
		cheerUpMenuItem:registerScriptTapHandler(cheerUpCallBack)
		_middleNodeMenu:addChild(cheerUpMenuItem,1,i)

		--已鼓舞按钮
		local cheerOverSprite = CCSprite:create("images/olympic/cheer_up/cheer_over.png")
		cheerOverSprite:setAnchorPoint(ccp(0.5,0))
		cheerOverSprite:setPosition(ccp(80 + gapLength*(i - 1),0))
		cheerOverSprite:setVisible(false)
		_middleNode:addChild(cheerOverSprite,1,i)

		--灰色鼓舞图片
		local grayCheerUpSprite = BTGraySprite:create("images/olympic/cheer_up/cheer_n.png")
		grayCheerUpSprite:setAnchorPoint(ccp(0.5,0))
		grayCheerUpSprite:setPosition(ccp(80 + gapLength*(i - 1),0))
		grayCheerUpSprite:setVisible(false)
		_middleNode:addChild(grayCheerUpSprite,1,i + kGrayTag)

		--若当前位置没有人，则置为灰
		--若玩家有鼓舞的人，则初始化为灰，下面判断处理
		--若进入到半决赛及以后的比赛，则，初始化为灰，下面判断处理
		--若玩家已经报名，则不能助威，显示为灰
		if table.isEmpty(_finalFourInfo[i]) then
			cheerUpMenuItem:setVisible(false)
			grayCheerUpSprite:setVisible(true)
		end

		if OlympicData.getCheerUid() ~= 0 then
			cheerUpMenuItem:setVisible(false)
			grayCheerUpSprite:setVisible(false)
		end
		--若玩家助威的为这个骚年，则，显示已助威
		if (not table.isEmpty(_finalFourInfo[i])) and (tonumber(_finalFourInfo[i].uid) == OlympicData.getCheerUid()) then
			cheerUpMenuItem:setVisible(false)
			grayCheerUpSprite:setVisible(false)
			cheerOverSprite:setVisible(true)
		end
	end
	----------------------------------------------------------------------------------------------------------------------------------------------------------------
	--7个台子
	for i = 1,7 do
		------------------------------------------------------------------------------------------------------------------------
		--最底下4个
		if (i <= 4) and (i >= 1) then
			local beginPosY = 70
			--台子
			local fourStage = CCSprite:create("images/olympic/shan_tanzi.png")
			fourStage:setAnchorPoint(ccp(0.5,0))
			fourStage:setPosition(ccp(80 + gapLength*(i - 1),beginPosY))
			_middleNode:addChild(fourStage,2)
			-------------------------------------------------------------------------特效
			local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/zihuxi/zihuxi" ), -1,CCString:create(""))
			spellEffectSprite:setPosition(ccp(fourStage:getContentSize().width/2,50))
		    spellEffectSprite:setAnchorPoint(ccp(0.5, 0))
		    fourStage:addChild(spellEffectSprite,-1)

		    local animationEnd = function(actionName,xmlSprite)
		  --  		spellEffectSprite:retain()
				-- spellEffectSprite:autorelease()
		  --       spellEffectSprite:removeFromParentAndCleanup(true)
		    end

		    local animationFrameChanged = function(frameIndex,xmlSprite)
		    end

		    local delegate = BTAnimationEventDelegate:create()
		    delegate:registerLayerEndedHandler(animationEnd)
		    delegate:registerLayerChangedHandler(animationFrameChanged)
		    
		    spellEffectSprite:setDelegate(delegate)
			-------------------------------------------------------------------------特效结束
			--灰色转折点，第一个和第三个线
			local grayTurnSprite = CCSprite:create("images/olympic/line/downRightLine_gray.png")
			--金色转折点，第一个和第三个线
			local goldTurnSprite = CCSprite:create("images/olympic/line/downRightLine_light.png")
			if i == 3 or i == 1 then
				--灰线
				grayTurnSprite:setScaleY(-1)
				grayTurnSprite:setPosition(ccp(80 + gapLength*(i - 1) + grayTurnSprite:getContentSize().width/2,beginPosY + fourStage:getContentSize().height))
				--金线
				goldTurnSprite:setScaleY(-1)
				goldTurnSprite:setPosition(ccp(80 + gapLength*(i - 1) + goldTurnSprite:getContentSize().width/2,beginPosY + fourStage:getContentSize().height))

				--两条竖线，因为只有两条，所以放到1或3里面了
				--灰线
				local grayLineSprite = CCScale9Sprite:create("images/olympic/line/horizontalLine_gray.png")
				grayLineSprite:setRotation(90)
				grayLineSprite:setAnchorPoint(ccp(0.5,0))
				grayLineSprite:setPosition(ccp(80 + gapLength*(i - 1) + gapLength/2 - grayLineSprite:getContentSize().height/2,beginPosY + 30 + fourStage:getContentSize().height))

				--金线
				local goldLineSprite = CCScale9Sprite:create("images/olympic/line/horizontalLine_light.png")
				goldLineSprite:setRotation(90)
				goldLineSprite:setAnchorPoint(ccp(0.5,0))
				goldLineSprite:setPosition(ccp(80 + gapLength*(i - 1) + gapLength/2 - goldLineSprite:getContentSize().height/2,beginPosY + 30 + fourStage:getContentSize().height))

				--查看战报按钮
				local checkReportMenuItem = CCMenuItemImage:create("images/olympic/checkbutton/check_btn_h.png","images/olympic/checkbutton/check_btn_n.png")
				checkReportMenuItem:setAnchorPoint(ccp(0.5,0.5))
				checkReportMenuItem:setPosition(ccp(80 + gapLength*(i - 1) + gapLength/2,beginPosY + fourStage:getContentSize().height - 5))
				checkReportMenuItem:registerScriptTapHandler(checkReportCallBack)

				--灰色战报图标
				local grayReportSprite = BTGraySprite:create("images/olympic/checkbutton/check_btn_h.png")
				grayReportSprite:setAnchorPoint(ccp(0.5,0.5))
				grayReportSprite:setPosition(ccp(80 + gapLength*(i - 1) + gapLength/2,beginPosY + fourStage:getContentSize().height - 5))

				local vsSprite = CCSprite:create("images/arena/vs.png")
				vsSprite:setAnchorPoint(ccp(0.5,0.5))
				vsSprite:setPosition(ccp(80 + gapLength*(i - 1) + gapLength/2,140))
				vsSprite:setScale(0.7)
				_middleNode:addChild(vsSprite,5)

				if i == 1 then
					_middleNode:addChild(grayLineSprite,2,kGrayLineTag + 5)
					_middleNode:addChild(goldLineSprite,2,kGoldLineTag + 5)
					_middleNodeMenu:addChild(checkReportMenuItem,4,kReportTag + 1)
					_middleNode:addChild(grayReportSprite,5,kGrayReportTag + 1)
				else
					_middleNode:addChild(grayLineSprite,2,kGrayLineTag + 6)
					_middleNode:addChild(goldLineSprite,2,kGoldLineTag + 6)
					_middleNodeMenu:addChild(checkReportMenuItem,4,kReportTag + 2)
					_middleNode:addChild(grayReportSprite,5,kGrayReportTag + 2)
				end
			end

			--第二个和第四个线
			if i == 2 or i == 4 then
				--灰线
				grayTurnSprite:setScaleX(-1)
				grayTurnSprite:setScaleY(-1)
				grayTurnSprite:setPosition(ccp(80 + gapLength*(i - 1) - grayTurnSprite:getContentSize().width/2,beginPosY + fourStage:getContentSize().height))
				--金线
				goldTurnSprite:setScaleX(-1)
				goldTurnSprite:setScaleY(-1)
				goldTurnSprite:setPosition(ccp(80 + gapLength*(i - 1) - goldTurnSprite:getContentSize().width/2,beginPosY + fourStage:getContentSize().height))
			end
			--灰线
			grayTurnSprite:setAnchorPoint(ccp(0.5,0))
			_middleNode:addChild(grayTurnSprite,2,kGrayLineTag + i)

			--金线
			goldTurnSprite:setAnchorPoint(ccp(0.5,0))
			_middleNode:addChild(goldTurnSprite,2,kGoldLineTag + i)
		end
		------------------------------------------------------------------------------------------------------------------------
		--中间2个
		if (i <= 6) and (i >= 5) then
			local beginPosY = 285
 			local twoStage = CCSprite:create("images/olympic/shan_tanzi.png")
			twoStage:setAnchorPoint(ccp(0.5,0))
			twoStage:setPosition(ccp(secondBeginX + (i - 5)*secondGap,beginPosY))
			_middleNode:addChild(twoStage,2)

			-------------------------------------------------------------------------特效
			local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/zihuxi/zihuxi" ), -1,CCString:create(""))
			spellEffectSprite:setPosition(ccp(twoStage:getContentSize().width/2,50))
		    spellEffectSprite:setAnchorPoint(ccp(0.5, 0))
		    twoStage:addChild(spellEffectSprite,-1)

		    local animationEnd = function(actionName,xmlSprite)
		  --  		spellEffectSprite:retain()
				-- spellEffectSprite:autorelease()
		  --       spellEffectSprite:removeFromParentAndCleanup(true)
		    end

		    local animationFrameChanged = function(frameIndex,xmlSprite)
		    end

		    local delegate = BTAnimationEventDelegate:create()
		    delegate:registerLayerEndedHandler(animationEnd)
		    delegate:registerLayerChangedHandler(animationFrameChanged)
		    
		    spellEffectSprite:setDelegate(delegate)
			-------------------------------------------------------------------------特效结束
			
			--灰色转折线
			local grayTurnSprite = CCSprite:create("images/olympic/line/downRightLine_gray.png")
			--金色转折线
			local goldTurnSprite = CCSprite:create("images/olympic/line/downRightLine_light.png")
			if i == 5 then
				--灰线
				grayTurnSprite:setScaleY(-1)
				grayTurnSprite:setPosition(ccp(secondBeginX + (i - 5)*secondGap + grayTurnSprite:getContentSize().width/2,beginPosY + twoStage:getContentSize().height))
				--金线
				goldTurnSprite:setScaleY(-1)
				goldTurnSprite:setPosition(ccp(secondBeginX + (i - 5)*secondGap + goldTurnSprite:getContentSize().width/2,beginPosY + twoStage:getContentSize().height))

				--补足横线
				--灰线
				local addGrayLineSprite = CCSprite:create("images/olympic/line/horizontalLine_gray.png")
				addGrayLineSprite:setAnchorPoint(ccp(0,0.5))
				addGrayLineSprite:setPosition(ccp(secondBeginX + (i - 5)*secondGap + grayTurnSprite:getContentSize().width,beginPosY + twoStage:getContentSize().height - addGrayLineSprite:getContentSize().height/2))
				_middleNode:addChild(addGrayLineSprite,2,kGrayLineTag + i + 4)
				--金线
				local addGoldLineSprite = CCSprite:create("images/olympic/line/horizontalLine_light.png")
				addGoldLineSprite:setAnchorPoint(ccp(0,0.5))
				addGoldLineSprite:setPosition(ccp(secondBeginX + (i - 5)*secondGap + goldTurnSprite:getContentSize().width,beginPosY + twoStage:getContentSize().height - addGoldLineSprite:getContentSize().height/2))
				_middleNode:addChild(addGoldLineSprite,2,kGoldLineTag + i + 4)

				--一条竖线
				--灰线
				local championLineSprite = CCSprite:create("images/olympic/line/horizontalLine_gray.png")
				championLineSprite:setRotation(90)
				championLineSprite:setAnchorPoint(ccp(0.5,0))
				championLineSprite:setPosition(ccp(secondBeginX + (i - 5)*secondGap + secondGap/2 - championLineSprite:getContentSize().height/2,beginPosY + 30 + twoStage:getContentSize().height))
				_middleNode:addChild(championLineSprite,2,kGrayLineTag + i + 6)
				--金线
				local goldChampionLineSprite = CCSprite:create("images/olympic/line/horizontalLine_light.png")
				goldChampionLineSprite:setRotation(90)
				goldChampionLineSprite:setAnchorPoint(ccp(0.5,0))
				goldChampionLineSprite:setPosition(ccp(secondBeginX + (i - 5)*secondGap + secondGap/2 - goldChampionLineSprite:getContentSize().height/2,beginPosY + 30 + twoStage:getContentSize().height))
				_middleNode:addChild(goldChampionLineSprite,2,kGoldLineTag + i + 6)

				local vsSprite = CCSprite:create("images/arena/vs.png")
				vsSprite:setAnchorPoint(ccp(0.5,0.5))
				vsSprite:setPosition(ccp(secondBeginX + (i - 5)*secondGap + secondGap/2 - goldChampionLineSprite:getContentSize().height/2,355))
				_middleNode:addChild(vsSprite,5)

				--查看战报按钮
				local checkReportMenuItem = CCMenuItemImage:create("images/olympic/checkbutton/check_btn_h.png","images/olympic/checkbutton/check_btn_n.png")
				checkReportMenuItem:setAnchorPoint(ccp(0.5,0.5))
				checkReportMenuItem:setPosition(ccp(secondBeginX + (i - 5)*secondGap + secondGap/2,beginPosY + twoStage:getContentSize().height - 5))
				checkReportMenuItem:registerScriptTapHandler(checkReportCallBack)
				_middleNodeMenu:addChild(checkReportMenuItem,4,kReportTag + 3)

				--灰色战报图标
				local grayReportSprite = BTGraySprite:create("images/olympic/checkbutton/check_btn_h.png")
				grayReportSprite:setAnchorPoint(ccp(0.5,0.5))
				grayReportSprite:setPosition(ccp(secondBeginX + (i - 5)*secondGap + secondGap/2,beginPosY + twoStage:getContentSize().height - 5))
				_middleNode:addChild(grayReportSprite,5,kGrayReportTag + 3)
			end

			if i == 6 then
				--灰线
				grayTurnSprite:setScaleX(-1)
				grayTurnSprite:setScaleY(-1)
				grayTurnSprite:setPosition(ccp(secondBeginX + (i - 5)*secondGap - grayTurnSprite:getContentSize().width/2,beginPosY + twoStage:getContentSize().height))
				--金线
				goldTurnSprite:setScaleX(-1)
				goldTurnSprite:setScaleY(-1)
				goldTurnSprite:setPosition(ccp(secondBeginX + (i - 5)*secondGap - goldTurnSprite:getContentSize().width/2,beginPosY + twoStage:getContentSize().height))

				--补足横线
				--灰线
				local addGrayLineSprite = CCSprite:create("images/olympic/line/horizontalLine_gray.png")
				addGrayLineSprite:setAnchorPoint(ccp(1,0.5))
				addGrayLineSprite:setPosition(ccp(secondBeginX + (i - 5)*secondGap - grayTurnSprite:getContentSize().width,beginPosY + twoStage:getContentSize().height - addGrayLineSprite:getContentSize().height/2))
				_middleNode:addChild(addGrayLineSprite,2,kGrayLineTag + i + 4)
				--金线
				local addGoldLineSprite = CCSprite:create("images/olympic/line/horizontalLine_light.png")
				addGoldLineSprite:setAnchorPoint(ccp(1,0.5))
				addGoldLineSprite:setPosition(ccp(secondBeginX + (i - 5)*secondGap - goldTurnSprite:getContentSize().width,beginPosY + twoStage:getContentSize().height - addGoldLineSprite:getContentSize().height/2))
				_middleNode:addChild(addGoldLineSprite,2,kGoldLineTag + i + 4)
			end
			--灰线
			grayTurnSprite:setAnchorPoint(ccp(0.5,0))
			_middleNode:addChild(grayTurnSprite,2,kGrayLineTag + i + 2)
			--金线
			goldTurnSprite:setAnchorPoint(ccp(0.5,0))
			_middleNode:addChild(goldTurnSprite,2,kGoldLineTag + i + 2)
		end
		------------------------------------------------------------------------------------------------------------------------
		--冠军的位置
		if i == 7 then
			local kingStage = CCSprite:create("images/olympic/kingChair.png")
			kingStage:setAnchorPoint(ccp(0.5,0))
			kingStage:setPosition(ccp(secondBeginX + secondGap/2,500))
			_middleNode:addChild(kingStage,2)

			local kingLight = CCSprite:create("images/olympic/kingLight.png")
			kingLight:setAnchorPoint(ccp(0.5,0))
			kingLight:setPosition(ccp(kingStage:getContentSize().width/2,70))
			kingStage:addChild(kingLight)

			-------------------------------------------------------------------------特效
			local spellEffectSprite_1 = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/guangjun/guangjuntai" ), -1,CCString:create(""))
			spellEffectSprite_1:setPosition(ccp(secondBeginX + secondGap/2,575))
		    spellEffectSprite_1:setAnchorPoint(ccp(0.5, 0))
		    spellEffectSprite_1:setFPS_interval(1/20)
		    _middleNode:addChild(spellEffectSprite_1,10)

		    local animationEnd_1 = function(actionName,xmlSprite)
		  --  		spellEffectSprite:retain()
				-- spellEffectSprite:autorelease()
		  --       spellEffectSprite:removeFromParentAndCleanup(true)
		    end

		    local animationFrameChanged_1 = function(frameIndex,xmlSprite)
		    end

		    local delegate_1 = BTAnimationEventDelegate:create()
		    delegate_1:registerLayerEndedHandler(animationEnd_1)
		    delegate_1:registerLayerChangedHandler(animationFrameChanged_1)
		    
		    spellEffectSprite_1:setDelegate(delegate_1)
			-------------------------------------------------------------------------特效结束

			-------------------------------------------------------------------------特效
			local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/hongguang/hongguang" ), -1,CCString:create(""))
			spellEffectSprite:setPosition(ccp(kingLight:getContentSize().width/2,20))
		    spellEffectSprite:setAnchorPoint(ccp(0.5, 0))
		    kingLight:addChild(spellEffectSprite,9999)

		    local animationEnd = function(actionName,xmlSprite)
		  --  		spellEffectSprite:retain()
				-- spellEffectSprite:autorelease()
		  --       spellEffectSprite:removeFromParentAndCleanup(true)
		    end

		    local animationFrameChanged = function(frameIndex,xmlSprite)
		    end

		    local delegate = BTAnimationEventDelegate:create()
		    delegate:registerLayerEndedHandler(animationEnd)
		    delegate:registerLayerChangedHandler(animationFrameChanged)
		    
		    spellEffectSprite:setDelegate(delegate)
			-------------------------------------------------------------------------特效结束
		end
	end
end

--[[
	@des 	:创建4皇
	@param 	:
	@return :
--]]
function createKingFour()
	local gapLength = (640-160)/3
	local bodyPosY = 105
	--遍历四强信息
	for i = 1,#_finalFourInfo do
		if not table.isEmpty(_finalFourInfo[i]) then
			local playerInfo = _finalFourInfo[i]
			--playerInfo 结构
		    --     sign_up_index:int    报名位置
		    --     olympic_index:int    比赛位置
		    --     final_rank:int        排名
		    --     uid:int
		    --     uname:int
		    --     dress:array
		    --     htid:int
		    --     level:int
            --     fight_force:int
            --     be_cheer_num:int
            bodyPosY = 105
			--玩家性别
			local playerGender = HeroModel.getSex(playerInfo.htid)
			local imagePath
			if not table.isEmpty(playerInfo.dress) then
				imagePath = HeroUtil.getHeroBodyImgByHTID(playerInfo.htid,playerInfo.dress["1"],playerGender)
				bodyPosY = bodyPosY - 0.35*HeroUtil.getHeroBodySpriteOffsetByHTID(playerInfo.htid, playerInfo.dress["1"])
			else
				imagePath = HeroUtil.getHeroBodyImgByHTID(playerInfo.htid)
				bodyPosY = bodyPosY - 0.35*HeroUtil.getHeroBodySpriteOffsetByHTID(playerInfo.htid)
			end
			--形象置灰
			local playerBodySprite
			if _haveFinalTwo and (tonumber(playerInfo.final_rank) == 4) then
				playerBodySprite = BTGraySprite:create(tostring(imagePath))
			else
				playerBodySprite = CCSprite:create(tostring(imagePath))
			end

			playerBodySprite:setAnchorPoint(ccp(0.5,0))
			playerBodySprite:setPosition(ccp(80 + gapLength*(i - 1),bodyPosY))
			playerBodySprite:setScale(0.35)
			_middleNode:addChild(playerBodySprite,3,kBodyTag + i)

			--玩家姓名label
			local playerNameLabel = CCRenderLabel:create(playerInfo.uname,g_sFontPangWa,18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			if tonumber(playerInfo.uid) == tonumber(UserModel.getUserUid()) then
				playerNameLabel:setColor(ccc3(0xe4,0x00,0xff))
			end
			playerNameLabel:setAnchorPoint(ccp(0.5,0))
			playerNameLabel:setPosition(ccp(80 + gapLength*(i - 1),bodyPosY - 25))
			_middleNode:addChild(playerNameLabel,3)

			--获得助威数
			local gainCheerUpLabel = CCRenderLabel:create(GetLocalizeStringBy("zzh_1039"),g_sFontName,18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			gainCheerUpLabel:setColor(ccc3(0xff,0xf6,0x00))
			gainCheerUpLabel:setAnchorPoint(ccp(0,0.5))

			local cheerUpNumLabel
			if playerInfo.be_cheer_num ~= nil then
				cheerUpNumLabel = CCRenderLabel:create(tostring(playerInfo.be_cheer_num),g_sFontName,18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			else
				cheerUpNumLabel = CCRenderLabel:create("0",g_sFontName,18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			end
			cheerUpNumLabel:setColor(ccc3(0x00,0xff,0x18))
			cheerUpNumLabel:setAnchorPoint(ccp(0,0.5))

			local underNode = CCNode:create()
			underNode:setContentSize(CCSizeMake(gainCheerUpLabel:getContentSize().width + cheerUpNumLabel:getContentSize().width,gainCheerUpLabel:getContentSize().height))
			underNode:setAnchorPoint(ccp(0.5,1))
			underNode:setPosition(ccp(80 + gapLength*(i - 1),bodyPosY - 25))
			print("创建助威nodetag",kCheerNodeTag + i)
			_middleNode:addChild(underNode,3,kCheerNodeTag + i)

			gainCheerUpLabel:setPosition(ccp(0,underNode:getContentSize().height/2))
			cheerUpNumLabel:setPosition(ccp(gainCheerUpLabel:getContentSize().width,underNode:getContentSize().height/2))

			underNode:addChild(gainCheerUpLabel,1,2)
			print("助威描述tag:2")
			print("助威数目tag:1")
			underNode:addChild(cheerUpNumLabel,1,1)

			local lostSprite
			print("是否有两强",_haveFinalTwo)
			if _haveFinalTwo then
				lostSprite = CCSprite:create("images/olympic/lost.png")
				lostSprite:setAnchorPoint(ccp(1,1))
				lostSprite:setPosition(ccp(playerBodySprite:getContentSize().width/2 - 10,450))
				lostSprite:setScale(1/0.35)
				playerBodySprite:addChild(lostSprite)
			end

			print("id的i",i)
			print_t(playerInfo)

			if (tonumber(playerInfo.final_rank) == 2) or (tonumber(playerInfo.final_rank) == 1) then
				lostSprite:setVisible(false)
				
				local winSprite = CCSprite:create("images/olympic/win.png")
				winSprite:setAnchorPoint(ccp(1,1))
				winSprite:setPosition(ccp(playerBodySprite:getContentSize().width/2 - 10,450))
				winSprite:setScale(1/0.35)
				playerBodySprite:addChild(winSprite)

				local grayLine = _middleNode:getChildByTag(kGrayLineTag + i)
				grayLine:setVisible(false)
				local goldLine = _middleNode:getChildByTag(kGoldLineTag + i)
				goldLine:setVisible(true)
			end
		end
	end
end

--[[
	@des 	:创建2皇
	@param 	:
	@return :
--]]
function createKingTwo()
	local secondBeginX = 80 + (640-160)/6
	local secondGap = 640 - secondBeginX*2
	local bodyPosY = 320
	--遍历两强
	for i = 1,#_finalTwoInfo do
		bodyPosY = 335
		if not table.isEmpty(_finalTwoInfo[i]) then
			local playerInfo = _finalTwoInfo[i]

			local playerGender = HeroModel.getSex(playerInfo.htid)
			local imagePath
			if not table.isEmpty(playerInfo.dress) then
				imagePath = HeroUtil.getHeroBodyImgByHTID(playerInfo.htid,playerInfo.dress["1"],playerGender)
				bodyPosY = bodyPosY - 0.35*HeroUtil.getHeroBodySpriteOffsetByHTID(playerInfo.htid, playerInfo.dress["1"])
			else
				bodyPosY = bodyPosY - 0.35*HeroUtil.getHeroBodySpriteOffsetByHTID(playerInfo.htid)
				imagePath = HeroUtil.getHeroBodyImgByHTID(playerInfo.htid)
			end

			local playerBodySprite
			if _haveFinalOne and (tonumber(playerInfo.final_rank) == 2) then
				playerBodySprite = BTGraySprite:create(tostring(imagePath))
			else
				playerBodySprite = CCSprite:create(tostring(imagePath))
			end

			playerBodySprite:setAnchorPoint(ccp(0.5,0))
			playerBodySprite:setPosition(ccp(secondBeginX + (i - 1)*secondGap,bodyPosY))
			playerBodySprite:setScale(0.35)
			_middleNode:addChild(playerBodySprite,3,kBodyTag + 4 + i)

			local playerNameLabel = CCRenderLabel:create(playerInfo.uname,g_sFontPangWa,18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			if tonumber(playerInfo.uid) == tonumber(UserModel.getUserUid()) then
				playerNameLabel:setColor(ccc3(0xe4,0x00,0xff))
			end
			playerNameLabel:setAnchorPoint(ccp(0.5,0))
			playerNameLabel:setPosition(ccp(secondBeginX + (i - 1)*secondGap,bodyPosY - 25))
			_middleNode:addChild(playerNameLabel,3)

			--获得助威数
			local gainCheerUpLabel = CCRenderLabel:create(GetLocalizeStringBy("zzh_1039"),g_sFontName,18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			gainCheerUpLabel:setColor(ccc3(0xff,0xf6,0x00))

			local cheerUpNumLabel
			if playerInfo.be_cheer_num ~= nil then
				cheerUpNumLabel = CCRenderLabel:create(tostring(playerInfo.be_cheer_num),g_sFontName,18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			else
				cheerUpNumLabel = CCRenderLabel:create("0",g_sFontName,18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			end
			cheerUpNumLabel:setColor(ccc3(0x00,0xff,0x18))

			--阳仔说可以用BaseUI了
			local cheerUpNode = BaseUI.createHorizontalNode({gainCheerUpLabel,cheerUpNumLabel})
			cheerUpNode:setAnchorPoint(ccp(0.5,1))
			cheerUpNode:setPosition(ccp(secondBeginX + (i - 1)*secondGap,bodyPosY - 25))
			_middleNode:addChild(cheerUpNode,3)

			local grayLine = _middleNode:getChildByTag(kGrayLineTag + i + 4)
			grayLine:setVisible(false)
			local goldLine = _middleNode:getChildByTag(kGoldLineTag + i + 4)
			goldLine:setVisible(true)

			local lostSprite
			if _haveFinalOne then
				lostSprite = CCSprite:create("images/olympic/lost.png")
				lostSprite:setAnchorPoint(ccp(1,1))
				lostSprite:setPosition(ccp(playerBodySprite:getContentSize().width/2 - 10,450))
				lostSprite:setScale(1/0.35)
				playerBodySprite:addChild(lostSprite)
			end

			if tonumber(playerInfo.final_rank) == 1 then
				lostSprite:setVisible(false)

				local winSprite = CCSprite:create("images/olympic/win.png")
				winSprite:setAnchorPoint(ccp(1,1))
				winSprite:setPosition(ccp(playerBodySprite:getContentSize().width/2 - 10,450))
				winSprite:setScale(1/0.35)
				playerBodySprite:addChild(winSprite)

				local grayLine_1 = _middleNode:getChildByTag(kGrayLineTag + i + 6)
				local grayLine_2 = _middleNode:getChildByTag(kGrayLineTag + i + 8)
				grayLine_1:setVisible(false)
				grayLine_2:setVisible(false)
				local goldLine_1 = _middleNode:getChildByTag(kGoldLineTag + i + 6)
				local goldLine_2 = _middleNode:getChildByTag(kGoldLineTag + i + 8)
				goldLine_1:setVisible(true)
				goldLine_2:setVisible(true)
			end

			if i == 1 then
				if (not table.isEmpty(_finalFourInfo[1])) and (not table.isEmpty(_finalFourInfo[2])) then
					local reportMenuItem = _middleNodeMenu:getChildByTag(kReportTag + i)
					reportMenuItem:setVisible(true)
					local grayReportSprite = _middleNode:getChildByTag(kGrayReportTag + i)
					grayReportSprite:setVisible(false)
					print("加入1战报前")
					print_t(_battleReportInfo)
					print("是否为空",OlympicData.getReportIdByOlympicPos(_finalFourInfo[1].olympic_index,_finalFourInfo[2].olympic_index))
					_battleReportInfo[1] = OlympicData.getReportIdByOlympicPos(_finalFourInfo[1].olympic_index,_finalFourInfo[2].olympic_index)
					print("加入1战报")
					print_t(_battleReportInfo)
				end
			end

			if i == 2 then
				if (not table.isEmpty(_finalFourInfo[3])) and (not table.isEmpty(_finalFourInfo[4])) then
					local reportMenuItem = _middleNodeMenu:getChildByTag(kReportTag + i)
					reportMenuItem:setVisible(true)
					local grayReportSprite = _middleNode:getChildByTag(kGrayReportTag + i)
					grayReportSprite:setVisible(false)
					_battleReportInfo[2] = OlympicData.getReportIdByOlympicPos(_finalFourInfo[3].olympic_index,_finalFourInfo[4].olympic_index)
				end
			end
		end
	end
end

--[[
	@des 	:创建king
	@param 	:
	@return :
--]]
function createKing()
	local secondBeginX = 80 + (640-160)/6
	local secondGap = 640 - secondBeginX*2
	local bodyPosY = 560
	--冠军
	if not table.isEmpty(_finalOneInfo[1]) then
		local playerInfo = _finalOneInfo[1]

		local playerGender = HeroModel.getSex(playerInfo.htid)
		local imagePath
		if not table.isEmpty(playerInfo.dress) then
			imagePath = HeroUtil.getHeroBodyImgByHTID(playerInfo.htid,playerInfo.dress["1"],playerGender)
			bodyPosY = bodyPosY - 0.35*HeroUtil.getHeroBodySpriteOffsetByHTID(playerInfo.htid, playerInfo.dress["1"])
		else
			imagePath = HeroUtil.getHeroBodyImgByHTID(playerInfo.htid)
			bodyPosY = bodyPosY - 0.35*HeroUtil.getHeroBodySpriteOffsetByHTID(playerInfo.htid)
		end
		local playerBodySprite = CCSprite:create(tostring(imagePath))
		playerBodySprite:setAnchorPoint(ccp(0.5,0))
		playerBodySprite:setPosition(ccp(secondBeginX + secondGap/2,bodyPosY))
		playerBodySprite:setScale(0.35)
		_middleNode:addChild(playerBodySprite,3)

		local playerNameLabel = CCRenderLabel:create(playerInfo.uname,g_sFontPangWa,18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		if tonumber(playerInfo.uid) == tonumber(UserModel.getUserUid()) then
			playerNameLabel:setColor(ccc3(0xe4,0x00,0xff))
		end
		playerNameLabel:setAnchorPoint(ccp(0.5,0))
		playerNameLabel:setPosition(ccp(secondBeginX + secondGap/2,bodyPosY - 25))
		_middleNode:addChild(playerNameLabel,20)

		--获得助威数
		local gainCheerUpLabel = CCRenderLabel:create(GetLocalizeStringBy("zzh_1039"),g_sFontName,18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		gainCheerUpLabel:setColor(ccc3(0xff,0xf6,0x00))

		local cheerUpNumLabel
		if playerInfo.be_cheer_num ~= nil then
			cheerUpNumLabel = CCRenderLabel:create(tostring(playerInfo.be_cheer_num),g_sFontName,18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		else
			cheerUpNumLabel = CCRenderLabel:create("0",g_sFontName,18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		end
		cheerUpNumLabel:setColor(ccc3(0x00,0xff,0x18))

		--阳仔说可以用BaseUI了
		local cheerUpNode = BaseUI.createHorizontalNode({gainCheerUpLabel,cheerUpNumLabel})
		cheerUpNode:setAnchorPoint(ccp(0.5,1))
		cheerUpNode:setPosition(ccp(secondBeginX + secondGap/2,bodyPosY - 25))
		_middleNode:addChild(cheerUpNode,20)

		local grayLine = _middleNode:getChildByTag(kGrayLineTag + 11)
		grayLine:setVisible(false)
		local goldLine = _middleNode:getChildByTag(kGoldLineTag + 11)
		goldLine:setVisible(true)

		if (not table.isEmpty(_finalTwoInfo[1])) and (not table.isEmpty(_finalTwoInfo[2])) then
			local reportMenuItem = _middleNodeMenu:getChildByTag(kReportTag + 3)
			reportMenuItem:setVisible(true)
			local grayReportSprite = _middleNode:getChildByTag(kGrayReportTag + 3)
			grayReportSprite:setVisible(false)
			_battleReportInfo[3] = OlympicData.getReportIdByOlympicPos(_finalTwoInfo[1].olympic_index,_finalTwoInfo[2].olympic_index)
		end

		local crownSprite = CCSprite:create("images/olympic/king_hat.png")
		crownSprite:setAnchorPoint(ccp(0.5,0))
		crownSprite:setPosition(ccp(playerBodySprite:getContentSize().width/2,285))
		crownSprite:setScale(1/0.35)
		playerBodySprite:addChild(crownSprite)

		-- local reportMenuItem = _middleNodeMenu:getChildByTag(kReportTag + 3)
		-- reportMenuItem:setVisible(true)
		-- local grayReportSprite = _middleNode:getChildByTag(kGrayReportTag + 3)
		-- grayReportSprite:setVisible(false)
	end
end

----------------------------------------入口函数----------------------------------------
--[[
	@des 	:入口函数，用于场景切换
	@param 	:
	@return :
--]]
function show()
    local layer = createLayer()
    MainScene.changeLayer(layer, "Olympic4Layer")
end

--[[
	@des 	:创建场景
	@param 	:
	@return :创建好的layer
--]]
function createLayer()
	init()

	_bgLayer = CCLayer:create()
	--菜单栏，信息提示框，主角信息都不显示
	MainScene.setMainSceneViewsVisible(false, false, false)
	_bgLayer:setContentSize(CCSizeMake(g_winSize.width,g_winSize.height))

	local bgSprite = CCSprite:create("images/olympic/playoff_bg.jpg")
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setPosition(ccp(g_winSize.width/2,g_winSize.height/2))
	bgSprite:setScale(MainScene.bgScale)
	_bgLayer:addChild(bgSprite)

	--四强信息，两强信息，冠军信息
	_finalFourInfo,_finalTwoInfo,_finalOneInfo,_haveFinalTwo,_haveFinalOne = OlympicData.getFinalFourInfo()
	print("四强信息")
	print_t(_finalFourInfo)

	print("两强信息")
	print_t(_finalTwoInfo)

	print("冠军信息")
	print_t(_finalOneInfo)

	--创建顶部UI
	createTopUI()
	--创建底部UI
	createBottomUI()
	--创建中部UI
	createMiddleUI()
	
	--初始化线的状态
	initItemState()
	
	--创建4强人物
	createKingFour()
	--创建2强
	createKingTwo()
	--创建冠军
	createKing()

	--注册推送，有战报就推送
	OlympicService.registerBattleRecordPush(pushReportCallBack)

	--注册推送，阶段改变推送
	OlympicService.regisgerStagechangePush(pushStageCallBack)

	--阳仔叫我抄他的 - -！
	schedule(_bgLayer, updateTimeFunc, 1)

	--助威推送
	OlympicService.re_olympic_refreshCheerUp(refreshCheerUpNum)

	return _bgLayer
end

----------------------------------------刷新函数----------------------------------------
--[[
	@des 	:推送后刷新助威数目
	@param 	:玩家uid
	@return :
--]]
function refreshCheerUpNum(p_uid)
	local playerIndex = OlympicData.getPlayerIndex(p_uid)
	print("玩家index",playerIndex)
	print("ccnode下标",kCheerNodeTag + math.floor(playerIndex/8) + 1)
	local curNode =  tolua.cast(_middleNode:getChildByTag(kCheerNodeTag + math.floor(playerIndex/8) + 1), "CCNode") 
	local curLabel = tolua.cast(curNode:getChildByTag(1), "CCRenderLabel")
	curLabel:setString(tostring(OlympicData.getPlayerCheerNum(p_uid)))
end

--阳仔叫我抄他的 - -！
function getTimeDes( p_timeInterval )
	if(p_timeInterval <= 0) then
		return GetLocalizeStringBy("zzh_1052")
	end

	local hour = math.floor(p_timeInterval/3600)
	local min  = math.floor((p_timeInterval - hour*3600)/60)
	local sec  = p_timeInterval - hour*3600 - 60*min
	return string.format("%02d",hour) .. "  :  " .. string.format("%02d",min) .. "  :  ".. string.format("%02d",sec)
end

--阳仔叫我抄他的 - -！
function updateTimeFunc()
	if OlympicData.getStage() == 8 then
		_gameOverLabel:setVisible(true)
		_desTimeNode:setVisible(false)
		_countingLabel:setVisible(false)
	else
		_nowStageEndTime = OlympicData.getStageNowEndTime() - BTUtil:getSvrTimeInterval()
		if(_nowStageEndTime <=0) then
			_nowStageEndTime = 0
			_countingLabel:setVisible(true)
			_desTimeNode:setVisible(false)
		elseif(_timeString) then
			_desTimeNode:setVisible(true)
			_countingLabel:setVisible(false)
			_timeString:setString(getTimeDes(_nowStageEndTime))
		end
	end
end