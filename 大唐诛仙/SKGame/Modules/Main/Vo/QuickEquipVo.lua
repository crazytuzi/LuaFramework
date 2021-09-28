-- 快捷穿装vo
QuickEquipVo = BaseClass()
QuickEquipVo.curIdx = 1	-- 记录创建顺序

function QuickEquipVo:__init(data)
	self.equipInfo = data
	self:InitIndex()
end

function QuickEquipVo:InitIndex()
	self.index = QuickEquipVo.curIdx
	QuickEquipVo.curIdx = QuickEquipVo.curIdx + 1
end

function QuickEquipVo:GetCreateIndex()
	return self.index or 0
end

function QuickEquipVo:GetGoodsData()
	local t = 1
	local id = self.equipInfo.bid
	local num = 1
	local bind = self.equipInfo.isBinding
	return {t, id, num, bind}
end

function QuickEquipVo:GetEquipType()
	return self.equipInfo.equipType
end

function QuickEquipVo:GetScore()
	return self.equipInfo.score or 0
end

function QuickEquipVo:GetEquipId()
	return self.equipInfo.id
end

function QuickEquipVo:GetEquipInfo()
	return self.equipInfo
end

function QuickEquipVo:IsHaveEquip()
	local equip = PkgModel:GetInstance():GetOnEquipByEquipType(self:GetEquipType())
	if equip then
		return true
	else
		return false
	end
end

function QuickEquipVo:__delete()
	self.equipInfo = nil
end