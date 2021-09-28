InscriptionEffectVo =BaseClass()

function InscriptionEffectVo:__init()
	self.slotPos = 0 --铭文槽位
	self.inscriptionId = 0 --铭文表id
	self.effectType = GodFightRuneConst.EffectType.None
	self.effectId = 0 --铭文具体产生效果的id
	self.attrValue = 0--属性值
end

function InscriptionEffectVo:__delete()
	self.slotPos = nil
	self.inscriptionId = nil
	self.effectId = nil
	self.attrValue = nil
end

function InscriptionEffectVo:InitVo(newVo)
	if newVo then
		self.slotPos = newVo.slotPos or 0
		self.inscriptionId = newVo.inscriptionId or 0
		self.effectType = newVo.effectType or GodFightRuneConst.EffectType.None
		self.effectId = newVo.effectId or 0
		self.attrValue = newVo.attrValue or 0
	end
end

