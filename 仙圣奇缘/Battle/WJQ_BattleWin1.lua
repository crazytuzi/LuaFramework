--------------------------------------------------------------------------------------
-- 文件名:	WJQ_EquipWnd.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	王家麒
-- 日  期:	2014-04-08 4:37
-- 版  本:	1.0
-- 描  述:	副本胜利的结算动画
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------

Game_BatWin1 = class("Game_BatWin1")
Game_BatWin1.__index = Game_BatWin1

local tbRewardInfo = nil
local tbRewardResource = nil
local tbRewardItems = nil
local tbCardSourceLevel = nil

local tbDropItemMode = {}
local tbDropItemTime = {}


local function destroy()
	for key,value in pairs(tbDropItemTime) do
		g_Timer:destroyTimerByID(value)
	end
	tbDropItemMode = {}
	tbDropItemTime = {}		
end

local function onClick_DropItem(pSender, nIndex)
	local CSV_DropItem = tbRewardItems[nIndex]
	if not CSV_DropItem then return end
	g_ShowDropItemTip(CSV_DropItem)
end

local nItemFlag = 0
local function onUpdateListView_DropItem(Panel_DropItem, nIndex)
	Panel_DropItem:setName("Panel_DropItem"..nIndex)
	Panel_DropItem:removeAllChildren()
	local CSV_DropItem = tbRewardItems[nIndex]
	local itemModel = g_CloneDropItemModel(CSV_DropItem)
	itemModel:setName("itemModel")
	itemModel:setScale(0.8)
	-- itemModel:setVisible(false)
	itemModel:setPosition(ccp(55,55))
	Panel_DropItem:addChild(itemModel)
	g_SetBtnWithEvent(itemModel, nIndex, onClick_DropItem, true)

end

function Game_BatWin1:runBattleMemberExpJumpAction(Image_BattleMember, nIndex)
	local Image_ExpValue = tolua.cast(Image_BattleMember:getChildByName("Image_ExpValue"), "ImageView")
	local Label_ExpValue = tolua.cast(Image_ExpValue:getChildByName("Label_ExpValue"), "Label")
	self.tbExpTimerId[nIndex] = g_CreatePropDynamic(Label_ExpValue, 0.75, 0, tbRewardResource.nTeamMemberExp, "+%d", g_getColor(ccs.COLOR.LIME_GREEN), g_getColor(ccs.COLOR.WHITE))
end

function Game_BatWin1:runBattleMemberForeverAction(Image_BattleMember)
	local Label_LevelSource = tolua.cast(Image_BattleMember:getChildByName("Label_LevelSource"), "Label")
	local Label_LevelTarget = tolua.cast(Image_BattleMember:getChildByName("Label_LevelTarget"), "Label")
	
	local arrAct_LevelSource = CCArray:create()
	local actionFadeTo_LevelSource1 = CCFadeTo:create(0.8, 255)
	local actionFadeTo_LevelSource2 = CCFadeTo:create(0.8, 0)
	arrAct_LevelSource:addObject(actionFadeTo_LevelSource1)
	arrAct_LevelSource:addObject(CCDelayTime:create(0.6))
	arrAct_LevelSource:addObject(actionFadeTo_LevelSource2)	
	local function fadeOutLevelTarget()
		local arrAct_LevelTarget = CCArray:create()
		local actionFadeTo_LevelTarget1 = CCFadeTo:create(0.8, 255)
		local actionFadeTo_LevelTarget2 = CCFadeTo:create(0.8, 0)
		arrAct_LevelTarget:addObject(actionFadeTo_LevelTarget1)
		arrAct_LevelTarget:addObject(CCDelayTime:create(0.6))
		arrAct_LevelTarget:addObject(actionFadeTo_LevelTarget2)	
		local action_LevelTarget = CCSequence:create(arrAct_LevelTarget)
		Label_LevelTarget:runAction(action_LevelTarget)
	end
	arrAct_LevelSource:addObject(CCCallFuncN:create(fadeOutLevelTarget))
	arrAct_LevelSource:addObject(CCDelayTime:create(2.2))
	local action_LevelSource = CCSequence:create(arrAct_LevelSource)
	local actionForever_LevelSource = CCRepeatForever:create(action_LevelSource)
	Label_LevelSource:runAction(actionForever_LevelSource)
	
	local Image_LevelUpTip = tolua.cast(Image_BattleMember:getChildByName("Image_LevelUpTip"), "ImageView")
	if Image_LevelUpTip:isVisible() then
		g_CreateUpAndDownAnimation(Image_LevelUpTip, nil, 8)
	end
end

