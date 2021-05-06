 local CMagicCtrl = class("CMagicCtrl")
define.Magic = {
	Defend_ID = 102,
	Action = {
		Attack = 1,
		Seal = 2,
		Assist = 3,
		Cure = 4,
	},
	Target = {
		Ally = 1,
		Enemy = 2,
		Self = 3,
		AllyNotSelf = 4,
	},
	Status = {
		Alive = 1,
		Died = 2,
		All = 3,
	},
	SpcicalID = {
		GoBack = 99,		
		CreateRole = 98,
		WarSimulate = 97,
		DialogueAni = 96,
	},
	SummonMagic = {
		41602, 31502
	},
}

CMagicCtrl.g_PCall = true

function CMagicCtrl.ctor(self)
	self.m_Units = {}
	self.m_CurUnitIdx = 0
	self.m_DontDestroyEffects = {}
	self.m_CalcPosObject = CObject.New(UnityEngine.GameObject.New("CalcPosObject"))
end

function CMagicCtrl.ResetCalcPosObject(self)
	self.m_CalcPosObject:SetParent(nil, false)
	self.m_CalcPosObject:SetPos(Vector3.zero)
	self.m_CalcPosObject:SetLocalEulerAngles(Vector3.zero)
end

--requireddata 必须传的数据
function CMagicCtrl.NewMagicUnit(self, id, index, requireddata)
	id = id or 1
	index = index or 1
	local dFileData = self:GetFileData(id, index)
	if not dFileData then
		print("默认法术文件都没有")
		return
	end
	
	self.m_CurUnitIdx = self.m_CurUnitIdx + 1
	local oUnit = CMagicUnit.New(self.m_CurUnitIdx)

	oUnit:SetMagicIDAndIdx(tonumber(id), tonumber(index))
	oUnit:SetRequiredData(requireddata)
	oUnit:ParseFileDict(dFileData)
	self.m_Units[self.m_CurUnitIdx] = oUnit
	return oUnit
end

function CMagicCtrl.GetMagicUnit(self, id)
	return self.m_Units[id]
end

function CMagicCtrl.GetMagcAnimStartTime(self, id, index)
	local dFile = self:GetFileData(id, index)
	return dFile.magic_anim_start_time
end

function CMagicCtrl.GetMagcAnimEndTime(self, id, index)
	local dFile = self:GetFileData(id, index)
	return dFile.magic_anim_end_time
end

function CMagicCtrl.TryGetFile(self, id, index)
	local s = string.format("magic_%d_%d", id, index)
	local b, m = pcall(require, "logic.magic.magicfile."..s)
	if b then
		return m.DATA
	end
end

function CMagicCtrl.GetFileData(self, id, index)
	local dFile = self:TryGetFile(id, index) 
	if not dFile then
		if index > 1 then
			dFile = self:TryGetFile(id, 1)
		end
		if not dFile then
			dFile = self:TryGetFile(1, 1)
		end
	end
	return dFile
end

function CMagicCtrl.Update(self, dt)
	local deletes = {}
	for id, oUnit in pairs(self.m_Units) do
		if oUnit:IsGarbage() then
			deletes[id] = true
		else
			local sucess, ret = xxpcall(oUnit.Update, oUnit, dt)
			if not sucess then
				deletes[id] = true
			end
		end
	end
	for id, v in pairs(deletes) do
		self.m_Units[id] = nil
	end
end

function CMagicCtrl.Clear(self, sEnv)
	for id, oUnit in pairs(self.m_Units) do
		if oUnit.m_RunEnv == sEnv then
			oUnit:ClearUnit()
			self.m_Units[id] = nil
		end
	end
	local list = self.m_DontDestroyEffects[sEnv]
	if list and next(list) ~= nil then
		for i, oEffect in ipairs(list) do
			oEffect:Destroy()
		end
		self.m_DontDestroyEffects[sEnv] = nil
	end
end

function CMagicCtrl.AddDontDestroyEffect(self, sEnv, oEff)
	table.safeinsert(self.m_DontDestroyEffects, oEff, sEnv)
end

function CMagicCtrl.IsExcuteMagic(self)
	for id, oUnit in pairs(self.m_Units) do
		if not oUnit:IsGarbage() and oUnit:IsRunning() then
			return true
		end
	end
	return false
end

function CMagicCtrl.IsAllEnd(self)
	for id, oUnit in pairs(self.m_Units) do
		if not oUnit.m_IsEnd then
			return false
		end
	end
	return true
end

return CMagicCtrl