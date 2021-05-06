local CSevenDayTargetPage = class("CSevenDayTargetPage", CPageBase)

function CSevenDayTargetPage.ctor(self, ob)
	CPageBase.ctor(self, ob)
end

function CSevenDayTargetPage.OnInitPage(self)
	self.m_LeftTimeLabel = self:NewUI(1, CLabel)
	self.m_DayBuyBox = self:NewUI(3, CBox)
	self.m_DayTable = self:NewUI(4, CTable)
	self.m_TargetGrid = self:NewUI(5, CGrid)
	self.m_TargetBox = self:NewUI(6, CBox)
	self.m_TotalLabel = self:NewUI(7, CLabel)
	self.m_RewardGrid = self:NewUI(9, CGrid)
	self:InitContent()
end

function CSevenDayTargetPage.InitContent(self)
	self.m_TargetDic = {}
	self.m_TargetGridList = {}
	self.m_TargetBox:SetActive(false)
	g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWelfareEvent"))
	self:InitDayBuyBox()
	self:InitDayTable()
	self:InitRewardGrid()
	self:DefaulePage()
end

function CSevenDayTargetPage.DefaulePage(self)
	self:RefreshLeftTime()
	self:RefreshTargetTotal()
	local server_day = 0
	for i,oBox in ipairs(self.m_DayTable:GetChildList()) do
		oBox.m_LockSpr:SetActive(oBox.m_Day > server_day) 
	end
	self:RefreshDayBuyBox(1)
end

function CSevenDayTargetPage.OnWelfareEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Welfare.Event.OnSevenDayTarget then
		self:Refresh()
	elseif oCtrl.m_EventID == define.Welfare.Event.OnSevenDayTargetRedDot then	
		self:DelayCall(0, "RefreshRedDot")
	end
end

function CSevenDayTargetPage.Refresh(self)
	if g_WelfareCtrl:IsOpenSevenDayTarget() then
		self:RefreshLeftTime()
		self:RefreshTargetTotal()
		self:RefreshDayTable()
		self:RefreshRedDot()
	else
		if self:GetActive() then
			CWelfareView:CloseView()
		end
	end
end

function CSevenDayTargetPage.RefreshRedDot(self)
	--daytable
	local daytable = g_WelfareCtrl:GetSevenDayTargetRedDot()
	if daytable then
		for i,oBox in ipairs(self.m_DayTable:GetChildList()) do
			if table.index(daytable, oBox.m_Day) and g_WelfareCtrl:GetSevenDayServerDay() + 1 >= oBox.m_Day then
				oBox:AddEffect("RedDot")
			else
				oBox:DelEffect("RedDot")
			end
		end
	end
	--daybuybox
	local daybuybox = g_WelfareCtrl:GetSevenDayTargetTodayRedDot()
	if daybuybox then
		if self.m_DayBuyBox.m_AlreadyBuy then
			self.m_DayBuyBox:DelEffect("RedDot")
		else
			self.m_DayBuyBox:AddEffect("RedDot")
		end
	else
		self.m_DayBuyBox:DelEffect("RedDot")
	end
end

function CSevenDayTargetPage.InitDayBuyBox(self)
	self.m_DayBuyBox.m_CostLabel = self.m_DayBuyBox:NewUI(1, CLabel)
	self.m_DayBuyBox.m_ItemBox = self.m_DayBuyBox:NewUI(2, CItemRewardBox)
	self.m_DayBuyBox.m_XianGouSpr = self.m_DayBuyBox:NewUI(3, CSprite)
	self.m_DayBuyBox.m_YiGouSpr = self.m_DayBuyBox:NewUI(4, CSprite)
	self.m_DayBuyBox.m_IgnoreCheckEffect = true
	
	self.m_DayBuyBox.BuyFun = function ()
		if self.m_DayBuyBox.m_AlreadyBuy then
			g_NotifyCtrl:FloatMsg("已购买该礼包")
		else 
			netachieve.C2GSBuySevenDayGift(self.m_DayBuyBox.m_Day)
			CItemTipsSimpleInfoView:CloseView()
		end
	end