function Game_BatWin1:showReturnAndAgainBtn()
	local Image_BatResultPNL = tolua.cast(self.rootWidget:getChildByName("Image_BatResultPNL"), "ImageView")
	
	local Button_Again = tolua.cast(Image_BatResultPNL:getChildByName("Button_Again"), "Button") 
	local arrAct_Again = CCArray:create()
	arrAct_Again:addObject(CCDelayTime:create(0.12))
	local function showButton_Again()
		Button_Again:setVisible(true)
		Button_Again:setTouchEnabled(true)
	end
	arrAct_Again:addObject(CCCallFuncN:create(showButton_Again))
	local actionSequence_Again = CCSequence:create(arrAct_Again)
	Button_Again:runAction(actionSequence_Again)
	
	local Button_Return = tolua.cast(Image_BatResultPNL:getChildByName("Button_Return"), "Button") 
	local arrAct_Return = CCArray:create()
	arrAct_Return:addObject(CCDelayTime:create(0.3))
	local function showButton_Return()
		Button_Return:setVisible(true)
		Button_Return:setTouchEnabled(true)
		self.rootWidget:setTouchEnabled(true)
	end
	arrAct_Return:addObject(CCCallFuncN:create(showButton_Return))
	local actionSequence_Return = CCSequence:create(arrAct_Return)
	Button_Return:runAction(actionSequence_Return)
end

function Game_BatWin1:runDropItemSequenceAction()
	self.tbExpTimerId = {}
	local nBattleCardListCount = self.ListView_Member:getChildrenCount()
	local nStartIndex = self.ListView_Member:getFirstChildIndex()
	local nEndIndex = nStartIndex + nBattleCardListCount
	if nBattleCardListCount > 0 then
		for nIndex = nStartIndex, nEndIndex do
			local Panel_BattleMember = tolua.cast(self.ListView_Member:getChildByName("Panel_BattleMember"..nIndex), "Layout")
			if Panel_BattleMember then
				local Image_BattleMember = tolua.cast(Panel_BattleMember:getChildByName("Image_BattleMember"..nIndex), "ImageView")
				self:runBattleMemberExpJumpAction(Image_BattleMember, nIndex)
				self:runBattleMemberForeverAction(Image_BattleMember)
			end
		end
	end
	
	local nChildCount = self.ListView_DropItem:getChildrenCount()
	if nChildCount > 0 then
		local nStartIndex = self.ListView_DropItem:getFirstChildIndex()
		local nEndIndex = nStartIndex + nChildCount
		for nIndex = nStartIndex, nEndIndex do
			local Panel_DropItem = tolua.cast(self.ListView_DropItem:getChildByName("Panel_DropItem"..nIndex), "Layout")
			if Panel_DropItem then
				-- local itemModel = tolua.cast(Panel_DropItem:getChildByName("itemModel"), "ImageView")
				local arrAct = CCArray:create()
				arrAct:addObject(CCDelayTime:create((nIndex-1)*0.12))
				local function showBattleMember()
					local itemModel = tolua.cast(Panel_DropItem:getChildByName("itemModel"), "ImageView")
					itemModel:setVisible(true)
					if nIndex == nChildCount then
						self:showReturnAndAgainBtn()
					end
				end
				arrAct:addObject(CCCallFuncN:create(showBattleMember))
				local actionSequence = CCSequence:create(arrAct)
				Panel_DropItem:runAction(actionSequence)
			end
		end
	else
		self:showReturnAndAgainBtn()
	end
end

function Game_BatWin1:setListView_DropItem()
	local nItemsCount = GetTableLen(tbRewardItems)
	self.ListView_DropItem:updateItems(nItemsCount)
	
	for nIndex = 1, nItemsCount do
		local Panel_DropItem = tolua.cast(self.ListView_DropItem:getChildByName("Panel_DropItem"..nIndex), "Layout")
		if Panel_DropItem then
			local itemModel = tolua.cast(Panel_DropItem:getChildByName("itemModel"), "ImageView")
			itemModel:setVisible(false)
		end
	end
end

function Game_BatWin1:runBattleMemberSequenceAction()
	local nBattleCardListCount = g_Hero:getBattleCardListCount()
	for nIndex = 1, nBattleCardListCount do
		local Panel_BattleMember = tolua.cast(self.ListView_Member:getChildByName("Panel_BattleMember"..nIndex), "Layout")
		local arrAct = CCArray:create()
		arrAct:addObject(CCDelayTime:create((nIndex-1)*0.12))
		local function showBattleMember()
			Panel_BattleMember:setVisible(true)
			if nIndex == nBattleCardListCount then
				self:runDropItemSequenceAction()
			end
		end
		arrAct:addObject(CCCallFuncN:create(showBattleMember))
		local actionSequence = CCSequence:create(arrAct)
		Panel_BattleMember:runAction(actionSequence)
	end
