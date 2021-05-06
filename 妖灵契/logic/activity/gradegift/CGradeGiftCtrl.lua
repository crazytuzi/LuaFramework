local CGradeGiftCtrl = class("CGradeGiftCtrl", CCtrlBase)

function CGradeGiftCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:ResetCtrl()
end

function CGradeGiftCtrl.ResetCtrl(self)
	self.m_ShowEffect = false
	self.m_Grade = 1
	self.m_EndTime = 0
	self.m_FreeGiftList = {}
	self.m_PayGiftList = {}
	self.m_OldPrice = 0
	self.m_NowPrice = 0
	self.m_Discount = 0
	self.m_FirstIn = true
	self.m_Status = define.GradeGift.Status.Over
end

function CGradeGiftCtrl.Test(self)
	g_GradeGiftCtrl:UpdataInfo(25, g_TimeCtrl:GetTimeS()+ 3600, {}, 1000, 800, 80, define.GradeGift.Status.Buying)
end

function CGradeGiftCtrl.UpdataInfo(self, grade, endtime, lBuyGift, oldPrice, nowPrice, discount, status, lFreeGift, openui, payid, iosPayid)
	if status == define.GradeGift.Status.Buying and (openui == 1 or self.m_FirstIn) then
		self.m_ShowEffect = true
	end
	self.m_Grade = grade
	self.m_EndTime = endtime
	self.m_FreeGiftList = lFreeGift
	self.m_PayGiftList = lBuyGift
	self.m_OldPrice = oldPrice
	self.m_NowPrice = nowPrice
	self.m_Discount = discount
	self.m_Status = status
	self.m_Payid = payid
	self.m_IosPayID = iosPayid
	self.m_FirstIn = false
	-- printc("CGradeGiftCtrl UpdataInfo----------------")
	if openui == 1 and not CGradeGiftView:GetView() then
		CGradeGiftView:ShowView()
	else
		self:OnEvent(define.GradeGift.Event.UpdateInfo)
	end
end

function CGradeGiftCtrl.GetStatus(self)
	return self.m_Status
end

function CGradeGiftCtrl.GetRestTime(self)
	local iTime = self.m_EndTime - g_TimeCtrl:GetTimeS()
	if iTime < 0 then
		return 0
	end
	return iTime
end

return CGradeGiftCtrl