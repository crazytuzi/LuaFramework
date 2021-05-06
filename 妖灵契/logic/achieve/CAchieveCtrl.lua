local CAchieveCtrl = class("CAchieveCtrl", CCtrlBase)

define.Achieve = {
	Status = {
		--0-未完成　1-完成　2-领完了奖励
		UnFinished = 0 ,
		Finishing  = 1,
		Finished   = 2,
	},
	Event = {
		AchieveDone = 1,
		RedDot = 2,
		AchieveDegree = 3,
		Refresh = 4,
	},
}

function CAchieveCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:ResetCtrl()
end

function CAchieveCtrl.ResetCtrl(self)
	self.m_AchieveRedDot = nil
	self.m_CurPoint = nil	--当前总成就点
	self.m_CurRewardIdx = nil	--当前成就点奖励索引
	self.m_AlreadyGet = {}	--已领取成就点奖励
	self.m_DirectionInfo = {} -- 成就大类信息(大类id,大类进度)
	self.m_AchieveList = {} --成就信息
	self.m_IsAllRewardGet = false
	self.m_ForceSelect = nil
	self.m_CopyAchieveReward = table.copy(data.achievedata.REWARDPOINT)
end

function CAchieveCtrl.ForceShow(self, iDirection, iBelong)
	self.m_ForceSelect = {
		iDirection = iDirection,
		iBelong = iBelong,
	}
	self:C2GSAchieveMain()
end

function CAchieveCtrl.ShowConnect(self)
	g_NotifyCtrl:ShowConnect()
end

function CAchieveCtrl.C2GSAchieveMain(self, cb)
	if not g_LoginCtrl:HasLoginRole() then
		return
	end
	netachieve.C2GSAchieveMain()
end

function CAchieveCtrl.C2GSAchieveDirection(self, iDirection, iBelong)
	netachieve.C2GSAchieveDirection(iDirection, iBelong)
end

function CAchieveCtrl.C2GSAchieveReward(self, iAchieve)
	netachieve.C2GSAchieveReward(iAchieve)
end

function CAchieveCtrl.C2GSAchievePointReward(self, idx)
	netachieve.C2GSAchievePointReward(idx)
end

function CAchieveCtrl.SetCurPoint(self, cur_point)
	self.m_CurPoint = cur_point or 0
end

function CAchieveCtrl.GetCurPoint(self)
	return self.m_CurPoint 
end

function CAchieveCtrl.SetDirectionInfo(self, directions)
	for i,v in ipairs(directions) do
		self.m_DirectionInfo[v.id] = v
	end
end

function CAchieveCtrl.GetDirectionInfo(self)
	return self.m_DirectionInfo
end

function CAchieveCtrl.GetCopyAchieveReward(self)
	return self.m_CopyAchieveReward
end

function CAchieveCtrl.SetCurRewardIdx(self, already_get)
	self.m_CurRewardIdx = self.m_CurRewardIdx or 1
	self.m_AlreadyGet = already_get
	if already_get and #already_get > 0 then
		local lrewardpoint = self.m_CopyAchieveReward
		for i,v in ipairs(already_get) do
			lrewardpoint[v].get = true
		end
		for i,v in ipairs(lrewardpoint) do
			self.m_CurRewardIdx = i
			if not v.get then 
				self.m_CurRewardIdx = i
				return
			end
		end
		self.m_IsAllRewardGet = true
	end
end

function CAchieveCtrl.IsAllRewardGet(self)
	return self.m_IsAllRewardGet
end

function CAchieveCtrl.GetCurRewardIdx(self)
	return self.m_CurRewardIdx
end