end

local function setImage_BattleMember(Image_BattleMember, tbCard)
	local Image_Frame = tolua.cast(Image_BattleMember:getChildByName("Image_Frame"), "ImageView")
	Image_Frame:loadTexture(getCardFrameByEvoluteLev(tbCard:getEvoluteLevel()))
	local Image_Icon = tolua.cast(Image_BattleMember:getChildByName("Image_Icon"), "ImageView")
	Image_Icon:loadTexture(getIconImg(tbCard:getCsvBase().SpineAnimation))
	
	local nStarLevel = tbCard:getStarLevel()
	local Image_StarLevel = tolua.cast(Image_BattleMember:getChildByName("Image_StarLevel"), "ImageView")
	Image_StarLevel:loadTexture(getIconStarLev(tbCard:getStarLevel()))
	if nStarLevel == 5 then
		Image_StarLevel:setScale(1.0)
	elseif nStarLevel == 6 then
		Image_StarLevel:setScale(0.9)
	elseif nStarLevel == 7 then
		Image_StarLevel:setScale(0.8)
	end
	
	local Image_ExpValue = tolua.cast(Image_BattleMember:getChildByName("Image_ExpValue"), "ImageView")
	local Label_ExpValue = tolua.cast(Image_ExpValue:getChildByName("Label_ExpValue"), "Label")
	Label_ExpValue:setText("+0")
	
	local Image_ExpPercent = tolua.cast(Image_BattleMember:getChildByName("Image_ExpPercent"), "ImageView")
	local ProgressBar_ExpPercent = tolua.cast(Image_ExpPercent:getChildByName("ProgressBar_ExpPercent"), "LoadingBar")
	ProgressBar_ExpPercent:setPercent(tbCard:getNewExpPrecentByAddExp(tbRewardResource.nTeamMemberExp))
	
	local nLevelSource = tbCard:getLevel()
	local Label_LevelSource = tolua.cast(Image_BattleMember:getChildByName("Label_LevelSource"), "Label")
	Label_LevelSource:setText(nLevelSource)
	Label_LevelSource:setOpacity(0)
	
	local nLevelTarget = tbCard:getNewLvByAddExp(tbRewardResource.nTeamMemberExp)
	local Label_LevelTarget = tolua.cast(Image_BattleMember:getChildByName("Label_LevelTarget"), "Label")
	Label_LevelTarget:setText(nLevelTarget)
	Label_LevelTarget:setOpacity(0)
	
	local Image_LevelUpTip = tolua.cast(Image_BattleMember:getChildByName("Image_LevelUpTip"), "ImageView")
	if nLevelTarget > nLevelSource then
		Image_LevelUpTip:setVisible(true)
	else
		Image_LevelUpTip:setVisible(false)
	end
	Image_BattleMember:loadTexture(getCardBackByEvoluteLev(tbCard:getEvoluteLevel()))
end

function Game_BatWin1:onUpdateListView_BattleMember(Panel_BattleMember, nIndex)
	Panel_BattleMember:setName("Panel_BattleMember"..nIndex)
	Panel_BattleMember:removeAllChildren()
	Panel_BattleMember:setVisible(false)
	
	local GameObj_Card = g_Hero:getCardObjByServID(self.tbBattleCardServerID[nIndex])
	local Image_BattleMember = tolua.cast(g_WidgetModel.Image_BattleMember:clone(), "ImageView")
	Image_BattleMember:setName("Image_BattleMember"..nIndex)
	Image_BattleMember:setPosition(ccp(60,110))
	setImage_BattleMember(Image_BattleMember, GameObj_Card)
	Panel_BattleMember:addChild(Image_BattleMember)
end

