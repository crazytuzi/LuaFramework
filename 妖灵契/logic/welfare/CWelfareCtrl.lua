local CWelfareCtrl = class("CWelfareCtrl", CCtrlBase)

function CWelfareCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:ResetCtrl()
end

function CWelfareCtrl.ResetCtrl(self)
	self.m_SecondTest = 0
	self.m_HistoryChargeDegree = 0
	self.m_HistoryGotList = {}
	self.m_SecondTestDay = 0
	self.m_CzjjData = {} --成长基金
	self.m_YiYuanLiBaoInfo = {}
	self.m_YueKaData = {
		--yk={type="yk", val=1, left_count = 10},
		--zsk={type="zsk", val=1, left_count = 10},
	} --月卡信息
	self.m_TotalLockSkin = false
	self:InitDailySign()
	self:InitSevenDayTarget()
	self:InitRewardBack()
	self:InitLimit()
	self:InitFreeEnergy()
	self.m_YuekaRedDot = true
	self:InitFirstCharge()
	self:InitChargeScore()
	self:InitChargeBack()
	self:InitRechargeWelfare()
	self:InitRushRecharge()
	self:ResetLoopPayInfo()
	self:ResetLimitPay()
	self:ResetTestWelfare()
	self:InitYiYuanLiBao()
	self:ResetCostScore()
	self:InitRankBack()
	self:InitCostSaveTime()
	self:InitCostSaveGold()
end

function CWelfareCtrl.UpdateDay(self)
	
end

function CWelfareCtrl.ForceSelect(self, idx)
	if main.g_AppType  == "shenhe" or data.welfaredata.WelfareControl[idx].open == 0 then
		g_NotifyCtrl:FloatMsg("该功能暂未开放")
		return
	end
	CWelfareView:ShowView(function (oView)
		oView:ForceSelect(idx)
	end)
end

function CWelfareCtrl.OnReceiveSecondTest(self, oData, iDay)
	-- printc("CWelfareCtrl.OnReceiveData: " .. oData)
	self.m_SecondTest = oData
	self.m_SecondTestDay = iDay
	if oData == 1 then
		if IOTools.GetRoleData("welfare_secondtest_finish") ~= true then
			IOTools.SetRoleData("welfare_secondtest", true)
		end
	else
		IOTools.SetRoleData("welfare_secondtest_finish", false)
	end
	self:OnEvent(define.Welfare.Event.OnChangeSecondTest)
end

function CWelfareCtrl.OnHistoryRecharge(self, degree, getlist)
	self.m_HistoryChargeDegree = degree
	self.m_HistoryGotList = {}
	for k,v in pairs(getlist) do
		self.m_HistoryGotList[v] = true
	end
	self:OnEvent(define.Welfare.Event.OnHistoryRecharge)
end

function CWelfareCtrl.TestFirstRedDot(self)
	IOTools.SetRoleData("welfare_secondtest_first")
	IOTools.SetRoleData("welfare_RechargeWelfare_first")
	IOTools.SetRoleData("welfare_totalRecharge_first")
end

function CWelfareCtrl.OnBackPartnerInfo(self, pid, partnerlist, star)
	self.m_BackPid = pid
	self.m_BackStar = star
	self.m_BackList = {}
	for k,v in pairs(partnerlist) do
		self.m_BackList[v.sid] = v.star
	end
	self:OnEvent(define.Welfare.Event.OnBackPartnerInfo)
end

function CWelfareCtrl.IsGotPartner(self, partnerType)
	return self.m_BackList[partnerType]
end

function CWelfareCtrl.IsSecondTestNeedRedDot(self)
	local b = true
	if self.m_BackPid and self.m_BackStar and self.m_BackPid ~= 0 and self.m_BackStar then
		b = false
	end
	-- if data.welfaredata.WelfareControl[define.Welfare.ID.SecondTest].open == 0 then
	-- 	return false
	-- end
	-- --未打开过
	-- if IOTools.GetRoleData("welfare_secondtest_first") ~= true then
	-- 	return true
	-- end
	--满足条件
	-- if IOTools.GetRoleData("welfare_secondtest") then
	-- 	return true
	-- end
	return b
end

function CWelfareCtrl.IsTotalRechargeNeedRedDot(self)
	if data.welfaredata.WelfareControl[define.Welfare.ID.TotalRecharge].open == 0 then
		return false
	end
	for k,v in pairs(data.welfaredata.TotalRecharge) do
		if v.open == 1 and self.m_HistoryChargeDegree >= v.condition and (not self.m_HistoryGotList[v.id]) then
			return true
		end
	end
	return false
end

function CWelfareCtrl.IsRechargeNeedRedDot(self)
	if data.welfaredata.WelfareControl[define.Welfare.ID.RechargeWelfare].open == 0 then
		return false
	end
	if IOTools.GetRoleData("welfare_RechargeWelfare_first") ~= true then
		return true
	end
	return false
end

function CWelfareCtrl.IsDailySignRedDot(self)
	if data.welfaredata.WelfareControl[define.Welfare.ID.DailySign].open == 0 then
		return false
	end
	local info = self:GetDailySignInfo()
	return info and info["week"] and not info["week"].is_sign
end

function CWelfareCtrl.IsZhaoMuBaoLiuNeedRedDot(self)
	if data.welfaredata.WelfareControl[define.Welfare.ID.ZhaoMuBaoLiu].open == 0 then
		return false
	end
	return false
