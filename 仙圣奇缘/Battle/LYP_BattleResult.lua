--------------------------------------------------------------------------------------
-- 文件名:	LYP_BattleResult.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2014-1-3 15:32
-- 版  本:	1.0
-- 描  述:	战斗结束结算界面
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------

--创建CCard类继承UILayout
CBattleResult = class("CBattleResult")
CBattleResult.__index = CBattleResult

Enum_BattleWinCharType = {
	_Star = 1,
	_TiaoZhanShengLi = 2,
	_TiaoZhanJieShu = 3,
}

local function ClearAllResouce(bReturnToMainHome)
   if TbBattleReport and TbBattleReport.TbBattleWnd then
        TbBattleReport.TbBattleWnd.Scene:loadTexture(getUIImg("Blank")) --为了释放jpg内存
        TbBattleReport.GameObj_BattleProcess:removePlistResouce()
    end

    if TbBattleReport and TbBattleReport.IsSettingOpening then
        g_WndMgr:closeWnd("Game_BattleSetting")
    end
    
    if TbBattleReport and TbBattleReport.openDrop then
        g_WndMgr:closeWnd("Game_BattleDrop")
    end
	
	if g_WndMgr:getWnd("Game_BattleFighterInfo") and g_WndMgr:isVisible("Game_BattleFighterInfo") then
		g_WndMgr:closeWnd("Game_BattleFighterInfo")
	end
	
	g_WndMgr:closeWnd("Game_Battle")
	
	g_WndMgr:dumpAnimationResouce()
	
	if g_BattleResouce then
		g_BattleResouce:ReleaseCach()
	end
	
	g_BattleMgr:reNewBattleData()

    g_ClientMsgTips:closeConfirm()
	
	g_playSoundMusic(g_GameMusic, true) 
	
	if bReturnToMainHome == true then
		local function restartNewPlayerGuide()
			mainWnd:showPlayerGuide()
		end
		g_WndMgr:showMainWnd(restartNewPlayerGuide)
	end
	
	TbBattleReport = nil 
end

function onColseCleanupAction()
	ClearAllResouce()
end

function EscapeClearAllResouce(bClear, bReturnToMainHome)
    local function waitToClear()
	    SimpleAudioEngine:sharedEngine():stopAllEffects()
	  
		if TbBattleReport then
			local tbGameFighters_OnWnd = TbBattleReport.tbGameFighters_OnWnd
			for nPos, GameFighter in pairs(tbGameFighters_OnWnd) do
				if GameFighter and GameFighter ~= {} and GameFighter.isExsit_Layout and GameFighter:isExsit_Layout() then
					GameFighter:removeFromParentAndCleanup(true)
				end
				
				if TbBattleReport.tbGameFighters_OnWnd[nPos] and TbBattleReport.tbGameFighters_OnWnd[nPos] ~= {} then
					TbBattleReport.tbGameFighters_OnWnd[nPos]:release()
					TbBattleReport.tbGameFighters_OnWnd[nPos] = nil
				end
			end
		end

		ClearAllResouce(bReturnToMainHome)
    end
    
	if TbBattleReport then
		if not TbBattleReport.bClear then
			if bClear then
				waitToClear()
			else
				TbBattleReport.bClear = true
				g_Timer:pushTimer(1*g_TimeSpeed, waitToClear)
			end
		end
	end
end

