CPlayerBuffCtrl = class("CPlayerBuffCtrl", CCtrlBase)

function CPlayerBuffCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:ResetCtrl()
end

function CPlayerBuffCtrl.ResetCtrl(self)
	self.m_BuffItems = {}
	self.m_SidToBuff = {}
	self.m_HouseBuff = {stage = 0, loveship = 0}
	self.m_FirstUpdate = true
end

function CPlayerBuffCtrl.GetBuffList(self)
	return self.m_BuffItems
end

function CPlayerBuffCtrl.InitBuff(self, itemdata)
	if itemdata then
		self.m_BuffItems = {}
		for i, dItem in ipairs(itemdata) do
			local oItem = CItem.New(dItem)
			oItem:SetValue("end_time", oItem:GetValue("end_time") + g_TimeCtrl:GetTimeS())
			self.m_BuffItems[dItem.id] = oItem
			self.m_SidToBuff[dItem.sid] = oItem
		end
	end
	self:OnEvent(define.PlayerBuff.Event.OnRefreshBuff)
end

function CPlayerBuffCtrl.GS2CUpdateBuffItem(self, itemdata)
	local oItem = CItem.New(itemdata)
	oItem:SetValue("end_time", oItem:GetValue("end_time") + g_TimeCtrl:GetTimeS())
	self.m_BuffItems[itemdata.id] = oItem
	self.m_SidToBuff[itemdata.sid] = oItem
	self:OnEvent(define.PlayerBuff.Event.OnRefreshBuff)
end

function CPlayerBuffCtrl.RemoveBuffItem(self, itemid)
	if self.m_BuffItems[itemid] then
		self.m_SidToBuff[self.m_BuffItems[itemid]:GetValue("sid")] = nil
		self.m_BuffItems[itemid] = nil
	end
	self:OnEvent(define.PlayerBuff.Event.OnRefreshBuff)
end

function CPlayerBuffCtrl.UseBuffItem(self, itemID)
	local oItem = g_ItemCtrl:GetItem(itemID)
	local iSid = oItem:GetValue("sid")
	if self.m_SidToBuff[iSid] then
		local windowConfirmInfo = {
			msg = "已使用同种神格，选择需要的操作：\n强化：神格效果提升25%，时间不变\n覆盖：神格剩余时间重置，效果不变",
			okStr = "强化",
			cancelStr = "覆盖",
			okCallback = function()
				g_ItemCtrl:SetShowAttrChangeFlag(true)
				netitem.C2GSBuffStoneOp(itemID, 1)
			end,
			cancelCallback = function()
				g_ItemCtrl:SetShowAttrChangeFlag(true)
				netitem.C2GSBuffStoneOp(itemID, 2)
			end,
			noCancelCbTouchOut = true,
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	else
		g_ItemCtrl:SetShowAttrChangeFlag(true)
		g_ItemCtrl:C2GSItemUse(itemID, g_AttrCtrl.pid, 1)
	end
end

function CPlayerBuffCtrl.AddBuffItem(self, itemdata)
	local oItem = CItem.New(itemdata)
	oItem:SetValue("end_time", oItem:GetValue("end_time") + g_TimeCtrl:GetTimeS())
	self.m_BuffItems[itemdata.id] = oItem
	self.m_SidToBuff[itemdata.sid] = oItem
	self:OnEvent(define.PlayerBuff.Event.OnRefreshBuff)
end

function CPlayerBuffCtrl.HasBuff(self)
	for k,v in pairs(self.m_BuffItems) do
		if v then
			return true
		end
	end
	return false
end

function CPlayerBuffCtrl.UpdateHouseBuff(self, oInfo)
	local lastInfo = self.m_HouseBuff
	self.m_HouseBuff = oInfo
	if (not self.m_FirstUpdate) and lastInfo.stage < oInfo.stage then
		if g_HouseCtrl:IsInHouse() then
			CHouseBuffLvUpView:ShowView()
		else
			CHouseMainView:SetShowCB(function ()
				CHouseBuffLvUpView:ShowView()
				CHouseMainView:ClearShowCB()
			end)
			g_NotifyCtrl:FloatMsg("宅邸BUFF升级了，快去看看吧")
		end
	end
	self.m_FirstUpdate = false
	self:OnEvent(define.PlayerBuff.Event.OnRefreshBuff)
end

function CPlayerBuffCtrl.GetHouseBuff(self)
	return self.m_HouseBuff
end

function CPlayerBuffCtrl.GetHouseAttrStr(self, iLv, sFormat, iNext)
	local tempFormat = sFormat or "%s%s+%s "
	local oData = data.housedata.LoveBuff[iLv]
	local str = ""
	local baseStr = string.replace(oData.buff, "{", "")
	baseStr = string.replace(baseStr, "}", "")

	local ratioStr = string.replace(oData.buff_ratio, "{", "")
	ratioStr = string.replace(ratioStr, "}", "")
	ratioStr = string.replace(ratioStr, "attack", "attack_ratio")
	ratioStr = string.replace(ratioStr, "defense", "defense_ratio")
	ratioStr = string.replace(ratioStr, "maxhp", "maxhp_ratio")
	ratioStr = string.replace(ratioStr, "attack_ratio_ratio", "attack_ratio")
	ratioStr = string.replace(ratioStr, "defense_ratio_ratio", "defense_ratio")
	ratioStr = string.replace(ratioStr, "maxhp_ratio_ratio", "maxhp_ratio")

	baseStr = string.format("%s,%s", baseStr, ratioStr)
	-- printc("baseStr: " .. baseStr)
	local sList = string.split(baseStr, ",")
	for i,v in ipairs(sList) do
		local kvList = string.split(v, "=")
		local key = kvList[1]
		local value = kvList[2]
		str = string.format(tempFormat, str, define.Attr.String[key], g_ItemCtrl:AttrStringConvert(key, value))
		if iNext and i % iNext == 0 and i < #sList then
			str = str .. "\n"
		end
	end
	return str
end

return CPlayerBuffCtrl