end

function CWelfareCtrl.IsSevenDayTargetRedDot(self)
	if not self:IsOpenSevenDayTarget() then
		return false
	end
	return self:CheckSevenDayRedDot()
end

function CWelfareCtrl.IsNeedRedDot(self)
	--if self:IsSecondTestNeedRedDot() then
		-- printc("IsSecondTestNeedRedDot")
		--return true
	--end

	--if self:IsRechargeNeedRedDot() then
		-- printc("IsRechargeNeedRedDot")
	--	return true
	--end

	if self:IsCostSaveRedDot() then
		printc("IsCostSaveRedDot")
		return true
	end

	if self:IsDailySignRedDot() then
		-- printc("IsDailySignRedDot")
		return true
	end

	if self:IsZhaoMuBaoLiuNeedRedDot() then
		-- printc("IsZhaoMuBaoLiuNeedRedDot")
		return true
	end

	if self:IsSevenDayTargetRedDot() then
		-- printc("IsSevenDayTargetRedDot")
		return true
	end

	if self:IsCzjjRedDot() then
		return true
	end

	if self:IsYueKaRedDot() then
		return true
	end

	if self:IsFreeEnergyRedDot() then
		return true
	end

	if self:IsRewardBackRedDot() then
		return true
	end

	return false
end

--region每日签到部分
function CWelfareCtrl.InitDailySign(self)
	self.m_DailySignInfo = nil
end

function CWelfareCtrl.OnReceiveDailySign(self, signinfo)
	self.m_DailySignInfo = table.list2dict(signinfo, "key")
	self:OnEvent(define.Welfare.Event.OnDailySign)
end

function CWelfareCtrl.GetDailySignInfo(self)
	return self.m_DailySignInfo
end

--endregion每日签到部分

--region七日目标部分
function CWelfareCtrl.IsOpenSevenDayTarget(self)
	return self:GetSevenDayTargetEndTime() > 0
		and data.welfaredata.WelfareControl[define.Welfare.ID.SevenDayTarget].open == 1
		and data.globalcontroldata.GLOBAL_CONTROL.sevenday.is_open == "y"
		and g_AttrCtrl.grade >= tonumber(data.globalcontroldata.GLOBAL_CONTROL.sevenday.open_grade)
end

function CWelfareCtrl.GetSevenDayTargetEndTime(self)
	local info = self:GetSevenDayTargetInfo()
	local tCur = os.date("*t", g_TimeCtrl:GetTimeS())
	local todyIntervel = 86400 - ((tCur.hour * 60+ tCur.min) * 60 + tCur.sec)

	if info.server_day then
		local close_day = tonumber(data.globaldata.GLOBAL.sevenday_close.value)
		local intervel = (close_day - info.server_day) * 86400 + todyIntervel
		local end_time = intervel
		return end_time
	else
		return 0
	end
end

function CWelfareCtrl.AutoCheckSevenDayTarget(self)
	if self.m_SevenDayTimer then
		Utils.DelTimer(self.m_SevenDayTimer)
		self.m_SevenDayTimer = nil
	end
	local info = self:GetSevenDayTargetInfo()
	if info.close then
		return
	end 
	local end_time = self:GetSevenDayTargetEndTime()
	local function updatesec()
		if end_time <= 0 then
			self:CloseSevenDayTarget()
			return false
		end
		end_time = end_time - 1
		return true
	end
	self.m_SevenDayTimer = Utils.AddTimer(updatesec, 1, 0)
end

--客户端自行结束
--~g_WelfareCtrl:CloseSevenDayTarget()
function CWelfareCtrl.CloseSevenDayTarget(self)
	local info = self:GetSevenDayTargetInfo()
	local server_day = info.server_day or g_AttrCtrl.open_day or 0
	self:OnReceiveSevenDayMain(info.cur_point, info.already_get, server_day + 1, true)
end

function CWelfareCtrl.InitSevenDayTarget(self)
	self.m_SevenDayTargetInfo = {}
	self.m_SevenDayTargetRedDot = {}
	self.m_SevenDayBuy = {}
end

function CWelfareCtrl.GetSevenDayTargetInfo(self)
	return self.m_SevenDayTargetInfo
end

function CWelfareCtrl.GetSevenDayBuy(self)
	return self.m_SevenDayBuy
end

function CWelfareCtrl.GetSevenDayTargetRedDot(self)
	return self.m_SevenDayTargetRedDot
end

function CWelfareCtrl.CheckSevenDayRedDot(self)
	local bSever, bLocal
	bLocal = self:GetSevenDayTargetTodayRedDot()
	if self.m_SevenDayTargetRedDot then
		for i=1,7 do
			if table.index(self.m_SevenDayTargetRedDot, i) and self:GetSevenDayServerDay() + 1 >= i then
				bSever = true
				break
			end
		end
		--bSever = #self.m_SevenDayTargetRedDot > 0
	end
	--printc(bSever, bLocal, "七天目标红点")
	return bSever or bLocal or false
end

function CWelfareCtrl.SetSevenDayTargetTodayRedDot(self, bToday)
	g_WindowTipCtrl:SetTodayTip("sevendaytarget_todayreddot", bToday)
	self:OnEvent(define.Welfare.Event.OnSevenDayTargetRedDot)
end

