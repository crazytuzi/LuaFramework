local CLoginRewardCtrl = class("CLoginRewardCtrl", CCtrlBase)

CLoginRewardCtrl.BREED_MAX = 1500
CLoginRewardCtrl.BREED_INTERVAL = 210

function CLoginRewardCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_LoginRewardInfo = {}
	self.m_LoginDay = nil
	IOTools.SetRoleData("autoshow_loginreward", false)
	g_AttrCtrl:AddCtrlEvent("CLoginRewardCtrl", callback(self, "OnAttrEvent"))
end

function CLoginRewardCtrl.OnAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		if oCtrl.m_EventData["dAttr"]["grade"] then
			self:CheckAutoOpen()
		end
	end
end

--~table.print(g_LoginRewardCtrl.m_LoginRewardInfo)
function CLoginRewardCtrl.RefreshLoginRewardInfo(self, login_day, rewarded_day, breed_val, breed_rwd)
	self.m_LoginRewardInfo = {
		login_day = login_day,
		rewarded_day = rewarded_day,
		isday2 = MathBit.andOp(rewarded_day, 2) == 0,
		isday7 = MathBit.andOp(rewarded_day, 64) == 0,
		breed_val = breed_val,
		breed_rwd = breed_rwd,
	}
	
	self:CheckAutoOpen()
	self:OnEvent(define.LoginReward.Event.LoginReward)
end

function CLoginRewardCtrl.RefreshLoginRewardDay(self, rewarded_day)
	self.m_LoginRewardInfo.rewarded_day = rewarded_day
	self:OnEvent(define.LoginReward.Event.LoginReward)
end

function CLoginRewardCtrl.CheckAutoOpen(self)
	self:CheckUpdateDay()
	local bRoleData = not IOTools.GetRoleData("autoshow_loginreward")
	local bOpen = (g_LoginRewardCtrl:IsHasLoginReward() and
		g_ActivityCtrl:IsActivityVisibleBlock("loginreward") and
		g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.loginreward.open_grade and 
		data.globalcontroldata.GLOBAL_CONTROL.loginreward.is_open == "y" )
	local bHasGet = self:HasCanGetReward()
	local bIllegalView = not self:HadIllegalView()
	local mainMenuView = CMainMenuView:GetView()
	local bMainMenu = mainMenuView and mainMenuView:GetActive()
	local bWar = not g_WarCtrl:IsWar()

	local b = bRoleData and bOpen and bHasGet and bIllegalView and bMainMenu and bWar
	local bTimer = bRoleData and bOpen and bHasGet

	--printc(bRoleData, bOpen, bHasGet, bIllegalView, bMainMenu)
	if b then
		self.m_LoginDay = self.m_LoginRewardInfo.login_day
		IOTools.SetRoleData("autoshow_loginreward", true)
		if self.m_AutoTimer then
			Utils.DelTimer(self.m_AutoTimer)
			self.m_AutoTimer = nil
		end
		local function logincallback()
			if not self:HadIllegalView() then
				CLoginRewardView:ShowView()
			--else
			--	self:CheckAutoOpen()
			end
		end
		g_ViewCtrl:AddLoginCallBack("CLoginRewardView", logincallback)
	elseif bTimer then
		if not self.m_AutoTimer then
			self.m_AutoTimer = Utils.AddTimer(callback(self, "CheckAutoOpen"), 0.1, 0.1)
		end
		return true
	end
end

function CLoginRewardCtrl.CheckUpdateDay(self)
	if self.m_LoginRewardInfo.login_day and self.m_LoginDay ~= self.m_LoginRewardInfo.login_day then
		self.m_LoginDay = self.m_LoginRewardInfo.login_day
		IOTools.SetRoleData("autoshow_loginreward", false)
	end
end

function CLoginRewardCtrl.HadIllegalView(self)
	local IllegalView = {
		"CGuideView", "COrgMainView", "CLuckyDrawView", "CTreasureNormalView", "CHouseMainView",
		"CChapterFuBenMainView", "CEquipFubenMainView", "CWelfareView",
	}
	local views = g_ViewCtrl:GetViews()
	for i,cls in ipairs(IllegalView) do
		if views[cls] then
			return true
		end
	end
	return false
end

function CLoginRewardCtrl.GetLoginRewardInfo(self)
	return self.m_LoginRewardInfo
end

function CLoginRewardCtrl.IsLoginRewardToday(self)
	local info  = self:GetLoginRewardInfo()
	if info and info.rewarded_day and info.login_day then
		return MathBit.andOp(info.rewarded_day, 2 ^ (info.login_day-1)) == 0
	end
	--没数据默认今天已领取
	return false
end

--还有奖励没有领取但是不一定可以领取
function CLoginRewardCtrl.IsHasLoginReward(self)
	local b = false
	local info = self:GetLoginRewardInfo()
	if info and info.rewarded_day then
		local flag = 0
		for i=1,15 do
			flag = 2 ^ i - 1
			if MathBit.andOp(info.rewarded_day, flag) ~= flag then
				--有奖励没领取
				b = true
				break 
			end
		end
	end
	if not b then
		b = not info.breed_rwd or info.breed_rwd == 0
	end
	--没数据默认全部数据已领取
	return b
end

--有奖励可以领取但是没领取
function CLoginRewardCtrl.HasCanGetReward(self)
	local b = false
	local info = self:GetLoginRewardInfo()
	if info and info.rewarded_day then
		local dData = data.loginrewarddata.Reward
		for i,v in ipairs(dData) do
			local bNotTime = i > info.login_day
			local bGet = MathBit.andOp(info.rewarded_day, 2 ^ (i-1)) == 0 --0是没有领取，1是已领取
			if not bNotTime and bGet then
				b = true
				break
			end
		end
		if not b then
			b = info.breed_val and info.breed_val >= CLoginRewardCtrl.BREED_MAX and 
			    info.breed_rwd and info.breed_rwd ~= 1 --孵化奖励没领取
		end
	end
	return b
end
--~g_LoginRewardCtrl:OpenNextView(8)
function CLoginRewardCtrl.OpenNextView(self, next_day)
	if self.m_NextViewTimer then
		Utils.DelTimer(self.m_NextViewTimer)
		self.m_NextViewTimer = nil
	end
	local function cb()
		CLoginRewardView:CloseView()
		CLoginRewardNextView:ShowView(function (oView)
			oView:SetNextDay(next_day)
		end)
	end 
	local function delay()
		local oView = CItemRewardListView:GetView()
		if oView then
			oView:SetTweenCompleteCB(cb)
			return false
		end
		return true
	end
	self.m_NextViewTimer = Utils.AddTimer(delay, 0.1, 0.1)
end

return CLoginRewardCtrl