MonsterVo = BaseClass(PuppetVo)
MonsterVo.Type = {
	None = 0, -- 初始化用
	Normal = 1, -- 普通小怪
	Elite = 2,  -- 精英怪物
	Boss = 3,   -- boss
	Stupid = 4, -- 只跑不打
}
function MonsterVo:__init()
	--------------------------------------------
	self.exp = 0  --怪物的经验
	self.guid = ""
	self.p_attack = 0
	self.m_attack = 0
	self.p_damage = 0
	self.m_damage = 0
	self.type = PuppetVo.Type.MONSTER
	self.monsterType = MonsterVo.Type.None
	self.die = false
	-----------------------------------------------
	self.buffVoList = {}
end

-- 初始
function MonsterVo:InitVo( attrs)
	for k, v in pairs(attrs) do
		if type(v) ~= "function" and k ~= "_class_type"  then
			if k == "moveSpeed" and v~=0 then
				v = v*0.01
			end
			self[k] = v
		end
	end
	self.buffVoList = attrs.buffVoList
	self:UsedDispatchChange(true)
	self.isCompleted = true

end

-- 更新数据
function MonsterVo:UpdateVo( info )
	for k, v in pairs(info) do
		if type(v) ~= "function" and k ~= "_class_type" then
			if self[k] then
				self:SetValue( k, v, self[k] )
			end
		end
	end
end
-- 设置数值
function MonsterVo:SetValue( k, v, old )
	if not self.isCompleted then return end
	if self[k] ~= v then
		if k == "hp" then
			self:SetValue( "die", v <= 0 )
		end
		if k == "moveSpeed" then
	  		v = v*0.01
   		end
   		self[k] = v
		self:OnChange(k, v, old)
	end
end

-- 不发布属性变化事件
function MonsterVo:UsedDispatchChange( bool )
	self.isUsedispatchchange = bool
end

function MonsterVo:OnChange( key, value, pre )
	if self.isUsedispatchchange then
		self:DispatchEvent(SceneConst.OBJ_UPDATE, key, value, pre)
		if self.monsterType == MonsterVo.Type.Boss then
			GlobalDispatcher:DispatchEvent(EventName.BOSS_INFO_UPDATE,self)
		end
	end
end

function MonsterVo.GetCfg( id )
	return GetCfgData("monster"):Get(id)
end

function MonsterVo:__delete()
	self.die=true
	self.isCompleted = false
	self.isUsedispatchchange = nil
end