function CWelfareCtrl.GetSevenDayTargetTodayRedDot(self, bToday)
	local notbuy = false --false:全部每日限购已购买
	local info = self:GetSevenDayBuy()
	local server_day = math.min(7,self:GetSevenDayServerDay())
	for i=1,server_day do --只有7天可以购买
		if not table.index(info, i) then
			notbuy = true
			break
		end
	end
	return g_WindowTipCtrl:IsShowTips("sevendaytarget_todayreddot") and notbuy
end

function CWelfareCtrl.GetSevenDayTargetPage(self)
	if main.g_AppType  == "shenhe" then
		g_NotifyCtrl:FloatMsg("该功能暂未开放")
		return
	end
	local oView = CWelfareView:GetView()
	if oView then
		local oPage = oView.m_SevenDayTargetPage
		if oPage and oPage == oView.m_CurPage then
			return oPage
		end
	end
	return
end

function CWelfareCtrl.OnReceiveSevenDayMain(self, cur_point, already_get, server_day, close)
	local old = table.copy(self.m_SevenDayTargetInfo)
	self.m_SevenDayTargetInfo =	{
		cur_point = cur_point or old.cur_point,
		already_get = already_get or old.already_get,
		server_day = server_day or old.server_day or 0,
		close = close,
	}
	self:OnEvent(define.Welfare.Event.OnSevenDayTarget)
	self:AutoCheckSevenDayTarget()
end

function CWelfareCtrl.GetSevenDayServerDay(self)
	local info = self:GetSevenDayTargetInfo()
	return info and info.server_day or 0
end

function CWelfareCtrl.OnReceiveSevenDayDegree(self, info)
	local oPage = self:GetSevenDayTargetPage()
	if oPage then
		oPage:RefreshTargetOne(info)
	end
end

function CWelfareCtrl.OnReceiveSevenDayInfo(self, day, achlist)
	local oPage = self:GetSevenDayTargetPage()
	if oPage then
		achlist = table.copy(achlist)
		oPage:RefreshTargetGrid(day, achlist)
	end
end

function CWelfareCtrl.OnReceiveSevenDayRedDot(self, days)
	self.m_SevenDayTargetRedDot = days
	self:OnEvent(define.Welfare.Event.OnSevenDayTargetRedDot)	
end

function CWelfareCtrl.OnReceiveSevenDayBuy(self, already_buy)
	self.m_SevenDayBuy = already_buy
	local oPage = self:GetSevenDayTargetPage()
	if oPage then
		oPage:RefreshDayBuyBox()
	end
end

--endregion七日目标部分

--region首冲奖励

function CWelfareCtrl.InitFirstCharge(self)
	self.m_IsOpenFirstCharge = nil
	self.m_IsReceiveFirstCharge = nil
end
--~printc(g_WelfareCtrl.m_IsOpenFirstCharge, g_WelfareCtrl.m_IsReceiveFirstCharge)
function CWelfareCtrl.SetFirstCharge(self, bOpen, bReceive)
	self.m_IsOpenFirstCharge = bOpen
	self.m_IsReceiveFirstCharge = bReceive
	self:OnEvent(define.Welfare.Event.OnFirstCharge)
end

function CWelfareCtrl.IsOpenNeiChong(self)
	return not self.m_IsOpenFirstCharge and not self.m_IsReceiveFirstCharge
end

function CWelfareCtrl.IsOpenFirstCharge(self)
	return self.m_IsOpenFirstCharge 
		and g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.firstcharge.open_grade 
		and data.globalcontroldata.GLOBAL_CONTROL.firstcharge.is_open == "y"
		and main.g_AppType  ~= "shenhe"
end

function CWelfareCtrl.IsFirstChargeRedDot(self)
	return self.m_IsReceiveFirstCharge
end

--判断特效
function CWelfareCtrl.IsFirstChargeEff(self)
	return self:GetFirstChargeEff()
end

function CWelfareCtrl.GetFirstChargeEff(self)
	return g_WindowTipCtrl:IsShowTips("firstchargeeff")
end

function CWelfareCtrl.SetFirstChargeEff(self, bToday)
	g_WindowTipCtrl:SetTodayTip("firstchargeeff", bToday)
	self:OnEvent(define.Welfare.Event.OnFirstCharge)
end

--endregion首冲奖励

--region奖励找回
function CWelfareCtrl.InitRewardBack(self)
	self.m_RewardBackInfo = {}
	self.m_OpenDay = nil
end

function CWelfareCtrl.OnReceiveRefreshRewardBack(self, info)
	self.m_RewardBackInfo = info
	self:CheckAutoOpenRewardBack()
	self:OnEvent(define.Welfare.Event.OnRewardBack)
end

function CWelfareCtrl.GetRewardBackInfo(self)
	return self.m_RewardBackInfo
end

function CWelfareCtrl.IsRewardBackRedDot(self)
	return self:HasRewardBackFree()
end

function CWelfareCtrl.HasRewardBackFree(self)
	local info = self.m_RewardBackInfo
	if info then
		for i,v in ipairs(info) do
			if v.free and v.free == 1 then
				return true
			end
		end
	end
	return false
end

--~table.print(g_WelfareCtrl.m_RewardBackInfo)
function CWelfareCtrl.IsOpenRewardBack(self)
	local info = self.m_RewardBackInfo
	return info and #info > 0
end

