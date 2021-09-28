require "Core.Module.Common.UIEffect"

local PetFashionEffect = class("PetFashionEffect", UIEffect)
function PetFashionEffect:New()
	local o = {};
	setmetatable(o, self);
	self.__index = self;
	self._configId = 0
	return o;
end


local colorRay1 = Color.New(1, 1, 1, 1)
local colorCircle1 = Color.New(1, 1, 1, 1)
local colorCircle2 = Color.New(1, 1, 1, 1)
local colorSmoke = Color.New(1, 1, 1, 1)
local colorlizi = Color.New(1, 1, 1, 1)

function PetFashionEffect:SetByConfig(config)
	if(self._configId ~= config.id) then
		self._configId = config.id
		self._effectPath = config.effect_id
		if(self._effect) then
			Resourcer.Recycle(self._effect, false)
			self._effect = nil
		end
		
		if(self._effect == nil) then
			self._effect = UIUtil.GetUIEffect(self._effectPath, self._parent, self._tag, self._offset);
		end
		
		if(self._effect) then
			colorRay1:Set(config.ray1[1], config.ray1[2], config.ray1[3], config.ray1[4])
			colorCircle1:Set(config.circle1[1], config.circle1[2], config.circle1[3], config.circle1[4])
			colorCircle2:Set(config.circle2[1], config.circle2[2], config.circle2[3], config.circle2[4])
			colorSmoke:Set(config.smoke[1], config.smoke[2], config.smoke[3], config.smoke[4])
			colorlizi:Set(config.lizi[1], config.lizi[2], config.lizi[3], config.lizi[4])
	 
			local ray1 = UIUtil.GetChildByName(self._effect, "ParticleSystem", "ray1")
			if(ray1) then
				ray1.startColor = colorRay1
			end
			
			local circle1 = UIUtil.GetChildByName(self._effect, "ParticleSystem", "circle1")			
			if(circle1) then
				circle1.startColor = colorCircle1				
			end
			
			local circle2 = UIUtil.GetChildByName(self._effect, "ParticleSystem", "circle2")
			if(circle2) then
				circle2.startColor = colorCircle2				
			end
			
			local smoke = UIUtil.GetChildByName(self._effect, "ParticleSystem", "smoke")
			if(smoke) then
				smoke.startColor = colorSmoke
			end
			
			local lizi = UIUtil.GetChildByName(self._effect, "ParticleSystem", "lizi")
			if(lizi) then
				lizi.startColor = colorlizi
			end
		end
	end
	
	self:Play()
end

return PetFashionEffect 