end

function CSevenDayTargetPage.SetDayBuyBoxData(self, dGift)
	local sid = dGift.item.sid
	local num = dGift.item.num
	if string.find(sid, "value") then
		sid, num = g_ItemCtrl:SplitSidAndValue(sid)
	end
	self.m_DayBuyBox.m_Sid = sid
	self.m_DayBuyBox.m_Num = num
	self.m_DayBuyBox.m_Cost = dGift.cost
	self.m_DayBuyBox.m_CostLabel:SetText(dGift.cost)
	local sid = self.m_DayBuyBox.m_Sid 
	local num = self.m_DayBuyBox.m_Num
	local config = {
		isLocal = true,
		buyfun = self.m_DayBuyBox.BuyFun,
	}
	self.m_DayBuyBox.m_ItemBox:SetItemBySid(sid, num, config)
	self.m_DayBuyBox.m_ItemBox:AddUIEvent("click", callback(self, "OnClickDayBuyBox"))
end

function CSevenDayTargetPage.UpdateDayBuyBoxInfo(self, day, already_buy)
	self.m_DayBuyBox.m_Day = day
	self.m_DayBuyBox.m_AlreadyBuy = already_buy
	self.m_DayBuyBox.m_XianGouSpr:SetActive(not already_buy)
	self.m_DayBuyBox.m_CostLabel:SetActive(not already_buy)
	self.m_DayBuyBox.m_YiGouSpr:SetActive(already_buy)
end

function CSevenDayTargetPage.OnClickDayBuyBox(self, oBox)
	local config = {
		isLocal = true,
		buyfun = self.m_DayBuyBox.BuyFun,
	}
	g_WindowTipCtrl:SetWindowItemTipsSimpleItemInfo(self.m_DayBuyBox.m_Sid, {widget = self, side=enum.UIAnchor.Side.Center, behindStrike = self.m_BehindStrike,}, nil, config)
	g_WelfareCtrl:SetSevenDayTargetTodayRedDot(true)
end

function CSevenDayTargetPage.InitDayTable(self)
	self.m_DayTable:InitChild(function(obj, idx)
		local oBox = CBox.New(obj)
		oBox.m_Day = idx
		oBox.m_SelectSpr = oBox:NewUI(1, CSprite)
		oBox.m_LockSpr = oBox:NewUI(2, CSprite)
		oBox.m_LockSpr:SetActive(false)
		oBox.m_IgnoreCheckEffect = true
		oBox:SetGroup(self.m_DayTable:GetInstanceID())
		oBox.m_LockSpr:AddUIEvent("click", function () g_NotifyCtrl:FloatMsg("未达到目标天数，无法切换") end)
		oBox:AddUIEvent("click", callback(self, "OnDayBox"))
		function oBox.SetSelect(self, bValue)
			oBox.m_SelectSpr:SetActive(bValue)
		end
		return oBox
	end)
end

function CSevenDayTargetPage.OnDayBox(self, oBox)
	if self.m_CurDayBox and oBox.m_Day ~= self.m_CurDayBox.m_Day then
		self:SelectBox(oBox.m_Day)
		netachieve.C2GSOpenSevenDay(self.m_CurDayBox.m_Day)
	end
end

function CSevenDayTargetPage.SelectBox(self, day)
	if not day or day < 1 then
		day = 1 
	elseif day > 7 then
		day = 7
	end
	local oBox = self.m_DayTable:GetChild(day)
	if oBox then
		if self.m_CurDayBox then
			self.m_CurDayBox:SetSelect(false)
		end
		self.m_CurDayBox = oBox
		self.m_CurDayBox:SetSelect(true)
		self.m_DayTable:Reposition()
		self:RefreshDayBuyBox(day)	
	end
end