function CWelfareCtrl.CheckAutoOpenRewardBack(self)
	self:CheckUpdateDay()
	local bRoleData = not IOTools.GetRoleData("autoshow_welfare_rewardback")
	local bOpen = data.globalcontroldata.GLOBAL_CONTROL.welfare.is_open == "y" and 
			g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.welfare.open_grade and
			data.welfaredata.WelfareControl[define.Welfare.ID.RewardBack].open == 1 and
			self:HasRewardBackFree()
	local bWar = not g_WarCtrl:IsWar()
	local b = bRoleData and bOpen and bWar
	if b then
		IOTools.SetRoleData("autoshow_welfare_rewardback", true)
		local function logincallback()
			self:ForceSelect(define.Welfare.ID.RewardBack)
		end
		g_ViewCtrl:AddLoginCallBack("CWelfareView", logincallback)
	end
end

function CWelfareCtrl.CheckUpdateDay(self)
	if self.m_OpenDay ~= g_AttrCtrl.open_day then
		self.m_OpenDay = g_AttrCtrl.open_day
		IOTools.SetRoleData("autoshow_welfare_rewardback", false)
	end
end

--endregion奖励找回

--region成长基金
function CWelfareCtrl.SetCzjjData(self, k, v)
	self.m_CzjjData[k] = v
	self:OnEvent(define.Welfare.Event.OnCzjj, {key=k,value=v})
end

function CWelfareCtrl.GetCzjjData(self, k)
	return self.m_CzjjData[k]
end

function CWelfareCtrl.IsBuyCzjj(self)
	return self.m_CzjjData.buy_flag and (self.m_CzjjData.buy_flag > 0)
end

function CWelfareCtrl.IsGetCzjjReward(self, key)
	if self.m_CzjjData.get_flags then
		local v = self.m_CzjjData.get_flags[key]
		if v and v > 0 then
			return true
		end
	end
	return false
end

function CWelfareCtrl.IsCzjjFinish(self)
	if self:IsBuyCzjj() then
		for k, v in pairs(self.m_CzjjData.get_flags) do
			if v == 0 then
				return false
			end
		end
		return true
	end
	return false
end

function CWelfareCtrl.IsCzjjRedDot(self)
	local czjjData = data.chargedata.CZJJ_DATA
	if self:IsBuyCzjj() then
		if self.m_CzjjData.get_flags then
			for k,v in pairs(self.m_CzjjData.get_flags) do
				if v == 0 then
					if g_AttrCtrl.grade >= czjjData[k].grade then
						return true
					end
				end
			end
		end
	end
	return false
end
--endregion成长基金


--region月卡
function CWelfareCtrl.IsYueKaRedDot(self)
	if self:HasYueKa() and self:HasZhongShengKa() then
		return false
	end
	return self.m_YuekaRedDot
	-- for k, cardinfo in pairs(self.m_YueKaData)do
	-- 	if cardinfo.val == 1 then
	-- 		return true
	-- 	end
	-- end
	-- return false
end

--是否有月卡
function CWelfareCtrl.HasYueKa(self)
	local cardinfo = self.m_YueKaData["yk"]
	if cardinfo and cardinfo.val > 0 then
		return true
	end
	return false
end

--是否有终身卡
function CWelfareCtrl.HasZhongShengKa(self)
	local cardinfo = self.m_YueKaData["zsk"]
	if cardinfo and cardinfo.val > 0 then
		return true
	end
	return false
end

function CWelfareCtrl.SetYueKaData(self, type, v)
	self.m_YueKaData[type] = v
	self:OnEvent(define.Welfare.Event.OnYueKa, {key=type,value=v})
end

function CWelfareCtrl.GetYueKaData(self, type, k)
	local dData = self.m_YueKaData[type]
	if dData then
		return dData[k]
	end
end
--endregion月卡

--限时狂欢
function CWelfareCtrl.InitLimit(self)
	self.m_DrawCnt = 0
	self.m_IsNewDraw = false

	self.m_CostPoint = 0
	self.m_IsNewCostPoint = 1
	self.m_FirstOpenSkin = true
end

function CWelfareCtrl.IsOpenLimitReward(self)
	if data.welfaredata.WelfareControl[define.Welfare.ID.LimitReward].open == 1
		and g_AttrCtrl.grade >= tonumber(data.welfaredata.WelfareControl[define.Welfare.ID.LimitReward].grade) then
		return true
	else
		return false
	end
end

function CWelfareCtrl.UpdateDrawCnt(self, iCnt)
	self.m_DrawCnt = iCnt
	self:OnEvent(define.Welfare.Event.UpdateDrawCnt)
end

function CWelfareCtrl.IsNewLimitDraw(self)
	local iCnt = self.m_DrawCnt or 0
	return iCnt > 0
end

function CWelfareCtrl.UpdateCostPoint(self, iPoint)
	local iLastPoint = self.m_CostPoint or 0
	self.m_CostPoint = iPoint
	if iPoint - iLastPoint >= 125 then
		if g_LoginCtrl:IsFirstLoginToday() and self.m_IsNewCostPoint == 1 then
			self.m_IsNewCostPoint = 2
		end
		self:OnEvent(define.Welfare.Event.UpdateCostPoint)
	end
end

function CWelfareCtrl.IsNewCostPoint(self)
	return self.m_IsNewCostPoint == 2
end

function CWelfareCtrl.ClearNewCostPoint(self)
	self.m_IsNewCostPoint = 0
	self:OnEvent(define.Welfare.Event.UpdateCostPoint)
