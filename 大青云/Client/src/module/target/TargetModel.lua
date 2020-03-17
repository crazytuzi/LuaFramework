--[[
选中目标数据模型(玩家，怪物)
haohu
2014年9月1日10:27:47
]]

_G.TargetModel = Module:new()

TargetModel.id                  = 0
TargetModel.Cid                  = 0
TargetModel[enAttrType.eaName]  = ""
TargetModel[enAttrType.eaLevel] = 0
TargetModel[enAttrType.eaHp]    = 0
TargetModel[enAttrType.eaMaxHp] = 0
TargetModel[enAttrType.eaProf]	= 0
TargetModel.icon                = 0
TargetModel.isLocked            = false

function TargetModel:Init()
	self.id                  = 0
	self[enAttrType.eaName]  = ""
	self[enAttrType.eaLevel] = 0
	self[enAttrType.eaHp]    = 0
	self[enAttrType.eaMaxHp] = 0
	self[enAttrType.eaProf]	 = 0
	self.icon                = 0
	self.isLocked            = false
end

function TargetModel:UpdateTargetAttr(attrType, attrValue)
	if self[attrType] ~= nil and self[attrType] ~= attrValue then
		self[attrType] = attrValue
		self:sendNotification( NotifyConsts.TargetAttrChange, { type = attrType, val = attrValue } )
	end
end

function TargetModel:SetId(id)
	self.id = id;
end

function TargetModel:GetId()
	return self.id;
end


function TargetModel:SetCId(id)
	self.Cid = id;
end

function TargetModel:GetCId()
	return self.Cid;
end

function TargetModel:GetName()
	return self[enAttrType.eaName]
end

function TargetModel:SetName(name)
	self[enAttrType.eaName] = name
end

function TargetModel:GetMaxHp()
	return self[enAttrType.eaMaxHp]
end

function TargetModel:SetMaxHp(maxHp)
	self[enAttrType.eaMaxHp] = maxHp
end

function TargetModel:GetHp()
	return self[enAttrType.eaHp]
end

function TargetModel:SetHp(hp)
	self[enAttrType.eaHp] = hp
end

function TargetModel:GetLevel()
	return self[enAttrType.eaLevel]
end

function TargetModel:SetLevel(level)
	self[enAttrType.eaLevel] = level
end

function TargetModel:SetIcon(icon)
	self.icon = icon;
end

function TargetModel:GetIcon()
	return self.icon;
end

function TargetModel:SetProf(prof)
	self[enAttrType.eaProf] = prof;
end

function TargetModel:GetProf()
	return self[enAttrType.eaProf]
end

function TargetModel:GetLockState()
	return self.isLocked
end

function TargetModel:SetLockState(isLocked)
	if self.isLocked ~= isLocked then
		self.isLocked = isLocked
		self:sendNotification( NotifyConsts.TargetLockStateChange )
	end
end