local CWarriorDamageHud = class("CWarriorDamageHud", CAsyncHud)

function CWarriorDamageHud.ctor(self, cb)
	CAsyncHud.ctor(self, "UI/Hud/WarriorDamageHud.prefab", cb, true)
end

function CWarriorDamageHud.OnCreateHud(self)
	self.m_NumberBox = self:NewUI(1, CBox)
	self.m_BaojiBg = self:NewUI(2, CSprite)
	self.m_NumberBox:SetActive(false)
	self.m_BaojiBg:SetActive(false)
	local comp = self.m_NumberBox:GetComponent(classtype.DataContainer)
	self.m_AnimTime = comp.floatValue
	self.m_PosList = {}
	self.m_WaitShowList = {}
	self.m_NextShowTime = 0
	self.m_MaxInCol = 6
	
end

function CWarriorDamageHud.Recycle(self)
	if self.m_UpdateTimer  then
		Utils.DelTimer(self.m_UpdateTimer)
		self.m_UpdateTimer = nil
	end
end

function CWarriorDamageHud.ShowDamage(self, iValue, bCrit, bDamageFollow, damage_type)
	local dInfo = {value=iValue, is_crit=bCrit, is_damage = bDamageFollow, damage_type = damage_type}
	table.insert(self.m_WaitShowList, dInfo)
	if not self.m_UpdateTimer  then
		self.m_UpdateTimer = Utils.AddTimer(callback(self, "OnUpdate"), 0, 0)
	end
end

function CWarriorDamageHud.OnUpdate(self, dt)
	local bResetTime = false
	if self.m_NextShowTime <= 0 then
		for i= 1, self.m_MaxInCol do
			local dInfo = self.m_WaitShowList[1]
			if dInfo then
				self:ShowOne(dInfo.value, dInfo.is_crit, dInfo.is_damage, dInfo.damage_type)
				table.remove(self.m_WaitShowList, 1)
			else
				break
			end
			if i == self.m_MaxInCol then
				bResetTime = true
			end
		end
	end
	if bResetTime then
		self.m_NextShowTime = math.random(0.15, 0.3)
	else
		self.m_NextShowTime = self.m_NextShowTime - dt
	end
	return true
end

function CWarriorDamageHud.ShowOne(self, iValue, bCrit, bHudFollow, damage_type)
	local oNumber = self:BuildNumber(iValue, bCrit, damage_type)
	oNumber:SetParent(self.m_Transform)
	local dPosInfo = self:GetPosInfo()
	dPosInfo.is_using = true
	oNumber:SetLocalPos(dPosInfo.pos)
	Utils.AddTimer(function()
		if Utils.IsExist(oNumber) then
			local oAction = CActionFloat.New(oNumber, 0.25, "SetAlpha", 1, 0.3)
			oAction:SetEndCallback(function ()
				if Utils.IsExist(oNumber) then 
					oNumber:Destroy()
				end
			end)
			g_ActionCtrl:AddAction(oAction)
		end
	end, self.m_AnimTime, self.m_AnimTime)
	Utils.AddTimer(function()
		dPosInfo.is_using = false
	end, 0, self:GetUnsePosTime())
	if bHudFollow == false then
		self:SetAutoUpdate(false)
		self:SetActive(true)
	else
		self:SetAutoUpdate(true)
	end
end

function CWarriorDamageHud.GetUnsePosTime(self)
	local col = math.ceil(#self.m_WaitShowList/self.m_MaxInCol)
	if col > 1 then
		return self.m_AnimTime * 0.5
	else
		return self.m_AnimTime
	end
	
end

function CWarriorDamageHud.BuildNumber(self, iValue, bCrit, damage_type)
	local oNumberBox = self.m_NumberBox:Clone()
	oNumberBox:SetActive(true)
	local oNumbseSpr = oNumberBox:NewUI(1, CSprite)
	local oTable = oNumberBox:NewUI(2, CTable)
	local sPrefix = ""
	local bZiYu = iValue > 0 or damage_type == 1
	if bZiYu then
		sPrefix = bCrit and "shuzi_baoji_ziyu" or "shuzi_ziyu"
	else
		sPrefix = bCrit and "shuzi_baoji" or "shuzi_gongji"
	end
	local s = tostring(math.abs(iValue))
	local len = #s
	for i=1, len do
		local sNumber = string.sub(s, i, i)
		local oSpr = oNumbseSpr:Clone()
		oSpr:SetSpriteName(sPrefix..sNumber)
		-- oSpr:MakePixelPerfect()
		--local iScale = 1 - (len-i) * 0.035
		--oSpr:SetLocalScale(Vector3.New(iScale, iScale, iScale))
		oTable:AddChild(oSpr)
	end
	oNumbseSpr:Destroy()
	oTable:Reposition()
	oTable:UITweenPlay()
	local iScale
	if bCrit then
		local oBg = self.m_BaojiBg:Clone()
		local spr = bZiYu and "text_baoji_ziyu" or "text_bao"
		oBg:SetSpriteName(spr)
		oBg:SetActive(true)
		oBg:SetParent(oNumberBox.m_Transform)
		local pos = oBg:GetLocalPos()
		oBg:SetLocalPos(Vector3.New(pos.x + (len/2)*30, 20, 0))
		oBg:UITweenPlay()
	end
	return oNumberBox
end

function CWarriorDamageHud.GetPosInfo(self)
	if next(self.m_PosList) then
		for i, dPosInfo in ipairs(self.m_PosList) do
			if not dPosInfo.is_using then
				return dPosInfo
			end 
		end
	end
	local idx = #self.m_PosList + 1
	local col = math.ceil(idx / self.m_MaxInCol)
	local row = idx % (self.m_MaxInCol)
	if row == 0 then
		row = self.m_MaxInCol
	end
	local iBaseX = 40 + 65 * (col-1)
	local iBaseY = 100 + ((col-1) % 2) * (-15)
	local dPosInfo = {
		pos = Vector3.New(iBaseX - 10 * row, iBaseY - 30 * row, 0),
		is_using = false,
	}
	table.insert(self.m_PosList, dPosInfo)
	return dPosInfo
end


return CWarriorDamageHud