end

function CWelfareCtrl.IsFirstOpenSkin(self)
	return self.m_FirstOpenSkin
end

function CWelfareCtrl.ClearFirstOpenSkin(self)
	self.m_FirstOpenSkin = false
	self:OnEvent(define.Welfare.Event.UpdateCostPoint)
end

--endregion限时狂欢

--region免费体力
function CWelfareCtrl.InitFreeEnergy(self)
	self.m_EnergyReceive = 0 --体力领取记录
	self.m_FreeEnergyEvent = nil
end

function CWelfareCtrl.IsFreeEnergyRedDot(self)
	return self:IsZhongWuCanGet() or self:IsWanshangCanGet()
end

function CWelfareCtrl.IsZhongWuCanGet(self)
	if self.m_FreeEnergyEvent == define.Welfare.Event.OnFreeEnergyZhongwu then
		return MathBit.andOp(self.m_EnergyReceive, 1) ~= 1
	end
end

function CWelfareCtrl.IsWanshangCanGet(self)
	if self.m_FreeEnergyEvent == define.Welfare.Event.OnFreeEnergyWanshang then
		return MathBit.andOp(self.m_EnergyReceive, 2) ~= 2
	end
end

function CWelfareCtrl.IsFreeEnergyOpen(self)
	return true--self.m_FreeEnergyEvent ~= define.Welfare.Event.OnFreeEnergyClose
end

function CWelfareCtrl.OnReceiveFreeEnergy(self, info)
	local energy_receive = info.energy_receive or self.m_EnergyReceive or 0
	if energy_receive then
		self.m_EnergyReceive = energy_receive
		self.m_FreeEnergyEvent = nil
		self:AutoCheckFreeEnergy()
	end
end

function CWelfareCtrl.GetFreeEnergy(self)
	return self.m_EnergyReceive
end

function CWelfareCtrl.GetFreeEnergyEvent(self)
	return self.m_FreeEnergyEvent
end

function CWelfareCtrl.IsOpenChargeBack(self)
	return true
end

function CWelfareCtrl.IsChargeBackRedDot(self)
	return false
end

function CWelfareCtrl.IsCostSaveRedDot(self)
	local time = g_TimeCtrl:GetTimeS()
	return self:IsOpenCostSave() and self.m_CostSaveGetStatue == false and self.m_CostSaveGold ~= 0 and time > (self.m_CostSaveEndTime - 3600 * 24)
end

function CWelfareCtrl.IsOpenCostSave(self)
	local b = false
	local t = g_TimeCtrl:GetTimeS()	
	if self.m_CostSaveStartTime ~= 0 and self.m_CostSaveEndTime ~= 0 and t > self.m_CostSaveStartTime and t < self.m_CostSaveEndTime then
		b = true
	end
	return b
end

function CWelfareCtrl.AutoCheckFreeEnergy(self)
	if self.m_FreeEnergyTimer then
		Utils.DelTimer(self.m_FreeEnergyTimer)
		self.m_FreeEnergyTimer = nil
	end
	local iCur = g_TimeCtrl:GetTimeS()
	local tCur = os.date("*t", iCur)
	local zhongwu = {
		iopen = os.time({
			year=tCur.year, 
			month=tCur.month, 
			day=tCur.day, 
			hour=12, 
			min=0, 
			sec=0,
		}),
		iend = os.time({
			year=tCur.year, 
			month=tCur.month, 
			day=tCur.day, 
			hour=17, 
			min=30, 
			sec=0,
		}),
	} --12:00~17:30
	local wanshang = {
		iopen = os.time({
			year=tCur.year, 
			month=tCur.month, 
			day=tCur.day, 
			hour=18, 
			min=0, 
			sec=0,
		}),
		iend = os.time({
			year=tCur.year, 
			month=tCur.month, 
			day=tCur.day, 
			hour=22, 
			min=30, 
			sec=0,
		}),
	} --18:00~22:30
	
	local idx = 0
	local function updatesec()
		if idx == 600 then --10分钟校准一次服务器时间
			iCur = g_TimeCtrl:GetTimeS()
		end
		if iCur >= zhongwu.iopen and iCur <= zhongwu.iend then
			if self.m_FreeEnergyEvent ~= define.Welfare.Event.OnFreeEnergyZhongwu then
				self.m_FreeEnergyEvent = define.Welfare.Event.OnFreeEnergyZhongwu
				self:OnEvent(self.m_FreeEnergyEvent)
			end
		elseif iCur >= wanshang.iopen and iCur <= wanshang.iend then
			if self.m_FreeEnergyEvent ~= define.Welfare.Event.OnFreeEnergyWanshang then
				self.m_FreeEnergyEvent = define.Welfare.Event.OnFreeEnergyWanshang
				self:OnEvent(self.m_FreeEnergyEvent)
			end
		else
			if self.m_FreeEnergyEvent ~= define.Welfare.Event.OnFreeEnergyClose then
				self.m_FreeEnergyEvent = define.Welfare.Event.OnFreeEnergyClose
				self:OnEvent(self.m_FreeEnergyEvent)
			end
		end
		idx = idx + 1
		iCur = iCur + 1
		return true
	end
	self.m_FreeEnergyTimer = Utils.AddTimer(updatesec, 1, 0)
end

--endregion免费体力

