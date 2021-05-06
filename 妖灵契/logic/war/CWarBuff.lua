local CWarBuff = class("CWarBuff")

function CWarBuff.ctor(self, id, oWarrior)
	self.m_BuffID = id
	self.m_Data = self:GetData(id)
	if not self.m_Data then
		printerror("未配置buff", id, ",用buff编辑器添加")
		return
	end
	self.m_Effects = {common={}, level={}}
	self.m_Mats = {common={}, level={}}
	self.m_WarroiorRef = weakref(oWarrior)
	self.m_FromWid = nil
	self.m_HasProcessed = false
end

function CWarBuff.SetFromWid(self, id)
	self.m_FromWid = id
end

function CWarBuff.SetLevel(self, level)
	self.m_Level = level
	if self.m_Data.buff_type == "normal" then
		self:ProcessNormalType()
	elseif self.m_Data.buff_type == "add" then
		self:ProcessAddType()
	elseif self.m_Data.buff_type == "multi" then
		self:ProcessMultiType()
	elseif self.m_Data.buff_type == "chain" then
		self:ProcessChainType()
	end
	self.m_HasProcessed = true
end

function CWarBuff.ProcessNormalType(self)
	if self.m_HasProcessed then
		return
	end
	for i, dEffect in ipairs(self.m_Data.effect_list) do
		self:AddEffect(dEffect, function(oEffect) table.insert(self.m_Effects.common, oEffect)end
			, function(sMatPath) table.insert(self.m_Mats.common, sMatPath) end)
	end
end

function CWarBuff.ProcessAddType(self)
	local iMaxAdd = self.m_Data.add_cnt
	local dEffectInfo = self.m_Data.effect_list[1]
	for i=1, iMaxAdd do
		if i <= self.m_Level then
			local oExist = self.m_Effects.level[i]
			local iEffectRotate = (360 / self.m_Level) * i
			local function rotate(oEffect)
				if dEffectInfo.pos_type ~= "node" then
					DOTween.DOKill(oEffect.m_Transform, false)
					oEffect:SetEulerAngles(Vector3.New(0, iEffectRotate, 0))
					local tween = DOTween.DOLocalRotate(oEffect.m_Transform, Vector3.New(0, 360, 0), 2.5, enum.DOTween.RotateMode.LocalAxisAdd)
					DOTween.SetEase(tween, enum.DOTween.Ease.Linear)
					DOTween.SetLoops(tween, -1)
				end
				self.m_Effects.level[i] = oEffect
			end
			if oExist then
				rotate(oExist)
			else
				self:AddEffect(dEffectInfo, rotate,function(sMatPath)
					self.m_Mats.level[i] = sMatPath
				end)
		end
		else
			self:DelLevelEffect(i)
		end
	end
end

function CWarBuff.ProcessMultiType(self)
	local iMaxEffect = #self.m_Data.effect_list
	for i=1, iMaxEffect do
		local dEffectInfo = self.m_Data.effect_list[i]
		if i <= self.m_Level then
			if not self.m_Effects.level[i] then
				self:AddEffect(dEffectInfo, function(oEffect)
					self.m_Effects.level[i] = oEffect
				end,
				function(sMatPath)
					self.m_Mats.level[i] = sMatPath
				end)
			end
		else
			self:DelLevelEffect(i)
		end
	end
end

function CWarBuff.ProcessChainType(self)
	if self.m_HasProcessed then
		return
	end
	for i, dEffect in ipairs(self.m_Data.effect_list) do
		if i == 1 then
			local oWarrior = self:GetWarrior()
			if oWarrior and self.m_FromWid and oWarrior.m_ID ~= self.m_FromWid then
				local oFromWarrior = g_WarCtrl:GetWarrior(self.m_FromWid)
				if oFromWarrior then
					local oChainEffect = CChainEffect.New(dEffect.path, oWarrior:GetLayer(), true)
					oFromWarrior.m_Actor:MainModelCall(function(oModel)
						if Utils.IsExist(oChainEffect) then
							local trans = oModel:Find(dEffect.find_path) or oWarrior.m_WaistTrans
							if trans then
								oChainEffect:SetBeginObj(trans)
							end
						end
					end)
					oWarrior.m_Actor:MainModelCall(function(oModel)
						if Utils.IsExist(oChainEffect) then
							local trans = oModel:Find(dEffect.find_path) or oWarrior.m_WaistTrans
							if trans then
								oChainEffect:SetEndObj(trans)
							end
						end
					end)
					table.insert(self.m_Effects.common, oChainEffect)
				end
			end
		else
			self:AddEffect(dEffect, function(oEffect) table.insert(self.m_Effects.common, oEffect)end
			, function(sMatPath) table.insert(self.m_Mats.common, sMatPath) end)
		end
	end
end

function CWarBuff.AddEffect(self, dEffectInfo, fAddEffect, fAddMat)
	local oWarrior = self:GetWarrior()
	if dEffectInfo.path and dEffectInfo.path ~= "" then
		if dEffectInfo.pos_type == "node" or dEffectInfo.pos_type == "model" then
			local function get()
				local oEffect = CEffect.New(dEffectInfo.path, oWarrior:GetLayer(), true)
				oEffect:SetLocalPos(Vector3.New(0, dEffectInfo.height,0))
				fAddEffect(oEffect)
				return oEffect
			end
			if dEffectInfo.pos_type == "node"  then
				oWarrior.m_Actor:BindObjByIdx(dEffectInfo.node_idx, get)
			else
				oWarrior.m_Actor:BindObjByFind(dEffectInfo.find_path, get)
			end
		else
			local oEffect = CEffect.New(dEffectInfo.path, oWarrior:GetLayer(), true)
			oEffect:SetParent(oWarrior:GetBindTrans(dEffectInfo.pos_type))
			oEffect:SetLocalPos(Vector3.New(0, dEffectInfo.height, 0))
			fAddEffect(oEffect)
		end
	end
	if dEffectInfo.mat_path and dEffectInfo.mat_path ~= "" then
		oWarrior.m_Actor:LoadMaterial(dEffectInfo.mat_path)
		fAddMat(dEffectInfo.mat_path)
	end
end

function CWarBuff.DelLevelEffect(self, iLevel)
	if self.m_Effects.level[iLevel] then
		self.m_Effects.level[iLevel]:Destroy()
		self.m_Effects.level[iLevel] = nil
	end
	if self.m_Mats.level[iLevel] then
		local oWarrior = self:GetWarrior()
		oWarrior.m_Actor:DelMaterial(self.m_Mats.level[iLevel])
		self.m_Mats.level[iLevel] = nil
	end
end


function CWarBuff.GetWarrior(self)
	return getrefobj(self.m_WarroiorRef)

end

function CWarBuff.GetData(self, id)
	local d = data.warbuffdata.DATA[id]
	return d
end

function CWarBuff.Clear(self)
	for sType, dEffects in pairs(self.m_Effects) do
		for k, oEffect in pairs(dEffects) do
			if not Utils.IsNil(oEffect) then
				DOTween.DOKill(oEffect.m_Transform, true)
				oEffect:Destroy()
			end
		end
	end
	self.m_Effects = {common={}, level={}}

	local oWarrior = self:GetWarrior()
	for sType, dMats in pairs(self.m_Mats) do
		for k, sMatPath in pairs(dMats) do
			oWarrior.m_Actor:DelMaterial(sMatPath)
		end
	end
	self.m_Mats = {common={}, level={}}
	self.m_HasProcessed = false
end

return CWarBuff