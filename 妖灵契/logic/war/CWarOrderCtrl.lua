local CWarOrderCtrl = class("CWarOrderCtrl", CDelayCallBase)
CWarOrderCtrl.g_OrderTime = 30
--已支持order
--Attack Magic Escape Protect Defend Call
function CWarOrderCtrl.ctor(self)
	CDelayCallBase.ctor(self)
	self:InitValue()
end

function CWarOrderCtrl.InitValue(self)
	self.m_WaitOrderWids = {}
	self.m_SpeedOrderWids = {}
	self.m_CurOrderWid = nil
	self.m_OrderInfo = {name="", targetID=nil, orderID=nil}
	self.m_IsCanOrder = false
	self.m_IsInSelTarget = false
	self.m_TimeInfo = nil
	self.m_LastOrderMagic = {} -- 记录上一次法术id
	self.m_LocalMagicData = nil
end

function CWarOrderCtrl.GetOrderWid(self)
	return self.m_CurOrderWid
end

function CWarOrderCtrl.IsHeroOrder(self)
	return self.m_CurOrderWid == g_WarCtrl.m_HeroWid
end

function CWarOrderCtrl.GetOrderInfo(self)
	return self.m_OrderInfo
end

function CWarOrderCtrl.IsWaitOrder(self, wid)
	return table.index(self.m_WaitOrderWids, wid) ~= nil
end

function CWarOrderCtrl.OrderStart(self, iOrderTime, oWarrior)
	if g_WarCtrl:GetViewSide() then
		return
	end
	if g_WarCtrl:IsWarStart() then
		return
	end
	local oFloatView = CWarFloatView:GetView()
	if oWarrior:IsCanOrder() then
		self.m_IsCanOrder = true
		self:CheckShowDefaultMagic(true)

		-- self:UpdateWaitOrderWids()
		-- self:SortWaitWids()
		-- self:SetCurOrderWid(self.m_WaitOrderWids[1])
		local oWarView = CWarMainView:GetView()
		if oWarView then
			oWarView:CheckShow()
		end
		iOrderTime = iOrderTime or CWarOrderCtrl.g_OrderTime
		self.m_TimeInfo = {start_time=g_TimeCtrl:GetTimeS(), order_time = iOrderTime}
		if oFloatView then
			oFloatView.m_BoutTimeBox:StartCountDown()
		end
	else
		if oFloatView then
			oFloatView.m_BoutTimeBox:ShowWait(true)
		end
	end
	
end

function CWarOrderCtrl.UpdateWaitOrderWids(self)
	local list = {g_WarCtrl.m_HeroWid}
	for i, oWarrior in pairs(g_WarCtrl:GetWarriors()) do
		if oWarrior:IsAlly() and oWarrior.m_OwnerWid and oWarrior.m_OwnerWid == g_WarCtrl.m_HeroWid
			and #oWarrior.m_MagicList > 0 and not oWarrior:IsOrderDone() then
				table.insert(list, oWarrior.m_ID)
		end
	end
	table.sort(list, WarTools.GetSortFuncSpeed(true))
	self.m_WaitOrderWids = list
end

function CWarOrderCtrl.UpdateSpeedOrderWids(self)
	local list = {}
	for i, oWarrior in pairs(g_WarCtrl:GetWarriors()) do
		if oWarrior:IsAlly() and #oWarrior.m_MagicList > 0 then
			table.insert(list, oWarrior.m_ID)
		end 
	end
	table.sort(list, WarTools.GetSortFuncSpeed(true))
	self.m_SpeedOrderWids = list
end

function CWarOrderCtrl.AddWaitWid(self, wid)
	if not table.index(self.m_WaitOrderWids, wid) then
		table.insert(self.m_WaitOrderWids, wid)
	end
	self:SortWaitWids()
end

function CWarOrderCtrl.SortWaitWids(self)
	table.sort(self.m_WaitOrderWids, WarTools.GetSortFuncSpeed(true))
end

function CWarOrderCtrl.DelWaitWid(self, wid)
	local idx = table.index(self.m_WaitOrderWids, wid)
	if idx then
		table.remove(self.m_WaitOrderWids, idx)
	end
end