--regiron 充值积分
function CWelfareCtrl.InitChargeScore(self)
	self.m_ChargeScoreID = nil
	self.m_ChargeScoreStatus = nil
	self.m_ChargeScoreInfo = nil
	self.m_ChargeStarTime = nil
	self.m_ChargeEndTime = nil
end

function CWelfareCtrl.SetChargeScore(self, cur_id, status, score_info, start_time, end_time)
	self.m_ChargeScoreID = cur_id
	self.m_ChargeScoreStatus = status
	self.m_ChargeScoreInfo = score_info or {}
	self.m_ChargeStarTime = start_time
	self.m_ChargeEndTime = end_time
	self.m_ChargeScoreInfo["buyinfo"] = {}
	if self.m_ChargeScoreInfo["buy_info"] then
		for i,v in ipairs(self.m_ChargeScoreInfo["buy_info"]) do
			if v.id then
				self.m_ChargeScoreInfo["buyinfo"][v.id] = v
			end
		end
	end
	self:OnEvent(define.Welfare.Event.OnChargeScore)
end

function CWelfareCtrl.IsChargeScoreOpen(self)
	return self.m_ChargeScoreID and self.m_ChargeScoreID ~= 0 and self.m_ChargeScoreStatus == 1
end

function CWelfareCtrl.GetChargeScoreInfo(self)
	return self.m_ChargeScoreInfo
end

function CWelfareCtrl.GetChargeScoreID(self)
	return self.m_ChargeScoreID
end

function CWelfareCtrl.GS2CUpdateCSBuyTimes(self, id, buy_times, score)
	score = score or 0
	self.m_ChargeScoreInfo["score"] = score
	if not self.m_ChargeScoreInfo["buyinfo"] then
		self.m_ChargeScoreInfo["buyinfo"] = {}
	end
	if id then
		self.m_ChargeScoreInfo["buyinfo"][id] = {id = id, buy_times=buy_times}
	end
	local oView = CLimitRewardView:GetView()
	if oView and oView.m_RechargeScorePage:GetActive() then
		oView.m_RechargeScorePage:UpdateCSBuyTimes(id, buy_times, score)
	end
	self:OnEvent(define.Welfare.Event.OnChargeScore)
end

--endregion 重置积分

function CWelfareCtrl.CreateChargeBackInfo(self, info)
	local t = {
		rmb = info.rmb,
		left_amount = info.left_amount,
	}
	return t
end

function CWelfareCtrl.InitChargeBack(self, infos, start_time, end_time, schedule)	
	self.m_ChargeBackTimeS = start_time
	self.m_ChargeBackTimeE = end_time
	self.m_ChargeBackSchedule = schedule
	self.m_ChargeInfo = {}
	if infos and next(infos) then
		for _, v in pairs(infos) do
			local vv = self:CreateChargeBackInfo(v)
			self.m_ChargeInfo[vv.rmb] = vv
		end
		self:OnEvent(define.Welfare.Event.OnChargeBack)
	end
end

function CWelfareCtrl.UpdateChargeBack(self, info)
	self.m_ChargeInfo = self.m_ChargeInfo or {}	
	self.m_ChargeInfo[info.rmb] = self:CreateChargeBackInfo(info)
	self:OnEvent(define.Welfare.Event.OnChargeBack)
end

function CWelfareCtrl.GetChargeBackInfo(self)
	self.m_ChargeInfo = self.m_ChargeInfo or {}
	return self.m_ChargeInfo
end

function CWelfareCtrl.IsInChargeBack(self)
    local b = false 
    if self.m_ChargeBackTimeS and self.m_ChargeBackTimeE and self.m_ChargeBackSchedule ~= 0 then
        local s = os.date("*t", self.m_ChargeBackTimeS)
        local e = os.date("*t", self.m_ChargeBackTimeE) 
        local day1 = 
        {
            [1] = s["year"],
            [2] = s["month"],
            [3] = s["day"],
        }
        local day2 = 
        {
            [1] = e["year"],
            [2] = e["month"],
            [3] = e["day"],
        }
        b = g_TimeCtrl:IsInDays(day1, day2)
        local curt = os.date("*t", g_TimeCtrl:GetTimeS())
    end
    return b and g_TimeCtrl:GetTimeS() <= self.m_ChargeBackTimeE
end

function CWelfareCtrl.InitYiYuanLiBao(self)
	self.m_YiYuanLiBaoInfo = {}
	self.m_YiYuanLiBaoStartTime = 0
	self.m_YiYuanLiBaoEndTime = 0
end

function CWelfareCtrl.IsYiYuanLiBaoOpen(self)
	local iNow = g_TimeCtrl:GetTimeS()
	return self.m_YiYuanLiBaoStartTime < iNow and iNow < self.m_YiYuanLiBaoEndTime
end

function CWelfareCtrl.UpdateYiYuanLiBaoList(self, oInfo, starttime, endtime)
	self.m_YiYuanLiBaoInfo = {}
	self.m_YiYuanLiBaoStartTime = starttime
	self.m_YiYuanLiBaoEndTime = endtime
	for i,v in ipairs(oInfo) do
		self.m_YiYuanLiBaoInfo[v.key] = v.done
	end
	self:OnEvent(define.Welfare.Event.OnUpdateYiYuanLiBaoList)
end