function CBattleResult:showEctypeBattleResult(tbBattleResult, nBattleType, bIsWin)
	local function funcBattleResultEndCall()
		if(tbBattleResult.drop_result and #tbBattleResult.drop_result > 0)then
			g_Hero:addTeamMemberExpWithHeroEvent(self.tbRewardInfo.tbRewardResource.nTeamMemberExp,
					self.tbRewardInfo.tbRewardResource.nMasterCardLevel,
					self.tbRewardInfo.tbRewardResource.nMasterCardExp
				)
		end
		
		if (nBattleType == macro_pb.Battle_Atk_Type_normal_pass
			or nBattleType == macro_pb.Battle_Atk_Type_advanced_pass
			or nBattleType == macro_pb.Battle_Atk_Type_master_pass
		) then --战斗副本
			if g_WndMgr:getWnd("Game_EctypeList") then 
				g_WndMgr:getWnd("Game_EctypeList"):refreshWndFromBattle()
			end
		elseif nBattleType == macro_pb.Battle_Atk_Type_Jing_Ying_pass then --精英副本 20150702 by zgj
			--nil
		end
	end
	
	if bIsWin then
		if nBattleType == macro_pb.Battle_Atk_Type_Jing_Ying_pass then --精英副本 20150702 by zgj
			self:showBattleSucc(tbBattleResult, Enum_BattleWinCharType._Star, funcBattleResultEndCall)
		else
			self:showBattleSucc(tbBattleResult, Enum_BattleWinCharType._TiaoZhanShengLi, funcBattleResultEndCall)
		end
	else
		self:showBattleFail(funcBattleResultEndCall)
	end
end

function CBattleResult:showBaXianBattleResult(tbBattleResult, bIsWin, nBattleType)
	if bIsWin then
		local function funcBattleSuccEndCall()
	        g_BaXianGuoHaiSystem:ResponseRobResult()
		end
		self:showBattleSucc(tbBattleResult, Enum_BattleWinCharType._TiaoZhanJieShu, funcBattleSuccEndCall)
	else
		self:showBattleFail(funcBattleResultEndCall)
	end
end
	
function CBattleResult:showWorldBossBattleResult(tbBattleResult, bIsWin, nBattleType)
	local function funcBattleResultEndCall()
		if not tbBattleResult.drop_result then return end
		local total = 0
		for i =1, #tbBattleResult.drop_result do
			local tbDropList = tbBattleResult.drop_result[i].drop_lst
			for j =1, #tbDropList do
				local tbDropItem = tbDropList[j]
				local nType = tbDropItem.drop_item_type
				local nNum = tbDropItem.drop_item_num
				if nType == macro_pb.ITEM_TYPE_GOLDS then
					total = total+nNum
				end
			end
		end

		g_ShowRewardMsgConfrim(macro_pb.ITEM_TYPE_GOLDS, total)
	end
	
	if bIsWin then
		local function funcBattleSuccEndCall()
			if(tbBattleResult.drop_result and #tbBattleResult.drop_result > 0)then
				g_Hero:addTeamMemberExpWithCallEvent(self.tbRewardInfo.tbRewardResource.nTeamMemberExp,
					funcBattleResultEndCall,
					self.tbRewardInfo.tbRewardResource.nMasterCardLevel,
					self.tbRewardInfo.tbRewardResource.nMasterCardExp
				)
			else
				funcBattleResultEndCall()
			end
		end
		self:showBattleSucc(tbBattleResult, Enum_BattleWinCharType._TiaoZhanJieShu, funcBattleSuccEndCall)
	else
		self:showBattleFail(funcBattleResultEndCall)
	end
end
	
function CBattleResult:showActivityBattleResult(tbBattleResult, nBattleType, bIsWin)
	local function funcBattleResultEndCall()
		if nBattleType == macro_pb.Battle_Atk_Type_Money then
			local wndInstantce = g_WndMgr:getWnd("Game_ActivityFuLuDaoSub")
			if wndInstantce then
				wndInstantce:updateMasterEnergy()
			end
		elseif nBattleType == macro_pb.Battle_Atk_Type_Exp then
			local wndInstantce = g_WndMgr:getWnd("Game_ActivityFuLuDaoSub")
			if wndInstantce then
				wndInstantce:updateMasterEnergy()
			end
		elseif nBattleType == macro_pb.Battle_Atk_Type_Tribute then	
			local wndInstantce = g_WndMgr:getWnd("Game_ActivityFuLuDaoSub")
			if wndInstantce then
				wndInstantce:updateMasterEnergy()
			end
		elseif nBattleType == macro_pb.Battle_Atk_Type_Aura then	
			local wndInstantce = g_WndMgr:getWnd("Game_ActivityFuLuDaoSub")
			if wndInstantce then
				wndInstantce:updateMasterEnergy()
			end
		elseif nBattleType == macro_pb.Battle_Atk_Type_Knowledge then	
			local wndInstantce = g_WndMgr:getWnd("Game_ActivityFuLuDaoSub")
			if wndInstantce then
				wndInstantce:updateMasterEnergy()
			end
		end
	end
	
	if bIsWin then
		local function funcBattleSuccEndCall()
			if(tbBattleResult.drop_result and #tbBattleResult.drop_result > 0)then
				g_Hero:addTeamMemberExpWithCallEvent(self.tbRewardInfo.tbRewardResource.nTeamMemberExp,
					funcBattleResultEndCall,
					self.tbRewardInfo.tbRewardResource.nMasterCardLevel,
					self.tbRewardInfo.tbRewardResource.nMasterCardExp
				)
			else
				funcBattleResultEndCall()
			end
		end
		self:showBattleSucc(tbBattleResult, Enum_BattleWinCharType._TiaoZhanShengLi, funcBattleSuccEndCall)
	else
		self:showBattleFail()
	end
end

function CBattleResult:showDuJieBattleResult(tbBattleResult, bIsWin, nBattleType)

	--渡劫前
	local objWnd = g_WndMgr:getWnd("Game_CardDuJie")
	if objWnd then
		local tbCardInfo = g_Hero:getCardObjByServID(objWnd.nCardID)
		self.tbDuJieParams = {
			RealmColorType_Source = tbCardInfo:getRealmColorType(),
			RealmName_Source = tbCardInfo:getRealmName(),
			HpMax_Source = tbCardInfo:getHPMax(), --生命
			ForcePoints_Source = tbCardInfo:getForcePoints(),--武力
			MagicPoints_Source = tbCardInfo:getMagicPoints(),--法术
			SkillPoints_Source = tbCardInfo:getSkillPoints(),--绝技	
		}
	else
		self.tbDuJieParams = {}
	end
	
	if TbBattleReport and TbBattleReport.tbDujie then
		local tbResCard = TbBattleReport.tbDujie.card_info
		local tbCardInfo = g_Hero:getCardObjByServID(tbResCard.cardid)
		tbCardInfo:setReleamProp(tbResCard.relamlv, tbResCard.relamexp)
	else
	end
	
	--渡劫后
	if objWnd then
		local tbCardInfo = g_Hero:getCardObjByServID(objWnd.nCardID)
		self.tbDuJieParams.tbCardTarget = tbCardInfo
	else
		self.tbDuJieParams.tbCardTarget = nil
	end
	
	local function funcBattleResultEndCall()
		local function funcDuJieCallBack()
			local objWnd = g_WndMgr:getWnd("Game_CardDuJie")
			if objWnd then
				local tbCardInfo = g_Hero:getCardObjByServID(objWnd.nCardID)
				if tbCardInfo and tbCardInfo:checkIsInBattle() then
					g_Hero:showTeamStrengthGrowAnimation()
				end
			end
		end
		g_ShowUpgradeEventAnimation(2, 4, self.tbDuJieParams, funcDuJieCallBack, nil)
	end
	
	if bIsWin then
		local function funcBattleSuccEndCall()
			if(tbBattleResult.drop_result and #tbBattleResult.drop_result > 0)then
				g_Hero:addTeamMemberExpWithCallEvent(self.tbRewardInfo.tbRewardResource.nTeamMemberExp,
					funcBattleResultEndCall,
					self.tbRewardInfo.tbRewardResource.nMasterCardLevel,
					self.tbRewardInfo.tbRewardResource.nMasterCardExp
				)
			else
				funcBattleResultEndCall()
			end
		end
		self:showBattleSucc(tbBattleResult, Enum_BattleWinCharType._TiaoZhanShengLi, funcBattleSuccEndCall)
	else
		self:showBattleFail()
	end

end
	
function CBattleResult:showRankBattleResult(tbBattleResult, bIsWin, nBattleType)
	local function funcBattleResultEndCall()
		showArenaWinAnimation(nil, bIsWin)
	end
	if bIsWin then
		local function funcBattleSuccEndCall()
			if g_PlayerGuide:checkCurrentGuideSequenceNode("BattleResultEnd", "Game_BatResult") then
				g_PlayerGuide:showCurrentGuideSequenceNode()
			end
			
			if(tbBattleResult.drop_result and #tbBattleResult.drop_result > 0)then
				g_Hero:addTeamMemberExpWithCallEvent(self.tbRewardInfo.tbRewardResource.nTeamMemberExp,
					funcBattleResultEndCall,
					self.tbRewardInfo.tbRewardResource.nMasterCardLevel,
					self.tbRewardInfo.tbRewardResource.nMasterCardExp
				)
			else
				funcBattleResultEndCall()
			end
		end
		self:showBattleSucc(tbBattleResult, Enum_BattleWinCharType._TiaoZhanShengLi, funcBattleSuccEndCall)
	else
		self:showBattleFail(funcBattleResultEndCall)
	end
end

function CBattleResult:showPkBattleResult(tbBattleResult, bIsWin, nBattleType)
	if bIsWin then
		self:showBattleSucc(tbBattleResult, Enum_BattleWinCharType._TiaoZhanShengLi, nil, nBattleType)
	else
		self:showBattleFail(nil)
	end
end

function CBattleResult:showBattleSucc(tbBattleResult, nAniType, funcCallBack, nBattleType)	
	self.tbRewardInfo = {
		nStarScore = self.nStarScore,
		tbRewardResource = {
			nYuanBao = 0,
			nCoins = 0,
			nKnowLedge = 0,
			nTeamMemberExp = 0,
            nPrestige = 0,
			nMasterCardLevel = 0,
			nMasterCardExp = 0,
		},
		nOldLevel = 0,
		tbRewardItems = {},
		--tbCardSourceLevel = {},
		nAnimationType = nAniType,
		closeCallBack = nil
	}
	
	--为了在关闭界面触发Player升级事件，所以在关闭界面将掉落更新的Player里面
	
	self.tbRewardInfo.closeCallBack = function()	
		if funcCallBack then
			funcCallBack()
		end
		onColseCleanupAction()
	end

	if(tbBattleResult.drop_result and #tbBattleResult.drop_result > 0)then
		for i =1, #tbBattleResult.drop_result do
			local tbDropList = tbBattleResult.drop_result[i].drop_lst
			if tbDropList and #tbDropList > 0 then
				for j =1, #tbDropList do
					local tbDropItem = tbDropList[j]
					if tbDropItem then
						local nItemType = tbDropItem.drop_item_type
						local nItemCfgID = tbDropItem.drop_item_config_id
						local nItemStarLev = tbDropItem.drop_item_star_lv
						local nItemNum = tbDropItem.drop_item_num
						local nItemEvoluteLevel = tbDropItem.drop_item_blv
						local tbReward = {}
						if(nItemType < macro_pb.ITEM_TYPE_MASTER_EXP)then
							table.insert(self.tbRewardInfo.tbRewardItems,
								{
									DropItemType = nItemType,
									DropItemID = nItemCfgID,
									DropItemStarLevel = nItemStarLev,
									DropItemNum = nItemNum,
									DropItemEvoluteLevel = nItemEvoluteLevel,
								}
							)
							g_Hero:addDropItem(tbDropItem)
						elseif(nItemType == macro_pb.ITEM_TYPE_COUPONS)then
							self.tbRewardInfo.tbRewardResource.nYuanBao = self.tbRewardInfo.tbRewardResource.nYuanBao + nItemNum
						elseif(nItemType == macro_pb.ITEM_TYPE_GOLDS)then
							self.tbRewardInfo.tbRewardResource.nCoins = self.tbRewardInfo.tbRewardResource.nCoins + nItemNum
						elseif(nItemType == macro_pb.ITEM_TYPE_KNOWLEDGE)then
							self.tbRewardInfo.tbRewardResource.nKnowLedge = self.tbRewardInfo.tbRewardResource.nKnowLedge + nItemNum
						elseif(nItemType == macro_pb.ITEM_TYPE_CARDEXPINBATTLE)then
							self.tbRewardInfo.tbRewardResource.nTeamMemberExp = self.tbRewardInfo.tbRewardResource.nTeamMemberExp + nItemNum
							self.tbRewardInfo.tbRewardResource.nMasterCardLevel = tbDropItem.lv
							self.tbRewardInfo.tbRewardResource.nMasterCardExp = tbDropItem.exp
                        -- 增加声望 20150625 by zgj
                        elseif(nItemType == macro_pb.ITEM_TYPE_PRESTIGE)then
							self.tbRewardInfo.tbRewardResource.nPrestige = self.tbRewardInfo.tbRewardResource.nPrestige + nItemNum
						end
					end
				end
			end
		end

		self.tbRewardInfo.nStarScore = self.nStarScore
		
		if self.tbRewardInfo.tbRewardResource.nYuanBao > 0 then
			g_Hero:addYuanBao(self.tbRewardInfo.tbRewardResource.nYuanBao)
		end
		g_Hero:addCoins(self.tbRewardInfo.tbRewardResource.nCoins)
		g_Hero:addKnowledge(self.tbRewardInfo.tbRewardResource.nKnowLedge)
		
		if self.tbRewardInfo.tbRewardResource.nPrestige > 0 then
			g_Hero:addPrestige(self.tbRewardInfo.tbRewardResource.nPrestige)
		end
		
		g_WndMgr:showWnd("Game_BatWin1", self.tbRewardInfo)
	else
		self.tbRewardInfo.nStarScore = self.nStarScore
		g_WndMgr:showWnd("Game_BatWin1", self.tbRewardInfo)
	end
end

function CBattleResult:showBattleFail(funcCallBack)
	local function funcBattleResultEndCall()
		if funcCallBack then
			funcCallBack()
		end
		ClearAllResouce(false)
	end
	g_WndMgr:showWnd("Game_BatFailed", funcBattleResultEndCall)
end

--初始化主界面的伙伴详细介绍界面
function CBattleResult:showBattleResult(tbBattleResult, nStarScore)
	if(not tbBattleResult)then
		return
	end
	
	
	
	self.nStarScore = nStarScore
	local WndResult = nil

	local nBattleType = g_BattleData:getEctypeType()
	
	if (nBattleType == macro_pb.Battle_Atk_Type_normal_pass --战斗副本
		or nBattleType == macro_pb.Battle_Atk_Type_advanced_pass
		or nBattleType == macro_pb.Battle_Atk_Type_master_pass
		or nBattleType == macro_pb.Battle_Atk_Type_Jing_Ying_pass --精英副本 20150702 by zgj
	) then
		self:showEctypeBattleResult(tbBattleResult, nBattleType, tbBattleResult.iswin, nBattleType)
	elseif (nBattleType == macro_pb.Battle_Atk_Type_RichGod --活动副本
		or nBattleType == macro_pb.Battle_Atk_Type_GodTrial
		or nBattleType == macro_pb.Battle_Atk_Type_PickPeach
        or nBattleType == macro_pb.Battle_Atk_Type_Money
		or nBattleType == macro_pb.Battle_Atk_Type_Exp
		or nBattleType == macro_pb.Battle_Atk_Type_Tribute
		or nBattleType == macro_pb.Battle_Atk_Type_Aura
		or nBattleType == macro_pb.Battle_Atk_Type_Knowledge
	) then
		self:showActivityBattleResult(tbBattleResult, nBattleType, tbBattleResult.iswin, nBattleType)
	elseif(nBattleType == macro_pb.Battle_Atk_Type_dujie)then --渡劫
		self:showDuJieBattleResult(tbBattleResult, tbBattleResult.iswin, nBattleType) 
	elseif (nBattleType == macro_pb.Battle_Atk_Type_WorldBoss) or
		   (nBattleType == macro_pb.Battle_Atk_Type_SceneBoss) or 
		   (nBattleType == macro_pb.Battle_Atk_Type_GuildWorldBoss) or
		   (nBattleType == macro_pb.Battle_Atk_Type_GuildSceneBoss) then --世界Boss
		self:showWorldBossBattleResult(tbBattleResult, tbBattleResult.iswin, nBattleType) 
	elseif(nBattleType == macro_pb.Battle_Atk_Type_Rotational)then --六道轮回，暂未开放
		--nil
	elseif(nBattleType == macro_pb.Battle_Atk_Type_ArenaPlayer 
		or nBattleType == macro_pb.Battle_Atk_Type_ArenaRobot)
		or nBattleType == macro_pb.Battle_Atk_Type_CrossArenaPlayer
		then --竞技场、机器人竞技场
		self:showRankBattleResult(tbBattleResult, tbBattleResult.iswin, nBattleType)
	elseif nBattleType == macro_pb.Battle_Atk_Type_Player then --好友切磋
		self:showPkBattleResult(tbBattleResult, tbBattleResult.iswin, nBattleType)
	elseif nBattleType == macro_pb.Battle_Atk_Type_BaXian_Rob then --八仙过海
		self:showBaXianBattleResult(tbBattleResult, tbBattleResult.iswin, nBattleType)
	elseif(nBattleType == 100)then --图鉴
		g_IsExitBattleProcess = nil
	else
		error("===副本类型错误===="..nBattleType)
	end
end

g_BattleResult = CBattleResult.new()