function Game_BatWin1:setListView_Member()
	local tbBattleCardList = g_Hero:getBattleCardList()
	self.tbBattleCardServerID = {}
	for i = 1, #tbBattleCardList do
        local value = tbBattleCardList[i]
		if value.nServerID > 0 then
			table.insert(self.tbBattleCardServerID, value.nServerID)
        end
	end

	self.ListView_Member:updateItems(#self.tbBattleCardServerID)
end

function Game_BatWin1:fadeInAction(obeAction, nTime, nFunc)
	local nTime = nTime or 0.25
	local func = nFunc
	local actionFadeIn = CCFadeIn:create(nTime)
	local actionExplosion = sequenceAction({
		actionFadeIn,
		CCCallFuncN:create(function() 
			if func then func() end
		end)
	})
	obeAction:runAction(actionExplosion)	
end

--经验，铜钱，阅历	
function Game_BatWin1:showResourceInfoPNLAction()
	local Image_ResourceInfoPNL = tolua.cast(self.rootWidget:getChildByName("Image_ResourceInfoPNL"), "ImageView")
	local function runResourceInfoEndAction()
		--执行资源奖励数值跳动动画
		self:setImage_ResourceInfoPNL()
		
		local function runBatWinPNLEndAction()
			--队列动画
			self:runBattleMemberSequenceAction()
		end
		--道具奖励面板
		local Image_BatResultPNL = tolua.cast(self.rootWidget:getChildByName("Image_BatResultPNL"), "ImageView")
		self:fadeInAction(Image_BatResultPNL, 0.25, runBatWinPNLEndAction)
	end
		
	self:fadeInAction(Image_ResourceInfoPNL, 0.25, runResourceInfoEndAction)
end

--经验、阅历、铜钱数值跳动动画
function Game_BatWin1:setImage_ResourceInfoPNL()
	local Image_ResourceInfoPNL = tolua.cast(self.rootWidget:getChildByName("Image_ResourceInfoPNL"), "ImageView")
	
	local function runResourceAction1()
		if not g_WndMgr:getWnd("Game_BatWin1") then return end
		local Button_YuanBao = tolua.cast(Image_ResourceInfoPNL:getChildByName("Button_YuanBao"), "Button")
		Button_YuanBao:setVisible(true)
		local Label_ResourceValue = tolua.cast(Button_YuanBao:getChildByName("Label_ResourceValue"), "Label")
        if tbRewardResource.nPrestige and tbRewardResource.nPrestige == 0 then
		    self.YuanBaoTimerId = g_CreatePropDynamic(Label_ResourceValue, 0.75, 0, tbRewardResource.nYuanBao, "+%d", g_getColor(ccs.COLOR.LIME_GREEN), g_getColor(ccs.COLOR.WHITE))
        else
            local Image_Icon = tolua.cast(Button_YuanBao:getChildByName("Image_Icon"), "ImageView")
            Image_Icon:loadTexture(getUIImg("Icon_PlayerInfo_Prestige"))
            local Label_Name = tolua.cast(Button_YuanBao:getChildByName("Label_Name"), "Label")
            Label_Name:setText(_T("声望")); 
            self.YuanBaoTimerId = g_CreatePropDynamic(Label_ResourceValue, 0.75, 0, tbRewardResource.nPrestige, "+%d", g_getColor(ccs.COLOR.LIME_GREEN), g_getColor(ccs.COLOR.WHITE))      
        end
		
	end
	
	local function runResourceAction2()
		if not g_WndMgr:getWnd("Game_BatWin1") then return end
		local Button_TongQian = tolua.cast(Image_ResourceInfoPNL:getChildByName("Button_TongQian"), "Button")
		Button_TongQian:setVisible(true)
		local Label_ResourceValue = tolua.cast(Button_TongQian:getChildByName("Label_ResourceValue"), "Label")
		self.CoinsTimerId = g_CreatePropDynamic(Label_ResourceValue, 0.75, 0, tbRewardResource.nCoins, "+%d", g_getColor(ccs.COLOR.LIME_GREEN), g_getColor(ccs.COLOR.WHITE))
	end
	
	local function runResourceAction3()
		if not g_WndMgr:getWnd("Game_BatWin1") then return end
		local Button_XueShi = tolua.cast(Image_ResourceInfoPNL:getChildByName("Button_XueShi"), "Button")
		Button_XueShi:setVisible(true)
		local Label_ResourceValue = tolua.cast(Button_XueShi:getChildByName("Label_ResourceValue"), "Label")
		self.XueShiTimerId = g_CreatePropDynamic(Label_ResourceValue, 0.75, 0, tbRewardResource.nKnowLedge, "+%d", g_getColor(ccs.COLOR.LIME_GREEN), g_getColor(ccs.COLOR.WHITE))
	end

	local actionExplosion = sequenceAction({
		CCDelayTime:create(0.1),
		CCCallFuncN:create(runResourceAction2),
		CCDelayTime:create(0.2),
		CCCallFuncN:create(runResourceAction3),
		CCDelayTime:create(0.3),
		CCCallFuncN:create(runResourceAction1),
	})
	self.rootWidget:runAction(actionExplosion)	
end
--[[
	飞星动画
]]
function Game_BatWin1:showStarsAnimation(func,nStarScore)
	local timeFly = 0
	local endFunc = nil
	for i = 1, nStarScore do
		local Image_Star = tolua.cast(self.rootWidget:getChildByName("Image_Star"..i), "ImageView")
		if i == nStarScore then
			endFunc = func
		end
		timeFly = timeFly + 0.2	
		g_AnimationFlyStar(Image_Star,timeFly,endFunc)
	end
    if nStarScore == 0 then
        func()
    end
	for i = 1, 4 do
		local Image_Char = tolua.cast(self.rootWidget:getChildByName("Image_Char"..i), "ImageView")
		Image_Char:setVisible(false)
	end

end

function Game_BatWin1:showCharsAnimation(func, nAnimationType)
	for i = 1, 3 do
		local Image_Star = tolua.cast(self.rootWidget:getChildByName("Image_Star"..i), "ImageView")
		Image_Star:setVisible(false)
	end
	
	if g_LggV:getLanguageVer() == eLanguageVer.LANGUAGE_viet_VIET then
		if nAnimationType == 2 then
			local Image_Char1 = tolua.cast(self.rootWidget:getChildByName("Image_Char1"), "ImageView")
			Image_Char1:setPositionXY(270, 600)
			Image_Char1:setVisible(false)
			local Image_Char2 = tolua.cast(self.rootWidget:getChildByName("Image_Char2"), "ImageView")
			Image_Char2:setPositionXY(495, 635)
			Image_Char2:setVisible(false)
			local Image_Char3 = tolua.cast(self.rootWidget:getChildByName("Image_Char3"), "ImageView")
			Image_Char3:setPositionXY(725, 620)
			Image_Char3:setVisible(false)
			local Image_Char4 = tolua.cast(self.rootWidget:getChildByName("Image_Char4"), "ImageView")
			Image_Char4:setPositionXY(945, 580)
			Image_Char4:setVisible(false)
		else
			local Image_Char1 = tolua.cast(self.rootWidget:getChildByName("Image_Char1"), "ImageView")
			Image_Char1:setPositionXY(285, 600)
			Image_Char1:setVisible(false)
			local Image_Char2 = tolua.cast(self.rootWidget:getChildByName("Image_Char2"), "ImageView")
			Image_Char2:setPositionXY(510, 635)
			Image_Char2:setVisible(false)
			local Image_Char3 = tolua.cast(self.rootWidget:getChildByName("Image_Char3"), "ImageView")
			Image_Char3:setPositionXY(695, 625)
			Image_Char3:setVisible(false)
			local Image_Char4 = tolua.cast(self.rootWidget:getChildByName("Image_Char4"), "ImageView")
			Image_Char4:setPositionXY(890, 595)
		end
	else
		local Image_Char1 = tolua.cast(self.rootWidget:getChildByName("Image_Char1"), "ImageView")
		Image_Char1:setPositionXY(383, 570)
		Image_Char1:setVisible(false)
		local Image_Char2 = tolua.cast(self.rootWidget:getChildByName("Image_Char2"), "ImageView")
		Image_Char2:setPositionXY(515, 595)
		Image_Char2:setVisible(false)
		local Image_Char3 = tolua.cast(self.rootWidget:getChildByName("Image_Char3"), "ImageView")
		Image_Char3:setPositionXY(643, 595)
		Image_Char3:setVisible(false)
		local Image_Char4 = tolua.cast(self.rootWidget:getChildByName("Image_Char4"), "ImageView")
		Image_Char4:setPositionXY(775, 570)
		Image_Char4:setVisible(false)
	end
	
	local timeFly = 0
	local endFunc = nil
	for i = 1, 4 do
		local Image_Char = tolua.cast(self.rootWidget:getChildByName("Image_Char"..i), "ImageView")
		if i == 4 then
			endFunc = func
		end
		if nAnimationType == 2 then
			if i == 3 then
				Image_Char:loadTexture(getBattleImg("Char_Sheng"))
			elseif i == 4 then
				Image_Char:loadTexture(getBattleImg("Char_Li"))
			end
		elseif nAnimationType == 3 then
			if i == 3 then
				Image_Char:loadTexture(getBattleImg("Char_Jie"))
			elseif i == 4 then
				Image_Char:loadTexture(getBattleImg("Char_Shu"))
			end
		end
		timeFly = timeFly + 0.2	
		g_AnimationFlyStar(Image_Char, timeFly, endFunc)
	end
end

function Game_BatWin1:openWnd(tbData)
	if g_bReturn then return end
	if not tbData then return end
	
	local Image_BatResultPNL = tolua.cast(self.rootWidget:getChildByName("Image_BatResultPNL"), "ImageView")
	Image_BatResultPNL:setOpacity(0)
	
	local Button_Again = tolua.cast(Image_BatResultPNL:getChildByName("Button_Again"), "Button") 
	Button_Again:setVisible(false)
	Button_Again:setTouchEnabled(false)
	local Button_Return = tolua.cast(Image_BatResultPNL:getChildByName("Button_Return"), "Button")
	local function onClickButton_Return(pSender, nTag)
		--预加载窗口缓存防止卡顿
		if TbBattleReport then
			if g_BattleData then
				local nBattleType = g_BattleData:getEctypeType()
				if nBattleType == macro_pb.Battle_Atk_Type_normal_pass --战斗副本
					or nBattleType == macro_pb.Battle_Atk_Type_advanced_pass
					or nBattleType == macro_pb.Battle_Atk_Type_master_pass
				then
					local tbCardLeader = g_Hero:getBattleCardByIndex(1)
					local nNewLevel = tbCardLeader:getNewLvByAddExp(tbRewardResource.nTeamMemberExp)
					if nNewLevel > g_Hero:getMasterCardLevel() then
						g_WndMgr:getFormtbRootWidget("Game_HeroLevelUpAnimation")
					end
					
					if g_Hero:getIsMapFirstFinish() then
						g_WndMgr:getFormtbRootWidget("Game_TaskFinishedAnimation")
					end
				elseif nBattleType == macro_pb.Battle_Atk_Type_Jing_Ying_pass then --精英副本
					local tbCardLeader = g_Hero:getBattleCardByIndex(1)
					local nNewLevel = tbCardLeader:getNewLvByAddExp(tbRewardResource.nTeamMemberExp)
					if nNewLevel > g_Hero:getMasterCardLevel() then
						g_WndMgr:getFormtbRootWidget("Game_HeroLevelUpAnimation")
					end
				elseif nBattleType == macro_pb.Battle_Atk_Type_Money --活动副本
					or nBattleType == macro_pb.Battle_Atk_Type_Exp
					or nBattleType == macro_pb.Battle_Atk_Type_Tribute
					or nBattleType == macro_pb.Battle_Atk_Type_Aura
					or nBattleType == macro_pb.Battle_Atk_Type_Knowledge
				then
					local tbCardLeader = g_Hero:getBattleCardByIndex(1)
					local nNewLevel = tbCardLeader:getNewLvByAddExp(tbRewardResource.nTeamMemberExp)
					if nNewLevel > g_Hero:getMasterCardLevel() then
						g_WndMgr:getFormtbRootWidget("Game_HeroLevelUpAnimation")
					end
				elseif nBattleType == macro_pb.Battle_Atk_Type_dujie then --渡劫
					g_WndMgr:getFormtbRootWidget("Game_UpgradeAnimation")
				elseif nBattleType == macro_pb.Battle_Atk_Type_WorldBoss 
					or nBattleType == macro_pb.Battle_Atk_Type_SceneBoss
					or nBattleType == macro_pb.Battle_Atk_Type_GuildWorldBoss
					or nBattleType == macro_pb.Battle_Atk_Type_GuildSceneBoss
				then --世界Boss
					g_WndMgr:getFormtbRootWidget("Game_RewardMsgConfirm")
				elseif nBattleType == macro_pb.Battle_Atk_Type_ArenaPlayer
					or nBattleType == macro_pb.Battle_Atk_Type_ArenaRobot
					or nBattleType == macro_pb.Battle_Atk_Type_CrossArenaPlayer
				then --竞技场、机器人竞技场
					g_WndMgr:getFormtbRootWidget("Game_HeroLevelUpAnimation")
					g_WndMgr:getFormtbRootWidget("Game_RankLevelUpAnimation")
				elseif nBattleType == macro_pb.Battle_Atk_Type_BaXian_Rob then --八仙过海
					--
				end
			end
		end
		g_WndMgr:closeWnd("Game_BatWin1")
	end
	g_SetBtnWithGuideCheck(Button_Return, nil, onClickButton_Return, true, true, nil, nil)
	Button_Return:setVisible(false)
	Button_Return:setTouchEnabled(false)
	self.rootWidget:setTouchEnabled(false)
	
	tbRewardInfo = tbData
	tbRewardResource = tbData.tbRewardResource
	tbRewardItems = tbData.tbRewardItems
	
	self:setListView_Member()
	self:setListView_DropItem()
		
	local Image_ResourceInfoPNL = tolua.cast(self.rootWidget:getChildByName("Image_ResourceInfoPNL"), "ImageView")
	Image_ResourceInfoPNL:setOpacity(0)
	local Button_YuanBao = tolua.cast(Image_ResourceInfoPNL:getChildByName("Button_YuanBao"), "Button")
	Button_YuanBao:setVisible(false)
	
	local Button_TongQian = tolua.cast(Image_ResourceInfoPNL:getChildByName("Button_TongQian"), "Button")
	Button_TongQian:setVisible(false)
	
	local Button_XueShi = tolua.cast(Image_ResourceInfoPNL:getChildByName("Button_XueShi"), "Button")
	Button_XueShi:setVisible(false)
	
	local function showPanelAction()
		--淡入 信息面板
		self:showResourceInfoPNLAction()
	end
	
	local nLightHeight = 580

	
	if tbData.nAnimationType == Enum_BattleWinCharType._Star then --精英副本 20150702 by zgj
		self:showStarsAnimation(showPanelAction, tbRewardInfo.nStarScore)
		nLightHeight = 580
	elseif tbData.nAnimationType == Enum_BattleWinCharType._TiaoZhanShengLi then
		self:showCharsAnimation(showPanelAction, tbData.nAnimationType)
		nLightHeight = 600
	elseif tbData.nAnimationType == Enum_BattleWinCharType._TiaoZhanJieShu then
		self:showCharsAnimation(showPanelAction, tbData.nAnimationType)
		nLightHeight = 600
	end
	for i = 1, 7 do
		local Image_Light = tolua.cast(self.rootWidget:getChildByName("Image_Light"..i), "ImageView")
		Image_Light:setPositionY(nLightHeight)
	end
	g_playSoundEffectBattle("Sound/Battle_Win.mp3")
	
	if g_PlayerGuide:checkCurrentGuideSequenceNode("BattleResultBegin", "Game_BatResult") then
		g_PlayerGuide:showCurrentGuideSequenceNode()
	end
end

function Game_BatWin1:initWnd()
	local Image_Light7 = tolua.cast(self.rootWidget:getChildByName("Image_Light7"), "ImageView")
	g_SetBlendFuncWidget(Image_Light7, 3)
	
	local opacity = 125
	for i = 1, 6 do
		local Image_Light = tolua.cast(self.rootWidget:getChildByName("Image_Light"..i), "ImageView")
		if i >= 3 then opacity = 100 end
		Image_Light:setOpacity(opacity)
		g_SetBlendFuncWidget(Image_Light, 4)
		Image_Light:setScale(0)
	end
	
	local tbRotate = {360,-360,360,360,-360,360}
	for i = 1, 6 do
		local Image_Light = tolua.cast(self.rootWidget:getChildByName("Image_Light"..i), "ImageView")
		local scaleToAction = CCScaleTo:create(0.2,1.35)
		local action = sequenceAction({scaleToAction, CCCallFuncN:create(function() 	
			local actionRotate_Light1 = CCRotateBy:create(5,tbRotate[i]) 	
			local actionRotateForever_Light1 = CCRepeatForever:create(actionRotate_Light1)
			Image_Light:runAction(actionRotateForever_Light1) 
		end)})
		Image_Light:runAction(action)
	end
	
	local Image_BatResultPNL = tolua.cast(self.rootWidget:getChildByName("Image_BatResultPNL"), "ImageView")
	local ListView_Member = tolua.cast(Image_BatResultPNL:getChildByName("ListView_Member"), "ListViewEx")
	self.ListView_Member = ListView_Member
	self.ListView_Member:setLayoutType(LAYOUT_LINEAR_HORIZONTAL)
	self.ListView_Member:setVisible(true)
	local Panel_BattleMember = tolua.cast(self.ListView_Member:getChildByName("Panel_BattleMember"),"Layout")
	registerListViewEvent(self.ListView_Member, Panel_BattleMember, handler(self, self.onUpdateListView_BattleMember), 0, nil, nil, 6)
	
	local imgScrollSlider = self.ListView_Member:getScrollSlider()
	if not g_tbScrollSliderXY.ListView_Member_BatWin_Y then
		g_tbScrollSliderXY.ListView_Member_BatWin_Y = imgScrollSlider:getPositionY()
	end
	imgScrollSlider = imgScrollSlider:setPositionY(g_tbScrollSliderXY.ListView_Member_BatWin_Y - 3)
	
	local ListView_DropItem = tolua.cast(Image_BatResultPNL:getChildByName("ListView_DropItem"), "ListViewEx")
	self.ListView_DropItem = ListView_DropItem
	self.ListView_DropItem:setLayoutType(LAYOUT_LINEAR_HORIZONTAL)
	self.ListView_DropItem:setVisible(true)
	local Panel_DropItem = tolua.cast(self.ListView_DropItem:getChildByName("Panel_DropItem"),"Layout")
	--registerListViewEvent(self.ListView_DropItem, Panel_DropItem, onUpdateListView_DropItem, 0, nil, nil, 14)
	
	local function adjustFunc(Panel_DropItem, index)

		-- local itemModel = tolua.cast(Panel_DropItem:getChildByName("itemModel"), "ImageView")
		-- if index >= 7 then
			-- itemModel:setVisible(true)
		-- end
	end
	registerListViewEvent(self.ListView_DropItem, Panel_DropItem, onUpdateListView_DropItem, 0,adjustFunc)

	
	local imgScrollSlider = self.ListView_DropItem:getScrollSlider()
	if not g_tbScrollSliderXY.ListView_DropItem_BatWin_Y then
		g_tbScrollSliderXY.ListView_DropItem_BatWin_Y = imgScrollSlider:getPositionY()
	end
	imgScrollSlider = imgScrollSlider:setPositionY(g_tbScrollSliderXY.ListView_DropItem_BatWin_Y - 4)

    local function onClickAgain()
		if g_PlayerGuide:checkIsInGuide() then
			g_ClientMsgTips:showMsgConfirm(_T("处于新手引导过程中, 无法退出副本"))
			return
		end
		self.bClickAgain = true
        g_WndMgr:closeWnd("Game_BatWin1")
    end
    g_SetBtn(self.rootWidget, "Button_Again", onClickAgain, true,nil,0)
end

function Game_BatWin1:closeWnd()
	local nBattleCardListCount = g_Hero:getBattleCardListCount()
	for nIndex = 1, nBattleCardListCount do	
		if self.tbExpTimerId and self.tbExpTimerId[nIndex] then
			g_Timer:destroyTimerByID(self.tbExpTimerId[nIndex])
		end
	end
	
	g_Timer:destroyTimerByID(self.YuanBaoTimerId)
	g_Timer:destroyTimerByID(self.CoinsTimerId)
	g_Timer:destroyTimerByID(self.XueShiTimerId)
	
	if tbRewardInfo.closeCallBack then
		tbRewardInfo.closeCallBack()
	end
	
	if not self.bClickAgain then
		if g_WndMgr:isVisible("Game_SelectGameLevel1") then
			g_WndMgr:hideWnd("Game_SelectGameLevel1")
		end
		if g_WndMgr:isVisible("Game_SelectGameLevel2") then
			g_WndMgr:hideWnd("Game_SelectGameLevel2")
		end
		if g_WndMgr:isVisible("Game_SelectGameLevel3") then
			g_WndMgr:hideWnd("Game_SelectGameLevel3")
		end
	else
		
	end
	 
	destroy()

	--优化因窗口缓存
	for i = 1, 3 do
		local Image_Star = tolua.cast(self.rootWidget:getChildByName("Image_Star"..i), "ImageView")
		Image_Star:setVisible(false)
	end
end

--战斗失败界面
Game_BatFailed = class("Game_BatFailed")
Game_BatFailed.__index = Game_BatFailed

local function onClick_Button_GoToEquip()
    g_WndMgr:openWnd("Game_Equip1")
end

local function onClick_Button_GoToCard()
    g_WndMgr:showWnd("Game_Card")
end

local function onClick_Button_GoToZhenRong()
	g_WndMgr:showWnd("Game_MainUI")
end

function Game_BatFailed:initWnd(widget)
	if not widget then return end
	widget:setTouchEnabled(true)
	local function onTouchScreen(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then
	        g_WndMgr:closeWnd("Game_BatFailed")

            if(self.func)then
		        self.func()
	        end
	        self.func = nil
		end	
	end
	widget:addTouchEventListener(onTouchScreen)
	
	g_SetBtn(widget,"Button_GoToEquip", onClick_Button_GoToEquip, true)  
	g_SetBtn(widget,"Button_GoToCard", onClick_Button_GoToCard, true)  
	g_SetBtn(widget,"Button_GoToZhenRong", onClick_Button_GoToZhenRong, true)  
	
	self.onClickButton_Return = true
end

function Game_BatFailed:openWnd(tbData)
    if g_bReturn then return end

	self.func = tbData
	
	local function playSound()
		g_playSoundEffectBattle("Sound/Battle_Lose.mp3")
	end
	g_Timer:pushTimer(0.1, playSound)
	
	if g_PlayerGuide:checkCurrentGuideSequenceNode("BattleResultBegin", "Game_BatResult") then
		g_PlayerGuide:showCurrentGuideSequenceNode()
	end
end

function Game_BatFailed:closeWnd()
	if g_PlayerGuide:checkCurrentGuideSequenceNode("BattleResultEnd", "Game_BatResult") then
		g_PlayerGuide:showCurrentGuideSequenceNode()
	end
	if g_PlayerGuide:checkCurrentGuideSequenceNode("OnUpdateExp", "Game_HeroLevelUpAnimation") then
		g_PlayerGuide:showCurrentGuideSequenceNode()
	end
end