function CAchieveCtrl.OpenAchieveMain(self, directions, cur_point, already_get)
	self:SetCurPoint(cur_point)
	self:SetDirectionInfo(directions)
	self:SetCurRewardIdx(already_get)
	local oView = CAchieveMainView:GetView()
	if oView then
		oView:RefreshAchieveSlider()
		if self.m_ForceSelect then
			oView:DefaultSelect(self.m_ForceSelect.iDirection, self.m_ForceSelect.iBelong)
			self.m_ForceSelect = nil
		else
			oView:DefaultSelect()
		end
	else
		CAchieveMainView:ShowView(function (oView)
			oView:RefreshAchieveSlider()
			if self.m_ForceSelect then
				oView:DefaultSelect(self.m_ForceSelect.iDirection, self.m_ForceSelect.iBelong)
				self.m_ForceSelect = nil
			else
				oView:DefaultSelect()
			end
		end)
	end
end

function CAchieveCtrl.OpenAchieveDirection(self, iDirection, iBelong, achlist)
	self:UpdateAchieveList(achlist)
	local oView = CAchieveMainView:GetView()
	if oView then
		oView:RefreshAchieveInfo(achlist)
	end
end

function CAchieveCtrl.UpdateAchieveList(self, achlist)
	for i,dAchieve in ipairs(achlist) do
		self.m_AchieveList[dAchieve.id] = dAchieve
	end
end

function CAchieveCtrl.OpenAchieveTips(self, iAchieve)
	CAchieveFinishTipsView:ShowView(function (oView)
		oView:SetAchieve(iAchieve)
	end)
end

function CAchieveCtrl.CacheOpenAchieveTips(self, cb)
	if g_AttrCtrl.grade < data.globalcontroldata.GLOBAL_CONTROL.achieve.open_grade then
		return
	end
	self.m_AchieveTipsCB = cb
end

function CAchieveCtrl.AchieveDone(self, pbdata)
	--printc("有新的成就完成:", pbdata.id)
	local id = pbdata.id
	local bPop = pbdata.pop
	self:ForceDoneAchieve(id)
	if bPop then
		g_ViewCtrl:DontDestroyOnCloseAll("CAchieveFinishTipsView", true)
		self:CacheOpenAchieveTips(callback(self, "OpenAchieveTips", id))
	end
	self:CheckShowAchieveTips()
	self:OnEvent(define.Achieve.Event.AchieveDone, pbdata)
end

function CAchieveCtrl.CheckShowAchieveTips(self)
	if self.m_AchieveTipsCB then
		if  g_WarCtrl:IsWar() or 
			self:HadIllegalView() then
			return false
		end
		self.m_AchieveTipsCB()
		self.m_AchieveTipsCB = nil
		return true
	end
end

function CAchieveCtrl.HadIllegalView(self)
	local IllegalView = {"COrgMainView", "CLuckyDrawView", "CTreasureNormalView", "CHouseMainView"}
	local views = g_ViewCtrl:GetViews()
	for i,cls in ipairs(IllegalView) do
		if views[cls] then
			return true
		end
	end
end

--客户端强制完成Achieve
function CAchieveCtrl.ForceDoneAchieve(self, iAchieve)
	local dAchieve = data.achievedata.ACHIEVE[iAchieve]
	self.m_AchieveList[dAchieve.id] = {
		id = dAchieve.id,
		cur = dAchieve.condition,
		done = define.Achieve.Status.Finishing,
	}
end

function CAchieveCtrl.AchieveDegree(self, info)
	self:OnEvent(define.Achieve.Event.AchieveDegree, info)
end


function CAchieveCtrl.CheckAchieveRedDot(self)
	for k,achlist in pairs(self.m_AchieveList) do
		for i,dAchieve in ipairs(achlist) do
			if dAchieve.done and dAchieve.done == define.Achieve.Status.Finishing then
				return true
			end
		end
	end
end

function CAchieveCtrl.SetAchieveRedDot(self, infolist)
	if #infolist > 0 then
		self.m_AchieveRedDot = table.list2dict(infolist, "id")
	else
		self.m_AchieveRedDot = nil
	end
	self:OnEvent(define.Achieve.Event.RedDot)
end

function CAchieveCtrl.HasAchieveRedDot(self)
	if g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.achieve.open_grade then
		return self.m_AchieveRedDot ~= nil
	else
		return false
	end
end

function CAchieveCtrl.GetAchieveRedDot(self)
	return self.m_AchieveRedDot
end

return CAchieveCtrl