function CSevenDayTargetPage.RefreshDayBuyBox(self, day)
	day = day or self.m_CurDayBox.m_Day
	local dGift = data.achievedata.SevenDayTarget_Gift[day]
	if dGift then
		self:SetDayBuyBoxData(dGift)
	end
	local info = g_WelfareCtrl:GetSevenDayBuy()
	local already_buy = table.index(info, day) ~= nil
	self:UpdateDayBuyBoxInfo(day, already_buy)
end

function CSevenDayTargetPage.InitRewardGrid(self)
	self.m_RewardGrid:InitChild(function(obj, idx)
		if idx == 3 then
			local oBox = CBox.New(obj)
			oBox.m_IconSprite = oBox:NewUI(1, CSprite)
			oBox.m_PointLabel = oBox:NewUI(10, CLabel)
			oBox.m_GotSprite = oBox:NewUI(11, CSprite)
			oBox.m_GotSprite:SetActive(false)
			oBox:AddUIEvent("click", callback(self, "OnRewardBox", idx, oBox))
			return oBox			
		else
			local oBox = CBox.New(obj)
			oBox.m_ItemBox = oBox:NewUI(1, CItemRewardBox)
			oBox.m_PointLabel = oBox:NewUI(2, CLabel)
			oBox.m_GotSprite = oBox:NewUI(3, CSprite)
			oBox.m_GotSprite:SetActive(false)
			oBox:AddUIEvent("click", callback(self, "OnRewardBox", idx, oBox))
			return oBox
		end
	end)
end

function CSevenDayTargetPage.OnRewardBox(self, idx, oBox)
	if oBox.m_AlreadyGet or not oBox.m_CanGet then
		if idx ~= 3 then
			oBox.m_ItemBox:OnClickTipsBox()
		else
			g_WindowTipCtrl:SetTitleSimpleInfoTips(oBox.m_TitleID, {widget = oBox,})
		end
	else
		netachieve.C2GSSevenDayPointReward(oBox.m_ID)
	end
end

--~printc(g_TimeCtrl:Convert(g_WelfareCtrl:GetSevenDayTargetInfo().end_time),"---", g_TimeCtrl:Convert(g_TimeCtrl:GetTimeS()))
function CSevenDayTargetPage.RefreshLeftTime(self)
	local info = g_WelfareCtrl:GetSevenDayTargetInfo()
	if self.m_LeftTimer then
		Utils.DelTimer(self.m_LeftTimer)
		self.m_LeftTimer = nil
	end
	local end_time = g_WelfareCtrl:GetSevenDayTargetEndTime()
	local function countdown()
		if Utils.IsNil(self) then
			return
		end
		if end_time <= 0 then
			self.m_LeftTimeLabel:SetActive(false)
			return
		end
		if end_time < 86400 then
			self.m_LeftTimeLabel:SetText(self:GetLeftTime(end_time))
		else
			self.m_LeftTimeLabel:SetText(self:GetLeftTime(end_time, true))
		end
		end_time = end_time - 1
		return true
	end
	self.m_LeftTimer = Utils.AddTimer(countdown, 1, 0)
end

function CSevenDayTargetPage.GetLeftTime(self, iSec, bDay)
	iSec = math.floor(iSec)
	if bDay then
		local day = math.modf(iSec / 86400)
		local hour = math.modf((iSec % 86400) / 3600)
		local min = math.floor((iSec % 3600) / 60)
		local sec = iSec % 60	
		return string.format("活动倒计时：%d天%02d小时%02d分%02d秒", day, hour, min, sec)
	else
		local hour = math.modf(iSec / 3600)
		local min = math.floor((iSec % 3600) / 60)
		local sec = iSec % 60
		return string.format("活动倒计时：%d小时%02d分%02d秒", hour, min, sec)
	end
