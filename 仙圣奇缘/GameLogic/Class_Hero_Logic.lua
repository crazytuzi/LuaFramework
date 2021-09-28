--------------------------------------------------------------------------------------
-- 文件名:	Hero.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2013-12-16 15:24
-- 版  本:	1.0
-- 描  述:	玩家数据
-- 应  用:
---------------------------------------------------------------------------------------

g_ParamsHeroLevelUp = {}

--新手引导数据
function Class_Hero:initPlayerGuideStep(nKey, nValue)
	cclog("服务端记录的步骤"..nKey.."-"..nValue.." 即将开始引导"..nKey.."-"..nValue)
	self.nPlayerGuideId = nKey or 1
	self.nPlayerGuideIndex = nValue or 1
end

function Class_Hero:setNewPlayerGuideData(msg)
	self.nPlayerGuideId = msg.guide_id
	self.nPlayerGuideIndex = msg.guide_no
	
	local CSV_Guide = g_DataMgr:getGuideCsv(msg.guide_id)

	--新手引导 统计
	if msg.guide_id <= g_nForceGuideMaxID then
		local TDdata =  CDataEvent:CteateDataEvent()
		cclog("=============发送引导节点给TalkingData引导ID=============="..msg.guide_id)
		cclog("=============发送引导节点给TalkingData引导Index=============="..msg.guide_no)
		TDdata:PushDataEvent(msg.guide_no, "S")
		gTalkingData:onEvent(msg.guide_id, TDdata)
	else
		-- if msg.guide_no == 1 then
			-- local TDdata =  CDataEvent:CteateDataEvent()
			-- TDdata:PushDataEvent(msg.guide_no, "S")
			-- gTalkingData:onEvent(msg.guide_id, TDdata)
		-- end
	end
end

--检查是否有新手引导
function Class_Hero:checkSendGuideMsgQualify(nGuideID, nIndex)
    if g_nForceGuideMaxID <= 0 then return true end
	
	local CSV_GuideSequence = g_DataMgr:getGuideSequenceCsv(nGuideID, nIndex)
	if CSV_GuideSequence.GuideID == 0 then return true end
	
	--返回true说明已经发过消息了
	if self.nPlayerGuideId == nGuideID then
		return self.nPlayerGuideIndex >= nIndex
	elseif self.nPlayerGuideId > nGuideID then
		return true
	elseif self.nPlayerGuideId < nGuideID then
		return false
	end
end

--检查是否全部地图已通过 LYP
function Class_Hero:checkMapEctypeFirstFinished()
    local instance = g_WndMgr:getWnd("Game_EctypeList")
	return instance and g_Hero:getIsMapFirstFinish()	
end

--该接口在每一个等级都会触发一次
function Class_Hero:onLevelUpEeveryStep(nMasterLevel)

end

function Class_Hero:onLevelUpEndCall()
	if g_PlayerGuide:checkCurrentGuideSequenceNode("OnUpdateExp", "Game_HeroLevelUpAnimation") then
		g_PlayerGuide:showCurrentGuideSequenceNode()
	end
	
	local tbCardTarget = g_Hero:getBattleCardByIndex(1)
	if tbCardTarget.funcBattleResultEndCall then
		tbCardTarget.funcBattleResultEndCall()
		tbCardTarget.funcBattleResultEndCall = nil
	end
end