function CWarOrderCtrl.GetRemainTime(self)
	if self.m_TimeInfo then
		local iRemain = self.m_TimeInfo.order_time - (g_TimeCtrl:GetTimeS() - self.m_TimeInfo.start_time)
		return math.floor(iRemain)
	else
		return nil
	end
end

function CWarOrderCtrl.IsCanOrder(self)
	return self.m_IsCanOrder
end

function CWarOrderCtrl.FinishOrder(self)
	if self.m_CurOrderWid then
		local oWarrior = g_WarCtrl:GetWarrior(self.m_CurOrderWid)
		if oWarrior then
			oWarrior:DelBindObj("warrior_tip")
			oWarrior:SetOrderDone(true)
		end
		self.m_CurOrderWid = nil
	end
	self.m_IsCanOrder = false
	self:CheckShowDefaultMagic(false)
	self.m_OrderInfo = {name="", targetID=nil, orderID=nil}
	self.m_WaitOrderWids = {}
	self:SetCurOrderWid(nil)
	self:ShowSelectTarget(false)
	self.m_OrderTimeInfo = nil
	self.m_TimeInfo = nil
	local oWarView = CWarMainView:GetView()
	if oWarView then
		oWarView:CheckShow()
	end
	local oFloatView = CWarFloatView:GetView()
	if oFloatView then
		oFloatView:FinishOrder()
	end
	
	g_ViewCtrl:CloseGroup("WarOrder")
end

function CWarOrderCtrl.TimeUp(self, bSendAutoWar)
	printc("TimeUp!!!! Section:".. tostring(g_WarCtrl.m_CurSection))
	if bSendAutoWar then
		netwar.C2GSWarAutoFight(g_WarCtrl:GetWarID(), 2)
	end
	g_WarCtrl:ResumeAfterReplace()
	g_WarCtrl:SetReplace(false)
	self:FinishOrder()
end

function CWarOrderCtrl.SetOrder(self, sOrderName, iOrderID)
	self.m_OrderInfo = {name=sOrderName, targetID=nil, orderID=iOrderID}
	self:CheckSelTarget()
end

function CWarOrderCtrl.CheckSelTarget(self)
	if self.m_OrderInfo.name then
		if self:IsNeedSelTarget(self.m_OrderInfo.name) then
			self:ShowSelectTarget(true)
		else
			self:SendOrder()
		end
	end
end

function CWarOrderCtrl.IsNeedSelTarget(self, sOrderName)
	local list = {"Attack","Magic", "Protect"}
	return table.index(list, sOrderName) ~= nil
end

function CWarOrderCtrl.SetTargetID(self, iTargetID)
	self.m_OrderInfo.targetID = iTargetID
	local oFloatView = CWarFloatView:GetView()
	if oFloatView then
		oFloatView:HideOrderTip()
	end
	self:ShowSelectTarget(false)
	self:SendOrder()
end

function CWarOrderCtrl.ShowSelectTarget(self, bShow)
	local list = g_WarCtrl:GetWarriors()
	for i, oWarrior in pairs(list) do
		if Utils.IsExist(oWarrior) then
			if bShow then
				local bTarget = self:IsOrderTarget(oWarrior)
				oWarrior:ShowSelSpr(bTarget)
				oWarrior.m_Actor:SetColliderEnbled(bTarget or oWarrior:IsAlly() or g_WarCtrl:IsAutoWar())
			else
				oWarrior:ShowSelSpr(false)
				oWarrior.m_Actor:SetColliderEnbled(true)
			end
		end
	end
	self.m_IsInSelTarget = bShow
end

function CWarOrderCtrl.IsInSelTarget(self)
	return self.m_IsInSelTarget == true
end

function CWarOrderCtrl.CancelSelectTarget(self)
	self.m_OrderInfo.orderID = nil
	local oFloatView = CWarFloatView:GetView()
	if oFloatView then
		oFloatView:HideOrderTip()
	end
	self:ShowSelectTarget(false)
end

function CWarOrderCtrl.IsOrderTarget(self, targetobj)
	local funcname = self.m_OrderInfo.name.."Condition"
	local f = self[funcname]
	if f then
		return f(self, targetobj)
	else
		return false
	end
end

