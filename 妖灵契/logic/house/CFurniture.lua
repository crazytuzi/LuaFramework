local CFurniture = class("CFurniture", CObject, CBindObjBase)

function CFurniture.ctor(self, obj, key)
	CObject.ctor(self, obj)
	CBindObjBase.ctor(self, obj)
	-- self:SetName("" .. key)
	self.m_BoxCollider = self:GetMissingComponent(classtype.BoxCollider)
	self.m_Key = key
	self.m_CurMode = nil
	-- self.m_Config = data.housedata.DATA.Config[key] --客户端家具配置信息
	self.m_Config = data.housedata.FurnitureType[key] or {}
	local iType = self.m_Config.type
	-- local iType = self:GetValue("upgrade_type")
	if iType then --可升级家具才有
		self.m_ServerInfo = g_HouseCtrl:GetFurnitureInfo(iType)
		self.m_UpgradeInfo = data.housedata.Upgrade[iType]
	end
	local pos = self.m_Config.operate_pos
	if pos then --可操作家具才有
		self.m_OperateTrans = self:NewBindTransform(Vector3.New(pos.x, pos.y, pos.z))
		self:AddInitHud("house_operate")
	end
	g_HouseCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnHouseEvent"))
	self:Refresh()
end

function CFurniture.Destroy(self)
	self:ClearBindObjs()
	self.m_GameObject = nil
	-- CObject.Destroy(self)
end

function CFurniture.OnHouseEvent(self, oCtrl)
	if oCtrl.m_EventID == define.House.Event.FurnitureRefresh then
		if self:GetValue("upgrade_type") == oCtrl.m_EventData.type then
			self.m_ServerInfo = oCtrl.m_EventData
			self:SetFurnitureMode(self.m_CurMode)
		end
	elseif oCtrl.m_EventID == define.House.Event.AdornRefresh then
		if self:GetValue("adorn_id") == oCtrl.m_EventData.id then
			self:Refresh()
		end
	end
end

function CFurniture.Refresh(self)
	local id = self:GetValue("adorn_id")
	if id then
		local info = g_HouseCtrl:GetAdornInfo(id) or {}
		self:SetActive(info.show == true)
	end
end

function CFurniture.GetValue(self, key)
	if self.m_ServerInfo and self.m_ServerInfo[key] then
		return self.m_ServerInfo[key]
	end
	if self.m_UpgradeInfo and self.m_UpgradeInfo[key] then
		return self.m_UpgradeInfo[key]
	end
	if self.m_Config[key] then
		return self.m_Config[key]
	end
end

function CFurniture.OnTouch(self)
	if not g_HouseCtrl:CanTouch() then
		return
	end
	if self.m_Key == "door" then
		nethouse.C2GSOpenWorkDesk(g_HouseCtrl.m_OwnerPid)
	else
		printc("touch", self.m_Key)
	end
end

function CFurniture.SetFurnitureMode(self, iMode)
	if not self.m_OperateTrans then
		return
	end
	self.m_CurMode = iMode
	local bLock = false
	if iMode == define.House.Mode.Upgrade and self:IsCanUpgrade() then
		if self:IsLock() then
			bLock = true
		else
			self:ShowUpgrade()
			return
		end
	elseif iMode == define.House.Mode.Adorn and self:IsCanAdorn() then
		self:ShowAdorn()
		return
	end
	if bLock then
		self:ShowLock()
	else
		self:HideAll()
	end
end

function CFurniture.GetHudCamera(self)
	return g_CameraCtrl:GetHouseCamera()
end

function CFurniture.IsCanUpgrade(self)
	local iType = self:GetValue("upgrade_type")
	if iType then
		return true
	else
		return false
	end
end

function CFurniture.IsMeetUpgradeRequire(self)
	local dHave = {
		item_cnt = g_HouseCtrl:GetHouseItemAmount(define.Item.ID.ShiJianJiaoLang),
		gold = g_AttrCtrl.coin,
	}
	local bMeet = true
	local iLevel = self:GetValue("level")
	local dTypeNeed = self:GetValue(iLevel)
	for k, iHave in pairs(dHave) do
		local iNeed = dTypeNeed[k]
		if iNeed and iNeed < iHave then
			bMeet = false
			break
		end
	end
	local bMeet
end

function CFurniture.IsCanAdorn(self)
	return self:GetValue("adorns") ~= nil
end

function CFurniture.IsLock(self)
	local iType = self:GetValue("upgrade_type")
	if iType then
		local dInfo = g_HouseCtrl:GetFurnitureInfo(self.m_Type)
		return dInfo and dInfo.lock_status == 0 or false
	else
		return false
	end
end

function CFurniture.ShowUpgrade(self)
	self:SetOperate(function(oHud) oHud:ShowOperate("upgrade") end)
end

function CFurniture.ShowAdorn(self)
	self:SetOperate(function(oHud) oHud:ShowOperate("adorn") end)
end

function CFurniture.ShowLock(self)
	self:SetOperate(function(oHud) oHud:ShowOperate("lock") end)
end

function CFurniture.HideAll(self)
	self:SetOperate(function(oHud) oHud:HideAll() end)
end

function CFurniture.SetUpgradeTime(self, iTime)
	if not self.m_OperateTrans then
		return
	end
	self:SetOperate(function(oHud) oHud:SetUpgradeTime(iTime) end)
end

function CFurniture.GetLeftUpgradeTime(self)
	local iEnd = self:GetValue("create_time") + self:GetValue("secs")
	local iLeft = iEnd - g_TimeCtrl:GetTimeS()
	return iLeft
end

function CFurniture.SetOperate(self, func)
	self:AddHud("house_operate", CHouseOperateHud, self.m_OperateTrans, func, true)
end

function CFurniture.GetAdornList(self)
	local list = {}
	local adorns = self:GetValue("adorns")
	if adorns then
		for i, key in ipairs(adorns) do
			local dConfig = data.housedata.DATA.Config[key]
			local dInfo = g_HouseCtrl:GetAdornInfo(dConfig.adorn_id)
			table.insert(list, {id=dConfig.adorn_id, show=dInfo and dInfo.show or false})
		end
	end
	return list
end

return CFurniture