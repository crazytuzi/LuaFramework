--------------------------------------------------------------------------------------
-- 文件名:	Class_CDBar.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	zgj
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	CD控件
-- 应  用:  register， unRegister
---------------------------------------------------------------------------------------


Class_CDBar = class("Class_CDBar")
Class_CDBar.__index = Class_CDBar

function Class_CDBar:onClickRemove(pSender, eventType, nType)
	if eventType == ccs.TouchEventType.ended then 
		cclog("消除冷却时间")
		local gold = g_VIPBase:getVipLevelCDGold(nType)
		if not g_CheckYuanBaoConfirm(gold,_T("您的元宝不足是否前往充值?")) then
			return
		end
		
		local str = _T("是否花费")..gold.._T("元宝清除冷却时间？")
		g_ClientMsgTips:showConfirm(str, function() 
			local function func()
				g_ShowSysTips({text = _T("冷却时间清除成功，下一VIP等级将减少消耗的元宝")})
				self.tb[nType].nStartTime = 0
				self.tb[nType].widget:setVisible(false)
				g_Timer:destroyTimerByID(self.tb[nType].nTimerID)
				if self.tb[nType].func then
					self.tb[nType].func()
				end

				gTalkingData:onPurchase(TDPurchase_Type.TDP_WORLD_BOSS_TWO_REMOVE_CD, 1, gold)
				
			end
			g_VIPBase:responseFunc(func)
			g_VIPBase:requestVipBuyTimesRequest(nType)
		end)
	end
end

function Class_CDBar:updateTime(nType)
	local nTime = self.tb[nType].nCD - (g_GetServerTime() - self.tb[nType].nStartTime)
	if nTime > 0 then
		local cooldown = SecondsToTable(nTime)
		local strTimes = TimeTableToStr(cooldown,":", true)
		if self.tb[nType].Label_CD:isExsit() then
			self.tb[nType].Label_CD:setText(strTimes)
		end
	else
		if self.tb[nType].widget:isExsit() then
			self.tb[nType].widget:setVisible(false)
		end
		g_Timer:destroyTimerByID(self.tb[nType].nTimerID)
		if self.tb[nType].func then
			self.tb[nType].func()
		end
	end
end

--控件， 类型， 开始时间,  结束回调
function Class_CDBar:register(widget, nType, nStartTime, func)
	self.tb[nType] = self.tb[nType] or {}

	widget:setTouchEnabled(true)
	widget:addTouchEventListener(function (pSender,eventType)
			self:onClickRemove(pSender, eventType, nType)
		end)

	self.tb[nType].Label_CD = tolua.cast(widget:getChildByName("Label_CD"), "Label")
	self.tb[nType].widget = widget
	self.tb[nType].func = func
	if self.tb[nType].nTimerID then
		g_Timer:destroyTimerByID(self.tb[nType].nTimerID)
		self.tb[nType].nTimerID = nil
	end

	self.tb[nType].nStartTime = nStartTime or self.tb[nType].nStartTime or 0
	self.tb[nType].nCD = g_VIPBase:getVipLevelCD(nType)
	if g_GetServerTime() - self.tb[nType].nStartTime >= self.tb[nType].nCD then
		widget:setVisible(false)
	else
		widget:setVisible(true)
		self:updateTime(nType)
        g_Timer:destroyTimerByID(self.tb[nType].nTimerID)
		self.tb[nType].nTimerID = g_Timer:pushLoopTimer(1, function ()
				self:updateTime(nType)
			end)
	end
end

function Class_CDBar:unRegister(nType)
	g_Timer:destroyTimerByID(self.tb and self.tb[nType] and self.tb[nType].nTimerID)
end

function Class_CDBar:ctor()
	self.tb = {}
end

g_CDBar = Class_CDBar.new()