function CWarOrderCtrl.SendOrder(self)
	local funcname = self.m_OrderInfo.name.."Send"
	local f = self[funcname]
	if f then
		f(self)
	end
	-- if self.m_OrderInfo.name == "Magic" then
	self:RemoveCurOrder()
	self:ShowNext()
	-- end
end

function CWarOrderCtrl.ChangeAutoMagicByWid(self, wid, magicId, dontSave)
	local oWarrior = g_WarCtrl:GetWarrior(wid)
	if oWarrior then
		if oWarrior.m_ID == g_WarCtrl.m_HeroWid then
			self:ChangeAutoMagic("hero", magicId, dontSave)
		else
			self:ChangeAutoMagic(oWarrior.m_PartnerID, magicId, dontSave)
		end
	end
end

function CWarOrderCtrl.ChangeAutoMagic(self, id, magicId, dontSave)
	-- printc(string.format("ChangeAutoMagic, id:%s, magicId:%s", id, magicId))
	if self.m_LocalMagicData == nil then
		self:ReadLocalSettings()
	end
	if id == nil then
		return
	end
	self.m_LocalMagicData["" .. id] = magicId
	if not dontSave then
		self:SaveLocalSettings()
	end
end

function CWarOrderCtrl.RemoveCurOrder(self)
	local idx = table.index(self.m_WaitOrderWids, self.m_CurOrderWid)
	table.remove(self.m_WaitOrderWids, idx)
end

function CWarOrderCtrl.AutoOrder(self)
	local funcname = self.m_OrderInfo.name.."Send"
	local f = self[funcname]
	if f then
		f(self)
	end
end

function CWarOrderCtrl.ShowNext(self)
	if next(self.m_WaitOrderWids) then
		local wid = self.m_WaitOrderWids[1]
		self:SetCurOrderWid(wid)
	else
		self:FinishOrder()
	end
end

function CWarOrderCtrl.SetCurOrderWid(self, wid)
	if self.m_CurOrderWid == wid then
		return
	end
	local oWarView = CWarMainView:GetView()
	local oLastWarrior = g_WarCtrl:GetWarrior(self.m_CurOrderWid)
	if oLastWarrior then
		oLastWarrior:DelBindObj("warrior_tip") 
		if oWarView then
			local oBox = oWarView.m_RT.m_WarSpeedBox:GetBoxByWid(self.m_CurOrderWid)
			if oBox then
				oBox:ClearEffect()
			end
		end
	end
	if wid then
		local oWarrior = g_WarCtrl:GetWarrior(wid)
		if oWarrior then
			oWarrior:AddBindObj("warrior_tip") 
		end
	end
	self.m_CurOrderWid = wid
end

function CWarOrderCtrl.GetLastMagicID(self, wid)
	if self.m_LocalMagicData == nil then
		self:ReadLocalSettings()
	end
	local oWarrior = g_WarCtrl:GetWarrior(wid)
	if oWarrior then
		if oWarrior.m_ID == g_WarCtrl.m_HeroWid then
			return self.m_LocalMagicData["hero"]
		else
			return self.m_LocalMagicData[tostring(oWarrior.m_PartnerID)]
		end
	end
end

--自动战斗下指令
function CWarOrderCtrl.GetRandomVictim(self, id)
	for i, oWarrior in pairs(g_WarCtrl:GetWarriors()) do
		if self:MagicCondition(oWarrior) then
			return oWarrior
		end
	end
end

function CWarOrderCtrl.HeroAutoWar(self)
	local magic = g_WarCtrl:GetHeroAutoMagic()
	local wid = g_WarCtrl.m_HeroWid
	if not self:AutoMagic(wid, magic) then
		magic = g_WarCtrl:GetDefalutAutoMagic(wid)
		self:AutoMagic(wid, magic)
	end
end

function CWarOrderCtrl.PartnerAutoWar(self, wid)
	local oWarrior = g_WarCtrl:GetWarrior(wid)
	if not oWarrior or not oWarrior.m_PartnerID then
		return
	end
	local magic = oWarrior:GetAutoMagic()
	if not self:AutoMagic(wid, magic) then
		magic = g_WarCtrl:GetDefalutAutoMagic(wid)
		self:AutoMagic(wid, magic)
	end
end