end
function CSevenDayTargetPage.RefreshTargetTotal(self)
	local info = g_WelfareCtrl:GetSevenDayTargetInfo()
	local cur_point = info.cur_point or 0
	self.m_TotalLabel:SetText(cur_point)

	local already_get = info.already_get or 0
	local dPointData = data.achievedata.SevenDayTarget_Point
	for i,oBox in ipairs(self.m_RewardGrid:GetChildList()) do
		local d = dPointData[i]
		if d and d.item then
			oBox.m_ID = d.id
			oBox.m_AlreadyGet = table.index(already_get, oBox.m_ID)
			oBox.m_CanGet = cur_point >= d.point
			oBox.m_GotSprite:SetActive(oBox.m_AlreadyGet ~= nil)
			oBox.m_PointLabel:SetText(string.format("完成%d个目标", d.point))
			if i == 3 then
				local dTitle = data.titledata.DATA[d.title]
				oBox.m_TitleID = d.title
				oBox.m_IconSprite:SpriteItemShape(dTitle.item_icon)
				oBox.m_IconSprite:MakePixelPerfect()
				if not oBox.m_AlreadyGet and oBox.m_CanGet then
					oBox.m_IconSprite:AddEffect("round")
				else
					oBox.m_IconSprite:DelEffect("round")
				end
			else
				oBox.m_ItemBox:SetItemBySid(d.item.sid, d.item.num)
				if not oBox.m_AlreadyGet and oBox.m_CanGet then
					oBox.m_ItemBox:GetCurShowBox().m_IconSprite:AddEffect("round")
				else
					oBox.m_ItemBox:GetCurShowBox().m_IconSprite:DelEffect("round")
				end
			end
		end	
	end
end

function CSevenDayTargetPage.RefreshDayTable(self)
	local info = g_WelfareCtrl:GetSevenDayTargetInfo()
	local server_day = info.server_day + 1
	for i,oBox in ipairs(self.m_DayTable:GetChildList()) do
		oBox.m_LockSpr:SetActive(oBox.m_Day > server_day) 
	end
end

function CSevenDayTargetPage.RefreshTargetGrid(self, day, targetlist)
	self:SelectBox(day)
	targetlist = targetlist or {}
	self.m_TargetDic = {}
	local targetlist= self:GetTargetData(targetlist)
	for i,v in ipairs(targetlist) do
		local oBox
		oBox = self.m_TargetGridList[i]
		if oBox then
			oBox = self:UpdateTargetBox(oBox, v)
			oBox:SetActive(true)
		else
			oBox = self:CreateTargetBox()
			oBox = self:UpdateTargetBox(oBox, v)
			oBox:SetActive(true)
			table.insert(self.m_TargetGridList, oBox)
			self.m_TargetGrid:AddChild(oBox)
		end
		oBox:SetName(tostring(oBox.m_TargetID))
		self.m_TargetDic[oBox.m_TargetID] = oBox
	end
	self.m_TargetGrid:Reposition()
	self:RefreshRedDot()
end

function CSevenDayTargetPage.GetTargetData(self, targetlist)
	local targetdic = table.list2dict(targetlist, "id")
	local dData = data.achievedata.SevenDayTarget
	local curday = self.m_CurDayBox and self.m_CurDayBox.m_Day or 1
	local targetlist = {}
	for k,v in pairs(dData) do
		if v.day == curday then
			--排序 1完成<2未完成<3已完成
			local d = targetdic[v.id]
			if d then
				if d.done then
					if d.done == 1 then
						d.sort = 1 
					elseif d.done == 2 then
						d.sort = 3
					end
				else
					d.sort = 2
				end
			else
				d = {
					id = v.id,
					cur = 0,
					sort = 2,--默认未完成
					done = 0,
				}
			end
			table.insert(targetlist, d)
		end
	end

	table.sort(targetlist, function (a, b)
		if a.sort == b.sort then
			return a.id < b.id 
		else
			return a.sort < b. sort
		end
	end)
	return targetlist
end