--该事件只会在最终等级触发一次
function Class_Hero:showLevelUpAnimation(nOldLevel, bIsLevelUp, nNewlevel) --bIsNotLevelUp 在未升级时播放通关动画
	if bIsLevelUp then --有升级
		if self:checkMapEctypeFirstFinished() then --有升级、有通关
			if g_CheckIsHaveOpenFunc(nNewlevel) then --有升级、有通关、有功能开启
				local function funcLevelUpAniEndCall()
					if nNewlevel >= 8 then --有升级、有通关、有功能开启、无引导
						local function funcTaskAniEndCall()
							local wndInstance = g_WndMgr:getWnd("Game_EctypeList")
							if wndInstance then
								local function wndCloseEndCall()
									g_ShowFunctionOpenAnimtionByLevel(nNewlevel, self.onLevelUpEndCall)
								end
								g_WndMgr:closeWnd("Game_EctypeList", wndCloseEndCall)
							else
								g_ShowFunctionOpenAnimtionByLevel(nNewlevel, self.onLevelUpEndCall)
							end
						end
						g_ShowTaskFinishedEventAnimation(nil, funcTaskAniEndCall)
					else --有升级、有通关、有功能开启、有引导
						g_ShowTaskFinishedEventAnimation(nil, self.onLevelUpEndCall)
					end
				end
				g_ParamsHeroLevelUp = {
					Level_Source = nOldLevel,
					funcEndCallBack = funcLevelUpAniEndCall,
				}
				g_ShowHeroLevelUpAnimation(g_ParamsHeroLevelUp)
			else --有升级、有通关、无功能开启
				local function funcLevelUpAniEndCall()
					if nNewlevel >= 8 then --有升级、有通关、无功能开启、无引导
						local function funcTaskAniEndCall()
							local wndInstance = g_WndMgr:getWnd("Game_EctypeList")
							if wndInstance then
								g_WndMgr:closeWnd("Game_EctypeList", self.onLevelUpEndCall)
							else
								self:onLevelUpEndCall()
							end
						end
						g_ShowTaskFinishedEventAnimation(nil, funcTaskAniEndCall)
					else --有升级、有通关、无功能开启、有引导
						g_ShowTaskFinishedEventAnimation(nil, self.onLevelUpEndCall)
					end
				end
				g_ParamsHeroLevelUp = {
					Level_Source = nOldLevel,
					funcEndCallBack = funcLevelUpAniEndCall,
				}
				g_ShowHeroLevelUpAnimation(g_ParamsHeroLevelUp)
			end
		else --有升级、无通关
			if g_CheckIsHaveOpenFunc(nNewlevel) then --有升级、无通关、有功能开启
				if nNewlevel >= 8 then --有升级、无通关、有功能开启、无引导
					local function funcUpdateAniEnd()
						g_ShowFunctionOpenAnimtionByLevel(nNewlevel, self.onLevelUpEndCall)
					end
					g_ParamsHeroLevelUp = {
						Level_Source = nOldLevel,
						funcEndCallBack = funcUpdateAniEnd,
					}
					g_ShowHeroLevelUpAnimation(g_ParamsHeroLevelUp)
				else --有升级、无通关、有功能开启、有引导
					g_ParamsHeroLevelUp = {
						Level_Source = nOldLevel,
						funcEndCallBack = self.onLevelUpEndCall,
					}
					g_ShowHeroLevelUpAnimation(g_ParamsHeroLevelUp)
				end
			else --有升级、无通关、无功能开启

				g_ParamsHeroLevelUp = {
					Level_Source = nOldLevel,
					funcEndCallBack = self.onLevelUpEndCall,
				}
				g_ShowHeroLevelUpAnimation(g_ParamsHeroLevelUp)
			end
		end
	else --无升级
		if self:checkMapEctypeFirstFinished() then --无升级、有通关
			local function funcTaskAniEndCall()
				if nNewlevel >= 8 then --无升级、有通关、无引导
					local wndInstance = g_WndMgr:getWnd("Game_EctypeList")
					if wndInstance then
						g_WndMgr:closeWnd("Game_EctypeList", self.onLevelUpEndCall)
					else
						self:onLevelUpEndCall()
					end
				else --无升级、有通关、有引导
					self:onLevelUpEndCall()
				end
			end
			g_ShowTaskFinishedEventAnimation(nil, funcTaskAniEndCall)
		else -- 无升级、无通关
			self:onLevelUpEndCall()
		end
	end
end

--角色更新时触发的一些数据层逻辑
function Class_Hero:onLevelUpEvent(nNewlevel)
	self:sortAssistantCsvIdList()
end

function Class_Hero:ctor()
	self.tbDailyNotice = {}
	self.tbSoulList = {}
	self.tbItemList = {}
	self.nSoulListCount = 0
	self.tbFirstOpSate = {}
	self.tbFateItem = {}
	self.tbFateUnDressed = {}
	self.tbCountUnDressedInType = {}
	self.CardList =  {}
	self.tbHasSummonBattleCardList = {}
	self.tbEquipList = {}
	self.tbHunPoList = {}
	self.nItemLisCount = 0
	self.tbCardBattleList = {}
	self.tbZhenFaList = {}
	self.tbXinFaList = {}
	self.tbZhanShuList = {}
	self.tbEctypeStars = {} --副本过关星级情况
    self.tbBigMapRequest = {} --副本过关星级情况
    self.nContinuousLoginDate = 0 --连续登入数据记录
end

---玩家所有游戏数据
g_Hero = Class_Hero.new()