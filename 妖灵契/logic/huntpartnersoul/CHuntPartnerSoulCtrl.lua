local CHuntPartnerSoulCtrl = class("CHuntPartnerSoulCtrl", CCtrlBase)

function CHuntPartnerSoulCtrl.ctor(self)
    CCtrlBase.ctor(self)
    self:ResetCtrl()
end

function CHuntPartnerSoulCtrl.ResetCtrl(self)
	self.m_SoulList = {}
	self.m_NpcList = {}
	self.m_RefreshTime = {}
	self:DelTimer()
end

function CHuntPartnerSoulCtrl.UpdateHuntInfo(self, oInfo)
	self.m_SoulList = {}
	for i,v in ipairs(oInfo.soulinfo) do
		table.insert(self.m_SoulList, v)
	end
	
	self.m_NpcList = {}
	for i,v in ipairs(oInfo.npcinfo) do
		self.m_NpcList[v.level] = v.status == 1
	end
	
	self.m_RefreshTime = {}
	for i,v in ipairs(oInfo.freeinfo) do
		self.m_RefreshTime[v.level] = v.last_freetime + 86400
	end
	local iNextTime = self:GetRefreshTime()
	if iNextTime > 0 then
		self:DelTimer()
		self.m_RefreshTimerID = Utils.AddTimer(function ()
			self:OnEvent(define.HuntPartnerSoul.Event.OnUpdateTime)
		end, 0, iNextTime)
	end
	self:OnEvent(define.HuntPartnerSoul.Event.UpdateHuntInfo)
end

function CHuntPartnerSoulCtrl.DelTimer(self)
	if self.m_RefreshTimerID then
		Utils.DelTimer(self.m_RefreshTimerID)
		self.m_RefreshTimer = nil
	end
end

function CHuntPartnerSoulCtrl.GetSoulList(self)
	return self.m_SoulList
end

function CHuntPartnerSoulCtrl.GetNpcList(self)
	return self.m_NpcList
end

function CHuntPartnerSoulCtrl.OneKeySale(self)
	for i,v in ipairs(self.m_SoulList) do
		if v.type == 2 then
			nethuodong.C2GSSaleSoulByOneKey()
			return true
		end
	end
	return false
end

function CHuntPartnerSoulCtrl.OneKeyPick(self)
	for i,v in ipairs(self.m_SoulList) do
		if v.type == 1 then
			nethuodong.C2GSPickUpSoulByOneKey()
			return true
		end
	end
	g_NotifyCtrl:FloatMsg("当前列表未发现可拾取的御灵")
	return false
end

function CHuntPartnerSoulCtrl.OpenHuntView(self)
	local oControlData = data.globalcontroldata.GLOBAL_CONTROL.huntpartnersoul
	if oControlData.is_open == "n" then
		g_NotifyCtrl:FloatMsg("该功能正在维护，已临时关闭，请您留意官网相关信息。")
		return
	elseif oControlData.open_grade > g_AttrCtrl.grade then
		g_NotifyCtrl:FloatMsg(string.format("%s级开启猎灵", oControlData.open_grade))
		return
	end
	CHuntPartnerSoulView:ShowView()
end

function CHuntPartnerSoulCtrl.GetRefreshTime(self)
	local iTime = (self.m_RefreshTime[4] or 0) - g_TimeCtrl:GetTimeS()
	if iTime < 0 then
		iTime = 0
	end
	return iTime
end

function CHuntPartnerSoulCtrl.HasRedDot(self)
	return self:GetRefreshTime() <= 0
end

function CHuntPartnerSoulCtrl.Hunt(self, iLevel)
	if self.m_NpcList[iLevel] then
		nethuodong.C2GSHuntSoul(iLevel)
	else
		printc(string.format("iLevel %s不存在", iLevel))
		self:OnEvent(define.HuntPartnerSoul.Event.UpdateHuntInfo)
	end
end

function CHuntPartnerSoulCtrl.OnAddPartnerSoul(self, oSoul)
	table.insert(self.m_SoulList, oSoul)
	self:OnEvent(define.HuntPartnerSoul.Event.OnAddPartnerSoul)
end

function CHuntPartnerSoulCtrl.OnDelPartnerSoul(self, lSoulID)
	for k,v in pairs(lSoulID) do
		for i,oSoul in ipairs(self.m_SoulList) do
			if v == oSoul.createtime then
				table.remove(self.m_SoulList, i)
				break
			end
		end
	end
	self:OnEvent(define.HuntPartnerSoul.Event.OnDelPartnerSoul)
end

function CHuntPartnerSoulCtrl.UpdateNpc(self, iLevel, iNextActive)
	if iLevel ~= 1 then
		self.m_NpcList[iLevel] = false
	end
	if iNextActive == 1 and iLevel + 1 <= #data.huntdata.DATA then
		self.m_NpcList[iLevel + 1] = true
	end
	self:OnEvent(define.HuntPartnerSoul.Event.UpdateNpc)
end

function CHuntPartnerSoulCtrl.IsAutoSell(self)
	return g_AttrCtrl.systemsetting.huntsetting.auto_sale == 1
end

return CHuntPartnerSoulCtrl