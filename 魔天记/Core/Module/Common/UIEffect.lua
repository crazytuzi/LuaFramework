
UIEffect = class("UIEffect")

function UIEffect:New()
	local o = {};
	setmetatable(o, self);
	self.__index = self;
	return o;
end



function UIEffect:Init(parent, tag, time, effectPath, offset, sc)
	self:_Init(parent, tag, time, effectPath, offset, sc)
end

function UIEffect:_Init(parent, tag, time, effectPath, offset, sc)
	self._parent = parent
	self._time = time
	self._tag = tag
	self._tempTime = 0
	self._effectPath = effectPath
	self._offset = offset or 1
	self._sc = sc or 1;
end

function UIEffect:Play()
	self:Stop()
	if(self._effect == nil) then
		self._effect = UIUtil.GetUIEffect(self._effectPath, self._parent, self._tag, self._offset);
		if self._sc ~= 1 then
			self._effect.transform.localScale = Vector3.New(self._sc, self._sc, self._sc);
		end
		
	end
	if(self._effect) then
		self._effect:SetActive(true)
		if(self._time ~= 0) then
			if(self._timer == nil) then
				self._timer = Timer.New(function() self:Update(time) end, 0, - 1, false)
				self._timer:Start()
			end
			self._timer:Pause(false)
			
		end
	end
end

function UIEffect:SetParent(p)
	if self._effect ~= nil then
		self._effect.transform.parent = p
	end
end

function UIEffect:SetPos(x, y)
	if self._effect ~= nil then
		Util.SetLocalPos(self._effect, x, y, 0);
	end
end

function UIEffect:SetLayer(layer)
	if self._effect ~= nil then
		NGUITools.SetLayer(self._effect, layer)
	end
end

function UIEffect:SetPos1(x, y)
	if self._effect ~= nil then
		Util.SetPos(self._effect, x, y, 0);
	end
end

function UIEffect:GetParticle(particleName)
	if(self._effect and self._particle == nil) then
		self._particle = UIUtil.GetChildByName(self._effect, "ParticleSystem", particleName)
	end
end

function UIEffect:SetColor(r, g, b, a)
	if(self._particle) then
		local color = Color.New(r / 255, g / 255, b / 255, a / 255);
		self._particle.startColor = color
	end
end

function UIEffect:GetEffectPath()
	return self._effectPath
end

function UIEffect:Stop()
	if(self._timer) then
		self._timer:Pause(true)
	end
	if(self._effect) then
		self._effect:SetActive(false)
	end
	
	self._tempTime = 0
end

function UIEffect:ChangeEffect(name)
	if(self._effect) then
		Resourcer.Recycle(self._effect, false)
		self._effect = nil
	end
	
	self._effectPath = name
end

function UIEffect:Dispose()
	self:_Dispose()
end

function UIEffect:Update(time)
	if(self._tempTime >= self._time) then
		self:Stop()
	end
	
	self._tempTime = self._tempTime + Timer.deltaTime
end


function UIEffect:_Dispose()
	if(self._timer) then
		self._timer:Stop()
		self._timer = nil
	end
	
	if(self._effect) then
		Resourcer.Recycle(self._effect)
		self._effect = nil
	end
	
	self._particle = nil;
	
	for k, v in pairs(self) do
		self[k] = nil
	end
end