function CWelfareCtrl.UpdateYiYuanLiBao(self, oInfo)
	if self.m_YiYuanLiBaoInfo[oInfo.key] then
		self.m_YiYuanLiBaoInfo[oInfo.key] = oInfo.done
		self:OnEvent(define.Welfare.Event.OnUpdateYiYuanLiBao, oInfo)
	end
end

function CWelfareCtrl.IsBuyYiYuanToday(self, id)
	return self.m_YiYuanLiBaoInfo[id] == 1
end

--充值返利
function CWelfareCtrl.InitRechargeWelfare(self)
	self.m_RechargeWelfareRMB = 0
	self.m_RechargeWelfareYueKaCnt = 0
	self.m_RechargeWelfareRMBGold = 0
	self.m_HasRechargeWelfareZSK = false
	self.m_HasRechargeWelfareCZJJ = false
	self.m_HasRechargeWelfareGradeGift = false
	self.m_HasRechargeWelfareOneRMB = false
	self.m_HasRechargeWelfareSpecial = false
end

function CWelfareCtrl.UpdateRechargeWelfare(self, rmb, yueKaCnt, zsk, czjj, gradegift, onermb, special)
	self.m_RechargeWelfareRMB = rmb
	self.m_RechargeWelfareYueKaCnt = yueKaCnt
	self.m_HasRechargeWelfareZSK = zsk
	self.m_HasRechargeWelfareCZJJ = czjj
	self.m_HasRechargeWelfareGradeGift = gradegift
	self.m_HasRechargeWelfareOneRMB = onermb
	self.m_HasRechargeWelfareSpecial = special
	self:OnEvent(define.Welfare.Event.UpdateRechargeWelfare)
end

--限时累充
function CWelfareCtrl.InitRushRecharge(self)
	self.m_RushRechargeInfo = {}
	self.m_RushRechargeProgress = 0
	self.m_RushRechargeStartTime = 0
	self.m_RushRechargeEndTime = 0
end

function CWelfareCtrl.UpdateRushRecharge(self, infoList, progress, starttime, endtime)
	self.m_RushRechargeInfo = {}
	for i,v in ipairs(infoList) do
		self.m_RushRechargeInfo[v.id] = v
	end
	self.m_RushRechargeProgress = progress
	self.m_RushRechargeStartTime = starttime
	self.m_RushRechargeEndTime = endtime
	self:OnEvent(define.Welfare.Event.UpdateRushRecharge)
end

function CWelfareCtrl.TestRushRecharge(self)
	local oData = {}
	for k,v in pairs(data.welfaredata.RushRecharge) do
		if v.plan == 1 then
			local oDataNode = {
				id = v.id,
				receive = v.id % 2
			}
			table.insert(oData, oDataNode)
		end
	end
	self:UpdateRushRecharge(oData, 1000, g_TimeCtrl:GetTimeS(), g_TimeCtrl:GetTimeS() + 86400)
end

function CWelfareCtrl.IsRushRechargeOpen(self)
	local iNow = g_TimeCtrl:GetTimeS()
	return self.m_RushRechargeStartTime < iNow and iNow < self.m_RushRechargeEndTime
end

function CWelfareCtrl.UpdateRushRechargeProgress(self, progress)
	self.m_RushRechargeProgress = progress
	self:OnEvent(define.Welfare.Event.UpdateRushRecharge)
end

function CWelfareCtrl.UpdateRushRechargeList(self, info)
	if self.m_RushRechargeInfo[info.id] then
		self.m_RushRechargeInfo[info.id] = info
		self:OnEvent(define.Welfare.Event.UpdateRushRechargeList, info)
	end
end

--
function CWelfareCtrl.ResetLoopPayInfo(self)
	self.m_LoopPayList = {}
	self.m_LoopPayProgress = 0
	self.m_LoopPayStartTime = 0
	self.m_LoopPayEndTime = 0
	self.m_LoopPayCode = 0
end

function CWelfareCtrl.SetLoopPayInfo(self, dList, iProgress, iStartTime, iEndTime, code)
	self.m_LoopPayList = dList
	self.m_LoopPayProgress = iProgress
	self.m_LoopPayStartTime = iStartTime
	self.m_LoopPayEndTime = iEndTime
	self.m_LoopPayCode = code
end

function CWelfareCtrl.UpdateLoopPayProgress(self, iProgress)
	self.m_LoopPayProgress = iProgress
	self:OnEvent(define.Welfare.Event.UpdateLoopPay)
end

function CWelfareCtrl.UpdateLoopPayUnit(self, unit)
	for i = 1, #self.m_LoopPayList do
		if self.m_LoopPayList[i]["id"] == unit["id"] then
			self.m_LoopPayList[i] = unit
			break
		end
	end
	self:OnEvent(define.Welfare.Event.UpdateLoopPay)
end

function CWelfareCtrl.IsOpenLoopPay(self)
	local iTime = g_TimeCtrl:GetTimeS()
	if self.m_LoopPayStartTime * self.m_LoopPayEndTime ~= 0 then
		if iTime >= self.m_LoopPayStartTime and iTime < self.m_LoopPayEndTime then
			return true
		end
	end
	return false
end

function CWelfareCtrl.IsHasLoopPayRedDot(self)
	if not self:IsOpenLoopPay() then
		return false
	end
	local d = data.welfaredata.LoopPay
	for _, obj in ipairs(self.m_LoopPayList) do
		if g_WelfareCtrl:GetLoopState(obj.id, d[obj.id]["day"]) == 0 then
			return true
		end
	end
	return false
