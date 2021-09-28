SummonThingVo = BaseClass(MonsterVo)
SummonThingVo.Type = {
	None = 0, --初始化用
	Normal = 1, --普通召唤
}

function SummonThingVo:__init()
	self.type = PuppetVo.Type.Summon

	self.ownerGuid = 0
	self.die = false
	-----------------------------------------------
end
function SummonThingVo:GetOwnerPlayer()
	if self.die then return nil end
	return SceneModel:GetInstance():GetPlayer(self.ownerGuid)
end
function SummonThingVo:__delete()
	self.ownerGuid = 0
	self.die=true
end