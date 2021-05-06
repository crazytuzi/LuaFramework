local CConvoyCtrl = class("CConvoyCtrl", CCtrlBase)

function CConvoyCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:ResetCtrl()
end

function CConvoyCtrl.ResetCtrl(self)
	self.m_Status = 0
	self.m_ConvoyPartner = 0
	self.m_TargetNpc = 0
	self.m_EndTime = 0
	self.m_SelectedPos = 1
	self.m_PoolInfoDic = {}
	self.m_RefreshCost = 0
	self.m_ViewRandomIdx = 1
	self.m_RefreshCnt = 0
	self.m_FreeTime = 0
	self.m_LastStatus = 0
	self:OnEvent(define.Convoy.Event.UpdateConvoyInfo)
end

function CConvoyCtrl.SendRefresh(self)
	nethuodong.C2GSRefreshTarget()
end

function CConvoyCtrl.GetRefreshCost(self)
	return self.m_RefreshCost
end

function CConvoyCtrl.IsConvoying(self)
	return self.m_Status == 1
end

function CConvoyCtrl.GetFreeRefreshCnt(self)
	return self.m_FreeTime
end

function CConvoyCtrl.GetCurrentLv(self)
	return self.m_SelectedPos
end

function CConvoyCtrl.IsMaxLv(self)
	return self.m_SelectedPos >= #data.convoydata.ConvoyPool
end

function CConvoyCtrl.AcceptTask(self)
	nethuodong.C2GSStarConvoy()
end

function CConvoyCtrl.GiveUp(self)
	nethuodong.C2GSGiveUpConvoy()
end

function CConvoyCtrl.GetViewTalkText(self)
	return data.convoydata.RandomTalk[self.m_ViewRandomIdx].content
end

function CConvoyCtrl.GetConvoyPartnerType(self)
	return self.m_ConvoyPartner
end

function CConvoyCtrl.GetRestTime(self)
	return self.m_EndTime - g_TimeCtrl:GetTimeS()
end

function CConvoyCtrl.UpdateConvoyInfo(self, convoyinfo)
	-- printc("UpdateConvoyInfo")
	local tempLv = self.m_SelectedPos
	self.m_LastStatus = self.m_Status
	self.m_Status = convoyinfo.status
	self.m_ConvoyPartner = convoyinfo.convoy_partner
	self.m_TargetNpc = convoyinfo.target_npc
	self.m_EndTime = convoyinfo.end_time
	self.m_SelectedPos = convoyinfo.selected_pos
	if self.m_SelectedPos < 1 then
		self.m_SelectedPos = 1
	end
	self.m_PoolInfoDic = {}
	for k,v in pairs(convoyinfo.pool_info) do
		self.m_PoolInfoDic[v.pos] = v
	end
	self.m_RefreshCost = convoyinfo.refresh_cost
	self.m_RefreshCnt = convoyinfo.refresh_time
	self.m_FreeTime = convoyinfo.free_time
	if tempLv ~= self.m_SelectedPos then
		local randomList = data.convoydata.FollowTalk[self.m_PoolInfoDic[self.m_SelectedPos].partnerid]
		if randomList and #randomList.ui_talk > 0 then
			self.m_ViewRandomIdx = randomList.ui_talk[Utils.RandomInt(1, #randomList.ui_talk)]
		else
			self.m_ViewRandomIdx = 1
		end
	end
	self:BeginConvoy()
	self:OnEvent(define.Convoy.Event.UpdateConvoyInfo)
end

function CConvoyCtrl.GetShapeByPos(self, iPos)
	if self.m_PoolInfoDic[iPos] and self.m_PoolInfoDic[iPos].partnerid and data.convoydata.FollowTalk[self.m_PoolInfoDic[iPos].partnerid].shape then
		return data.convoydata.FollowTalk[self.m_PoolInfoDic[iPos].partnerid].shape
	end
	return 301
end

function CConvoyCtrl.CheckModel(self)
	if self.m_LastStatus == 1 and self.m_Status == 0 then
		self.m_LastStatus = 0
		g_MapCtrl:DelAllFollowWalker()
		for j,c in pairs(g_AttrCtrl.followers) do
			g_MapCtrl:AddFollowPartner(c)
		end
		local oHero = g_MapCtrl:GetHero()
		if oHero then
			oHero:StopWalk()
		end
		g_TaskCtrl:SetRecordLogic(nil)
	elseif self.m_Status == 1 then
		if not g_WarCtrl:IsWar() then
			CConvoyingView:ShowView()
		end
		local partnerData = data.convoydata.FollowTalk[self.m_ConvoyPartner]
		if partnerData then
			g_MapCtrl:DelAllFollowWalker()
			local partnerInfo = {
				name = partnerData.name,
				model_info = {
					shape = partnerData.shape,
				},
			}
			g_MapCtrl:AddFollowPartner(partnerInfo)
			local oFollower = g_MapCtrl:GetHeroFollower(self.m_ConvoyPartner)
			if oFollower then
				local talkList = {}
				for k,v in pairs(data.convoydata.FollowTalk[self.m_ConvoyPartner].content) do
					table.insert(talkList, data.convoydata.TalkContent[v].content)
				end
				oFollower:SetRandomTalkData(talkList, 5, 10)
			end
		else
			printc("data.convoydata.FollowTalk不存在id： " .. self.m_ConvoyPartner)
		end
	end
end

function CConvoyCtrl.BeginConvoy(self)
	-- printc("BeginConvoy")
	self:CheckModel()
	if self.m_Timer == nil then
		self.m_Timer = Utils.AddTimer(callback(self, "UpdateConvoy"), 1, 0)
	end
end

function CConvoyCtrl.UpdateConvoy(self)
	-- printc("UpdateConvoy")
	if not self:IsConvoying() then
		self:DelTimer()
		return false
	end
	if g_WarCtrl:IsWar() then
		return true
	end
	local oHero = g_MapCtrl:GetHero()
	if oHero and not oHero:IsWalking() then
		if not g_MapCtrl:IsLoading() then
			local taskData = 
			{
				acceptnpc = self.m_TargetNpc,
				autotype = 0,
			}
			local oTask = CTask.NewByData(taskData)
			g_TaskCtrl:ClickTaskLogic(oTask)
		end
	end
	return true
end

function CConvoyCtrl.DelTimer(self)
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil
	end
end

function CConvoyCtrl.GetTargetData(self)
	return data.npcdata.NPC.GLOBAL_NPC[self.m_TargetNpc]
end

function CConvoyCtrl.GetRewardData(self, iLv)
	local oData = data.convoydata.ConvoyPool[iLv]
	return oData
end

function CConvoyCtrl.ShowWarResult(self, oCmd)
	CWarResultView:ShowView(function(oView)
		oView:SetWarID(oCmd.war_id)
		oView:SetWin(oCmd.win)
		oView:SetDelayCloseView()
	end)
end

return CConvoyCtrl