end

function CWelfareCtrl.GetLoopPayTime(self)
	if self.m_LoopPayStartTime ~= 0 then
		local iStartTime = self.m_LoopPayStartTime
		local str1 = os.date("%Y年%m月%d日", iStartTime)

		local iEndTime = self.m_LoopPayEndTime
		local str2 = os.date("%Y年%m月%d日", iEndTime)
		return str1.."-"..str2
	end
	return ""
end

function CWelfareCtrl.GetLoopState(self, id, iDay)
	if iDay > self.m_LoopPayProgress then
		return 2
	else
		for _, obj in ipairs(self.m_LoopPayList) do
			if obj["id"] == id then
				return obj["receive"]
			end
		end
	end
end

function CWelfareCtrl.GetLoopPayCode(self)
	return self.m_LoopPayCode
end

function CWelfareCtrl.ResetLimitPay(self)
	self.m_LimitPayAmount = 0
	self.m_LimitPayData = {}
	self.m_LimitPayStartTime = 0
	self.m_LimitPayEndTime = 0
	self.m_LimitPayPlanID = 0
end

function CWelfareCtrl.RefreshLimitPay(self, iAmount, dData)
	self.m_LimitPayAmount = iAmount
	self.m_LimitPayData = dData
	self:OnEvent(define.Welfare.Event.UpdateLimitPay)
end

function CWelfareCtrl.GetLimitPayState(self, iFuliID)
	for _, obj in ipairs(self.m_LimitPayData) do
		if obj.reward == iFuliID then
			return obj.status
		end
	end
	return 0
end

function CWelfareCtrl.GetLimitPayAmount(self)
	return self.m_LimitPayAmount
end

function CWelfareCtrl.GetLimitPayPlanID(self)
	return self.m_LimitPayPlanID
end

function CWelfareCtrl.UpdateLimitPayTime(self, iStartTime, iEndTime, iPlanID)
	self.m_LimitPayStartTime = iStartTime
	self.m_LimitPayEndTime = iEndTime
	self.m_LimitPayPlanID = iPlanID
end

function CWelfareCtrl.IsOpenLimitPay(self)
	if self.m_LimitPayStartTime == 0 then
		return false
	else
		local iTime = g_TimeCtrl:GetTimeS()
		if iTime >= self.m_LimitPayStartTime and iTime < self.m_LimitPayEndTime then
			return true
		end
	end
	return false
end

function CWelfareCtrl.GetLimitPayRestTime(self)
	if self.m_LimitPayStartTime ~= 0 then
		local iStartTime = self.m_LimitPayStartTime
		local str1 = os.date("%Y年%m月%d日", iStartTime)

		local iEndTime = self.m_LimitPayEndTime
		local str2 = os.date("%Y年%m月%d日", iEndTime)
		return str1.."-"..str2
	end
	return ""
end

function CWelfareCtrl.IsHasLimitPayRedDot(self)
	for k,v in pairs(data.welfaredata.LimitPay) do
		if self.m_LimitPayAmount >= v.condition  then
			if self:GetLimitPayState(v.id) == 0 then
				return true
			end
		end
	end
	return false
end

function CWelfareCtrl.ResetCostScore(self)
	self.m_CostScoreStartTime = 0
	self.m_CostScoreEndTime = 0
end

function CWelfareCtrl.UpdateCostScoreTime(self, iStartTime, iEndTime)
	self.m_CostScoreStartTime = iStartTime
	self.m_CostScoreEndTime = iEndTime
end

function CWelfareCtrl.IsOpenCostScore(self)
	if self.m_CostScoreStartTime == 0 then
		return false
	else
		local iTime = g_TimeCtrl:GetTimeS()
		if iTime >= self.m_CostScoreStartTime and iTime < self.m_CostScoreEndTime then
			return true
		end
	end
	return false
end

function CWelfareCtrl.ResetTestWelfare(self)
	self.m_IsShowTestWelfareRedDot = false
end

function CWelfareCtrl.InitRankBack(self)
	self.m_RankBackStartTime = 0
	self.m_RankBackEndTime = 0
end

function CWelfareCtrl.InitCostSaveTime(self, sTime, eTime, planId)
	self.m_CostSaveStartTime = sTime or 0
	self.m_CostSaveEndTime = eTime or 0
	self.m_CostSavePlanId = planId or 1
end

function CWelfareCtrl.InitCostSaveGold(self, gold, status)
	self.m_CostSaveGold = gold or 0
	self.m_CostSavePercent = 55
	if status == 0 then
		self.m_CostSaveGetStatue = false
	else
		self.m_CostSaveGetStatue = true
	end
	self:OnEvent(define.Welfare.Event.OnCostSaveInfo)
end

function CWelfareCtrl.UpdateRankBack(self, starttime, endtime)
	self.m_RankBackStartTime = starttime
	self.m_RankBackEndTime = endtime
	self:OnEvent(define.Welfare.Event.UpdateRankBack)
end

function CWelfareCtrl.IsRankBackOpen(self)
	local iTime = g_TimeCtrl:GetTimeS()
	if iTime >= self.m_RankBackStartTime and iTime < self.m_RankBackEndTime then
		return true
	end
	return false
end

function CWelfareCtrl.IsOpenQQVip(self)
	return g_QQPluginCtrl:IsQQLogin()
end

return CWelfareCtrl
