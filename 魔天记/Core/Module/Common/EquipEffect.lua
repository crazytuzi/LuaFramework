EquipEffect = class("EquipEffect")

--专门用于装备特效
function EquipEffect:New()
	self = {};
	setmetatable(self, {__index = EquipEffect});
	
	return self;
end

function EquipEffect:Init(_effectConfig, parent)
	self._parent = parent
	self._effectConfig = _effectConfig
	self._goEffect = Resourcer.Get("Effect/BuffEffect", self._effectConfig.effect_name, self._parent)	
	if(self._goEffect) then
		Util.SetLocalPos(self._goEffect, self._effectConfig.position_x, self._effectConfig.position_y, self._effectConfig.position_z)
		Util.SetLocalRotation(self._goEffect, self._effectConfig.rotation_x, self._effectConfig.rotation_y, self._effectConfig.rotation_z)					
		self._glowParticle = UIUtil.GetChildByName(self._goEffect, "ParticleSystem", "glow")
		self._smokeParticle = UIUtil.GetChildByName(self._goEffect, "ParticleSystem", "smoke")
		if(self._glowParticle) then
			self._glowParticle.startSize = self._effectConfig.glow_start_size
		end
		
		if(self._smokeParticle) then
			self._smokeParticle.startSize = self._effectConfig.smoke_start_size			
		end	
		
	end
end

function EquipEffect:SetActive(active)
	if(self._goEffect) then
		self._goEffect:SetActive(active)
	end
end

function EquipEffect:ChangeGlowColor(color)
	if(self._glowParticle) then
		self._glowParticle.startColor = color		
	end
end

function EquipEffect:ChangeSmokeColor(color)
	if self._smokeParticle then
		self._smokeParticle.startColor = color
	end	
end

function EquipEffect:Dispose()
	self._glowParticle = nil
	self._smokeParticle = nil
	
	if(self._goEffect) then
		Resourcer.Recycle(self._goEffect, true)
		self._goEffect = nil	
	end	
end