function CWarOrderCtrl.AutoMagic(self, wid, magic)
	if g_WarCtrl:IsCanUseMagic(magic) then
		local dInfo = {name="Magic", orderID=magic}
		self:SetCurOrderWid(wid)
		self.m_OrderInfo = dInfo
		local target = self:GetRandomVictim(magic)
		if target then
			self.m_OrderInfo.targetID = target.id
			self:AutoOrder()
			return true
		end
	end
end


--判断目标函数
function CWarOrderCtrl.AttackCondition(self, targetobj)
	return not targetobj:IsAlly()
end

function CWarOrderCtrl.MagicCondition(self, targetobj)
	local dMagic = DataTools.GetMagicData(self.m_OrderInfo.orderID)
	local bTarget = true
	-- if dMagic.target_status == define.Magic.Status.Alive then
	-- 	bTarget = targetobj:IsAlive()
	-- elseif dMagic.target_status == define.Magic.Status.Died then
	-- 	bTarget = not targetobj:IsAlive()
	-- end
	if bTarget then
		if dMagic.target_type == define.Magic.Target.Ally then
			bTarget = targetobj:IsAlly()
		elseif dMagic.target_type == define.Magic.Target.Enemy then
			bTarget = not targetobj:IsAlly()
		elseif dMagic.target_type == define.Magic.Target.Self then
			bTarget = targetobj.m_ID == self.m_CurOrderWid
		elseif dMagic.target_type == define.Magic.Target.AllyNotSelf then
			bTarget = targetobj:IsAlly() and targetobj.m_ID ~= self.m_CurOrderWid
		end
	end
	return bTarget
end

function CWarOrderCtrl.ProtectCondition(self, targetobj)
	return targetobj:IsAlly() and targetobj.m_Pid ~= g_AttrCtrl.pid
end


--发包函数
function CWarOrderCtrl.AttackSend(self)
	local warid = g_WarCtrl:GetWarID()
	netwar.C2GSWarNormalAttack(warid, self.m_CurOrderWid, self.m_OrderInfo.targetID )
end

function CWarOrderCtrl.MagicSend(self)
	local warid = g_WarCtrl:GetWarID()
	WarTools.print("MagicSend",self.m_OrderInfo.orderID)
	netwar.C2GSWarSkill(warid, {self.m_CurOrderWid}, {self.m_OrderInfo.targetID}, self.m_OrderInfo.orderID)
end

function CWarOrderCtrl.ProtectSend(self)
	local warid = g_WarCtrl:GetWarID()
	netwar.C2GSWarProtect(warid, self.m_CurOrderWid, self.m_OrderInfo.targetID)
end

function CWarOrderCtrl.DefendSend(self)
	local warid = g_WarCtrl:GetWarID()
	netwar.C2GSWarDefense(warid, self.m_CurOrderWid)
end

function CWarOrderCtrl.EscapeSend(self)
	local warid = g_WarCtrl:GetWarID()
	-- netwar.C2GSWarEscape(warid, self.m_CurOrderWid)
	netwar.C2GSWarEscape(warid, g_WarCtrl.m_HeroWid)
end

function CWarOrderCtrl.CallSend(self)
	local warid = g_WarCtrl:GetWarID()
	netwar.C2GSWarSummon(warid, self.m_CurOrderWid, self.m_OrderInfo.orderID)
end

function CWarOrderCtrl.ReadLocalSettings(self)
	local dSkillData = IOTools.GetAutoSkillData()
	self.m_LocalMagicData = {}
	for k,v in pairs(dSkillData) do
		self.m_LocalMagicData[k] = v
	end
end

function CWarOrderCtrl.SaveLocalSettings(self)
	IOTools.SetLocalMagicData(self.m_LocalMagicData)
end

function CWarOrderCtrl.CheckShowDefaultMagic(self, bShow)
	if bShow and not g_WarCtrl:IsAutoWar() then
		for wid, oWarrior in pairs(g_WarCtrl:GetWarriors()) do
			local iMagic = self:GetLastMagicID(wid)
			if oWarrior:IsAlly() and iMagic then
				oWarrior:SetUseMagic(iMagic)
			end
		end
	else
		for wid, oWarrior in pairs(g_WarCtrl:GetWarriors()) do
			oWarrior:SetUseMagic(nil)
		end
	end
end

return CWarOrderCtrl