function CSevenDayTargetPage.CreateTargetBox(self)
	local oBox = self.m_TargetBox:Clone()
	oBox.m_NameLabel = oBox:NewUI(1, CLabel)
	oBox.m_ValueLabel = oBox:NewUI(2, CLabel)
	oBox.m_ItemGrid = oBox:NewUI(3, CGrid)
	oBox.m_ItemBox = oBox:NewUI(4, CItemRewardBox)
	oBox.m_OperateBtn = oBox:NewUI(5, CButton)
	oBox.m_FinishSpr = oBox:NewUI(6, CSprite)
	oBox.m_TweenScale = oBox.m_OperateBtn:GetComponent(classtype.TweenScale)
	oBox.m_TweenScale.enabled = false
	oBox.m_ItemBox:SetActive(false)
	oBox.m_ItemList = {}
	oBox.m_ItemGrid:Clear()
	return oBox
end

function CSevenDayTargetPage.UpdateTargetBox(self, oBox, dTarget)
	local dData = data.achievedata.SevenDayTarget[dTarget.id]
	oBox.m_TargetID = dTarget.id
	oBox.m_Condition = dData.condition
	oBox.m_Max = dData.max
	oBox.m_OpenUI = dData.openui
	oBox.m_Done = dTarget.done
	oBox.m_NameLabel:SetText(dData.name)
	self:UpdateTargetDegree(oBox, dTarget)
	self:UpdateTargetItem(oBox, dData)
	return oBox
end

function CSevenDayTargetPage.UpdateTargetDegree(self, oBox, dTarget)
	local cur = dTarget.cur or 0
	cur = math.min(cur, oBox.m_Max)
	oBox.m_ValueLabel:SetText(string.format("%s/%s", string.numberConvert(cur), string.numberConvert(oBox.m_Max)))

	if not dTarget.done or dTarget.done == define.Achieve.Status.UnFinished then	
		oBox.m_OperateBtn:SetText("前 往")
		oBox.m_OperateBtn:SetActive(true)
		oBox.m_FinishSpr:SetActive(false)
		oBox.m_TweenScale.enabled = false
		oBox.m_OperateBtn:SetLocalScale(Vector3.one)
	elseif dTarget.done == define.Achieve.Status.Finishing then
		oBox.m_OperateBtn:SetText("领 取")
		oBox.m_OperateBtn:SetActive(true)
		oBox.m_FinishSpr:SetActive(false)
		oBox.m_TweenScale.enabled = true
	elseif dTarget.done == define.Achieve.Status.Finished then
		oBox.m_OperateBtn:SetActive(false)
		oBox.m_FinishSpr:SetActive(true)
		oBox.m_TweenScale.enabled = false
		oBox.m_OperateBtn:SetLocalScale(Vector3.one)
	end
	oBox.m_OperateBtn:AddUIEvent("click", callback(self, "OnOperate", oBox))
end

function CSevenDayTargetPage.OnOperate(self, oBox)
	if oBox.m_Done == define.Achieve.Status.Finishing then
		netachieve.C2GSSevenDayReward(oBox.m_TargetID)
	else
		g_OpenUICtrl:OpenUI(oBox.m_OpenUI)
	end
end

function CSevenDayTargetPage.UpdateTargetItem(self, oBox, dData)
	for i,v in ipairs(oBox.m_ItemList) do
		if v then
			v:SetActive(false)
		end
	end
	local lRewardItem = dData.rewarditem
	for i,v in ipairs(lRewardItem) do
		local box = oBox.m_ItemList[i]
		if box then
			box:SetActive(true)
		else
			box = oBox.m_ItemBox:Clone()
			box:SetActive(true)
			table.insert(oBox.m_ItemList, box)
			oBox.m_ItemGrid:AddChild(box)
		end
		box:SetItemBySid(v.sid, v.num)
		oBox.m_ItemGrid:AddChild(box)
	end
	oBox.m_ItemGrid:Reposition()
end

function CSevenDayTargetPage.RefreshTargetOne(self, info)
	local oBox = self.m_TargetDic and self.m_TargetDic[info.id]
	if oBox and info then
		self:UpdateTargetDegree(oBox, info)
	end
end

return CSevenDayTargetPage